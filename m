From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH] netns: remove useless synchronize_net()
Date: Tue, 10 Feb 2009 17:40:36 +0100
Message-ID: <4991AE04.7020307@free.fr>
References: <498ABDA2.5040603@dev.6wind.com>	<20090205.234520.149982266.davem@davemloft.net>	<498C403D.9040500@dev.6wind.com> <20090206.141026.85510254.davem@davemloft.net> <49919FD4.3000008@dev.6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <49919FD4.3000008@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Nicolas Dichtel wrote:
> Le 06.02.2009 23:10, David Miller a =E9crit :
>> From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
>> Date: Fri, 06 Feb 2009 14:50:53 +0100
>>
>>> If namespace is destroyed after this function, then cleanup_net()
>>> will ensure that nobody is looking at it
>>
>> Maybe, but you better get some opinions from the people who wrote
>> and maintain the network namespace code before I can consider
>> your change seriously.
>>
>> None of them responded to your patch posting, probably because
>> you failed to CC: any of them.
> Sorry, I forget to cc them, now it's done.
> The thread can be found here:=20
> http://marc.info/?l=3Dlinux-netdev&m=3D123382930115535&w=3D2
>
> So, I'm waiting for maintainers's opinions.
We can move one network device from one namespace to another namespace,=
=20
and that do not necessarily implies the network namespace will die and=20
call cleanup_net.
Without synchronize_net, it would be possible to have netif_receive_skb=
=20
and dev_change_net_namespace to be executed concurrently, no ?
Wouldn't the execution of one of this function be problematic if we are=
=20
in the delivery of a packet to the upper protocol in the big=20
rcu_read_lock section of netif_receive_skb ?

    dev_shutdown(dev);

    /* Notify protocols, that we are about to destroy
       this device. They should clean all the things.
    */
    call_netdevice_notifiers(NETDEV_UNREGISTER, dev);

    /*
     *    Flush the unicast and multicast chains
     */
    dev_addr_discard(dev);

    netdev_unregister_kobject(dev);

    /* Actually switch the network namespace */
    dev_net_set(dev, net);


Thanks
  -- Daniel


