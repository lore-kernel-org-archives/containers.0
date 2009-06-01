From: Amerigo Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][v3][PATCH 6/7] Define do_fork_with_pids()
Date: Mon, 1 Jun 2009 16:19:29 +0800
Message-ID: <20090601081929.GC4381@cr0.nay.redhat.com>
References: <20090530235714.GA4083@us.ibm.com>
	<20090531000255.GE4191@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090531000255.GE4191-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, May 30, 2009 at 05:02:55PM -0700, Sukadev Bhattiprolu wrote:
>
>From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>Date: Mon, 4 May 2009 01:17:44 -0700
>Subject: [RFC][v3][PATCH 6/7] Define do_fork_with_pids()
>
>do_fork_with_pids() is same as do_fork(), except that it takes an
>additional, 'pid_set', parameter. This parameter, currently unused,
>specifies the set of target pids of the process in each of its pid
>namespaces.
>
>Changelog[v3]:
>	- Fix "long-line" warning from checkpatch.pl
>
>Changelog[v2]:
>	- To facilitate moving architecture-inpdendent code to kernel/fork.c
>	  pass in 'struct target_pid_set __user *' to do_fork_with_pids()
>	  rather than 'pid_t *' (next patch moves the arch-independent
>	  code to kernel/fork.c)
>
>Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
>---
> include/linux/sched.h |    3 +++
> include/linux/types.h |    5 +++++
> kernel/fork.c         |   16 ++++++++++++++--
> 3 files changed, 22 insertions(+), 2 deletions(-)
>
>diff --git a/include/linux/sched.h b/include/linux/sched.h
>index b4c38bc..e3bdb86 100644
>--- a/include/linux/sched.h
>+++ b/include/linux/sched.h
>@@ -1995,6 +1995,9 @@ extern int disallow_signal(int);
> 
> extern int do_execve(char *, char __user * __user *, char __user * __user *, struct pt_regs *);
> extern long do_fork(unsigned long, unsigned long, struct pt_regs *, unsigned long, int __user *, int __user *);
>+extern long do_fork_with_pids(unsigned long, unsigned long, struct pt_regs *,
>+				unsigned long, int __user *, int __user *,
>+				struct target_pid_set __user *pid_set);
> struct task_struct *fork_idle(int);
> 
> extern void set_task_comm(struct task_struct *tsk, char *from);
>diff --git a/include/linux/types.h b/include/linux/types.h
>index 5abe354..17ec186 100644
>--- a/include/linux/types.h
>+++ b/include/linux/types.h
>@@ -204,6 +204,11 @@ struct ustat {
> 	char			f_fpack[6];
> };
> 
>+struct target_pid_set {
>+	int num_pids;
>+	pid_t *target_pids;
>+};
>+

A quick question: why not putting this definition into
include/linux/pid.h?
