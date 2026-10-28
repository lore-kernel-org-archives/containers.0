Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.70
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793225899;
	b=VxOMGefIxFVHQad2oxnlqjuY47KOMW63IdfI1ovMzvSbtUGkua4LqQaFWDw2eg6gqOW+
	 I/7FeUxKZC9GHWuSz5jgYR8Lp3B7HbDTEAkp8LmRbcO89WSAvr8YoVn4B9Dn0tIRyPqVo
	 Gr3EMH+gXMtgtJmQJtQ8Yy7b4Ewf8nmbx49ZNnDf5RThVC5lyIChYaAF9dzX3P/u1eC2H
	 gF/pUVgXKgEt1oCXOfizwtUgrskh9HruX3iOWSb4wervlLznAwi4W3YibJFMPPniWYP9Z
	 E2viHejVGBr/QpIUuGm5CIzXuy307wggIm5C9SK8H1nHPQfVMr42pM4P5OwiDmDbrGg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793225899;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=uR8d+2KzOCc+PCIXuOJ1VzHWTSd8KrcryDy/HkQ7hhE=;
	b=zW4U8mrxsl0TYV/z89X3ZZoLhY072Ci6tUp132P6xnKV1GymEdmSGD0MQNGdDZ7cT4Dw
	 NUpwYocE5jB6ecZWKDueiF1WL/jr/1Zz1omw8lrY5A0pSW5y7kY0JTKSY6MEAl0CQxnF+
	 8BXMnvmQynlaNkg2C56eTqETqSVlwOktGxQMusKpHZVyKjs4wufOvmSrD17VRnepCStfd
	 W3YwJL7ls7hJBjKofC15Aqhg1W+KskHSUtgBQPBv6W4kDzGXUNUmmoFKXpv3MQwIp5zqa
	 xfoc4bhL2FHJHRcZ/6gt2UGy9oNlbS9Dchx3RQ4yCL70RbzQtK/5WrTe0sBPVKW9okg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--halg.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=GMRL7+3Z;
	arc=none smtp.remote-ip=209.85.218.70
Received: from mail-ej1-f70.google.com (mail-ej1-f70.google.com [209.85.218.70])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83BCD60A3829
	for <containers@lists.linux.dev>; Wed, 28 Oct 2026 22:18:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 83BCD60A3829
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--halg.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=GMRL7+3Z
Received: by mail-ej1-f70.google.com with SMTP id a640c23a62f3a-c42f98f351eso152803766b.0
        for <containers@lists.linux.dev>; Wed, 28 Oct 2026 15:18:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1793225898; x=1793830698; darn=lists.linux.dev;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=uR8d+2KzOCc+PCIXuOJ1VzHWTSd8KrcryDy/HkQ7hhE=;
        b=GMRL7+3ZN+oBURCuiArw5qzXBBzjV7PkW2iCszkMO1LX/K2hw61Sqpgl2xWt9PqIUV
         DJturvfSBSCZamTwOcvXGwLkz+zxIhDmoyxpmwOYMoXtDngIzLpWb84AB/EdmRtQ4GMR
         Uq7XERfQrWJ3Z5tQ3rmHx3//XNMco2G6dw76HJ5qJzC7H5HPnfnSNFBf7B6Yt4XO7zMS
         58X9BUv6Zw8gT+BbN0t/rP2ZyjeyJAByJ+8ZWHhKorXt4+5uRBPMcZm1iuOqyQqR/Vdc
         92xSRiSGKI9onPU6j8v8BcAeC4c/HinrwrEWXqGtBbQWTJsWVjvoz1RLocwA7txtbsYL
         HYsw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793225898; x=1793830698;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=uR8d+2KzOCc+PCIXuOJ1VzHWTSd8KrcryDy/HkQ7hhE=;
        b=wVGuUM2BeKGDlCzGRF0c9jxmdyPTh1+raYzId0anb1g/WermKkZYEb094ZilrF2Ruk
         DlwsU01jxLGScM8MKwMDgtLivX2buW3mPP+6Xw/KY+uw7HwMDQp8eXzFlD+RLeyu0K2Y
         vWy54PM/WyIf065lKbdmOKr00fjfjc7G7pj5qltZQWNwKrnR1wjv5seL/nfvMT7bh0h4
         1WiJ2y05CQidw1IW/Bi0iQYYnSZB0KJITkxhG1r1sMH6S0TYaWyOeXX2LRygkN7klJK3
         aBTIFj8NhFVRY4yP3Bz2bLoBSMB6I8PbCvl/fKYonV/7TkPDT2NIc+uCXFEKP0UDwHem
         yw4w==
