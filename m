From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 20/38] netns ct: NOTRACK in netns
Date: Fri, 05 Sep 2008 14:25:10 +0200
Message-ID: <48C12526.90501__15782.4210160927$1220617800$gmane$org@trash.net>
References: <20080821220432.GT31136@x200.localdomain>
	<48C012B8.10606@trash.net> <20080905025838.GA2789@x200.localdomain>
	<48C11918.8020508@trash.net> <48C11DF5.9040207@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C11DF5.9040207-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>>>> I think you could avoid this mess by using a struct nf_conntrack
>>>> for the untracked conntrack instead of struct nf_conn. It shouldn't
>>>> make any difference since its ignored anyways.
>>> Ewww, can I?
>> I hope so :) A different possiblity suggest by Pablo some time ago
>> would be to mark untracked packets in skb->nfctinfo and not
>> attach a conntrack at all.
> 
> Indeed, I remember that :). I left that patch of the table time ago [1].
> There's a nf_reset call missing as Patrick said at that time. I can
> recover it if you like the idea.

I think that would be a good idea.
