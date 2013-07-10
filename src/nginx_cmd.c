#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>

int main(int argc, char **argv)
{
    char s[100];
    sprintf(s, "/etc/init.d/nginx %20s", argv[1]);
    system( "/etc/init.d/nginx" );
    exit(0);
}