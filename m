From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Fri, 05 Sep 2008 13:54:29 +0200
Message-ID: <48C11DF5.9040207__228.512523654167$1220617677$gmane$org@netfilter.org>
References: <20080821220432.GT31136@x200.localdomain>
	<48C012B8.10606@trash.net> <20080905025838.GA2789@x200.localdomain>
	<48C11918.8020508@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C11918.8020508-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
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
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> On Thu, Sep 04, 2008 at 06:54:16PM +0200, Patrick McHardy wrote:
>>> adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
>>>> Make untracked conntrack per-netns. Compare conntracks with relevant
>>>> untracked one.
>>>>
>>>> The following code you'll start laughing at this code:
>>>>
>>>>     if (ct == ct->ct_net->ct.untracked)
>>>>         ...
>>>>
>>>> let me remind you that ->ct_net is set in only one place, and never
>>>> overwritten later.
>>>>
>>>> All of this requires some surgery with headers, otherwise horrible
>>>> circular
>>>> dependencies. And we lost nf_ct_is_untracked() as function, it
>>>> became macro.
>>> I think you could avoid this mess by using a struct nf_conntrack
>>> for the untracked conntrack instead of struct nf_conn. It shouldn't
>>> make any difference since its ignored anyways.
>>
>> Ewww, can I?
> 
> I hope so :) A different possiblity suggest by Pablo some time ago
> would be to mark untracked packets in skb->nfctinfo and not
> attach a conntrack at all.

Indeed, I remember that :). I left that patch of the table time ago [1].
There's a nf_reset call missing as Patrick said at that time. I can
recover it if you like the idea.

[1]
http://lists.netfilter.org/pipermail/netfilter-devel/2005-June/020171.html

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
