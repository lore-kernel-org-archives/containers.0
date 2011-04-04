From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 05/10] Core checkpoint/restart support code
Date: Mon, 4 Apr 2011 15:29:14 -0700
Message-ID: <20110404222914.GB27628__18718.3234295391$1301957557$gmane$org@count0.beaverton.ibm.com>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
	<1298936432-29607-6-git-send-email-ntl@pobox.com>
	<20110403190324.GD15044@hallyn.com>
	<1301929228.31531.39.camel@tp-t61>
	<20110404151017.GA4857@hallyn.com>
	<1301931608.31531.49.camel@tp-t61>
	<20110404162753.GA3456@hallyn.com>
	<4D9A00B1.2080002@cs.columbia.edu>
	<1301953409.31531.130.camel@tp-t61>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1301953409.31531.130.camel@tp-t61>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 04, 2011 at 04:43:29PM -0500, Nathan Lynch wrote:
> On Mon, 2011-04-04 at 13:32 -0400, Oren Laadan wrote:
> > From the technical point of view it *is* a big problem:  there are
> > very good reasons why we chose a certain design. 
> > 
> > If Natahan is suggesting in-kernel tree creation as a temporary thing
> > to simplify the code for review - then, given that this patch handles
> > a single process, doing so add lots of unnecessary code, all of which
> > in the kernel.
> > 
> > If this is the beginning of a permanent approach, then it is totally
> > incompatible with what we have done so far, and severely restricts 
> > the kind of use--cases of the project, potentially making it too
> > unattractive for many natural adaptors, like HPC users. Sorry, nack.
> 
> It's not a stopgap measure to "ease review" or whatever; recreating the
> task tree in-kernel is a fundamental - and simplifying - part of the
> design.  I have earned through painful experience the opinion that
> recreating the task tree in userspace is pretty much insane, as is
> exposing the pid allocator to userspace via eclone(2), as is attempting
> to support c/r of any resource that isn't isolated/virtualized, as is
> having every recreated task "rendezvous" in the kernel by having them
> all call restart(2), even though little significant work can be done in
> parallel.

So far we've been proceeding under the assumption that some userspace
code ugliness was acceptable if it simplified the kernel code. With
ghost issues and the stuff you've mentioned above I think it's become
questionable whether that choice has simplified the kernel code enough
and trying something different is valuable.

At this point the only advantage I still see in userspace task creation for
restart is the reviewability of it. eclone is a small piece of code that
can be reviewed independently of restart and thus will prove alot easier to
review for correctness and security than in-kernel task creation for restart.

Cheers,
	-Matt Helsley
