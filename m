From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] File name length limit off by sizeof(struct ckpt_hdr)
Date: Fri, 23 Oct 2009 20:29:13 -0400
Message-ID: <4AE24A59.8020801@librato.com>
References: <bb799d3c1e3e27d60dac114992c3e310fe14a9e6.1256320668.git.matthltc@us.ibm.com>
	<633d58fa4318bd9ae8d9955cfa70d246184c38a5.1256320668.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <633d58fa4318bd9ae8d9955cfa70d246184c38a5.1256320668.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Matt Helsley wrote:
> Unlike the length passed into ckpt_write_obj_type, the maximum length passed
> to ckpt_read_buf_type must include the length of the struct ckpt_hdr.

IMHO, the right way to fix this is to change ckpt_read_obj_type().

This will preserve symmetry between checkpoint and restart, and also
fix a similar problem in kernel/groups.c (MAX_GROUPINFO_SIZE).

No need to resend - I'll fix already.

Oren.

> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/files.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/checkpoint/files.c b/checkpoint/files.c
> index 0564666..562c338 100644
> --- a/checkpoint/files.c
> +++ b/checkpoint/files.c
> @@ -449,7 +449,7 @@ struct file *restore_open_fname(struct ckpt_ctx *ctx, int flags)
>  	if (flags & (O_CREAT | O_EXCL | O_NOCTTY | O_TRUNC))
>  		return ERR_PTR(-EINVAL);
>  
> -	h = ckpt_read_buf_type(ctx, PATH_MAX, CKPT_HDR_FILE_NAME);
> +	h = ckpt_read_buf_type(ctx, PATH_MAX + sizeof(*h), CKPT_HDR_FILE_NAME);
>  	if (IS_ERR(h))
>  		return (struct file *) h;
>  	len = h->len - sizeof(*h);
