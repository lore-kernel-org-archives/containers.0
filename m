From: Zhu Yanhai <zhu.yanhai-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: allocate specific port range for container?
Date: Wed, 6 Nov 2013 11:36:13 +0800
Message-ID: <CAC8teKW_ekeqX7NTKRWC92FsKpRx_o+Rtv3PC=bM+YtkKDexRQ@mail.gmail.com>
References: <1383680242.61814.YahooMailNeo@web184303.mail.ne1.yahoo.com>
	<20131105215324.GB4256@ac100>
	<1383690907.99487.YahooMailNeo@web184302.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1383690907.99487.YahooMailNeo-abza1nB0wQu2Y7dhQGSVAJOW+3bF1jUfVpNB7YpNyf8@public.gmane.org>
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

2013/11/6 Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org>:
>
>
>
>
> ________________________________
>  From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
> To: Hongbing Wang <hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org>
> Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
> Sent: Tuesday, November 5, 2013 1:53 PM
> Subject: Re: allocate specific port range for container?
>
>
> Quoting Hongbing Wang (hongbingwang-rphTv4pjVZMJGwgDXS7ZQA@public.gmane.org):
>> Hello LXC experts:
>>
>> Is it possible to allocate specific transport port range for the socket based applications inside one container?
>
> How do you mean?  You want ports 50000-51000 of the host to be forwarded
> to container 1, and 60000-61000 to container 2?
>
> [HB] We want the apps inside LXC_a to use the port b/w 50k - 51k and LXC_b to be allocated the port b/w 60k - 61k.
>
>> Say I have two containers: LXC_a and LXC_b, and each has some socket based applications I cannot modify or have no source code. If I need port range 50000 - 51000 for LXC_a and 60000 - 61000 for LXC_b. Any way to achieve this?
>>
>> The /proc/sys/net/ipv4/ip_local_port_range is for the host to adjust the ephemeral port range, and we do not have the per LXC based setting on the local_port_range. Is this due to that the LXC network namespace isolation is at the L3 level? How could I achieve this per port range LXC?
>
> The network namespaces are actually at L2, not L3.  Each container has
> its own routing table.
>
> I think you can get what you want by simply giving each container a veth
> nic and using iptables on the host to forward the ports you want to the
> appropriate container.  That's how I co-locate web, mail, and other
> server containers on the same host.
>
> [HB] for my specific case we do not use iptables. We can route the packets to the LXC_a or LXC_b, but we want the ports to be within specific ranges.

Then how about SElinux ? You can specify the ports rules against each
container. Serge Hallyn has a cookbook about this
(http://www.ibm.com/developerworks/library/l-lxc-security/)
I'm using a SElinux policy based on Serge Hallyn's original edition in
the production system, since I have so many containers on the physical
box  that I can't give them each a individual veth and IP, also NAT is
forbidden by the network topology (it's a long story). In one words, I
don't create separate network namespace for them at all, but let them
use one single network namespace and leverage the SElinux policy for
security.

BTW, there is one thing strange for me about the SElinux ports policy,
it does not prevent the container from name binding the ports in
/proc/sys/net/ipv4/ip_local_port_range, although the ports in
/proc/sys/net/ipv4/ip_local_port_range surly doesn't have the
container's labels. So actually I added a in-house patch as below to
make it work as expected,

--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3935,24 +3935,18 @@ static int selinux_socket_bind(struct socket
*sock, struct sockaddr *address, in
                }

                if (snum) {
-                       int low, high;
-
-                       inet_get_local_port_range(&low, &high);
-
-                       if (snum < max(PROT_SOCK, low) || snum > high) {
-                               err = sel_netport_sid(sk->sk_protocol,
-                                                     snum, &sid);
-                               if (err)
-                                       goto out;
-                               COMMON_AUDIT_DATA_INIT(&ad, NET);
-                               ad.u.net.sport = htons(snum);
-                               ad.u.net.family = family;
-                               err = avc_has_perm(isec->sid, sid,
-                                                  isec->sclass,
-                                                  SOCKET__NAME_BIND, &ad);
-                               if (err)
-                                       goto out;
-                       }
+                       err = sel_netport_sid(sk->sk_protocol,
+                                       snum, &sid);
+                       if (err)
+                               goto out;
+                       COMMON_AUDIT_DATA_INIT(&ad, NET);
+                       ad.u.net.sport = htons(snum);
+                       ad.u.net.family = family;
+                       err = avc_has_perm(isec->sid, sid,
+                                       isec->sclass,
+                                       SOCKET__NAME_BIND, &ad);
+                       if (err)
+                               goto out;
                }

                switch (isec->sclass) {
-- 
1.8.0.1

--
Thanks,
Zhu Yanhai

>
> Regards,
> -HB
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
