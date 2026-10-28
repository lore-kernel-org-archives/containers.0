Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.69
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793225899;
	b=xdMQjQlktBDCQ7wMWPdnQEi5vrtUmiOrXa7sfO/eVZY0q0y/X8PwkIDevs8Tj6ayS/qz
	 aodLHMA/ctUCZy4htBb7q4sz/OkD+/TIRU2dwaBCD93aXEBeNYFQkEU6sPqsAudPe13Bl
	 dfzZttt1KQMkrSfc52k5XCYbsJ/w4kBn5scXdKfZQJWojb33aEkAho2UwnR8MIj2CMKnX
	 dxSVpIgSW6fpJSR6xd3DBbP6TRWtOgjedrBLo1lQY5xw/DkOMyAlf1CPL1sKipyfj46kJ
	 iYv/g4KU6d6vbOCw+zke2msCULPZjmLGy7zYzgQ4pzZLy/j/esPp3Zj9ZC8WQ+mHdFw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793225899;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=I/ZYYIcrC5oBnGUKKa5wL3lWDWpXYu+7qOwpTlnRuRw=;
	b=5pdrjIeUFYxnCCW6aEmQj9w0ar4kEIo5r0X43lSxmFb00kvu6ASQT9bXF9BPCgE0opKr
	 vOk3jId+Agjy2GvtLWWresl++XodhkP8P3E9h9sghQ/8afD8qAaHrLvsInb85Nl7Ot6Jc
	 4czDPmscRVbzztxQO9G3zQZGBeSaI9PlQ143RNfRodFaFGkJ7MdCpXa4X2TH1UVuCkQ2P
	 2+oltsOYdiG7f8JfhRauAGc+Uu94/6n0l8Uf5xlG78HHheRvdajw9ITF8vK6j2dNsfZfx
	 MMSfuz+n9HQjQdfhSnrNTXxNuMGCBEsX8mGRz28HTeCr4inkiyQt7+um7X9TJOOIAFA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--halg.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=YcOhmdSb;
	arc=none smtp.remote-ip=209.85.208.69
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 854D660A2612
	for <containers@lists.linux.dev>; Wed, 28 Oct 2026 22:18:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 854D660A2612
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--halg.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=YcOhmdSb
Received: by mail-ed1-f69.google.com with SMTP id 4fb4d7f45d1cf-6b1e00100eeso1975118a12.3
        for <containers@lists.linux.dev>; Wed, 28 Oct 2026 15:18:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1793225894; x=1793830694; darn=lists.linux.dev;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=I/ZYYIcrC5oBnGUKKa5wL3lWDWpXYu+7qOwpTlnRuRw=;
        b=YcOhmdSbqmG/IbN5QVvTt3cupKAbZayRmBumYPiL6fMUD8pNwg3EQYSA0XH+dsrE9e
         hX/GNwFBnyFK9BxhbeYlX+YHhfDDpURoaAO2IuVM/MH85lhs5GSaM7FRQtnol/VmKB0L
         jI8hAxomOBGsGh7ZuDdpeR0noTrJbQtZ2gqrRxU7g8YP3ai4z6/ojRfjm34I429RAbtB
         EdPjxC8ZQngzY1THSDVEbWcsYM5lALBXyfB+BjP8o6lMqAZT0n5Gu6EAFEhcb3GPvgP5
         ttg1Rz1bfJ2DyXGSvXE6l5xIkWv6eUJX9726uUKs71dC/8F4vjnIBrc/1NGAle1UtlPf
         agQA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793225894; x=1793830694;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=I/ZYYIcrC5oBnGUKKa5wL3lWDWpXYu+7qOwpTlnRuRw=;
        b=hCQ7OsChN47tFHTtwR2e7dU0bDoX5aoIteFEVUJ3Ljj+Jjbu1b8S8zozcXDADqn6Fv
         8O/HmPSf8lRwsmtdEIj22Sa6clJmrh8PgVUGm34Er4lx6UAalG6XY2inCkkAyODC7uoM
         3k3puO+1sn15NxYJ+zM3aQ3QTb10tJ67YaKHQ/RJOIVhawd6S1saouPhhvkLxyOEMpbR
         QwQZqAvVLtnw2WB+AHFpqhECd6PLMyH+A/WxpiOLgxL6Fvn7SLvKLFADomqEtew06eza
         o+SkvKkJyndTlxcj8y30qazXAYyZukWQlPjJR9c3fktsiZe5i6vp/Bd6l68jku59A/9L
         3FUA==
