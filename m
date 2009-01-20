From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [PATCH 7/7][v7] proc: Show SIG_DFL signals to init as
	"ignored" signals
Date: Mon, 19 Jan 2009 17:04:53 -0800
Message-ID: <20090120010453.GA14612@us.ibm.com>
References: <20090117202638.GA11825@us.ibm.com> <20090117203753.GH11825@us.ibm.com> <20090117221909.GB3962@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761094AbZATBId@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090117221909.GB3962@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg@redhat.com] wrote:
| On 01/17, Sukadev Bhattiprolu wrote:
| >
| > Init processes ignore SIG_DFL signals unless they are from an ancestor
| > namespace.  Ensure /proc/pid/status correcly reports these signals.
| 
| This is the user-visible change, and I don't really understand why do we
| need it.

This discussion came up earlier, with Bastian and Roland and my understanding
was that we should fix the SigIgn line in /proc/pid/status - so I had added
a TODO for this patchset.

| 
| Imho, this patch can confuse the user-space. Why should we report that,
| say, SIGCONT is ignored by the global init?

But it is ignored right ?

Also, if user space looks at the SigIgn line and assumes that SIGKILL or
SIGUSR1 will kill init, user space can still be confused when it doesn't
really kill - no ?

| 
| 
| Even if I am wrong, I believe this change is orthogonal to rhis series,
| and should be posted separately.
| 

You are right that its not strictly tied to this patchset. init was
dropping SIGKILL before too.

So, should I just post separately or drop altogether ?

Sukadev
