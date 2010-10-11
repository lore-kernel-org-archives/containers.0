From: MALATTAR <mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>
Subject: Re: Fwd: Re: lxc-performance?
Date: Mon, 11 Oct 2010 10:05:24 +0200
Message-ID: <4CB2C544.4070006@univ-fcomte.fr>
References: <4CAED1CF.6050908@univ-fcomte.fr>
	<20101008164122.GA16891@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101008164122.GA16891-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

  Le 08/10/2010 18:41, Serge E. Hallyn a =E9crit :
> Quoting MALATTAR (mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org):
>>
>> -------- Message original --------
>> Sujet: 	Re: lxc-performance
>> Date : 	Thu, 07 Oct 2010 16:56:05 +0200
>> De : 	MALATTAR<mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>
>> Pour : 	MALATTAR<mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>
>>
>>
>>
>> Le 07/10/2010 16:43, MALATTAR a =E9crit :
>>> ------------------------------------------------------------------------
>>> 06.10.2010 23:41, MALATTAR ?????:
>>>
>>>> /  the container dora1, where i launch an instance of my IDS, does not=
 take
>>> />/  more than 70 MB as memory even though the memory limit for it is m=
uch
>>> />/  bigger than this value,
>>> /
>>> How do you measure memory usage?
>> by using the command:
>> lxc-cgroup -n dora1 memory.usage_in_bytes
>>>    What's in memory.max_usage_in_bytes of
>>> the container's cgroup?
>> executing the next command lxc-cgroup -n dora1 memory.max_usage_in_bytes
>> gave me 70193152 bytes
> Interesting - that's not the value you set in your intro email.
???
> What does /var/lib/lxc/dora1/config have?
>
lxc.utsname =3D dora1
lxc.tty =3D 4
lxc.network.type =3D veth
lxc.network.flags =3D up
lxc.network.link =3D br-node1
lxc.network.name =3D eth0
lxc.network.mtu =3D 1500
lxc.network.ipv4 =3D 10.0.0.1/24
lxc.network.hwaddr =3D 12:DA:00:4B:54:45
lxc.rootfs =3D /lxc/rootfs.fedora
lxc.mount =3D /lxc/fstab.fedora
lxc.cgroup.devices.deny =3D a
# /dev/null and zero
lxc.cgroup.devices.allow =3D c 1:3 rwm
lxc.cgroup.devices.allow =3D c 1:5 rwm
# consoles
lxc.cgroup.devices.allow =3D c 5:1 rwm
lxc.cgroup.devices.allow =3D c 5:0 rwm
lxc.cgroup.devices.allow =3D c 4:0 rwm
lxc.cgroup.devices.allow =3D c 4:1 rwm
# /dev/{,u}random
lxc.cgroup.devices.allow =3D c 1:9 rwm
lxc.cgroup.devices.allow =3D c 1:8 rwm
# /dev/pts/* - pts namespaces are "coming soon"
lxc.cgroup.devices.allow =3D c 136:* rwm
lxc.cgroup.devices.allow =3D c 5:2 rwm
# rtc
lxc.cgroup.devices.allow =3D c 254:0 rwm
lxc.cgroup.memory.limit_in_bytes =3D 1524435456
lxc.pts=3D1


-- =

Mouhannad AlATTAR
Doctorant =E0 L=92UFR Sciences,Techniques et Gestion de l=92Industrie
P=F4le multimedia de Franche Comt=E9 - numerica
1, cours Leprince-Ringuet
25201 Montb=E9liard
Fixe bureau : 03 81 99 47 87
Portable : 06 16 71 05 10
