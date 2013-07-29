From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 9/9] netfilter: use ns_printk in iptable context
Date: Mon, 29 Jul 2013 17:48:56 +0800
Message-ID: <51F63A88.4090405@cn.fujitsu.com>
References: <1375065080-26740-1-git-send-email-rui.xiang@huawei.com>
	<1375065080-26740-10-git-send-email-rui.xiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375065080-26740-10-git-send-email-rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rui Xiang <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, libo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/29/2013 10:31 AM, Rui Xiang wrote:
> To containerise iptables log, use ns_printk
> to report individual logs to container as
> getting syslog_ns from skb->dev->nd_net->user_ns.
> 
> Signed-off-by: Rui Xiang <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>  include/net/netfilter/xt_log.h | 6 +++++-
>  net/netfilter/xt_LOG.c         | 4 ++--
>  2 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/netfilter/xt_log.h b/include/net/netfilter/xt_log.h
> index 9d9756c..5222cba 100644
> --- a/include/net/netfilter/xt_log.h
> +++ b/include/net/netfilter/xt_log.h
> @@ -39,10 +39,14 @@ static struct sbuff *sb_open(void)
>  	return m;
>  }
>  
> -static void sb_close(struct sbuff *m)
> +static void sb_close(struct sbuff *m, struct sk_buff *skb)
>  {
>  	m->buf[m->count] = 0;
> +#ifdef CONFIG_NET_NS
> +	ns_printk(skb->dev->nd_net->user_ns->syslog_ns, "%s\n", m->buf);
> +#else
>  	printk("%s\n", m->buf);
> +#endif
>  
>  	if (likely(m != &emergency))
>  		kfree(m);
> diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
> index 5ab2484..f2cd2fa3 100644
> --- a/net/netfilter/xt_LOG.c
> +++ b/net/netfilter/xt_LOG.c
> @@ -493,7 +493,7 @@ ipt_log_packet(struct net *net,
>  
>  	dump_ipv4_packet(m, loginfo, skb, 0);
>  
> -	sb_close(m);
> +	sb_close(m, skb);


why don't you pass net directly to sb_close here?

un init net namespace will not trigger any system log through ipt_LOG/ip6t_LOG.
You can check the FIXME in ipt_log_packet.

BTW,for this patch,you should cc netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org too.
