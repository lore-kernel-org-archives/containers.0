From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: pidns : PR_SET_PDEATHSIG + SIGKILL regression
Date: Fri, 02 Oct 2009 16:05:50 +0200
Message-ID: <4AC608BE.9020805@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

I noticed a changed behaviour with the PR_SET_PDEATHSIG and SIGKILL 
between different kernel versions.

With a kernel 2.6.27.21-78.2.41.fc9.x86_64, the SIGKILL signal is 
delivered to the child process when the parent dies but with a 2.6.31 
kernel version that don't happen.

The program below shows the problem. I remember there was were some 
modifications about not killing the init process of the container from 
inside, but in this case, that happens _conceptually_ from outside. 
Keeping this feature is very important to be able to wipe out the 
container when the parent process of the container dies.

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/prctl.h>
#include <sys/param.h>
#include <sys/poll.h>
#include <signal.h>
#include <sched.h>

#ifndef CLONE_NEWPID
#  define CLONE_NEWPID            0x20000000
#endif

int child(void *arg)
{
    if (prctl(PR_SET_PDEATHSIG, SIGKILL, 0, 0, 0)) {
        perror("prctl");
        return -1;
    }

    sleep(3);
    printf("I should have gone with my parent\n");
    return -1;
}

pid_t clonens(int (*fn)(void *), void *arg, int flags)
{
    long stack_size = sysconf(_SC_PAGESIZE);
     void *stack = alloca(stack_size) + stack_size;
    return clone(fn, stack, flags | SIGCHLD, arg);
}

int main(int argc, char *argv[])
{
    pid_t pid;

    pid = clonens(child, NULL, CLONE_NEWNS|CLONE_NEWPID);
    if (pid < 0) {
        perror("clone");
        return -1;
    }

    /* let the child to be ready, ugly but simple code */
    sleep(1);
    
    return 0;
}
