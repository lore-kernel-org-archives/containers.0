From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 5/8] add f_op for checkpointability
Date: Fri, 20 Mar 2009 17:30:22 -0400
Message-ID: <49C40AEE.6040309__7194.03415355391$1237585122$gmane$org@cs.columbia.edu>
References: <20090227203425.F3B51176@kernel>	<20090227203431.D1E697CB@kernel>
	<20090228205329.GB4254@infradead.org>	<1236013556.26788.466.camel@nimitz>	<20090303131528.GB10931@infradead.org>
	<1237583604.8286.294.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237583604.8286.294.camel@nimitz>
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
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org



Dave Hansen wrote:
> On Tue, 2009-03-03 at 08:15 -0500, Christoph Hellwig wrote:
>> On Mon, Mar 02, 2009 at 09:05:56AM -0800, Dave Hansen wrote:
>>> On Sat, 2009-02-28 at 15:53 -0500, Christoph Hellwig wrote:
>>>> Also the double-use of the op seem not very nice to me.  Is there any
>>>> real life use case were you would have the operation on a file but
>>>> sometimes not allow checkpoiting?
>>> I'm still reaching here...
>>>
>>> I was thinking of /proc.  Opening your own /proc/$$/* would certainly be
>>> considered OK.  But, doing it for some other process not in your pid
>>> namespace would not be OK and would not be checkpointable.
>>>
>>> I know we're not quite in real-life territory here, yet, but I'm still
>>> thinking.
>> That mighr be a good enough excuse, I was just wondering what the use
>> case was.
> 
> I just thought of another one: unlinked files and directories.  They're
> a pain to checkpoint and won't be supported for a while.  Holding open
> an unlinked file would make a process uncheckpointable for a bit.

Actually, unlinked directories are the easiest to restore: you recreate it,
open it, and then immediately delete them. This works, because an unlinked
directory does not hold any data except for its existence.

For unlinked files, in physical file systems (non pseudo), for many apps
they are small in size, so a first approximation would be to save the
contents of that file with the checkpoint image, and on restart recreate
the file, put the contents, open it, and then unlink it again.

Oren.

> 
> -- Dave
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
