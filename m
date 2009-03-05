From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][PATCH 00/11] track files for checkpointability
Date: Fri, 6 Mar 2009 01:00:44 +0300
Message-ID: <20090305220044.GA2819__19028.6963865676$1236290244$gmane$org@x200.localdomain>
References: <20090305163857.0C18F3FD@kernel>
	<20090305174037.GA2274@x200.localdomain>
	<1236280567.22399.99.camel@nimitz>
	<20090305210840.GA2499@x200.localdomain>
	<1236288427.22399.122.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1236288427.22399.122.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 05, 2009 at 01:27:07PM -0800, Dave Hansen wrote:
> > Imagine, unsupported file is opened between userspace checks
> > for /proc/*/checkpointable and /proc/*/fdinfo/*/checkpointable
> > and whatever, you stil have to do all the checks inside checkpoint(2).
> 
> Alexey, we have two problems here.  I completely agree that we have to
> do complete and thorough checks of each file descriptor at
> sys_checkpoint().  Any checks made at other times should not be trusted.
> 
> The other side is what Ingo has been asking for.  How do we *know* when
> we are checkpointable *before* we call (and without calling)

This "without calling checkpoint(2)" results in much complications
as demonstrated.

task_struct and file are not like other structures because they are exposed
in /proc. For PROC_FS=n kernels, one can't even check.

You can do checkpoint(2) without actual dump. You pass, you're most
certainly checkpointable (with inevitable race condition in mind).

With time the amount of stuff C/R won't support will approach zero,
but the infrastructure for "checkpointable" will stay constant.
If it's too much right now, it will be way too much in future.

> sys_checkpoint()?  You are yet to acknowledge that this is a valid use
> case, but it is exactly what Ingo is asking for, I believe.

It's a valid requirement.

> If nice printk()s are sufficient to cover what Ingo wants, I'm quite
> happy to remove the /proc files.  
