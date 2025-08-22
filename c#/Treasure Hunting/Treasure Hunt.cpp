#include <stdio.h>
#include <stdlib.h>

#define BUFFER_SIZE 4096

int main(int argc, char* argv[]) {
    if (argc != 3) {
        fprintf(stderr, "用法: %s <文件1> <文件2>\n", argv[0]);
        return 1;
    }

    FILE* file1 = fopen(argv[1], "rb");
    FILE* file2 = fopen(argv[2], "rb");

    // 检查文件是否成功打开
    if (!file1 || !file2) {
        fprintf(stderr, "错误：无法打开文件\n");
        if (!file1) fprintf(stderr, "  -> %s\n", argv[1]);
        if (!file2) fprintf(stderr, "  -> %s\n", argv[2]);
        if (file1) fclose(file1);
        if (file2) fclose(file2);
        return 2;
    }

    // 获取文件大小
    fseek(file1, 0, SEEK_END);
    fseek(file2, 0, SEEK_END);
    long size1 = ftell(file1);
    long size2 = ftell(file2);
    rewind(file1);
    rewind(file2);

    // 检查文件大小是否一致
    if (size1 != size2) {
        fprintf(stderr, "错误：文件大小不同\n");
        fprintf(stderr, "  %s: %ld 字节\n", argv[1], size1);
        fprintf(stderr, "  %s: %ld 字节\n", argv[2], size2);
        fclose(file1);
        fclose(file2);
        return 3;
    }

    // 逐块比较文件内容
    unsigned char buf1[BUFFER_SIZE];
    unsigned char buf2[BUFFER_SIZE];
    long position = 0;
    int bytes_read;

    while ((bytes_read = fread(buf1, 1, BUFFER_SIZE, file1)) > 0) {
        if (fread(buf2, 1, BUFFER_SIZE, file2) != bytes_read) {
            fprintf(stderr, "错误：读取文件时发生意外错误\n");
            fclose(file1);
            fclose(file2);
            return 4;
        }

        // 逐字节比较
        for (int i = 0; i < bytes_read; ++i) {
            if (buf1[i] != buf2[i]) {
                printf("文件内容不一致！\n");
                printf("第一个不同位置：字节 %ld (0x%lX)\n", position + i, position + i);
                printf("%s: 0x%02X\n", argv[1], buf1[i]);
                printf("%s: 0x%02X\n", argv[2], buf2[i]);
                fclose(file1);
                fclose(file2);
                return 5;
            }
        }
        position += bytes_read;
    }

    printf("文件内容完全相同！\n");
    fclose(file1);
    fclose(file2);
    return 0;
}