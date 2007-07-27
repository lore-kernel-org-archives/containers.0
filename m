From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH 9/15] Move alloc_pid() after the namespace is cloned
Date: Fri, 27 Jul 2007 19:12:39 +0400
Message-ID: <20070727151238.GA336@tv-sign.ru>
References: <46A8B37B.6050108@openvz.org> <46A8B531.3050602@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <46A8B531.3050602-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/26, Pavel Emelyanov wrote:
>
> This is a fix for Sukadev's patch that moved the alloc_pid() call from
> do_fork() into copy_process().

... and this patch changes almost every line from Sukadev's patch.
Sorry gents, but isn't it better to ask Andrew to drop that patch
(which is quite useless by itself), and send a new one which incorporates
all necessary changes? Imho, it would be much easier to understand.

> @@ -1406,7 +1422,13 @@ long do_fork(unsigned long clone_flags,
> 	if (!IS_ERR(p)) {
> 		struct completion vfork;
> 
> -		nr = pid_nr(task_pid(p));
> +		/*
> +		 * this is enough to call pid_nr_ns here, but this if
> +		 * improves optimisation of regular fork()
> +		 */
> +		nr = (clone_flags & CLONE_NEWPID) ?
> +			task_pid_nr_ns(p, current->nsproxy->pid_ns) :
> +				task_pid_vnr(p);

Shouldn't we do the same for CLONE_PARENT_SETTID in copy_process() ?
Otherwise *parent_tidptr may have a wrong value which doesn't match
to what fork() returns.

Oleg.
