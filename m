From: Marian Marinov <mm-108MBtLGafw@public.gmane.org>
Subject: Re: [PATCH] IPC initialize shmmax and shmall from the current value
	not the default
Date: Mon, 26 May 2014 03:07:10 +0300
Message-ID: <538285AE.30102@1h.com>
References: <5365723D.7030303@1h.com>
	<1399161216.2573.9.camel@buesod1.americas.hpqcorp.net>
	<536621D4.60002@colorfullife.com> <5367EDB6.3010408@1h.com>
	<537DF520.2050904@1h.com> <53824C0D.1070204@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <53824C0D.1070204-nhLOkwUX5cPe2c5cEj3t2g@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Manfred Spraul <manfred-nhLOkwUX5cPe2c5cEj3t2g@public.gmane.org>, Davidlohr Bueso <davidlohr-VXdhtT5mjnY@public.gmane.org>
Cc: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, n-horiguchi-PaJj6Psr51x8UrSeD/g0lQ@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi Manfred,

On 05/25/2014 11:01 PM, Manfred Spraul wrote:
> Hi Marian,
> 
> On 05/22/2014 03:01 PM, Marian Marinov wrote:
>> -----BEGIN PGP SIGNED MESSAGE----- Hash: SHA1
>> 
>> On 05/05/2014 10:59 PM, Marian Marinov wrote:
>>> 
>>> In my tests it worked exactly as expected. Here is an example:
>>> 
>>> [root@sp2 ~]# sysctl -a|grep shmmax kernel.shmmax = 68719476736 [root@sp2 ~]# lxc-attach -n cent_plain 
>>> [root@localhost ~]# sysctl -a|grep shmmax kernel.shmmax = 68719476736 [root@localhost ~]# halt [root@sp2 ~]#
>>> sysctl -a|grep shmmax kernel.shmmax = 68719476736 [root@sp2 ~]# sysctl kernel.shmmax=34359738368 kernel.shmmax
>>> = 34359738368 [root@sp2 ~]# lxc-start -n cent_plain -d [root@sp2 ~]# lxc-attach -n cent_plain [root@localhost
>>> ~]# sysctl -a|grep shmmax kernel.shmmax = 34359738368 [root@localhost ~]#
>>> 
>>> So it seams to work as expected :)
>>> 
>>> It works because wen you setup a new shmmax limit it is actually the limit in the init_ipc_ns. So when we are 
>>> creating a new ipc_ns its ok to copy the values from init_ipc_ns.
>>> 
>>> -Marian
>>> 
>> Ping?
>> 
>> So will there be any more comments on that?
>> 
>> 

It seams logical. I like your approach even better.
I'll test it tomorrow to confirm if all of my tests are successful.

Marian

> Attached is an untested idea: - each new namespace copies from it's parent, i.e. nested namespaces should work. -
> msg, sem and shm updated
> 
> -- Manfred


- -- 
Marian Marinov
Founder & CEO of 1H Ltd.
Jabber/GTalk: hackman-/eSpBmjxGS4dnm+yROfE0A@public.gmane.org
ICQ: 7556201
Mobile: +359 886 660 270
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEARECAAYFAlOCha4ACgkQ4mt9JeIbjJTMvwCdGHV2R7Y1H7x14n53Vyihg5AB
2k4Anjp6inQsGjvof2MAx9Sh2/1K3L25
=QTO9
-----END PGP SIGNATURE-----
