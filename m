Received: from mail-pz2-f32.google.com (mail-pz2-f32.google.com [74.125.228.32])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7777A3911D5
	for <containers@lists.linux.dev>; Sat, 26 Sep 2026 07:00:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.228.32
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790406061; cv=none; b=QZXwmqVCvWzfOXLm5sncik2eIMe3gAogSfJWcltzPtjEe1ysgwRC36vuDc93ZWU4H/FMpO6lWHB8r0wnspO/6CQF9raUWIMEYGHE/LGU2wEWyX41F+05DnPiuGUBAveFum6pEgsxmZrAptF0vQuhQB8Uru1jl4DuZYvZLrAITg8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790406061; c=relaxed/simple;
	bh=SBZEM4eixy9EH9qcDy5q/DL1eUZ0Z/4uyOzur4eGZro=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=pmKyhxijfWD759LEZz4rgH2B1PBK2wSjr77KwFcIEHomvB1JrGtAmJrYBPjgq+TE1McFqd+jGd3AnH/C70IE8v7t+ejHtlA5I1vtXydEJx+2cgebB+uoxASUm4sfNlbo+Me1bxDgQohPSECDAaP4/9XYO7IUiO2Gu+ihow0TPMk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Z6UlCv1V; arc=none smtp.client-ip=74.125.228.32
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Z6UlCv1V"
Received: by mail-pz2-f32.google.com with SMTP id 41be03b00d2f7-cc4d04d73b8so574580a12.1
        for <containers@lists.linux.dev>; Sat, 26 Sep 2026 00:00:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790406059; x=1791010859; darn=lists.linux.dev;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :content-type:mime-version:subject:date:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=OnL76jpHr7vBDo6mf67vFeDAqzHFwrvodH62utIq19k=;
        b=Z6UlCv1VFph3uO0HDglQVUqjRuYqvxHQN8JqRfEu0GP19UMk6clyjOVVlqNatyhxoA
         2XuZjS3mNM0hkUsXjHL2v0qG/O0FFYEZ3sc2q4F3Z30cMUr404y0mYYH5L2ftQw8Zki7
         oHSKGNKwnkktdnhsjbVIOZeQ+FiwOknxssGpOTGJGYTiLBHUaaMveqfaEm4SicgdnUqd
         rxaB2RLKe5N3AwqDMh6KFT124QIM4xikwLGJ8oULKu/tlYgMXNROgK9r/qqtcDwuOuMN
         RCbqRkVUzqKWAGbSw2cv8MeP7b7ZhRvmuwFAPxDgBWPNteNQ/3Iix2UbE44d9reWNuAe
         3ulQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790406059; x=1791010859;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :content-type:mime-version:subject:date:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=OnL76jpHr7vBDo6mf67vFeDAqzHFwrvodH62utIq19k=;
        b=occa3Rpt4A7gmGurZJXK1Zz+Na+xGYFhEz6i2uYr3VLD7jSEYZXHyx0d8edyE3EvIP
         vNc8Wgg5HZ4BLlxKhVhhHq+NofdYJVpmMPkMB9gf+/HvlhWB2lfUpyoS9NAFgQYxXkCc
         +r1oQAFtiIak7L4pigcOF6zJYFOGCmneg/hM4OzKHSIx6FipC8bllVbliVutsd9UvxiW
         Nlyn4BFGHIjB7vIgeTvZq1SlpSh4tRfLJLf12kiHDJGo6lgXzWfo21Mta3eONcGeUklU
         oVA2l+QXR5YjWyngI38PG3D/FX01sJxjpDBK1Ws+CKG9687S4xAjZjhI6w4z5v+/rWq1
         0gfQ==
X-Forwarded-Encrypted: i=1; AKwUvBzs38d3UM2uav4YSoZgt8iBL+JSVyjCSnJ3hhQ0W5J2GMeQ121gkTK93KJK8Otv5fwLRBq0XiP+7K8Y@lists.linux.dev
X-Gm-Message-State: AFuF++noF0bx0lOxtzH0U26r3vOTi9sbYwi4D6f+qvmq2+1VlXoB9fSL
	vh8EDiAGdXEEswp90kxPsUtwMxC5QO+Ow+AIjw8zkLyy7ER9+7KRKoKE
