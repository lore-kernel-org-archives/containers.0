From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 53/54] Detect resource leaks for
	whole-containercheckpoint
Date: Thu, 7 May 2009 14:45:01 -0700
Message-ID: <20090507214501.GA29671@us.ibm.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<1240961064-13991-54-git-send-email-orenl@cs.columbia.edu>
	<20090507061321.GA13725@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090507061321.GA13725-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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

On Wed, May 06, 2009 at 11:13:21PM -0700, Sukadev Bhattiprolu wrote:
> Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:

<snip>

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

Perhaps I'm misreading Oren's explanation, but the refcount on the file
should not be:

	2*#vmas(vm_file==mm->exe_file) + #fds(filp==mm->exe_file)

It should be:

	#vmas(vm_file==mm->exe_file) + #fds(filp==mm->exe_file) + 1(for mm->exe_file).

because added_exe_file_vma() increments num_exe_file_vmas but does not
change the file reference count. So incrementing the obj count while
walking the vmas and fds should bring the count 1 short of matching.

Cheers,
	-Matt
