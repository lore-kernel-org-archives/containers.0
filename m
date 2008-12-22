From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC][PATCH 5/6][v3] Protect cinit from unblocked SIG_DFL
	signals
Date: Mon, 22 Dec 2008 23:46:18 +0100
Message-ID: <20081222224618.GB1536@redhat.com>
References: <20081221005106.GA4912@us.ibm.com> <20081221005454.GE5025@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756068AbYLVWsU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081221005454.GE5025@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

On 12/20, Sukadev Bhattiprolu wrote:
>
> +static int sig_task_unkillable(struct task_struct *t, int same_ns)
> +{
> +	int flags = t->signal->flags;
> +
> +	if (unlikely(flags & SIGNAL_UNKILLABLE) ||
> +			(same_ns && (flags & SIGNAL_UNKILLABLE_FROM_NS)))
> +		return 1;

Hmm. I do not understand the point of the new flag,
SIGNAL_UNKILLABLE_FROM_NS (patch 3/6).

Actually, "same_ns" is a bad name, imho. It actually means "not from
parent ns", and this is not the same as "from the same ns".

Let's suppose we rename it, then the code becomes

	if (unlikely(flags & SIGNAL_UNKILLABLE) ||
		(!parent_ns && (flags & SIGNAL_UNKILLABLE_FROM_NS)))

But, parent_ns == T is not possible for the global init, so why
do we need the extra flag? we can just do

	if (unlikely(flags & SIGNAL_UNKILLABLE) && !parent_ns)
		return 1;

No?

> @@ -867,11 +886,17 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
>  {
>  	struct sigpending *pending;
>  	struct sigqueue *q;
> +	int same_ns;
>  
>  	trace_sched_signal_send(sig, t);
>  
>  	assert_spin_locked(&t->sighand->siglock);
> -	if (!prepare_signal(sig, t))
> +
> +	same_ns = 1;
> +	if (siginfo_from_ancestor_ns(t, info))
> +		same_ns = 0;

This looks a bit strang, why not

	same_ns = siginfo_from_ancestor_ns(t, info);

?

Oleg.
