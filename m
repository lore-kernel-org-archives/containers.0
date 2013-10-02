From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Device Namespaces
Date: Wed, 02 Oct 2013 15:45:46 -0700
Message-ID: <871u43pa05.fsf@xmission.com>
References: <CAA2m6vexArJ+6jFbK80Amstk=LK30=XDNHdBHSswP=LgpSP-6A@mail.gmail.com>
	<871u4yddg4.fsf@xmission.com>
	<CAA2m6vc_kWWGDWcdjk26N3YvTqZySLFxPQRjOD9_ypBOka2+GQ@mail.gmail.com>
	<CAE=NcrbyFFoMn2nfBA_=ZtwD=eGLvqK=L-U9MuGrtJFLZfZppw@mail.gmail.com>
	<87bo3gshz5.fsf_-_@xmission.com> <20130926053320.GB3725@kroah.com>
	<CAE=NcrYV2RiMV7PcwEjFGFRBrz9XdZGs86Wau2a+6xpYN2aEHA@mail.gmail.com>
	<CALCETrWWoHzuJcnfEUY+cFpOgT5gnG8U1cVbCW0_8V7Z_v6DJw@mail.gmail.com>
	<20131001175345.GA4145@mail.hallyn.com> <87had0wz07.fsf@xmission.com>
	<20131001205718.GA17036@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131001205718.GA17036-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org> (Greg Kroah-Hartman's message
	of "Tue, 1 Oct 2013 13:57:18 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, devel <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, mhw <mhw-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Stephane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


I think libudev is a solution to a completely different problem.  It is
possible I am blind but I just don't see how libudev even attempts to
solve the problem.

The desire is to plop a distro install into a subdirectory.  Fire up a
container around it, and let the distro's userspace do it's thing to
manage hotplug events.

devtmpfs can be faked fairly easily.
I don't know about sysfs.

Sending events that say you have hotplugged is the largest practical
problem.

On the minimal side I think the patch below is enough to let us fake up
uevents for the container and make things work.  I have heard the words
faking uevents and is a bad thing.  But I have not heard a reason or seen
any attempt at explanation.  My guess is that we are simply talking
about different problems.

I would like to see someone wire up all of the userspace bits and see
how well hotplug can be made to work before I walk down the path
represented by this patch but it seems reasonable.  But I do have
anecdotal reports from someone who walked a similar path that this is
enough to bring up a full desktop system in a container.

Eric


diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 7a6c396a263b..46d05783da82 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -38,6 +38,7 @@ extern void netlink_table_ungrab(void);
 
 #define NL_CFG_F_NONROOT_RECV	(1 << 0)
 #define NL_CFG_F_NONROOT_SEND	(1 << 1)
+#define NL_CFG_F_IMPERSONATE_KERN (1 << 2)
 
 /* optional Netlink kernel configuration parameters */
 struct netlink_kernel_cfg {
diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index 52e5abbc41db..f75e34397df8 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -375,9 +375,12 @@ static int uevent_net_init(struct net *net)
 	struct uevent_sock *ue_sk;
 	struct netlink_kernel_cfg cfg = {
 		.groups	= 1,
-		.flags	= NL_CFG_F_NONROOT_RECV,
+		.flags	= NL_CFG_F_NONROOT_RECV | NL_CFG_F_IMPERSONATE_KERN,
 	};
 
+	if (net->user_ns != &init_user_ns)
+		return 0;
+
 	ue_sk = kzalloc(sizeof(*ue_sk), GFP_KERNEL);
 	if (!ue_sk)
 		return -ENOMEM;
@@ -399,6 +402,9 @@ static void uevent_net_exit(struct net *net)
 {
 	struct uevent_sock *ue_sk;
 
+	if (net->user_ns != &init_user_ns)
+		return;
+
 	mutex_lock(&uevent_sock_mutex);
 	list_for_each_entry(ue_sk, &uevent_sock_list, list) {
 		if (sock_net(ue_sk->sk) == net)
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 0c61b59175dc..71863cc465eb 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1252,7 +1252,7 @@ static int netlink_release(struct socket *sock)
 
 	skb_queue_purge(&sk->sk_write_queue);
 
-	if (nlk->portid) {
+	if (sk_hashed(sk)) {
 		struct netlink_notify n = {
 						.net = sock_net(sk),
 						.protocol = sk->sk_protocol,
@@ -1409,11 +1409,21 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			return err;
 	}
 
-	if (nlk->portid) {
+	if (sk_hashed(sk)) {
 		if (nladdr->nl_pid != nlk->portid)
 			return -EINVAL;
 	} else {
-		err = nladdr->nl_pid ?
+		bool autobind = nladdr->nl_pid == 0;
+		if (nladdr->nl_pid == 0 && (nladdr->nl_pad == 0xffff)) {
+			if (!(nl_table[sk->sk_protocol].flags & NL_CFG_F_IMPERSONATE_KERN))
+				return -EPERM;
+			if (net->user_ns == &init_user_ns)
+				return -EPERM;
+			if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
+				return -EPERM;
+			autobind = false;
+		}
+		err = !autobind ?
 			netlink_insert(sk, net, nladdr->nl_pid) :
 			netlink_autobind(sock);
 		if (err)
@@ -1467,7 +1477,7 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 	if (nladdr->nl_groups && !netlink_capable(sock, NL_CFG_F_NONROOT_SEND))
 		return -EPERM;
 
-	if (!nlk->portid)
+	if (!sk_hashed(sk))
 		err = netlink_autobind(sock);
 
 	if (err == 0) {
@@ -2228,7 +2238,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		dst_group = nlk->dst_group;
 	}
 
-	if (!nlk->portid) {
+	if (!sk_hashed(sk)) {
 		err = netlink_autobind(sock);
 		if (err)
 			goto out;
