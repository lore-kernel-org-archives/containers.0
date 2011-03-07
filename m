From: Philip Rhoades <phil-8eKeQ+h1VH4pAS55Wn97og@public.gmane.org>
Subject: Re: Getting started - Error message
Date: Mon, 07 Mar 2011 20:23:50 +1100
Message-ID: <4D74A426.6090700@pricom.com.au>
References: <4D6FE422.1040807@pricom.com.au> <4D709E19.2090704@free.fr>
Reply-To: phil-8eKeQ+h1VH4pAS55Wn97og@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D709E19.2090704-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel,


On 2011-03-04 19:08, Daniel Lezcano wrote:
> On 03/03/2011 07:55 PM, Philip Rhoades wrote:
>> People,
>>
>> I used this info to get started on Fedora 14 x86_64:
>>
>> http://www.techrepublic.com/blog/opensource/introducing-linux-virtual-containers-with-lxc/1289
>>
>>
>> and everything seems happy when doing the setup stuff but when I try
>> to run:
>>
>> /usr/bin/lxc-execute -n test -f /etc/lxc/lxc-test.conf /bin/bash
>>
>> I get:
>>
>> lxc-execute: network is not created for 'lxc.network.link' = 'br0
>> lxc.network.hwaddr = 4a:49:43:49:79:bd' option
>>
>> lxc-execute: failed to process 'lxc.network.link = br0
>> lxc.network.hwaddr = 4a:49:43:49:79:bd
>> '
>> lxc-execute: failed to read configuration file
>>
>> but the conf file is readable:
>>
>> -rw-r--r-- 1 root root 215 Mar 4 05:29 /etc/lxc/lxc-test.conf
>
> The blog shows something like that:
>
> "lxc.utsname = test lxc.network.type = veth lxc.network.flags = up
> lxc.network.link = br0 lxc.network.hwaddr = 4a:49:43:49:79:bd
> lxc.network.ipv4 = 192.168.250.150 lxc.network.ipv6 =
> 2003:db8:1:0:214:1234:fe0b:3596"
>
> The configuration file should be in this format:
>
> lxc.utsname = test
> lxc.network.type = veth
> lxc.network.flags = up
> lxc.network.link = br0
> lxc.network.hwaddr = 4a:49:43:49:79:bd
> lxc.network.ipv4 = 192.168.250.150
> lxc.network.ipv6 = 2003:db8:1:0:214:1234:fe0b:3596


I should have seen that! (I did notice the same problem in one of the 
commands.  I changed the IP addresses appropriately for my setup but the 
comment:  "The next commands then reset the IP address of eth0 to 
0.0.0.0, but since it is bound to the bridge interface, it will respond 
to the previous IP address anyways." does not seem to be true for me and 
my normal networking was messed up.  Anyway, is it possible to set up 
the container without messing with the existing eth0 setup?

Thanks,

Phil.
-- 
Philip Rhoades

GPO Box 3411
Sydney NSW	2001
Australia
E-mail:  phil-8eKeQ+h1VH4pAS55Wn97og@public.gmane.org
