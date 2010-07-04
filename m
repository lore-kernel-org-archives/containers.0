From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: How do containers tie to multiple IP's on a NIC?
Date: Sun, 04 Jul 2010 21:49:31 +0200
Message-ID: <4C30E5CB.1080902@free.fr>
References: <20100704034023.GA29753@transpect.com> <4C30BC16.9090802@free.fr>
	<20100704191841.GA31425@transpect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100704191841.GA31425-M6G8SDWvnhfby3iVrkZq2A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Whit Blauvelt <whit-M6G8SDWvnhfby3iVrkZq2A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/04/2010 09:18 PM, Whit Blauvelt wrote:
> On Sun, Jul 04, 2010 at 06:51:34PM +0200, Daniel Lezcano wrote:
>
>    
>> What container userspace command are you using ? libvirt ? liblxc ?
>> unshare --net ?
>>      
> Which one do you recommend, considering what I'm trying to do with multiple
> IPs on a NIC? I haven't committed to one yet. Which utility do you expect
> future development will favor most? I'll be happy to use any tool which gets
> the job done, preferably one that has a future.
>    

Well  ... please don't consider what I will suggest as "preaching for 
its parish" ;)
(not sure it is a correct expression. It is a direct translation from 
French)

I would recommend to use the lxc tools, preferably the 0.7.1 version. 
These tools allow to do what you are expecting that is assign several Ip 
addresses to the same virtual nic.

They are available at:

http://lxc.sourceforge.net/download/lxc/lxc-0.7.1.tar.gz

an older version is certainly available on your distro.

As a quick start:

write a configuration file (eg. lxc.conf)

lxc.network.type=macvlan
lxc.network.link=eth0
lxc.network.flags=up
lxc.network.ipv4=1.2.3.4/24
lxc.network.ipv4=192.168.1.123/24
lxc.network.ipv4=10.0.0.23
lxc.network.ipv4=172.2.1.3

And then lxc-execute -n foo -f lxc.conf /bin/bash

In your shell you should have a new network with one interface and 
several IP addresses.

You can create much more complex configuration but I let you check if 
these tools fit your needs.

Thanks
   -- Daniel