X-Forwarded-Encrypted: i=1; AKwUvBwxhi7BG6lllUamuP5RrcweY1msje29pWfjZOV4iTtmlwTpfKBJiDVC0dCOcMjjf8dRb1ktiQD63VLh@lists.linux.dev
X-Gm-Message-State: AFq9FYKBoZSFkcZ/5RMoW6jFA4MV04WW0dKZC7zfk6BwXN0qJew+rVzL
	g3G8i2GvqhjcAZC/KZCrVwq2LKkHX9kjAJnrOwIQyp06lTy6K04Gx0HLylmS7aSH0b95gAFf4Q=
	=
X-Received: from ejckx26.prod.google.com ([2002:a17:907:775a:b0:c31:9629:c57e])
 (user=halg job=prod-delivery.src-stubby-dispatcher) by 2002:a17:907:868c:b0:c26:1648:a06b
 with SMTP id a640c23a62f3a-c49bdf5c1e6mr326815366b.38.1793225897748; Wed, 28
 Oct 2026 15:18:17 -0700 (PDT)
Date: Wed, 28 Oct 2026 22:17:04 +0000
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
Message-ID: <20261028221705.3915340-8-halg@google.com>
Subject: [PATCH 7/8] selftests/capabilities: add clone3() tests for CLONE_NEWUSER_BSET
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

Add tests to userns_bounding_set_test to verify per-namespace
capability bounding via CLONE_NEWUSER_BSET.

Signed-off-by: Hallgrimur H. Gunnarsson <halg@google.com>
---
 .../capabilities/userns_bounding_set_test.c   | 146 ++++++++++++++++++
 .../selftests/clone3/clone3_selftests.h       |   1 +
 2 files changed, 147 insertions(+)

diff --git a/tools/testing/selftests/capabilities/userns_bounding_set_test.c b/tools/testing/selftests/capabilities/userns_bounding_set_test.c
index 798758e0705d..140c12e16e9e 100644
--- a/tools/testing/selftests/capabilities/userns_bounding_set_test.c
+++ b/tools/testing/selftests/capabilities/userns_bounding_set_test.c
@@ -417,4 +417,150 @@ TEST_F(userns_bset, parent_owner_cap_restricted)
 	EXPECT_EQ(EPERM, run_parent_owner_setns(restricted_mask));
 }
 
