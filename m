From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 53/54] Detect resource leaks
	forwhole-containercheckpoint
Date: Fri, 8 May 2009 01:12:25 -0700
Message-ID: <20090508081225.GB29671@us.ibm.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<1240961064-13991-54-git-send-email-orenl@cs.columbia.edu>
	<20090508045622.GA31731@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090508045622.GA31731-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, May 07, 2009 at 09:56:22PM -0700, Sukadev Bhattiprolu wrote:
> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> | 
> | 
> | Sukadev Bhattiprolu wrote:
> | > Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
> | > | Add a 'users' count to objhash items, and, for a !CHECKPOINT_SUBTREE
> | > | checkpoint, return an error code if the actual objects' counts are
> | > | higher, indicating leaks (references to the objects from a task not
> | > | being checkpointed).  Of course, by this time most of the checkpoint
> | > | image has been written out to disk, so this is purely advisory.  But
> | > | then, it's probably naive to argue that anything more than an advisory
> | > | 'this went wrong' error code is useful.
> | > | 
> | > | The comparison of the objhash user counts to object refcounts as a
> | > | basis for checking for leaks comes from Alexey's OpenVZ-based c/r
> | > | patchset.
> | > | 
> | > | Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> | > | ---
> | > |  checkpoint/checkpoint.c    |    8 +++
> | > |  checkpoint/memory.c        |    2 +
> | > |  checkpoint/objhash.c       |  108 +++++++++++++++++++++++++++++++++++++++----
> | > |  include/linux/checkpoint.h |    2 +
> | > |  4 files changed, 110 insertions(+), 10 deletions(-)
> | > | 
> | > | diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> | > | index 4319976..32a0a8e 100644
> | > | --- a/checkpoint/checkpoint.c
> | > | +++ b/checkpoint/checkpoint.c
> | > | @@ -498,6 +498,14 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
> | > |  	if (ret < 0)
> | > |  		goto out;
> | > | 
> | > | +	if (!(ctx->flags & CHECKPOINT_SUBTREE)) {
> | > | +		/* verify that all objects are contained (no leaks) */
> | > | +		if (!ckpt_obj_contained(ctx)) {
> | > | +			ret = -EBUSY;
> | > | +			goto out;
> | > | +		}
> | > | +	}
> | > | +
> | > |  	/* on success, return (unique) checkpoint identifier */
> | > |  	ctx->crid = atomic_inc_return(&ctx_count);
> | > |  	ret = ctx->crid;
> | > | diff --git a/checkpoint/memory.c b/checkpoint/memory.c
> | > | index 7637c1e..5ae2b41 100644
> | > | --- a/checkpoint/memory.c
> | > | +++ b/checkpoint/memory.c
> | > | @@ -687,6 +687,8 @@ static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
> | > |  			ret = exe_objref;
> | > |  			goto out;
> | > |  		}
> | > | +		/* account for all references through vma/exe_file */
> | > | +		ckpt_obj_users_inc(ctx, mm->exe_file, mm->num_exe_file_vmas);
> | > 
> | > Do we really need to add num_exe_file_vmas here ?
> | > 
> | > A quick look at all callers for added_exe_file_vma() seems to show that
> | > those callers also do a get_file().
> | 
> | Each vma whose file is the same as mm->exe_file causes the refcount
> | of that file to increase by 2: once by vma->vm_file, and once via
> | added_exe_file_vma(). The c/r code calls ckpt_obj_checkpoint() only
> | once, thus once one obj_file_grab() for that file. The code above
> | accounts for the missing count.
> 
> If the executable is shared between a parent and child (as in fork()/dup_mm)
> do we still need to account for the 'added_exe_file_vma()' in the child
> process ?
> 
> i.e I can trace a call to added_exe_file_vma() when loading/mmaping a biniary.
> But I can't trace a call to added_exe_file_vma() during fork()/dup_mm()).

Yes, this is consistent with the common case. The count should usually
only change when exec'ing. That said, it increases as the original vmas
are split or merged as protection/permission bits change or sections are
unmapped altogether.
 
> Here is how I can account for the 16 in the obj->users :-)
> 
> 	Parent:
> 		do_checkpoint_mm: +2	= 2	(first time/obj_new())
> 		num_exe_vmas: +2	= 4

You mean mm->exe_file, not "num_exe_file_vmas"? num_exe_file_vmas
is irrelevant when it comes to checkpoint.

This seems odd: +4 to the obj->users count seems like 2 too many. It
should just be +2 -- once for mm->exe_file and once for the objhash
itself.

> 
> 		filemap_checkpoint: +1	= 5	(text section)
> 		filemap_checkpoint: +1	= 6	(data section)

These filemap_checkpoint counts make perfect sense.

> 
> 	Child:
> 		do_checkpoint_mm: +1	= 7

OK (for the child's mm->exe_file ref)

> 		num_exe_file_vmas: +2	= 9

Bad

> 
> 		filemap_checkpoint: +1	= 10	(text section)
> 		filemap_checkpoint: +1	= 11	(data section)
> 
> 	Grand child:
> 
> 		do_checkpoint_mm: +1	= 12

OK (for the child's mm->exe_file ref)

> 		num_exe_file_vmas: +2	= 14

Bad

> 
> 		filemap_checkpoint: +1	= 15	(text section)
> 		filemap_checkpoint: +1	= 16	(data section)
> 
> Even if we were to drop the num_exe_file_vmas for the child and
> grand-child, we would be off by 2 :-(

Drop all the "num_exe_vmas" increments.

> As of now, I can account for 9 of the 10 found in file->f_count.
> 
> 
> 	Parent:
> 		load_a.out/do_mmap: +2	= 2	(text)
> 		load_aout/do_mmap(): +2	= 4	(data)

(aside: I don't know why these add two each... are you sure there
weren't two more refs by dup_mm_exe_file() in child and grandchild
below?)

These happen during exec. Are you missing this one:

	void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
	{
		if (new_exe_file)
			get_file(new_exe_file);
	...

	int flush_old_exec(struct linux_binprm * bprm)
	{
		char * name;
		int i, ch, retval;
		char tcomm[sizeof(current->comm)];

		/*
		 * Make sure we have a private signal table and that
		 * we are unassociated from the previous thread group.
		 */
		retval = de_thread(current);
		if (retval)
			goto out;

		set_mm_exe_file(bprm->mm, bprm->file); <----- *here*

		/*
		 * Release all of the old mmap stuff
		 */
		retval = exec_mmap(bprm->mm);
		if (retval)
			goto out;
	...

> 
> 	Child:
> 		dup_mm()/dup_mmap(): +1	= 5	(text)
> 		dup_mm()/dup_mmap(): +1	= 6	(data)

Odd. Should be += 3 for each fork-induced dup_mm():
	1 for text VMA
	1 for data VMA
	1 for mm->exe_file (see dup_mm_exe_file() in fs/proc/base.c)

> 
> 	Grand Child:
> 		dup_mm()/dup_mmap(): +1	= 7	(text)
> 		dup_mm()/dup_mmap(): +1	= 8	(data)
>
> 	Checkpoint/Objhash:
> 
> 		obj_new/obj_file_grab: +1 = 9

By dropping the "num_exe_vmas" additions to obj->users and assuming
I'm right about file->f_count being referenced three times for each
fork, I think that accounts for everything -- file->f_count == obj->users.

> Another question is regarding the obj->users = 2 in obj_new():
> 
> 	- one of this reference is for the get_file() in obj_file_grab()
> 	  called near the end of obj_new() right ?
> 
> 	- where can I find the other get_file() ?

I think in flush_old_exec() above.

Cheers,
	-Matt
