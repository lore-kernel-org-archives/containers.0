From: Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
Subject: Re: how to do not allow to mount /cgroup inside container?
Date: Tue, 25 Aug 2009 16:51:43 +0200
Message-ID: <ac1c4bf20908250751n159f0258ta84c7372e2cd01cf@mail.gmail.com>
References: <ac1c4bf20908250517j43d49f9fv1b5d6d5beae8aa@mail.gmail.com>
	<4A93DD67.5030905@free.fr> <20090825140537.GA19644@us.ibm.com>
	<ac1c4bf20908250743t9c30c27ud3ff649003465334@mail.gmail.com>
Reply-To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <ac1c4bf20908250743t9c30c27ud3ff649003465334-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

2009/8/25 Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>

> 2009/8/25 Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
>
>> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
>> > Krzysztof Taraszka wrote:
>> >> Hi,
>> >>
>> >> I was looking for possibility to secure lxc container to do not allow
>> 'root
>> >> container user'  from changing limits from cgroup. Right now without
>> STACK64
>> >> or SELinux he can do this easily.
>> >> I read the
>> http://www.ibm.com/developerworks/linux/library/l-lxc-security/cookbook
>> >> and decided to use STACK64 kernel mechanism.
>> >> Well... mounting cgroup inside container fails (great!, i am looked for
>> that
>> >> ;)) but networking fails too (interface bring up, sshd bring up,
>> connection
>> >> beetween host and container is, but 'mtr', 'ping' even 'apt-get update'
>> >> fails and I do not know why). I secure my container exactly like in the
>> >> cookbook.
>>
>> Yeah, smack's use of cipso can make things tricky, and it's possible
>> things
>> have changed a bit recently.  Although I'm currently running smack in my
>> everyday s390 kernel to test checkpointing of its labels, and networking
>> is working fine.
>
>
>> Can you give me a few details - what distro, smack policy, and precise
>> kernel
>> version are you using, for starters?
>>
>
> debian lenny amd64,
> kernel 2.6.30.5
> lxc-tools from git
>
> lxc1amd64:~# cat /etc/smackaccesses
> debian _ rwa
> _ debian rwa
> _ host rwax
> host _ rwax
>
> where "debian" is container, "host" is a host.
>
> I did this:
>
> for f in `find /root/rootfs.debian`; do
>     attr -S -s SMACK64 -V debian $f
> done
>
> on the container fs.
>
> container startup script look like here:
>
> lxc1amd64:~# cat vs1.sh
> #!/bin/sh
> cp /bin/dropmacadmin /root/rootfs.debian/bin/
> attr -S -s SMACK64 -V debian /root/rootfs.debian/bin/dropmacadmin
> echo debian > /proc/self/attr/current
> lxc-start -n debian /bin/dropmacadmin /sbin/init
>
> /etc/fstab inside container look like:
>
> debian:~# cat /etc/fstab
> tmpfs  /dev/shm   tmpfs  defaults,smackfsroot=debian,smackfsdef=debian  0 0
>
> And here is some output when I tried to do ping to the wp.pl, tried to
> apt-get update and tried to ping gateway
>
> debian:~# ping wp.pl
> PING wp.pl (212.77.100.101) 56(84) bytes of data.
> From 10.177.128.1 icmp_seq=1 Parameter problem: pointer = 20
> From 10.177.128.1 icmp_seq=2 Parameter problem: pointer = 20
> ^C
> --- wp.pl ping statistics ---
> 2 packets transmitted, 0 received, +2 errors, 100% packet loss, time 1001ms
>
> debian:~# apt-get update
> Err http://ftp.debian.org lenny Release.gpg
>   Could not connect to ftp.debian.org:80 (130.89.149.226). - connect (71
> Protocol error)
> Err http://ftp.debian.org lenny/main Translation-en_US
>   Could not connect to ftp.debian.org:80 (130.89.149.226). - connect (71
> Protocol error)
> Ign http://ftp.debian.org lenny Release
> Ign http://ftp.debian.org lenny/main Packages/DiffIndex
> Ign http://ftp.debian.org lenny/main Packages
> Err http://ftp.debian.org lenny/main Packages
>   Could not connect to ftp.debian.org:80 (130.89.149.226). - connect (71
> Protocol error)
> W: Failed to fetch http://ftp.debian.org/debian/dists/lenny/Release.gpg
> Could not connect to ftp.debian.org:80 (130.89.149.226). - connect (71
> Protocol error)
>
> W: Failed to fetch
> http://ftp.debian.org/debian/dists/lenny/main/i18n/Translation-en_US.gz
> Could not connect to ftp.debian.org:80 (130.89.149.226). - connect (71
> Protocol error)
>
> W: Failed to fetch
> http://ftp.debian.org/debian/dists/lenny/main/binary-amd64/Packages  Could
> not connect to ftp.debian.org:80 (130.89.149.226). - connect (71 Protocol
> error)
>
> E: Some index files failed to download, they have been ignored, or old ones
> used instead.
> debian:~# ping 192.168.1.1
> PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
> 64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=0.085 ms
> unknown option 86
> 64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=0.136 ms
> unknown option 86
> 64 bytes from 192.168.1.1: icmp_seq=3 ttl=64 time=0.116 ms
> unknown option 86
> ^C
> --- 192.168.1.1 ping statistics ---
> 3 packets transmitted, 3 received, 0% packet loss, time 2005ms
> rtt min/avg/max/mdev = 0.085/0.112/0.136/0.022 ms
>
> did you changed your smack policy or you have the same as mine?
>
>

Oh, I forgot to add that smack-utils I got from here:

https://launchpad.net/~anthonywrather/+archive/ppa/+files/smack-util_0.2-0ubuntu0~ppa3.tar.gz

because this link won't work:
http://schaufler-ca.com/data/080616/smack-util-0.1.tar

-- 
Krzysztof Taraszka
