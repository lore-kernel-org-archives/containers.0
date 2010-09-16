From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 03/17][cr][v4]: Checkpoint file-owner information
Date: Thu, 16 Sep 2010 19:34:11 -0400
Message-ID: <4C92A973.9040801@cs.columbia.edu>
References: <1281987801-1293-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1281987801-1293-4-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1281987801-1293-4-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Suka,

I was just about to pull this series, and merge every pair of
checkpoint-restore patches into a single patch. But then I saw
the problem described below, and I expect there will be v5. So
please for v5 and on, merge the checkpoint and restore parts
of a patch - it makes reviewing easier and reduced the number
of individual patches.

On 08/16/2010 03:43 PM, Sukadev Bhattiprolu wrote:
> Checkpoint the file->f_owner information for an open file. This
> information will be used to restore the file-owner information
> when the application is restarted from the checkpoint.
> 
> The file->f_owner information is "private" to each 'struct file' i.e.
> fown_struct is not an external object shared with other file structures.
> So the information can directly be added to the 'ckpt_hdr_file' object.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>  fs/checkpoint.c                |   27 +++++++++++----------------
>  include/linux/checkpoint_hdr.h |    5 +++++
>  2 files changed, 16 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/checkpoint.c b/fs/checkpoint.c
> index 87d7c6e..ce1b4af 100644
> --- a/fs/checkpoint.c
> +++ b/fs/checkpoint.c
> @@ -168,12 +168,19 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
>  			   struct ckpt_hdr_file *h)
>  {
>  	struct cred *f_cred = (struct cred *) file->f_cred;
> +	struct pid *pid = file->f_owner.pid;
>  
>  	h->f_flags = file->f_flags;
>  	h->f_mode = file->f_mode;
>  	h->f_pos = file->f_pos;
>  	h->f_version = file->f_version;
>  
> +	h->f_owner_pid = pid_nr_ns(pid, ns_of_pid(pid));

You take the pid as seen in the namespace in which ths @pid was
allocated (ns_of_pid). I'm not sure this is what we want .. is it ?

I would assume that the way to go is to save the pid as seen from
the _top_ pid-ns of the containers/subtree - so use ctx->root_task's
pid-ns as a reference.

Moreover, when restarting (now fast-forward to next patch where you
do the restore) - the restore occurs in the context of the restarting
task. However, in that context the pid may at all be invalid.

Perhaps the proper way to tackle this is to make 'struct pid *'
citizens of the objhash - that is, treat them as shared objects,
and refer to them through the tag.

Also, the pid may be invalid even if we originally only had one
single pid-ns, in the case that the original task carrying that pid
had already died by the time we checkpoint.

In this case, perhaps we can just ignore that pid (because there
will be no process to receive a signal, anyway). The alternative
is to create dummy 'struct pid *' on restart as necessary.

Once addressed, we will also need some test cases in the suite to
show that it works correctly ...

Thoughts ?

> +	h->f_owner_pid_type = file->f_owner.pid_type;
> +	h->f_owner_uid = file->f_owner.uid;
> +	h->f_owner_euid = file->f_owner.euid;

We will also need something like the above for user-ns, when the
user-ns is eventually conceived - maybe leave a "todo" comment ?

Oren.

> +	h->f_owner_signum = file->f_owner.signum;
> +
>  	h->f_credref = checkpoint_obj(ctx, f_cred, CKPT_OBJ_CRED);
>  	if (h->f_credref < 0)
>  		return h->f_credref;
> @@ -184,10 +191,10 @@ int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
>  		return h->f_secref;
>  	}
>  
> -	ckpt_debug("file %s credref %d secref %d\n",
> -		file->f_dentry->d_name.name, h->f_credref, h->f_secref);
> -
> -	/* FIX: need also file->f_owner, etc */
> +	ckpt_debug("file %s credref %d secref %d, fowner-pid %d, type %d, "
> +			"fowner-signum %d\n", file->f_dentry->d_name.name,
> +			h->f_credref, h->f_secref, h->f_owner_pid,
> +			h->f_owner_pid_type, h->f_owner_signum);
>  
>  	return 0;
>  }
> @@ -267,7 +274,6 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
>  	struct fdtable *fdt;
>  	int objref, ret;
>  	int coe = 0;	/* avoid gcc warning */
> -	pid_t pid;
>  
>  	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_DESC);
>  	if (!h)
> @@ -302,17 +308,6 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
>  	}
>  
>  	/*
> -	 * TODO: Implement c/r of fowner and f_sigio.  Should be
> -	 * trivial, but for now we just refuse its checkpoint
> -	 */
> -	pid = f_getown(file);
> -	if (pid) {
> -		ret = -EBUSY;
> -		ckpt_err(ctx, ret, "%(T)fd %d has an owner (%d)\n", fd);
> -		goto out;
> -	}
> -
> -	/*
>  	 * if seen first time, this will add 'file' to the objhash, keep
>  	 * a reference to it, dump its state while at it.
>  	 */
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 9e8d518..0381019 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -575,6 +575,11 @@ struct ckpt_hdr_file {
>  	__u64 f_pos;
>  	__u64 f_version;
>  	__s32 f_secref;
> +	__s32 f_owner_pid;
> +	__u32 f_owner_pid_type;
> +	__u32 f_owner_uid;
> +	__u32 f_owner_euid;
> +	__s32 f_owner_signum;
>  } __attribute__((aligned(8)));
>  
>  struct ckpt_hdr_file_generic {
