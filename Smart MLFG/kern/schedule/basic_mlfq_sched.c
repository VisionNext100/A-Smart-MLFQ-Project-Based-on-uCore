#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <sched.h>
#include <stdio.h>

/* ==================== 基础MLFQ配置 ==================== */
#define MLFQ_LEVELS 4                   /* 4级队列 */
#define BOOST_TICKS 1000                /* 防饥饿提升周期，与智能版本保持一致以公平对比 */

/* 各队列时间片配置（与智能版本相同） */
static int level_slice[MLFQ_LEVELS] = {2, 4, 8, 16};

/* 
 * MLFQ私有数据结构
 * 与智能版本相同的数据结构，确保对比公平性
 */
struct mlfq_data {
    list_entry_t queues[MLFQ_LEVELS];/* 4个队列的链表头 */
    unsigned int global_timer;/* 全局计时器，用于防饥饿 */
};

/* 全局MLFQ实例 */
static struct mlfq_data mlfq_inst;

/* 
 * basic_mlfq_init - 初始化基础MLFQ调度器
 * @rq: 运行队列
 * 
 * 初始化所有队列和全局计时器
 */
static void
basic_mlfq_init(struct run_queue *rq) {
    int i;
    for (i = 0; i < MLFQ_LEVELS; i++) {
        list_init(&(mlfq_inst.queues[i]));/* 初始化每个队列 */
    }
    mlfq_inst.global_timer = 0;/* 全局计时器清零 */
    rq->proc_num = 0;/* 进程计数清零 */
    cprintf("[Basic MLFQ] Init: No Smart Prediction.\n");/* 标识为基础版本 */
}

/* 
 * basic_mlfq_update_level - 基础MLFQ层级调整
 * @proc: 待更新的进程
 * 
 * 简单规则：
 * 1. 时间片耗尽 → 降一级（惩罚）
 * 2. 主动放弃 → 回到最高级（奖励）
 * 
 * 问题：无法区分真正的IO密集进程和恶意刷分的进程
 */
static void
basic_mlfq_update_level(struct proc_struct *proc) {
    /* 边界检查：确保层级在有效范围内 */
    if (proc->mlfq_level < 0 || proc->mlfq_level >= MLFQ_LEVELS) 
        proc->mlfq_level = 0;

    if (proc->current_slice_ticks <= 0) {
        /* 情况1：时间片耗尽 → 降级（惩罚） */
        if (proc->mlfq_level < MLFQ_LEVELS - 1) {
            proc->mlfq_level++;/* 降一级 */
        }
    } else {
        /* 情况2：主动放弃 → 直接回最高级（盲目奖励）
         * 缺陷：无法区分"真的IO密集"还是"恶意刷分"
         */
        proc->mlfq_level = 0; /* 直接回到最高优先级 */
    }
    
    /* 调试信息：对比智能版本 */
    if (proc->pid > 2) {/* 过滤系统进程 */
         cprintf("[Basic MLFQ] PID: %d | Level: %d (Logic: Timeout->Down, Yield->Top)\n", 
                 proc->pid, proc->mlfq_level);
    }
}

/* 
 * basic_mlfq_enqueue - 将进程加入基础MLFQ队列
 * @rq: 运行队列
 * @proc: 待入队进程
 */
static void
basic_mlfq_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    assert(proc->state == PROC_RUNNABLE);

    /* 如果不是首次调度，则更新层级 */
    if (proc->sched_count > 0) {
        basic_mlfq_update_level(proc);/* 应用简单规则调整层级 */
    } else {
        proc->mlfq_level = 0;/* 新进程：默认最高优先级 */
    }

    /* 重置当前时间片（根据当前层级） */
    proc->current_slice_ticks = level_slice[proc->mlfq_level];

    /* 将进程插入对应层级的队列头部 */
    list_add_before(&(mlfq_inst.queues[proc->mlfq_level]), &(proc->run_link));
    
    /* 设置运行队列指针并更新计数 */
    if (proc->rq != rq) proc->rq = rq;
    rq->proc_num++;
}

/* 
 * basic_mlfq_dequeue - 从基础MLFQ队列中移除进程
 * @rq: 运行队列
 * @proc: 待出队进程
 */
static void
basic_mlfq_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
    list_del_init(&(proc->run_link));/* 从链表中移除 */
    rq->proc_num--;/* 更新进程计数 */
}

/* 
 * priority_boost - 防饥饿机制
 * 
 * 功能：将所有低优先级队列中的进程提升到最高优先级队列
 * 与智能版本保持相同的实现，确保对比公平性
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
    cprintf(" [Basic MLFQ] Priority Boost Triggered.\n");
}

/* 
 * basic_mlfq_pick_next - 选择下一个要运行的进程
 * @rq: 运行队列
 * 返回: 下一个要运行的进程
 * 
 * 策略：从最高优先级队列开始查找，找到第一个可运行进程
 */
static struct proc_struct *
basic_mlfq_pick_next(struct run_queue *rq) {
    int i;
    list_entry_t *le;
    struct proc_struct *p;

    /* 检查是否需要防饥饿提升 */
    if (mlfq_inst.global_timer >= BOOST_TICKS) {
        priority_boost();/* 执行防饥饿提升 */
        mlfq_inst.global_timer = 0;/* 重置计时器 */
    }

    /* 从最高优先级（0）到最低优先级（MLFQ_LEVELS-1）扫描队列 */
    for (i = 0; i < MLFQ_LEVELS; i++) {
        if (!list_empty(&(mlfq_inst.queues[i]))) {

            /* 选择该队列的第一个进程（FIFO） */
            le = list_next(&(mlfq_inst.queues[i]));
            p = le2proc(le, run_link);

            p->sched_count++; /* 增加调度计数 */
            return p;
        }
    }
    return NULL;/* 没有可运行进程 */
}

/* 
 * basic_mlfq_proc_tick - 时钟中断处理
 * @rq: 运行队列
 * @proc: 当前运行的进程
 * 
 * 功能：减少当前进程的时间片，更新全局计时器
 */
static void
basic_mlfq_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->state == PROC_RUNNABLE) {
        proc->current_slice_ticks--;/* 减少时间片 */

        /* 时间片用完，需要重新调度 */
        if (proc->current_slice_ticks <= 0) {
            proc->need_resched = 1;
        }
    }
    mlfq_inst.global_timer++;/* 更新全局计时器（用于防饥饿） */
}

/* 
 * 基础MLFQ调度器类定义
 * 实现sched_class接口
 */
struct sched_class basic_mlfq_sched_class = {
    .name = "basic_mlfq_scheduler",   /* 调度器名称 */
    .init = basic_mlfq_init,          /* 初始化函数 */
    .enqueue = basic_mlfq_enqueue,    /* 入队函数 */
    .dequeue = basic_mlfq_dequeue,    /* 出队函数 */
    .pick_next = basic_mlfq_pick_next,/* 选择下一个进程 */
    .proc_tick = basic_mlfq_proc_tick,/* 时钟中断处理 */
};