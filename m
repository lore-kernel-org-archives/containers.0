From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8 net-2.6.26] [NETNS]: Make netns refconting debug
 like a socket one.
Date: Wed, 16 Apr 2008 01:58:29 -0700 (PDT)
Message-ID: <20080416.015829.254939858.davem@davemloft.net>
References: <1208262959.21529.32.camel@iris.sw.ru>
	<1208263075-28016-1-git-send-email-den@openvz.org>
	<4804C1D8.7000803@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4804C1D8.7000803@hp.com>
Sender: netdev-owner@vger.kernel.org
To: brian.haley@hp.com
Cc: den@openvz.org, netdev@vger.kernel.org, containers@lists.osdl.org, dlezcano@fr.ibm.com
List-Id: containers.vger.kernel.org

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 15 Apr 2008 10:55:20 -0400

> Denis V. Lunev wrote:
> > +#ifdef NETNS_REFCNT_DEBUG
> >  static inline struct net *hold_net(struct net *net)
> >  {
> > +	if (net == NULL)
> > +		return NULL;
> > +	atomic_inc(&net->use_count);
> >  	return net;
> >  }
> 
> This could be shrunk to:
 ...
> This one too:

I've checked in Denis's patch with those simplifications added.
Thanks everyone.
