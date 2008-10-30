From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Thu, 30 Oct 2008 14:19:20 -0400
Message-ID: <4909FAA8.5000107@cs.columbia.edu>
References: <1225219047.12673.182.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1225219047.12673.182.camel@nimitz>
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
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


I'm not sure why you say it's "un-linux-y" to begin with. But to the
point, here are my thought:


1. What you suggest is to expose the internal data to user space and
pull it. Isn't that what cryo tried to do ?  And the conclusion was
that it takes too many interfaces to work out, code in, provide, and
maintain forever, with issues related to backward compatibility and
what not. In fact, the conclusion was "let's do a kernel-blob" !


2. So there is a high price tag for the extra flexibility - more code,
more complexity, more maintenance nightmare, more API fights. But the
real question IMHO is what do you gain from it ?

> This lets userspace pick and choose what parts of the checkpoint it
> cares about.

So what ?  Why do you ever need that ?  What sort of information would
you get from there, that you can't get from existing mechanism (ptrace) ?

If this is only to be able to parallelize checkpoint - then let's discuss
the problem, not a specific solution.

> It enables us to do all the I/O from userspace: no in-kernel
> sys_read/write().

What's so wrong with in-kernel vfs_read/write() ?  You mentioned deadlocks,
but I'm yet to see one and understand the prolbem. My experience with Zap
(and Andrey's with OpenVZ) has been pretty good.

If eventually this becomes the main issue, we can discuss alternatives
(some have been proposed in the past) and again, fit a solution to the
problem as opposed to fit a problem to a solution.

> I think this interface is much more flexible than a plain syscall.

Flexibility can be a friend or an enemy. Can you quantify or qualify what
you gain, for the high cost of going in that direction ?


3. Your approach doesn't play well with what I call "checkpoint that
involves self". This term refers to a process that checkpoints itself
(and only itself), or to a process that attempts to checkpoint its own
container.  In both cases, there is no other entity that will read the
data from the file system while the caller is blocked.


4. I'm not sure how you want to handle shared objects. Simply saying:

> This also shows how we might handle shared objects.

isn't quite convincing. Keep in mind that sharing is determined in kernel,
and in the order that objects are encountered (as they should only be
dumped once). There may be objects that are shared, and themselves refer
to objects that are shared, and such objects are best handles in a bundled
manner (e.g. think of the two fds of a pipe). I really don't see how you
might handle all of that with your suggested scheme.


5. Your suggestions leaves too many details out. Yes, it's a call for
discussion. But still. Zap, OpenVZ and other systems build on experience
and working code. We know how to do incremental, live, and other goodies.
I'm not sure how these would work with your scheme.


6. Performance: in one important use case I checkpoint the entire user
desktop once a second, with downtime (due to checkpoint) of < 15ms for
even busy configurations and large memory footprint. While syscall are
relatively cheap, I wonder if you approach could keep up with it.


Oren.

Dave Hansen wrote:
> I hate the syscall.  It's a very un-Linux-y way of doing things.  There,
> I said it.  Here's an alternative.  It still uses the syscall to
> initiate things, but it uses debugfs to transport the data instead.
> This is just a concept demonstration.  It doesn't actually work, and I
> wouldn't be using debugfs in practice.
> 
> System calls in Linux are fast.  Doing lots of them is not a problem.
> If it becomes one, we can always export a condensed version of this
> format next to the expanded one, kinda like ftrace does.  Atomicity with
> this approach is also not a problem.  The system call in this approach
> doesn't return until the checkpoint is completely written out.
> 
> This lets userspace pick and choose what parts of the checkpoint it
> cares about.  It enables us to do all the I/O from userspace: no
> in-kernel sys_read/write().  I think this interface is much more
> flexible than a plain syscall.
> 
> Want to do a fast checkpoint?  Fine, copy all data, use a lot of memory,
> store it in-kernel.  Dump that out when the filesystem is accessed.
> Destroy it when userspace asks.
> 
> Want to do a checkpoint with a small memory footprint?
> 10 write one struct
> 20 wait for userspace
> 30 goto 10
> 
> Userspace can loop like it is reading a pipe.  We could even track
> per-checkpoint memory usage in the cr_ctx and stop writing when we go
> over a certain memory threshold.
> 
> We can have two modes, internally.  Userspace never has to know what
> which one we've chosen.  Say we have a word of data to output.  We can
> either make a copy at sys_checkpoint() time and let the data continue to
> be modified (let the task run).  Or, we can keep the task frozen and
> generate data at debugfs read() time.  This means potentially zero
> copying of data until userspace wants it.
> 
> The same goes for structures which might have complicated locking or
> lifetime rules.  
> 
> This also shows how we might handle shared objects.
> 
> To use, just sys_checkpoint() as before, and look at /sys/kernel/debug/.
> Use the crid you got back from the syscall to locate your checkpoint.
> Write into the 'done' file when you want the sys_checkpoint() to return.
> 
> /sys/kernel/debug/checkpoint-1/
> /sys/kernel/debug/checkpoint-1/done
> /sys/kernel/debug/checkpoint-1/task-1141
> /sys/kernel/debug/checkpoint-1/task-1141/fds
> /sys/kernel/debug/checkpoint-1/task-1141/fds/1
> /sys/kernel/debug/checkpoint-1/task-1141/fds/1/coe
> /sys/kernel/debug/checkpoint-1/task-1141/fds/1/fd_nr
> /sys/kernel/debug/checkpoint-1/task-1141/fds/1/fd
> /sys/kernel/debug/checkpoint-1/task-1141/fds/0
> /sys/kernel/debug/checkpoint-1/task-1141/fds/0/coe
> /sys/kernel/debug/checkpoint-1/task-1141/fds/0/fd_nr
> /sys/kernel/debug/checkpoint-1/task-1141/fds/0/fd
> /sys/kernel/debug/checkpoint-1/files
> /sys/kernel/debug/checkpoint-1/files/2
> /sys/kernel/debug/checkpoint-1/files/2/f_version
> /sys/kernel/debug/checkpoint-1/files/2/f_pos
> /sys/kernel/debug/checkpoint-1/files/2/f_mode
> /sys/kernel/debug/checkpoint-1/files/2/f_flags
> /sys/kernel/debug/checkpoint-1/files/1
> /sys/kernel/debug/checkpoint-1/files/1/target
> /sys/kernel/debug/checkpoint-1/files/1/fd_type
> /sys/kernel/debug/checkpoint-1/files/1/f_version
> /sys/kernel/debug/checkpoint-1/files/1/f_pos
> /sys/kernel/debug/checkpoint-1/files/1/f_mode
> /sys/kernel/debug/checkpoint-1/files/1/f_flags
> 
> So, why not?
> 
> -- Dave
> 
> 
> ------------------------------------------------------------------------
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
