From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [NETNS] Oops in register_pernet_operations() with CONFIG_NET_NS=n
Date: Thu, 25 Oct 2007 09:04:22 -0600
Message-ID: <m17ilb6xs9.fsf@ebiederm.dsl.xmission.com>
References: <47209317.8000802@bull.net> <4720A181.3060003@sw.ru>
	<4720AD20.5030902@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4720AD20.5030902@bull.net> (Benjamin Thery's message of "Thu, 25
	Oct 2007 16:50:08 +0200")
Sender: netdev-owner@vger.kernel.org
To: Benjamin Thery <benjamin.thery@bull.net>
Cc: "Denis V. Lunev" <den@sw.ru>, Pavel Emelianov <xemul@openvz.org>, "Eric W. Biederman" <ebiederm@xmission.com>, David Miller <davem@davemloft.net>, Linux Netdev List <netdev@vger.kernel.org>, Cedric Le Goater <clg@fr.ibm.com>, Linux Containers <containers@lists.osdl.org>, Daniel Lezcano <dlezcano@fr.ibm.com>
List-Id: containers.vger.kernel.org

Benjamin Thery <benjamin.thery@bull.net> writes:

> Denis V. Lunev wrote:
>> The patch attached should help. The idea is simple. The "init" should be
>> called only once without NETNS. Period. No need for any lists.
>
> This is the kind of idea I had but I didn't think it could be 
> that simple. :) 
> Thanks Denis.

It isn't.

>> I'll resend it to Dave after the ACK.
>
> Tested on x86_64 with CONFIG_NET_NS=n and y. 
> It fixes the issue we observed.
>
> Acked-by: Benjamin Thery <benjamin.thery@bull.net>

Try rmmod.

Eric
