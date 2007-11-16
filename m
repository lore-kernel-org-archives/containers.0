From: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [patch 1/1][NETNS] fix fib_frontend compilation error
Date: Fri, 16 Nov 2007 14:33:50 +0300
Message-ID: <473D801E.2030909@sw.ru>
References: <20071114142443.794857293@mai.toulouse-stg.fr.ibm.com>
	<20071114142523.283777897@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071114142523.283777897-WECHFHqYCmGD/CxQmPlnQ0FT0OZdM7KVQQ4Iyu8u01E@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

apparently, the patch is not enough, fib4_rules_init is called from
non-init function. I'll drop this one during port to 2.6.25 tree

dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org wrote:
> Added net namespace parameter to fib4_rules_init when statically
> defined in fib_frontend.c
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
> @@ -59,7 +59,7 @@ struct fib_table *ip_fib_main_table;
>  #define FIB_TABLE_HASHSZ 1
>  static struct hlist_head fib_table_hash[FIB_TABLE_HASHSZ];
>  
> -static void __init fib4_rules_init(void)
> +static void __init fib4_rules_init(struct net *net)
>  {
>  	ip_fib_local_table = fib_hash_init(RT_TABLE_LOCAL);
>  	hlist_add_head_rcu(&ip_fib_local_table->tb_hlist, &fib_table_hash[0]);
> 
