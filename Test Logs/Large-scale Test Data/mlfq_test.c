#include <stdio.h>
#include <ulib.h>
#include <string.h>

/* --- 压力测试配置 --- */
const int TOTAL_PHASES = 80;         // 增大到 80 轮，让调度器充分“热身”
const int CPU_LOOP_COUNT = 4000000;  // 增大计算量，确保由 Timeout 触发降级
const int IO_LOOP_COUNT  = 50000;    // 模拟少量的 I/O 处理时间

/* 辅助：获取当前毫秒时间 */
int get_time() {
    return (int)gettime_msec();
}

/* 1. 纯 CPU 密集型任务 (重负载) */
void cpu_heavy_task(int id, int arrival_time) {
    int start_time = get_time();
    int response_time = start_time - arrival_time;

    // 减少过程打印，避免 I/O 刷屏影响测速
    cprintf("(PID %d) [CPU-Heavy] Started. Resp: %d ms\n", id, response_time);

    int i, j;
    volatile int x = 0;
    for (i = 0; i < TOTAL_PHASES; i++) {
        /* 疯狂计算 */
        for (j = 0; j < CPU_LOOP_COUNT; j++) {
            x = x + j * i;
        }
        /* 每 20 轮才打印一次进度 */
        if (i % 20 == 0 || i == TOTAL_PHASES - 1) {
            cprintf("    (PID %d) CPU Phase %d/%d\n", id, i, TOTAL_PHASES);
        }
    }

    int end_time = get_time();
    int turn_time = end_time - arrival_time;

    // 使用统一的 [RESULT] 标签方便查看
    cprintf("[RESULT] PID: %d | Type: CPU-Heavy | Resp: %d ms | Turnaround: %d ms\n",
            id, response_time, turn_time);
}

/* 2. 纯 I/O 密集型任务 (高频交互) */
void io_heavy_task(int id, int arrival_time) {
    int start_time = get_time();
    int response_time = start_time - arrival_time;

    cprintf("(PID %d) [IO-Heavy ] Started. Resp: %d ms\n", id, response_time);

    int i, j;
    volatile int x = 0;
    for (i = 0; i < TOTAL_PHASES; i++) {
        /* 稍微做一点点事，然后立马 Yield */
        for (j = 0; j < IO_LOOP_COUNT; j++) x++;

        yield(); // 主动让出

        if (i % 20 == 0 || i == TOTAL_PHASES - 1) {
             cprintf("    (PID %d) I/O Yield %d/%d\n", id, i, TOTAL_PHASES);
        }
    }

    int end_time = get_time();
    int turn_time = end_time - arrival_time;
    cprintf("[RESULT] PID: %d | Type: IO-Heavy  | Resp: %d ms | Turnaround: %d ms\n",
            id, response_time, turn_time);
}

/* 3. 混合型任务 (模拟真实负载：有时计算，有时等待) */
void mixed_task(int id, int arrival_time) {
    int start_time = get_time();
    int response_time = start_time - arrival_time;

    cprintf("(PID %d) [Mixed-Work] Started. Resp: %d ms\n", id, response_time);

    int i, j;
    volatile int x = 0;
    for (i = 0; i < TOTAL_PHASES; i++) {
        /* 逻辑：每 10 轮里，有 2 轮疯狂计算(Burst)，8 轮休息(Yield) */
        if (i % 10 < 2) {
            // 模拟突发计算 (CPU Burst)
            for (j = 0; j < CPU_LOOP_COUNT; j++) x += j;
        } else {
            // 模拟等待用户输入 (IO Wait)
            for (j = 0; j < IO_LOOP_COUNT; j++) x++;
            yield();
        }

        if (i % 20 == 0 || i == TOTAL_PHASES - 1) {
             cprintf("    (PID %d) Mix Phase %d/%d\n", id, i, TOTAL_PHASES);
        }
    }

    int end_time = get_time();
    int turn_time = end_time - arrival_time;
    cprintf("[RESULT] PID: %d | Type: Mixed-Work| Resp: %d ms | Turnaround: %d ms\n",
            id, response_time, turn_time);
}

int main(void) {
    int pids[5];
    int arrival_times[5];
    int i;

    cprintf("\n=======================================================\n");
    cprintf("      STRESS TEST: 5 Processes (2 CPU, 2 IO, 1 Mixed)\n");
    cprintf("=======================================================\n");

    /* 启动 5 个进程，模拟高并发 */

    // 1. CPU Heavy
    arrival_times[0] = get_time();
    if ((pids[0] = fork()) == 0) { cpu_heavy_task(3, arrival_times[0]); exit(0); }

    // 2. IO Heavy (应该很快)
    arrival_times[1] = get_time();
    if ((pids[1] = fork()) == 0) { io_heavy_task(4, arrival_times[1]); exit(0); }

    // 3. CPU Heavy (增加竞争)
    arrival_times[2] = get_time();
    if ((pids[2] = fork()) == 0) { cpu_heavy_task(5, arrival_times[2]); exit(0); }

    // 4. Mixed (测试智能调度)
    arrival_times[3] = get_time();
    if ((pids[3] = fork()) == 0) { mixed_task(6, arrival_times[3]); exit(0); }

    // 5. IO Heavy (增加 IO 队列长度)
    arrival_times[4] = get_time();
    if ((pids[4] = fork()) == 0) { io_heavy_task(7, arrival_times[4]); exit(0); }

    /* 等待所有子进程结束 */
    for (i = 0; i < 5; i++) {
        waitpid(pids[i], NULL);
    }

    cprintf("\n=======================================================\n");
    cprintf("                  TEST COMPLETE                        \n");
    cprintf("=======================================================\n");
    return 0;
}
