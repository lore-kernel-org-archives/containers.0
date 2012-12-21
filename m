From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 11/11] pidns: Support unsharing the pid namespace.
Date: Fri, 21 Dec 2012 09:51:03 -0800
Message-ID: <87fw2zmgzc.fsf@xmission.com>
References: <8739097bkk.fsf@xmission.com>
	<1353083750-3621-1-git-send-email-ebiederm@xmission.com>
	<1353083750-3621-11-git-send-email-ebiederm@xmission.com>
	<20121219181400.GA22991@redhat.com> <871uektc2f.fsf@xmission.com>
	<20121221154931.GA18730@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121221154931.GA18730-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Oleg Nesterov's message of
	"Fri, 21 Dec 2012 16:49:31 +0100")
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

> Eric. I understand that it is too late to discuss this. And yes, I simply
> do not understand the problem space, I never used containers.
>
> But, stupid question. Let's ignore the pid_ns-specific oddities.
>
> 1. Ignoring setns(), why do we need /proc/pid/ns/ ?
>
> 2. Why setns() requires /proc/pid/ns/ ? IOW, why it can't be
>
> 	sys_setns(pid_t pid, int clone_flags)
> 	{
> 		truct task_struct *tsk = find_task_by_vpid(pid);
> 		struct nsproxy *target = get_nsproxy(tsk->nsproxy);
>
> 		new_nsproxy = create_new_namespaces(...);
>
> 		if (clone_flags & CLONE_NEWNS)
> 			mntns_install(...);
> 		if (clone_flags & CLONE_NEWIPC)
> 			ipcns_install(...);
> 		...
> 	}
>
> I feel I missed something trivial, but what?

It is a question of naming.

The problem I set out to solve when all of this was introduced was how
to name namespaces without introducing yet another namespace.

The solution to the naming problem that I finally found was to introduce
something I could mount.  Using a file in /proc I can bind mount it
anywhere in the mount namespace with any name.  That gives me names for
namespaces in the mount namespace.  Furthermore those names go away
when the mount namespace goes away making them very easy to manage.

Being able to open the file instead of passing a path to setns
allows a process for private per process naming (via file descriptors).

To get a practical feel of this it may be worth looking at iproute.

ip netns add
ip netns del
ip netns exec

Eric
