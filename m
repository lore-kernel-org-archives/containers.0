From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] user-cr: Extract headers from kernel source tree.
Date: Mon, 5 Oct 2009 21:25:42 -0500
Message-ID: <20091006022542.GB31628@us.ibm.com>
References: <1254554424-2979-2-git-send-email-matthltc@us.ibm.com>
	<1254606041.2928.3.camel@localhost.localdomain>
	<20091005180000.GD18101@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091005180000.GD18101-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> On Sat, Oct 03, 2009 at 04:40:41PM -0500, Nathan Lynch wrote:
> > On Sat, 2009-10-03 at 00:20 -0700, Matt Helsley wrote:
> > > Sanitize kernel headers for userspace by extracting non-__KERNEL__
> > > portions of the various checkpoint headers and placing them in a
> > > similar organization of userspace headers.
> > > 
> > > The script is run from the top level of the user-cr source tree like:
> > > 
> > > 	./scripts/extract-headers.sh -s <path-to-kern-source> -o ./include
> > > 
> > > The patch includes a copy of the auto-generated headers and adjusts
> > > the user-cr programs to use them.
> > 
> > I appreciate the effort put into this, but why isn't the
> > "headers_install" target of the kernel Makefile sufficient to produce
> > headers that are usable by userspace?  So far as I know, other projects
> > with complex kernel/user interfaces (e.g. kvm) haven't had to resort to
> > special-purpose programs like this.
> 
> This script trims down the kernel headers from 4MB to 62k and places them
> in the user-cr source tree. That means it's reasonable to just copy user-cr
> anywhere and rebuild -- no need to copy your kernel headers seperately
> and then fuss with KERNELSRC etc.
> 
> At one point this patch also moved all arch-detection out of the Makefile
> and left it to cpp. That's no longer true now that we have the bits
> necessary for clone_with_pids. A seperate patch could finish that though.
> Removing arch-detection in the Makefile might make cross-compiling easier.
> 
> That said, it's not meant to replace /usr/include headers. When the
> syscall numbers make it into /usr/include, for instance, the part of this
> script that gathers them will be obsolete.
> 
> Lastly, it may be useful for anyone who wants to compare c/r headers to
> build checkpoint image translation tools. It should be alot easier to
> see the relevant changes...
> 
> So it's useful for me. Perhaps I should make it optional and toss it into
> contrib/ instead.

Perhaps we need more discussion on how we all compile this stuff...

On my one system, I don't have kernel sources on my target machine at
all.  Every time there is a meaningful change of headers I do
	scp include/linux/checkpoint* root@target:/usr/include/linux
	scp arch/s390/include/asm/checkpoint_hdr.h root@target:/usr/include/asm/

On my kvm partition, I can't recall whether make headers_install worked,
or whether I manually copied the checkpoint headers in.  I basically never
compile ckptinfo precisely because it requires finagling with KERNELSRC
and then doesn't compile anyway...

-serge
