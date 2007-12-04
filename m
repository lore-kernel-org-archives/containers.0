From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] netns: Tag the network flow with the network namespace it is in (v2)
Date: Wed, 05 Dec 2007 09:40:33 +1100
Message-ID: <E1IzgRN-0006Hq-00@gondolin.me.apana.org.au>
References: <47559FA9.2080109@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <47559FA9.2080109@sw.ru>
Sender: netdev-owner@vger.kernel.org
To: "Denis V. Lunev" <den@sw.ru>
Cc: shemminger@linux-foundation.org, den@openvz.org, davem@davemloft.net, devel@openvz.org, netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Denis V. Lunev <den@sw.ru> wrote:
>
> could you exactly point me out the flow cache your are talking about.
> Is this dst entry cache or struct flow_cache described in the
> net/core/flow.c

The flow object is embedded in struct rtable so does its size change?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
