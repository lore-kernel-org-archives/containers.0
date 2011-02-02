From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Fix restored pipe usage counts
Date: Wed, 02 Feb 2011 09:56:06 -0500
Message-ID: <4D497086.7050405@cs.columbia.edu>
References: <1296586032-5658-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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


Thanks, pushed to v23-rc1.

Oren

On 02/01/2011 01:47 PM, Dan Smith wrote:
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
> +			return ERR_PTR(-EBADF);
> +
>  		ret = ckpt_obj_insert(ctx, file, h->pipe_objref, CKPT_OBJ_FILE);
> +		fput(file);
>  		if (ret < 0)
>  			goto out;
>  
