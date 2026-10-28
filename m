Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.69
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793225896;
	b=UE+iCThVcVHZucLHkZdw13uaClTvrS1Y7hXqTHGA8/Yzphff33Kiw5mpQSWX0f07I7a5
	 3pSVuqPQpQKMceBOgtav4BGPa2chc0MtkJFldQ7DP5tt3wAf3O1IlgSpqKSzE0ITXZdGL
	 gNdDD3GNz5+kROSVFjhaMCi5RudzGYBMeYg9YXJ+I6BP5raZ6non7eti7JTznvMsvXBRO
	 bLiIl+FyjKc2IsKS3ZFEuNhvGOWpEFQkRXUPz9ATGc1myQIWPGfT2boHKJR/NtkhnA/Ov
	 KfUw32Ng6f1oG33pluXlgWRuFdG8Xq4wiDivWcgpiGlZhE278WrqU3JPfa6NWiPJpLQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793225896;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=IliLvxEFhtUoKzlsMTRJTupCYDKTYP3W6Uvf0vlrqBM=;
	b=BGfxM1ohDYgCx3/wDvIHNOxSJ79dclendLHjZ1did3yaI6cveTGDn3wQ5uQZ1m5v3PwK
	 opETm8JQWE9rQMOTp2qUdJY/OghpSAZ/Hpd+gD+V3ck+hp4L200t4JuQ/OTnYXFAxvIMG
	 BjNSy/rP2JqFaWK0EMyE2GG4pV0SKlKiqqX07maBlz+bzS6bCIM3RCDXQ7hrYLPeP2E1h
	 Pe/rQNNysjg+vT8NkWrvrLiBwl18sAZblAwH7dW88Nl8c6rf3zm7KhmZdWDPWM+OW9UhD
	 8WrpJw1JLRlPFod2zJRMf5cAqZtiJNGwqP7zDpGXKbVtfPmZiW9sU54McpjRFIZGMbw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--halg.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b="k5ShI/tR";
	arc=none smtp.remote-ip=209.85.218.69
Received: from mail-ej1-f69.google.com (mail-ej1-f69.google.com [209.85.218.69])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96B6760A2621
	for <containers@lists.linux.dev>; Wed, 28 Oct 2026 22:18:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 96B6760A2621
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--halg.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=k5ShI/tR
Received: by mail-ej1-f69.google.com with SMTP id a640c23a62f3a-c41b03cd1dcso129296766b.3
        for <containers@lists.linux.dev>; Wed, 28 Oct 2026 15:18:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1793225895; x=1793830695; darn=lists.linux.dev;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=IliLvxEFhtUoKzlsMTRJTupCYDKTYP3W6Uvf0vlrqBM=;
        b=k5ShI/tRwv1H+erWZg4jrr5DGidCnEhdmRmVagXd9/V8Uj0j89Uc4olWSTjyGRr907
         hql2B9Ent6Wd9318fjQrI6RlHqLK0dYqHDJFSkNRwYmgX6jM9ryj2qkPNlaF4awUQr0W
         QWuhRyR/W8WCIn4CTjlTmOn6OwoMEKN5Mj+zx3Wjw2uTEVZyfbf9nC877IS6OL+OJvjK
         kzsWOwgJhKc2iLexoQFOE0U7Vr5ma9rd19IB3TgjBm7ALn1ClWgxVGg+bCjtFgEVVW8E
         XpFAVhca2TnoY6fZ3zNGW8MjRHKyo0sMHQTghRwJk3/I1pAtguF7m93GTo3hVZgRoVfj
         3heA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793225895; x=1793830695;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=IliLvxEFhtUoKzlsMTRJTupCYDKTYP3W6Uvf0vlrqBM=;
        b=LkBaxPdDRHIvVozXtOA5u97x6gKz41IdZn3ON98m0zSABHn0Wm01F5ip68FBt2Viyu
         oRf0v8j0JL6aYz8bBz/lEQ8t5RH/v2rOyKb4miov24WeaRlwHHB/mmoMZtQcm4/ZHcUg
         MZXcpZgKnjjgc7ZYul9Gy1MmuGgKLOSozWMrVcltkVc0LEzFLrWU3FDpGrw4cNaiCJSV
         bKbPdaYbKH1L8jW3QD4XVv5FffqX5/PfdZEvGCR7/rbu0Mu7FkdY/kn0PDJOBtGVzweC
         YhCJQBsm/oRMMa+N7pYzVnO98mpLFbDdD0ugwR4BgppXuW3gswEpS3c0dBXNIUU8KUjH
         +jSg==
X-Forwarded-Encrypted: i=1; AKwUvBztxnv8bF6A2i6vwol7cSN4/TTSyms3PIEdg9v3sZMK66OOjgg3SRJipquWHqZl5UVubdSPjOHnFNee@lists.linux.dev
X-Gm-Message-State: AFq9FYKJRLzRs9pg2HwIOi2zszdk+UmOTmXFPqng1K92FK6IIWzy5iKi
	RgXo+0GRuWALHjXxTrUk1wJzSyTPK+kszbPm0PnrK/zap7Cw8rsNCZaCbC8vh5Qx5I/QD6+9Ng=
	=
