.data
    # ===== Messages =====
    prompt_filename: .asciiz "Enter input filename: "
    msg_error_open:  .asciiz "Error: Cannot open file!\n"
    msg_error_format:.asciiz "Error: Invalid file format!\n"
    msg_success:     .asciiz "Schedule written to output.txt\n"
    newline:         .asciiz "\n"
   
    # ===== Output strings =====
    out_header:   .asciiz "Selected job sequence:\n"
    out_timeslot: .asciiz "Time slot "
    out_colon:    .asciiz ": "
    out_total:    .asciiz "\nTotal profit: "
   
    # ===== Arrays =====
    jobs_array: .space 120
    schedule:   .space 40
   
    # ===== Variables =====
    filename: .space 100
    buffer:   .space 1024
    num_jobs: .word 0
    total_profit: .word 0
    output_filename: .asciiz "output.txt"
    test_filename: .asciiz "input.txt"

.text
.globl main

# ============================================
# MAIN
# ============================================
main:
    jal prompt_and_read_filename
    jal open_and_read_file
    jal validate_input
    jal schedule_jobs
    jal calculate_total_profit
    jal write_output
   
    li $v0, 4
    la $a0, msg_success
    syscall
   
    li $v0, 10
    syscall

# ============================================
# prompt_and_read_filename
# ============================================
prompt_and_read_filename:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    li $v0, 4
    la $a0, prompt_filename
    syscall
   
    li $v0, 8
    la $a0, filename
    li $a1, 99
    syscall
   
    la $t0, filename
clean_loop:
    lb $t1, 0($t0)
    beqz $t1, clean_done
    beq $t1, 10, replace_null
    beq $t1, 13, replace_null
    addi $t0, $t0, 1
    j clean_loop

replace_null:
    sb $zero, 0($t0)
clean_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ============================================
# open_and_read_file
# ============================================


open_and_read_file:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    # فتح الملف
    li $v0, 13
    la $a0, test_filename
    li $a1, 0
    li $a2, 0
    syscall
   
    move $s0, $v0          # حفظ file descriptor
   
    bltz $s0, file_open_error

    # قراءة المحتوى
    li $v0, 14
    move $a0, $s0
    la $a1, buffer
    li $a2, 1024
    syscall

    # إغلاق الملف
    li $v0, 16
    move $a0, $s0
    syscall

    jal parse_jobs

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

file_open_error:
    li $v0, 4
    la $a0, msg_error_open
    syscall
    li $v0, 10
    syscall

# ============================================
# parse_jobs
# ============================================
parse_jobs:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    la $t0, buffer
    la $t1, jobs_array
    li $t2, 0

parse_loop:
    lb $t3, 0($t0)
    beqz $t3, parse_done
    beq $t3, 10, next_line

    # Read Job ID
    li $t4, 0
read_jobid:
    lb $t3, 0($t0)
    blt $t3, 48, jobid_done
    bgt $t3, 57, jobid_done
    mul $t4, $t4, 10
    addi $t3, $t3, -48
    add $t4, $t4, $t3
    addi $t0, $t0, 1
    j read_jobid

jobid_done:
    sw $t4, 0($t1)

    # Skip spaces or tabs
    lb $t3, 0($t0)
    beq $t3, 32, skip_space
    beq $t3, 9,  skip_space
    j read_deadline

skip_space:
    addi $t0, $t0, 1
    j jobid_done

read_deadline:
    li $t4, 0
read_deadline_loop:
    lb $t3, 0($t0)
    blt $t3, 48, deadline_done
    bgt $t3, 57, deadline_done
    mul $t4, $t4, 10
    addi $t3, $t3, -48
    add $t4, $t4, $t3
    addi $t0, $t0, 1
    j read_deadline_loop

deadline_done:
    sw $t4, 4($t1)

    # Read Profit
    li $t4, 0
read_profit:
    lb $t3, 0($t0)
    blt $t3, 48, profit_done
    bgt $t3, 57, profit_done
    mul $t4, $t4, 10
    addi $t3, $t3, -48
    add $t4, $t4, $t3
    addi $t0, $t0, 1
    j read_profit

profit_done:
    sw $t4, 8($t1)
   
    addi $t2, $t2, 1
    addi $t1, $t1, 12

next_line:
    addi $t0, $t0, 1
    j parse_loop

parse_done:
    la $t3, num_jobs
    sw $t2, 0($t3)
   
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ============================================
# validate_input
# ============================================
validate_input:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    la $t0, num_jobs
    lw $t1, 0($t0)
    li $t2, 1
    blt $t1, $t2, validation_error
    li $t2, 10
    bgt $t1, $t2, validation_error

    la $t3, jobs_array
    li $t4, 0
validate_loop:
    bge $t4, $t1, validate_done
    lw $t5, 4($t3)
    li $t6, 1
    blt $t5, $t6, validation_error
    lw $t5, 8($t3)
    bltz $t5, validation_error
    addi $t3, $t3, 12
    addi $t4, $t4, 1
    j validate_loop

validate_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

validation_error:
    li $v0, 4
    la $a0, msg_error_format
    syscall
    li $v0, 10
    syscall

