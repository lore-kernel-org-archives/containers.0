From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: pidns : PR_SET_PDEATHSIG + SIGKILL regression
Date: Fri, 2 Oct 2009 17:39:29 -0700
Message-ID: <20091003003929.GA20034@us.ibm.com>
References: <4AC608BE.9020805@fr.ibm.com> <20091002154702.GB26864@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="7AUc2qLy4jB3hD7Z"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091002154702.GB26864-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Ccing Oleg and Roland.

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| Thanks, Daniel, great testcase.

Agree :-)

| 
| Suka, Pavel, the problem is because send_signal() only calls a
| signal from_ancestor_ns if is_si_special(info), while reparent_thread()
| sends SEND_SIG_NOINFO.
| 
| Why is the '!is_si_special(info)' check there for from_ancestor_ns()?

The is_si_special() check is to ensure that we don't affect any signals
that the kernel is generating (such as the SIGKILL when out of memory).
Ensuring that info is not special also makes it safe to check SI_FROMUSER
(which in turn is needed to ensure we are not in interrupt context and
can safely deref 'current' to find the pidns).

Following quick patch seems to fix the problem. But I am not sure if
pdeath_signal needs to be treated as SEND_SIG_NOINFO (does it need to
be special or can we pass in a siginfo like we do when sending SIGCHLD
to parent) ?

| 
| -serge
| 
| Quoting Daniel Lezcano (dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
| > Hi,
| > 
| > I noticed a changed behaviour with the PR_SET_PDEATHSIG and SIGKILL 
| > between different kernel versions.
| > 
| > With a kernel 2.6.27.21-78.2.41.fc9.x86_64, the SIGKILL signal is 
| > delivered to the child process when the parent dies but with a 2.6.31 
| > kernel version that don't happen.
| > 
| > The program below shows the problem. I remember there was were some 
| > modifications about not killing the init process of the container from 
| > inside, but in this case, that happens _conceptually_ from outside. 
| > Keeping this feature is very important to be able to wipe out the 
| > container when the parent process of the container dies.
| > 

(Test case moved to attachment).

Sukadev

---

 kernel/exit.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

Index: linux-2.6/kernel/exit.c
===================================================================
--- linux-2.6.orig/kernel/exit.c	2009-10-02 16:36:47.000000000 -0700
+++ linux-2.6/kernel/exit.c	2009-10-02 17:19:06.000000000 -0700
@@ -738,8 +738,19 @@ static struct task_struct *find_new_reap
 static void reparent_thread(struct task_struct *father, struct task_struct *p,
 				struct list_head *dead)
 {
-	if (p->pdeath_signal)
-		group_send_sig_info(p->pdeath_signal, SEND_SIG_NOINFO, p);
+	struct siginfo info;
+
+	if (p->pdeath_signal) {
+		info.si_signo = p->pdeath_signal;
+		info.si_errno = 0;
+
+		rcu_read_lock();
+		info.si_pid = task_pid_nr_ns(father, task_active_pid_ns(p));
+		info.si_uid = __task_cred(father)->uid;
+		rcu_read_unlock();
+
+		group_send_sig_info(p->pdeath_signal, &info, p);
+	}
 
 	list_move_tail(&p->sibling, &p->real_parent->children);
 

--7AUc2qLy4jB3hD7Z
Content-Type: text/x-csrc; charset=us-ascii
Content-Description: pdeath.c
Content-Disposition: attachment; filename="pdeath.c"

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

--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--7AUc2qLy4jB3hD7Z--
