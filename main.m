//
//  main.m
//  ProcessEnumerator
//
//  Created by Max Bazaliy on 5/11/16.
//  Copyright © 2016 Max Bazaliy. All rights reserved.
//

#import "codesign.h"
#import <sys/syscall.h>
#import <sys/sysctl.h>

const char* copy_cs_identity_for_pid (pid_t pid)
{
    char buff[4096];
    char *result = NULL;
    char *iterator = (char*)&buff;
    
    if (syscall(SYS_csops, pid, CS_OPS_IDENTITY, buff, 4096) != -1)
        result = strdup((char*)(iterator+8)); // quick n dirty
    else
        result = NULL;
    
    return result;
}


const char* copy_proc_args_for_pid (pid_t pid)
{
    size_t buf_size = 4096;
    char buff[buf_size];
    char *result = NULL;
    char *iterator = (char*)&buff;
    int stuff[3];
    
    stuff[0] = CTL_KERN;
    stuff[1] = KERN_PROCARGS2;
    stuff[2] = pid;

    if (sysctl(stuff, 3, buff, &buf_size, NULL, 0) != -1)
        result = strdup((char*)(iterator+5)); // quick n dirty
    else
        result = NULL;
    
    return result;
}

int main(int argc, char * argv[])
{
    pid_t current_pid = 1;
    
    while (true) {
        
        if (current_pid >= 20000) { //havent seen pids highter than 14000
            break;
        }
        
        const char * identity = copy_cs_identity_for_pid(current_pid);
        if (identity == NULL) {
            current_pid++;
            continue;           // pid not exist
        }
        
        const char * path = copy_proc_args_for_pid(current_pid);
        
        if (path == NULL) {
            printf("Found process with id %d and identity %s\n", current_pid, identity );
        } else {
            printf("Found process with id %d, identity %s and path %s\n", current_pid, identity, path );
            free((void *)path);
        }
        free((void*)identity);
        current_pid++;
    }
    
    return 0;
}
