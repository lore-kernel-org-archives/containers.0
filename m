From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14][PATCH 53/54] Detect resource leaks for
	whole-container checkpoint
Date: Wed, 6 May 2009 20:50:26 -0700
Message-ID: <20090507035026.GB6003@linux.vnet.ibm.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<1240961064-13991-54-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1240961064-13991-54-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| Add a 'users' count to objhash items, and, for a !CHECKPOINT_SUBTREE
| checkpoint, return an error code if the actual objects' counts are
| higher, indicating leaks (references to the objects from a task not
| being checkpointed).  Of course, by this time most of the checkpoint
| image has been written out to disk, so this is purely advisory.  But
| then, it's probably naive to argue that anything more than an advisory
| 'this went wrong' error code is useful.
| 
| The comparison of the objhash user counts to object refcounts as a
| basis for checking for leaks comes from Alexey's OpenVZ-based c/r
| patchset.
| 
| Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
| ---
|  checkpoint/checkpoint.c    |    8 +++
|  checkpoint/memory.c        |    2 +
|  checkpoint/objhash.c       |  108 +++++++++++++++++++++++++++++++++++++++----
|  include/linux/checkpoint.h |    2 +
|  4 files changed, 110 insertions(+), 10 deletions(-)
| 
| diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
| index 4319976..32a0a8e 100644
| --- a/checkpoint/checkpoint.c
| +++ b/checkpoint/checkpoint.c
| @@ -498,6 +498,14 @@ int do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
|  	if (ret < 0)
|  		goto out;
| 
| +	if (!(ctx->flags & CHECKPOINT_SUBTREE)) {
| +		/* verify that all objects are contained (no leaks) */
| +		if (!ckpt_obj_contained(ctx)) {
| +			ret = -EBUSY;
| +			goto out;
| +		}
| +	}
| +
|  	/* on success, return (unique) checkpoint identifier */
|  	ctx->crid = atomic_inc_return(&ctx_count);
|  	ret = ctx->crid;
| diff --git a/checkpoint/memory.c b/checkpoint/memory.c
| index 7637c1e..5ae2b41 100644
| --- a/checkpoint/memory.c
| +++ b/checkpoint/memory.c
| @@ -687,6 +687,8 @@ static int do_checkpoint_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
|  			ret = exe_objref;
|  			goto out;
|  		}
| +		/* account for all references through vma/exe_file */
| +		ckpt_obj_users_inc(ctx, mm->exe_file, mm->num_exe_file_vmas);

Do we really need to add num_exe_file_vmas here ?

A quick look at all callers for added_exe_file_vma() seems to show that
those callers also do a get_file().

Anyway, when I try to C/R a simple process tree, I get -EBUSY because
ckpt_obj_contained() finds a ref-count mismatch for the executable file.

I suspect the above increment of 'num_exe_file_vmas' is causing 
'obj->users' to exceed the value returned by the file's ->ref_users().

Or, when incrementing by 'num_exe_file_vmas', should we also call
obj_file_grab() ('num_exe_file_vmas' times) to keep the ref counts
in sync ?