X-Gm-Gg: AYBFou3be22U/83c+VpjLloMQNY7hRj9q/kwcJIQFQzcfgRuctsc+3BM1xNlB0jTigy
	/Q6fCZLTjftVRXUZmty87J/Ttzy8jNx1Fmtcxm53vuQavXEEukENUHRXdSeXvKWYlFLmG5lQY/s
	A+z3mU4UL+7NmMqBvgrXHx/AQsRf1lOQD4gbelMouhio/EhiUqsgcA72iJO6MPXScfOmRXOl/bP
	hDr46M7ZaDXyyoU6TD17Xd8/3UYTGGBMSKtIs6N7pjAHD38yClwUVeGYI1XryhR8fKH41MKAGcF
	ESvh/xVXgtR3xdizq14x1otJCD6oOWxkqQlqzAHE6tUkKHCT+ecbuPhKivc4/7vFGaCgj2XQjS/
	40qOQvHNH/RokwskSRxU/zJf2GN/pqq2DKWWofLnG/G4iE/maREDlL/7P6/WGlkrUYHDVHkK62r
	QRa/ubcQ4awXxY7arq6/a7UQL41WxOOMhrzSmLELF+Ry9Ybstc9ukLAMSm+7Kl5IFYVbK1eg==
X-Received: by 2002:a17:90b:3e4d:b0:3a0:da60:813e with SMTP id 98e67ed59e1d1-3a0da6082ffmr1187847a91.34.1790406058759;
        Sat, 26 Sep 2026 00:00:58 -0700 (PDT)
Received: from [10.1.2.130] ([67.185.120.12])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3a0974ec5d0sm15987119a91.4.2026.09.26.00.00.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 26 Sep 2026 00:00:58 -0700 (PDT)
From: Kir Kolyshkin <kolyshkin@gmail.com>
Date: Sat, 26 Sep 2026 00:00:54 -0700
Subject: [PATCH v2 2/2] selftests/filesystems: test
 OPEN_TREE_DROP_MNTNS_MOUNTS
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260926-nsfs-prune-rfc-v2-2-53509260e4e7@gmail.com>
References: <20260926-nsfs-prune-rfc-v2-0-53509260e4e7@gmail.com>
In-Reply-To: <20260926-nsfs-prune-rfc-v2-0-53509260e4e7@gmail.com>
To: Christian Brauner <brauner@kernel.org>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Aleksa Sarai <cyphar@cyphar.com>
Cc: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@kernel.org>, 
 "Eric W . Biederman" <ebiederm@xmission.com>, 
 David Howells <dhowells@redhat.com>, Amir Goldstein <amir73il@gmail.com>, 
 Andrei Vagin <avagin@google.com>, Shuah Khan <shuah@kernel.org>, 
 Giuseppe Scrivano <giuseppe@scrivano.org>, linux-fsdevel@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 containers@lists.linux.dev, Kir Kolyshkin <kolyshkin@gmail.com>
X-Mailer: b4 0.14.3

Pin a mount namespace below a tmpfs mount, the way snapd does under
/run/snapd/ns, and attach a recursive clone of that tmpfs inside a
younger mount namespace created with OPEN_TREE_NAMESPACE.  Without
OPEN_TREE_DROP_MNTNS_MOUNTS move_mount(2) fails with ELOOP; with it,
it succeeds.

Also check that the flag is rejected without OPEN_TREE_CLONE or
OPEN_TREE_NAMESPACE, and accepted with the latter.

Assisted-by: Claude:claude-opus-5
Signed-off-by: Kir Kolyshkin <kolyshkin@gmail.com>
---
 .../filesystems/open_tree_ns/open_tree_ns_test.c   | 183 +++++++++++++++++++++
 1 file changed, 183 insertions(+)

