From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [C/R ARM][PATCH 1/3] ARM: Rudimentary syscall interfaces
Date: Wed, 24 Mar 2010 07:02:52 -0700
Message-ID: <20100324140252.GC5704__24249.5417049669$1269441894$gmane$org@count0.beaverton.ibm.com>
References: <1269219965-23923-1-git-send-email-christofferdall@christofferdall.dk>
	<1269219965-23923-2-git-send-email-christofferdall@christofferdall.dk>
	<20100323205342.GA19572@n2100.arm.linux.org.uk>
	<20100324020342.GB5704@count0.beaverton.ibm.com>
	<Pine.LNX.4.64.1003240055050.5867@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.1003240055050.5867-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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
Cc: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>, linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Mar 24, 2010 at 12:57:46AM -0400, Oren Laadan wrote:
> On Tue, 23 Mar 2010, Matt Helsley wrote:
> 
> > On Tue, Mar 23, 2010 at 08:53:42PM +0000, Russell King - ARM Linux wrote:
> > > On Sun, Mar 21, 2010 at 09:06:03PM -0400, Christoffer Dall wrote:
> > > > This small commit introduces a global state of system calls for ARM
> > > > making it possible for a debugger or checkpointing to gain information
> > > > about another process' state with respect to system calls.
> > > 
> > > I don't particularly like the idea that we always store the syscall
> > > number to memory for every system call, whether the stored version is
> > > used or not.
> > > 
> > > Since ARM caches are generally not write allocate, this means mostly
> > > write-only variables can have a higher than expected expense.
> > > 
> > > Is there not some thread flag which can be checked to see if we need to
> > > store the syscall number?
> > 
> > Perhaps before we freeze the task we can save the syscall number on ARM.
> > The patches suggest that the signal delivery path -- which the freezer
> > utilizes -- has the syscall number already.
> > 
> > Should work since the threads must be frozen first anyway.
> 
> I like the idea.
> 
> However, would it also work for those cases when the freezing does not 
> occur from the signal delivery path - e.g. for vfork and ptraced tasks ?

We could just as easily set it before the vfork uninterruptible completion.
ptracing I'd don't know about though.

Cheers,
	-Matt Helsley
