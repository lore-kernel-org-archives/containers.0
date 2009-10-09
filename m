From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: pidns memory leak
Date: Fri, 09 Oct 2009 15:18:23 +0200
Message-ID: <4ACF381F.9050808@fr.ibm.com>
References: <4AC5F198.2070407@fr.ibm.com> <20091006040526.GA22923@us.ibm.com>
	<4ACAFD6A.3060008@fr.ibm.com>
	<20091008030828.GA18973@us.ibm.com> <4ACD9ECC.90508@fr.ibm.com>
	<20091009032928.GA2031@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000807030909080707080107"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091009032928.GA2031-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------000807030909080707080107
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Sukadev Bhattiprolu wrote:
> Daniel Lezcano [dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
>> Sukadev Bhattiprolu wrote:
>>> Still digging through some traces, but below I have some questions that 
>>> I am still trying to answer.
>>>
>>>> I am not sure what you mean by 'struct pids' but what I observed is:
>>> Ok, I see that too. If pids leak, then pid-namespace will leak too.
>>> Do you see any leaks in proc_inode_cache ?
>> Yes, right. It leaks too.
> 
> Ok, some progress...
> 
> Can you please verify these observations:
> 
> - If the container exits normally, the leak does not seem to happen.
>   (i.e reduce your sleep 3600 to say sleep 3 and remove the lxc-stop).
> 
> - Revert the following commit and check if the leak happens:
> 
> 	commit 7766755a2f249e7e0dabc5255a0a3d151ff79821
> 	Author: Andrea Arcangeli <andrea-l3A5Bk7waGM@public.gmane.org>
> 	Date:   Mon Feb 4 22:29:21 2008 -0800
> 
> (this commit added the check for PF_EXITING in proc_flush_task_mnt 
> loosely explained below).



> Incomplete analysis :-)
> 
> If the container-init is terminated (by the lxc-stop), the container zaps
> other processes in the container and waits for them. The leak happens in
> this case.
> 
> Following sequence of events occur:
> 
> 	- container-init calls do_exit and sets PF_EXITING (in exit_signals())
> 
> 	- container init calls zaps_pid_ns_processes() (exit_notify /
> 	  forget_orignal_parent() / find_new_reaper())
> 
> 	- In zap_pid_ns_processes() container-init sends SIGKILL to
> 	  descendants and calls sys_wait().
> 
> 	- The sys_wait() is expected to call release_task() which calls
> 	  proc_flush_task_mnt().
> 
> 	- proc_flush_task_mnt() looks up the dentry for the pid (2 in
> 	  our example) and finds the dentry.
> 
> 	  But since container-init is itself exiting (i.e PF_EXITING is
> 	  set) it does NOT call the shrink_dcache_parent(), but,
> 	  interestingly calls d_drop() and dput().
> 
> 	  Now the d_drop() unhashes the dentry for the pid 2.
> 
> 	- proc_flush_task_mnt() then tries to find the dentry for the
> 	  tgid of the process. In our case, the tgid == pid == 2 and
> 	  we just unhashed the dentry for "2".
> 
> 	  So, we don't find the dentry for the leader either (and hence
> 	  don't make the second shrink_dcache_parent() call in
> 	  proc_flush_task_mnt() either).
> 
> 	  Without a call to shrink_dcache_parent(), the proc inode
> 	  for the process that was terminated by container init is
> 	  not deleted (i.e we don't call proc_delete_inode() or
> 	  the put_pid() inside it) causing us to leak proc_inodes,
> 	  struct pid and hence struct pid_namespace.

Ouch !

Nice analysis :)

Following your explanation I was able to reproduce a simple program 
added in attachment. But there is something I do not understand is why 
the leak does not appear if I do the 'lstat' (cf. test program) in the 
pid 2 context.


> There should be a better fix, but first please confirm if reverting the
> above commit fixes the leak for you also.

I confirm the leak does no longer appear when reverting this patch.

Thanks
   -- Daniel

--------------000807030909080707080107
Content-Type: text/x-csrc;
 name="bugpidns_leak.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bugpidns_leak.c"

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/prctl.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <sys/poll.h>
#include <signal.h>
#include <sched.h>

#ifndef CLONE_NEWPID
#  define CLONE_NEWPID            0x20000000
#endif

int child(void *arg)
{
	pid_t pid;
	struct stat s;

	if (mount("proc", "/proc", "proc", 0, NULL)) {
		perror("mount");
		return -1;
	}

	pid = fork();
	if (pid < 0) {
		perror("fork");
		return -1;
	}

	if (!pid) {
		poll(0, 0 , -1);
		exit(-1);
	}

	poll(0, 0, -1);

	return 0;
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
	struct stat s;
	char path[MAXPATHLEN];

	pid = clonens(child, NULL, CLONE_NEWNS|CLONE_NEWPID);
	if (pid < 0) {
		perror("clone");
		return -1;
	}

	/* yes ugly.*/
	sleep(1);

	/* !! assumption : child of my child is pid + 1 
	 * any reliable simple solution is welcome :) */
	snprintf(path, sizeof(path), "/proc/%d/exe", pid + 1);
	
	if (lstat(path, &s)) {
		perror("lstat");
		exit(-1);
	}

	if (kill(pid, SIGKILL)) {
		perror("kill");
		return -1;
	}

	return 0;
}

--------------000807030909080707080107
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------000807030909080707080107--
