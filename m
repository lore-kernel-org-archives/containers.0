From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Fix kfree() corruption in sock_read_buffer_sendmsg()
Date: Fri, 14 Aug 2009 13:51:45 -0500
Message-ID: <20090814185145.GA5712@us.ibm.com>
References: <1250264153-21697-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1250264153-21697-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> The memcpy_from_iovec() function that the unix sendmsg functions use modifies
> the struct msghdr.  Since the current code uses the msg.iovec_base pointer
> in the msghdr for the kmalloc() and kfree(), we end up freeing the wrong
> pointer.  This patch stores the original address in a separate pointer and
> corrects the kfree() call to use it.
> 
> Cc: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Tested-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  net/unix/checkpoint.c |    8 +++++---
>  1 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
> index 841d25d..65b7025 100644
> --- a/net/unix/checkpoint.c
> +++ b/net/unix/checkpoint.c
> @@ -118,6 +118,7 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sock)
>  {
>  	struct msghdr msg;
>  	struct kvec kvec;
> +	void *buf;
>  	int ret = 0;
>  	int len;
> 
> @@ -134,8 +135,9 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sock)
>  	}
> 
>  	kvec.iov_len = len;
> -	kvec.iov_base = kmalloc(len, GFP_KERNEL);
> -	if (!kvec.iov_base)
> +	buf = kmalloc(len, GFP_KERNEL);
> +	kvec.iov_base = buf;
> +	if (!buf)
>  		return -ENOMEM;
> 
>  	ret = ckpt_kread(ctx, kvec.iov_base, len);
> @@ -147,7 +149,7 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sock)
>  	if ((ret > 0) && (ret != len))
>  		ret = -ENOMEM;
>   out:
> -	kfree(kvec.iov_base);
> +	kfree(buf);
> 
>  	return ret;
>  }
> -- 
> 1.6.2.5
