From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 21/25] netns ct: per-netns event cache
Date: Fri, 05 Sep 2008 13:34:39 +0200
Message-ID: <48C1194F.7030608__25069.7739924819$1220614833$gmane$org@trash.net>
References: <20080821220445.GU31136@x200.localdomain>
	<48C013BE.3060800@trash.net>
	<20080905034415.GB2789@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080905034415.GB2789-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
> On Thu, Sep 04, 2008 at 06:58:38PM +0200, Patrick McHardy wrote:
>> adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
>>>  static inline void
>>> -nf_conntrack_event_cache(enum ip_conntrack_events event,
>>> +nf_conntrack_event_cache(struct net *net, enum ip_conntrack_events event,
>>>  			 const struct sk_buff *skb)
>>>  {
>> Passing the conntrack instead of the struct net and the skb
>> would probably keep the callers cleaner.
> 
> Dunno, passing netns explicitly like saying conntrack event happened in
> netns A, which is reasonable. OTOH, s/skb/ct/ is indeed nicer.
> 
> I'll change it as you suggest and see what happens.
> 
> BTW, I asked earlier if untracked conntracks are ever supposed to drop into
> event cache. If they're, trimming nf_conntrack_untracked is out of question.

No, they are skipped by the only event handler, ctnetlink.
