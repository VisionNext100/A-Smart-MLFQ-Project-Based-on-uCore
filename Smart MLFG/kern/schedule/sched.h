#ifndef __KERN_SCHEDULE_SCHED_H__
#define __KERN_SCHEDULE_SCHED_H__

#include <defs.h>
#include <list.h>
#include <skew_heap.h>

/* 最大时间片长度 */
#define MAX_TIME_SLICE 5

/* 前向声明 */
struct proc_struct;

/* 定时器结构 */
typedef struct {
    unsigned int expires;        /* 到期时间 */
    struct proc_struct *proc;    /* 等待的进程 */
    list_entry_t timer_link;     /* 定时器链表节点 */
} timer_t;

/* 定时器转换宏 */
#define le2timer(le, member)            \
to_struct((le), timer_t, member)

/* 定时器初始化函数 */
static inline timer_t *
timer_init(timer_t *timer, struct proc_struct *proc, int expires) {
    timer->expires = expires;
    timer->proc = proc;
    list_init(&(timer->timer_link));
    return timer;
}

/* 前向声明 */
struct run_queue;

/* 
 * 调度器类结构（借鉴Linux设计）
 * 通过调度类实现调度策略的可扩展性
 */
struct sched_class {
    // the name of sched_class
    const char *name; /* 调度器名称 */
    // Init the run queue
    void (*init)(struct run_queue *rq);/* 初始化运行队列 */
    // put the proc into runqueue, and this function must be called with rq_lock
    void (*enqueue)(struct run_queue *rq, struct proc_struct *proc);/* 入队 */
    // get the proc out runqueue, and this function must be called with rq_lock
    void (*dequeue)(struct run_queue *rq, struct proc_struct *proc);/* 出队 */
    // choose the next runnable task
    struct proc_struct *(*pick_next)(struct run_queue *rq);/* 选择下一个 */
    // dealer of the time-tick
    void (*proc_tick)(struct run_queue *rq, struct proc_struct *proc);/* 时钟中断处理 */
    /* for SMP support in the future
     *  load_balance
     *     void (*load_balance)(struct rq* rq);
     *  get some proc from this rq, used in load_balance,
     *  return value is the num of gotten proc
     *  int (*get_proc)(struct rq* rq, struct proc* procs_moved[]);
     */
};

/* 运行队列结构 */
struct run_queue {
    list_entry_t run_list;        /* 运行链表（用于非MLFQ调度器） */
    unsigned int proc_num;        /* 进程数量 */
    int max_time_slice;           /* 最大时间片 */
    // For LAB6 ONLY
    skew_heap_entry_t *lab6_run_pool;/* stride运行池 */
};

/* 函数声明 */
void sched_init(void);
void wakeup_proc(struct proc_struct *proc);
void schedule(void);
void add_timer(timer_t *timer);     // add timer to timer_list
void del_timer(timer_t *timer);     // del timer from timer_list
void run_timer_list(void);          // call scheduler to update tick related info, and check the timer is expired? If expired, then wakup proc

#endif /* !__KERN_SCHEDULE_SCHED_H__ */

