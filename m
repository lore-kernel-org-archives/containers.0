From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Relax tcp.window_clamp value in INET restore
Date: Fri, 4 Dec 2009 21:32:45 -0600
Message-ID: <20091205033245.GA3177@us.ibm.com>
References: <1259953399-8530-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1259953399-8530-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> This value can grow higher than 16k, but it clamped at packet receive
> time if over that limit.  Instead of failing here, just clamp to the same
> limit.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org

Tested-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Thanks, Dan.

-serge

> Cc: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
> ---
>  net/ipv4/checkpoint.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv4/checkpoint.c b/net/ipv4/checkpoint.c
> index 788e110..c80324f 100644
> --- a/net/ipv4/checkpoint.c
> +++ b/net/ipv4/checkpoint.c
> @@ -429,10 +429,8 @@ static int inet_precheck(struct socket *sock, struct ckpt_hdr_socket_inet *in)
>  	/* do_tcp_setsockopt() quietly makes this coercion */
>  	if (in->tcp.window_clamp < (SOCK_MIN_RCVBUF / 2))
>  		in->tcp.window_clamp = SOCK_MIN_RCVBUF / 2;
> -	else if (in->tcp.window_clamp > 65535U) {
> -		ckpt_debug("invalid window_clamp value\n");
> -		return -EINVAL;
> -	}
> +	else
> +		in->tcp.window_clamp = min(in->tcp.window_clamp, 65535U);
> 
>  	if (in->tcp.rcv_ssthresh > (4U * in->tcp.advmss))
>  		in->tcp.rcv_ssthresh = 4U * in->tcp.advmss;
> -- 
> 1.6.2.5
