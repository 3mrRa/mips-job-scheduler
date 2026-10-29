\# Job Sequencing with Deadlines (MIPS Assembly)



A low-level implementation of the \*\*Job Sequencing with Deadlines\*\* greedy algorithm written in \*\*MIPS32 Assembly Language\*\*. The program parses job data from an input file, sorts jobs by profit, assigns them to optimal time slots to maximize total profit, and exports the final execution schedule to an output file.



\---



\## Features



\- \*\*File I/O in Assembly\*\*: Reads input files and outputs scheduled results using MIPS `syscall` routines.

\- \*\*Robust Text Parsing\*\*: Parses raw byte buffers into structured integers (Job ID, Deadline, Profit) while handling whitespace and newline variations.

\- \*\*Input Validation\*\*: Verifies job counts (up to 10 jobs), valid positive deadlines, and non-negative profits.

\- \*\*Greedy Scheduling Algorithm\*\*:

&#x20; - Implements an descending-order \*\*Bubble Sort\*\* by profit across multi-word job structures.

&#x20; - Schedules each job into the latest available time slot before its deadline.

\- \*\*Modular Codebase\*\*: Clean subroutines utilizing stack frames (`$sp`, `$ra`) and standard MIPS register conventions.



\---



\## Problem Overview \& Algorithm



Given a set of jobs where each job has an \*\*ID\*\*, an integer \*\*Deadline\*\*, and an associated \*\*Profit\*\*:

1\. \*\*Sort\*\*: Jobs are sorted in descending order of profit.

2\. \*\*Assign Slot\*\*: For each sorted job, the algorithm searches for an empty time slot starting from $\\min(\\text{deadline}, \\text{max\\\_slots})$ backwards down to slot 1.

3\. \*\*Execute or Discard\*\*: If an empty slot is found, the job is scheduled; otherwise, it is skipped.

4\. \*\*Profit Calculation\*\*: Computes the sum of profits of all assigned jobs.



\---



\## Input \& Output Format



\### Input Format (`input.txt`)

Each line represents a single job containing three space-separated integers:

```text

<Job\_ID> <Deadline> <Profit>

Example:



Plaintext

1 2 100

2 1 19

3 2 27

4 1 25

5 3 15

Output Format (output.txt)

Lists scheduled jobs by time slot, followed by the total profit:



Plaintext

Selected job sequence:

Time slot 1: 4

Time slot 2: 1

Time slot 3: 5



Total profit: 140

How to Run

Using MARS Simulator

Download and install MARS (MIPS Assembler and Runtime Simulator).



Place input.txt in the same directory as the MARS executable / project root.



Open mips1.asm in MARS.



Click Run → Assemble (F3).



Click Run → Go (F5).



Check output.txt generated in your working directory.



Using SPIM

Bash

spim -file mips1.asm

