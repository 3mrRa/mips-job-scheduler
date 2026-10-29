# Job Sequencing with Deadlines (MIPS Assembly)

A low-level implementation of the **Job Sequencing with Deadlines** greedy algorithm written in **MIPS32 Assembly Language**. The program parses job data from an input file, sorts jobs by profit, assigns them to optimal time slots to maximize total profit, and exports the final execution schedule to an output file.

---

## Features

* **File I/O in Assembly**: Reads input files and outputs scheduled results using MIPS `syscall` routines.
* **Text Parsing**: Parses raw byte buffers into structured integers (Job ID, Deadline, Profit) while handling spaces, tabs, and newlines.
* **Input Validation**: Verifies job count (up to 10 jobs), positive deadlines, and non-negative profits.
* **Greedy Scheduling Algorithm**:
  * Implements a descending-order **Bubble Sort** by profit across multi-word job structures.
  * Schedules each job into the latest available time slot before its deadline.
* **Modular Codebase**: Clean subroutines utilizing stack frames (`$sp`, `$ra`) and standard MIPS register conventions.

---

## Problem Overview & Algorithm

Given a set of jobs where each job has an **ID**, an integer **Deadline**, and an associated **Profit**:

1. **Sort**: Sort all jobs in descending order based on profit.
2. **Find Slot**: For each job, look for an available time slot starting from its deadline down to slot 1.
3. **Assign**: If a free slot is found, assign the job to that slot; otherwise, ignore it.
4. **Profit Calculation**: Sum the total profit of all successfully scheduled jobs.

---

## Input & Output Format

### Input Format (`input.txt`)

Each line represents a single job containing three space-separated integers:

```text
<Job_ID> <Deadline> <Profit>