X-Forwarded-Encrypted: i=1; AKwUvBxOJEW0R4sJG5AkyaUve+25ykBA/yq83lJaXTGNMdSyQ/7yDRCXlN3CIlAo26sccLywsOZ6JpThgPwX@lists.linux.dev
X-Gm-Message-State: AFq9FYLXDuZBNrIj+6G76LXMVcJtmdkPOG2g9qD2DefcstE8jiUz/M27
	3mt5rAEc7MJck14AfzTp+YEIfxFc3ntHd0gdlkuP2Naq3mz/9JcMaJ0VKf9MGd5cpCiTvQWi0g=
	=
X-Received: from edtu10.prod.google.com ([2002:aa7:db8a:0:b0:6b4:92f8:2825])
 (user=halg job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6402:1945:b0:6ac:73f8:2e4f
 with SMTP id 4fb4d7f45d1cf-6b49cb7d69amr2368103a12.29.1793225893694; Wed, 28
 Oct 2026 15:18:13 -0700 (PDT)
Date: Wed, 28 Oct 2026 22:17:00 +0000
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
Message-ID: <20261028221705.3915340-4-halg@google.com>
Subject: [PATCH 3/8] userns: allow restricting capability bounding set via clone3()
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

While the unprivileged_userns_caps_allowed sysctl enforces a
system-wide capability ceiling for unprivileged users, the
clone3() support allows sandboxes and container runtimes to
voluntarily restrict the capability bounding set of a new user
namespace on a per-namespace basis.

Introduce the CLONE_NEWUSER_BSET flag and add a cap_bset field
to struct clone_args (CLONE_ARGS_SIZE_VER3). When specified alongside
CLONE_NEWUSER, the new user namespace's capability bounding set is
intersected with cap_bset in addition to the parent namespace's
bounding set and any applicable unprivileged sysctl ceiling.

Signed-off-by: Hallgrimur H. Gunnarsson <halg@google.com>
---
 Documentation/admin-guide/sysctl/kernel.rst |  5 +++++
 include/linux/cred.h                        |  3 ++-
 include/linux/sched/task.h                  |  1 +
 include/linux/user_namespace.h              |  4 ++--
 include/uapi/linux/sched.h                  |  7 +++++++
 kernel/cred.c                               | 10 ++++++++--
 kernel/fork.c                               | 18 +++++++++++++++---
 kernel/user_namespace.c                     | 11 +++++++----
 8 files changed, 47 insertions(+), 12 deletions(-)

diff --git a/Documentation/admin-guide/sysctl/kernel.rst b/Documentation/admin-guide/sysctl/kernel.rst
index 25fe46e7724b..4b6654e89c6d 100644
--- a/Documentation/admin-guide/sysctl/kernel.rst
+++ b/Documentation/admin-guide/sysctl/kernel.rst
@@ -1709,6 +1709,11 @@ Privileged creators (holding ``CAP_SYS_ADMIN`` in the parent namespace) are
 unaffected by this ceiling and inherit the parent namespace's bounding set
 unmodified.
 
+Regardless of privilege level, a creator using ``clone3(2)`` with the
+``CLONE_NEWUSER_BSET`` flag can further restrict the new namespace's
+bounding set by specifying a ``cap_bset`` mask in ``struct clone_args``,
+which is intersected with the resulting bounding set.
+
 Upon entering a user namespace during creation or via ``setns(2)``,
 the task's permitted, effective, and bounding capability sets are clamped
 to the namespace's bounding set. Tasks inside the namespace cannot exceed
diff --git a/include/linux/cred.h b/include/linux/cred.h
index 6ef1750c93e2..39eeb1584ef7 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -19,6 +19,7 @@
 
 struct cred;
 struct inode;
+struct kernel_clone_args;
 
 extern struct task_struct init_task;
 
@@ -150,9 +151,9 @@ struct cred {
 	};
 } __randomize_layout;
 
+int copy_creds(struct task_struct *p, const struct kernel_clone_args *kargs);
 extern void __put_cred(struct cred *);
 extern void exit_creds(struct task_struct *);
-extern int copy_creds(struct task_struct *, u64);
 extern const struct cred *get_task_cred(struct task_struct *);
 extern struct cred *cred_alloc_blank(void);
 extern struct cred *prepare_creds(void);
