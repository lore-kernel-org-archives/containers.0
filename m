From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 10/29] actually use f_op in checkpoint code
Date: Mon, 6 Apr 2009 20:29:12 -0700
Message-ID: <20090407032912.GF12316@us.ibm.com>
References: <1238477349-11029-1-git-send-email-orenl@cs.columbia.edu>
	<1238477349-11029-11-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238477349-11029-11-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

A minor comment and a nit.

Oren Laadan [orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org] wrote:
| From d832bfba9a50789fbfadf8486fbdfbd8b498a9ea Mon Sep 17 00:00:00 2001
| From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| Date: Fri, 27 Mar 2009 12:50:47 -0700
| Subject: [PATCH 10/29] actually use f_op in checkpoint code
| 
| 
| Right now, we assume all normal files and directories
| can be checkpointed.  However, as usual in the VFS, there
| are specialized places that will always need an ability
| to override these defaults.  We could do this completely
| in the checkpoint code, but that would bitrot quickly.
| 
| This adds a new 'file_operations' function for
| checkpointing a file.  I did this under the assumption
| that we should have a dirt-simple way to make something
| (un)checkpointable that fits in with current code.
| 
| As you can see in the ext[234] and /proc patches, all
| that we have to do to make something simple be
| supported is add a single "generic" f_op entry.
| 
| Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| ---
|  checkpoint/ckpt_file.c |   31 +++++++++++++++----------------
|  include/linux/fs.h     |   11 +++++++++++
|  2 files changed, 26 insertions(+), 16 deletions(-)
| 
| diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
| index 9c344c7..0fe68bf 100644
| --- a/checkpoint/ckpt_file.c
| +++ b/checkpoint/ckpt_file.c
| @@ -91,6 +91,11 @@ static int cr_write_file_generic(struct cr_ctx *ctx, struct file *file,
|  
|  	hh->fd_type = CR_FD_GENERIC;
|  
| +	/*
| +	 * FIXME: when we'll add support for unlinked files/dirs, we'll
| +	 * need to distinguish between unlinked filed and unlinked dirs.
| +	 */
| +
|  	ret = cr_write_obj(ctx, &h, hh);
|  	if (ret < 0)
|  		return ret;
| @@ -98,12 +103,16 @@ static int cr_write_file_generic(struct cr_ctx *ctx, struct file *file,
|  	return cr_write_fname(ctx, &file->f_path, &ctx->fs_mnt);
|  }
|  
| +int generic_file_checkpoint(struct cr_ctx *ctx, struct file *file,
| +			    struct cr_hdr_file *hh)
| +{
| +	return cr_write_file_generic(ctx, file, hh);
| +}
| +
|  /* cr_write_file - dump the state of a given file pointer */
|  static int cr_write_file(struct cr_ctx *ctx, struct file *file)
|  {
|  	struct cr_hdr_file *hh;
| -	struct dentry *dent = file->f_dentry;
| -	struct inode *inode = dent->d_inode;
|  	int ret;
|  
|  	hh = cr_hbuf_get(ctx, sizeof(*hh));
| @@ -116,21 +125,11 @@ static int cr_write_file(struct cr_ctx *ctx, struct file *file)
|  	hh->f_version = file->f_version;
|  	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
|  
| -	/*
| -	 * FIXME: when we'll add support for unlinked files/dirs, we'll
| -	 * need to distinguish between unlinked filed and unlinked dirs.
| -	 */
| -	switch (inode->i_mode & S_IFMT) {
| -	case S_IFREG:
| -	case S_IFDIR:
| -		ret = cr_write_file_generic(ctx, file, hh);
| -		break;
| -	default:
| -		ret = -EBADF;
| -		break;
| -	}
| -	cr_hbuf_put(ctx, sizeof(*hh));
| +	ret = -EBADF;
| +	if (file->f_op->checkpoint)
| +		ret = file->f_op->checkpoint(ctx, file, hh);

Minor: not bisect safe for checkpoint - fwiw, with previous patch we could
checkpoint a process with open file, but with this change, we can't ? How
about merge patches 10 and 11 ?

|  
| +	cr_hbuf_put(ctx, sizeof(*hh));
|  	return ret;
|  }
|  
| diff --git a/include/linux/fs.h b/include/linux/fs.h
| index 3bf5057..835ee9e 100644
| --- a/include/linux/fs.h
| +++ b/include/linux/fs.h
| @@ -1296,6 +1296,14 @@ int generic_osync_inode(struct inode *, struct address_space *, int);
|  typedef int (*filldir_t)(void *, const char *, int, loff_t, u64, unsigned);
|  struct block_device_operations;
|  
| +#ifdef CONFIG_CHECKPOINT
| +struct cr_ctx;
| +struct cr_hdr_file;
| +int generic_file_checkpoint(struct cr_ctx *, struct file *, struct cr_hdr_file *);
| +#else
| +#define generic_file_checkpoint NULL
| +#endif
| +
|  /* These macros are for out of kernel modules to test that
|   * the kernel supports the unlocked_ioctl and compat_ioctl
|   * fields in struct file_operations. */
| @@ -1334,6 +1342,9 @@ struct file_operations {
|  	ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
|  	ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
|  	int (*setlease)(struct file *, long, struct file_lock **);
| +#ifdef CONFIG_CHECKPOINT
| +	int (*checkpoint)(struct cr_ctx *, struct file *file, struct cr_hdr_file *);

Nit :-) s/file *file/file */

| +#endif
|  };
|  
|  struct inode_operations {
| -- 
| 1.5.2.5
| 
