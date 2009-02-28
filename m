From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 5/8] add f_op for checkpointability
Date: Fri, 27 Feb 2009 18:51:43 -0800
Message-ID: <1235789503.26788.413.camel__45554.7326164835$1235789634$gmane$org@nimitz>
References: <20090227203425.F3B51176@kernel>
	<20090227203431.D1E697CB@kernel>  <20090228021412.GD19872@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090228021412.GD19872-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2009-02-27 at 18:14 -0800, Sukadev Bhattiprolu wrote:
> | -int cr_file_supported(struct file *file)
> | +typedef int (do_checkpoint_t)(struct file *, struct cr_ctx *,
> | +			      struct cr_hdr_fd *);
> | +
> | +int generic_file_checkpoint(struct file *file, struct cr_ctx *ctx,
> | +			 struct cr_hdr_fd *hh)
> | +{
> | +	/*
> | +	 * A NULL hh means to make a trial run not
> | +	 * actually writing data.  Just determine
> | +	 * if the file is checkpointable.
> | +	 */
> | +	if (!hh)
> | +		return 0;
> | +
> | +	hh->f_flags = file->f_flags;
> | +	hh->f_mode = file->f_mode;
> | +	hh->f_pos = file->f_pos;
> | +	hh->f_version = file->f_version;
> | +	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
> | +
> | +	return 0;
> | +}
> | +
> | +do_checkpoint_t *cr_file_get_func(struct file *file)
> |  {
> 
> Do we really need this helper ? IOW do callers need this function pointer
> itself ? Or can we have a more generic helper that callers can use both
> check if checkpoint is possible (pass NULL in ctx and hh) and to actually
> checkpoint. Something like:

That helper is there because I overload that f_op->checkpoint for both
the "is this file checkpointable" function and the "checkpoint this
file" operation.

> 	int cr_file_checkpoint(file, ctx, hh)
> 	{
> 		int rc = -1;
> 
> 		if (!cr_fs_checkpointable(fstype))
> 			return rc;
> 		
> 		if (!cr_file_checkpointable(file))
> 			return rc;
> 
> 		if (special_file(file))
> 			return rc;
> 
> 		op = file->f_op->checkpoint;
> 		if (!op)
> 			op = generic_file_checkpoint;
> 
> 		return (*op)(file, ctx, hh);
> 	}

First thing you have to be careful about is that the f_op should be able
to override *everything*.  So it has to be first, always.

The other part is that I'd prefer not to call check (a la !
cr_file_checkpointable()) then try to checkpoint a second later, since
we share the implementation between the two here.  

You are probably right that we should probably be able to do this:

int cr_file_checkpointable(file)
{
	return !cr_file_checkpoint(file, NULL, NULL);
}

I'll look into that and see how natural it is to implement.

> |  	struct inode *inode = file->f_dentry->d_inode;
> |  	struct file_system_type *fs_type = inode->i_sb->s_type;
> | 
> | -	if (fs_is_cr_able(fs_type))
> | -		return 0;
> | +	if (file->f_op->checkpoint)
> | +		return file->f_op->checkpoint;
> | +
> | +	if (!fs_is_cr_able(fs_type))
> | +		return NULL;
> | 
> |  	if (special_file(inode->i_mode))
> | -		return 0;
> | +		return NULL;
> | 
> | -	return 1;
> | +	return generic_file_checkpoint;
> | +}
> | +
> | +int cr_file_supported(struct file *file)
> | +{
> | +	do_checkpoint_t *func = cr_file_get_func(file);
> | +
> | +	if (func)
> | +		return !func(file, NULL, NULL);
> | +
> | +	return 0;
> |  }
> | 
> |  /* cr_write_fd_data - dump the state of a given file pointer */
> |  static int cr_write_fd_data(struct cr_ctx *ctx, struct file *file, int parent)
> |  {
> | +	do_checkpoint_t *ckpt_func;
> |  	struct cr_hdr h;
> |  	struct cr_hdr_fd *hh = cr_hbuf_get(ctx, sizeof(*hh));
> | -	struct dentry *dent = file->f_dentry;
> | -	struct inode *inode = dent->d_inode;
> | -	enum fd_type fd_type;
> |  	int ret;
> | 
> |  	h.type = CR_HDR_FD_DATA;
> |  	h.len = sizeof(*hh);
> |  	h.parent = parent;
> | 
> | -	hh->f_flags = file->f_flags;
> | -	hh->f_mode = file->f_mode;
> | -	hh->f_pos = file->f_pos;
> | -	hh->f_version = file->f_version;
> | -	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
> | -
> | -	switch (inode->i_mode & S_IFMT) {
> | -	case S_IFREG:
> | -		fd_type = CR_FD_FILE;
> | -		break;
> | -	case S_IFDIR:
> | -		fd_type = CR_FD_DIR;
> | -		break;
> | -	default:
> | -		cr_hbuf_put(ctx, sizeof(*hh));
> | -		return -EBADF;
> | -	}
> | +	ckpt_func = cr_file_get_func(file);
> | +	ret = -EBADF;
> | +	if (!ckpt_func)
> | +		goto out;
> | 
> | -	/* FIX: check if the file/dir/link is unlinked */
> | -	hh->fd_type = fd_type;
> | +	ret = ckpt_func(file, ctx, hh);
> | +	if (ret)
> | +		goto out;
> 
> So we can combine these two steps into just one ?
> 
> 	ret = -EBADF;
> 	hh->fd_type = fd_type;
> 	if (cr_file_checkpoint(file, ctx, hh))
> 		goto out;

We could but it would be harder to read. :)

I really don't like operational things inside if()s like that.  I think
it kinda hides important code.

Thanks for taking the time to look at this, Suka.

-- Dave
