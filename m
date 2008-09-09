From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 16/33] netns ct: per-netns event cache
Date: Tue, 9 Sep 2008 11:07:42 +0400
Message-ID: <20080909070742.GE5786__32233.1206327819$1220944113$gmane$org@x200.localdomain>
References: <48C01046.2070704@trash.net>
	<1220842990-30500-16-git-send-email-adobriyan@gmail.com>
	<48C613CB.5000303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48C613CB.5000303-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
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

On Tue, Sep 09, 2008 at 08:12:27AM +0200, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> Heh, last minute proof-reading of this patch made me think,
>> that this is actually unneeded, simply because "ct" pointers will be
>> different for different conntracks in different netns, just like they
>> are different in one netns.
>>
>> Not so sure anymore.
>
> Its necessary because the cache needs to be flushed on netns exit
> and this is only allowed while its not in use anymore.
>
> I don't see anything in this series actually making sure nothing
> hits the cache on exit though. Am I missing something?

When netns refcount hits zero, netdevices in it will start dropping packets.
And there is synchronize_net() call before cache flush.

I think this is enough.

> Additionally (I might have missed a following patch moving it
> out though) this doesn't belong in the netns exit path:
>
> void nf_conntrack_cleanup(struct net *net)
> {
> 	rcu_assign_pointer(ip_ct_attach, NULL);
> ...
> 	rcu_assign_pointer(nf_ct_destroy, NULL);

This is dealt with in 17/33

Have you got 18/33, archives show it's missing?
