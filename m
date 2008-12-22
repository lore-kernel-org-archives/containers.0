From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC][PATCH 4/6][v3] Define siginfo_from_ancestor_ns()
Date: Mon, 22 Dec 2008 23:26:04 +0100
Message-ID: <20081222222604.GA1536@redhat.com>
References: <20081221005106.GA4912@us.ibm.com> <20081221005424.GD5025@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755727AbYLVW2g@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081221005424.GD5025@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

On 12/20, Sukadev Bhattiprolu wrote:
>
> + * TODO:
> + * 	  Making SI_ASYNCIO a kernel signal could make this less hacky.
> + */
> +#ifdef CONFIG_PID_NS
> +static inline int siginfo_from_user(siginfo_t *info)
> +{
> +	if (!is_si_special(info) && SI_FROMUSER(info) &&

OK, if we can trust SI_FROMUSER(), then it is better, i agree.

I was worried about in-kernel usage of .si_code <= 0 ...

> +				info->si_code != SI_ASYNCIO)

but this is horrible, imho.

OK, if we can't change the ABI, then perhaps we can change
kill_pid_info_as_uid() to not send the fatal signals to UNKILLABLE
task? This helper is strange and ugly anyway,


To clarify, I do not blame the patch itself, and I do not suggest
to do this right now.

Oleg.
