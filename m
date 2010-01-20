From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] checkpoint: rename fs_mnt to root_fs_path
Date: Wed, 20 Jan 2010 11:56:01 -0500
Message-ID: <4B5735A1.9030001@cs.columbia.edu>
References: <20091229211509.GA19720@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091229211509.GA19720-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


Added, thanks.

Serge E. Hallyn wrote:
> the fs_mnt is neither an fs nor an mnt, but rather the struct path* root
> of the root task in the checkpointed container.  So call it root_fs_path.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/checkpoint.c          |    4 ++--
>  checkpoint/files.c               |    6 +++---
>  checkpoint/sys.c                 |    2 +-
>  fs/pipe.c                        |    2 +-
>  include/linux/checkpoint_types.h |    2 +-
>  net/unix/checkpoint.c            |    2 +-
>  6 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index c345773..1eda48b 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -572,8 +572,8 @@ static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
>  	task_lock(ctx->root_task);
>  	fs = ctx->root_task->fs;
>  	read_lock(&fs->lock);
> -	ctx->fs_mnt = fs->root;
> -	path_get(&ctx->fs_mnt);
> +	ctx->root_fs_path = fs->root;
> +	path_get(&ctx->root_fs_path);
>  	read_unlock(&fs->lock);
>  	task_unlock(ctx->root_task);
>  
> diff --git a/checkpoint/files.c b/checkpoint/files.c
> index d6cf945..03fcd1d 100644
> --- a/checkpoint/files.c
> +++ b/checkpoint/files.c
> @@ -213,7 +213,7 @@ int generic_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
>  	ret = ckpt_write_obj(ctx, &h->common.h);
>  	if (ret < 0)
>  		goto out;
> -	ret = checkpoint_fname(ctx, &file->f_path, &ctx->fs_mnt);
> +	ret = checkpoint_fname(ctx, &file->f_path, &ctx->root_fs_path);
>   out:
>  	ckpt_hdr_put(ctx, h);
>  	return ret;
> @@ -489,12 +489,12 @@ int checkpoint_obj_task_fs(struct ckpt_ctx *ctx, struct fs_struct *fs)
>  	if (!fs)
>  		return -ENOMEM;
>  
> -	ret = checkpoint_fname(ctx, &fscopy->root, &ctx->fs_mnt);
> +	ret = checkpoint_fname(ctx, &fscopy->root, &ctx->root_fs_path);
>  	if (ret < 0) {
>  		ckpt_err(ctx, ret, "%(T)writing name of fs root");
>  		goto out;
>  	}
> -	ret = checkpoint_fname(ctx, &fscopy->pwd, &ctx->fs_mnt);
> +	ret = checkpoint_fname(ctx, &fscopy->pwd, &ctx->root_fs_path);
>  	if (ret < 0) {
>  		ckpt_err(ctx, ret, "%(T)writing name of pwd");
>  		goto out;
> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index 749e2fd..e332827 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -229,7 +229,7 @@ static void ckpt_ctx_free(struct ckpt_ctx *ctx)
>  		fput(ctx->logfile);
>  
>  	ckpt_obj_hash_free(ctx);
> -	path_put(&ctx->fs_mnt);
> +	path_put(&ctx->root_fs_path);
>  	ckpt_pgarr_free(ctx);
>  
>  	if (ctx->tasks_arr)
> diff --git a/fs/pipe.c b/fs/pipe.c
> index b5d0aea..51eb174 100644
> --- a/fs/pipe.c
> +++ b/fs/pipe.c
> @@ -895,7 +895,7 @@ static int pipe_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
>  
>  	/* FIFO also needs a file name */
>  	if (h->common.f_type == CKPT_FILE_FIFO) {
> -		ret = checkpoint_fname(ctx, &file->f_path, &ctx->fs_mnt);
> +		ret = checkpoint_fname(ctx, &file->f_path, &ctx->root_fs_path);
>  		if (ret < 0)
>  			goto out;
>  	}
> diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
> index f95c3ff..be728be 100644
> --- a/include/linux/checkpoint_types.h
> +++ b/include/linux/checkpoint_types.h
> @@ -59,7 +59,7 @@ struct ckpt_ctx {
>  	struct deferqueue_head *deferqueue;	/* deferred c/r work */
>  	struct deferqueue_head *files_deferq;	/* deferred file-table work */
>  
> -	struct path fs_mnt;     /* container root (FIXME) */
> +	struct path root_fs_path;     /* container root (FIXME) */
>  
>  	struct task_struct *tsk;/* checkpoint: current target task */
>  	char err_string[256];	/* checkpoint: error string */
> diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
> index b6f6af3..90415b0 100644
> --- a/net/unix/checkpoint.c
> +++ b/net/unix/checkpoint.c
> @@ -96,7 +96,7 @@ static int unix_write_cwd(struct ckpt_ctx *ctx,
>  	path.dentry = unix_sk(sk)->dentry;
>  	path.mnt = unix_sk(sk)->mnt;
>  
> -	fqpath = ckpt_fill_fname(&path, &ctx->fs_mnt, buf, &len);
> +	fqpath = ckpt_fill_fname(&path, &ctx->root_fs_path, buf, &len);
>  	if (IS_ERR(fqpath)) {
>  		ret = PTR_ERR(fqpath);
>  		goto out;
