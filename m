From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 00/11] track files for checkpointability
Date: Thu, 05 Mar 2009 14:24:25 -0800
Message-ID: <1236291865.22399.139.camel__10554.0095516064$1236292003$gmane$org@nimitz>
References: <20090305163857.0C18F3FD@kernel>
	<20090305174037.GA2274@x200.localdomain>
	<1236280567.22399.99.camel@nimitz>
	<20090305210840.GA2499@x200.localdomain>
	<1236288427.22399.122.camel@nimitz>
	<20090305220044.GA2819@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090305220044.GA2819-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2009-03-06 at 01:00 +0300, Alexey Dobriyan wrote:
> On Thu, Mar 05, 2009 at 01:27:07PM -0800, Dave Hansen wrote:
> > > Imagine, unsupported file is opened between userspace checks
> > > for /proc/*/checkpointable and /proc/*/fdinfo/*/checkpointable
> > > and whatever, you stil have to do all the checks inside checkpoint(2).
> > 
> > Alexey, we have two problems here.  I completely agree that we have to
> > do complete and thorough checks of each file descriptor at
> > sys_checkpoint().  Any checks made at other times should not be trusted.
> > 
> > The other side is what Ingo has been asking for.  How do we *know* when
> > we are checkpointable *before* we call (and without calling)
> 
> This "without calling checkpoint(2)" results in much complications
> as demonstrated.

I'll let you take that up with Ingo. :)

> task_struct and file are not like other structures because they are exposed
> in /proc.

Very true.  But, we can always use the task as a proxy to say whether
any of this tasks's *resources* are uncheckpointable.  Is this task's
ipc_namespace checkpointable, etc...

> For PROC_FS=n kernels, one can't even check.

Definitely.  I'd be happy to make this check require PROC=y or even
DEBUGFS=y.  I just want to make the mechanism usable for developers so
they're more motivated to find and fix checkpoint issues.

> You can do checkpoint(2) without actual dump. You pass, you're most
> certainly checkpointable (with inevitable race condition in mind).

OK, so you envision this as maybe calling sys_checkpoint() with a -1 fd
or something?  I'm generally OK with that.  If the /proc stuff is really
the sticking point here, I'd be happy to stick it at the end of the
series so we can throw it away more easily.

> With time the amount of stuff C/R won't support will approach zero,
> but the infrastructure for "checkpointable" will stay constant.
> If it's too much right now, it will be way too much in future.

What have you seen in OpenVZ?  Do new things that are not checkpointable
pop up very often?

-- Dave
