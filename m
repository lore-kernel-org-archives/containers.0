From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 7/7][v7] proc: Show SIG_DFL signals to init as
	"ignored" signals
Date: Tue, 20 Jan 2009 08:33:05 +0100
Message-ID: <20090120073305.GA29130@redhat.com>
References: <20090117202638.GA11825@us.ibm.com> <20090117203753.GH11825@us.ibm.com> <20090117221909.GB3962@redhat.com> <20090120010453.GA14612@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759478AbZATHfb@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090120010453.GA14612@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 01/19, Sukadev Bhattiprolu wrote:
>
> Oleg Nesterov [oleg@redhat.com] wrote:
> | On 01/17, Sukadev Bhattiprolu wrote:
> | >
> | > Init processes ignore SIG_DFL signals unless they are from an ancestor
> | > namespace.  Ensure /proc/pid/status correcly reports these signals.
> |
> | This is the user-visible change, and I don't really understand why do we
> | need it.
>
> This discussion came up earlier, with Bastian and Roland and my understanding
> was that we should fix the SigIgn line in /proc/pid/status - so I had added
> a TODO for this patchset.

Hmm. I must admit I don't understand what this patch buys us. Admin should
know that init is special and can't be killed by the SIG_DFL signal.

Now we change the contents if pid/status, and every user-visible change
should have a good reason, imho.

> | Imho, this patch can confuse the user-space. Why should we report that,
> | say, SIGCONT is ignored by the global init?
>
> But it is ignored right ?

Following this logic, we can report that, say, SIG_DFL'ed SIGWINCH is always
ignored by any task, not only by init?

> Also, if user space looks at the SigIgn line and assumes that SIGKILL or
> SIGUSR1 will kill init, user space can still be confused when it doesn't
> really kill - no ?

yes, but this is oddity is very old.

But, otoh, SIGCHLD. There is a huge difference between SIG_IGN and SIG_DFL
in that case, why should we hide it?

More generally, why should we hide from admin what init does with signals?

> So, should I just post separately or drop altogether ?

I guess you already see that personally I dislike this patch ;) At least
I'd ask you to not mix it with this series.

But perhaps I am wrong, I can't "prove" this change is not good, I'd be
ready to agree with majority.

Oleg.
