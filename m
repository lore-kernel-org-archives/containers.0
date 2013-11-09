From: Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org>
Subject: Re: allocate specific port range for container?
Date: Fri, 8 Nov 2013 17:14:21 -0800 (PST)
Message-ID: <1383959661.2417.YahooMailNeo@web184305.mail.ne1.yahoo.com>
References: <1383680242.61814.YahooMailNeo@web184303.mail.ne1.yahoo.com>
	<20131105215324.GB4256@ac100>
	<1383690907.99487.YahooMailNeo@web184302.mail.ne1.yahoo.com>
	<87vc02qx7i.fsf@xmission.com>
Reply-To: Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87vc02qx7i.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org





________________________________
 From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org> =

Cc: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>; "containers-cunTk1MwBs9QetFLy7KEm77oxUfYCNXn@public.gmane.org=
ion.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>; Zhu Yanhai <zhu.yanhai@gm=
ail.com> =

Sent: Friday, November 8, 2013 3:40 PM
Subject: Re: allocate specific port range for container?
 =


Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org> writes:

> ________________________________
>=A0 From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
> To: Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org> =

> Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm2CgeU+1il2p@public.gmane.org=
ation.org> =

> Sent: Tuesday, November 5, 2013 1:53 PM
> Subject: Re: allocate specific port range for container?
>=A0 =

>
> Quoting Hongbing Wang (hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org):
>> Hello LXC experts:
>> =

>> Is it possible to allocate specific transport port range for the socket =
based applications inside one container?=A0
>
> How do you mean?=A0 You want ports 50000-51000 of the host to be forwarded
> to container 1, and 60000-61000 to container 2?
>
> [HB] We want the apps inside LXC_a to use the port b/w 50k - 51k and LXC_=
b to be allocated the port b/w 60k - 61k.
>
>> Say I have two containers: LXC_a and LXC_b, and each has some socket
>> based applications I cannot modify or have no source code. If I need
>> port range 50000 - 51000 for LXC_a and 60000 - 61000 for LXC_b. Any
>> way to achieve this?
>> =

>> The /proc/sys/net/ipv4/ip_local_port_range is for the host to adjust
>> the ephemeral port range, and we do not have the per LXC based
>> setting on the local_port_range. Is this due to that the LXC network
>> namespace isolation is at the L3 level? How could I achieve this per
>> port range LXC?

> The network namespaces are actually at L2, not L3.=A0 Each container has
> its own routing table.
>
> I think you can get what you want by simply giving each container a veth
> nic and using iptables on the host to forward the ports you want to the
> appropriate container.=A0 That's how I co-locate web, mail, and other
> server containers on the same host.
>
> [HB] for my specific case we do not use iptables. We can route the
> packets to the LXC_a or LXC_b, but we want the ports to be within
> specific ranges.

I have been working on this recently.

I have recently made ip_local_port range per netns to help support this.

[HB] That is exactly what I am looking for! Do u have any plan to open-sour=
ce your work?

Yanhai posted that he is using SELinux, we use different distro with lots o=
f other limitations which require to support the existing features.

Thanks,
-HB

Beyond that what I am doing is using ingress traffic control to redirect
packets in the appopriate port range into the appropriate network
namespace.

Compared to nat with iptables and some of the other solutions it comes
out fairly clean and it at the very beginning stages at the packet
processing path so unnecessary work can be avoided.

There are a couple of cases you have to watch for icmp, arp and looping
packets back to other namespaces on the same box but it is pretty
straight forward to setup.=A0 The trickiest bit is that you have to read
the tc source to find the tc commands that make the tc classifier easy
to use.

The primary restricition I currently have is that the port ranges need
to be a power of 2 in size, to make the u32 classifier easy to use.

Eric
