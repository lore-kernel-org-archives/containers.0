From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] Send checkpoint and restart debug info to a log
	file (v2)
Date: Mon, 26 Oct 2009 16:52:38 -0500
Message-ID: <20091026215238.GA10900@us.ibm.com>
References: <20091021210507.GA2098@us.ibm.com> <4ADF853F.6080807@librato.com>
	<20091021224922.GA5827@us.ibm.com> <4ADF95D0.8060806@librato.com>
	<20091022005157.GA11608@us.ibm.com>
	<20091022060400.GE7757@count0.beaverton.ibm.com>
	<4AE1FA7A.5030702@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AE1FA7A.5030702-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> 
> 
> Matt Helsley wrote:
> > On Wed, Oct 21, 2009 at 07:51:57PM -0500, Serge E. Hallyn wrote:
> >> Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> > 
> > <snip>
> > 
> >>>> More practically, requiring userspace to pass over a flag
> >>>> consisting of CKPT_DBG_MEM|CKPT_DBG|FILE|CKPT_DBG|TASK, and
> >>>> handle corresponding usage flags, is not nice.
> >>> I agree with you on about this. Maybe we want a better
> >>> interface ?
> >>>
> >>> Which brings me to this random thought: maybe we want to
> >>> make the fourth argument of sys_{checkpoint,restart} a
> >>> structure, to make it easier to extend it in the future
> >>> without having to go throw a clone3-like hell...
> > 
> > Adding new kernel interfaces is supposed to be somewhat hellish.
> > 
> >>> Specifically, this structure could now be:
> >>>
> >>> struct ckpt_args {
> >>> 	int version;
> >>> 	int logfd;
> >>> 	int logmask;
> >>> };
> >>>
> >>> (or use union checkpoint {} and union restart {} to tell
> >>> between checkpoint- and restart-related args.
> >> Well I don't like passing structs to the kernel actually (and
> > 
> > Let's not do this. I agree that passing structs, when unnecessary,
> > is gross. Especially if it gets used to extend the arguments
> > passed via the syscall interface (new flag values I don't mind).
> 
> Ok, we already allow future extension by being strict about
> which flags are taken or not.
> 
> Then what do we do with logmask ?   I prefer it to be a per-syscall
> value as opposed to a system-wise setting.

Ok well let's be honest with ourselves - we'd like to give end-users
reasonable debug info to figure out common problems.  But we will
always have cases where we have to hand-instrument the kernel for
our own advanced debugging.  Cases where you must print out only a
specific info to catch a race condition probably will fit into
such a case.  So I'd prefer to aim for giving the end-user just one
or a few options - nothing, errors only, or all debugging info that
we care to insert in everyday kernels (which hopefully isn't too
much, but let's a user figure out approximately where the problem
happened, i.e. recreating a socket, opening a file, etc).  Otherwise
too much debugging will (a) deter from the readability of the code
(b) bulk up the kernel and (c) make the api cumberson (too many
flags to checkpoint/restart userspace programs, and passing structs
to syscall).

In fact I'm wondering whether for the shipped c/r kernel we want
to have only ckpt_error()s and make sure we record the location in
the restart file where we errored out.  The ckpt_write_err() info
is already very helpful in tracking down checkpoint errors.  Of course
this becomes a pain whenever we introduce a subte bug and have to
hand-instrument everything.  And then I have to curse all the printks
I have to add.  But it's not reasonabe to have every other line of
c/r code be a debug statement either.

-serge
