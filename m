From: Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org>
Subject: Re: allocate specific port range for container?
Date: Fri, 8 Nov 2013 17:49:04 -0800 (PST)
Message-ID: <1383961744.34672.YahooMailNeo@web184305.mail.ne1.yahoo.com>
References: <1383680242.61814.YahooMailNeo@web184303.mail.ne1.yahoo.com>
	<20131105215324.GB4256@ac100>
	<1383690907.99487.YahooMailNeo@web184302.mail.ne1.yahoo.com>
	<87vc02qx7i.fsf@xmission.com>
	<1383959661.2417.YahooMailNeo@web184305.mail.ne1.yahoo.com>
	<87ppqal5aw.fsf@xmission.com>
Reply-To: Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ppqal5aw.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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



Thanks, Eric. I will look into your patch.
-HB


________________________________
 From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org> =

Cc: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>; "containers-cunTk1MwBs9QetFLy7KEm77oxUfYCNXn@public.gmane.org=
ion.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>; Zhu Yanhai <zhu.yanhai@gm=
ail.com> =

Sent: Friday, November 8, 2013 5:41 PM
Subject: Re: allocate specific port range for container?
 =


Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org> writes:

Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> writes:
> > I have been working on this recently.
> >
> > I have recently made ip_local_port range per netns to help support
> > this.
>
> [HB] That is exactly what I am looking for! Do u have any plan to
> open-source your work?

Baring typos this is it.=A0 In due course the code should will also appear
in Mesos.

Before you run this make certain to look and discover the environment
variables you need to set.

linkaddr=3D$(ip -o link show dev eth0 | sed -e 's|^.*link/ether \(..:..:..:=
..:..:..\).*$|\1|' )

ip netns add container

ip link add veth0 type veth peer name eth0 netns container address $linkaddr

tc qdisc add dev eth0 ingress

tc filter add dev eth0 ffff: protocol u32 \
=A0  match ether dst $linkaddr \
=A0  match ip dst $ip \
=A0  match ip dport $port_start $port_mask \
=A0  action mirred egress redirect dev $netns-device

tc filter add dev eth0 parent ffff: protocol ip u32 \
=A0  match ip dst $ip \
=A0  match ip protocol 1 0xff \
=A0  action mirred egress mirror dev veth0

tc filter add dev eth0 parent ffff: protocol arp basic \
=A0  action mirred egress mirror dev veth0

tc filter add dev lo parent ffff: protocol u32 \
=A0  match ip dst $ip \
=A0  match ip dport $port_start $port_mask \
=A0  action mirred egress redirect dev veth0


tc qdisc add dev veth0 ingress

tc filter add veth0 parent ffff: protocol arp basic
=A0  action mirred egress redirect dev eth0

tc filter add dev veth0 parent ffff: protocol ip u32 \
=A0  match ip protocol 1 0xff \
=A0  action mirred egress redirect dev eth0

tc filter add dev veth0 parent ffff: protocol ip u32 \
=A0  match ip sport $port_start $port_mask \
=A0  action mirred egress redirect dev eth0

tc filter add dev veth0 parent ffff: protocol ip u32 \
=A0  match ip dst $ip \
=A0  match ip sport $port_start $port_mask \
=A0  action mirred egress redirect dev lo

ip netns exec container ip link set lo up
ip netns exec container tc qdisc add dev lo ingress
ip netns exec container ip link set eth0 up
ip netns exec container ip addr add ${ip}/24 dev eth0
ip netns exec container sysctl net.ipv4.ip_local_port_range=3D"$port_start =
$port_end"

ip netns exec container tc filter add dev lo parent ffff: protocol ip u32 \
=A0  match ip dst $ip
=A0  action mirred egress redirect dev eth0

ip netns exec container tc filter add dev lo parent ffff: protocol ip u32 \
=A0  match ip dst $ip
=A0  match ip dport $port_start $port_mask

Eric
