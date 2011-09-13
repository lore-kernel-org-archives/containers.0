From: Alex Bligh <alex@alex.org.uk>
Subject: Re: [PATCH] Fix repeatable Oops on container destroy with conntrack
Date: Tue, 13 Sep 2011 21:44:38 +0100
Message-ID: <7631498AC7E7C0EAD641AC7D@nimrod.local>
References: <2184C0CE5A5EDC94CDDA5053@Ximines.local>
 <20110912072524.GA2996@p183.telecom.by> <20110912093749.GE2194@1984>
 <E0902A9541FD5D118EA02B31@Ximines.local> <20110912183357.GC3641@1984>
 <87A32B21CA99D62CE1AB7A4B@Ximines.local>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87A32B21CA99D62CE1AB7A4B@Ximines.local>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org, coreteam@netfilter.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, Linux Containers <containers@lists.osdl.org>, Alex Bligh <alex@alex.org.uk>
List-Id: containers.vger.kernel.org

Alexey / Pablo,

--On 12 September 2011 20:06:25 +0100 Alex Bligh <alex@alex.org.uk> wrote:

> Pablo,
>
> --On 12 September 2011 20:33:57 +0200 Pablo Neira Ayuso
> <pablo@netfilter.org> wrote:
>
>> Yes, this is what Alexey was pointing out in the previous email and
>> why he suggested to move it to nfnetlink_has_listeners (to cover the
>> expectation case).
>>
>> But you're right, we cannot move it to nfnetlink_has_listeners because
>> of the item->report case. Please, include the expectation part and
>> resend the patch.
>
> Thanks - see below

Is this new version OK? I am happy to adjust if not.

I think we ought to get /something/ in, because without anything it's
very simple to cause an oops and a resultant machine hang.

-- 
Alex Bligh

> Signed-off-by: Alex Bligh <alex@alex.org.uk>
> ---
>  net/netfilter/nf_conntrack_netlink.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
>
> diff --git a/net/netfilter/nf_conntrack_netlink.c
> b/net/netfilter/nf_conntrack_netlink.c
> index 482e90c..f44d571 100644
> --- a/net/netfilter/nf_conntrack_netlink.c
> +++ b/net/netfilter/nf_conntrack_netlink.c
> @@ -570,6 +570,11 @@ ctnetlink_conntrack_event(unsigned int events,
> struct nf_ct_event *item)
>                 return 0;
>
>         net = nf_ct_net(ct);
> +
> +       /* container deinit, netlink may have died before
> death_by_timeout */
> +       if (!net->nfnl)
> +               return 0;
> +
>         if (!item->report && !nfnetlink_has_listeners(net, group))
>                 return 0;
>
> @@ -1723,6 +1728,10 @@ ctnetlink_expect_event(unsigned int events, struct
> nf_exp_event *item)
>         } else
>                 return 0;
>
> +       /* container deinit, netlink may have died before
> death_by_timeout */
> +       if (!net->nfnl)
> +               return 0;
> +
>         if (!item->report && !nfnetlink_has_listeners(net, group))
>                 return 0;
>
> --
> 1.7.5.4
>
>



-- 
Alex Bligh
