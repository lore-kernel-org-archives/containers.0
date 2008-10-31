From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Thu, 30 Oct 2008 20:12:28 -0700
Message-ID: <m1k5bpwj8j.fsf@frodo.ebiederm.org>
References: <1225219047.12673.182.camel@nimitz>
	<m163n9y7yb.fsf@frodo.ebiederm.org>
	<1225411757.12673.383.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1225411757.12673.383.camel@nimitz> (Dave Hansen's message of
	"Thu, 30 Oct 2008 17:09:17 -0700")
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

Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:

> On Thu, 2008-10-30 at 16:33 -0700, Eric W. Biederman wrote:

>> If you called it a core dump instead of a checkpoint you have exactly the same
> set
>> of issues.
>
> I completely agree with you that there's a lot of common ground here
> between coredumps and checkpoints.  I'm not aware of any applications
> like, let's say Oracle, that use coredumps in the process of normal
> execution.  Checkpoints must be more scalable and lower overhead than
> coredumps are.

Checkpoints certainly need to be as light weight as we can make them.

Checkpoints as backup of where you are in case the machine crashes
I'm not certain I believe in.  Checkpoints for saving state over
a kernel upgrade or for migrating to a different machine make a lot
of sense to me.

>> Why we are doing vfs_write instead of file->f_op->write I don't understand.
>
> That's an excellent question.  I assume you're asking because at least
> the elf core dump code uses it, right?

Yes.

>> > System calls in Linux are fast.  Doing lots of them is not a problem.
>> > If it becomes one, we can always export a condensed version of this
>> > format next to the expanded one, kinda like ftrace does.  Atomicity with
>> > this approach is also not a problem.  The system call in this approach
>> > doesn't return until the checkpoint is completely written out.
>> 
>> Extra copies for something (memory) you want to transfer quickly
>> and efficiently is a problem.
>
> That's definitely true.  But, as I said, this approach isn't bound to
> copying everything.  We have the flexibility to choose what we do.

With a file descriptor I can push the data onto a network socket and
the receiving process is on another computer.  0 copies, 0 trips
to user space.  I'm not certain how you would achieve that with filesystem
approach.

>> Reading the memory of another process is a problem, to the point
>> that the /proc/<pid>/mem interface has been removed from the kernel.
>
> Yes, this is certainly true.  All of the ptrace-related security issues
> surely tell us something.  But, I'm not sure of your point here.  Are
> you saying that using sys_checkpoint() to dump a process's pages is
> inherently safer than approach that uses a filesystem in order to do the
> same?

I'm saying inspecting another process is a very racy operation so something
we need to be especially careful with. 

>> > Want to do a fast checkpoint?  Fine, copy all data, use a lot of memory,
>> > store it in-kernel.  Dump that out when the filesystem is accessed.
>> > Destroy it when userspace asks.
>> 
>> > So, why not?
>> 
>> Besides the part of creating a bunch of questionable interfaces
>> that we need to support forever.
>> 
>> Ultimately the question is how do you do checkpoint restore and I just
>> don't see that happening with a filesystem interface.  Way way way too many
>> dangerous syscalls that are only needed for one thing.
>
> I completely understand what you're saying here.  But, could you
> distinguish how this differs from the current way that sys_checkpoint()
> does it?  Surely, the checkpoint format is an ABI.  It is a complex ABI
> with many, many constituent structures.  This is an ABI with many, many,
> ways of reading simple data.  Seems like just slicing up the problem
> differently to me.

I was thinking about restore.  Creating objects with a certain id can
easily be a security risk if you are not creating the namespace those
objects live in at the same time.  There is currently the downside
that we can't create namespaces as unprivileged users ( The
implementation of suid is so annoying). But the general concept still
applies, and if we ever get the uid namespace correct we will be able
to create namespaces as unprivileged users.

Eric
