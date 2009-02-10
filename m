From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH] netns: remove useless synchronize_net()
Date: Tue, 10 Feb 2009 18:13:45 +0100
Message-ID: <4991B5C9.9040005@free.fr>
References: <498ABDA2.5040603@dev.6wind.com>	<20090205.234520.149982266.davem@davemloft.net>	<498C403D.9040500@dev.6wind.com> <20090206.141026.85510254.davem@davemloft.net> <49919FD4.3000008@dev.6wind.com> <4991AE04.7020307@free.fr> <4991AFDA.8020704@dev.6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4991AFDA.8020704@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, containers@lists.osdl.org, "Eric W. Biederman" <ebiederm@xmission.com>
List-Id: containers.vger.kernel.org

Nicolas Dichtel wrote:
> Le 10.02.2009 17:40, Daniel Lezcano a =E9crit :
>> Nicolas Dichtel wrote:
>>> Le 06.02.2009 23:10, David Miller a =E9crit :
>>>> From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
>>>> Date: Fri, 06 Feb 2009 14:50:53 +0100
>>>>
>>>>> If namespace is destroyed after this function, then cleanup_net()
>>>>> will ensure that nobody is looking at it
>>>>
>>>> Maybe, but you better get some opinions from the people who wrote
>>>> and maintain the network namespace code before I can consider
>>>> your change seriously.
>>>>
>>>> None of them responded to your patch posting, probably because
>>>> you failed to CC: any of them.
>>> Sorry, I forget to cc them, now it's done.
>>> The thread can be found here:=20
>>> http://marc.info/?l=3Dlinux-netdev&m=3D123382930115535&w=3D2
>>>
>>> So, I'm waiting for maintainers's opinions.
>> We can move one network device from one namespace to another=20
>> namespace, and that do not necessarily implies the network namespace=
=20
>> will die and call cleanup_net.
>> Without synchronize_net, it would be possible to have=20
>> netif_receive_skb and dev_change_net_namespace to be executed=20
>> concurrently, no ?
>> Wouldn't the execution of one of this function be problematic if we=20
>> are in the delivery of a packet to the upper protocol in the big=20
>> rcu_read_lock section of netif_receive_skb ?
> Just to be sure: there is two synchronize_net() in=20
> dev_change_net_namespace(), and I was talking about the second one.=20
> The second one is called just before exiting the function.
>
>
> Regards,
> Nicolas

Ah, ok :)

Hmm, at the first glance I would say it is useless but perhaps there is=
=20
a trick here I do not understand.
Eric, is there any particular reason to call synchronize_net before=20
exiting the dev_change_net_namespace function ?


