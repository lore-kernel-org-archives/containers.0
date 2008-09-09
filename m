From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 16/33] netns ct: per-netns event cache
Date: Tue, 09 Sep 2008 09:07:11 +0200
Message-ID: <48C6209F.6090804__42735.7365414084$1220944154$gmane$org@trash.net>
References: <48C01046.2070704@trash.net>
	<1220842990-30500-16-git-send-email-adobriyan@gmail.com>
	<48C613CB.5000303@trash.net>
	<20080909070742.GE5786@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080909070742.GE5786-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Alexey Dobriyan wrote:
> On Tue, Sep 09, 2008 at 08:12:27AM +0200, Patrick McHardy wrote:
>> Alexey Dobriyan wrote:
>>> Heh, last minute proof-reading of this patch made me think,
>>> that this is actually unneeded, simply because "ct" pointers will be
>>> different for different conntracks in different netns, just like they
>>> are different in one netns.
>>>
>>> Not so sure anymore.
>> Its necessary because the cache needs to be flushed on netns exit
>> and this is only allowed while its not in use anymore.
>>
>> I don't see anything in this series actually making sure nothing
>> hits the cache on exit though. Am I missing something?
> 
> When netns refcount hits zero, netdevices in it will start dropping packets.
> And there is synchronize_net() call before cache flush.
> 
> I think this is enough.

Thanks for the explanation, I have a closer look at this.

>> Additionally (I might have missed a following patch moving it
>> out though) this doesn't belong in the netns exit path:
>>
>> void nf_conntrack_cleanup(struct net *net)
>> {
>> 	rcu_assign_pointer(ip_ct_attach, NULL);
>> ...
>> 	rcu_assign_pointer(nf_ct_destroy, NULL);
> 
> This is dealt with in 17/33
> 
> Have you got 18/33, archives show it's missing?

There are two patches labeled 17/33, I assume the second one is
actually 18/33.
