From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 05/33] netns ct: per-netns expectations
Date: Tue, 9 Sep 2008 11:07:26 +0400
Message-ID: <20080909070726.GD5786__571.639606687491$1220944079$gmane$org@x200.localdomain>
References: <48C01046.2070704@trash.net>
	<1220842990-30500-5-git-send-email-adobriyan@gmail.com>
	<48C60E6E.5080905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48C60E6E.5080905-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
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

On Tue, Sep 09, 2008 at 07:49:34AM +0200, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> Make per-netns a) expectation hash and b) expectations count.
>>
>> Expectations always belongs to netns to which it's master conntrack belong.
>> This is natural and doesn't bloat expectation.
>>
>> Proc files and leaf users are stubbed to init_net, this is temporary.
>
> Looks fine, applied.
>
>> @@ -406,7 +404,7 @@ int nf_ct_expect_related(struct nf_conntrack_expect *expect)
>>  		}
>>  	}
>>  -	if (nf_ct_expect_count >= nf_ct_expect_max) {
>> +	if (net->ct.expect_count >= nf_ct_expect_max) {
>>  		if (net_ratelimit())
>>  			printk(KERN_WARNING
>>  			       "nf_conntrack: expectation table full\n");
>
> I assume these message are globally visible even with namespaces?
> Can we make this (and the corresponding ct hash message) refer to
> the namespace? Otherwise it might be a bit confusing.

This is somewhat peculiar situation.

netns doesn't have unique ID like, say, ifindex.

The only number related to netns is "struct net *". They can be
distinguised by pointer value, but userspace when does clone(CLONE_NEWNET)
do not, obviously, control it and after creation doesn't have a way to find
it out.

And if we print with "%p, net" kernelspace pointer get exposed which is
not nice.
