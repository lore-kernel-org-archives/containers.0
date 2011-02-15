From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] pidns: Support unsharing the pid namespace.
Date: Tue, 15 Feb 2011 20:01:18 +0100
Message-ID: <20110215190118.GA16707__26023.7603135922$1297870187$gmane$org@redhat.com>
References: <1297788824-20534-1-git-send-email-daniel.lezcano@free.fr>
	<1297788824-20534-2-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1297788824-20534-2-git-send-email-daniel.lezcano-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On 02/15, Daniel Lezcano wrote:
>
> - Pass both nsproxy->pid_ns and task_active_pid_ns to copy_pid_ns
>   As they can now be different.

But since they can be different we have to convert some users of
current->nsproxy first? But that patch was dropped.

> Unsharing of the pid namespace unlike unsharing of other namespaces
> does not take effect immediately.  Instead it affects the children
> created with fork and clone.

IOW, unshare(CLONE_NEWPID) implicitly affects the subsequent fork(),
using the very subtle way.

I have to admit, I can't say I like this very much. OK, if we need
this, can't we just put something into, say, signal->flags so that
copy_process can check and create the new namespace.

Also. I remember, I already saw something like this and google found
my questions. I didn't actually read the new version, perhaps my
concerns were already answered...

	But what if the task T does unshare(CLONE_NEWPID) and then, say,
	pthread_create() ? Unless I missed something, the new thread won't
	be able to see T ?

	and, in this case the exiting sub-namespace init also kills its
	parent?

	OK, suppose it does fork() after unshare(), then another fork().
	In this case the second child lives in the same namespace with
	init created by the 1st fork, but it is not descendant ? This means
	in particular that if the new init exits, zap_pid_ns_processes()->
	do_wait() can't work.

Or not?

Oleg.