diff --git a/include/linux/sched/task.h b/include/linux/sched/task.h
index e0c1ca8c6a18..498db7adce5f 100644
--- a/include/linux/sched/task.h
+++ b/include/linux/sched/task.h
@@ -45,6 +45,7 @@ struct kernel_clone_args {
 	struct cgroup *cgrp;
 	struct css_set *cset;
 	unsigned int kill_seq;
+	u64 cap_bset;
 };
 
 /*
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index a0ccfb93f2a7..a584ee5775af 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -194,7 +194,7 @@ static inline bool userns_has_cap(const struct user_namespace *ns, int cap)
 	return cap_raised(ns->cap_bset, cap);
 }
 
-extern int create_user_ns(struct cred *new);
+int create_user_ns(struct cred *new, kernel_cap_t req_bset);
 extern int unshare_userns(unsigned long unshare_flags, struct cred **new_cred);
 extern void __put_user_ns(struct user_namespace *ns);
 
@@ -230,7 +230,7 @@ static inline bool userns_has_cap(const struct user_namespace *ns, int cap)
 	return true;
 }
 
-static inline int create_user_ns(struct cred *new)
+static inline int create_user_ns(struct cred *new, kernel_cap_t req_bset)
 {
 	return -EINVAL;
 }
diff --git a/include/uapi/linux/sched.h b/include/uapi/linux/sched.h
index efd00d9f8bd3..10e4a4733005 100644
--- a/include/uapi/linux/sched.h
+++ b/include/uapi/linux/sched.h
@@ -41,6 +41,7 @@
 #define CLONE_PIDFD_AUTOKILL	(1ULL << 36) /* Kill child when clone pidfd closes. */
 #define CLONE_EMPTY_MNTNS	(1ULL << 37) /* Create an empty mount namespace. */
 #define CLONE_NEWNET_LOOPBACK	(1ULL << 38) /* Create network namespace with loopback UP. */
+#define CLONE_NEWUSER_BSET	(1ULL << 39) /* Set userns capability bounding set. */
 
 /*
  * cloning flags intersect with CSIGNAL so can be used with unshare and clone3
@@ -96,6 +97,10 @@
  *                kernel's limit of nested PID namespaces.
  * @cgroup:       If CLONE_INTO_CGROUP is specified set this to
  *                a file descriptor for the cgroup.
+ * @cap_bset:     If CLONE_NEWUSER_BSET is specified, this
+ *                specifies the capability bounding set mask to
+ *                apply to the new user namespace. Unknown
+ *                capability bits (> CAP_LAST_CAP) are ignored.
  *
  * The structure is versioned by size and thus extensible.
  * New struct members must go at the end of the struct and
@@ -113,12 +118,14 @@ struct clone_args {
 	__aligned_u64 set_tid;
 	__aligned_u64 set_tid_size;
 	__aligned_u64 cgroup;
+	__aligned_u64 cap_bset;
 };
 #endif
 
 #define CLONE_ARGS_SIZE_VER0 64 /* sizeof first published struct */
 #define CLONE_ARGS_SIZE_VER1 80 /* sizeof second published struct */
 #define CLONE_ARGS_SIZE_VER2 88 /* sizeof third published struct */
+#define CLONE_ARGS_SIZE_VER3 96 /* sizeof fourth published struct */
 
 /*
  * Scheduling policies
diff --git a/kernel/cred.c b/kernel/cred.c
index 3df4e15bd67f..20f37a351602 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -260,8 +260,9 @@ struct cred *prepare_exec_creds(void)
  * The new process gets the current process's subjective credentials as its
  * objective and subjective credentials
  */
