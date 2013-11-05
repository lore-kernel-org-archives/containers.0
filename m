From: Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org>
Subject: Re: allocate specific port range for container?
Date: Tue, 5 Nov 2013 14:35:07 -0800 (PST)
Message-ID: <1383690907.99487.YahooMailNeo@web184302.mail.ne1.yahoo.com>
References: <1383680242.61814.YahooMailNeo@web184303.mail.ne1.yahoo.com>
	<20131105215324.GB4256@ac100>
Reply-To: Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131105215324.GB4256@ac100>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org





________________________________
 From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
To: Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org> =

Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm77oxUfYCNXn@public.gmane.org=
ion.org> =

Sent: Tuesday, November 5, 2013 1:53 PM
Subject: Re: allocate specific port range for container?
 =


Quoting Hongbing Wang (hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org):
> Hello LXC experts:
> =

> Is it possible to allocate specific transport port range for the socket b=
ased applications inside one container?=A0

How do you mean?=A0 You want ports 50000-51000 of the host to be forwarded
to container 1, and 60000-61000 to container 2?

[HB] We want the apps inside LXC_a to use the port b/w 50k - 51k and LXC_b =
to be allocated the port b/w 60k - 61k.

> Say I have two containers: LXC_a and LXC_b, and each has some socket base=
d applications I cannot modify or have no source code. If I need port range=
 50000 - 51000 for LXC_a and 60000 - 61000 for LXC_b. Any way to achieve th=
is?
> =

> The /proc/sys/net/ipv4/ip_local_port_range is for the host to adjust the =
ephemeral port range, and we do not have the per LXC based setting on the l=
ocal_port_range. Is this due to that the LXC network namespace isolation is=
 at the L3 level? How could I achieve this per port range LXC?

The network namespaces are actually at L2, not L3.=A0 Each container has
its own routing table.

I think you can get what you want by simply giving each container a veth
nic and using iptables on the host to forward the ports you want to the
appropriate container.=A0 That's how I co-locate web, mail, and other
server containers on the same host.

[HB] for my specific case we do not use iptables. We can route the packets =
to the LXC_a or LXC_b, but we want the ports to be within specific ranges.

Regards,
-HB
