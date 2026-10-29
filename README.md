# Job Sequencing with Deadlines — MIPS Assembly

A **MIPS Assembly** program that solves the **Job Sequencing with Deadlines** problem using a greedy algorithm. It reads a list of jobs from a text file, then selects and schedules them so that the **total profit is maximized** while respecting each job's deadline.

---

## Project Files

| File | Description |
|------|-------------|
| `mips1.asm` | Program source code |
| `input.txt` | Input file (list of jobs) |
| `output.txt` | Output file (written when the program runs) |

---

## Problem Description

- Each job has an **ID**, a **deadline**, and a **profit**.
- Every job takes **one unit of time**, and each time slot can hold only **one job**.
- Goal: pick the set of jobs that can be completed before their deadlines and yields the highest total profit.

## Algorithm

1. Sort jobs by profit in **descending order** (Bubble Sort).
2. For each job in that order, search for the latest free slot from its deadline **down to slot 1**.
3. If a free slot is found, place the job there; otherwise skip it.
4. Sum the profits of the scheduled jobs and write the result.

**Time complexity:** O(n²), from the Bubble Sort and the slot search.

---

## Input Format

One job per line:

```
<JobID> <Deadline> <Profit>
```

Example:

```
1 2 100
2 1 19
3 2 27
4 1 25
5 3 15
```

### Validation Rules

| Rule | Value |
|------|-------|
| Number of jobs | 1 to 10 |
| Deadline | >= 1 (values above 10 are capped at 10) |
| Profit | >= 0 |
| Field separator | Space or Tab |

If validation fails, the program prints `Error: Invalid file format!` and exits.

---

## How to Run

1. Open `mips1.asm` in **MARS** (or QtSPIM).
2. Place `input.txt` in the **simulator's working directory**.
3. Click **Assemble**, then **Run**.
4. When `Enter input filename:` appears, type the file name (`input.txt`).
5. Open `output.txt` to see the result.

---

## Output Format

```
Selected job sequence:
Time slot <n>: <JobID>
...

Total profit: <sum>
```

### Expected Output for the Sample Input

| Time Slot | Job | Profit |
|-----------|-----|--------|
| 1 | 3 | 27 |
| 2 | 1 | 100 |
| 3 | 5 | 15 |

**Total profit = 142** (jobs 2 and 4 are dropped because slot 1 is already taken).

---

## Code Structure

| Procedure | Purpose |
|-----------|---------|
| `main` | Calls each stage in order, then prints a success message |
| `prompt_and_read_filename` | Asks for the file name and strips the trailing newline |
| `open_and_read_file` | Opens the file and reads it into `buffer` (up to 1024 bytes) |
| `parse_jobs` | Converts the text to integers and stores them in `jobs_array` |
| `validate_input` | Checks job count, deadlines, and profits |
| `schedule_jobs` | Sorts by profit and assigns jobs to time slots |
| `calculate_total_profit` | Sums the profit of scheduled jobs |
| `write_output` | Writes the result to `output.txt` |

### Memory Layout (`.data`)

| Variable | Size | Use |
|----------|------|-----|
| `jobs_array` | 120 bytes | 10 jobs x 12 bytes (ID, Deadline, Profit) |
| `schedule` | 40 bytes | 10 slots x 4 bytes (`-1` = empty) |
| `buffer` | 1024 bytes | Raw contents of the input file |
| `filename` | 100 bytes | File name typed by the user |

### Syscalls Used

`4` print string, `1` print integer, `8` read string, `13` open file, `14` read file, `15` write file, `16` close file, `10` exit.

---

## Known Issues in the Current Code

Found while reviewing `mips1.asm`; worth fixing before submission:

1. **`J` prefix in `input.txt`:** the current file uses `J1 2 100`, but `parse_jobs` only reads digits. The `J` creates a phantom job with deadline 0, validation fails, and `Invalid file format!` is printed. This is why `output.txt` stays empty. Fix: use plain numbers (`1 2 100`) or make the parser skip the `J`.
2. **Typed file name is ignored:** the program asks for a file name but always opens the hard-coded `test_filename` (`input.txt`) instead of `filename`.
3. **Numbers never reach the file:** `syscall 1` prints to the **console**, not the file, so `output.txt` lacks the slot numbers, job IDs, and total profit. Numbers must be converted to strings (itoa) and written with `syscall 15`.
4. **Job ID vs. index mix-up:** `schedule_jobs` stores the job **ID** in the schedule, but `calculate_total_profit` and `write_output` use it as an **index** into the sorted `jobs_array`, producing wrong values. Fix: store the array index instead.
5. **Header length:** `out_header` is written with length 24 but the string is 23 bytes, so a stray `\0` byte lands in the file.
6. **`write_error`** returns silently without any error message.

---

## Environment

- **Language:** MIPS32 Assembly
- **Simulator:** MARS 4.5 (recommended) or QtSPIM
