From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 1/2] nfnetlink: add netns support
Date: Wed, 13 Jan 2010 14:02:33 +0100
Message-ID: <4B4DC469.5000408__16453.3893498175$1263387789$gmane$org@trash.net>
References: <20100113122420.GA5790@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100113122420.GA5790@x200>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Alexey Dobriyan wrote:
> Make nfnetlink socket per-netns.
> 
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -81,6 +81,8 @@ struct net {
>  #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
>  	struct netns_ct		ct;
>  #endif
> +	struct sock		*nfnl;
> +	struct sock		*nfnl_stash;

Shouldn't this be contained in an ifdef(CONFIG_NETFILTER_NETLINK)
(_MODULE) ?

>  #endif

> +static void __net_exit nfnetlink_net_exit_batch(struct list_head *net_exit_list)
>  {
> -	printk("Netfilter messages via NETLINK v%s.\n", nfversion);
> +	struct net *net;
>  
> -	nfnl = netlink_kernel_create(&init_net, NETLINK_NETFILTER, NFNLGRP_MAX,
> -				     nfnetlink_rcv, NULL, THIS_MODULE);
> -	if (!nfnl) {
> -		printk(KERN_ERR "cannot initialize nfnetlink!\n");
> -		return -ENOMEM;
> +	list_for_each_entry(net, net_exit_list, exit_list) {
> +		rcu_assign_pointer(net->nfnl, NULL);
> +	}
> +	synchronize_net();
> +	list_for_each_entry(net, net_exit_list, exit_list) {
> +		netlink_kernel_release(net->nfnl_stash);
>  	}

No parenthesis around single statements please.

> --- a/net/netfilter/nfnetlink_log.c
> +++ b/net/netfilter/nfnetlink_log.c
> @@ -323,7 +323,7 @@ __nfulnl_send(struct nfulnl_instance *inst)
>  			  NLMSG_DONE,
>  			  sizeof(struct nfgenmsg));
>  
> -	status = nfnetlink_unicast(inst->skb, inst->peer_pid, MSG_DONTWAIT);
> +	status = nfnetlink_unicast(inst->skb, &init_net, inst->peer_pid, MSG_DONTWAIT);

Overly long line.

The remaining parts look good to me.
