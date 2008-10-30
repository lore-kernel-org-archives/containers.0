From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Thu, 30 Oct 2008 12:37:31 -0700
Message-ID: <1225395451.12673.348.camel@nimitz>
References: <1225219047.12673.182.camel@nimitz>
	<4909FAA8.5000107@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4909FAA8.5000107-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2008-10-30 at 14:19 -0400, Oren Laadan wrote:
> I'm not sure why you say it's "un-linux-y" to begin with. But to the
> point, here are my thought:
> 
> 1. What you suggest is to expose the internal data to user space and
> pull it. Isn't that what cryo tried to do ?

No, cryo attempted to use existing kernel interfaces when they exist,
and create new ones in different places one at a time.

> And the conclusion was
> that it takes too many interfaces to work out, code in, provide, and
> maintain forever, with issues related to backward compatibility and
> what not.

You may have concluded that. :)

> In fact, the conclusion was "let's do a kernel-blob" !

This is a blob.  It's simply a blob exported in a filesystem.  Note that
it exports the same format as the 'big blob' with the same types.  Stick
a couple of cr_hdr* objects on to what we have in the filesystem, and we
get the same blob that we have now.

How would a tarball of this filesystem be any less of a blob than the
output from sys_checkpoint() is now?

> 2. So there is a high price tag for the extra flexibility - more code,
> more complexity, more maintenance nightmare, more API fights. But the
> real question IMHO is what do you gain from it ?

I think I've shown here that it can be done in a tremendously small
amount of code.  There are no more API fights than what we would have
now for each additional type of 'struct cr_something' that the syscall
would spit out.

> > This lets userspace pick and choose what parts of the checkpoint it
> > cares about.
> 
> So what ?  Why do you ever need that ?

The simplest example would be checkpointing 'cat > some_file'.  Perhaps
the restorer doesn't want to write to some_file.  The important thing to
them is to get the stdout and not redirect it.  This gets down to the
"what fds do you checkpoint" problem.  We've discussed this, and your
approach is to add another kernel interface which flags fds before the
checkpoint.  Right?  This would obviate the need for such an interface
inside the kernel.

> If this is only to be able to parallelize checkpoint - then let's discuss
> the problem, not a specific solution.

This approach parallelizes naturally.  There's no additional code in the
kernel to handle it.  It certainly isn't the only reason, though.

> > It enables us to do all the I/O from userspace: no in-kernel
> > sys_read/write().
> 
> What's so wrong with in-kernel vfs_read/write() ?  You mentioned deadlocks,
> but I'm yet to see one and understand the prolbem. My experience with Zap
> (and Andrey's with OpenVZ) has been pretty good.
> 
> If eventually this becomes the main issue, we can discuss alternatives
> (some have been proposed in the past) and again, fit a solution to the
> problem as opposed to fit a problem to a solution.

As Andrew said, this is a very unconventional way of doing things.  My
approach is certainly more conventional, and proved to work.  We should
have very, very good reasons for departing from what we know to work. 


> 3. Your approach doesn't play well with what I call "checkpoint that
> involves self". This term refers to a process that checkpoints itself
> (and only itself), or to a process that attempts to checkpoint its own
> container.  In both cases, there is no other entity that will read the
> data from the file system while the caller is blocked.

I would propose an in-userspace solution for this issue.  If a process
wants to checkpoint itself, it must first fork and let the forked
process do the checkpoint.

In practice, I expect self-checkpoint to be a very small minority of the
use of this feature.  Applications smart enough to self-checkpoint are
probably smart enough not to need to. 

> 4. I'm not sure how you want to handle shared objects. Simply saying:
> 
> > This also shows how we might handle shared objects.
> 
> isn't quite convincing. Keep in mind that sharing is determined in kernel,
> and in the order that objects are encountered (as they should only be
> dumped once). There may be objects that are shared, and themselves refer
> to objects that are shared, and such objects are best handles in a bundled
> manner (e.g. think of the two fds of a pipe). I really don't see how you
> might handle all of that with your suggested scheme.

In all fairness, what you posted doesn't show pipes, either. :)

But, in your approach, you would be reading from the 'struct
cr_hdr_files' and you would see a pipe fd along with its identifier in
the cr_hdr_fd_ent->objref field.  You would do a lookup in the hash
table on that objref and either return a pipe if one is there, or create
a new one if the other end hasn't been seen yet.  Right?

All we need to export with my scheme is the inode nr in the pipe
filesystem and the fact that the pipe is a pipe.  In other words, create
something like this:

/sys/kernel/debug/checkpoint-1/files/2/f_isapipe
/sys/kernel/debug/checkpoint-1/files/2/f_inode_nr

Just substitute whatever flags or things you would have used inside
'cr_hdr_fd_ent' to denote the presence of a pipe.  This could use the
same.

If we were doing a configfs-style restart, the restarter would simply
restore those two files.  The act of doing open(O_CREAT) is the same
trigger as what you have now when a cr_hdr of some type is encountered.

> 5. Your suggestions leaves too many details out. Yes, it's a call for
> discussion. But still. Zap, OpenVZ and other systems build on experience
> and working code. We know how to do incremental, live, and other goodies.
> I'm not sure how these would work with your scheme.

Well, we haven't even gotten to memory, yet.  For incremental and live,
virtually all the data is memory contents, right?

I understand this is *different* from what you're using, and that
reduces your confidence in it.  That's unavoidable.  But, can you share
your insight into incremental and live checkpointing to point out things
which conflict with this approach?

> 6. Performance: in one important use case I checkpoint the entire user
> desktop once a second, with downtime (due to checkpoint) of < 15ms for
> even busy configurations and large memory footprint. While syscall are
> relatively cheap, I wonder if you approach could keep up with it.

Again, I think this all comes down to how we do memory.  If we have one
file per byte of memory, I think we'll see syscall overhead.  All of the
other data that gets transferred is going to be teeny compared to
memory.

-- Dave
