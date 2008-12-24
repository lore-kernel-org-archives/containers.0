From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC][PATCH 5/7][v4] Protect cinit from blocked fatal signals
Date: Wed, 24 Dec 2008 17:09:31 +0100
Message-ID: <20081224160931.GC11593@redhat.com>
References: <20081224114414.GA7879@us.ibm.com> <20081224115229.GE8020@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752138AbYLXQL6@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224115229.GE8020@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 12/24, Sukadev Bhattiprolu wrote:
>
> + * So, @signal is for a container-init and if @signr is either SIGKILL or
> + * SIGSTOP, it must have come from an ancestor namespace.

This is wrong. SIGKILL can be sent "internally", for example by
do_group_exit().

> + * If @signal refers to a container-init and @signr is neither SIGKILL nor
> + * SIGSTOP, it was queued because it was blocked when it was posted.

This is not right too. It is possible that init had a handler when
the signal was sent, and the handler was set to SIG_DFL before the
signal was dequeued.

> +static int unkillable_by_sig(struct signal_struct *signal, int signr)
> +{
> +	if ((signal->flags & SIGNAL_UNKILLABLE) && !sig_kernel_only(signr))
> +		return 1;
> +	return 0;
> +}
> +
>  int get_signal_to_deliver(siginfo_t *info, struct k_sigaction *return_ka,
>  			  struct pt_regs *regs, void *cookie)
>  {
> @@ -1909,9 +1944,11 @@ relock:
>  
>  		/*
>  		 * Global init gets no signals it doesn't want.
> +		 * Container-init gets no signals it doesn't want from same
> +		 * container.
>  		 */
> -		if (unlikely(signal->flags & SIGNAL_UNKILLABLE) &&
> -		    !signal_group_exit(signal))
> +		if (unkillable_by_sig(signal, signr) &&
> +				!signal_group_exit(signal))

No need to check signal_group_exit(signal). It was needed to
handle SIGKILL when it is sent by do_group_exit()/de_thread().
With this patch this is covered by sig_kernel_only().

Personally, I'd prefer to retain this check inline with a small
comment

		/* SMALL COMMENT ;) */
		if (unlikely(signal->flags & SIGNAL_UNKILLABLE) &&
		    !sig_kernel_only(signr))
			continue;

Oleg.
