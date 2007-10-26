From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [NETNS] Oops in register_pernet_operations() with CONFIG_NET_NS=n
Date: Fri, 26 Oct 2007 17:40:19 -0600
Message-ID: <m1myu5wil8.fsf@ebiederm.dsl.xmission.com>
References: <m1bqan5cuk.fsf@ebiederm.dsl.xmission.com>
	<20071026.043155.75000997.davem@davemloft.net>
	<4721D283.4050909@bull.net>
	<20071026.045503.62376243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20071026.045503.62376243.davem@davemloft.net> (David Miller's
	message of "Fri, 26 Oct 2007 04:55:03 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: benjamin.thery@bull.net, netdev@vger.kernel.org, dlunev@gmail.com, containers@lists.osdl.org, clg@fr.ibm.com, xemul@openvz.org
List-Id: containers.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> Thanks for doing this.
>
> But this appears to be still discussed, so I'll give
> Denis and others another day to work out the fix they
> want to include.

At this point I think all that really needs to happen is to remove
__net_initdata.  The function attributes seem sane.  Not that
I have any problem with the complete revert either.

I will send a patch to that effect in just a moment.

Eric

