From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 17/33] netns ct: final init_net tweaks
Date: Tue, 9 Sep 2008 11:32:45 +0400
Message-ID: <20080909073245.GA7307__26796.8990411193$1220945688$gmane$org@x200.localdomain>
References: <48C01046.2070704@trash.net>
	<1220842990-30500-17-git-send-email-adobriyan@gmail.com>
	<48C623CA.9060803@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48C623CA.9060803-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
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

On Tue, Sep 09, 2008 at 09:20:42AM +0200, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> Add checks for init_net to not create kmem caches twice and so on.
>>
>> Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>
>> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
>> index b55944e..52d0663 100644
>> --- a/net/netfilter/nf_conntrack_core.c
>> +++ b/net/netfilter/nf_conntrack_core.c
>> @@ -1016,7 +1016,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_flush);
>>     supposed to kill the mall. */
>>  void nf_conntrack_cleanup(struct net *net)
>>  {
>> -	rcu_assign_pointer(ip_ct_attach, NULL);
>> +	if (net_eq(net, &init_net))
>> +		rcu_assign_pointer(ip_ct_attach, NULL);
>
> Having multiple of these net_eq checks per function (14 total) is
> not a very nice way to do this.

Yep, I was just afraid of some subtle ordering rules and to keep
potential init_net breakage to minimum.

> How about splitting the code into a netns and a global part instead?

Prebably they aren't strict at all.
