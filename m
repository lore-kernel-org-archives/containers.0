From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] Remove struct timeval from socket header
Date: Tue, 25 Aug 2009 01:54:32 -0400
Message-ID: <4A937C98.2030202@librato.com>
References: <1251137994-17972-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1251137994-17972-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Added, thanks.

Dan Smith wrote:
> This patch removes the 'struct timeval' from the socket header and replaces
> it with a fixed-size type as suggested by Oren.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/checkpoint_hdr.h |    5 +++--
>  net/checkpoint.c               |   22 ++++++++++++++++++++--
>  2 files changed, 23 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 5473a4f..01be039 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -385,6 +385,9 @@ struct ckpt_hdr_socket {
>  		__s64 rcvlowat;
>  		__u64 flags;
>  
> +		__s64 rcvtimeo;
> +		__s64 sndtimeo;
> +
>  		__u32 err;
>  		__u32 err_soft;
>  		__u32 priority;
> @@ -400,8 +403,6 @@ struct ckpt_hdr_socket {
>  		__u8 no_check;
>  
>  		struct linger linger;
> -		struct timeval rcvtimeo;
> -		struct timeval sndtimeo;
>  	} sock __attribute__ ((aligned(8)));
>  } __attribute__ ((aligned(8)));
>  
> diff --git a/net/checkpoint.c b/net/checkpoint.c
> index a7e7db0..2c62d54 100644
> --- a/net/checkpoint.c
> +++ b/net/checkpoint.c
> @@ -349,6 +349,24 @@ static int sock_restore_flags(struct socket *sock,
>         return 0;
>  }
>  
> +static int sock_copy_timeval(int op, struct sock *sk,
> +			     int sockopt, __s64 *saved)
> +{
> +	struct timeval tv;
> +
> +	if (op == CKPT_CPT) {
> +		if (CKPT_COPY_SOPT(op, sk, sockopt, &tv))
> +			return -EINVAL;
> +		*saved = timeval_to_ns(&tv);
> +	} else {
> +		tv = ns_to_timeval(*saved);
> +		if (CKPT_COPY_SOPT(op, sk, sockopt, &tv))
> +			return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
>  static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
>  		       struct ckpt_hdr_socket *h, int op)
>  {
> @@ -392,12 +410,12 @@ static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
>  		return -EINVAL;
>  	}
>  
> -	if (CKPT_COPY_SOPT(op, sk, SO_SNDTIMEO, &h->sock.sndtimeo)) {
> +	if (sock_copy_timeval(op, sk, SO_SNDTIMEO, &h->sock.sndtimeo)) {
>  		ckpt_debug("Failed to set SO_SNDTIMEO");
>  		return -EINVAL;
>  	}
>  
> -	if (CKPT_COPY_SOPT(op, sk, SO_RCVTIMEO, &h->sock.rcvtimeo)) {
> +	if (sock_copy_timeval(op, sk, SO_RCVTIMEO, &h->sock.rcvtimeo)) {
>  		ckpt_debug("Failed to set SO_RCVTIMEO");
>  		return -EINVAL;
>  	}
