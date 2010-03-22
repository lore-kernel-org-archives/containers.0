From: Nick Piggin <npiggin-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [C/R v20][PATCH 38/96] c/r: dump open file descriptors
Date: Mon, 22 Mar 2010 21:30:35 +1100
Message-ID: <20100322103035.GF17637@laptop>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
	<1268960401-16680-4-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1268960401-16680-4-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 18, 2010 at 08:59:47PM -0400, Oren Laadan wrote:
> @@ -531,6 +533,15 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
>  		return -EINVAL;  /* cleanup by ckpt_ctx_free() */
>  	}
>  
> +	/* root vfs (FIX: WILL CHANGE with mnt-ns etc */
> +	task_lock(ctx->root_task);
> +	fs = ctx->root_task->fs;
> +	read_lock(&fs->lock);
> +	ctx->root_fs_path = fs->root;
> +	path_get(&ctx->root_fs_path);
> +	read_unlock(&fs->lock);
> +	task_unlock(ctx->root_task);
> +
>  	return 0;
>  }
>  
> diff --git a/checkpoint/files.c b/checkpoint/files.c
> new file mode 100644
> index 0000000..7a57b24
> --- /dev/null
> +++ b/checkpoint/files.c
> +char *ckpt_fill_fname(struct path *path, struct path *root, char *buf, int *len)
> +{
> +	struct path tmp = *root;
> +	char *fname;
> +
> +	BUG_ON(!buf);
> +	spin_lock(&dcache_lock);
> +	fname = __d_path(path, &tmp, buf, *len);
> +	spin_unlock(&dcache_lock);
> +	if (IS_ERR(fname))
> +		return fname;
> +	*len = (buf + (*len) - fname);
> +	/*
> +	 * FIX: if __d_path() changed these, it must have stepped out of
> +	 * init's namespace. Since currently we require a unified namespace
> +	 * within the container: simply fail.
> +	 */
> +	if (tmp.mnt != root->mnt || tmp.dentry != root->dentry)
> +		fname = ERR_PTR(-EBADF);

Maybe something like this is better in fs/?


> +static int scan_fds(struct files_struct *files, int **fdtable)
> +{
> +	struct fdtable *fdt;
> +	int *fds = NULL;
> +	int i = 0, n = 0;
> +	int tot = CKPT_DEFAULT_FDTABLE;
> +
> +	/*
> +	 * We assume that all tasks possibly sharing the file table are
> +	 * frozen (or we are a single process and we checkpoint ourselves).
> +	 * Therefore, we can safely proceed after krealloc() from where we
> +	 * left off. Otherwise the file table may be modified by another
> +	 * task after we scan it. The behavior is this case is undefined,
> +	 * and either checkpoint or restart will likely fail.
> +	 */
> + retry:
> +	fds = krealloc(fds, tot * sizeof(*fds), GFP_KERNEL);
> +	if (!fds)
> +		return -ENOMEM;
> +
> +	rcu_read_lock();
> +	fdt = files_fdtable(files);
> +	for (/**/; i < fdt->max_fds; i++) {
> +		if (!fcheck_files(files, i))
> +			continue;
> +		if (n == tot) {
> +			rcu_read_unlock();
> +			tot *= 2;	/* won't overflow: kmalloc will fail */
> +			goto retry;
> +		}
> +		fds[n++] = i;
> +	}
> +	rcu_read_unlock();

...

> +static int checkpoint_file_desc(struct ckpt_ctx *ctx,
> +				struct files_struct *files, int fd)
> +{
> +	struct ckpt_hdr_file_desc *h;
> +	struct file *file = NULL;
> +	struct fdtable *fdt;
> +	int objref, ret;
> +	int coe = 0;	/* avoid gcc warning */
> +	pid_t pid;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_DESC);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	rcu_read_lock();
> +	fdt = files_fdtable(files);
> +	file = fcheck_files(files, fd);
> +	if (file) {
> +		coe = FD_ISSET(fd, fdt->close_on_exec);
> +		get_file(file);
> +	}
> +	rcu_read_unlock();
> +
> +	ret = find_locks_with_owner(file, files);
> +	/*
> +	 * find_locks_with_owner() returns an error when there
> +	 * are no locks found, so we *want* it to return an error
> +	 * code.  Its success means we have to fail the checkpoint.
> +	 */
> +	if (!ret) {
> +		ret = -EBADF;
> +		ckpt_err(ctx, ret, "%(T)fd %d has file lock or lease\n", fd);
> +		goto out;
> +	}
> +
> +	/* sanity check (although this shouldn't happen) */
> +	ret = -EBADF;
> +	if (!file) {
> +		ckpt_err(ctx, ret, "%(T)fd %d gone?\n", fd);
> +		goto out;
> +	}
> +
> +	/*
> +	 * TODO: Implement c/r of fowner and f_sigio.  Should be
> +	 * trivial, but for now we just refuse its checkpoint
> +	 */
> +	pid = f_getown(file);
> +	if (pid) {
> +		ret = -EBUSY;
> +		ckpt_err(ctx, ret, "%(T)fd %d has an owner (%d)\n", fd);
> +		goto out;
> +	}
> +
> +	/*
> +	 * if seen first time, this will add 'file' to the objhash, keep
> +	 * a reference to it, dump its state while at it.
> +	 */

All these kinds of things (including above hunks) IMO are nasty to put
outside fs/. It would be nice to see higher level functionality
implemented in fs and exported to your checkpoint stuff.

Apparently it's hard because checkpointing is so incestuous with
everything, but that's why it's important to structure the code well.
