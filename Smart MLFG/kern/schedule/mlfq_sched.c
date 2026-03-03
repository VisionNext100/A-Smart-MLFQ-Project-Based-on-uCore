#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <sched.h>
#include <stdio.h>

/* ==================== MLFQ配置参数 ==================== */
#define MLFQ_LEVELS 4                   /* 4级队列 */
#define BOOST_TICKS 1000                /* 防饥饿提升周期 */
#define SCORE_SCALE 1000                /* 评分缩放因子 */
#define IO_BOUND_THRESHOLD  300         /* IO密集型阈值 */

/* 各队列时间片配置（单位：ticks） */
static int level_slice[MLFQ_LEVELS] = {2, 4, 8, 16};

/* 
 * MLFQ私有数据结构
 * 注意：不使用run_queue结构，而是自定义数据结构
 */
struct mlfq_data {
    list_entry_t queues[MLFQ_LEVELS];       /* 4个队列的链表头 */
    unsigned int global_timer;              /* 全局计时器，用于防饥饿 */
};

/* 定义一个静态实例，专门用于 MLFQ 调度 */
static struct mlfq_data mlfq_inst;

/* 
 * mlfq_init - 初始化MLFQ调度器
 * @rq: 运行队列（仅用于proc_num统计）
 */
static void
mlfq_init(struct run_queue *rq) {
    int i;

    /* 初始化4个优先级队列 */
    for (i = 0; i < MLFQ_LEVELS; i++) {
        list_init(&(mlfq_inst.queues[i]));
    }

    /* 初始化全局计时器 */
    mlfq_inst.global_timer = 0;

    /* 初始化运行队列的进程计数 */
    rq->proc_num = 0;

    cprintf("[MLFQ] Init: Levels=%d, Slices=2/4/8/16 (Using static storage)\n", MLFQ_LEVELS);
}

/* 
 * mlfq_predict_and_level_update - 智能预测和队列层级更新
 * @proc: 待更新的进程
 * 
 * 算法原理：
 * 1. 根据进程使用时间片的情况计算本次CPU爆发时间
 * 2. 使用EWMA(指数加权移动平均)更新CPU评分
 * 3. 根据评分和本次行为调整队列层级
 */

static void
mlfq_predict_and_level_update(struct proc_struct *proc) {
    int max_slice, used, ratio;
    int old_level = proc->mlfq_level;/* 保存旧层级用于调试 */
    
    /* 1. 安全性检查：确保层级在有效范围内 */
    if (proc->mlfq_level < 0 || proc->mlfq_level >= MLFQ_LEVELS) 
        proc->mlfq_level = 0;
        
    /* 获取当前队列的时间片长度 */
    max_slice = level_slice[proc->mlfq_level];
    
    /* 2. 计算本次实际使用的CPU时间 */
    if (proc->current_slice_ticks <= 0) {
        used = max_slice; /* 时间片耗尽，使用了全部时间片 */
    } else {
        used = max_slice - proc->current_slice_ticks; /* 主动放弃，计算已用时间 */
    }

    proc->last_burst = used;/* 记录本次爆发时间 */

    /* 3. 计算时间片使用比率 (0-1000) */
    ratio = (used * SCORE_SCALE) / max_slice;
    
    /* 4. EWMA更新CPU评分: NewScore = 0.6*OldScore + 0.4*CurrentRatio */
    /* 公式: NewScore = 0.6 * OldScore + 0.4 * CurrentRatio */
    if (proc->cpu_score == 0) proc->cpu_score = ratio;
    else proc->cpu_score = (6 * proc->cpu_score + 4 * ratio) / 10;

    /* 5. 根据行为调整队列层级 (核心策略) */
    if (proc->current_slice_ticks <= 0) {
        /* 情况 A: 时间片用完 -> 惩罚 (降级) */
        if (proc->mlfq_level < MLFQ_LEVELS - 1) {
            proc->mlfq_level++;
        }
    }
    else {
        /* 情况 B: 主动放弃 (Yield) -> 奖励 */

        /* 如果预测分真的很低 (IO特征明显)，直接提拔到最高级 */
        if (proc->cpu_score < IO_BOUND_THRESHOLD) {
            proc->mlfq_level = 0;
        } 
        /* 否则，稍微奖励一下，提升一级 */
        else if (proc->mlfq_level > 0) {
             proc->mlfq_level--;
        }
    }

    /* 6. 调试信息输出（仅对用户进程） */
    /* 过滤掉 idle (pid=0), init (pid=1) 和 shell (pid=2)，只看我们测试的子进程 */
    if (proc->pid > 2) {
        /* 仅当状态发生有趣变化，或者每隔几次打印一次，避免刷屏 */
        /* 这里我们选择：只要是用户进程，每次入队都打印，以便观察 */
        cprintf("[MLFQ PRED] PID: %d | Used: %d/%d | Score: %d | Level: %d -> %d\n",
                proc->pid,
                used, max_slice,
                proc->cpu_score,
                old_level, proc->mlfq_level);
    }
}