diff --git a/tools/testing/selftests/filesystems/open_tree_ns/open_tree_ns_test.c b/tools/testing/selftests/filesystems/open_tree_ns/open_tree_ns_test.c
index 82f3c8c02c9a..05d16c56ab35 100644
--- a/tools/testing/selftests/filesystems/open_tree_ns/open_tree_ns_test.c
+++ b/tools/testing/selftests/filesystems/open_tree_ns/open_tree_ns_test.c
@@ -14,6 +14,7 @@
 #include <limits.h>
 #include <linux/nsfs.h>
 #include <sched.h>
+#include <signal.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
@@ -32,6 +33,10 @@
 #define OPEN_TREE_NAMESPACE	(1 << 1)
 #endif
 
+#ifndef OPEN_TREE_DROP_MNTNS_MOUNTS
+#define OPEN_TREE_DROP_MNTNS_MOUNTS	(1 << 2)
+#endif
+
 static int get_mnt_ns_id(int fd, uint64_t *mnt_ns_id)
 {
 	if (ioctl(fd, NS_GET_MNTNS_ID, mnt_ns_id) < 0)
@@ -1004,4 +1009,182 @@ TEST_F(open_tree_ns_unbindable, recursive_skips_on_unbindable)
 	close(fd);
 }
 
+/*
+ * Pin a mount namespace at @where, the way snapd does under /run/snapd/ns.
+ * The namespace has to be younger than ours, so a child unshares and the
+ * parent binds the child's namespace file: binding one's own namespace is
+ * refused by the very check this test is about.
+ */
+static int pin_mount_namespace(const char *where)
+{
+	int pipefd[2], status, ret = -1;
+	char path[PATH_MAX];
+	pid_t pid;
+	char c;
+
+	if (pipe(pipefd))
+		return -1;
+
+	pid = fork();
+	if (pid < 0)
+		goto out;
+	if (pid == 0) {
+		close(pipefd[0]);
+		if (unshare(CLONE_NEWNS))
+			_exit(1);
+		/* Tell the parent the namespace exists, then hold it open. */
+		if (write(pipefd[1], "x", 1) != 1)
+			_exit(1);
+		pause();
+		_exit(0);
+	}
+
+	close(pipefd[1]);
+	pipefd[1] = -1;
+	if (read(pipefd[0], &c, 1) != 1)
+		goto out_kill;
+
+	snprintf(path, sizeof(path), "/proc/%d/ns/mnt", pid);
+	if (mount(path, where, NULL, MS_BIND, NULL))
+		goto out_kill;
+
+	ret = 0;
+
+out_kill:
+	kill(pid, SIGKILL);
+	waitpid(pid, &status, 0);
+out:
+	close(pipefd[0]);
+	if (pipefd[1] >= 0)
+		close(pipefd[1]);
+	return ret;
+}
+
+FIXTURE(open_tree_ns_drop_mntns)
+{
+	char dir[64];
+	char pin[PATH_MAX];
+	bool mounted;
+};
+
+FIXTURE_SETUP(open_tree_ns_drop_mntns)
+{
+	int fd, ret;
+
+	self->mounted = false;
+	snprintf(self->dir, sizeof(self->dir), "/tmp/open_tree_ns_drop_mntns.XXXXXX");
+
+	ret = sys_open_tree(-1, NULL, 0);
+	if (ret == -1 && errno == ENOSYS)
+		SKIP(return, "open_tree() syscall not supported");
+
+	/*
+	 * Work in a private mount namespace, so whatever is mounted here,
+	 * the pinned namespace included, goes away with the test process.
+	 */
+	if (unshare(CLONE_NEWNS))
+		SKIP(return, "unshare(CLONE_NEWNS) failed: %s", strerror(errno));
+	ASSERT_EQ(mount(NULL, "/", NULL, MS_REC | MS_PRIVATE, NULL), 0);
+
+	ASSERT_NE(mkdtemp(self->dir), NULL);
+	if (mount("tmpfs", self->dir, "tmpfs", 0, NULL))
+		SKIP(return, "Failed to mount tmpfs");
+	self->mounted = true;
+
+	fd = sys_open_tree(AT_FDCWD, self->dir,
+			   OPEN_TREE_CLONE | OPEN_TREE_DROP_MNTNS_MOUNTS |
+			   OPEN_TREE_CLOEXEC);
+	if (fd < 0 && errno == EINVAL)
+		SKIP(return, "OPEN_TREE_DROP_MNTNS_MOUNTS not supported");
+	ASSERT_GE(fd, 0);
+	close(fd);
+
+	snprintf(self->pin, sizeof(self->pin), "%s/ns", self->dir);
+	fd = open(self->pin, O_CREAT | O_RDONLY | O_CLOEXEC, 0600);
+	ASSERT_GE(fd, 0);
+	close(fd);
+	ASSERT_EQ(pin_mount_namespace(self->pin), 0);
+}
+
+FIXTURE_TEARDOWN(open_tree_ns_drop_mntns)
+{
+	if (self->mounted)
+		umount2(self->dir, MNT_DETACH);
+	rmdir(self->dir);
+}
+
+/* Attach @clone_fd at "/" inside the namespace @ns_fd; returns errno. */
+static int move_into_namespace(int clone_fd, int ns_fd)
+{
+	pid_t pid;
+	int status;
+
+	pid = fork();
+	if (pid < 0)
+		return -1;
+	if (pid == 0) {
+		int target;
+
+		if (setns(ns_fd, CLONE_NEWNS))
+			_exit(255);
+		target = open("/", O_PATH | O_DIRECTORY | O_CLOEXEC);
+		if (target < 0)
+			_exit(255);
+		if (sys_move_mount(clone_fd, "", target, "",
+				   MOVE_MOUNT_F_EMPTY_PATH | MOVE_MOUNT_T_EMPTY_PATH))
+			_exit(errno);
+		_exit(0);
+	}
+	if (waitpid(pid, &status, 0) != pid || !WIFEXITED(status))
+		return -1;
+	return WEXITSTATUS(status);
+}
+
+TEST_F(open_tree_ns_drop_mntns, move_into_younger_namespace)
+{
+	int clone_fd, ns_fd;
+
+	ns_fd = sys_open_tree(AT_FDCWD, self->dir,
+			      OPEN_TREE_NAMESPACE | OPEN_TREE_CLOEXEC);
+	ASSERT_GE(ns_fd, 0);
+
+	/*
+	 * Without the flag the clone carries the pinned namespace along,
+	 * and move_mount() refuses it from inside a younger namespace.
+	 */
+	clone_fd = sys_open_tree(AT_FDCWD, self->dir,
+				 OPEN_TREE_CLONE | AT_RECURSIVE | OPEN_TREE_CLOEXEC);
+	ASSERT_GE(clone_fd, 0);
+	EXPECT_EQ(move_into_namespace(clone_fd, ns_fd), ELOOP);
+	close(clone_fd);
+
+	/* With the flag the pinned namespace is left out. */
+	clone_fd = sys_open_tree(AT_FDCWD, self->dir,
+				 OPEN_TREE_CLONE | OPEN_TREE_DROP_MNTNS_MOUNTS |
+				 AT_RECURSIVE | OPEN_TREE_CLOEXEC);
+	ASSERT_GE(clone_fd, 0);
+	EXPECT_EQ(move_into_namespace(clone_fd, ns_fd), 0);
+	close(clone_fd);
+
+	close(ns_fd);
+}
+
+TEST_F(open_tree_ns_drop_mntns, flag_combinations)
+{
+	int fd;
+
+	/* Nothing is copied, so there is nothing to drop. */
+	EXPECT_LT(sys_open_tree(AT_FDCWD, self->dir,
+				OPEN_TREE_DROP_MNTNS_MOUNTS | OPEN_TREE_CLOEXEC), 0);
+	EXPECT_EQ(errno, EINVAL);
+
+	/* OPEN_TREE_NAMESPACE never copies them; the flag is a no-op there. */
+	fd = sys_open_tree(AT_FDCWD, self->dir,
+			   OPEN_TREE_NAMESPACE | OPEN_TREE_DROP_MNTNS_MOUNTS |
+			   AT_RECURSIVE | OPEN_TREE_CLOEXEC);
+	EXPECT_GE(fd, 0);
+	if (fd >= 0)
+		close(fd);
+}
+
 TEST_HARNESS_MAIN

-- 
2.55.0

