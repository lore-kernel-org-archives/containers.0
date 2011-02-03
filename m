From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Fix restored pipe usage counts
Date: Wed, 2 Feb 2011 19:47:56 -0800
Message-ID: <20110203034756.GR16432@count0.beaverton.ibm.com>
References: <1296586032-5658-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1296586032-5658-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Feb 01, 2011 at 10:47:12AM -0800, Dan Smith wrote:
> Oren's version of my patch leaks pipe objects due to the way the fget() and
> fput() operations are structured.  The intent was to avoid getting and putting
> references more than necessary, but the result was a more confusing (IMHO)
> pattern that resulted in keeping an extra reference in some situations.
> 
> This patch changes the pattern to something more easily understood and
> verified, and also allows several of my tests to pass again, as they did
> before the recent patch.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  fs/pipe.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/pipe.c b/fs/pipe.c
> index 908b8bc..f9ad0f2 100644
> --- a/fs/pipe.c
> +++ b/fs/pipe.c
> @@ -968,6 +968,7 @@ struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
>  		if (!file)	/* this should _never_ happen ! */
>  			return ERR_PTR(-EBADF);
>  		ret = restore_pipe(ctx, file);
> +		fput(file);
>  		if (ret < 0)
>  			goto out;
> 
> @@ -978,13 +979,12 @@ struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
>  		 * other side of the pipe to the hash, to be picked up
>  		 * when that side is restored.
>  		 */
> -		if (which == 1) {	/* the 'other' size */
> -			fput(file);
> -			file = fget(fds[0]);
> -			if (!file)	/* this should _never_ happen ! */
> -				return ERR_PTR(-EBADF);
> -		}

> +		file = fget(fds[1-which]);
> +		if (!file)	/* this should _never_ happen ! */

If it should never happen then this should be:

		BUG_ON(!file);

that way we see the bug as soon as it's detected rather than having to
dig through the stack and 'step' through the code to figure out the
source of EBADF. I noticed Oren applied this patch and the same never
assertion was made in a few other places so I've inlined a patch.

> +			return ERR_PTR(-EBADF);
> +
>  		ret = ckpt_obj_insert(ctx, file, h->pipe_objref, CKPT_OBJ_FILE);
> +		fput(file);
>  		if (ret < 0)
>  			goto out;

pipe c/r: Use BUG_ON() instead of returning

BUG_ON is appropriate for things which should never happen. These
fd lookups should always return non-NULL file pointers because we
just successfully created them and no other control flow path exists
that could modify the file table of a restarting task.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

diff --git a/fs/pipe.c b/fs/pipe.c
index d79ad44..1237f14 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -980,8 +980,7 @@ struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 
 		/* use the "write" side to restore the pipe's contents */
 		file = fget(fds[1]);
-		if (!file)	/* this should _never_ happen ! */
-			return ERR_PTR(-EBADF);
+		BUG_ON(!file);
 		ret = restore_pipe(ctx, file);
 		fput(file);
 		if (ret < 0)
@@ -995,8 +994,7 @@ struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 		 * when that side is restored.
 		 */
 		file = fget(fds[1-which]);
-		if (!file)	/* this should _never_ happen ! */
-			return ERR_PTR(-EBADF);
+		BUG_ON(!file);
 
 		ret = ckpt_obj_insert(ctx, file, h->pipe_objref, CKPT_OBJ_FILE);
 		fput(file);
@@ -1004,8 +1002,7 @@ struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 			goto out;
 
 		file = fget(fds[which]);	/* 'this' side */
-		if (!file)	/* this should _never_ happen ! */
-			return ERR_PTR(-EBADF);
+		BUG_ON(!file);
 
 		/* get rid of the file descriptors (caller sets that) */
 		sys_close(fds[0]);
