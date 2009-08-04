From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/5] Export fill_fname() as ckpt_fill_fname()
Date: Tue, 4 Aug 2009 14:24:42 -0500
Message-ID: <20090804192442.GD10275@us.ibm.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com>
	<1249331463-11887-5-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1249331463-11887-5-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  checkpoint/files.c         |    8 ++++----
>  include/linux/checkpoint.h |    2 ++
>  2 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/checkpoint/files.c b/checkpoint/files.c
> index bcdc774..555bc54 100644
> --- a/checkpoint/files.c
> +++ b/checkpoint/files.c
> @@ -28,14 +28,14 @@
>   */
> 
>  /**
> - * fill_fname - return pathname of a given file
> + * ckpt_fill_fname - return pathname of a given file
>   * @path: path name
>   * @root: relative root
>   * @buf: buffer for pathname
>   * @len: buffer length (in) and pathname length (out)
>   */
> -static char *fill_fname(struct path *path, struct path *root,
> -			char *buf, int *len)
> +char *ckpt_fill_fname(struct path *path, struct path *root,
> +		      char *buf, int *len)
>  {
>  	struct path tmp = *root;
>  	char *fname;
> @@ -79,7 +79,7 @@ int checkpoint_fname(struct ckpt_ctx *ctx, struct path *path, struct path *root)
>  	if (!buf)
>  		return -ENOMEM;
> 
> -	fname = fill_fname(path, root, buf, &flen);
> +	fname = ckpt_fill_fname(path, root, buf, &flen);
>  	if (!IS_ERR(fname))
>  		ret = ckpt_write_obj_type(ctx, fname, flen,
>  					  CKPT_HDR_FILE_NAME);
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 3536633..cab31d1 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -72,6 +72,8 @@ extern int ckpt_read_string(struct ckpt_ctx *ctx, char **str, int max);
>  extern void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type);
>  extern void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type);
>  extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
> +extern char *ckpt_fill_fname(struct path *path, struct path *root,
> +			     char *buf, int *len);
> 
>  /* ckpt kflags */
>  #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
> -- 
> 1.6.2.5
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
