From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: c/r support on FUSE filesystems.
Date: Fri, 1 Apr 2011 15:00:21 -0700
Message-ID: <20110401220021.GO22601@count0.beaverton.ibm.com>
References: <AANLkTikPaUYrX8cKQMehNCL6bCjPBVkNa4G1Fs_Fu4XV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikPaUYrX8cKQMehNCL6bCjPBVkNa4G1Fs_Fu4XV-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vishnumurthy Prabhu <prabhuvishnumurthy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 01, 2011 at 11:30:24AM +0530, Vishnumurthy Prabhu wrote:
> hi,
> I just worked with implementation of of CR support for FUSE filesystems. I
> have attached two files here that support FUSE-cr. fuse_kcr.h/c belongs to
> fs/fuse dir. What I found is that similar approach as that of generic file
> checkpoint can be used in fuse also and it works fine. In fact I did
> separate implementation just because if there is any need for extra
> functionalities, we can add that in these, so I kept it separate.  I want
> know any problems or issues in this implementation.

This is definitely something we're interested in seeing.

My guess is since there are a lot of "Only in " lines that you didn't do the
manual diff correctly. That's making this posting hard to review.

We use the LKML patch review/submission process here too. Please have a look
at what LKML patch submissions are supposed to look like. At least read
Documentation/SubmittingPatches and Documentation/CodingStyle.

It seems like you generated the patch by hand and then concatenated some
source files by hand without mentioning their paths/names. I don't think
any tools will apply this patch correctly (most people use tools
which won't recognize this). Please consider using patch-generating tools
like git, mercurial, or quilt for example. git and mercurial have other big
advantages too -- you won't have to keep a mental list of modified files
or you won't have to wait a long time for diff to compare two huge kernel
source trees.

Can you tell us about the testing you've done with this? What kind of
additions/changes does this make to the FUSE userspace API? Can you
please describe how it's supposed to work with FUSE userspace code?

Thanks!

> 
> 
> Thank you
> regards,
> Vishnumurthy P

> Only in linux-cr: .config
> Only in linux-cr/drivers/gpu/drm/radeon: r100_reg_safe.h
> Only in linux-cr/drivers/gpu/drm/radeon: r200_reg_safe.h
> Only in linux-cr/drivers/gpu/drm/radeon: r300_reg_safe.h
> Only in linux-cr/drivers/gpu/drm/radeon: r420_reg_safe.h
> Only in linux-cr/drivers/gpu/drm/radeon: r600_reg_safe.h
> Only in linux-cr/drivers/gpu/drm/radeon: rn50_reg_safe.h
> Only in linux-cr/drivers/gpu/drm/radeon: rs600_reg_safe.h
> Only in linux-cr/drivers/gpu/drm/radeon: rv515_reg_safe.h

For example, I can't imagine that you modified these files when you
wrote FUSE c/r support. I suspect you're diff'ing two different kernel
versions.

> diff -crB linux-cr1/fs/checkpoint.c linux-cr/fs/checkpoint.c

If you continue diff'ing by hand could you please make it a unified context
diff (-u) with functions (-p) instead of a plain context diff (-c)?

> *** linux-cr1/fs/checkpoint.c	2010-09-14 06:59:05.026511080 +0530
> --- linux-cr/fs/checkpoint.c	2011-03-30 21:14:15.260306880 +0530
> ***************
> *** 711,716 ****
> --- 711,718 ----
>   				  struct ckpt_hdr_file *ptr);
>   };
>   
> + extern struct file *fuse_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr);
> + 
>   static struct restore_file_ops restore_file_ops[] = {
>   	/* ignored file */
>   	{
> ***************
> *** 760,765 ****
> --- 762,773 ----
>   		.file_type = CKPT_FILE_EVENTFD,
>   		.restore = eventfd_restore,
>   	},
> + 	/*FUSE filesystem .It needs special handling*/
> + 	{
> + 		.file_name = "FUSE",
> + 		.file_type = CKPT_FILE_FUSE,
> + 		.restore = fuse_file_restore,
> + 	},	
>   };
>   
>   static void *restore_file(struct ckpt_ctx *ctx)
> diff -crB linux-cr1/fs/fuse/dev.c linux-cr/fs/fuse/dev.c
> *** linux-cr1/fs/fuse/dev.c	2010-09-14 06:59:05.114511787 +0530
> --- linux-cr/fs/fuse/dev.c	2011-03-28 21:59:53.786456000 +0530
> ***************
> *** 35,41 ****
>   	memset(req, 0, sizeof(*req));
>   	INIT_LIST_HEAD(&req->list);
>   	INIT_LIST_HEAD(&req->intr_entry);
> ! 	init_waitqueue_head(&req->waitq);
>   	atomic_set(&req->count, 1);
>   }
>   
> --- 34,41 ----
>   	memset(req, 0, sizeof(*req));
>   	INIT_LIST_HEAD(&req->list);
>   	INIT_LIST_HEAD(&req->intr_entry);
> ! 	init_waitqueue_head(&req->waitq); //used to initialize a wait queue head variable that was allocated dynamically

