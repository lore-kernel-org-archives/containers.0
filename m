From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] powerpc: bare minimum checkpoint/restart
	implementation
Date: Thu, 5 Feb 2009 10:09:46 -0600
Message-ID: <20090205160946.GF27410__39073.7943970182$1233851108$gmane$org@us.ibm.com>
References: <1233182478-27113-1-git-send-email-ntl@pobox.com>
	<1233182478-27113-2-git-send-email-ntl@pobox.com>
	<1233718789.16867.156.camel@pasglop>
	<20090204155406.GA2039@us.ibm.com>
	<1233781099.4612.1.camel@pasglop>
	<498A284E.4050501@cs.columbia.edu>
	<1233793012.4612.32.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1233793012.4612.32.camel@pasglop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Benjamin Herrenschmidt (benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org):
> On Wed, 2009-02-04 at 18:44 -0500, Oren Laadan wrote:
> > * Anything that is decided at compiled time should probably go to the arch-
> > dependent header.
> > 
> > * Anything that can change at boot time (e.g., for x86 that would include
> > the capabilities of the FPU), or even run time (is there any ?) should
> > be described to the letter (in fine print) in 'struct cr_hdr_cpu' and
> > friends.
> 
> I think we should avoid compile time completely.
> 
> We mostly try to have kernels running on everything anyway, and there's
> no reason not to be able to move a snapshot to a different CPU if it's
> not using a feature of the CPU that is different.

Absolutely, but the accepted way to handle that so far is that if
you want to run an "incompatible" checkpoint image on a new cpu,
a userspace program will rewrite the image to be correct for the target
cpu.

But what you list below seems more usable than trying to encapsulate
that info in some hokey version number system.

> Nathan, what about you start the structure with a 64 bit bitmask that
> indicates what "records" are present followed by concatenated records ?
> 
> IE. The "main" state (pt_regs) wouldn't change, but then, you could have
> a list of things:
> 
>  - FPRs
>  - old style VSX
>  - VSRs
>  - Freescale SPE state
>  - DABR
>  - BookE IAC/DACs
>  - tbd...
> 
> Then, when resuming a snapshot, we can use some bit masks trickery
> indicating the validity on a given target. IE. If CPU has no VSX and
> original program uses VSX then you can't resume. But if CPU has VSR you
> can.. etc... We can keep it trivial at fist, especting the same
> features, and try to be smart later.
> 
> Ben.
> 
