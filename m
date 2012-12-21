From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 11/11] pidns: Support unsharing the pid namespace.
Date: Fri, 21 Dec 2012 16:49:31 +0100
Message-ID: <20121221154931.GA18730@redhat.com>
References: <8739097bkk.fsf@xmission.com>
	<1353083750-3621-1-git-send-email-ebiederm@xmission.com>
	<1353083750-3621-11-git-send-email-ebiederm@xmission.com>
	<20121219181400.GA22991@redhat.com> <871uektc2f.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <871uektc2f.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 12/20, Eric W. Biederman wrote:
>
> Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>
> > So alloc_pid() becomes the only user nsproxy->pid_ns and it is not
> > necessarily equal to task_active_pid_ns(). It seems to me that this
> > adds a lot of new corner cases.
>
> I have tried to simply outlaw the most of the new corner cases as they
> simply are not interesting so there is no point implementing them,
> or thinking about them once they are outlawed.

Eric. I understand that it is too late to discuss this. And yes, I simply
do not understand the problem space, I never used containers.

But, stupid question. Let's ignore the pid_ns-specific oddities.

1. Ignoring setns(), why do we need /proc/pid/ns/ ?

2. Why setns() requires /proc/pid/ns/ ? IOW, why it can't be

	sys_setns(pid_t pid, int clone_flags)
	{
		truct task_struct *tsk = find_task_by_vpid(pid);
		struct nsproxy *target = get_nsproxy(tsk->nsproxy);

		new_nsproxy = create_new_namespaces(...);

		if (clone_flags & CLONE_NEWNS)
			mntns_install(...);
		if (clone_flags & CLONE_NEWIPC)
			ipcns_install(...);
		...
	}

I feel I missed something trivial, but what?

> @@ -1166,6 +1166,14 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>                                 current->signal->flags & SIGNAL_UNKILLABLE)
>                 return ERR_PTR(-EINVAL);
>
> +       /*
> +        * If the children will be in a different pid namespace don't allow
> +        * the creation of threads.
> +        */
> +       if ((clone_flags & (CLONE_THREAD|CLONE_SIGHAND|CLONE_VM|CLONE_PARENT)) &&
> +           task_active_pid_ns(current) != current->nsproxy->pid_ns)
> +               return ERR_PTR(-EINVAL);

Agreed, and this also removes other oddities with pthread_create().

Oleg.
