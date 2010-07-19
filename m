From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [Lxc-users] PHYS type lxc not working
Date: Mon, 19 Jul 2010 12:20:56 +0200
Message-ID: <4C442708.8030509__614.524939055805$1279534934$gmane$org@free.fr>
References: <AANLkTino_Vt88QmLt8o4nzLmex2NwBSxkO4bSRBbS-UD@mail.gmail.com>
	<20100707223344.GA3129@count0.beaverton.ibm.com>	<AANLkTinItYFIWCjJ_bbi0ah7dg98E2I8rYd8WOpjI_DK@mail.gmail.com>
	<1278575867.29985.2.camel@foo.co.tradefair>
	<AANLkTimQkO58LbEaEK95XJKA-03o5ZNRBOXZGp28nO49@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTimQkO58LbEaEK95XJKA-03o5ZNRBOXZGp28nO49-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sabdar <sabdar-ETsMpvZGyKJdeDdKuUvyIgC/G2K4zDHf@public.gmane.org>
Cc: atp <Andrew.Phillips-xheW4WVAX9Y@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/19/2010 09:21 AM, Sabdar wrote:
> Hi,
>       i tried the same but by upgrading to the latest ip utility and its
> works fine as you specified.With the old ip utility the "link add" commands
> fails,Thanks for the help.
>
> I tried "PHYS" in the kernel version 2.6.35-rc4 and phys seems to work but
> with a problem ie) the working configuration is as follows,
>
> lxc.utsname = gamma
> lxc.network.type = phys
> lxc.network.flags = up
> *lxc.network.link = eth0*
> *lxc.network.name*<http://lxc.network.name/>* = eth0*
> lxc.network.ipv4 = 192.168.10.1
>
> The same when we change as below  fails to release the host interface after
> lxc is stopped
>
> lxc.utsname = gamma
> lxc.network.type = phys
> lxc.network.flags = up
> *lxc.network.link = eth1*
> *lxc.network.name*<http://lxc.network.name/>* = eth0*
> lxc.network.ipv4 = 192.168.10.1
>
> Instead i see an interface as dev3 in my host after the lxc is stopped.Is it
> necessary that both the network.link and network.name has to be same in the
> case of "PHYS".
>    

When the container exits, the kernel "move" the physical interface from 
the container space to the host space.
But within the container, the physical interface is named "eth0", when 
it goes back to the host, the name is conflicting because the host has 
another interface with the eth0 name. So the kernel creates a new name 
(eg. dev3).

When no name is specified in the configuration file, the default name is 
"eth0", you are probably right that would make sense to keep the 
original name for the physical interface instead of defaulting to "eth0" 
but at the cost of having to modify generic scripts within the container 
to match the physical interface name.

IMHO, the kernel should reassign the previous name when the interface 
goes back to the host namespace, and if it conflicts then create a new 
name like "dev%d".

Thanks
   -- Daniel
