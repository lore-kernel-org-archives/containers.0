Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.71
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793225895;
	b=H/WNrvU+IntV5DarTR3SosOXrFCAQO+PjghgO+8jxr0ojwAeYwOS/VNd7b51Hn8JkuwW
	 /VqMZKefJBxcJfJjP97EblRQ9zmfCUL/GGLtaureTsli6IFh/FgRNl8cxO6rs1eQT2JFC
	 i8RxTwxABKVlUIgi7KCw9+SBSE2i7IKA+ot9RyTeiwBMI35eyncAlXqfdyVd7WSaSBBwI
	 3VoHhiQc5BvT18rgr/qotMHpwMlD0aFthHmMigxIiTU954/V3xGSosvsDws+NUXZrVRfL
	 /VAxrsgVmQ35vbpKVkIs+e6EC6py6ztxwMlE/Koeq3VPmKd6Aa1V+xZ8wyp2jVCwMMw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793225895;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=65gkrwysKwp4zEIPD1eJcpPuoQ0vzx+YLkBbHQtjT6w=;
	b=tdQvIBxo/AN/pU3A6Bv03Te+K5mi3ZNdUC9hMVX4xD17xSLIN1VT4VCJ5yJQlwBLARsL
	 PAYWCR1Tcpv6CmH6wc+LflRP8M5n1uPJBcgOfoBjR3+/K7k/CfwyVFvvWkEZalsdarTxT
	 lr2PBFEhkxTBSqorGWdt7OmiR4y0MR7904gN3Vbjm1r8XA56ZRXqu94ry+ohjS4R30oyw
	 euv/27TTbwrN4t1LNG23/I5Ityw94dZ4zrtbGynjEwyXSbAmUdgOAO0ZE3IKpiseyUU/D
	 D4oi0sOMQsvv2ZPshJq5LGS7GtmgzkjqgHS/comujGPC2llyvBxucoOFzcPi3tZWyyw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--halg.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=gEioJ44x;
	arc=none smtp.remote-ip=209.85.218.71
Received: from mail-ej1-f71.google.com (mail-ej1-f71.google.com [209.85.218.71])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD0E7606A33E
	for <containers@lists.linux.dev>; Wed, 28 Oct 2026 22:18:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AD0E7606A33E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--halg.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=gEioJ44x
Received: by mail-ej1-f71.google.com with SMTP id a640c23a62f3a-c498fa2d96cso124099866b.1
        for <containers@lists.linux.dev>; Wed, 28 Oct 2026 15:18:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1793225893; x=1793830693; darn=lists.linux.dev;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=65gkrwysKwp4zEIPD1eJcpPuoQ0vzx+YLkBbHQtjT6w=;
        b=gEioJ44x4fTCaOXtiwlNXhdiusFiZmYPr30jtgDtMTwLk4q9MghTNYhsLW37x5JDbG
         E1BHBXWQU3v8d0xPbSoznpWT1/pIRVug5sEf9lkmhH4TmNyy+SPsUlwQbngR0bTKkk7t
         eQedEo1fpU/Bsl5KxQJTQC9gvrFb7xRilLPO98u16MeYi4cmiz1XJ/6jF1+aCkxwVgWZ
         5V8ToG+IVjuHlcPrw2koqrYAgn+P4ChR9XrklW80u/xMwjqXE4H1TUtUSR07AdUYpXGj
         DymzBHox+bfqO04S0YNMBHOzjohTvCYI/c5xDuiQ16Ci4rvdgVgcj7uccofKdBqCCuIu
         auGw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793225893; x=1793830693;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=65gkrwysKwp4zEIPD1eJcpPuoQ0vzx+YLkBbHQtjT6w=;
        b=j6aH6Th86JiasWLfEgipk6njDpd/5xwft0h2ZLDWn2OoV3ccn1tyNnXbbF0KPva5a+
         JuZLUn7PPSzh/CyNGgZ602uoDEux0PFJJ8X75RyjLG7bwocL7J+VIGKz2CD8ueYkMHRZ
         seGM4A5ZtmsaO4AdpDX+zqNeSIMRCXeuzGcjpHZGm/QwK9IBtedvsXFRaPpKGZ+KLbUC
         lcFTGTZ+KFNOTSZg2aLZImZwtpLCY5fZMMRDngBcemk3qn66R07iqQY/RkERQnkerxcU
         k9/NVQQbnIkwJ6oG/7ON2b9Bzv88+gjhROVVp3uDhq64lfpSR06G+K+ypomcqvX6YSoE
         rYDA==
