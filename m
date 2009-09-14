From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] checkpoint: discard const from struct cred * where
	appropriate
Date: Mon, 14 Sep 2009 11:00:05 -0400
Message-ID: <4AAE5A75.5010307@librato.com>
References: <m3tyzdce33.fsf@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m3tyzdce33.fsf-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



Nathan Lynch wrote:
> Building the checkpoint tree results in enough build noise that
> it's getting easy to miss new warnings added during development:
> 
> kernel/cred.c:737: warning: passing argument 2 of 'checkpoint_capabilities' discards qualifiers from pointer target type
> checkpoint/process.c:146: warning: assignment discards qualifiers from pointer target type
> checkpoint/process.c:147: warning: assignment discards qualifiers from pointer target type
> checkpoint/files.c:154: warning: passing argument 2 of 'checkpoint_obj' discards qualifiers from pointer target type
> 
> The objhash code would require significant modification to properly
> handle const objects, and only struct cred * is causing this kind of
> warning, so just insert casts or drop const where it makes sense.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Thanks, applied.

> ---
>  checkpoint/files.c   |    4 +++-
>  checkpoint/process.c |    4 ++--
>  kernel/cred.c        |    2 +-
>  3 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/checkpoint/files.c b/checkpoint/files.c
> index 204055b..8f90c16 100644
> --- a/checkpoint/files.c
> +++ b/checkpoint/files.c
> @@ -146,12 +146,14 @@ static int scan_fds(struct files_struct *files, int **fdtable)
>  int checkpoint_file_common(struct ckpt_ctx *ctx, struct file *file,
>  			   struct ckpt_hdr_file *h)
>  {
> +	struct cred *f_cred = (struct cred *)file->f_cred;
> +
>  	h->f_flags = file->f_flags;
>  	h->f_mode = file->f_mode;
>  	h->f_pos = file->f_pos;
>  	h->f_version = file->f_version;
>  
> -	h->f_credref = checkpoint_obj(ctx, file->f_cred, CKPT_OBJ_CRED);
> +	h->f_credref = checkpoint_obj(ctx, f_cred, CKPT_OBJ_CRED);
>  	if (h->f_credref < 0)
>  		return h->f_credref;
>  
> diff --git a/checkpoint/process.c b/checkpoint/process.c
> index 40b2580..41566db 100644
> --- a/checkpoint/process.c
> +++ b/checkpoint/process.c
> @@ -143,8 +143,8 @@ static int checkpoint_task_creds(struct ckpt_ctx *ctx, struct task_struct *t)
>  	struct ckpt_hdr_task_creds *h;
>  	int ret;
>  
> -	rcred = get_cred(t->real_cred);
> -	ecred = get_cred(t->cred);
> +	rcred = (struct cred *)get_cred(t->real_cred);
> +	ecred = (struct cred *)get_cred(t->cred);
>  
>  	realcred_ref = checkpoint_obj(ctx, rcred, CKPT_OBJ_CRED);
>  	if (realcred_ref < 0) {
> diff --git a/kernel/cred.c b/kernel/cred.c
> index 27e02ca..9710cae 100644
> --- a/kernel/cred.c
> +++ b/kernel/cred.c
> @@ -706,7 +706,7 @@ int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid)
>  }
>  
>  #ifdef CONFIG_CHECKPOINT
> -static int do_checkpoint_cred(struct ckpt_ctx *ctx, const struct cred *cred)
> +static int do_checkpoint_cred(struct ckpt_ctx *ctx, struct cred *cred)
>  {
>  	int ret;
>  	int groupinfo_ref, user_ref;
