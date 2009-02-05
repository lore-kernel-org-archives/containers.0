From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/3] powerpc: bare minimum checkpoint/restart
	implementation
Date: Fri, 06 Feb 2009 08:01:22 +1100
Message-ID: <1233867682.4612.102.camel__35216.3258045495$1233867841$gmane$org@pasglop>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>
	<1233182478-27113-2-git-send-email-ntl@pobox.com>
	<1233718789.16867.156.camel@pasglop> <20090204155406.GA2039@us.ibm.com>
	<1233781099.4612.1.camel@pasglop> <498A284E.4050501@cs.columbia.edu>
	<1233793012.4612.32.camel@pasglop> <20090205160946.GF27410@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20090205160946.GF27410@us.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: containers@lists.osdl.org, Oren Laadan <orenl@cs.columbia.edu>, Nathan Lynch <ntl@pobox.com>, linuxppc-dev@ozlabs.org
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
