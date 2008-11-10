From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: Signals to cinit
Date: Mon, 10 Nov 2008 20:32:28 +0100
Message-ID: <20081110193228.GA15519@redhat.com>
References: <20081101180505.GA24268@us.ibm.com> <20081110173839.GA11121@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755861AbYKJSfK@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081110173839.GA11121@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@linux.vnet.ibm.com
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@openvz.org>, daniel@hozac.com, Nadia Derbey <Nadia.Derbey@bull.net>, serue@us.ibm.com, clg@fr.ibm.com, Containers <containers@lists.osdl.org>, sukadev@us.ibm.com, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

(lkml cced because containers list's archive is not useable)

On 11/10, Oleg Nesterov wrote:
>
> On 11/01, sukadev@linux.vnet.ibm.com wrote:
> >
> > Other approaches to try ?
>
> I think we should try to do something simple, even if not perfect. Because
> most users do not care about this problem since they do not use containers
> at all. It would be very sad to add intrusive changes to the code.
>
> I think we should fix another problem first. send_signal()->copy_siginfo()
> path must be changed anyway, when the signal comes from the parent ns we
> report the "wrong" si_code/si_pid, yes? So, somehow send_signal() must
> have "bool from_parent_ns" (or whatever) annyway.
>
> Now, let's forget forget for a moment that send_signal()->__sigqueue_alloc()
> can fail.
>
> I think we should encode this "from_parent_ns" into "struct siginfo". I do
> not think it is good idea to extend this structure, I think we can introduce
> SI_FROM_PARENT_NS or we perhaps can use "SI_FROMUSER(info) && info->si_pid == 0".
> Or something. yes, sys_rt_sigqueueinfo() is problematic...
>
> Now, copy_process(CLONE_NEWPID) sets child->signal |= SIGNAL_UNKILLABLE, this
> protects cinit from unwanted signals. Then we change get_signal_to_deliver()
>
> 	-	if (unlikely(signal->flags & SIGNAL_UNKILLABLE) &&
> 	+	if (unlikely(signal->flags & SIGNAL_UNKILLABLE) && !siginfo_from_parent_ns(info)
>
> and now we can kill cinit from parent ns. This needs more checks if we want
> to stop/strace it, but perhaps this is enough for the start. Note that we
> do not need to change complete_signal(), at least for now, the code under
> "if (sig_fatal(p, sig)" is just optimization.
>
>
> So, afaics, the only real problem is how we can handle the case when
> __sigqueue_alloc() fails. I think for the start we can just return
> -ENOMEM in this case (when from_parent_ns == T). Then we can improve
> this behaviour. We can change complete_signal() to ensure that the
> fatal signal from the upper ns always kills cinit, and in this case
> we ignore the the failed __sigqueue_alloc(). This way at least SIGKILL
> always works.
>
> Yes, this is not perfect, and it is very possible I missed something
> else. But simple.

But how can send_signal() know that the signal comes from the upper ns?
This is not trivial, we can't blindly use current to check. The signal
can be sent from irq/workqueue/etc.

Perhaps we can start with something like the patch below. Not that I like
it very much though. We should really place this code under
CONFIG_I_DO_CARE_ABOUT_NAMESPACES ;)

Oleg.

--- K-IS/kernel/signal.c~T	2008-11-10 19:21:17.000000000 +0100
+++ K-IS/kernel/signal.c	2008-11-10 20:31:24.000000000 +0100
@@ -798,11 +798,19 @@ static inline int legacy_queue(struct si
 	return (sig < SIGRTMIN) && sigismember(&signals->signal, sig);
 }
 
+#define SIG_FROM_USER	INT_MIN		/* MSB */
+
 static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 			int group)
 {
 	struct sigpending *pending;
 	struct sigqueue *q;
+	int from_ancestor_ns;
+
+	from_ancestor_ns = !is_si_special(info) &&
+		(info->si_signo | SIG_FROM_USER) &&
+		/* if t can't see us we are from parent ns */
+		task_pid_nr_ns(current, t->current->nsproxy->pid_ns) <= 0;
 
 	trace_sched_signal_send(sig, t);
 
@@ -855,6 +863,7 @@ static int send_signal(int sig, struct s
 			break;
 		default:
 			copy_siginfo(&q->info, info);
+			q->info.si_signo &= ~SIG_FROM_USER;
 			break;
 		}
 	} else if (!is_si_special(info)) {
@@ -2207,7 +2216,7 @@ sys_kill(pid_t pid, int sig)
 {
 	struct siginfo info;
 
-	info.si_signo = sig;
+	info.si_signo = sig | SIG_FROM_USER;
 	info.si_errno = 0;
 	info.si_code = SI_USER;
 	info.si_pid = task_tgid_vnr(current);
@@ -2224,7 +2233,7 @@ static int do_tkill(pid_t tgid, pid_t pi
 	unsigned long flags;
 
 	error = -ESRCH;
-	info.si_signo = sig;
+	info.si_signo = sig | SIG_FROM_USER;
 	info.si_errno = 0;
 	info.si_code = SI_TKILL;
 	info.si_pid = task_tgid_vnr(current);
@@ -2296,7 +2305,7 @@ sys_rt_sigqueueinfo(pid_t pid, int sig, 
 	   Nor can they impersonate a kill(), which adds source info.  */
 	if (info.si_code >= 0)
 		return -EPERM;
-	info.si_signo = sig;
+	info.si_signo = sig | SIG_FROM_USER;
 
 	/* POSIX.1b doesn't mention process groups.  */
 	return kill_proc_info(sig, &info, pid);