X-Forwarded-Encrypted: i=1; AKwUvBwXa6zWFZf6Juj7Mq3HR5USLUrlIl/J2vaVQEuUqWyWX+sLtRPtlYqbJti8S5i8TGZNdLVXDMY66i0P@lists.linux.dev
X-Gm-Message-State: AFq9FYLl1LZWEnzO/bZycpRLahxrtte/mGXgAHzViCXpXEKbyWTtXC/G
	vxfWGsJ55i1SaZxmOsnNQrVi+TFXRzoQVB9tFP81iICCTgiDfL8UHXebqoncRZm62bXiRW+gAA=
	=
X-Received: from ejdg4.prod.google.com ([2002:a17:906:1984:b0:c34:bf66:6f39])
 (user=halg job=prod-delivery.src-stubby-dispatcher) by 2002:a17:907:6d04:b0:c42:24ea:3227
 with SMTP id a640c23a62f3a-c49bdf5c677mr291588666b.31.1793225892705; Wed, 28
 Oct 2026 15:18:12 -0700 (PDT)
Date: Wed, 28 Oct 2026 22:16:59 +0000
In-Reply-To: <20261028221705.3915340-1-halg@google.com>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Post: <mailto:containers@lists.linux.dev>
List-Help: <mailto:containers+help@lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
List-Owner: <mailto:containers+owner@lists.linux.dev>
Precedence: list
Mime-Version: 1.0
References: <20261028221705.3915340-1-halg@google.com>
X-Mailer: git-send-email 2.56.0.313.g2479322e68-goog
Message-ID: <20261028221705.3915340-3-halg@google.com>
Subject: [PATCH 2/8] userns: introduce capability bounding set for user namespaces
From: "Hallgrimur H. Gunnarsson" <halg@google.com>
To: Christian Brauner <brauner@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Paul Moore <paul@paul-moore.com>, Serge Hallyn <sergeh@kernel.org>, Kees Cook <kees@kernel.org>, 
	"David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>
Cc: Jan Kara <jack@suse.cz>, James Morris <jmorris@namei.org>, Simon Horman <horms@kernel.org>, 
	Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	"=?UTF-8?q?G=C3=BCnther=20Noack?=" <gnoack@google.com>, KP Singh <kpsingh@kernel.org>, 
	Jonathan Calmels <jcalmels@3xx0.net>, Casey Schaufler <casey@schaufler-ca.com>, 
	linux-fsdevel@vger.kernel.org, linux-security-module@vger.kernel.org, 
	linux-api@vger.kernel.org, containers@lists.linux.dev, netdev@vger.kernel.org, 
	linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-kernel@vger.kernel.org, "Hallgrimur H. Gunnarsson" <halg@google.com>
Content-Type: text/plain; charset="UTF-8"

When an unprivileged process creates a new user namespace, it receives
a full set of capabilities scoped to that new namespace.

While these capabilities are isolated to the namespace, they allow
unprivileged tasks to interact with deep kernel code (like networking
logic) that historically assumed only a fully trusted root user could
access them. Depending on the workload, administrators may not always
want or need to grant every capability to unprivileged namespaces.

To provide administrators with flexible policy control over what
privileges are permitted by default, introduce a per-user-namespace
capability bounding set (cap_bset) and a global sysctl ceiling knob at:
    /proc/sys/kernel/unprivileged_userns_caps_allowed

