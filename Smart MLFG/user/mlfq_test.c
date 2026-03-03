/* user/mlfq_test.c */
#include <stdio.h>
#include <ulib.h>

/* 模拟 CPU 密集型任务 */
void cpu_bound_task(int id) {
    int i, j;
    int x = 0;
    cprintf("Process %d (CPU-Bound) started.\n", id);
    for (i = 0; i < 10; i++) {
        /* 大量计算，模拟CPU密集型工作 */
        for (j = 0; j < 5000000; j++) {
            x = x + j * i;
        }
        cprintf("CPU Process %d: Computed phase %d\n", id, i);
    }
    cprintf("Process %d finished.\n", id);
}

/* 模拟 IO 密集型任务 (频繁 yield/sleep) */
void io_bound_task(int id) {
    int i;
    cprintf("Process %d (IO-Bound) started.\n", id);
    for (i = 0; i < 20; i++) {
        /* 模拟 IO 等待 (在 uCore 中 yield 可以模拟放弃 CPU) */
        if (i % 2 == 0) {
            cprintf("IO Process %d: Waiting for IO (Yield) phase %d\n", id, i);
        }
        yield(); /* 主动放弃CPU，模拟IO等待 */
    }
    cprintf("Process %d finished.\n", id);
}

/* 主函数：创建混合工作负载测试MLFQ调度器 */
int main(void) {
    int pid1, pid2, pid3;

    cprintf("MLFQ Test: Starting Mixed Workload...\n");

    /* 创建第一个子进程：CPU密集型任务 */
    if ((pid1 = fork()) == 0) {
        cpu_bound_task(1); /* 子进程 1: CPU */
        exit(0);
    }

    /* 创建第二个子进程：IO密集型任务 */
    if ((pid2 = fork()) == 0) {
        io_bound_task(2);  /* 子进程 2: IO */
        exit(0);
    }

    /* 创建第三个子进程：另一个CPU密集型任务（干扰项） */
    if ((pid3 = fork()) == 0) {
        cpu_bound_task(3); /* 子进程 3: CPU (干扰项) */
        exit(0);
    }

    /* 父进程等待所有子进程结束 */
    waitpid(pid1, NULL);
    waitpid(pid2, NULL);
    waitpid(pid3, NULL);

    cprintf("MLFQ Test: All Finished.\n");
    return 0;
}