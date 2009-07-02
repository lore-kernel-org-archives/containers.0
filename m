From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] Disable CLONE_PARENT for init
Date: Thu, 2 Jul 2009 09:58:33 +0200
Message-ID: <20090702075833.GA14620__43013.9249693186$1246521827$gmane$org@redhat.com>
References: <20090701073140.GA14284@us.ibm.com>
	<20090701074654.A6C6321D57@magilla.sf.frob.com>
	<20090701082452.GA3297@redhat.com>
	<20090701214805.GA25734@us.ibm.com>
	<20090701215833.876DA404FD@magilla.sf.frob.com>
	<20090702003520.GA26247@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090702003520.GA26247-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/01, Sukadev Bhattiprolu wrote:
>
> --- linux-mmotm.orig/kernel/fork.c	2009-06-30 23:01:06.000000000 -0700
> +++ linux-mmotm/kernel/fork.c	2009-07-01 17:29:09.000000000 -0700
> @@ -974,6 +974,16 @@ static struct task_struct *copy_process(
>  	if ((clone_flags & CLONE_SIGHAND) && !(clone_flags & CLONE_VM))
>  		return ERR_PTR(-EINVAL);
>
> +	/*
> +	 * Siblings of global init remain as zombies on exit since they are
> +	 * not reaped by their parent (swapper). To solve this and to avoid
> +	 * multi-rooted process trees, prevent global and container-inits
> +	 * from creating siblings.
> +	 */
> +	if ((clone_flags & CLONE_PARENT) &&
> +				current->signal->flags & SIGNAL_UNKILLABLE)
> +		return ERR_PTR(-EINVAL);

Acked-by: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