When a new user namespace is created, it inherits the capability
bounding set of its parent namespace. For an unprivileged creator (i.e.
a task lacking CAP_SYS_ADMIN in the parent namespace), the child
namespace's bounding set is constrained by intersecting the parent's
bounding set with the sysctl ceiling combined with any effective
capabilities the creator already holds:
    child_bset = parent_bset & (sysctl_ceiling | creator_effective)

Capability bounding sets decrease monotonically down the namespace
hierarchy, ensuring child namespaces can never exceed the capabilities
of their ancestors.

Upon entering a user namespace during creation or via setns, the task's
permitted, effective, and bounding capability sets are clamped to the
namespace's bounding set. Furthermore, cap_capable_helper() is updated
so that implicit capabilities granted to parent-namespace owners over
child namespaces are strictly bounded by the owned namespace's
cap_bset.

The sysctl defaults to CAP_FULL_SET, preserving baseline backwards
compatibility and existing behavior unless an administrator explicitly
configures a restricted ceiling.

Signed-off-by: Hallgrimur H. Gunnarsson <halg@google.com>
---
 Documentation/admin-guide/sysctl/kernel.rst | 32 +++++++
 include/linux/user_namespace.h              | 16 ++++
 kernel/user.c                               |  1 +
 kernel/user_namespace.c                     | 93 +++++++++++++++++++--
 security/commoncap.c                        |  8 +-
 5 files changed, 142 insertions(+), 8 deletions(-)

diff --git a/Documentation/admin-guide/sysctl/kernel.rst b/Documentation/admin-guide/sysctl/kernel.rst
index b6328cd0f43e..25fe46e7724b 100644
--- a/Documentation/admin-guide/sysctl/kernel.rst
+++ b/Documentation/admin-guide/sysctl/kernel.rst
@@ -1690,6 +1690,38 @@ entry will default to 2 instead of 0.
 = =============================================================
 
 
+unprivileged_userns_caps_allowed
+================================
+
+This file contains a hexadecimal bitmask representing the capability bounding
+ceiling enforced on unprivileged user namespace creation. Instead of granting
+full capabilities upon namespace creation, this ceiling can be used to
+configure which capabilities are permitted.
+
+When an unprivileged task (a task lacking ``CAP_SYS_ADMIN`` in its parent user
+namespace) creates a new user namespace, the capability bounding set of the
+new namespace is intersected with the union of this mask and the creator's
+effective capabilities in the parent namespace:
+
+  child_bset = parent_bset & (sysctl_ceiling | creator_effective)
+
+Privileged creators (holding ``CAP_SYS_ADMIN`` in the parent namespace) are
+unaffected by this ceiling and inherit the parent namespace's bounding set
+unmodified.
+
+Upon entering a user namespace during creation or via ``setns(2)``,
+the task's permitted, effective, and bounding capability sets are clamped
+to the namespace's bounding set. Tasks inside the namespace cannot exceed
+this ceiling, even when executing setuid binaries or binaries with file
+capabilities.
+
+Unknown capability bits (above ``CAP_LAST_CAP``) are ignored and masked
+off when writing to this file.
+
+* Default: ``CAP_FULL_SET`` (all capabilities permitted)
+* Privilege required to modify: ``CAP_SETPCAP`` in the initial user namespace.
+
+
 warn_limit
 ==========
 
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index e38d9e60569f..a0ccfb93f2a7 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -3,6 +3,7 @@
 #define _LINUX_USER_NAMESPACE_H
 
 #include <linux/kref.h>
+#include <linux/capability.h>
 #include <linux/nsproxy.h>
 #include <linux/ns_common.h>
 #include <linux/rculist_nulls.h>
