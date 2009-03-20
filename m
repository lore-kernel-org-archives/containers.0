From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14-rc][PATCH 14/23] A new file type (CR_FD_OBJREF) for a
	file descriptor already setup
Date: Fri, 20 Mar 2009 13:46:06 -0700
Message-ID: <1237581966.8286.272.camel@nimitz>
References: <1237574868-3371-1-git-send-email-orenl@cs.columbia.edu>
	<1237574868-3371-15-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237574868-3371-15-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2009-03-20 at 14:47 -0400, Oren Laadan wrote:
> 
>  /* cr_write_file - dump the state of a given file pointer */
>  static int cr_write_file(struct cr_ctx *ctx, struct file *file)
>  {
>         struct cr_hdr h;
>         struct cr_hdr_file *hh;
> -       struct dentry *dent = file->f_dentry;
> -       struct inode *inode = dent->d_inode;
> +       struct inode *inode = file->f_dentry->d_inode;
>         enum fd_type fd_type;
>         int ret;
> 
> @@ -95,27 +113,35 @@ static int cr_write_file(struct cr_ctx *ctx,
> struct file *file)
>         hh->f_version = file->f_version;
>         /* FIX: need also file->uid, file->gid, file->f_owner, etc */
> 
> -       switch (inode->i_mode & S_IFMT) {
> -       case S_IFREG:
> -               fd_type = CR_FD_FILE;
> -               break;
> -       case S_IFDIR:
> -               fd_type = CR_FD_DIR;
> -               break;
> -       default:
> +       fd_type = cr_inode_to_fdtype(inode);
> +       if (fd_type < 0) {
>                 cr_hbuf_put(ctx, sizeof(*hh));
> -               return -EBADF;
> +               return fd_type;
>         }
> 
> -       /* FIX: check if the file/dir/link is unlinked */
>         hh->fd_type = fd_type;
> +       hh->fd_objref = 0;
> +
> +       /* FIX: check if the inode is unlinked */
> 
>         ret = cr_write_obj(ctx, &h, hh);
>         cr_hbuf_put(ctx, sizeof(*hh));
>         if (ret < 0)
>                 return ret;
> 
> -       return cr_write_fname(ctx, &file->f_path, &ctx->fs_mnt);
> +       switch (fd_type) {
> +       case CR_FD_OBJREF:
> +               /* nothing to do */
> +               break;
> +       case CR_FD_FILE:
> +       case CR_FD_DIR:
> +               ret = cr_write_fd_file(ctx, file);
> +               break;
> +       default:
> +               BUG();
> +       }
> +
> +       return ret;
>  }

This is already a 60-line function handling only two types of fds.
We're going to quite possibly have hundreds of different kinds of file
descriptors and I can't even imagine how that is going to start looking.

This all just looks like it lacks proper abstractions.

        fd_type = cr_inode_to_fdtype(inode);
		calls cr_inode_to_fdtype(inode):
			// detects pipe
        hh->fd_objref = cr_inode_to_objref(ctx, inode, hh->fd_type, &new);
		calls cr_inode_to_objref():
			// check for pipe and do some action
	switch (fd_type) {
	...
        case CR_FD_PIPE:
                ret = cr_write_fd_pipe(ctx, file);
                break;

So, we have 3 different pieces of code in three different places that
all have to be educated about pipes.  It also isn't apparent from their
call sites that each does something special and specific when it sees a
pipe.  This is also as simple as it will ever be.  It won't get any
better than this.

Let's say we have, oh, an f_op function for this.  Or, we just handle
the entire process in cr_write_fd_pipe():

cr_write_fd_pipe(file *file)
{
	int fdref = find_inode_in_hash(file->f_dentry->d_inode);

	if (fdref) {
		// oh, we already wrote this out...
		write_pipe_stub_record(inode, fdref);
		return;
	}

	// write whole pipe record
	hh->fdref = insert_inode_in_hash(file->f_dentry->d_inode);
	...
	write(hh)
}

The fact that a pipe's inodes can be shared can and should be *internal*
to the pipe handling function.  This all makes it incredibly apparent
that pipes have this behavior.  What you have in the patch above is
virtually indecipherable.

To summarize:

1. cr_inode_to_fdtype() shouldn't exist.  It is basically doing an inode
   to function mapping.  That's the job of an i_op.
2. The cr_inode_to_objref() and CR_FD_OBJREF case should not be in
   cr_write_file().  They are private to the pipe implementation.  If
   another user comes along, we can share code between it and pipes, but
   *not* in the main body of cr_write_file().

-- Dave
