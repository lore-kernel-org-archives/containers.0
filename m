From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v5][PATCH 8/8] Dump open file descriptors
Date: Tue, 16 Sep 2008 09:55:13 -0700
Message-ID: <1221584113.20360.16.camel__34051.9063444392$1221584405$gmane$org@nimitz>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>
	<1221347167-9956-9-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1221347167-9956-9-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, 2008-09-13 at 19:06 -0400, Oren Laadan wrote:
> +/* cr_write_fd_data - dump the state of a given file pointer */
> +static int cr_write_fd_data(struct cr_ctx *ctx, struct file *file, int parent)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_fd_data *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	struct dentry *dent = file->f_dentry;
> +	struct inode *inode = dent->d_inode;
> +	enum fd_type fd_type;
> +	int ret;
> +
> +	h.type = CR_HDR_FD_DATA;
> +	h.len = sizeof(*hh);
> +	h.parent = parent;
> +
> +	hh->f_flags = file->f_flags;
> +	hh->f_mode = file->f_mode;
> +	hh->f_pos = file->f_pos;
> +	hh->f_version = file->f_version;
> +	/* FIX: need also file->uid, file->gid, file->f_owner, etc */
> +
> +	switch (inode->i_mode & S_IFMT) {
> +	case S_IFREG:
> +		fd_type = CR_FD_FILE;
> +		break;
> +	case S_IFDIR:
> +		fd_type = CR_FD_DIR;
> +		break;
> +	case S_IFLNK:
> +		fd_type = CR_FD_LINK;
> +		break;
> +	default:
> +		return -EBADF;
> +	}
> +
> +	/* FIX: check if the file/dir/link is unlinked */
> +	hh->fd_type = fd_type;
> +
> +	ret = cr_write_obj(ctx, &h, hh);
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +	if (ret < 0)
> +		return ret;
> +
> +	return cr_write_fname(ctx, &file->f_path, ctx->vfsroot);
> +}

One of the big things I'm looking for in these file patches is to make
sure that we can expand some day to lots of mounts and lots of
filesystem namespaces.

This tells me that we probably need a per-process vfsroot (which is also
a shared object).  We probably need to make a note in the task structure
as well as here.  

-- Dave