# ============================================
# schedule_jobs
# ============================================
schedule_jobs:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    # Initialize schedule with -1
    la $t0, schedule
    li $t1, 10
    li $t2, -1
init_schedule:
    beqz $t1, init_done
    sw $t2, 0($t0)
    addi $t0, $t0, 4
    addi $t1, $t1, -1
    j init_schedule
init_done:

    # Bubble sort by profit (descending)
    la $t0, num_jobs
    lw $s0, 0($t0)
    li $s1, 0
sort_outer:
    bge $s1, $s0, sort_done
    li $s2, 0
sort_inner:
    sub $t0, $s0, $s1
    addi $t0, $t0, -1
    bge $s2, $t0, sort_next_outer
   
    la $t1, jobs_array
    mul $t2, $s2, 12
    add $t1, $t1, $t2
    lw $t3, 8($t1)
   
    la $t4, jobs_array
    addi $t5, $s2, 1
    mul $t2, $t5, 12
    add $t4, $t4, $t2
    lw $t5, 8($t4)
   
    bge $t3, $t5, no_swap

    # Swap all three fields
    lw $t6, 0($t1)
    lw $t7, 0($t4)
    sw $t7, 0($t1)
    sw $t6, 0($t4)
   
    lw $t6, 4($t1)
    lw $t7, 4($t4)
    sw $t7, 4($t1)
    sw $t6, 4($t4)
   
    lw $t6, 8($t1)
    lw $t7, 8($t4)
    sw $t7, 8($t1)
    sw $t6, 8($t4)

no_swap:
    addi $s2, $s2, 1
    j sort_inner
sort_next_outer:
    addi $s1, $s1, 1
    j sort_outer
sort_done:

    # Scheduling part
    la $t0, num_jobs
    lw $s0, 0($t0)
    li $s1, 0
schedule_loop:
    bge $s1, $s0, schedule_done
   
    la $t1, jobs_array
    mul $t2, $s1, 12
    add $t1, $t1, $t2
    lw $s2, 0($t1)   # job index
    lw $s3, 4($t1)   # deadline
   
    li $t3, 10
    ble $s3, $t3, use_deadline
    move $s3, $t3
use_deadline:
    move $t4, $s3
find_slot:
    li $t5, 1
    blt $t4, $t5, no_slot_found
    la $t6, schedule
    addi $t7, $t4, -1
    mul $t7, $t7, 4
    add $t6, $t6, $t7
    lw $t7, 0($t6)
    li $t8, -1
    beq $t7, $t8, slot_found
    addi $t4, $t4, -1
    j find_slot
slot_found:
    sw $s2, 0($t6)
no_slot_found:
    addi $s1, $s1, 1
    j schedule_loop
schedule_done:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ============================================
# calculate_total_profit
# ============================================
calculate_total_profit:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    li $s0, 0
    li $s1, 0
profit_loop:
    li $t0, 10
    bge $s1, $t0, calc_profit_done
   
    la $t1, schedule
    mul $t2, $s1, 4
    add $t1, $t1, $t2
    lw $t2, 0($t1)
   
    li $t3, -1
    beq $t2, $t3, next_slot
   
    la $t3, jobs_array
    mul $t4, $t2, 12
    add $t3, $t3, $t4
    lw $t4, 8($t3)
    add $s0, $s0, $t4

next_slot:
    addi $s1, $s1, 1
    j profit_loop

calc_profit_done:
    la $t0, total_profit
    sw $s0, 0($t0)
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ============================================
# write_output
# ============================================
write_output:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
   
    li $v0, 13
    la $a0, output_filename
    li $a1, 1
    li $a2, 0
    syscall
    bltz $v0, write_error
    move $s0, $v0

    li $v0, 15
    move $a0, $s0
    la $a1, out_header
    li $a2, 24
    syscall

    li $s1, 0
write_slot_loop:
    li $t0, 10
    bge $s1, $t0, write_total
   
    la $t1, schedule
    mul $t2, $s1, 4
    add $t1, $t1, $t2
    lw $t2, 0($t1)
    li $t3, -1
    beq $t2, $t3, skip_slot

    li $v0, 15
    move $a0, $s0
    la $a1, out_timeslot
    li $a2, 10
    syscall

    addi $t4, $s1, 1
    li $v0, 1
    move $a0, $t4
    syscall

    li $v0, 15
    move $a0, $s0
    la $a1, out_colon
    li $a2, 2
    syscall

    la $t3, jobs_array
    mul $t4, $t2, 12
    add $t3, $t3, $t4
    lw $t4, 0($t3)
    li $v0, 1
    move $a0, $t4
    syscall

    li $v0, 15
    move $a0, $s0
    la $a1, newline
    li $a2, 1
    syscall

skip_slot:
    addi $s1, $s1, 1
    j write_slot_loop

write_total:
    li $v0, 15
    move $a0, $s0
    la $a1, out_total
    li $a2, 15
    syscall

    la $t0, total_profit
    lw $a0, 0($t0)
    li $v0, 1
    syscall

    li $v0, 15
    move $a0, $s0
    la $a1, newline
    li $a2, 1
    syscall

    li $v0, 16
    move $a0, $s0
    syscall

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

write_error:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
