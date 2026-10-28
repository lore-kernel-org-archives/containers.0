Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.71
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793225894;
	b=ILT4EV91GavPYpRBbVvkiO9RBdf4nyXLcRgNTHm4E564n8a0K8+k8btQI9ntmWsgDWth
	 1DSOOCKeVbwJ280DSJmor7xarjiry6qeOTCLYN0IzmZIj1x1A+xwgFaS1YeCFJUmK77iL
	 TyqIrvVZsbCSr6vn17oHmuDnLMQ7JBoGUNR7aQGr9r2odL9RoOyRKSViQaO7ZcWZ2NNcr
	 pyilULRDy6SWm/xIiQv0PTqHm+RDkXUNYWQ6c8qzViONe8WCJHee6jppyeQAUx6hq1i3B
	 vAWMAq7MmXPRKFj/KE62ETzAnJv7erOv7tRoR76Snen5FXrsWpvTl0I/NwYOCwBpshQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793225894;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=9FCa9rxR0w5Su0OT2TXTOp3Qrhv4gyecy+qhdi4ZgS0=;
	b=mueexjkPRmQh2bo+/TLhjhuqhHjIG9x+wJLu+N/1VR5zR4hTwyi5uHQzR8EMZacDZHf5
	 aFKmbelDKcoudb3WaLudmza39Scdp5Vgrj/+U0H/JlNICgpBgY+4HLfwNwLAybiPnD98T
	 KeseoJIPBpiYCDQHzsdRapBq4CmSV1Xxv7HZDIXYwkHfdgA5avuasKDOHveoni8sQ2x7D
	 6rl6KlpO+zwQEdmKG3xMIcV8AXhXOiSm/I4FEyrTCSzKonD14IfnlFUCbeIgQGla03zgi
	 zmsxVoPS5CeKir6RobK/MCP1CvWC7UgvFc4RFMBGusAYkvI2ws2TcG2Z9N7fr+bjnbA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--halg.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=ASShSkCs;
	arc=none smtp.remote-ip=209.85.208.71
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4A945606A32E
	for <containers@lists.linux.dev>; Wed, 28 Oct 2026 22:18:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4A945606A32E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--halg.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=ASShSkCs
Received: by mail-ed1-f71.google.com with SMTP id 4fb4d7f45d1cf-6b1bc2e62d5so1611397a12.2
        for <containers@lists.linux.dev>; Wed, 28 Oct 2026 15:18:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1793225892; x=1793830692; darn=lists.linux.dev;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=9FCa9rxR0w5Su0OT2TXTOp3Qrhv4gyecy+qhdi4ZgS0=;
        b=ASShSkCs7jsWszb043RayBfJ7OoJ8iTbkUn7FAGQgnqdipK4S7kerG5YINfcC1b2gR
         D38Uvti9ceg43wLytNJhW85Ec8lZWTCLJHh8MFsaGFG1pzuwq3AUAMdDrm3rncioBoc0
         HTRN5mmqf4hI+6J7gSqFdJLsdnfLRqMsPKqM5TX3Y4a9PHhXgFS43Tf4OtrAL4NCfNV9
         FVKlJT6VixSETxMWlMze9xNHd34Fyrxc1w5FSqNAad2S9IsooTrWfRx8jrj6ngtKzVq+
         pOp3cKXLhK7JaWwlO3YxqkAMiI/rocxz3A1UmHJlNeDDwTuOYOeAVExeIXtL10cH79Jb
         /qHw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793225892; x=1793830692;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=9FCa9rxR0w5Su0OT2TXTOp3Qrhv4gyecy+qhdi4ZgS0=;
        b=CWdPCpYELnK+L5LLcwJF845ouUUNg1eO71AFDR29s/cYYAmQiEEFFMDHnmA+BqI/QL
         1/cwS303k4OD833ePrSQtSlFlmiblgoiLpaSN7UoIEbCqIObP5ZQhungifjny2wsnW6G
         uFwqXWspKKEztsqkRzjSFUSmp+ggywuNc5bZ5WEjjqDo+qa0vQaQfbXkRmEGTo3gVvxp
         poXf1sdMyUrikJGP8xFN4LPE7hIqo5XkqDNyLsVNDlpG9dXQ2zmbu9c58cdd/4WmevYB
         2suAyfrMElhuQz18era9d8U59eLt5bdSmysoI+cGqC2yXjWMpoNbhC5tgaxdCnaWH3Vo
         L0Ew==