Kernel folks tend to prefer seeing old-style C comments and not C++.
You might run a corrected patch through scripts/checkpatch.pl to see if there
are any other style points to address -- I'm not going to call them out
right now.

> ! 
>   	atomic_set(&req->count, 1);
>   }
>   
> ***************
> *** 102,108 ****
>   
>   	atomic_inc(&fc->num_waiting);
>   	block_sigs(&oldset);
> ! 	intr = wait_event_interruptible(fc->blocked_waitq, !fc->blocked);
>   	restore_sigs(&oldset);
>   	err = -EINTR;
>   	if (intr)
> --- 102,108 ----
>   
>   	atomic_inc(&fc->num_waiting);
>   	block_sigs(&oldset);
> ! 	intr = wait_event_interruptible(fc->blocked_waitq, !fc->blocked);  //waits on fc->blocked_waitq until fc->blocked becomes 0.

I don't think these comments are relevant to the patch...

>   	restore_sigs(&oldset);
>   	err = -EINTR;
>   	if (intr)
> diff -crB linux-cr1/fs/fuse/dir.c linux-cr/fs/fuse/dir.c
> *** linux-cr1/fs/fuse/dir.c	2010-09-14 06:59:05.114511787 +0530
> --- linux-cr/fs/fuse/dir.c	2011-03-28 21:59:53.802473000 +0530
> ***************
> *** 1576,1581 ****
> --- 1576,1584 ----
>   	.open		= fuse_dir_open,
>   	.release	= fuse_dir_release,
>   	.fsync		= fuse_dir_fsync,
> +  //#ifdef CONFIG_CHECKPOINT
> + 	//.checkpoint	= fuse_dir_checkpoint,
> +  //#endif
>   };
>   
>   static const struct inode_operations fuse_common_inode_operations = {
> diff -crB linux-cr1/fs/fuse/file.c linux-cr/fs/fuse/file.c
> *** linux-cr1/fs/fuse/file.c	2010-09-14 06:59:05.114511787 +0530
> --- linux-cr/fs/fuse/file.c	2011-03-28 21:59:53.737442000 +0530
> ***************
> *** 7,12 ****
> --- 7,13 ----
>   */
>   
>   #include "fuse_i.h"
> + #include "fuse_kcr.h"
>   
>   #include <linux/pagemap.h>
>   #include <linux/slab.h>
> ***************
> *** 1991,1996 ****
> --- 1992,2000 ----
>   	.unlocked_ioctl	= fuse_file_ioctl,
>   	.compat_ioctl	= fuse_file_compat_ioctl,
>   	.poll		= fuse_file_poll,
> + //#ifdef CONFIG_CHECKPOINT
> + 	.checkpoint	= fuse_file_checkpoint,
> + //#endif

Why are these cpp lines commented out?

>   };
>   
>   static const struct file_operations fuse_direct_io_file_operations = {
> ***************
> *** 2007,2012 ****
> --- 2011,2019 ----
>   	.unlocked_ioctl	= fuse_file_ioctl,
>   	.compat_ioctl	= fuse_file_compat_ioctl,
>   	.poll		= fuse_file_poll,
> + //#ifdef CONFIG_CHECKPOINT
> + 	.checkpoint	= fuse_file_checkpoint,
> + //#endif
>   	/* no splice_read */
>   };
>   
> Only in linux-cr/fs/fuse: fuse_kcr.c
> Only in linux-cr/fs/fuse: fuse_kcr.h

