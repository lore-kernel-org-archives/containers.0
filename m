From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 5/6][v5] Protect cinit from blocked fatal signals
Date: Mon, 5 Jan 2009 16:16:08 +0100
Message-ID: <20090105151608.GE3313@redhat.com>
References: <20081227204658.GA27197@us.ibm.com> <20081227205409.GD27337@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755979AbZAEPSt@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081227205409.GD27337@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 12/27, Sukadev Bhattiprolu wrote:
>
> +		 * Container-init gets no signals it doesn't want from same
> +		 * container.
>  		 */
> -		if (unlikely(signal->flags & SIGNAL_UNKILLABLE) &&
> -		    !signal_group_exit(signal))
> +		if ((signal->flags & SIGNAL_UNKILLABLE) &&
> +				!sig_kernel_only(signr))

minor, but why did you remove unlikely() ?

And could you improve the changelog a bit? Please explain
that !signal_group_exit() was needed to handle the case
when the mt init does exit/exec and sends SIGKILL to all
sub-threads. Now this is covered by sig_kernel_only().

In short, please explain that if SIGNAL_UNKILLABLE task
sees the sig_kernel_only() signal here, then it was either
sent by the parent namespace or it was generated internally.
In both cases we should not drop it.

But your current changelog mostly explains why do we need
another SIGNAL_UNKILLABLE check in get_signal_to_deliver(),
this is orthogonal to the change itself.

Oleg.
