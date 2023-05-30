Received: from mail-b.sr.ht (mail-b.sr.ht [173.195.146.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8884D206B4
	for <containers@lists.linux.dev>; Tue, 30 May 2023 19:00:02 +0000 (UTC)
Authentication-Results: mail-b.sr.ht; dkim=none 
Received: from git.sr.ht (unknown [173.195.146.142])
	by mail-b.sr.ht (Postfix) with ESMTPSA id 6224B11F05E;
	Tue, 30 May 2023 18:50:50 +0000 (UTC)
From: ~akihirosuda <akihirosuda@git.sr.ht>
Date: Tue, 30 May 2023 23:42:52 +0900
Subject:
 [PATCH linux 1/3] net/ipv4: split group_range logic to kernel/group_range.c
Message-ID: <168547265011.24337.4306067683997517082-1@git.sr.ht>
X-Mailer: git.sr.ht
Reply-to: ~akihirosuda <suda.kyoto@gmail.com>
In-Reply-To: <168547265011.24337.4306067683997517082-0@git.sr.ht>
To: linux-kernel@vger.kernel.org, containers@lists.linux.dev, serge@hallyn.com,
 brauner@kernel.org, paul@paul-moore.com, ebiederm@xmission.com
Cc: suda.kyoto@gmail.com, akihiro.suda.cz@hco.ntt.co.jp
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0

From: Akihiro Suda <akihiro.suda.cz@hco.ntt.co.jp>

The logic can be reused for other sysctls in future.

Signed-off-by: Akihiro Suda <akihiro.suda.cz@hco.ntt.co.jp>
---
 include/linux/group_range.h | 24 ++++++++++
 include/net/netns/ipv4.h    |  9 +---
 include/net/ping.h          |  6 ---
 kernel/Makefile             |  2 +-
 kernel/group_range.c        | 91 +++++++++++++++++++++++++++++++++++++
 net/ipv4/ping.c             | 39 ++--------------
 net/ipv4/sysctl_net_ipv4.c  | 56 ++---------------------
 7 files changed, 125 insertions(+), 102 deletions(-)
 create mode 100644 include/linux/group_range.h
 create mode 100644 kernel/group_range.c

diff --git a/include/linux/group_range.h b/include/linux/group_range.h
new file mode 100644
index 000000000000..5bd837eced95
--- /dev/null
+++ b/include/linux/group_range.h
@@ -0,0 +1,24 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _LINUX_GROUP_RANGE_H
+#define _LINUX_GROUP_RANGE_H
+
+#include <linux/seqlock.h>
+#include <linux/uidgid.h>
+
+/*
+ * gid_t is either uint or ushort.  We want to pass it to
+ * proc_dointvec_minmax(), so it must not be larger than MAX_INT
+ */
+#define GROUP_RANGE_MAX (((gid_t)~0U) >> 1)
+
+struct group_range {
+	seqlock_t       lock;
+	kgid_t          range[2];
+};
+
+typedef struct group_range* (*sysctl_group_range_func_t)(struct ctl_table *);
+int sysctl_group_range(sysctl_group_range_func_t fn, struct ctl_table *table,
+				 int write, void *buffer, size_t *lenp, loff_t *ppos);
+
+bool check_current_group_range(struct group_range *gr);
+#endif /* _LINUX_GROUP_RANGE_H */
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index db762e35aca9..75d745a7c6e1 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -6,11 +6,11 @@
 #ifndef __NETNS_IPV4_H__
 #define __NETNS_IPV4_H__
=20
-#include <linux/uidgid.h>
 #include <net/inet_frag.h>
 #include <linux/rcupdate.h>
 #include <linux/seqlock.h>
 #include <linux/siphash.h>
+#include <linux/group_range.h>
=20
 struct ctl_table_header;
 struct ipv4_devconf;
@@ -24,11 +24,6 @@ struct local_ports {
 	bool		warned;
 };
=20
-struct ping_group_range {
-	seqlock_t	lock;
-	kgid_t		range[2];
-};
-
 struct inet_hashinfo;
=20
 struct inet_timewait_death_row {
@@ -204,7 +199,7 @@ struct netns_ipv4 {
 	int sysctl_igmp_max_msf;
 	int sysctl_igmp_qrv;
=20
-	struct ping_group_range ping_group_range;
+	struct group_range ping_group_range;
=20
 	atomic_t dev_addr_genid;
=20
diff --git a/include/net/ping.h b/include/net/ping.h
index 9233ad3de0ad..37b1d7baeb7b 100644
--- a/include/net/ping.h
+++ b/include/net/ping.h
@@ -16,12 +16,6 @@
 #define PING_HTABLE_SIZE 	64
 #define PING_HTABLE_MASK 	(PING_HTABLE_SIZE-1)
=20
-/*
- * gid_t is either uint or ushort.  We want to pass it to
- * proc_dointvec_minmax(), so it must not be larger than MAX_INT
- */
-#define GID_T_MAX (((gid_t)~0U) >> 1)
-
 /* Compatibility glue so we can support IPv6 when it's compiled as a module =
*/
 struct pingv6_ops {
 	int (*ipv6_recv_error)(struct sock *sk, struct msghdr *msg, int len,
diff --git a/kernel/Makefile b/kernel/Makefile
index b69c95315480..fb3a812cf92e 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -10,7 +10,7 @@ obj-y     =3D fork.o exec_domain.o panic.o \
 	    extable.o params.o \
 	    kthread.o sys_ni.o nsproxy.o \
 	    notifier.o ksysfs.o cred.o reboot.o \
-	    async.o range.o smpboot.o ucount.o regset.o
+	    async.o range.o smpboot.o ucount.o regset.o group_range.o
=20
 obj-$(CONFIG_USERMODE_DRIVER) +=3D usermode_driver.o
 obj-$(CONFIG_MULTIUSER) +=3D groups.o
diff --git a/kernel/group_range.c b/kernel/group_range.c
new file mode 100644
index 000000000000..b5c7d35d680b
--- /dev/null
+++ b/kernel/group_range.c
@@ -0,0 +1,91 @@
+// SPDX-License-Identifier: GPL-2.0-only
+
+#include <linux/cred.h>
+#include <linux/group_range.h>
+#include <linux/uidgid.h>
+#include <linux/seqlock.h>
+#include <linux/sysctl.h>
+
+static void get_group_range(struct group_range *gr, kgid_t *low, kgid_t *hig=
h)
+{
+	unsigned int seq;
+
+	do {
+		seq =3D read_seqbegin(&gr->lock);
+
+		*low =3D gr->range[0];
+		*high =3D gr->range[1];
+	} while (read_seqretry(&gr->lock, seq));
+}
+
+static void set_group_range(struct group_range *gr, kgid_t low, kgid_t high)
+{
+	write_seqlock(&gr->lock);
+	gr->range[0] =3D low;
+	gr->range[1] =3D high;
+	write_sequnlock(&gr->lock);
+}
+
+static int group_range_min[] =3D { 0, 0 };
+static int group_range_max[] =3D { GROUP_RANGE_MAX, GROUP_RANGE_MAX };
+
+int sysctl_group_range(sysctl_group_range_func_t fn, struct ctl_table *table,
+				 int write, void *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct group_range *gr =3D fn(table);
+	struct user_namespace *user_ns =3D current_user_ns();
+	int ret;
+	gid_t urange[2];
+	kgid_t low, high;
+	struct ctl_table tmp =3D {
+		.data =3D &urange,
+		.maxlen =3D sizeof(urange),
+		.mode =3D table->mode,
+		.extra1 =3D &group_range_min,
+		.extra2 =3D &group_range_max,
+	};
+
+	get_group_range(gr, &low, &high);
+	urange[0] =3D from_kgid_munged(user_ns, low);
+	urange[1] =3D from_kgid_munged(user_ns, high);
+	ret =3D proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+
+	if (write && ret =3D=3D 0) {
+		low =3D make_kgid(user_ns, urange[0]);
+		high =3D make_kgid(user_ns, urange[1]);
+		if (!gid_valid(low) || !gid_valid(high))
+			return -EINVAL;
+		if (urange[1] < urange[0] || gid_lt(high, low)) {
+			low =3D make_kgid(&init_user_ns, 1);
+			high =3D make_kgid(&init_user_ns, 0);
+		}
+		set_group_range(gr, low, high);
+	}
+
+	return ret;
+}
+
+bool check_current_group_range(struct group_range *gr)
+{
+	kgid_t group =3D current_egid();
+	struct group_info *group_info;
+	int i;
+	kgid_t low, high;
+	bool ret =3D true;
+
+	get_group_range(gr, &low, &high);
+	if (gid_lte(low, group) && gid_lte(group, high))
+		return true;
+
+	group_info =3D get_current_groups();
+	for (i =3D 0; i < group_info->ngroups; i++) {
+		kgid_t gid =3D group_info->gid[i];
+
+		if (gid_lte(low, gid) && gid_lte(gid, high))
+			goto out_release_group;
+	}
+	ret =3D false;
+out_release_group:
+	put_group_info(group_info);
+	return ret;
+}
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 5178a3f3cb53..6e23771c5234 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -244,50 +244,17 @@ exit:
 	return sk;
 }
=20
-static void inet_get_ping_group_range_net(struct net *net, kgid_t *low,
-					  kgid_t *high)
-{
-	kgid_t *data =3D net->ipv4.ping_group_range.range;
-	unsigned int seq;
-
-	do {
-		seq =3D read_seqbegin(&net->ipv4.ping_group_range.lock);
-
-		*low =3D data[0];
-		*high =3D data[1];
-	} while (read_seqretry(&net->ipv4.ping_group_range.lock, seq));
-}
-
-
 int ping_init_sock(struct sock *sk)
 {
 	struct net *net =3D sock_net(sk);
-	kgid_t group =3D current_egid();
-	struct group_info *group_info;
-	int i;
-	kgid_t low, high;
-	int ret =3D 0;
=20
 	if (sk->sk_family =3D=3D AF_INET6)
 		sk->sk_ipv6only =3D 1;
=20
-	inet_get_ping_group_range_net(net, &low, &high);
-	if (gid_lte(low, group) && gid_lte(group, high))
-		return 0;
-
-	group_info =3D get_current_groups();
-	for (i =3D 0; i < group_info->ngroups; i++) {
-		kgid_t gid =3D group_info->gid[i];
+	if (!check_current_group_range(&net->ipv4.ping_group_range))
+		return -EACCES;
=20
-		if (gid_lte(low, gid) && gid_lte(gid, high))
-			goto out_release_group;
-	}
-
-	ret =3D -EACCES;
-
-out_release_group:
-	put_group_info(group_info);
-	return ret;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(ping_init_sock);
=20
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 40fe70fc2015..ad355ab265db 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -34,8 +34,6 @@ static int ip_ttl_min =3D 1;
 static int ip_ttl_max =3D 255;
 static int tcp_syn_retries_min =3D 1;
 static int tcp_syn_retries_max =3D MAX_TCP_SYNCNT;
-static int ip_ping_group_range_min[] =3D { 0, 0 };
-static int ip_ping_group_range_max[] =3D { GID_T_MAX, GID_T_MAX };
 static u32 u32_max_div_HZ =3D UINT_MAX / HZ;
 static int one_day_secs =3D 24 * 3600;
 static u32 fib_multipath_hash_fields_all_mask __maybe_unused =3D
@@ -133,66 +131,20 @@ static int ipv4_privileged_ports(struct ctl_table *tabl=
e, int write,
 	return ret;
 }
=20
-static void inet_get_ping_group_range_table(struct ctl_table *table, kgid_t =
*low, kgid_t *high)
+static struct group_range *ipv4_ping_group_range_func(struct ctl_table *tabl=
e)
 {
-	kgid_t *data =3D table->data;
 	struct net *net =3D
 		container_of(table->data, struct net, ipv4.ping_group_range.range);
-	unsigned int seq;
-	do {
-		seq =3D read_seqbegin(&net->ipv4.ping_group_range.lock);
=20
-		*low =3D data[0];
-		*high =3D data[1];
-	} while (read_seqretry(&net->ipv4.ping_group_range.lock, seq));
-}
-
-/* Update system visible IP port range */
-static void set_ping_group_range(struct ctl_table *table, kgid_t low, kgid_t=
 high)
-{
-	kgid_t *data =3D table->data;
-	struct net *net =3D
-		container_of(table->data, struct net, ipv4.ping_group_range.range);
-	write_seqlock(&net->ipv4.ping_group_range.lock);
-	data[0] =3D low;
-	data[1] =3D high;
-	write_sequnlock(&net->ipv4.ping_group_range.lock);
+	return &net->ipv4.ping_group_range;
 }
=20
 /* Validate changes from /proc interface. */
 static int ipv4_ping_group_range(struct ctl_table *table, int write,
 				 void *buffer, size_t *lenp, loff_t *ppos)
 {
-	struct user_namespace *user_ns =3D current_user_ns();
-	int ret;
-	gid_t urange[2];
-	kgid_t low, high;
-	struct ctl_table tmp =3D {
-		.data =3D &urange,
-		.maxlen =3D sizeof(urange),
-		.mode =3D table->mode,
-		.extra1 =3D &ip_ping_group_range_min,
-		.extra2 =3D &ip_ping_group_range_max,
-	};
-
-	inet_get_ping_group_range_table(table, &low, &high);
-	urange[0] =3D from_kgid_munged(user_ns, low);
-	urange[1] =3D from_kgid_munged(user_ns, high);
-	ret =3D proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
-
-	if (write && ret =3D=3D 0) {
-		low =3D make_kgid(user_ns, urange[0]);
-		high =3D make_kgid(user_ns, urange[1]);
-		if (!gid_valid(low) || !gid_valid(high))
-			return -EINVAL;
-		if (urange[1] < urange[0] || gid_lt(high, low)) {
-			low =3D make_kgid(&init_user_ns, 1);
-			high =3D make_kgid(&init_user_ns, 0);
-		}
-		set_ping_group_range(table, low, high);
-	}
-
-	return ret;
+	return sysctl_group_range(ipv4_ping_group_range_func, table,
+		write, buffer, lenp, ppos);
 }
=20
 static int ipv4_fwd_update_priority(struct ctl_table *table, int write,
--=20
2.38.4

