#include "stringu.h"
#include <stddef.h>

size_t strlen(const char* str) 
{
    size_t len = 0;
    while (str[len])
        len++;
    return len;
}

const char* numbtostr(uint32_t num)
{
    static char buf[11];
    char* ptr = buf + 10;
    *ptr = 0;
    do
    {
        *--ptr = '0' + num % 10;
        num /= 10;
    } while (num);
    return ptr;
}