This is the core change introduced by your patchset and it looks like
it's missing...

> diff -crB linux-cr1/fs/fuse/inode.c linux-cr/fs/fuse/inode.c
> *** linux-cr1/fs/fuse/inode.c	2010-09-14 06:59:05.118512015 +0530
> --- linux-cr/fs/fuse/inode.c	2011-03-28 21:59:53.805496000 +0530
> ***************
> *** 1200,1206 ****
>   
>   	printk(KERN_INFO "fuse init (API version %i.%i)\n",
>   	       FUSE_KERNEL_VERSION, FUSE_KERNEL_MINOR_VERSION);
> ! 
>   	INIT_LIST_HEAD(&fuse_conn_list);
>   	res = fuse_fs_init();
>   	if (res)
> --- 1200,1208 ----
>   
>   	printk(KERN_INFO "fuse init (API version %i.%i)\n",
>   	       FUSE_KERNEL_VERSION, FUSE_KERNEL_MINOR_VERSION);
> !     printk("#######################################\n");
> !     printk("#FUSE kernel module is initializing...#\n");
> !     printk("#######################################\n");

Remove

>   	INIT_LIST_HEAD(&fuse_conn_list);
>   	res = fuse_fs_init();
>   	if (res)
> ***************
> *** 1235,1240 ****
> --- 1237,1245 ----
>   
>   static void __exit fuse_exit(void)
>   {
> +     printk("##################################\n");
> +     printk("#FUSE kernel module is exiting...#\n");
> +     printk("##################################\n");

Remove

>   	printk(KERN_DEBUG "fuse exit\n");
>   
>   	fuse_ctl_cleanup();
> diff -crB linux-cr1/fs/fuse/Makefile linux-cr/fs/fuse/Makefile
> *** linux-cr1/fs/fuse/Makefile	2010-09-14 06:59:05.114511787 +0530
> --- linux-cr/fs/fuse/Makefile	2011-03-22 20:23:18.427370000 +0530
> ***************
> *** 5,8 ****
>   obj-$(CONFIG_FUSE_FS) += fuse.o
>   obj-$(CONFIG_CUSE) += cuse.o
>   
> ! fuse-objs := dev.o dir.o file.o inode.o control.o
> --- 5,8 ----
>   obj-$(CONFIG_FUSE_FS) += fuse.o
>   obj-$(CONFIG_CUSE) += cuse.o
>   
> ! fuse-objs := dev.o dir.o file.o inode.o control.o fuse_kcr.o
> Only in linux-cr/include: config
> Only in linux-cr/include: generated
> diff -crB linux-cr1/include/linux/checkpoint_hdr.h linux-cr/include/linux/checkpoint_hdr.h
> *** linux-cr1/include/linux/checkpoint_hdr.h	2010-09-14 06:59:05.515511078 +0530
> --- linux-cr/include/linux/checkpoint_hdr.h	2011-03-28 21:59:53.913441000 +0530
> ***************
> *** 561,567 ****
>   #define CKPT_FILE_EPOLL CKPT_FILE_EPOLL
>   	CKPT_FILE_EVENTFD,
>   #define CKPT_FILE_EVENTFD CKPT_FILE_EVENTFD
> ! 	CKPT_FILE_MAX
>   #define CKPT_FILE_MAX CKPT_FILE_MAX
>   };
>   
> --- 561,569 ----
>   #define CKPT_FILE_EPOLL CKPT_FILE_EPOLL
>   	CKPT_FILE_EVENTFD,
>   #define CKPT_FILE_EVENTFD CKPT_FILE_EVENTFD
> ! 	CKPT_FILE_FUSE,
> ! #define CKPT_FILE_FUSE CKPT_FILE_FUSE
> ! 	CKPT_FILE_MAX,
>   #define CKPT_FILE_MAX CKPT_FILE_MAX
>   };
>   
> diff -crB linux-cr1/include/linux/fuse.h linux-cr/include/linux/fuse.h
> *** linux-cr1/include/linux/fuse.h	2010-09-14 06:59:05.543512193 +0530
> --- linux-cr/include/linux/fuse.h	2011-03-28 21:59:53.846445000 +0530
> ***************
> *** 249,254 ****
> --- 249,258 ----
>   	FUSE_IOCTL         = 39,
>   	FUSE_POLL          = 40,
>   
> + #ifdef CONFIG_CHECKPOINT
> + 	FUSE_CHECKPOINT    = 1024,
> + #endif                                  /*CONFIG_CHECKPOINT*/

