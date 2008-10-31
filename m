From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Thu, 30 Oct 2008 17:09:17 -0700
Message-ID: <1225411757.12673.383.camel@nimitz>
References: <1225219047.12673.182.camel@nimitz>
	<m163n9y7yb.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m163n9y7yb.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2008-10-30 at 16:33 -0700, Eric W. Biederman wrote:
> Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
> > I hate the syscall.  It's a very un-Linux-y way of doing things.  There,
> > I said it.  Here's an alternative.  It still uses the syscall to
> > initiate things, but it uses debugfs to transport the data instead.
> > This is just a concept demonstration.  It doesn't actually work, and I
> > wouldn't be using debugfs in practice.
> 
> A syscall is a very linux-y way to do it.

Darn, I thought I'd be able to sneak that one by.

> If you called it a core dump instead of a checkpoint you have exactly the same set
> of issues.

I completely agree with you that there's a lot of common ground here
between coredumps and checkpoints.  I'm not aware of any applications
like, let's say Oracle, that use coredumps in the process of normal
execution.  Checkpoints must be more scalable and lower overhead than
coredumps are.

> Why we are doing vfs_write instead of file->f_op->write I don't understand.

That's an excellent question.  I assume you're asking because at least
the elf core dump code uses it, right?

> > System calls in Linux are fast.  Doing lots of them is not a problem.
> > If it becomes one, we can always export a condensed version of this
> > format next to the expanded one, kinda like ftrace does.  Atomicity with
> > this approach is also not a problem.  The system call in this approach
> > doesn't return until the checkpoint is completely written out.
> 
> Extra copies for something (memory) you want to transfer quickly
> and efficiently is a problem.

That's definitely true.  But, as I said, this approach isn't bound to
copying everything.  We have the flexibility to choose what we do.

> Reading the memory of another process is a problem, to the point
> that the /proc/<pid>/mem interface has been removed from the kernel.

Yes, this is certainly true.  All of the ptrace-related security issues
surely tell us something.  But, I'm not sure of your point here.  Are
you saying that using sys_checkpoint() to dump a process's pages is
inherently safer than approach that uses a filesystem in order to do the
same?

> > Want to do a fast checkpoint?  Fine, copy all data, use a lot of memory,
> > store it in-kernel.  Dump that out when the filesystem is accessed.
> > Destroy it when userspace asks.
> 
> > So, why not?
> 
> Besides the part of creating a bunch of questionable interfaces
> that we need to support forever.
> 
> Ultimately the question is how do you do checkpoint restore and I just
> don't see that happening with a filesystem interface.  Way way way too many
> dangerous syscalls that are only needed for one thing.

I completely understand what you're saying here.  But, could you
distinguish how this differs from the current way that sys_checkpoint()
does it?  Surely, the checkpoint format is an ABI.  It is a complex ABI
with many, many constituent structures.  This is an ABI with many, many,
ways of reading simple data.  Seems like just slicing up the problem
differently to me.

-- Dave