-int copy_creds(struct task_struct *p, u64 clone_flags)
+int copy_creds(struct task_struct *p, const struct kernel_clone_args *kargs)
 {
+	u64 clone_flags = kargs->flags;
 	struct cred *new;
 	int ret;
 
@@ -288,7 +289,12 @@ int copy_creds(struct task_struct *p, u64 clone_flags)
 		return -ENOMEM;
 
 	if (clone_flags & CLONE_NEWUSER) {
-		ret = create_user_ns(new);
+		kernel_cap_t cap_bset = CAP_FULL_SET;
+
+		if (clone_flags & CLONE_NEWUSER_BSET)
+			cap_bset = (kernel_cap_t){ .val = kargs->cap_bset };
+
+		ret = create_user_ns(new, cap_bset);
 		if (ret < 0)
 			goto error_put;
 		ret = set_cred_ucounts(new);
diff --git a/kernel/fork.c b/kernel/fork.c
index c0f7520e754a..a09f62cadeac 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -2168,7 +2168,7 @@ __latent_entropy struct task_struct *copy_process(
 #ifdef CONFIG_PROVE_LOCKING
 	DEBUG_LOCKS_WARN_ON(!p->softirqs_enabled);
 #endif
-	retval = copy_creds(p, clone_flags);
+	retval = copy_creds(p, args);
 	if (retval < 0)
 		goto bad_fork_free;
 
@@ -2932,7 +2932,9 @@ static noinline int copy_clone_args_from_user(struct kernel_clone_args *kargs,
 		     CLONE_ARGS_SIZE_VER1);
 	BUILD_BUG_ON(offsetofend(struct clone_args, cgroup) !=
 		     CLONE_ARGS_SIZE_VER2);
-	BUILD_BUG_ON(sizeof(struct clone_args) != CLONE_ARGS_SIZE_VER2);
+	BUILD_BUG_ON(offsetofend(struct clone_args, cap_bset) !=
+		     CLONE_ARGS_SIZE_VER3);
+	BUILD_BUG_ON(sizeof(struct clone_args) != CLONE_ARGS_SIZE_VER3);
 
 	if (unlikely(usize > PAGE_SIZE))
 		return -E2BIG;
@@ -2962,6 +2964,11 @@ static noinline int copy_clone_args_from_user(struct kernel_clone_args *kargs,
 	    (args.cgroup > INT_MAX || usize < CLONE_ARGS_SIZE_VER2))
 		return -EINVAL;
 
+	if ((args.flags & CLONE_NEWUSER_BSET) && usize < CLONE_ARGS_SIZE_VER3)
+		return -EINVAL;
+	if (!(args.flags & CLONE_NEWUSER_BSET) && args.cap_bset)
+		return -EINVAL;
+
 	*kargs = (struct kernel_clone_args){
 		.flags		= args.flags,
 		.pidfd		= u64_to_user_ptr(args.pidfd),
@@ -2973,6 +2980,7 @@ static noinline int copy_clone_args_from_user(struct kernel_clone_args *kargs,
 		.tls		= args.tls,
 		.set_tid_size	= args.set_tid_size,
 		.cgroup		= args.cgroup,
+		.cap_bset	= args.cap_bset & CAP_VALID_MASK,
 	};
 
 	if (args.set_tid &&
@@ -3020,7 +3028,7 @@ static bool clone3_args_valid(struct kernel_clone_args *kargs)
 	    ~(CLONE_LEGACY_FLAGS | CLONE_CLEAR_SIGHAND |
 	      CLONE_INTO_CGROUP | CLONE_AUTOREAP | CLONE_NNP |
 	      CLONE_PIDFD_AUTOKILL | CLONE_EMPTY_MNTNS |
-	      CLONE_NEWNET_LOOPBACK))
+	      CLONE_NEWNET_LOOPBACK | CLONE_NEWUSER_BSET))
 		return false;
 
 	/*
@@ -3038,6 +3046,10 @@ static bool clone3_args_valid(struct kernel_clone_args *kargs)
 	    kargs->exit_signal)
 		return false;
 
+	if ((kargs->flags & CLONE_NEWUSER_BSET) &&
+	    !(kargs->flags & CLONE_NEWUSER))
+		return false;
+
 	if (!clone3_stack_valid(kargs))
 		return false;
 
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 92f489e268a8..6e95dd1a1d04 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -143,7 +143,7 @@ static unsigned long enforced_nproc_rlimit(void)
  * This is called by copy_creds(), which will finish setting the target task's
  * credentials.
  */
-int create_user_ns(struct cred *new)
+int create_user_ns(struct cred *new, kernel_cap_t req_bset)
 {
 	struct user_namespace *ns, *parent_ns = new->user_ns;
 	kuid_t owner = new->euid;
@@ -184,15 +184,18 @@ int create_user_ns(struct cred *new)
 		goto fail_dec;
 
 	/*
+	 * Intersect the parent's bounding set with any voluntary
+	 * restrictions requested via clone3().
+	 *
 	 * If the caller has CAP_SYS_ADMIN in the parent namespace,
-	 * they are a privileged creator and inherit the parent's
+	 * they are a privileged creator and inherit this resulting
 	 * bounding set directly.
 	 *
 	 * Otherwise, enforce the unprivileged bounding ceiling, but
 	 * allow the child namespace to retain any capabilities the
 	 * creator already holds.
 	 */
-	cap_bset = parent_ns->cap_bset;
+	cap_bset = cap_intersect(parent_ns->cap_bset, req_bset);
 	if (!ns_capable_noaudit(parent_ns, CAP_SYS_ADMIN)) {
 		kernel_cap_t unpriv_bset = READ_ONCE(sysctl_unpriv_userns_bset);
 		kernel_cap_t allowed = cap_combine(unpriv_bset,
@@ -267,7 +270,7 @@ int unshare_userns(unsigned long unshare_flags, struct cred **new_cred)
 
 	cred = prepare_creds();
 	if (cred) {
-		err = create_user_ns(cred);
+		err = create_user_ns(cred, CAP_FULL_SET);
 		if (err)
 			put_cred(cred);
 		else
-- 
2.56.0.313.g2479322e68-goog

