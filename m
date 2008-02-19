From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 6/17 net-2.6.26] [NETNS]: Default arp parameters lookup.
Date: Tue, 19 Feb 2008 10:14:51 +0100
Message-ID: <47BA9E0B.6080209@fr.ibm.com>
References: <1203406116.27296.1.camel@iris.sw.ru> <1203406297-32725-6-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1203406297-32725-6-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org
List-Id: containers.vger.kernel.org

Denis V. Lunev wrote:
> Default ARP parameters should be findable regardless of the context.
> Required to make inetdev_event working.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> ---
>  net/core/neighbour.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index c895ad4..45ed620 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -1275,9 +1275,7 @@ static inline struct neigh_parms *lookup_neigh_params(struct neigh_table *tbl,
>  	struct neigh_parms *p;
> 
>  	for (p = &tbl->parms; p; p = p->next) {
> -		if (p->net != net)
> -			continue;
> -		if ((p->dev && p->dev->ifindex == ifindex) ||
> +		if ((p->dev && p->dev->ifindex == ifindex && p->net == net) ||
>  		    (!p->dev && !ifindex))
>  			return p;
>  	}

If the values are:
	p->dev == NULL
	ifindex == 0
	p->net != net

The parms should not be taken into account and the looping must 
continue. But with this modification it is not the case, if we specify 
parms ifindex == 0, the first parms with the dev field set to NULL will 
be taken belonging or not to the right net.

IMO the right test is:

if (p->net == net && ((p->dev && p->dev->ifindex == ifindex) || !p->dev 
&& !ifindex)))

I definitively prefer the first notation :)

 > -		if (p->net != net)
 > -			continue;

