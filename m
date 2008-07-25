From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/2] sys_restore prototype
Date: Fri, 25 Jul 2008 17:56:56 -0500
Message-ID: <20080725225655.GA28276@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

We were talking this morning about what trivial patchset to begin
with to get a start on checkpoint and restart.  We thought that
rather than start with checkpoint, maybe we should start with
something that reads a "checkpoint file" and "restarts" a single
task.  In this case, restart means it sets the process id and
executes the file which are found in the checkpoint file.

So here's what we whipped up for a half hour this morning,
and during some of Mark's talk this afternoon.

It refuses to run if it isn't the container init, so you must
unshare your pidns before calling sys_restore().

To test, I did:

[root@kvm-f9 ~]# cat mycheckpoint 
99 /root/whoami
[root@kvm-f9 ~]# cat restore.c
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


int main()
{
        int ret;
        char *argv[3];
        char *envp[1];

        //argv[0] = argv[1] = "/bin/bash";
        //argv[2] = envp[0] = NULL;
        argv[0] = "/root/whoami";
        argv[1] = envp[0] = NULL;
        int fd = open("/root/mycheckpoint", O_RDONLY);
        if (fd < 0)
                perror("open checkpoint file");
        ret = syscall(327, fd, argv, envp);
        printf("syscall returned %d\n", ret);
        perror("syscall for checkpoint");
        close(fd);
        return ret;
}
[root@kvm-f9 ~]# cat whoami.c
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

int main()
{
        printf("I am %d\n", getpid());
        return 0;
}

Next, I create a new pid namespace, remount /proc, and
 execute 'restore' using 'exec' so that pid 1 is doing it:

[root@kvm-f9 ~]# /home/hallyn/cryo/utils/ns_exec -cp /bin/bash
about to clone with 20020000
[root@kvm-f9 ~]# mount -t proc none /proc
[root@kvm-f9 ~]# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  1 18:46 pts/0    00:00:00 /bin/bash
root        26     1  0 18:46 pts/0    00:00:00 ps -ef
[root@kvm-f9 ~]# exec ./restore
I am 99

Seems to work.

-serge
