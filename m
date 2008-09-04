From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 21/25] netns ct: per-netns event cache
Date: Thu, 04 Sep 2008 18:58:38 +0200
Message-ID: <48C013BE.3060800__30503.7272898064$1220548003$gmane$org@trash.net>
References: <20080821220445.GU31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080821220445.GU31136-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
>  static inline void
> -nf_conntrack_event_cache(enum ip_conntrack_events event,
> +nf_conntrack_event_cache(struct net *net, enum ip_conntrack_events event,
>  			 const struct sk_buff *skb)
>  {

Passing the conntrack instead of the struct net and the skb
would probably keep the callers cleaner.

>  	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
>  	struct nf_conntrack_ecache *ecache;
>  
>  	local_bh_disable();
> -	ecache = &__get_cpu_var(nf_conntrack_ecache);
> +	ecache = per_cpu_ptr(net->ct.ecache, raw_smp_processor_id());
>  	if (ct != ecache->ct)
>  		__nf_ct_event_cache_init(ct);
>  	ecache->events |= event;
> @@ -60,16 +58,29 @@ nf_ct_expect_event(enum ip_conntrack_expect_events event,
>  	atomic_notifier_call_chain(&nf_ct_expect_chain, event, exp);
>  }
>  
