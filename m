From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/7][v6] Protect cinit from blocked fatal signals
Date: Sun, 11 Jan 2009 07:15:05 +0100
Message-ID: <20090111061505.GB9014@redhat.com>
References: <20090107074558.GA27881@us.ibm.com>
	<20090107075214.GF27985@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090107075214.GF27985-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On 01/06, Sukadev Bhattiprolu wrote:
>
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -1890,9 +1890,16 @@ relock:
>
>  		/*
>  		 * Global init gets no signals it doesn't want.
> +		 * Container-init gets no signals it doesn't want from same
> +		 * container.
> +		 *
> +		 * Note that if global/container-init sees a sig_kernel_only()
> +		 * signal here, the signal must have been generated internally
> +		 * or must have come from an ancestor namespace. In either
> +		 * case, the signal cannot be dropped.
>  		 */
>  		if (unlikely(signal->flags & SIGNAL_UNKILLABLE) &&
> -		    !signal_group_exit(signal))
> +				!sig_kernel_only(signr))

Just for record. We still have small problem with fatal_signal_pending(cinit),
we should add a similar change to complete_signal to ensure that the pending
SIGKILL implies SIGNAL_GROUP_EXIT. But this needs another patch, and this
series is imho fine.

Oleg.
