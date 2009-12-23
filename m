From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH RFC] Restore task fs_root and pwd
Date: Tue, 22 Dec 2009 19:46:33 -0500
Message-ID: <4B316869.90306@cs.columbia.edu>
References: <20091210190031.GA19315@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091210190031.GA19315-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Serge E. Hallyn wrote:
> Checkpoint and restore task->fs.  Tasks sharing task->fs will
> share them again after restart.
> 
> The fs/fs_struct.c part should of course be broken out, but
> this does the right thing for me.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Looks good. See a few comments below.

> ---
>  checkpoint/files.c             |  211 ++++++++++++++++++++++++++++++++++++++++
>  checkpoint/objhash.c           |    9 ++
>  checkpoint/process.c           |   13 +++
>  fs/open.c                      |   53 ++++++----
>  include/linux/checkpoint.h     |   10 ++-
>  include/linux/checkpoint_hdr.h |   10 ++
>  include/linux/fs.h             |    4 +
>  7 files changed, 287 insertions(+), 23 deletions(-)
> 
> diff --git a/checkpoint/files.c b/checkpoint/files.c
> index b622588..c8e8d7f 100644
> --- a/checkpoint/files.c
> +++ b/checkpoint/files.c
> @@ -24,6 +24,9 @@
>  #include <linux/checkpoint_hdr.h>
>  #include <linux/eventpoll.h>
>  #include <linux/eventfd.h>
> +#include <linux/fs.h>
> +#include <linux/fs_struct.h>
> +#include <linux/namei.h>
>  #include <net/sock.h>
>  
>  
> @@ -449,6 +452,71 @@ int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
>  	return ret;
>  }
>  
> +int checkpoint_get_task_fs(struct ckpt_ctx *ctx, struct task_struct *t)
> +{
> +	struct fs_struct *fs;
> +	int fs_objref;
> +	int kill;
> +
> +	task_lock(current);
> +	fs = t->fs;
> +	write_lock(&fs->lock);
> +	fs->users++;
> +	write_unlock(&fs->lock);

3 lines above are the same in obj_task_fs_grab()...

> +	task_unlock(current);
> +
> +	fs_objref = checkpoint_obj(ctx, fs, CKPT_OBJ_TASK_FS);
> +	write_lock(&fs->lock);
> +	kill = !--fs->users;
> +	write_unlock(&fs->lock);
> +	if (kill)
> +		free_fs_struct(fs);

And last 5 lines are the same in obj_task_fs_drop().

Perhaps put as helpers in fs_struct.h ?

> +
> +	return fs_objref;
> +}
> +
> +/*
> + * called with fs read_lock()d
> + */

Am I right to guess that this comment is stale ?

> +int checkpoint_obj_task_fs(struct ckpt_ctx *ctx, struct fs_struct *fs)
> +{
> +	struct ckpt_hdr_task_fs *h;
> +	int ret;
> +	struct fs_struct *fscopy;
> +

...

> +/* this is the fn called by objhash when it runs into a
> + * CKPT_OBJ_TASK_FS entry.  Creates an fs_struct and
> + * places it in the hash. */
> +static struct fs_struct *restore_obj_task_fs(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_task_fs *h;
> +	struct fs_struct *fs;
> +	int ret = 0;
> +	char *root, *cwd;
> +	int len;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_FS);
> +	if (IS_ERR(h))
> +		return ERR_PTR(PTR_ERR(h));
> +	ckpt_hdr_put(ctx, h);
> +
> +	fs = copy_fs_struct(current->fs);
> +	if (!fs)
> +		return ERR_PTR(-ENOMEM);
> +
> +	len = ckpt_read_payload(ctx, (void **) &root,
> +				PATH_MAX, CKPT_HDR_FILE_NAME);

Test for len < 0 ... ?

Since this is another place where we read file-name (also in
checkpoint/files.c), perhaps introduce a ckpt_read_fname() ?

> +	ret = restore_chroot(ctx, fs, root);
> +	kfree(root);
> +	if (ret) {
> +		free_fs_struct(fs);
> +		return ERR_PTR(ret);
> +	}
> +
> +	len = ckpt_read_payload(ctx, (void **) &cwd,
> +				PATH_MAX, CKPT_HDR_FILE_NAME);
> +	ret = restore_cwd(ctx, fs, cwd);
> +	kfree(cwd);
> +
> +	if (ret) {
> +		free_fs_struct(fs);
> +		return ERR_PTR(ret);
> +	}
> +	return fs;
> +}

...

Oren.
