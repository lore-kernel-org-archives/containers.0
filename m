From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Restore task fs_root and pwd (v2)
Date: Wed, 20 Jan 2010 15:55:21 -0500
Message-ID: <4B576DB9.9000502@cs.columbia.edu>
References: <20091228183948.GA19788@us.ibm.com>	<4B57675D.8080609@cs.columbia.edu>
	<4B576BF3.9030506@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B576BF3.9030506-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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



Oren Laadan wrote:
> 
> Oren Laadan wrote:
>> Very necessary !
>> See comments inline.
>>
>> Serge E. Hallyn wrote:
>>> Checkpoint and restore task->fs.  Tasks sharing task->fs will
>>> share them again after restart.
>>>
>>> Changelog:
>>> 	Dec 28: Addressed comments by Oren (and Dave)
>>> 		1. define and use {get,put}_fs_struct helpers
>>> 		2. fix locking comment
>>> 		3. define ckpt_read_fname() and use in checkpoint/files.c
>>>
>>> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>>> ---
>>>  checkpoint/files.c             |  197 +++++++++++++++++++++++++++++++++++++++-
>>>  checkpoint/objhash.c           |    9 ++
>>>  checkpoint/process.c           |   13 +++
>>>  fs/fs_struct.c                 |   21 ++++
>>>  fs/open.c                      |   53 ++++++-----
>>>  include/linux/checkpoint.h     |   10 ++-
>>>  include/linux/checkpoint_hdr.h |   10 ++
>>>  include/linux/fs.h             |    4 +
>>>  include/linux/fs_struct.h      |    2 +
>>>  9 files changed, 293 insertions(+), 26 deletions(-)
>>>
>>> diff --git a/checkpoint/files.c b/checkpoint/files.c
>>> index b622588..d6cf945 100644
>>> --- a/checkpoint/files.c
>>> +++ b/checkpoint/files.c
>>> @@ -24,6 +24,9 @@
>>>  #include <linux/checkpoint_hdr.h>
>>>  #include <linux/eventpoll.h>
>>>  #include <linux/eventfd.h>
>>> +#include <linux/fs.h>
>>> +#include <linux/fs_struct.h>
>>> +#include <linux/namei.h>
>>>  #include <net/sock.h>
>>>  
>>>  
>>> @@ -449,10 +452,81 @@ int ckpt_collect_file_table(struct ckpt_ctx *ctx, struct task_struct *t)
>>>  	return ret;
>>>  }
>>>  
>>> +int checkpoint_get_task_fs(struct ckpt_ctx *ctx, struct task_struct *t)
>> Renaming these to {checkpoint/restore}_obj_filesystem() will be
>> consistent with existing naming convention there.
>>
>>> +{
>>> +	struct fs_struct *fs;
>>> +	int fs_objref;
>>> +
>>> +	task_lock(current);
>>> +	fs = t->fs;
>>> +	get_fs_struct(fs);
>>> +	task_unlock(current);
>>> +
>>> +	fs_objref = checkpoint_obj(ctx, fs, CKPT_OBJ_TASK_FS);
>>> +	put_fs_struct(fs);
>>> +
>>> +	return fs_objref;
>>> +}
>>> +
>>> +/*
>>> + * called with fs refcount bumped so it won't disappear
>>> + */
>>> +int checkpoint_obj_task_fs(struct ckpt_ctx *ctx, struct fs_struct *fs)
>>> +{
>>> +	struct ckpt_hdr_task_fs *h;
>>> +	int ret;
>>> +	struct fs_struct *fscopy;
>>> +
>>> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_FS);
>>> +	if (!h)
>>> +		return -ENOMEM;
>>> +	ret = ckpt_write_obj(ctx, &h->h);
>>> +	ckpt_hdr_put(ctx, h);
>>> +	if (ret)
>>> +		return ret;
>>> +
>>> +	fscopy = copy_fs_struct(fs);
>>> +	if (!fs)
>>> +		return -ENOMEM;
>>> +
>> Reverse the order below: cwd first then root - this will allow
>> the cwd to be outside of the current chroot, in the case that
>> the task escaped the chroot.
>>
>>> +	ret = checkpoint_fname(ctx, &fscopy->root, &ctx->fs_mnt);
>>> +	if (ret < 0) {
>>> +		ckpt_err(ctx, ret, "%(T)writing name of fs root");
>>> +		goto out;
>>> +	}
>>> +	ret = checkpoint_fname(ctx, &fscopy->pwd, &ctx->fs_mnt);
>>> +	if (ret < 0) {
>>> +		ckpt_err(ctx, ret, "%(T)writing name of pwd");
>>> +		goto out;
>>> +	}
>>> +	ret = 0;
>> [...]
>>
>>> +/* this is the fn called by objhash when it runs into a
>>> + * CKPT_OBJ_TASK_FS entry.  Creates an fs_struct and
>>> + * places it in the hash. */
>>> +static struct fs_struct *restore_obj_task_fs(struct ckpt_ctx *ctx)
>>> +{
>>> +	struct ckpt_hdr_task_fs *h;
>>> +	struct fs_struct *fs;
>>> +	int ret = 0;
>>> +	char *root, *cwd;
>>> +
>>> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_FS);
>>> +	if (IS_ERR(h))
>>> +		return ERR_PTR(PTR_ERR(h));
>>> +	ckpt_hdr_put(ctx, h);
>>> +
>>> +	fs = copy_fs_struct(current->fs);
>>> +	if (!fs)
>>> +		return ERR_PTR(-ENOMEM);
>>> +
>> Please reverse the order below: restore cwd before chroot.
>>
>>> +	ret = ckpt_read_fname(ctx, &root);
>>> +	if (ret < 0)
>>> +		goto out;
>>> +	ret = restore_chroot(ctx, fs, root);
>>> +	kfree(root);
>>> +	if (ret)
>>> +		goto out;
>>> +
>>> +	ret = ckpt_read_fname(ctx, &cwd);
>>> +	if (ret < 0)
>>> +		goto out;
>>> +	ret = restore_cwd(ctx, fs, cwd);
>>> +	kfree(cwd);
>>> +
>>> +out:
>>> +	if (ret) {
>>> +		free_fs_struct(fs);
>>> +		return ERR_PTR(ret);
>>> +	}
>>> +	return fs;
>>> +}
>>> +
>>> +void *restore_task_fs(struct ckpt_ctx *ctx)
>>> +{
>>> +	return (void *) restore_obj_task_fs(ctx);
>>> +}
>>> +
>>> +/*
>>> + * Called by task restore code to set the restarted task's
>>> + * current->fs to an entry on the hash
>>> + */
>>> +int restore_set_task_fs(struct ckpt_ctx *ctx, int fs_objref)
>> (Please rename this one, too)
>>
>>> +{
>>> +	struct fs_struct *newfs, *oldfs;
>>> +
>>> +	newfs = ckpt_obj_fetch(ctx, fs_objref, CKPT_OBJ_TASK_FS);
>>> +	if (IS_ERR(newfs))
>>> +		return PTR_ERR(newfs);
>>> +
>>> +	task_lock(current);
>>> +	get_fs_struct(newfs);
>>> +	oldfs = current->fs;
>>> +	current->fs = newfs;
>>> +	task_unlock(current);
>>> +	put_fs_struct(oldfs);
>>> +
>>> +	return 0;
>>> +}
>>> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
>>> index 782661d..20fd3e9 100644
>>> --- a/checkpoint/objhash.c
>>> +++ b/checkpoint/objhash.c
>>> @@ -417,6 +417,15 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
>>>  		.checkpoint = checkpoint_userns,
>>>  		.restore = restore_userns,
>>>  	},
>>> +	/* struct fs_struct */
>>> +	{
>>> +		.obj_name = "TASK_FS",
>>> +		.obj_type = CKPT_OBJ_TASK_FS,
>>> +		.ref_drop = obj_task_fs_drop,
>>> +		.ref_grab = obj_task_fs_grab,
>>> +		.checkpoint = checkpoint_task_fs,
>>> +		.restore = restore_task_fs,
>> I think we also need a .collect method to prevent leaks ?
> 
> Scratch that.
> 
> I meant to ask if we needed more work on collect because the fs
> itself points to underlying objects (the path).
> 
> But no, because we didn't yet "objectize" the path.
> 
> Oren.

... and also add a call from ckpt_collect_task() to also do the
leak detection with a new checkpoint_collect_fs() function.

Oren.