X-Forwarded-Encrypted: i=1; AKwUvBxtbX7UyFcndqPdyhe9/q6lDs97zmG22s7KQ5eOsQTUkmpo5tPIZVmMMtIYJm4MHRrvWvOZs9P8ABOf@lists.linux.dev
X-Gm-Message-State: AFq9FYKlvK/pO0P9zQ3BHCh82BLkAXuzMz8SDj2GRkohHMN/usdI2Sts
	HrjW7dnr34mYg+E5Tno0qRausLjGddsgGby9/cm8/vjCNr7OAp8qKU83+FvWhwwgGzNZtopO6w=
	=
X-Received: from edt14.prod.google.com ([2002:a05:6402:454e:b0:6b1:c2b6:cf0a])
 (user=halg job=prod-delivery.src-stubby-dispatcher) by 2002:aa7:cfd3:0:b0:6b4:2aa6:2c07
 with SMTP id 4fb4d7f45d1cf-6b49cbd8fa6mr2184624a12.14.1793225891454; Wed, 28
 Oct 2026 15:18:11 -0700 (PDT)
Date: Wed, 28 Oct 2026 22:16:58 +0000
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
Message-ID: <20261028221705.3915340-2-halg@google.com>
Subject: [PATCH 1/8] net: introduce CLONE_NEWNET_LOOPBACK to auto-enable loopback
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

New network namespaces start with the loopback interface DOWN by
default, requiring CAP_NET_ADMIN over the owning user namespace to
bring it up.

To block external network access while preserving the localhost
networking that many applications expect, sandboxes (such as bwrap,
nsjail and minijail) commonly create an isolated network namespace
with only the loopback interface enabled.

However, requiring a sandbox to hold CAP_NET_ADMIN in a new user
namespace solely to bring loopback up conflicts with reducing the
CAP_NET_ADMIN attack surface.

Today, an unprivileged sandbox or sandbox manager must start with
CAP_NET_ADMIN in its user namespace to be able to bring up loopback,
drop it, and then take precautions to block CAP_NET_ADMIN from being
regained in nested user namespaces (e.g. via seccomp or
max_user_namespaces limits). This adds considerable complexity just
to bring up loopback.

Conversely, if CAP_NET_ADMIN is restricted at user namespace creation
time, tasks inside the new namespace never acquire CAP_NET_ADMIN.
While this removes the CAP_NET_ADMIN attack surface down the
namespace hierarchy, it also prevents userspace from bringing loopback
up, breaking localhost networking for unprivileged sandboxes.

Introduce the CLONE_NEWNET_LOOPBACK flag for clone3() and the
corresponding UNSHARE_NEWNET_LOOPBACK flag for unshare(). When
specified, each flag implies CLONE_NEWNET and automatically brings the
loopback device up in copy_net_ns() before returning the new network
namespace.

Making this an explicit opt-in preserves default network namespace
semantics while allowing unprivileged sandboxes to create an isolated
network namespace with functional localhost networking without ever
holding CAP_NET_ADMIN.

Signed-off-by: Hallgrimur H. Gunnarsson <halg@google.com>
---
 include/uapi/linux/sched.h |  2 ++
 kernel/fork.c              | 22 ++++++++++++++++++----
 kernel/nsproxy.c           |  9 +++++++++
 net/core/net_namespace.c   | 11 +++++++++++
 4 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/sched.h b/include/uapi/linux/sched.h
index 33a4624285cd..efd00d9f8bd3 100644
--- a/include/uapi/linux/sched.h
+++ b/include/uapi/linux/sched.h
@@ -40,6 +40,7 @@
 #define CLONE_NNP		(1ULL << 35) /* Set no_new_privs on child. */
 #define CLONE_PIDFD_AUTOKILL	(1ULL << 36) /* Kill child when clone pidfd closes. */
 #define CLONE_EMPTY_MNTNS	(1ULL << 37) /* Create an empty mount namespace. */
+#define CLONE_NEWNET_LOOPBACK	(1ULL << 38) /* Create network namespace with loopback UP. */
 
 /*
  * cloning flags intersect with CSIGNAL so can be used with unshare and clone3
@@ -52,6 +53,7 @@
  * unshare syscall:
  */
 #define UNSHARE_EMPTY_MNTNS 0x00100000 /* Unshare an empty mount namespace. */
