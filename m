From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 11/11] pidns: Support unsharing the pid namespace.
Date: Thu, 20 Dec 2012 17:43:04 -0800
Message-ID: <871uektc2f.fsf@xmission.com>
References: <8739097bkk.fsf@xmission.com>
	<1353083750-3621-1-git-send-email-ebiederm@xmission.com>
	<1353083750-3621-11-git-send-email-ebiederm@xmission.com>
	<20121219181400.GA22991@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121219181400.GA22991-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Oleg Nesterov's message of
	"Wed, 19 Dec 2012 19:14:00 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> Hi Eric,
>
> oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org no longer works, so I just noticed these emails.

Darn and instead of bouncing the emails just go into a black hole :(

I have updated my address book to point to oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org so
hopefully I don't make that mistake again.

> On 11/16, Eric W. Biederman wrote:
>>
>> Unsharing of the pid namespace unlike unsharing of other namespaces
>> does not take affect immediately.  Instead it affects the children
>> created with fork and clone.
>
> I'll try to read this series later, but I am not sure I will ever
> understand the code with these patches ;)

Hopefully the code doesn't cause you too many problems.

> So alloc_pid() becomes the only user nsproxy->pid_ns and it is not
> necessarily equal to task_active_pid_ns(). It seems to me that this
> adds a lot of new corner cases.

I have tried to simply outlaw the most of the new corner cases as they
simply are not interesting so there is no point implementing them,
or thinking about them once they are outlawed.

> Unless I missed something, at least we should not allow CLONE_THREAD
> if active_pid_ns != nsproxy->pid_ns. If nothing else, copy_process()
> initializes ->child_reaper only if thread_group_leader(child). And
> ->child_reaper == NULL can obviously lead to crash.

Hmm.  Let me think that through as you may have a point.

In copy_pid_ns I fail if task_active_pid_ns != nsproxy->pid_ns, and in
unshare CLONE_NEW_PID implies "CLONE_THREAD|CLONE_VM|CLONE_SIGHAND".  So
I avoid most of those cases already.

You are asking about clone(CLONE_THREAD) after unshare(CLONE_NEWPID).  I
totally failed to realize that case existed.  Oleg thank you for
pointing it out.

Below is my preliminary patch for ruling those things out.  I have added
CLONE_PARENT to the forbidden set because that seems about as bad
as CLONE_SIGHAND or CLONE_THREAD.

I will cook up a proper patch and get it merged shortly.

Eric


diff --git a/kernel/fork.c b/kernel/fork.c
index c36c4e3..340a25c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1166,6 +1166,14 @@ static struct task_struct *copy_process(unsigned long clone_flags,
                                current->signal->flags & SIGNAL_UNKILLABLE)
                return ERR_PTR(-EINVAL);
 
+       /*
+        * If the children will be in a different pid namespace don't allow
+        * the creation of threads.
+        */
+       if ((clone_flags & (CLONE_THREAD|CLONE_SIGHAND|CLONE_VM|CLONE_PARENT)) &&
+           task_active_pid_ns(current) != current->nsproxy->pid_ns)
+               return ERR_PTR(-EINVAL);
+
        retval = security_task_create(clone_flags);
        if (retval)
                goto fork_out;
