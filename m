From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: attach to a container : general protection fault
Date: Fri, 19 Mar 2010 16:59:22 +0100
Message-ID: <4BA39F5A.3000603@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060605090005070807070903"
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
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------060605090005070807070903
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Hi Eric,

I fall in a general protection fault with setns:

general protection fault: 0000 [#3] DEBUG_PAGEALLOC
last sysfs file: /sys/devices/virtual/net/sit0/type
CPU 0
Pid: 6843, comm: myattach2 Tainted: G      D    2.6.33 #239 /
RIP: 0010:[<ffffffff810e01d0>]  [<ffffffff810e01d0>] 
d_hash_and_lookup+0x3d/0x73
RSP: 0018:ffff880034aefd28  EFLAGS: 00010246
RAX: 0000000000019cac RBX: ffff880034aefd78 RCX: 0000000000000000
RDX: ffff880034aefd8a RSI: 0000000000000303 RDI: 0000000000000003
RBP: ffff880034aefd38 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000200000000 R12: 6b6b6b6b6b6b6b6b
R13: ffff8800383ef740 R14: 0000000000000014 R15: ffff880034aefd78
FS:  00007f94377816f0(0000) GS:ffffffff8161b000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fb88fb8c050 CR3: 0000000034a95000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process myattach2 (pid: 6843, threadinfo ffff880034aee000, task 
ffff88003d679048)
Stack:
  ffff880034aefd88 0000000000000001 ffff880034aefdc8 ffffffff8111712a
<0> ffff880034aefdc8 0000000000000046 0000000000000000 ffff8800349dcac0
<0> 0000001400000000 ffff8800349dcac0 0000000200019cac ffff880034aefd88
Call Trace:
  [<ffffffff8111712a>] proc_flush_task+0x8e/0x283
  [<ffffffff8102e4c7>] release_task+0x24/0x30f
  [<ffffffff8102ece3>] wait_consider_task+0x531/0x923
  [<ffffffff8102f1c2>] do_wait+0xed/0x213
  [<ffffffff81043342>] ? find_get_pid+0x0/0x66
  [<ffffffff8102f380>] sys_wait4+0x98/0xbb
  [<ffffffff8102daec>] ? child_wait_callback+0x0/0x53
  [<ffffffff810028e8>] system_call_fastpath+0x16/0x1b
Code: 48 8b 56 08 eb 1f 0f b6 32 ff c9 48 ff c2 48 89 f7 48 c1 e6 04 48 
c1 ef 04 48 8d 34 37 48 8d 04 06 48 6b c0 0b 85 c9 75 dd 89 03 <49> 8b 
84 24 b8 00 00 00 48 85 c0 74 19 48 8b 40 08 48 85 c0 74
RIP  [<ffffffff810e01d0>] d_hash_and_lookup+0x3d/0x73
  RSP <ffff880034aefd28>
---[ end trace 2a26f2e5384ecec1 ]---

That happens when creating a container, attach to it and then kill the 
container.

The program doing the attach is in "attachement" :)

That happens if you do:

    setns()
    fork(), exec(mycmd).
    waitpid().


Without the fork / waitpid, that is the current process does exec, the 
problem does not occur.

--------------060605090005070807070903
Content-Type: text/x-csrc;
 name="myattach2.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="myattach2.c"

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <syscall.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/param.h>

#define __NR_setns 300

int setns(int nstype, int fd)
{
    return syscall (__NR_setns, nstype, fd);
}

int main(int argc, char *argv[])
{
    char path[MAXPATHLEN];
    char *ns[] = { "pid", "mnt", "net", "pid", "uts" };
    const int size = sizeof(ns) / sizeof(char *);
    int fd[size];
    int i;
    pid_t pid;
   
    if (argc != 3) {
        fprintf(stderr, "mynsenter <pid> <command>\n");
        exit(1);
    }

    for (i = 0; i < size; i++) {
       
        sprintf(path, "/proc/%s/ns/%s", argv[1], ns[i]);

        fd[i] = open(path, O_RDONLY| FD_CLOEXEC);
        if (fd[i] < 0) {
            perror("open");
            return -1;
        }

    }
   
    for (i = 0; i < size; i++)
        if (setns(0, fd[i])) {
            perror("setns");
            return -1;
        }

    pid = fork();
    if (!pid) {

        fprintf(stderr, "mypid is %d\n", syscall(__NR_getpid));

        execve(argv[2], &argv[2], NULL);
        perror("execve");

    }

    if (pid < 0) {
        perror("fork");
        return -1;
    }

    if (waitpid(pid, NULL, 0) < 0) {
        perror("waitpid");
    }

    return 0;
}


--------------060605090005070807070903
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------060605090005070807070903--
