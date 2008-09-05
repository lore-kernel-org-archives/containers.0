From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 21/25] netns ct: per-netns event cache
Date: Fri, 5 Sep 2008 07:44:15 +0400
Message-ID: <20080905034415.GB2789__47635.1156984039$1220586287$gmane$org@x200.localdomain>
References: <20080821220445.GU31136@x200.localdomain>
	<48C013BE.3060800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48C013BE.3060800-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Sep 04, 2008 at 06:58:38PM +0200, Patrick McHardy wrote:
> adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
>>  static inline void
>> -nf_conntrack_event_cache(enum ip_conntrack_events event,
>> +nf_conntrack_event_cache(struct net *net, enum ip_conntrack_events event,
>>  			 const struct sk_buff *skb)
>>  {
>
> Passing the conntrack instead of the struct net and the skb
> would probably keep the callers cleaner.

Dunno, passing netns explicitly like saying conntrack event happened in
netns A, which is reasonable. OTOH, s/skb/ct/ is indeed nicer.

I'll change it as you suggest and see what happens.

BTW, I asked earlier if untracked conntracks are ever supposed to drop into
event cache. If they're, trimming nf_conntrack_untracked is out of question.

>>  	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
>>  	struct nf_conntrack_ecache *ecache;
>>   	local_bh_disable();
>> -	ecache = &__get_cpu_var(nf_conntrack_ecache);
>> +	ecache = per_cpu_ptr(net->ct.ecache, raw_smp_processor_id());
>>  	if (ct != ecache->ct)
>>  		__nf_ct_event_cache_init(ct);
>>  	ecache->events |= event;
>> @@ -60,16 +58,29 @@ nf_ct_expect_event(enum ip_conntrack_expect_events event,
>>  	atomic_notifier_call_chain(&nf_ct_expect_chain, event, exp);
>>  }
>>  