+#define UNSHARE_NEWNET_LOOPBACK 0x00200000 /* Unshare network namespace with loopback UP. */
 
 #ifndef __ASSEMBLY__
 /**
diff --git a/kernel/fork.c b/kernel/fork.c
index 416758c8a3d4..c0f7520e754a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -2728,6 +2728,15 @@ pid_t kernel_clone(struct kernel_clone_args *args)
 		args->flags = clone_flags;
 	}
 
+	/*
+	 * Set implied CLONE_NEWNET before copy_process() so that
+	 * security_task_alloc() and other clone_flags checks see it.
+	 */
+	if (clone_flags & CLONE_NEWNET_LOOPBACK) {
+		clone_flags |= CLONE_NEWNET;
+		args->flags = clone_flags;
+	}
+
 	/*
 	 * For legacy clone() calls, CLONE_PIDFD uses the parent_tid argument
 	 * to return the pidfd. Hence, CLONE_PIDFD and CLONE_PARENT_SETTID are
@@ -3010,7 +3019,8 @@ static bool clone3_args_valid(struct kernel_clone_args *kargs)
 	if (kargs->flags &
 	    ~(CLONE_LEGACY_FLAGS | CLONE_CLEAR_SIGHAND |
 	      CLONE_INTO_CGROUP | CLONE_AUTOREAP | CLONE_NNP |
-	      CLONE_PIDFD_AUTOKILL | CLONE_EMPTY_MNTNS))
+	      CLONE_PIDFD_AUTOKILL | CLONE_EMPTY_MNTNS |
+	      CLONE_NEWNET_LOOPBACK))
 		return false;
 
 	/*
@@ -3160,9 +3170,10 @@ void __init proc_caches_init(void)
  */
 static int check_unshare_flags(unsigned long unshare_flags)
 {
-	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_SIGHAND|
-				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
-				CLONE_NS_ALL | UNSHARE_EMPTY_MNTNS))
+	if (unshare_flags & ~(CLONE_THREAD | CLONE_FS | CLONE_SIGHAND |
+				CLONE_VM | CLONE_FILES | CLONE_SYSVSEM |
+				CLONE_NS_ALL | UNSHARE_EMPTY_MNTNS |
+				UNSHARE_NEWNET_LOOPBACK))
 		return -EINVAL;
 	/*
 	 * Not implemented, but pretend it works if there is nothing
@@ -3266,6 +3277,9 @@ int ksys_unshare(unsigned long unshare_flags)
 	if (unshare_flags & CLONE_NEWNS)
 		unshare_flags |= CLONE_FS;
 
+	if (unshare_flags & UNSHARE_NEWNET_LOOPBACK)
+		unshare_flags |= CLONE_NEWNET;
+
 	/* No unsharing with overriden fs state */
 	VFS_WARN_ON_ONCE(unshare_flags & (CLONE_NEWNS | CLONE_FS) &&
 			 current->fs != current->real_fs);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index d9d3d5973bf5..4e30c6a9f8ed 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -231,6 +231,15 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 		flags |= CLONE_EMPTY_MNTNS;
 	}
 
+	/*
+	 * Convert the 32-bit UNSHARE_NEWNET_LOOPBACK (which aliases
+	 * CLONE_CHILD_CLEARTID) to the unique 64-bit CLONE_NEWNET_LOOPBACK.
+	 */
+	if (flags & UNSHARE_NEWNET_LOOPBACK) {
+		flags &= ~(u64)UNSHARE_NEWNET_LOOPBACK;
+		flags |= CLONE_NEWNET_LOOPBACK;
+	}
+
 	*new_nsp = create_new_namespaces(flags, current, user_ns,
 					 new_fs ? new_fs : current->fs);
 	if (IS_ERR(*new_nsp)) {
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index da5f881fbd3b..70972639932a 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -596,6 +596,17 @@ struct net *copy_net_ns(u64 flags,
 		dec_net_namespaces(ucounts);
 		return ERR_PTR(rv);
 	}
+
+	if (flags & CLONE_NEWNET_LOOPBACK) {
+		rtnl_net_lock(net);
+		rv = dev_open(net->loopback_dev, NULL);
+		rtnl_net_unlock(net);
+		if (rv < 0) {
+			put_net(net);
+			return ERR_PTR(rv);
+		}
+	}
+
 	return net;
 }
 
-- 
2.56.0.313.g2479322e68-goog

