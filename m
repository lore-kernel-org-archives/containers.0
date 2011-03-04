From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: Getting started - Error message
Date: Fri, 04 Mar 2011 09:08:57 +0100
Message-ID: <4D709E19.2090704@free.fr>
References: <4D6FE422.1040807@pricom.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D6FE422.1040807-8eKeQ+h1VH4pAS55Wn97og@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: phil-8eKeQ+h1VH4pAS55Wn97og@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 03/03/2011 07:55 PM, Philip Rhoades wrote:
> People,
>
> I used this info to get started on Fedora 14 x86_64:
>
> http://www.techrepublic.com/blog/opensource/introducing-linux-virtual-containers-with-lxc/1289
>
> and everything seems happy when doing the setup stuff but when I try to run:
>
> /usr/bin/lxc-execute -n test -f /etc/lxc/lxc-test.conf /bin/bash
>
> I get:
>
> lxc-execute: network is not created for 'lxc.network.link' = 'br0
> lxc.network.hwaddr = 4a:49:43:49:79:bd' option
>
> lxc-execute: failed to process 'lxc.network.link = br0
> lxc.network.hwaddr = 4a:49:43:49:79:bd
> '
> lxc-execute: failed to read configuration file
>
> but the conf file is readable:
>
> -rw-r--r-- 1 root root 215 Mar  4 05:29 /etc/lxc/lxc-test.conf

The blog shows something like that:

"lxc.utsname = test lxc.network.type = veth lxc.network.flags = up 
lxc.network.link = br0 lxc.network.hwaddr = 4a:49:43:49:79:bd 
lxc.network.ipv4 = 192.168.250.150 lxc.network.ipv6 = 
2003:db8:1:0:214:1234:fe0b:3596"

The configuration file should be in this format:

lxc.utsname = test
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = br0
lxc.network.hwaddr = 4a:49:43:49:79:bd
lxc.network.ipv4 = 192.168.250.150
lxc.network.ipv6 = 2003:db8:1:0:214:1234:fe0b:3596

Thanks
   -- Daniel
