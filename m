From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: allocate specific port range for container?
Date: Fri, 08 Nov 2013 17:41:59 -0800
Message-ID: <87ppqal5aw.fsf@xmission.com>
References: <1383680242.61814.YahooMailNeo@web184303.mail.ne1.yahoo.com>
	<20131105215324.GB4256@ac100>
	<1383690907.99487.YahooMailNeo@web184302.mail.ne1.yahoo.com>
	<87vc02qx7i.fsf@xmission.com>
	<1383959661.2417.YahooMailNeo@web184305.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1383959661.2417.YahooMailNeo-abza1nB0wQvuQS8rMknbopOW+3bF1jUfVpNB7YpNyf8@public.gmane.org>
	(Hongbing Wang's message of "Fri, 8 Nov 2013 17:14:21 -0800 (PST)")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org> writes:

Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> writes:
> > I have been working on this recently.
> >
> > I have recently made ip_local_port range per netns to help support
> > this.
>
> [HB] That is exactly what I am looking for! Do u have any plan to
> open-source your work?

Baring typos this is it.  In due course the code should will also appear
in Mesos.

Before you run this make certain to look and discover the environment
variables you need to set.

linkaddr=$(ip -o link show dev eth0 | sed -e 's|^.*link/ether \(..:..:..:..:..:..\).*$|\1|' )

ip netns add container

ip link add veth0 type veth peer name eth0 netns container address $linkaddr

tc qdisc add dev eth0 ingress

tc filter add dev eth0 ffff: protocol u32 \
   match ether dst $linkaddr \
   match ip dst $ip \
   match ip dport $port_start $port_mask \
   action mirred egress redirect dev $netns-device

tc filter add dev eth0 parent ffff: protocol ip u32 \
   match ip dst $ip \
   match ip protocol 1 0xff \
   action mirred egress mirror dev veth0

tc filter add dev eth0 parent ffff: protocol arp basic \
   action mirred egress mirror dev veth0

tc filter add dev lo parent ffff: protocol u32 \
   match ip dst $ip \
   match ip dport $port_start $port_mask \
   action mirred egress redirect dev veth0


tc qdisc add dev veth0 ingress

tc filter add veth0 parent ffff: protocol arp basic
   action mirred egress redirect dev eth0

tc filter add dev veth0 parent ffff: protocol ip u32 \
   match ip protocol 1 0xff \
   action mirred egress redirect dev eth0

tc filter add dev veth0 parent ffff: protocol ip u32 \
   match ip sport $port_start $port_mask \
   action mirred egress redirect dev eth0

tc filter add dev veth0 parent ffff: protocol ip u32 \
   match ip dst $ip \
   match ip sport $port_start $port_mask \
   action mirred egress redirect dev lo

ip netns exec container ip link set lo up
ip netns exec container tc qdisc add dev lo ingress
ip netns exec container ip link set eth0 up
ip netns exec container ip addr add ${ip}/24 dev eth0
ip netns exec container sysctl net.ipv4.ip_local_port_range="$port_start $port_end"

ip netns exec container tc filter add dev lo parent ffff: protocol ip u32 \
   match ip dst $ip
   action mirred egress redirect dev eth0

ip netns exec container tc filter add dev lo parent ffff: protocol ip u32 \
   match ip dst $ip
   match ip dport $port_start $port_mask

Eric
