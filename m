From: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [patch 1/1][NETNS] fix compilation error
Date: Wed, 14 Nov 2007 14:00:38 +0300
Message-ID: <473AD556.9020601@sw.ru>
References: <20071114104348.624640717@mai.toulouse-stg.fr.ibm.com>
	<20071114104459.680016471@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071114104459.680016471-WECHFHqYCmGD/CxQmPlnQ0FT0OZdM7KVQQ4Iyu8u01E@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

done by the next Eric's patch. Just pushed

Daniel Lezcano wrote:
> fix rtentry_to_fib_config compilation error.
> Replaced the init_net() function call to &init_net.
> 
> Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> ---
>  net/ipv4/fib_frontend.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6-netns/net/ipv4/fib_frontend.c
> ===================================================================
> --- linux-2.6-netns.orig/net/ipv4/fib_frontend.c
> +++ linux-2.6-netns/net/ipv4/fib_frontend.c
> @@ -294,7 +294,7 @@ static int rtentry_to_fib_config(int cmd
>  	memset(cfg, 0, sizeof(*cfg));
>  	cfg->fc_nlinfo.pid = 0;
>  	cfg->fc_nlinfo.nlh = NULL;
> -	cfg->fc_nlinfo.net = init_net();
> +	cfg->fc_nlinfo.net = &init_net;
>  
>  	if (rt->rt_dst.sa_family != AF_INET)
>  		return -EAFNOSUPPORT;
> 
