From: Marian Marinov <mm-108MBtLGafw@public.gmane.org>
Subject: Re: [PATCH] IPC initialize shmmax and shmall from the current value
	not the default
Date: Thu, 22 May 2014 16:01:20 +0300
Message-ID: <537DF520.2050904__23870.6818236553$1400763713$gmane$org@1h.com>
References: <5365723D.7030303@1h.com>
	<1399161216.2573.9.camel@buesod1.americas.hpqcorp.net>
	<536621D4.60002@colorfullife.com> <5367EDB6.3010408@1h.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5367EDB6.3010408-108MBtLGafw@public.gmane.org>
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

On 05/05/2014 10:59 PM, Marian Marinov wrote:
> On 05/04/2014 02:17 PM, Manfred Spraul wrote:
>> Hi Marian,
>> 
>> Note: The limits will soon be increased to (nearly) ULONG_MAX. I.e.: If you propose the patch because you are
>> running into issues with a too small SEMMAX after an unshare(CLONE_NEWIPC), then this will be fixed soon.
>> 
>> 
>> On 05/04/2014 01:53 AM, Davidlohr Bueso wrote:
>>> On Sun, 2014-05-04 at 01:48 +0300, Marian Marinov wrote:
>>>> When we are creating new IPC namespace that should be cloned from the current namespace it is a good idea to
>>>> copy the values of the current shmmax and shmall to the new namespace.
>> The idea sounds reasonable: If an admin has reduced the limits, then the reduction should also apply after a
>> unshare(CLONE_NEWIPC).
>> 
>> But: Your patch doesn't use the current shmmax, it uses the shmmax from init_ipc_ns. Would it be possible to use
>> the current values?
> 
> In my tests it worked exactly as expected. Here is an example:
> 
> [root@sp2 ~]# sysctl -a|grep shmmax kernel.shmmax = 68719476736 [root@sp2 ~]# lxc-attach -n cent_plain 
> [root@localhost ~]# sysctl -a|grep shmmax kernel.shmmax = 68719476736 [root@localhost ~]# halt [root@sp2 ~]# sysctl
> -a|grep shmmax kernel.shmmax = 68719476736 [root@sp2 ~]# sysctl kernel.shmmax=34359738368 kernel.shmmax =
> 34359738368 [root@sp2 ~]# lxc-start -n cent_plain -d [root@sp2 ~]# lxc-attach -n cent_plain [root@localhost ~]#
> sysctl -a|grep shmmax kernel.shmmax = 34359738368 [root@localhost ~]#
> 
> So it seams to work as expected :)
> 
> It works because wen you setup a new shmmax limit it is actually the limit in the init_ipc_ns. So when we are
> creating a new ipc_ns its ok to copy the values from init_ipc_ns.
> 
> -Marian
> 

Ping?

So will there be any more comments on that?

Marian

>> 
>>> Why is this a good idea?
>>> 
>>> This would break userspace that relies on the current behavior. Furthermore we've recently changed the default
>>> value of both these limits to be as large as you can get, thus deprecating them. I don't like the idea of this
>>> being replaced by namespaces.
>> Davidlohr: We are not deprecating them, we make the default huge. The limits should stay as usable as they were.
>> 
>> With regards to breaking user space, I must think about it a bit more. Right now, each new namespace starts with
>> SEMMAX=32MB, i.e. an often unusable default.
>> 
>> -- Manfred
>> 
> 
> 


- -- 
Marian Marinov
Founder & CEO of 1H Ltd.
Jabber/GTalk: hackman-/eSpBmjxGS4dnm+yROfE0A@public.gmane.org
ICQ: 7556201
Mobile: +359 886 660 270
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEARECAAYFAlN99SAACgkQ4mt9JeIbjJQHrQCfdexU5xdW4A/pO66SvbcYQVqF
uREAoJ1e6hytp6435YUrpKjEG2qVulI1
=QqGi
-----END PGP SIGNATURE-----