+/*
+ * Verify that CLONE_NEWUSER_BSET restricts capabilities in the child user
+ * namespace even when the global sysctl allows all capabilities.
+ */
+TEST_F(userns_bset, clone3_bset_restriction)
+{
+	struct __clone_args args = {
+		.flags = CLONE_NEWUSER | CLONE_NEWUSER_BSET,
+		.exit_signal = SIGCHLD,
+		.cap_bset = cap_full_set & ~(1ULL << CAP_NET_ADMIN),
+	};
+	pid_t pid;
+	int status;
+
+	ASSERT_EQ(0, write_sysctl_caps(cap_full_set));
+
+	pid = sys_clone3(&args, sizeof(args));
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		if (!cap_raised(CAP_SYS_ADMIN))
+			_exit(1);
+		if (!cap_dropped(CAP_NET_ADMIN))
+			_exit(2);
+		_exit(0);
+	}
+
+	ASSERT_EQ(pid, waitpid(pid, &status, 0));
+	ASSERT_TRUE(WIFEXITED(status));
+	EXPECT_EQ(0, WEXITSTATUS(status));
+}
+
+/*
+ * Verify that passing cap_bset = 0 with CLONE_NEWUSER_BSET drops all
+ * capabilities in the new user namespace.
+ */
+TEST_F(userns_bset, clone3_bset_empty)
+{
+	struct __clone_args args = {
+		.flags = CLONE_NEWUSER | CLONE_NEWUSER_BSET,
+		.exit_signal = SIGCHLD,
+		.cap_bset = 0,
+	};
+	pid_t pid;
+	int status;
+
+	ASSERT_EQ(0, write_sysctl_caps(cap_full_set));
+
+	pid = sys_clone3(&args, sizeof(args));
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		if (!cap_dropped(CAP_SYS_ADMIN))
+			_exit(1);
+		if (!cap_dropped(CAP_NET_ADMIN))
+			_exit(2);
+		_exit(0);
+	}
+
+	ASSERT_EQ(pid, waitpid(pid, &status, 0));
+	ASSERT_TRUE(WIFEXITED(status));
+	EXPECT_EQ(0, WEXITSTATUS(status));
+}
+
+/*
+ * Verify that an unprivileged caller cannot use CLONE_NEWUSER_BSET to bypass
+ * the global sysctl ceiling.
+ */
+TEST_F(userns_bset, clone3_bset_cannot_bypass_sysctl)
+{
+	uint64_t restricted_mask = cap_full_set & ~(1ULL << CAP_NET_ADMIN);
+	pid_t pid;
+	int status;
+
+	ASSERT_EQ(0, write_sysctl_caps(restricted_mask));
+
+	pid = fork();
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		struct __clone_args args = {
+			.flags = CLONE_NEWUSER | CLONE_NEWUSER_BSET,
+			.exit_signal = SIGCHLD,
+			.cap_bset = cap_full_set,
+		};
+		int child_status;
+		pid_t child;
+
+		if (drop_privileges() != 0)
+			_exit(1);
+
+		child = sys_clone3(&args, sizeof(args));
+		if (child < 0)
+			_exit(2);
+
+		if (child == 0) {
+			if (!cap_raised(CAP_SYS_ADMIN))
+				_exit(3);
+			if (!cap_dropped(CAP_NET_ADMIN))
+				_exit(4);
+			_exit(0);
+		}
+
+		if (waitpid(child, &child_status, 0) != child ||
+		    !WIFEXITED(child_status) || WEXITSTATUS(child_status) != 0)
+			_exit(5);
+
+		_exit(0);
+	}
+
+	ASSERT_EQ(pid, waitpid(pid, &status, 0));
+	ASSERT_TRUE(WIFEXITED(status));
+	EXPECT_EQ(0, WEXITSTATUS(status));
+}
+
+/*
+ * Verify clone3() argument validation for CLONE_NEWUSER_BSET.
+ */
+TEST_F(userns_bset, clone3_bset_invalid_args)
+{
+	struct __clone_args args;
+
+	/* CLONE_NEWUSER_BSET without CLONE_NEWUSER must fail */
+	memset(&args, 0, sizeof(args));
+	args.flags = CLONE_NEWUSER_BSET;
+	args.exit_signal = SIGCHLD;
+	args.cap_bset = cap_full_set;
+	EXPECT_EQ(-1, sys_clone3(&args, sizeof(args)));
+	EXPECT_EQ(EINVAL, errno);
+
+	/* Non-zero cap_bset without CLONE_NEWUSER_BSET must fail */
+	memset(&args, 0, sizeof(args));
+	args.flags = CLONE_NEWUSER;
+	args.exit_signal = SIGCHLD;
+	args.cap_bset = cap_full_set;
+	EXPECT_EQ(-1, sys_clone3(&args, sizeof(args)));
+	EXPECT_EQ(EINVAL, errno);
+
+	/* CLONE_NEWUSER_BSET with struct size < VER3 must fail */
+	memset(&args, 0, sizeof(args));
+	args.flags = CLONE_NEWUSER | CLONE_NEWUSER_BSET;
+	args.exit_signal = SIGCHLD;
+	EXPECT_EQ(-1, sys_clone3(&args, CLONE_ARGS_SIZE_VER2));
+	EXPECT_EQ(EINVAL, errno);
+}
+
 TEST_HARNESS_MAIN
diff --git a/tools/testing/selftests/clone3/clone3_selftests.h b/tools/testing/selftests/clone3/clone3_selftests.h
index a0593e8950f0..2145d14956e5 100644
--- a/tools/testing/selftests/clone3/clone3_selftests.h
+++ b/tools/testing/selftests/clone3/clone3_selftests.h
@@ -31,6 +31,7 @@ struct __clone_args {
 	__aligned_u64 set_tid;
 	__aligned_u64 set_tid_size;
 	__aligned_u64 cgroup;
+	__aligned_u64 cap_bset;
 };
 
 static pid_t sys_clone3(struct __clone_args *args, size_t size)
-- 
2.56.0.313.g2479322e68-goog