This looks like it will be part of an ABI with userspace. That means it
should always be defined/reserved for checkpointing.

> + 
>   	/* CUSE specific operations */
>   	CUSE_INIT          = 4096,
>   };
> ***************
> *** 565,568 ****
> --- 568,583 ----
>   	__u32	padding;
>   };
>   
> + #ifdef CONFIG_CHECKPOINT
> + 	struct fuse_checkpoint_in{
> + 	__u64	fh;
> + 	__u32	flags;
> + 	__u32	padding;
> +         };
> + 
> +         struct fuse_checkpoint_out{
> +         __u32 status;
> +         };
> + #endif                                                  /*CONFIG_CHECKPOINT*/
> + 
>   #endif /* _LINUX_FUSE_H */
> Only in linux-cr/include/linux: version.h
> Only in linux-cr/scripts/basic: docproc
> Only in linux-cr/scripts/basic: fixdep
> Only in linux-cr/scripts/basic: hash
> Only in linux-cr/scripts: conmakehash
> Only in linux-cr/scripts/genksyms: genksyms
> Only in linux-cr/scripts/genksyms: keywords.c
> Only in linux-cr/scripts/genksyms: lex.c
> Only in linux-cr/scripts/genksyms: parse.c
> Only in linux-cr/scripts/genksyms: parse.h
> Only in linux-cr/scripts: kallsyms
> Only in linux-cr/scripts/kconfig: conf
> Only in linux-cr/scripts/kconfig: lex.zconf.c
> Only in linux-cr/scripts/kconfig: mconf
> Only in linux-cr/scripts/kconfig: zconf.hash.c
> Only in linux-cr/scripts/kconfig: zconf.tab.c
> Only in linux-cr/scripts/mod: elfconfig.h
> Only in linux-cr/scripts/mod: mk_elfconfig
> Only in linux-cr/scripts/mod: modpost
> Only in linux-cr/scripts/selinux/genheaders: genheaders
> Only in linux-cr/scripts/selinux/mdp: mdp
> Only in linux-cr/security/selinux: av_permissions.h
> Only in linux-cr: .version

The above also looks irrelevant to the kernel patch.


Is the content below the missing pair of files?

> /*
> fuse_cr: Checkpoint-Restart implementation for FUSE filesystem kernel module.
> 
> Authors: Manoj Kumar and Vishnumurthy Prabhu 
>          NITK Surathkal
> 
> */
> 
> #include "fuse_kcr.h"
> #include <linux/file.h>

swap header inclusion order -- "local" headers and less-generic kernel
headers go after.

> /*
> 	FUSE filesystem .It needs special handling
> 	{
> 		.file_name = "FUSE",
> 		.file_type = CKPT_FILE_FUSE,
> 		.restore = fuse_file_restore,
> 	},	
> */

Huh? What's this comment supposed to tell us?

> 
> struct ckpt_hdr_file_fuse {
> 	struct ckpt_hdr_file common;
> 	
> } __attribute__((aligned(8)));

This should be in include/linux/checkpoint_hdr.h *except* since it
doesn't need anything besides the ckpt_hdr_file I don't see why you
don't just use that struct instead.

