From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 03/12] Replace obj_no_grab and obj_no_drop ckpt ops with
	NULL
Date: Fri, 26 Feb 2010 12:48:04 -0600
Message-ID: <1267210084.15300.107.camel@localhost.localdomain>
References: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
	<3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc@us.ibm.com>
	<5d3d0d1f5d294ccd13453a19c15828faa789bb0f.1267173752.git.matthltc@us.ibm.com>
	<06ebd7532cbaeb5d2b13fc7b02db194840098b6d.1267173752.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <06ebd7532cbaeb5d2b13fc7b02db194840098b6d.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 2010-02-26 at 00:45 -0800, Matt Helsley wrote:
> Distributing the ckpt_obj_ops would require sharing these functions when
> we can get by with simple NULL pointers in the grab/drop operations.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/objhash.c |   36 ++++++++++++++++--------------------
>  1 files changed, 16 insertions(+), 20 deletions(-)
> 
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index 832520d..999d731 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -47,16 +47,6 @@ struct ckpt_obj_hash {
>  
>  /* helper grab/drop/users functions */
>  
> -static void obj_no_drop(void *ptr, int lastref)
> -{
> -	return;
> -}
> -
> -static int obj_no_grab(void *ptr)
> -{
> -	return 0;
> -}
> -
>  static int obj_inode_grab(void *ptr)
>  {
>  	return igrab((struct inode *) ptr) ? 0 : -EBADF;
> @@ -346,8 +336,8 @@ static void *restore_lsm_string_wrap(struct ckpt_ctx *ctx)
>  static const struct ckpt_obj_ops ckpt_obj_ignored_ops = {
>  	.obj_name = "IGNORED",
>  	.obj_type = CKPT_OBJ_IGNORE,
> -	.ref_drop = obj_no_drop,
> -	.ref_grab = obj_no_grab,
> +	.ref_drop = NULL,
> +	.ref_grab = NULL,
>  };
>  
>  /* inode object */
> @@ -412,8 +402,8 @@ static const struct ckpt_obj_ops ckpt_obj_sighand_ops = {
>  static const struct ckpt_obj_ops ckpt_obj_signal_ops = {
>  	.obj_name = "SIGNAL",
>  	.obj_type = CKPT_OBJ_SIGNAL,
> -	.ref_drop = obj_no_drop,
> -	.ref_grab = obj_no_grab,
> +	.ref_drop = NULL,
> +	.ref_grab = NULL,
>  };
>  /* ns object */
>  static const struct ckpt_obj_ops ckpt_obj_nsproxy_ops = {
> @@ -519,8 +509,8 @@ static const struct ckpt_obj_ops ckpt_obj_tty_ops = {
>  static const struct ckpt_obj_ops ckpt_obj_security_ptr_ops = {
>  	.obj_name = "SECURITY PTR",
>  	.obj_type = CKPT_OBJ_SECURITY_PTR,
> -	.ref_drop = obj_no_drop,
> -	.ref_grab = obj_no_grab,
> +	.ref_drop = NULL,
> +	.ref_grab = NULL,
>  };

ref_drop/grab will be NULL if you just remove the initializers -- do you
think it is preferable to be explicit?

Regardless, this is looking good to me.
