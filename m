From: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 1/3] powerpc: bare minimum checkpoint/restart
	implementation
Date: Fri, 06 Feb 2009 08:01:22 +1100
Message-ID: <1233867682.4612.102.camel__32059.4178782359$1233867846$gmane$org@pasglop>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>
	<1233182478-27113-2-git-send-email-ntl@pobox.com>
	<1233718789.16867.156.camel@pasglop> <20090204155406.GA2039@us.ibm.com>
	<1233781099.4612.1.camel@pasglop> <498A284E.4050501@cs.columbia.edu>
	<1233793012.4612.32.camel@pasglop> <20090205160946.GF27410@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090205160946.GF27410-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


> Absolutely, but the accepted way to handle that so far is that if
> you want to run an "incompatible" checkpoint image on a new cpu,
> a userspace program will rewrite the image to be correct for the target
> cpu.

That doesn't sound nice and definitely not something we want to do on
PowerPC. There are lots of reasons for that including the fact that the
actual feature set may depend on what the FW enabled which itself can
depend on the kernel version .. or not, etc etc...

I'd rather keep all that logic in the kernel to be honest.

> But what you list below seems more usable than trying to encapsulate
> that info in some hokey version number system.

There are things however that I can't expose and for which we can't do
much about.

IE. The kernel exposes some features to userspace, such as the PowerPC
ISA level supported, the presence of some optional instructions, etc...

We don't know whether the user space program is using that stuff
though... ie, we could get into situations where userspace is trying to
use, let's say, 44x MAC instructions, and thus that program will fail to
resume on some other processor, and we have no way to know about it from
the kernel.

But I'll leave that problem for later... Maybe we should implement some
way, using personalities or something similar, to run programs so that
they see a limited set of CPU features, for people who explicitely want
them to be migrateable.. a bit similar to what our Hypervisor does if
you want a partition to be migrateable between different processors, it
only advertises the common subset of functionality.

Ben.
