.data
    buffer:
        .word 3 4 5 4  # m,n,p,s
        .word 9,7,15,9 # values
        .word 2,1,0,2  # col_indices
        .word 0,1,2,4  # row_ptr
        # B matrix (4x5)
        .word 1,4,0,12,11
        .word 9,0,11,8,2
        .word 12,2,11,10,0
        .word 10,12,0,1,9
    seg_table: .word 0x0000003F, 0x00000006, 0x0000005B, 0x0000004F  # 0-3
               .word 0x00000066, 0x0000006D, 0x0000007D, 0x00000007  # 4-7
               .word 0x0000007F, 0x0000006F, 0x00000077, 0x0000007C  # 8-b
               .word 0x00000039, 0x0000005E, 0x00000079, 0x00000071  # c-f
    C: .space 60       # 3x5 result matrix

.text
main:
    jal sparse_matmul       # 调用稀疏矩阵乘法
    
    # 显示结果矩阵C
    la $a0, C              # 矩阵地址
    la $t0, buffer
    lw $a1, 0($t0)     # m
    lw $a2, 8($t0)     # p
    jal display_matrix_bcd  # 调用显示函数
            
# 数码管显示函数（每个数字显示1秒）
display_matrix_bcd:
    move $t0, $a0          # 矩阵地址
    li $t1, 0              # 行计数器(i)
    lui $t7, 0x4000        # 数码管地址高16位
    ori $t7, $t7, 0x0010   # 数码管地址低16位 (0x10000010)
    
display_row_loop:
    beq $t1, $a1, display_done
    li $t2, 0              # 列计数器(j)
    
display_col_loop:
    beq $t2, $a2, next_row
    
    # 获取当前元素值
    mul $t3, $t1, $a2      # i * 列数
    add $t3, $t3, $t2      # + j
    sll $t3, $t3, 2        # 字偏移量
    add $t3, $t0, $t3      # 计算元素地址
    lw $a0, 0($t3)         # $a0 = C[i][j]
    
    # 设置250次4位循环(1秒)
    li $s0, 250            # 循环计数器
    
number_display_loop:
    # 显示当前数字的4位
    li $t4, 0              # 位计数器(0-3)
    la $t9, seg_table      # 段码表地址
    
digit_refresh:
    beq $t4, 4, refresh_done
    
    # 获取当前4位数据（使用条件分支替代srlv）
    beq $t4, 0, get_digit0
    beq $t4, 1, get_digit1
    beq $t4, 2, get_digit2
    beq $t4, 3, get_digit3

get_digit0:
    andi $t8, $a0, 0xF     # 取最低4位
    j digit_processed

get_digit1:
    srl $t8, $a0, 4        # 右移4位
    andi $t8, $t8, 0xF
    j digit_processed

get_digit2:
    srl $t8, $a0, 8        # 右移8位
    andi $t8, $t8, 0xF
    j digit_processed

get_digit3:
    srl $t8, $a0, 12       # 右移12位
    andi $t8, $t8, 0xF

digit_processed:
    # 获取段码
    sll $t5, $t8, 2        # 索引×4
    add $t5, $t9, $t5      # 计算段码地址
    lw $t5, 0($t5)         # 加载段码值
    andi $t5, $t5, 0xFF    # 确保只取低8位
    
    # 生成位选信号（使用条件分支替代sllv）
    beq $t4, 0, set_an0
    beq $t4, 1, set_an1
    beq $t4, 2, set_an2
    beq $t4, 3, set_an3

set_an0:
    li $t6, 0x0100         # AN0
    j combine
set_an1:
    li $t6, 0x0200         # AN1
    j combine
set_an2:
    li $t6, 0x0400         # AN2
    j combine
set_an3:
    li $t6, 0x0800         # AN3

combine:
    or $t5, $t5, $t6       # 组合段码和位选
    
    # 输出到数码管
    sw $t5, 0($t7)
   
    # 精确1ms延时 (100MHz CPU)
    li $s1, 6250          # 循环次数
delay_loop:
    addi $s1, $s1, -1
    beq $s1, $zero, delay_end
    j delay_loop
    
delay_end:
    addi $t4, $t4, 1       # 下一位
    j digit_refresh
    
refresh_done:
    # 完成一次4位刷新(4ms)
    addi $s0, $s0, -1
    beq $s0, $zero, number_display_end
    j number_display_loop
    
number_display_end:    
    # 1秒后切换到下一个数字
    addi $t2, $t2, 1
    j display_col_loop
    
next_row:
    addi $t1, $t1, 1
    j display_row_loop
    
display_done:
    jr $ra


sparse_matmul:
    la $t0, buffer
    lw $s0, 0($t0)     # m
    lw $s1, 4($t0)     # n
    lw $s2, 8($t0)     # p
    lw $s3, 12($t0)    # s
    
    addi $s4, $t0, 16 # $s4: values
    
    sll $s5, $s3, 2 
    add $s5, $s5, $s4 # $s5: col_indices
    
    sll $s6, $s3, 3
    add $s6, $s6, $s4 # $s6: row_ptr
    
    addi $s7, $s0, 1
    sll $s7, $s7, 2
    add $s7, $s7, $s6 # $s7: B
    
    # TODO
    li $t0,0# t0=i
    la $a1,C
    mul $t1,$s0,$s2
    
loop1:
    beq $t0,$t1,end_loop1
    sll $t2,$t0,2
    add $t3,$t2,$a1
    sw $zero,0($t3)
    
    addi $t0,$t0,1
    j loop1
    
end_loop1:
    li $t0,0# i=t0
    
loop2:   
    beq $t0,$s0,end_loop2
    
    sll $t2,$t0,2
    add $t2,$t2,$s6# t2=row_ptr[i]
    
    lw $t3,0($t2)# start=t3
    lw $t4,4($t2)# end=t4
    move $t5,$t3# j=t5
    
loop3:
    beq $t5,$t4,end_loop3
    sll $t2,$t5,2
    
    add $t8,$t2,$s5
    lw $t6,0($t8)# t6=k
    add $t8,$t2,$s4
    lw $t7,0($t8)# t7=val
    
    li $t9,0# t9=l
    
loop4:
    beq $t9,$s2,end_loop4
    mul $t8,$t0,$s2
    add $t8,$t8,$t9
    sll $t8,$t8,2
    
    add $t8,$t8,$a1
    lw $t2,0($t8)# t2=c_val
    
    mul $t1,$t6,$s2
    add $t1,$t1,$t9
    sll $t1,$t1,2
    add $t1,$t1,$s7
    lw $t1,0($t1) # B[k*p+l]
    
    mul $t1,$t1,$t7
    add $t2,$t2,$t1
    sw $t2,0($t8)
    
    addi $t9,$t9,1
    j loop4
    
end_loop4:
    addi $t5,$t5,1
    j loop3
    
end_loop3:
    addi $t0,$t0,1
    j loop2
    
end_loop2:
    mul $v0,$s0,$s2
    jr $ra