> 
> //extern int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
> 
> int fuse_file_ckpt_send(struct file *file)
> {
>     struct inode *inode  = file->f_path.dentry->d_inode;
> 	struct fuse_conn *fc = get_fuse_conn(inode);
> //	struct fuse_file *ff = file->private_data;

Leftover garbage?

> 	struct fuse_req *req;
> 	struct fuse_checkpoint_in inarg;
> 	struct fuse_checkpoint_out outarg;
> 	__u64 nodeid;
> 	int err;
> 	struct fuse_file *ff;
> 
>     ff = file->private_data;
> 	if (is_bad_inode(inode))

CodingStyle whitespace issues. Please try checkpatch.pl

> 		return -EIO;
> 
>     nodeid = get_node_id(inode);
> 	req = fuse_get_req(fc);

I'm not familiar enough with FUSE internals. Shouldn't you check
if req is NULL or an ERR_PTR() before using it below?

> 	memset(&inarg, 0, sizeof(inarg));
> // inargs must be supplied.	
>     inarg.fh = ff->fh;
>     inarg.flags &= ~(0);
> //inargs to be supplied    
>     
>     req->in.h.opcode = FUSE_CHECKPOINT;
> 	req->in.h.nodeid = nodeid;
> 	req->in.numargs = 1;
> 	req->in.args[0].size = sizeof(inarg);
> 	req->in.args[0].value = &inarg;
> 	req->out.numargs = 1;
> 	req->out.args[0].size = sizeof(outarg);
> 	req->out.args[0].value = &outarg;
> 
> //aboue is sample inargs need to be changed...
> 	fuse_request_send(fc, req);
> 	err = req->out.h.error;
> 	fuse_put_request(fc, req);

IMPORTANT:

We need to make sure the task(s) responsible for handling the request in
userspace aren't frozen. As best I can tell that's a very real
possibility.

> 	if (err == -ENOSYS) {
> 		fc->no_flush = 1;
> 		err = 0;
> 	}
> 	return outarg.status;
> }
> 
> int fuse_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
> {
>    int ret;
>    struct ckpt_hdr_file_fuse *h;
>    
> 	if (d_unlinked(file->f_dentry)) {
> 		ckpt_err(ctx, -EBADF, "%(T)%(P)Unlinked files unsupported\n",
> 			 file);
> 		return -EBADF;

Unlinked files are important too. Have you had a chance to review my
recent patches for unlinked files?

> 	}
> 
> 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
> 	if (!h)
> 		return -ENOMEM;
> 
> 	h->common.f_type = CKPT_FILE_FUSE;   
>    
> 	ret = checkpoint_file_common(ctx, file, &h->common);
> 	if (ret < 0)
> 		goto out;
> 	ret = ckpt_write_obj(ctx, &h->common.h);
> 	if (ret < 0)
> 		goto out;
> 	ret = checkpoint_fname(ctx, &file->f_path, &ctx->root_fs_path);
> 	   
> //   ret = fuse_file_ckpt_send(file);

This looks like the only real difference from generic_file_checkpoint() yet
it's commented out. What's going on? Have you compiled this code?
Tested it?

>     out:
> 	  ckpt_hdr_put(ctx, h);
>     printk("**************************fuse_file_checkpoint is working fine\n");

Remove printk

> 	  return ret;	
> 
> }
> EXPORT_SYMBOL(fuse_file_checkpoint);
> 
> /******************************************************************************************************************************************************
> Restart
> */
> 
> struct file *fuse_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
> {
>     struct file *file;
> 	int ret;
> 
> 	if (ptr->h.type != CKPT_HDR_FILE  ||
> 	    ptr->h.len != sizeof(*ptr) || ptr->f_type != CKPT_FILE_FUSE)
> 		return ERR_PTR(-EINVAL);
> 
> 	file = restore_open_fname(ctx, ptr->f_flags);
> 	if (IS_ERR(file))
> 		return file;
> 
> 	ret = restore_file_common(ctx, file, ptr);
> 	if (ret < 0) {
> 		fput(file);
> 		file = ERR_PTR(ret);
> 	}
>     printk("**************************fuse_file_restore is working fine\n");

Remove this printk too. At most you'd want to use ckpt_debug() here and
ckpt_err() above when you encounter errors.

> 	return file;
> }
> 

> #ifdef CONFIG_CHECKPOINT
Is this a separate file from the previous code?

I don't think the #ifdef above should wrap the whole file. Actually,
my guess is these function declarations should go elsewhere within
the existing fuse headers.

> #ifndef _FUSE_KCR_H_
> #define _FUSE_KCR_H_
> 
> #include <linux/fuse.h>
> #include <linux/checkpoint.h>
> #include "fuse_i.h"
> 
> int fuse_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
> struct file *fuse_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr);
> #endif
> #endif

Needs alot more work but it seems like a start. I hope you'll continue
to add to and refine it and repost. Thanks!

Cheers,
	-Matt Helsley
