From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] Remove an unnecessary check on socket restart
Date: Thu, 01 Oct 2009 19:07:29 -0400
Message-ID: <4AC53631.6020505@librato.com>
References: <1254434651-6540-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1254434651-6540-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


To appear in ckpt-v18-dev, thanks.

Dan Smith wrote:
> This check is removed because it cannot be true because of the
> unsigned nature of the value being examined.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
> Cc: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
> ---
>  net/checkpoint.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/net/checkpoint.c b/net/checkpoint.c
> index a11ec7a..0087a8a 100644
> --- a/net/checkpoint.c
> +++ b/net/checkpoint.c
> @@ -484,8 +484,7 @@ static int sock_cptrst(struct ckpt_ctx *ctx, struct sock *sk,
>  		   (h->sock.state >= TCP_MAX_STATES)) {
>  		ckpt_debug("sock in invalid state: %i", h->sock.state);
>  		return -EINVAL;
> -	} else if ((h->socket.state < SS_FREE) ||
> -		   (h->socket.state > SS_DISCONNECTING)) {
> +	} else if (h->socket.state > SS_DISCONNECTING) {
>  		ckpt_debug("socket in invalid state: %i",
>  			   h->socket.state);
>  		return -EINVAL;
