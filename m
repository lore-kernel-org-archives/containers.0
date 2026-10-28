Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.70
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793225898;
	b=nyGvPxRru9MP2dHCoSrQIQRpFFiVGo0/WPk66kMzkj9LzJ9hl8Y6ZcyOlMBblvNK5jfM
	 eImkh8lf9gkp6Z7AlswIyRbepI+1+1vuJQjfMRgfUliSk2Zl9tT04NP5sVBcDS7YjCEtt
	 HVLdoPk4VBA5opMcJPysze4Up6xRWUigs2VN4QtiAnfgYWWm02Iu1bbh9DPYvwZiLQEBW
	 dIwo3UiJGTb1W15uMVN4cbZ8CgyOy8RfVOyA6xGe2v5dCPBRST0uaYKx0CxMPDWUAByL1
	 TZfDWUvzKHuK567we/0KbU+svtW9ylnO5576ir8xMlGG6lu0lmuqkEbN0w9AmZzWw5w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793225898;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=LuXjD7L3OcsNkkaeGIp4Cs+2/jEhkIJjHJvLaqO3j5k=;
	b=EtZbGS7pEg8xtbRRG4N6/oEjxP6QNBkSf+ysdkfPbGLXRZZdeGEH56LgandJNMtUzGYc
	 JLwPmFA8hfDoCtR8QaZWLKSYVXY6T//Mpxlgy/pi+M1SzXu9A1nAMog1c7Eg+AgxjQ5r8
	 SSp4wmFvIZVzMuTIP4Oe7tk0/2GNNQLRqBm1WuXlmqbPZ/BGmIKlpdscZqqukoNaFxNsY
	 e/Jx5wiK3bbsPrS17EJa8bpc1iVyWw5FrRVvRLM0FzqEqCnjMlGseWG556WCvHRv4HRnV
	 unY372pqFfY+u2ziZLzxk48uRP/Wf+NHnc/5hpzhbdqhcc2T5pY4LV4lxgmJlQv0OgA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--halg.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=MT2LmVVD;
	arc=none smtp.remote-ip=209.85.208.70
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A41A760A2634
	for <containers@lists.linux.dev>; Wed, 28 Oct 2026 22:18:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A41A760A2634
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--halg.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=MT2LmVVD
Received: by mail-ed1-f70.google.com with SMTP id 4fb4d7f45d1cf-6b1ab11f4a3so1612478a12.0
        for <containers@lists.linux.dev>; Wed, 28 Oct 2026 15:18:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1793225896; x=1793830696; darn=lists.linux.dev;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=LuXjD7L3OcsNkkaeGIp4Cs+2/jEhkIJjHJvLaqO3j5k=;
        b=MT2LmVVDDk+E+V2DwaqZWgxJVxiAOrobza4zbpCXn8/TZVJboXvIbYzKDjjgtIplOH
         WGFc0bNcdeCZkFh23YxP3Kb5wgeP74M6CeE7Wt3iNebGIBDC3NdpHHnT6hn6Nq1yE2J+
         Go2zd7Rh5niWyv4NdkoiTAF4+Hfu/Ry+FI1HGMXvLXx0CYnC701DQyUsWWn9xBsags5w
         tc31CBPfxXpJPdzBpE72JZfFYd8Z+eEcNWXouv9EL0x5bRtRk5mHthK28bwz05LEa/lF
         XhRixFXN4aRX/ZS1tsu504tZ0udpGVmB/yaQpcslFuXJwsZErrJNm4lKG6Ar7OwXmh3K
         qhhQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793225896; x=1793830696;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=LuXjD7L3OcsNkkaeGIp4Cs+2/jEhkIJjHJvLaqO3j5k=;
        b=dsT34UluuO58x3qAveP6VrC7rZ8F/iIaBYenVZ1IUcUWmV9P3Sx5tgAeAtEG/WZo0K
         fFw1LFkqQM0Vfu1F9OtOjPdfcIS23UObfiCzLEtS9e1yG+E/0hLYofTyM99oR0W31Gmz
         0oh/MNh5sLGb+vtRtyiX8hzcOFshklIu1a9pXRUxVcaUSLulAzvfrQDVFr6mhtGUf6qz
         8JH4jSfzpVUae7xa6niCeYmB8yaFHOwVudUqP8Nruh+I6fUj8+8gLJE5/R45DRO+2kjI
         j8ngpS9mcyGTnFi0oXnr1eCq9+wdKqaIQ8G2xL0G7gFklJ0+Zd6IQDSLhkYju5J37Lu7
         JwLw==
X-Forwarded-Encrypted: i=1; AKwUvBzdMZ8NSPAP4AyxCZIiL5aJIlQZTNdBQt6oM4ZuPKEzq38tXGOat3rkJlAdVVEWuNWDkernfOPbquCB@lists.linux.dev
X-Gm-Message-State: AFq9FYIudRW5F5wn0zmBQHXLAumNHz5urQ0J6CvH5a4EdOrri4cEJLYC
	JHt5RG5UCK2K8KRnq0zQRqKpkvbQAiPzMeGswU5sQKv5EpxduZ5eirmMvrnm1Yp9HcRSC+AI1Q=
	=
X-Received: from ejblw4.prod.google.com ([2002:a17:906:bcc4:b0:c46:48a5:ea8c])
 (user=halg job=prod-delivery.src-stubby-dispatcher) by 2002:a17:906:e2cf:b0:c49:c76f:dad4
 with SMTP id a640c23a62f3a-c49c76fdf58mr174243066b.31.1793225895629; Wed, 28
 Oct 2026 15:18:15 -0700 (PDT)
