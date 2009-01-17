From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 4/7][v7] Protect cinit from unblocked SIG_DFL signals
Date: Sat, 17 Jan 2009 23:12:42 +0100
Message-ID: <20090117221242.GA3962@redhat.com>
References: <20090117202638.GA11825@us.ibm.com> <20090117203621.GE11825@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765424AbZAQWPL@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090117203621.GE11825@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 01/17, Sukadev Bhattiprolu wrote:
>
> @@ -1331,7 +1341,7 @@ int send_sigqueue(struct sigqueue *q, struct task_struct *t, int group)
>  		goto ret;
>
>  	ret = 1; /* the signal is ignored */
> -	if (!prepare_signal(sig, t))
> +	if (!prepare_signal(sig, t, 1))

Hmm, just noticed. This looks wrong, it should be prepare_signal(sig, t, 0),
no?

For example, /sbin/init can create the posix timer with sigev_signo = SIGKILL
and it won't be killed before this patch.

This also looks wrong from the masquerading pov.


Otherwise, the patches 1-6 are imho fine.

Oleg.
