From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 5/8] add f_op for checkpointability
Date: Fri, 20 Mar 2009 14:13:24 -0700
Message-ID: <1237583604.8286.294.camel__21040.3157551356$1237583861$gmane$org@nimitz>
References: <20090227203425.F3B51176@kernel>
	<20090227203431.D1E697CB@kernel> <20090228205329.GB4254@infradead.org>
	<1236013556.26788.466.camel@nimitz>
	<20090303131528.GB10931@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090303131528.GB10931-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
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
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2009-03-03 at 08:15 -0500, Christoph Hellwig wrote:
> On Mon, Mar 02, 2009 at 09:05:56AM -0800, Dave Hansen wrote:
> > On Sat, 2009-02-28 at 15:53 -0500, Christoph Hellwig wrote:
> > > Also the double-use of the op seem not very nice to me.  Is there any
> > > real life use case were you would have the operation on a file but
> > > sometimes not allow checkpoiting?
> > 
> > I'm still reaching here...
> > 
> > I was thinking of /proc.  Opening your own /proc/$$/* would certainly be
> > considered OK.  But, doing it for some other process not in your pid
> > namespace would not be OK and would not be checkpointable.
> > 
> > I know we're not quite in real-life territory here, yet, but I'm still
> > thinking.
> 
> That mighr be a good enough excuse, I was just wondering what the use
> case was.

I just thought of another one: unlinked files and directories.  They're
a pain to checkpoint and won't be supported for a while.  Holding open
an unlinked file would make a process uncheckpointable for a bit.

-- Dave