Date: Wed, 28 Oct 2026 22:17:02 +0000
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
Message-ID: <20261028221705.3915340-6-halg@google.com>
Subject: [PATCH 5/8] selftests/net: add test suite for CLONE_NEWNET_LOOPBACK
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

Add tests in tools/testing/selftests/net to validate
CLONE_NEWNET_LOOPBACK and UNSHARE_NEWNET_LOOPBACK behavior.

Signed-off-by: Hallgrimur H. Gunnarsson <halg@google.com>
---
 tools/testing/selftests/net/.gitignore       |   1 +
 tools/testing/selftests/net/Makefile         |   1 +
 tools/testing/selftests/net/loopback_netns.c | 103 +++++++++++++++++++
 3 files changed, 105 insertions(+)
 create mode 100644 tools/testing/selftests/net/loopback_netns.c

diff --git a/tools/testing/selftests/net/.gitignore b/tools/testing/selftests/net/.gitignore
index c9f46031ac73..54919a8b3682 100644
--- a/tools/testing/selftests/net/.gitignore
+++ b/tools/testing/selftests/net/.gitignore
@@ -18,6 +18,7 @@ ipv6_flowlabel
 ipv6_flowlabel_mgr
 ipv6_fragmentation
 log.txt
+loopback_netns
 msg_zerocopy
 netlink-dumps
 nettest
diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 0f5c178bc224..7d7e88e6676f 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -184,6 +184,7 @@ TEST_GEN_PROGS := \
 	icmp_rfc4884 \
 	ipv6_flowlabel_mgr \
 	ipv6_fragmentation \
+	loopback_netns \
 	proc_net_pktgen \
 	reuseaddr_conflict \
 	reuseport_bpf \
diff --git a/tools/testing/selftests/net/loopback_netns.c b/tools/testing/selftests/net/loopback_netns.c
new file mode 100644
index 000000000000..03cc665fb502
--- /dev/null
+++ b/tools/testing/selftests/net/loopback_netns.c
@@ -0,0 +1,103 @@
+// SPDX-License-Identifier: GPL-2.0
+#define _GNU_SOURCE
+
+#include <errno.h>
+#include <sched.h>
+#include <string.h>
+#include <sys/ioctl.h>
+#include <sys/socket.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <unistd.h>
+
+#include <linux/sched.h>
+#include <linux/types.h>
+#include <net/if.h>
+
+#include "../clone3/clone3_selftests.h"
+#include "../kselftest_harness.h"
+
+static int get_lo_flags(void)
+{
+	struct ifreq ifr;
+	int fd, ret;
+
+	memset(&ifr, 0, sizeof(ifr));
+	strncpy(ifr.ifr_name, "lo", IFNAMSIZ - 1);
+
+	fd = socket(AF_INET, SOCK_DGRAM, 0);
+	if (fd < 0)
+		return -errno;
+
+	ret = ioctl(fd, SIOCGIFFLAGS, &ifr);
+	close(fd);
+
+	if (ret < 0)
+		return -errno;
+
+	return ifr.ifr_flags;
+}
+
+TEST(baseline_lo_down)
+{
+	int flags;
+
+	ASSERT_EQ(0, unshare(CLONE_NEWUSER | CLONE_NEWNET));
+
+	flags = get_lo_flags();
+	ASSERT_GE(flags, 0);
+	EXPECT_EQ(0, flags & IFF_UP);
+}
+
+TEST(unshare_loopback)
+{
+	struct stat st_before, st_after;
+	int flags;
+
+	ASSERT_EQ(0, stat("/proc/self/ns/net", &st_before));
+	ASSERT_EQ(0, unshare(CLONE_NEWUSER | UNSHARE_NEWNET_LOOPBACK));
+	ASSERT_EQ(0, stat("/proc/self/ns/net", &st_after));
+	EXPECT_NE(st_before.st_ino, st_after.st_ino);
+
+	flags = get_lo_flags();
+	ASSERT_GE(flags, 0);
+	EXPECT_NE(0, flags & IFF_UP);
+	EXPECT_NE(0, flags & IFF_RUNNING);
+}
+
+TEST(clone3_loopback)
+{
+	struct __clone_args args = {
+		.flags = CLONE_NEWUSER | CLONE_NEWNET_LOOPBACK,
+		.exit_signal = SIGCHLD,
+	};
+	struct stat st_parent, st_child;
+	int status;
+	pid_t pid;
+
+	ASSERT_EQ(0, stat("/proc/self/ns/net", &st_parent));
+
+	pid = sys_clone3(&args, sizeof(args));
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		int flags;
+
+		if (stat("/proc/self/ns/net", &st_child) != 0 ||
+		    st_parent.st_ino == st_child.st_ino)
+			_exit(1);
+
+		flags = get_lo_flags();
+		if (flags < 0 || !(flags & IFF_UP) || !(flags & IFF_RUNNING))
+			_exit(2);
+
+		_exit(0);
+	}
+
+	ASSERT_EQ(pid, waitpid(pid, &status, 0));
+	ASSERT_TRUE(WIFEXITED(status));
+	EXPECT_EQ(0, WEXITSTATUS(status));
+}
+
+TEST_HARNESS_MAIN
-- 
2.56.0.313.g2479322e68-goog

