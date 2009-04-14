From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 00/30] C/R OpenVZ/Virtuozzo style
Date: Wed, 15 Apr 2009 00:49:12 +0400
Message-ID: <20090414204912.GA28458__23150.1246140853$1239742427$gmane$org@x200.localdomain>
References: <20090410023207.GA27788@x200.localdomain>
	<1239340031.24083.21.camel@nimitz>
	<20090413091423.GA19236@x200.localdomain>
	<49E4108A.8050201@cs.columbia.edu>
	<20090414145830.GA27461@x200.localdomain>
	<49E4D115.5080601@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49E4D115.5080601-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

> >>> * not having CAP_SYS_ADMIN on restart(2)
> >> Surely you have read already on the containers mailing list that
> >> for the *time being* we attempt to get as far as possible without
> >> requiring root privileges, to identify security hot-spots.
> > 
> > More or less everything is hotspot.
> 
> Going back to my example of a subtree above: what sort of security
> issues you would have here, assuming all restart operations go via
> the usual security checks just like syscalls, and we take special
> care about values we allow as input, e.g. cpu debug registers etc ?

This is like asking if everything goes through correct security checks
how will you screw something up. Everything won't go via usual security
checks.

Just for giggles, writing exploit for localhost hole becomes easier --
you very effectively turn off all randomization kernel does because VMA
boundaries comes from disk.

> BTW, the checks for cpu registers and other values for sanity is
> needed anyway to ensure that the kernel freak out if wrong input
> is fed (maliciously or by mistake).

Out of head, mucking with registers of setuid program is no-no.
As well as mucking with dirty data of setuid program.

Capabilities will come from disk.

Many EPERM checks are suspect.

do_arch_prctl(ARCH_SET_GS) has TASK_SIZE check, do you?

> >> And surely you have read there the observation that for the general
> >> case root privileges will probably be inevitable.
> >>
> >> And surely you don't seriously think that adding this check changes
> >> the "design"...
> > 
> > This is not about design now, this is about if you allow restart(2) for
> > everyone, you open kernel to very very high number of holes of all
> > types. I wrote about it in reply to your code.
> > 
> 
> And there are many examples where this is not the case. The current
> patchset (v14-rc3), for example, to the best of my knowledge, does
> not have such issues (well, need to add checks for validity of regs
> but there is a FIXME comment :)

And such an obvious issue like segmentt RPL is fixed? :-)
