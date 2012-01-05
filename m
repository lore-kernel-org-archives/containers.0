From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH 0/1][V5] Handle reboot in a child pid namespace
Date: Thu,  5 Jan 2012 10:06:49 +0100
Message-ID: <1325754410-32600-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org


ChangeLog:
==========

 * V5
    - make static inline function for reboot_pid_ns to return 0 when
      CONFIG_PID_NS is off and do the pid_namespace pointer comparison
      inside the function. That makes the compiler to remove this portion
      of code when CONFIG_PID_NS is not enabled.

 * V4
   - store the signal number the child pid namespace init should
     exit from. It is simpler, cleaner, and does not add more encoding
     bits to the exit code of the process.

 * V3
   - removed lock and serialization of pid_ns_reboot

 * V2
   - added a lock for the pid namespace to prevent racy call
     to the 'reboot' syscall
   - Moved 'reboot' command assigned in zap_pid_ns_processes
     instead of wait_task_zombie
   - added tasklist lock around force_sig
   - added do_exit in pid_ns_reboot
   - used task_active_pid_ns instead of declaring a new variable in sys_reboot
   - moved code up before POWER_OFF changed to HALT in sys_reboot


Test case:
==========

#include <alloca.h>
#include <stdio.h>
#include <sched.h>
#include <unistd.h>
#include <signal.h>
#include <sys/reboot.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <linux/reboot.h>

static int do_reboot(void *arg)
{
        int *cmd = arg;

        if (reboot(*cmd))
                printf("failed to reboot(%d): %m\n", *cmd);
}

int test_reboot(int cmd, int sig)
{
        long stack_size = 4096;
        void *stack = alloca(stack_size) + stack_size;
        int status;
        pid_t ret;

        ret = clone(do_reboot, stack, CLONE_NEWPID | SIGCHLD, &cmd);
        if (ret < 0) {
                printf("failed to clone: %m\n");
                return -1;
        }

        if (wait(&status) < 0) {
                printf("unexpected wait error: %m\n");
                return -1;
        }

        if (!WIFSIGNALED(status)) {
                printf("child process exited but was not signaled\n");
                return -1;
        }

        if (WTERMSIG(status) != sig) {
                printf("signal termination is not the one expected\n");
                return -1;
        }

        return 0;
}

int main(int argc, char *argv[])
{
        int status;

        status = test_reboot(LINUX_REBOOT_CMD_RESTART, SIGHUP);
        if (status < 0)
                return 1;
        printf("reboot(LINUX_REBOOT_CMD_RESTART) succeed\n");

        status = test_reboot(LINUX_REBOOT_CMD_RESTART2, SIGHUP);
        if (status < 0)
                return 1;
        printf("reboot(LINUX_REBOOT_CMD_RESTART2) succeed\n");

        status = test_reboot(LINUX_REBOOT_CMD_HALT, SIGINT);
        if (status < 0)
                return 1;
        printf("reboot(LINUX_REBOOT_CMD_HALT) succeed\n");

        status = test_reboot(LINUX_REBOOT_CMD_POWER_OFF, SIGINT);
        if (status < 0)
                return 1;
        printf("reboot(LINUX_REBOOT_CMD_POWERR_OFF) succeed\n");

        status = test_reboot(LINUX_REBOOT_CMD_CAD_ON, -1);
        if (status >= 0) {
                printf("reboot(LINUX_REBOOT_CMD_CAD_ON) should have failed\n");
                return 1;
        }
        printf("reboot(LINUX_REBOOT_CMD_CAD_ON) has failed as expected\n");

        return 0;
}

Daniel Lezcano (1):
  Add reboot_pid_ns to handle the reboot syscall

 include/linux/pid_namespace.h |    8 +++++++-
 kernel/pid_namespace.c        |   33 +++++++++++++++++++++++++++++++++
 kernel/sys.c                  |    3 +++
 3 files changed, 43 insertions(+), 1 deletions(-)

-- 
1.7.5.4
