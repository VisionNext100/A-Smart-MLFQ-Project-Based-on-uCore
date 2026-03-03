#  基于 uCore 操作系统的多级反馈队列调度器与智能行为预测实现

本项目基于清华大学uCore OS教学实验代码修改。<br>原始代码版权归清华大学所有，遵循GPLv2协议。



## 项目概述

### 项目描述

**项目名称**：OS-2025-Smart MLFQ

**高校名称**：华东师范大学

**队伍ID**：T202510269998251

**队伍名**：3FW

**选题方向**：模块实验设计（进程调度算法）

### 项目介绍

这是一个基于 uCore 操作系统的内核级调度器改进项目，实现了 **多级反馈队列(MLFQ)** 调度算法，并创新性地引入了 **智能行为预测机制**。通过指数加权移动平均(EWMA)算法，调度器能够自动识别CPU密集型和IO密集型进程，实现动态优先级调整。

### 对比算法
为了验证智能MLFQ的优势，我们同时实现了两种基准调度器：
1. **时间片轮转(RR)** - 简单公平调度算法
2. **基础MLFQ** - 传统多级反馈队列算法
3. **智能MLFQ** (核心) - 引入行为预测的改进算法

### 项目文件分支
- [Smart MLFQ完整代码](https://gitlab.eduxiji.net/T202510269998251/project3035746-358881/-/tree/main/Smart%20MLFG)
- [实验指导书](https://gitlab.eduxiji.net/T202510269998251/project3035746-358881/-/blob/main/%E5%AE%9E%E9%AA%8C%E6%8C%87%E5%AF%BC%E4%B9%A6/Smart%20MLFQ%E5%AE%9E%E9%AA%8C%E6%8C%87%E5%AF%BC%E4%B9%A6.pdf)
- [测试日志](https://gitlab.eduxiji.net/T202510269998251/project3035746-358881/-/tree/main/%E6%B5%8B%E8%AF%95%E6%97%A5%E5%BF%97)
- [demo（video）](https://gitlab.eduxiji.net/T202510269998251/project3035746-358881/-/blob/main/demo(video)/demo.mp4)

## 开发环境搭建

### 硬件要求

-   **主机内存**：≥ 8GB RAM
-   **CPU**：支持虚拟化技术
-   **硬盘空间**：≥ 20GB 可用空间

### 软件要求

-   **VirtualBox 7.0+** 或 **QEMU 6.0+**
-   **Ubuntu 22.04 LTS**（虚拟机环境）
-   **编译工具链**：gcc, make, git, qemu-system-x86

### 环境配置步骤
进入 Ubuntu 环境（虚拟机/WSL）后，运行：
```bash
# 1. 安装必要工具（Ubuntu/Debian）
sudo apt update
sudo apt install -y build-essential git qemu-system-x86 gcc-multilib

# 验证安装
qemu-system-x86_64 --version
gcc --version
make --version
```

## 快速开始

### 编译运行
```bash
# 1. 克隆仓库
# 1. 克隆本仓库（包含完整的 uCore + 智能调度器实现）
git clone https://github.com/VisionNext100/A-Smart-MLFQ-Project-Based-on-uCore.git
cd A-Smart-MLFQ-Project-Based-on-uCore

# 2. 选择调度算法（编辑 kern/schedule/sched.c）
# 取消注释对应的调度器类：
#   &rr_sched_class         # RR调度器
#   &basic_mlfq_sched_class # 基础MLFQ
#   &mlfq_sched_class       # 智能MLFQ（默认）

# 3. 编译内核
make clean
make

# 4. 运行测试
make qemu
```

## 使用指南

### 测试程序说明

内核启动后会自动运行 `mlfq_test` 程序，该程序创建：

-   **2个CPU密集型进程**：执行大量计算
-   **2个IO密集型进程**：频繁让出CPU
-   **1个混合型进程**：混合CPU和IO操作

### 手动测试

```bash
# 内核启动后，在uCore shell中可以：
$ mlfq_test            # 运行完整测试
$ test_rr              # 仅测试RR调度器
$ test_basic_mlfq      # 仅测试基础MLFQ
$ test_smart_mlfq      # 仅测试智能MLFQ

# 查看调度统计信息
$ sched_info
```

### 性能对比测试

```bash
# 在宿主机上运行性能对比脚本
cd scripts
./run_benchmark.sh    # 运行所有调度器对比
./generate_report.sh  # 生成性能报告
```

## 核心特性

### 智能MLFQ调度器
- **4级优先级队列**：时间片分别为 2, 4, 8, 16 ticks
- **行为预测**：使用EWMA算法预测进程CPU密集度
- **动态优先级调整**：
  - CPU密集型进程：时间片用尽后降级
  - IO密集型进程：主动让出CPU后保持/提升优先级
- **防饥饿机制**：定期将所有进程提升到最高优先级队列

### 与uCore lab6及对比算法比较
| 特性 | RR调度器 | 基础MLFQ | **智能MLFQ** |
|------|----------|----------|--------------|
| **调度策略** | 时间片轮转 | 多级反馈队列 | **MLFQ+智能预测** |
| **进程区分** | 无，进程平等 | 简单区分 | **智能区分CPU/IO** |
| **时间片** | 固定长度 | 多级可变 | **多级可变+智能调整** |
| **自适应** | 无自适应 | 有限自适应 | **动态自适应** |
| **防饥饿** | 天然防饥饿 | 显式机制 | **显式+智能保证** |
| **抗恶意** | 无 | 无，易被利用 | **强，能识别恶意** |

## 项目结构

```
ucore-smart-scheduler/
├── kern/
│   ├── schedule/
│   │   ├── mlfq_sched.c        # 智能MLFQ（核心）
│   │   ├── basic_mlfq_sched.c  # 基础MLFQ（对比）
│   │   ├── rr_sched.c          # RR调度器（对比）
│   │   ├── sched.c             # 调度框架
│   │   └── sched.h             # 调度接口
│   └── process/
│       ├── proc.c              # 进程管理（扩展了proc_struct）
│       └── proc.h              # 进程控制块定义
├── user/
│   └── mlfq_test.c             # 调度器测试程序
├── docs/
│   └── 实验指导书.pdf          # 详细设计文档
├── Makefile
└── README.md
```

## 关键实现

### 进程控制块扩展
在 `proc_struct` 中新增字段：
```c
int mlfq_level;             // 当前队列层级 (0-3)
int current_slice_ticks;    // 剩余时间片
int cpu_score;              // CPU密集度评分 (0-1000)
int io_score;               // IO密集度评分 (0-1000)
```

### 智能预测算法
使用指数加权移动平均更新进程行为评分：
```c
// EWMA公式：NewScore = α * OldScore + (1-α) * CurrentRatio
// 本实验 α = 0.6
proc->cpu_score = (6 * proc->cpu_score + 4 * current_ratio) / 10;
```

### 调度决策逻辑
- `cpu_score > 700`：视为CPU密集型，降级惩罚
- `cpu_score < 300`：视为IO密集型，升级奖励
- `300 ≤ cpu_score ≤ 700`：根据具体行为调整

## 实验结果

调度算法的资源效率与性能对比和平均响应时间对比见下图：

[Comparison of Context Switches and Turnaround Time Across Scheduling Algorithms](https://ibb.co/Xfq3Yh3v)

[Average Response Time Comparison](https://ibb.co/k6WKPXRz)


测试实验结果分析：基于 5 个进程的压力测试 ( 2 CPU + 2 I/O + 1 Mixed )。

| 维度 | 指标 | Round Robin (RR) | Basic MLFQ | Smart MLFQ | 数据解读 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **I/O 进程**<br>(PID 4, 7) | **平均周转时间** | **310.5 ms** <br>**(极差)** | **12.0 ms** <br>**(极好)** | **13.0 ms** <br>**(极好)** | MLFQ 相比 RR 提升了 **~25倍** 的响应速度。RR 存在严重的护航效应。 |
| | **上下文切换** | 81 次 | 162 次 | 162 次 | MLFQ 允许 I/O 高频插队，切换次数翻倍是正常的代价。 |
| **CPU 进程**<br>(PID 3, 5) | **平均周转时间** | **294.5 ms** | 335.0 ms | 322.0 ms | 由于 I/O 频繁插队，MLFQ 中 CPU 进程的完成时间略有延后（饥饿现象）。 |
| | **上下文切换** | ~30 次 | **24 次** | **24 次** | MLFQ 底层时间片更长（16 ticks），减少了 **20%** 的无效切换，提升了吞吐效率。 |
| **混合进程**<br>(PID 6) | **周转时间** | 310 ms | 51 ms | **47 ms** | 混合任务在 MLFQ 中也能获得较好待遇，Smart MLFQ 略微优于 Basic。 |
| **系统整体** | **CPU 利用机制** | 固定时间片<br>(Slice=5) | 动态时间片<br>(2/4/8/16) | 动态时间片<br>(2/4/8/16) | MLFQ 通过动态时间片平衡了响应速度与吞吐量。 |


## 参考文献

1. **操作系统概念**（第九版）Abraham Silberschatz等，第5章CPU调度
2. **现代操作系统**（第四版）Andrew S. Tanenbaum，第2章进程与线程
3. **uCore OS实验指导书**，清华大学操作系统课程组