/* 
 * mlfq_enqueue - 将进程加入MLFQ队列
 * @rq: 运行队列
 * @proc: 待入队进程
 */
static void
mlfq_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    /* 使用我们的静态实例 mlfq_inst */
    
    assert(proc->state == PROC_RUNNABLE);

    /* 如果不是首次调度，则进行预测和层级更新 */
    if (proc->sched_count > 0) {
        mlfq_predict_and_level_update(proc);
    } else {
        /* 新进程：默认放在最高优先级队列 */
        proc->mlfq_level = 0;
    }

    /* 设置当前时间片 */
    proc->current_slice_ticks = level_slice[proc->mlfq_level];

    /* 将进程插入对应层级的队列头部 */
    list_add_before(&(mlfq_inst.queues[proc->mlfq_level]), &(proc->run_link));
    
    /* 设置运行队列指针 */
    if (proc->rq != rq) {
        proc->rq = rq;
    }

    /* 仍然维护全局 rq 的计数器，供系统其他部分查询 */
    rq->proc_num++;
}

/* 
 * mlfq_dequeue - 从MLFQ队列中移除进程
 * @rq: 运行队列
 * @proc: 待出队进程
 */
static void
mlfq_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);

    /* 从链表中移除 */
    list_del_init(&(proc->run_link));

    /* 更新运行队列进程计数 */
    rq->proc_num--;
}

/* 
 * priority_boost - 防饥饿机制：将所有进程提升到最高优先级队列
 * 
 * 原理：定时将所有低优先级队列中的进程移到最高优先级队列，
 *       防止CPU密集型进程饥饿IO密集型进程。
 */
static void
priority_boost(void) {
    int i;
    list_entry_t *le, *next;
    struct proc_struct *p;
    
    /* 从第1级队列开始（0级已经是最高的） */
    for (i = 1; i < MLFQ_LEVELS; i++) {
        le = list_next(&(mlfq_inst.queues[i]));

        /* 遍历该层级的所有进程 */
        while (le != &(mlfq_inst.queues[i])) {
            next = list_next(le);
            p = le2proc(le, run_link);
            
            /* 从当前队列移除 */
            list_del_init(le);
            
            /* 提升到最高优先级队列（层级0） */
            p->mlfq_level = 0;
            p->current_slice_ticks = level_slice[0];

            /* 加入到最高优先级队列 */
            list_add_before(&(mlfq_inst.queues[0]), le);
            
            le = next;
        }
    }
    cprintf(" [MLFQ] Priority Boost: Reset all to Level 0\n");
}

/* 
 * mlfq_pick_next - 选择下一个要运行的进程
 * @rq: 运行队列
 * 返回: 下一个要运行的进程，NULL表示没有可运行进程
 * 
 * 调度策略：从最高优先级队列开始查找，找到第一个可运行进程
 */
static struct proc_struct *
mlfq_pick_next(struct run_queue *rq) {
    int i;
    list_entry_t *le;
    struct proc_struct *p;

    /* 检查是否需要防饥饿提升 */
    if (mlfq_inst.global_timer >= BOOST_TICKS) {
        priority_boost();
        mlfq_inst.global_timer = 0;
    }

    /* 从最高优先级（0）到最低优先级（MLFQ_LEVELS-1）扫描队列 */
    for (i = 0; i < MLFQ_LEVELS; i++) {
        if (!list_empty(&(mlfq_inst.queues[i]))) {
            /* 选择该队列的第一个进程（FIFO） */
            le = list_next(&(mlfq_inst.queues[i]));
            p = le2proc(le, run_link);

            /* 增加调度计数（用于行为统计） */
            p->sched_count++; 

            return p;
        }
    }

    /* 没有可运行进程 */
    return NULL;
}

/* 
 * mlfq_proc_tick - 时钟中断处理函数
 * @rq: 运行队列
 * @proc: 当前运行的进程
 * 
 * 功能：
 * 1. 减少当前进程的时间片
 * 2. 更新全局计时器
 * 3. 时间片用完时设置重调度标志
 */
static void
mlfq_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->state == PROC_RUNNABLE) {

        /* 减少当前进程的时间片 */
        proc->current_slice_ticks--;

        /* 时间片用完，需要重新调度 */
        if (proc->current_slice_ticks <= 0) {
            proc->need_resched = 1;
        }
    }

    /* 更新全局计时器（用于防饥饿机制） */
    mlfq_inst.global_timer++;
}

/* 
 * MLFQ调度器类定义
 * 这是调度器框架要求的接口结构
 */
struct sched_class mlfq_sched_class = {
    .name = "mlfq_smart_sched",      /* 调度器名称 */
    .init = mlfq_init,               /* 初始化函数 */
    .enqueue = mlfq_enqueue,         /* 入队函数 */
    .dequeue = mlfq_dequeue,         /* 出队函数 */
    .pick_next = mlfq_pick_next,     /* 选择下一个进程 */
    .proc_tick = mlfq_proc_tick,     /* 时钟中断处理 */
};