@@ -89,6 +90,11 @@ struct user_namespace {
 	/* parent_could_setfcap: true if the creator if this ns had CAP_SETFCAP
 	 * in its effective capability set at the child ns creation time. */
 	bool			parent_could_setfcap;
+	/*
+	 * Capability bounding set for tasks inside the namespace and for owner
+	 * tasks in the parent namespace.
+	 */
+	kernel_cap_t		cap_bset;
 
 #ifdef CONFIG_KEYS
 	/* List of joinable keyrings in this namespace.  Modification access of
@@ -183,6 +189,11 @@ static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 	return ns;
 }
 
+static inline bool userns_has_cap(const struct user_namespace *ns, int cap)
+{
+	return cap_raised(ns->cap_bset, cap);
+}
+
 extern int create_user_ns(struct cred *new);
 extern int unshare_userns(unsigned long unshare_flags, struct cred **new_cred);
 extern void __put_user_ns(struct user_namespace *ns);
@@ -214,6 +225,11 @@ static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
 	return &init_user_ns;
 }
 
+static inline bool userns_has_cap(const struct user_namespace *ns, int cap)
+{
+	return true;
+}
+
 static inline int create_user_ns(struct cred *new)
 {
 	return -EINVAL;
diff --git a/kernel/user.c b/kernel/user.c
index 21bafdc11379..78f4c5e45dcc 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -69,6 +69,7 @@ struct user_namespace init_user_ns = {
 	.owner = GLOBAL_ROOT_UID,
 	.group = GLOBAL_ROOT_GID,
 	.flags = USERNS_INIT_FLAGS,
+	.cap_bset = CAP_FULL_SET,
 #ifdef CONFIG_KEYS
 	.keyring_name_list = LIST_HEAD_INIT(init_user_ns.keyring_name_list),
 	.keyring_sem = __RWSEM_INITIALIZER(init_user_ns.keyring_sem),
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 0bed462e9b2a..92f489e268a8 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -3,6 +3,9 @@
 #include <linux/export.h>
 #include <linux/nsproxy.h>
 #include <linux/slab.h>
+#include <linux/capability.h>
+#include <linux/string.h>
+#include <linux/sysctl.h>
 #include <linux/sched/signal.h>
 #include <linux/user_namespace.h>
 #include <linux/proc_ns.h>
@@ -41,17 +44,77 @@ static void dec_user_namespaces(struct ucounts *ucounts)
 	return dec_ucount(ucounts, UCOUNT_USER_NAMESPACES);
 }
 
+static kernel_cap_t sysctl_unpriv_userns_bset = CAP_FULL_SET;
+
+static int unpriv_userns_bset_handler(const struct ctl_table *table,
+				      int write, void *buffer,
+				      size_t *lenp, loff_t *ppos)
+{
+	struct ctl_table tmp_table = *table;
+	char buf[32] = {};
+	unsigned long long val;
+	char *s;
+	int ret;
+
+	if (!*lenp)
+		return 0;
+	if (write && *ppos)
+		return -EINVAL;
+	if (write && !capable(CAP_SETPCAP))
+		return -EPERM;
+
+	if (!write) {
+		kernel_cap_t unpriv_bset = READ_ONCE(sysctl_unpriv_userns_bset);
+
+		snprintf(buf, sizeof(buf), "%016llx", unpriv_bset.val);
+	}
+
+	tmp_table.data = buf;
+	tmp_table.maxlen = sizeof(buf);
+
+	ret = proc_dostring(&tmp_table, write, buffer, lenp, ppos);
+	if (ret || !write)
+		return ret;
+
+	s = strim(buf);
+	ret = kstrtoull(s, 16, &val);
+	if (ret)
+		return ret;
+
+	val &= CAP_VALID_MASK;
+	WRITE_ONCE(sysctl_unpriv_userns_bset, (kernel_cap_t){ .val = val });
+	return 0;
+}
+
+static const struct ctl_table user_namespace_sysctls[] = {
+	{
+		.procname	= "unprivileged_userns_caps_allowed",
+		.mode		= 0644,
+		.proc_handler	= unpriv_userns_bset_handler,
+	},
+};
+
+static int __init init_user_ns_sysctls(void)
+{
+	register_sysctl_init("kernel", user_namespace_sysctls);
+	return 0;
+}
+subsys_initcall(init_user_ns_sysctls);
+
 static void set_cred_user_ns(struct cred *cred, struct user_namespace *user_ns)
 {
-	/* Start with the same capabilities as init but useless for doing
-	 * anything as the capabilities are bound to the new user namespace.
+	/*
+	 * Tasks inside the user namespace start with (and are permanently
+	 * bounded by) the capabilities permitted by the user namespace
+	 * capability ceiling. The capabilities are scoped to the new user
+	 * namespace.
 	 */
 	cred->securebits = SECUREBITS_DEFAULT;
+	cred->cap_bset = user_ns->cap_bset;
+	cred->cap_permitted = user_ns->cap_bset;
+	cred->cap_effective = user_ns->cap_bset;
 	cred->cap_inheritable = CAP_EMPTY_SET;
-	cred->cap_permitted = CAP_FULL_SET;
-	cred->cap_effective = CAP_FULL_SET;
 	cred->cap_ambient = CAP_EMPTY_SET;
-	cred->cap_bset = CAP_FULL_SET;
 #ifdef CONFIG_KEYS
 	key_put(cred->request_key_auth);
 	cred->request_key_auth = NULL;
@@ -86,6 +149,7 @@ int create_user_ns(struct cred *new)
 	kuid_t owner = new->euid;
 	kgid_t group = new->egid;
 	struct ucounts *ucounts;
+	kernel_cap_t cap_bset;
 	int ret, i;
 
 	ret = -ENOSPC;
@@ -119,6 +183,24 @@ int create_user_ns(struct cred *new)
 	if (ret < 0)
 		goto fail_dec;
 
+	/*
+	 * If the caller has CAP_SYS_ADMIN in the parent namespace,
+	 * they are a privileged creator and inherit the parent's
+	 * bounding set directly.
+	 *
+	 * Otherwise, enforce the unprivileged bounding ceiling, but
+	 * allow the child namespace to retain any capabilities the
+	 * creator already holds.
+	 */
+	cap_bset = parent_ns->cap_bset;
+	if (!ns_capable_noaudit(parent_ns, CAP_SYS_ADMIN)) {
+		kernel_cap_t unpriv_bset = READ_ONCE(sysctl_unpriv_userns_bset);
+		kernel_cap_t allowed = cap_combine(unpriv_bset,
+						   new->cap_effective);
+
+		cap_bset = cap_intersect(cap_bset, allowed);
+	}
+
 	ret = -ENOMEM;
 	ns = kmem_cache_zalloc(user_ns_cachep, GFP_KERNEL);
 	if (!ns)
@@ -144,6 +226,7 @@ int create_user_ns(struct cred *new)
 	set_userns_rlimit_max(ns, UCOUNT_RLIMIT_SIGPENDING, rlimit(RLIMIT_SIGPENDING));
 	set_userns_rlimit_max(ns, UCOUNT_RLIMIT_MEMLOCK, rlimit(RLIMIT_MEMLOCK));
 	ns->ucounts = ucounts;
+	ns->cap_bset = cap_bset;
 
 	/* Inherit USERNS_SETGROUPS_ALLOWED from our parent */
 	mutex_lock(&userns_state_mutex);
diff --git a/security/commoncap.c b/security/commoncap.c
index 3399535808fe..f153e7bad1ba 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -88,11 +88,13 @@ static inline int cap_capable_helper(const struct cred *cred,
 		if (ns->level <= cred_ns->level)
 			return -EPERM;
 
-		/* 
+		/*
 		 * The owner of the user namespace in the parent of the
-		 * user namespace has all caps.
+		 * user namespace has all caps, subject to the bounding
+		 * set of the owned user namespace.
 		 */
-		if ((ns->parent == cred_ns) && uid_eq(ns->owner, cred->euid))
+		if (ns->parent == cred_ns && uid_eq(ns->owner, cred->euid) &&
+		    userns_has_cap(ns, cap))
 			return 0;
 
 		/*
-- 
2.56.0.313.g2479322e68-goog

