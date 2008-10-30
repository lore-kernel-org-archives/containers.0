From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Thu, 30 Oct 2008 16:33:16 -0700
Message-ID: <m163n9y7yb.fsf@frodo.ebiederm.org>
References: <1225219047.12673.182.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1225219047.12673.182.camel@nimitz> (Dave Hansen's message of
	"Tue, 28 Oct 2008 11:37:27 -0700")
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

> I hate the syscall.  It's a very un-Linux-y way of doing things.  There,
> I said it.  Here's an alternative.  It still uses the syscall to
> initiate things, but it uses debugfs to transport the data instead.
> This is just a concept demonstration.  It doesn't actually work, and I
> wouldn't be using debugfs in practice.

A syscall is a very linux-y way to do it.

If you called it a core dump instead of a checkpoint you have exactly the same set
of issues.

Why we are doing vfs_write instead of file->f_op->write I don't understand.

> System calls in Linux are fast.  Doing lots of them is not a problem.
> If it becomes one, we can always export a condensed version of this
> format next to the expanded one, kinda like ftrace does.  Atomicity with
> this approach is also not a problem.  The system call in this approach
> doesn't return until the checkpoint is completely written out.

Extra copies for something (memory) you want to transfer quickly
and efficiently is a problem.

Reading the memory of another process is a problem, to the point
that the /proc/<pid>/mem interface has been removed from the kernel.
  
> This lets userspace pick and choose what parts of the checkpoint it
> cares about.  It enables us to do all the I/O from userspace: no
> in-kernel sys_read/write().  I think this interface is much more
> flexible than a plain syscall.

Then get with Roland McGraff and build the next generation user
space debugging interface.

> Want to do a fast checkpoint?  Fine, copy all data, use a lot of memory,
> store it in-kernel.  Dump that out when the filesystem is accessed.
> Destroy it when userspace asks.

> So, why not?

Besides the part of creating a bunch of questionable interfaces
that we need to support forever.

Ultimately the question is how do you do checkpoint restore and I just
don't see that happening with a filesystem interface.  Way way way too many
dangerous syscalls that are only needed for one thing.

Checkpoint/Restore are an atomic operation, and filesystems suck and building
high level atomic primitives.

Eric
