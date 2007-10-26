From: David Miller <davem@davemloft.net>
Subject: Re: [NETNS] Oops in register_pernet_operations() with
 CONFIG_NET_NS=n
Date: Fri, 26 Oct 2007 04:31:55 -0700 (PDT)
Message-ID: <20071026.043155.75000997.davem@davemloft.net>
References: <m1y7dr5esy.fsf@ebiederm.dsl.xmission.com>
	<4720C9B9.80706@gmail.com>
	<m1bqan5cuk.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1bqan5cuk.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
To: ebiederm@xmission.com
Cc: dlunev@gmail.com, benjamin.thery@bull.net, xemul@openvz.org, netdev@vger.kernel.org, clg@fr.ibm.com, containers@lists.osdl.org, dlezcano@fr.ibm.com
List-Id: containers.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 25 Oct 2007 11:21:55 -0600

> > By the way, I think that we can in the case of undefined CONFIG_NET_NS
> > reduce register to calling ->init method and unregister to calling
> > ->exit method.
> >
> > This is a correct thing at least for now and will be welcomed by the all
> > embedded/etc people.
> 
> I'm not fundamentally opposed.  Earlier versions of my patchset
> did that and more.   However I think the pain is greater then the
> gain right now.  Especially since this concept seem to require
> having quality inspected into it.

I think the correct thing to do for now is to simply remove these
__net_* markers and their definitions.  There are so many tricky cases
that it is easier to just get rid of them.

Could someone send me a patch which does that?
