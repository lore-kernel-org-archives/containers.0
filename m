From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v3][PATCH 8/9] File descriprtors (dump)
Date: Thu, 04 Sep 2008 11:41:00 -0700
Message-ID: <1220553660.23386.60.camel@nimitz>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0809040405250.5982@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0809040405250.5982-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2008-09-04 at 04:05 -0400, Oren Laadan wrote:
> +/**
> + * cr_scan_fds - scan file table and construct array of open fds
> + * @files: files_struct pointer
> + * @fdtable: (output) array of open fds
> + * @return: the number of open fds found
> + *
> + * Allocates the file descriptors array (*fdtable), caller should free
> + */
> +int cr_scan_fds(struct files_struct *files, int **fdtable)
> +{
> +	struct fdtable *fdt;
> +	int *fdlist;
> +	int i, n, max;
> +
> +	max = CR_DEFAULT_FDTABLE;
> +
> + repeat:
> +	n = 0;
> +	fdlist = kmalloc(max * sizeof(*fdlist), GFP_KERNEL);
> +	if (!fdlist)
> +		return -ENOMEM;
> +
> +	spin_lock(&files->file_lock);
> +	fdt = files_fdtable(files);
> +	for (i = 0; i < fdt->max_fds; i++) {
> +		if (fcheck_files(files, i)) {
> +			if (n == max) {
> +				spin_unlock(&files->file_lock);
> +				kfree(fdlist);
> +				max *= 2;
> +				if (max < 0) {	/* overflow ? */
> +					n = -EMFILE;
> +					break;
> +				}
> +				goto repeat;
> +			}
> +			fdlist[n++] = i;
> +		}
> +	}
> +	spin_unlock(&files->file_lock);
> +
> +	*fdtable = fdlist;
> +	return n;
> +}

That loop needs some love.  At least save us from one level of
indenting:

> +	for (i = 0; i < fdt->max_fds; i++) {
> +		if (!fcheck_files(files, i)
> 			continue;
> 		if (n == max) {
> +			spin_unlock(&files->file_lock);
> +			kfree(fdlist);
> +			max *= 2;
> +			if (max < 0) {	/* overflow ? */
> +				n = -EMFILE;
> +				break;
> +			}
> +			goto repeat;
> +		}
> +		fdlist[n++] = i;
> +	}

My gut also says that there has to be a better way to find a good size
for fdlist() than growing it this way.  

Why do we even have a fixed size for this?

+#define CR_DEFAULT_FDTABLE  256

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
> +	BUG_ON(!inode);

Why a BUG_ON()?  We'll deref it in just a sec anyway.  We prefer to just
get the NULL dereference rather than an explicit BUG_ON().

> +	hh->f_flags = file->f_flags;
> +	hh->f_mode = file->f_mode;
> +	hh->f_pos = file->f_pos;
> +	hh->f_uid = file->f_uid;
> +	hh->f_gid = file->f_gid;

Is there a plan to save off the 'struct user' here instead?  Nested user
namespaces in one checkpoint image might get confused otherwise.

> +	hh->f_version = file->f_version;
> +	/* FIX: need also file->f_owner */
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

Why don't we just store (and use) (inode->i_mode & S_IFMT) in fd_type
instead of making our own types?

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
> +
> +/**
> + * cr_write_fd_ent - dump the state of a given file descriptor
> + * @ctx: checkpoint context
> + * @files: files_struct pointer
> + * @fd: file descriptor
> + *
> + * Save the state of the file descriptor; look up the actual file pointer
> + * in the hash table, and if found save the matching objref, otherwise call
> + * cr_write_fd_data to dump the file pointer too.
> + */
> +static int
> +cr_write_fd_ent(struct cr_ctx *ctx, struct files_struct *files, int fd)
> +{
> +	struct cr_hdr h;
> +	struct cr_hdr_fd_ent *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	struct file *file = NULL;
> +	struct fdtable *fdt;
> +	int coe, objref, ret;
> +
> +	/* make sure hh->fd (that is of type __u16) doesn't overflow */
> +	if (fd > USHORT_MAX) {
> +		pr_warning("CR: open files table too big (%d)\n", USHORT_MAX);
> +		return -EMFILE;
> +	}

Since the kernel always seems to make fds integers, it would make sense
to me to store them as integers in the checkpoint image.  Why bother to
shrink them down to a 16-bit type?

> +	rcu_read_lock();
> +	fdt = files_fdtable(files);
> +	file = fcheck_files(files, fd);
> +	if (file) {
> +		coe = FD_ISSET(fd, fdt->close_on_exec);
> +		get_file(file);
> +	}
> +	rcu_read_unlock();
> +
> +	/* sanity check (although this shouldn't happen) */
> +	if (!file)
> +		return -EBADF;
> +
> +	ret = cr_obj_add_ptr(ctx, (void *) file, &objref, CR_OBJ_FILE, 0);
> +	cr_debug("fd %d objref %d file %p c-o-e %d)\n", fd, objref, file, coe);
> +
> +	if (ret >= 0) {
> +		int new = ret;
> +
> +		h.type = CR_HDR_FD_ENT;
> +		h.len = sizeof(*hh);
> +		h.parent = 0;
> +
> +		hh->objref = objref;
> +		hh->fd = fd;
> +		hh->close_on_exec = coe;
> +
> +		ret = cr_write_obj(ctx, &h, hh);
> +		cr_hbuf_put(ctx, sizeof(*hh));
> +		if (ret < 0)
> +			return ret;
> +
> +		/* new==1 if-and-only-if file was new and added to hash */
> +		if (new)
> +			ret = cr_write_fd_data(ctx, file, objref);
> +	}

This if() block is in the normal flow path of the function and should go
at the top indentation level.  You can just do this:

	  if (ret < 0)
		goto out;
  	  // if block contents here...

   out:
> +	fput(file);
> +	return ret;
> +}
-- Dave
