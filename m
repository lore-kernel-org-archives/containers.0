From: Jun OKAJIMA <okajima-og82NyAXoxRpnGNL948N7c8NsWr+9BEh@public.gmane.org>
Subject: Re: Container for Amazon EC2?
Date: Thu, 18 Feb 2010 00:23:29 +0900
Message-ID: <2c2629fa1002170723o43aed18as7745b2ce4217474b@mail.gmail.com>
References: <2c2629fa1002150243n4c91d93ctee4509912228f3ea@mail.gmail.com>
	<20100215143905.GD28038@us.ibm.com> <20100217151943.GA9159@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100217151943.GA9159-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This is my result.
I dont know very well about lxc,
but this is usable?

       --- Okajima, Jun. Tokyo, Japan.


ubuntu@domU-12-31-39-06-28-B2:~$ lxc-checkconfig
Kernel config /proc/config.gz not found, looking in other places...
Found kernel config file /boot/config-2.6.31-302-ec2
--- Namespaces ---
Namespaces: enabled
Utsname namespace: enabled
Ipc namespace: enabled
Pid namespace: disabled
User namespace: disabled
Network namespace: disabled
Multiple /dev/pts instances: disabled

--- Control groups ---
Cgroup: enabled
Cgroup namespace: enabled
Cgroup device: disabled
Cgroup sched: enabled
Cgroup cpu account: enabled
Cgroup memory controller: enabled
Cgroup cpuset: enabled



--- Misc ---
Veth pair device: enabled
Macvlan: enabled
File capabilities: enabled
ubuntu@domU-12-31-39-06-28-B2:~$ uname -a
Linux domU-12-31-39-06-28-B2 2.6.31-302-ec2 #7-Ubuntu SMP Tue Oct 13
19:55:22 UTC 2009 x86_64 GNU/Linux
ubuntu@domU-12-31-39-06-28-B2:~$

2010/2/18 Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>:
> So I tried running one of the public ubuntu karmic images in
> ec2 (ami-bb709dd2). =A0I could sudo apt-get install lxc. =A0The
> default kernel (aki-5f15f636) didn't support namespaces. =A0Now
> you can specify kernels at boot, but I'm not sure if there is
> an easy way to find kernels with specific CONFIG_ options.
> I'll let you know if I find one with all namespaces and
> veth+bridge+macvlan enabled, bc that would then give you
> everything you'd need.
>
> -serge
>
> Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
>> It's been a little while (probably a year) since I played with
>> EC2, but generally the problem is that you don't have much of
>> a choice for underlying kernels. =A0So you can't pick vserver/openvz
>> kernels, and the available kernels are too old to have containers
>> features. =A0As kernels get updated, whether you can use lxc or not
>> will only depend on whether CONFIG_{containers} features are compiled
>> in.
>>
>> It couldn't hurt to write the amazon folks and ask about it...
>>
>> -serge
>>
>> Quoting Jun OKAJIMA (okajima-og82NyAXoxRpnGNL948N7c8NsWr+9BEh@public.gmane.org):
>> > Somebody know any Amazon EC2 Image which
>> > supports any container technology?
>> > Vserver/LXC/OpenVZ... Any technology is Okay,
>> > I want to use pre-created image for EC2.
>> >
>> > I found many images for Ubuntu 9.10,
>> > but it lacks some support for LXC.
>> > Fedora12 supports all functions of LXC,
>> > but did not find any image.
>> >
>> > =A0 =A0 =A0 --- Okajima, Jun. Tokyo, Japan.
>> > _______________________________________________
>> > Containers mailing list
>> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> > https://lists.linux-foundation.org/mailman/listinfo/containers
>> _______________________________________________
>> Containers mailing list
>> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>> https://lists.linux-foundation.org/mailman/listinfo/containers
>
