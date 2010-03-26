From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: Testing lxc 0.6.5 in Fedora 13
Date: Fri, 26 Mar 2010 12:32:01 +0100
Message-ID: <20100326113201.GB17113__22344.3784555004$1269603175$gmane$org@megiteam.pl>
References: <20100321195044.GA23757@megiteam.pl>
	<20100323212834.GH20796@count0.beaverton.ibm.com>
	<20100325213356.GB20541@megiteam.pl>
	<20100326111131.GA8604@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100326111131.GA8604-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Mar 26, 2010 at 12:11:31PM +0100, Oleg Nesterov wrote:
> Yes, this is broken. More precisely, this wasn't even supposed to work.
> 
> Even stracing of the sub-init itself (or global init btw) has problems,
> the straced init is not protected from unwanted signals.

Is this impossible/very hard to do cleanly? I understand that container's
init becomes vulnerable to signals sent from root-owned processes in the
container. If so, the impact of this issue should be quite limited, no?

Strace'ing processes across pidns boundary would be really useful in day
to day administrative work but if it's unfixable, I guess at least
preventing strace from attaching to processes in a descendant pidns
would be required in order to prevent container malfunction.

> Yes. First of all, tracehook_report_clone_complete() reports the wrong pid nr,
> as it seen inside the init's namespace. This is easy to fix, but I doubt this
> can help. IIRC strace doesn't use PTRACE_GETEVENTMSG at all, it looks at eax
> after syscall.
> 
> which patch?

The patch below posted by Matt. AIUI, it fixes the
tracehook_report_clone_complete() part, which results in an observable
change in strace's behaviour (not that it makes strace work, though).
Anyway, are there any remaining issues on the kernel side or does strace
have to be taught about pid namespaces?

Best regards,
 Grzegorz Nosek

diff --git a/kernel/fork.c b/kernel/fork.c
index 3a65513..7946ea6 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1404,6 +1404,7 @@ long do_fork(unsigned long clone_flags,
         */
        if (!IS_ERR(p)) {
                struct completion vfork;
+               int ptrace_pid_vnr;

                trace_sched_process_fork(current, p);

@@ -1439,14 +1440,21 @@ long do_fork(unsigned long clone_flags,
                        wake_up_new_task(p, clone_flags);
                }

+               ptrace_pid_vnr = nr;
+               if (unlikely(p->parent != p->real_parent)) {
+                       rcu_read_lock();
+                       ptrace_pid_vnr = task_pid_nr_ns(p, p->parent->nsproxy->pid_ns);
+                       rcu_read_unlock();
+               }
                tracehook_report_clone_complete(trace, regs,
-                                               clone_flags, nr, p);
+                                               clone_flags,
+                                               ptrace_pid_vnr, p);

                if (clone_flags & CLONE_VFORK) {
                        freezer_do_not_count();
                        wait_for_completion(&vfork);
                        freezer_count();
-                       tracehook_report_vfork_done(p, nr);
+                       tracehook_report_vfork_done(p, ptrace_pid_vnr);
                }
        } else {
                nr = PTR_ERR(p);
