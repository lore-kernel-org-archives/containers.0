From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 3/6][v5] Define siginfo_from_ancestor_ns()
Date: Mon, 5 Jan 2009 15:33:34 +0100
Message-ID: <20090105143334.GD3313@redhat.com>
References: <20081227204658.GA27197@us.ibm.com> <20081227205222.GB27337@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755401AbZAEOgW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081227205222.GB27337@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Really minor nit, just noticed...

On 12/27, Sukadev Bhattiprolu wrote:
>
> +static inline int siginfo_from_ancestor_ns(struct task_struct *t,
> +                       siginfo_t *info)
> +{
> +	struct pid_namespace *ns;
> +
> +	/*
> +	 * Ensure signal is from user-space before checking pid namespace.
> +	 * (We maybe called from interrupt context and dereferencing
> +	 * pid namespace would be safe).
> +	 */
> +	if (siginfo_from_user(info)) {

I can't parse the comment above, and imho it is confusing and
misleading. We can dereference pid namespace even in interrupt
context.

Also, the comment looks as if "when siginfo_from_user() is false,
it is not safe/possible to derive from_ancestor_ns". This is not
true, in that case we know that from_ancestor_ns must be false.

from_ancestor_ns == T means the signal was sent from the user
space, and it was sent to the task in the sub-namespace, so it
is clear why we check siginfo_from_user().

Oleg.
