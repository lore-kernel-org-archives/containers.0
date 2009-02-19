From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 1/5] create fs flag to mark c/r supported fs's
Date: Thu, 19 Feb 2009 11:24:51 -0800
Message-ID: <1235071491.26788.67.camel@nimitz>
References: <20090219182007.B4B47C1F@kernel>
	<20090219190009.GC28490@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090219190009.GC28490-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2009-02-19 at 14:00 -0500, Christoph Hellwig wrote:
> On Thu, Feb 19, 2009 at 10:20:07AM -0800, Dave Hansen wrote:
> > 
> > There are plenty of filesystems that are not supported for
> > c/r at this point.  Think of things like hugetlbfs which
> > are externally visible or pipefs which are kernel-internal.
> > 
> > This provides a quick way to make the "normal" filesystems
> > which are currently supported.  This is also safe if any
> > new code gets added.  We assume that a fs is non-supported
> > unless someone takes explicit action to the contrary.
> > 
> > I bet there are some more filesystems that are OK, but
> > these probably cover 99% of the users for now.
> 
> Given that a normal fs should be checkpointable you should
> make those exposing internal state, not the other way around.

In general I agree with you.  But, I think practicality gets in the way
here.  Here's the cscope output from file_system_type and
FS_REQUIRES_DEV (basically grepping the tree for them):

$ wc -l file_system_type FS_REQUIRES_DEV 
  256 file_system_type
   41 FS_REQUIRES_DEV

So, (very) roughly 1/6 of the filesystems are the "normal" block-based
ones that we all know and love.  The rest are ones that I'd have to at
the very least think about before saying that they're supported.

I guess we could say that FS_REQUIRES_DEV by default implies
FS_CHECKPOINTABLE:

#define __FS_REQUIRES_DEV 1
#define FS_REQUIRES_DEV (__FS_REQUIRES_DEV|FS_CHECKPOINTABLE)

I really don't mind doing it *that* much either way, but I'd sure like
to go specifically tag ~40 filesystems rather than 200.  

-- Dave
