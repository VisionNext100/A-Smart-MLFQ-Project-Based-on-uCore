#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <sched.h>
#include <stdio.h>

/* 
 * RR调度器 - 时间片轮转
 * 特点：所有进程平等，固定时间片，FIFO循环调度
 */

/* 
 * rr_init - 初始化RR调度器
 * @rq: 运行队列
 */
static void
rr_init(struct run_queue *rq) {
    list_init(&(rq->run_list));     /* 初始化运行链表 */
    rq->proc_num = 0;               /* 进程计数清零 */
    cprintf("[RR] Init: Round Robin Scheduler Enabled\n");
}


/* 
 * rr_enqueue - 将进程加入RR队列
 * @rq: 运行队列
 * @proc: 待入队进程
 * 
 * 策略：进程总是加到队列尾部，保证FIFO顺序
 */
static void
rr_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    assert(proc->state == PROC_RUNNABLE);

    /* 每次都加到队尾，维持FIFO顺序 */
    list_add_before(&(rq->run_list), &(proc->run_link));
    
    /* 重置固定时间片（使用运行队列的最大时间片） */
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) { 
        proc->time_slice = rq->max_time_slice;/* 固定为MAX_TIME_SLICE（通常5） */
    }
    
    /* 设置运行队列指针并更新计数 */
    proc->rq = rq;
    rq->proc_num++;
}

/* 
 * rr_dequeue - 从RR队列中移除进程
 * @rq: 运行队列
 * @proc: 待出队进程
 */
static void
rr_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
    list_del_init(&(proc->run_link));/* 从链表中移除 */
    rq->proc_num--;/* 更新进程计数 */
}

/* 
 * rr_pick_next - 选择下一个要运行的进程
 * @rq: 运行队列
 * 返回: 队列中的第一个进程（FIFO）
 * 
 * 策略：总是选择队列头的进程，实现轮转
 */
static struct proc_struct *
rr_pick_next(struct run_queue *rq) {
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list)) {
        return le2proc(le, run_link);/* 返回队列第一个进程 */
    }
    return NULL;/* 队列为空 */
}

/* 
 * rr_proc_tick - 时钟中断处理
 * @rq: 运行队列
 * @proc: 当前运行的进程
 * 
 * 功能：减少时间片，时间片用完时设置重调度标志
 */
static void
rr_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if (proc->time_slice > 0) {
        proc->time_slice--;/* 减少时间片 */
    }
    if (proc->time_slice == 0) {
        proc->need_resched = 1;/* 时间片用完，需要重新调度 */
    }
}

/* 
 * RR调度器类定义
 * 实现sched_class接口
 */
struct sched_class rr_sched_class = {
    .name = "rr_scheduler",          /* 调度器名称 */
    .init = rr_init,                 /* 初始化函数 */
    .enqueue = rr_enqueue,           /* 入队函数 */
    .dequeue = rr_dequeue,           /* 出队函数 */
    .pick_next = rr_pick_next,       /* 选择下一个进程 */
    .proc_tick = rr_proc_tick,       /* 时钟中断处理 */
};
