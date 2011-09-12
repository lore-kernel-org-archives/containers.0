From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] Fix repeatable Oops on container destroy with conntrack
Date: Mon, 12 Sep 2011 20:33:57 +0200
Message-ID: <20110912183357.GC3641@1984>
References: <2184C0CE5A5EDC94CDDA5053@Ximines.local>
 <20110912072524.GA2996@p183.telecom.by>
 <20110912093749.GE2194@1984>
 <E0902A9541FD5D118EA02B31@Ximines.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E0902A9541FD5D118EA02B31@Ximines.local>
Sender: netfilter-owner@vger.kernel.org
To: Alex Bligh <alex@alex.org.uk>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Hi Alex,

On Mon, Sep 12, 2011 at 11:32:18AM +0100, Alex Bligh wrote:
> I /think/ it is the correct fix, in that it certainly fixes the oops,
> and it's relatively low overhead. I ran the torture test for 24 hours
> without a problem.
> 
> My only concern is that eventually my torture test died as the
> machine (512MB VM) had run out of memory - this was after about 30
> hours. Save for having no free memory, the box is happy.
> It looks like there is something (possibly something
> entirely different) leaking memory. It does not appear to be
> conntrack. Whatever, a slow memory leak causing death on a tiny
> VM over 5,000 iterations is better than an oops after 5. Memory
> stats below. I will leave the vm up in case anyone wants other
> stats.

Seems like a different issue.

> On the suggestion to move the check for ->nfnl into
> nfnetlink_has_listeners(), the problem with that is that
> if item->report is non-NULL, nfnetlink_has_listeners()
> will not be called, and the early return will not be made.
> This will merely delay the oops until elsewhere (nfnetlink_send
> for example). The check is currently as follows:
> 
>        if (!item->report && !nfnetlink_has_listeners(net, group))
>                return 0;
> 
> I am a very long way from being a netlink expert, but I am not
> entirely sure what the point of progressing further is if there
> are no listeners if item->report is non-null. Certainly there is
> no point in progressing if net->nfnl NULL (as this will oops
> before item->report is meaningfully used - it's just passed
> as a parametner to nfnetlink_send which will crash). It's
> almost as if that test should be || not &&.
> 
> Perhaps we should check net->nfnl in both places.
> 
> I think there might be similar issues with ctnetlink_expect_event.

Yes, this is what Alexey was pointing out in the previous email and
why he suggested to move it to nfnetlink_has_listeners (to cover the
expectation case).

But you're right, we cannot move it to nfnetlink_has_listeners because
of the item->report case. Please, include the expectation part and
resend the patch.