X-Received: from ejad9.prod.google.com ([2002:a17:906:409:b0:c32:473d:4a4b])
 (user=halg job=prod-delivery.src-stubby-dispatcher) by 2002:a17:907:3f88:b0:c40:80eb:c54e
 with SMTP id a640c23a62f3a-c49bddac533mr311667066b.4.1793225894675; Wed, 28
 Oct 2026 15:18:14 -0700 (PDT)
Date: Wed, 28 Oct 2026 22:17:01 +0000
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
Message-ID: <20261028221705.3915340-5-halg@google.com>
Subject: [PATCH 4/8] nsfs: add NS_USER_GET_INFO ioctl to inspect user
 namespace capabilities
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

With the introduction of a capability bounding set for user namespaces,
userspace needs a way to inspect the capability ceiling enforced on a
given user namespace.

Introduce the NS_USER_GET_INFO ioctl on nsfs file descriptors to query
user namespace metadata, mirroring the extensible structure pattern
used by NS_MNT_GET_INFO.

Signed-off-by: Hallgrimur H. Gunnarsson <halg@google.com>
---
 fs/nsfs.c                 | 29 +++++++++++++++++++++++++++++
 include/uapi/linux/nsfs.h | 17 +++++++++++++++++
 2 files changed, 46 insertions(+)

diff --git a/fs/nsfs.c b/fs/nsfs.c
index c3b6ae76594a..50711362d792 100644
--- a/fs/nsfs.c
+++ b/fs/nsfs.c
@@ -170,6 +170,17 @@ static int copy_ns_info_to_user(const struct mnt_namespace *mnt_ns,
 	return 0;
 }
 
+static int copy_user_ns_info_to_user(const struct user_namespace *user_ns,
+				     struct user_ns_info __user *uinfo,
+				     size_t usize, struct user_ns_info *kinfo)
+{
+	kinfo->size = min(usize, sizeof(*kinfo));
+	kinfo->spare = 0;
+	kinfo->cap_bset = user_ns->cap_bset.val;
+
+	return copy_struct_to_user(uinfo, usize, kinfo, sizeof(*kinfo), NULL);
+}
+
 static bool nsfs_ioctl_valid(unsigned int cmd)
 {
 	switch (cmd) {
@@ -194,6 +205,8 @@ static bool nsfs_ioctl_valid(unsigned int cmd)
 		return extensible_ioctl_valid(cmd, NS_MNT_GET_NEXT, MNT_NS_INFO_SIZE_VER0);
 	case _IOC_NR(NS_MNT_GET_PREV):
 		return extensible_ioctl_valid(cmd, NS_MNT_GET_PREV, MNT_NS_INFO_SIZE_VER0);
+	case _IOC_NR(NS_USER_GET_INFO):
+		return extensible_ioctl_valid(cmd, NS_USER_GET_INFO, USER_NS_INFO_SIZE_VER0);
 	}
 
 	return false;
@@ -360,6 +373,22 @@ static long ns_ioctl(struct file *filp, unsigned int ioctl,
 		ret = fd_publish(fdf);
 		break;
 	}
+	case _IOC_NR(NS_USER_GET_INFO): {
+		struct user_ns_info __user *uinfo = (struct user_ns_info __user *)arg;
+		struct user_ns_info kinfo = {};
+		size_t usize = _IOC_SIZE(ioctl);
+
+		if (ns->ns_type != CLONE_NEWUSER)
+			return -EINVAL;
+
+		if (!uinfo)
+			return -EINVAL;
+
+		if (usize < USER_NS_INFO_SIZE_VER0)
+			return -EINVAL;
+
+		return copy_user_ns_info_to_user(to_user_ns(ns), uinfo, usize, &kinfo);
+	}
 	default:
 		ret = -ENOTTY;
 	}
diff --git a/include/uapi/linux/nsfs.h b/include/uapi/linux/nsfs.h
index 007fed5971b4..d2996d47c857 100644
--- a/include/uapi/linux/nsfs.h
+++ b/include/uapi/linux/nsfs.h
@@ -44,6 +44,23 @@ struct mnt_ns_info {
 #define NS_GET_MNTNS_ID		_IOR(NSIO, 5,  __u64)
 #define NS_GET_ID		_IOR(NSIO, 13, __u64)
 
+/**
+ * struct user_ns_info - information about a user namespace
+ * @size: size of this structure
+ * @spare: reserved for future use
+ * @cap_bset: capability bounding set of the user namespace
+ */
+struct user_ns_info {
+	__u32 size;
+	__u32 spare;
+	__u64 cap_bset;
+};
+
+#define USER_NS_INFO_SIZE_VER0 16 /* sizeof first published struct */
+
+/* Get information about user namespace. */
+#define NS_USER_GET_INFO	_IOR(NSIO, 14, struct user_ns_info)
+
 enum init_ns_ino {
 	IPC_NS_INIT_INO		= 0xEFFFFFFFU,
 	UTS_NS_INIT_INO		= 0xEFFFFFFEU,
-- 
2.56.0.313.g2479322e68-goog

