From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v3][PATCH 1/9] Create syscalls: sys_checkpoint, sys_restart
Date: Thu, 4 Sep 2008 15:37:30 -0500
Message-ID: <20080904203730.GA28313__711.105639538978$1220561775$gmane$org@us.ibm.com>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0809040401320.5982@takamine.ncl.cs.columbia.edu>
	<20080904144223.GA19364@us.ibm.com>
	<48C01B92.60900@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48C01B92.60900-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >> Create trivial sys_checkpoint and sys_restore system calls. They will
> >> enable to checkpoint and restart an entire container, to and from a
> >> checkpoint image file descriptor.
> >>
> >> The syscalls take a file descriptor (for the image file) and flags as
> >> arguments. For sys_checkpoint the first argument identifies the target
> >> container; for sys_restart it will identify the checkpoint image.
> >>
> >> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> >> ---
> 
> [...]
> 
> >> +/**
> >> + * sys_checkpoint - checkpoint a container
> >> + * @pid: pid of the container init(1) process
> >> + * @fd: file to which dump the checkpoint image
> >> + * @flags: checkpoint operation flags
> >> + */
> >> +asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
> >> +{
> >> +	pr_debug("sys_checkpoint not implemented yet\n");
> >> +	return -ENOSYS;
> >> +}
> >> +/**
> >> + * sys_restart - restart a container
> >> + * @crid: checkpoint image identifier
> > 
> > So can we compare your api to Andrey's?
> > 
> > You've explained before that crid is used to tie together multiple
> > calls to checkpoint, but why do you have to specify it for restart?
> > Can't it just come from the fd?  Or, the fd will be passed in
> > seek()d to the right position for the data for this task, so the crid
> > won't be available there?
> 
> I added the 'crid' inside to support a mode of operation in which we
> would like the checkpoint data to remain in memory across multiple
> system calls. Here are example scenarios:
> 
> 1) We will want to reduce down time by first buffering the checkpoint
> image in memory, then resuming the container, and only then writing
> the data back to a (the) file descriptor.
> So instead of:
>   freeze -> checkpoint and write back -> unfreeze
> We want:
>   freeze -> checkpoint to buffer -> unfreeze -> write back
> I envision each of these steps to be a separate invocation of a syscall.
> to the 'crid' returned by the sys_checkpoint() at the 2nd step, will be
> used to identify that data in the 4th step. (Note, that between the
> unfreeze and the write-back, another checkpoint may be already taken).
> 
> 2) A task may want to take a checkpoint (e.g. of itself, or a whole
> container) and keep that checkpoint in memory; at a later time it may
> want to revert to that checkpoint. Moreover, it may keep multiple such
> checkpoints (to where it may want to return). 'crid' tells sys_restart
> which one to use.
> 
> Note that this 'crid' will in fact be tied to resources that are kept
> by the kernel - e.g. references to COW pages (when we add that).
> Louis suggested to use a specialized FD instead of a numeric 'crid'
> (that is: create a anonymous inode and a struct file that represent
> that checkpoint in the kernel, and return an FD to it). This approach
> has pros and cons of 'crid' (see the archives of the containers
> mailing list). For now I kept 'crid', but I'm definitely open to change
> it to a FD.
> 
> Oren.

Oh, so the crid identifies one checkpoint inside the file - the single
file can store multiple checkpoints?

> > Andrey, how will the 'ctid' in your patchset be used?  It sounds
> > like it's actually going to set some integer id on the created
> > container?  We actually don't have container ids (or even
> > containers) right now, so we probably don't want that in our api,
> > right?

-serge
