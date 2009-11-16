From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 3/7] process.c: use ckpt_err at restart
Date: Mon, 16 Nov 2009 11:09:14 -0500
Message-ID: <4B01792A.4000508@cs.columbia.edu>
References: <1257465619-1777-1-git-send-email-serue@us.ibm.com>
	<1257465619-1777-4-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257465619-1777-4-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/process.c |   16 ++++++++--------
>  1 files changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/checkpoint/process.c b/checkpoint/process.c
> index 5bc8ccc..9a56f68 100644
> --- a/checkpoint/process.c
> +++ b/checkpoint/process.c
> @@ -581,16 +581,15 @@ static int restore_task_creds(struct ckpt_ctx *ctx)
>  
>  	realcred = ckpt_obj_fetch(ctx, h->cred_ref, CKPT_OBJ_CRED);
>  	if (IS_ERR(realcred)) {
> -		ckpt_debug("Error %ld fetching realcred (ref %d)\n",
> -			PTR_ERR(realcred), h->cred_ref);
>  		ret = PTR_ERR(realcred);
> +		ckpt_err(ctx, ret, "%(O)Error fetching realcred\n",
> +			 h->cred_ref);

Would it make sense to report fetching (and any other object related
generic error) in the original function - in this case ckpt_obj_fetch(),
something like:

	ckpt_err(ctx, ret, "%(O)Error fetching object type %s\n",...)

[...]

Oren.
