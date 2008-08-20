From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 1/4] checkpoint-restart: general infrastructure
Date: Wed, 20 Aug 2008 17:40:51 -0400
Message-ID: <48AC8F63.3050500@cs.columbia.edu>
References: <20080807224033.FFB3A2C1@kernel>
	<200808081146.54834.arnd@arndb.de>	<1218221451.19082.36.camel@nimitz>	<200808090013.41999.arnd@arndb.de>	<1218234411.19082.58.camel@nimitz>	<20080811150703.GA25930@us.ibm.com>
	<20080814055301.GH6995@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080814055301.GH6995-+ZI9xUNit7I@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>
Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Pavel Machek wrote:
> Hi!
> 
>>>>> I have to wonder if this is just a symptom of us trying to do this the
>>>>> wrong way.  We're trying to talk the kernel into writing internal gunk
>>>>> into a FD.  You're right, it is like a splice where one end of the pipe
>>>>> is in the kernel.
>>>>>
>>>>> Any thoughts on a better way to do this?  
>>>> Maybe you can invert the logic and let the new syscalls create a file
>>>> descriptor, and then have user space read or splice the checkpoint
>>>> data from it, and restore it by writing to the file descriptor.
>>>> It's probably easy to do using anon_inode_getfd() and would solve this
>>>> problem, but at the same time make checkpointing the current thread
>>>> hard if not impossible.
>>> Yeah, it does seem kinda backwards.  But, instead of even having to
>>> worry about the anon_inode stuff, why don't we just put it in a fs like
>>> everything else?  checkpointfs!
>> One reason is that I suspect that stops us from being able to send that
>> data straight to a pipe to compress and/or send on the network, without
>> hitting local disk.  Though if the checkpointfs was ram-based maybe not?
>>
>> As Oren has pointed out before, passing in an fd means we can pass a
>> socket into the syscall.
> 
> If you do pass a socket, will it handle blocking correctly? Getting
> deadlocked task would be bad. What happens if I try to snapshot into
> /proc/self/fd/0 ? Or maybe restore from /proc/cmdline?

Hmmm... these are good points.

Keep in mind that our principal goal is to checkpoint a whole container,
rather then a task to checkpoint itself (which is a by-product). Of course
your comments apply to a whole container as well.

In both cases, I don't think that blocking on a socket is a problem; the
checkpointer will enter a TASK_INTERRUPTIBLE state. Where is the deadlock ?
Writing or reading to/from /proc/self/... likewise - the programmer must
understand the implications, or the program won't work as expected. I don't
see a possible deadlock here, though.

For example - writing to /proc/self/fd/0 is ok; the state of fd[0] of that
task will be captured at some point in the middle of the checkpoint, so
after restart one cannot assume anything about the file position; the rest
should work.

Oren.
