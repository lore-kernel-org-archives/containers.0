Received: from mail-pl1-f170.google.com (mail-pl1-f170.google.com [209.85.214.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 70BD43F9278
	for <containers@lists.linux.dev>; Wed,  7 Oct 2026 06:24:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791354255; cv=none; b=R56cVC6glRLIpYC+x3WrBLqKpFBCXnNn4M0vdrUzvKU+SfYSGLXCFAut81d6Y2/fc4VK5JAKoZq5ssAzSGPsIzPzHbVbuMWG+DTPXyqAIP2JPISNpFL3wVy8IEhP04EX3SwoqHQ4gLrdM7GrjDRvhL4t6eMd2MD8OfX4M+ezSB8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791354255; c=relaxed/simple;
	bh=yKbAdIAk7lKrKeJFecFIjKC9cXzZzNASgcbnD3ik2g8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=rGEtUKdCueavGdH5Ky3XHbYXVkEm0jA+6xUVxNHcRWlfW/NWhUbUUo6IutxdpRbmWDnGvByrXUrImHfu/+zw6GsNl80iZ2ybIxCUN7ZaCpnHtXdjUWu7rHIJfWlQzaGaJwAalGbc7lNuWd9RRDHTvpaUEIfHnAk3XwO142rxUeE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=dsMWTAef; arc=none smtp.client-ip=209.85.214.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dsMWTAef"
Received: by mail-pl1-f170.google.com with SMTP id d9443c01a7336-2e61ac64ec3so328775ad.2
        for <containers@lists.linux.dev>; Tue, 06 Oct 2026 23:24:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791354254; x=1791959054; darn=lists.linux.dev;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :content-type:mime-version:subject:date:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=bul8Yte339vRqTq5tYRzTAT8u64iOZDpcCOd5xkxOQM=;
        b=dsMWTAefmWUCX8+5gEMWKEq2q4iaE1dIHDCZweakWjR4nY5rDE3lGdfwbdKoyRhtbd
         3rB/KL/Uid8bu1oOq36cNhfRjvFWFjMAanA3CCBnuuP3j/jUXAJkWRRVh08i2OOlpn2V
         pZfgvitLdv/SJTM+mbPgeYN1Vw5aFcFV4iiY7yq8ZS14hS1Bm2wfN73SNSPE638W8CFJ
         9bnBUivKaEd9q5L/LWVZRUQqcjcpRoN+Viob1cAoAa0irJjaAWJwjQ+OmOCKqrx4Fk86
         BzIt+SCrwd2+KXdNt9ktm32KSn3SjqQ5vJ0kMm5B1z35EOeSJPO4uNoHJQcMa7CGnUv4
         Q9Bw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791354254; x=1791959054;
        h=cc:to:in-reply-to:references:message-id:content-transfer-encoding
         :content-type:mime-version:subject:date:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=bul8Yte339vRqTq5tYRzTAT8u64iOZDpcCOd5xkxOQM=;
        b=cr9XSlrN78+dwzfb2uTXsWK4ptyl3KodeWuRf+QieCaGKHPyIR7zidClmda3/GKTSE
         fc+En6OPOzGR7IGzNmSBNfe4oWGzztyVXh1GEBuwEy4/gJI8rFD5kxGfAvoVOF7sC+v/
         dYKiRgb5v00ly+yaHoscmYuTcbw9+vb3jclWx6P8LkrTqFelKCVFfh4H5/OPRp6tmKH0
         yIdsV/54SUIdc0whU88QuShqDKa/aJ7RGOQqRBj3VCm8V9ikW+ZdldqSvQu5b6ad2Bvz
         TuSKOLOkIFA7tz/iJTq2+ZVe1UJG8CKNJVutotr85v/ohC2bX9kmo1KdANLMscklRxk0
         dqrg==
X-Forwarded-Encrypted: i=1; AKwUvBw/wm1VCzt5ySudYt6o1DcwIKT2+n0hQ8QRxwYQHFfk+HOERUN3stkYOG7cI+ytdIObTAjaIN21LIOO@lists.linux.dev
X-Gm-Message-State: AFq9FYLfmPuLA1DOBnjO25ds8zIE73V60bYPEw5hPDPNei+86EYpiyQn
	XaK5OwLEgLEcrnZN9fmSAKpForAnwHFhxGLYGDrweGBUj8dABAp8jmwd
X-Gm-Gg: AYBFou2DgfLy3NCiFW4P/CroS12V1v/cP0Q1lPzvwhfMaI9qZxBvIe1BI1lAfar6a4l
	MDLEbExZhW/xPjIrFVJuEx77k9ycEBwbAdUG776PyVg7jLPm95kqP0E+hrv9pGG4MBwgT0mBV2l
	W7x4QEx7blNEIDYOfe0aKqwgJdCaVr1cXU/ey+3qCNLe0ycnNIqhIGc6jbXdBiXu75Z3ngytcII
	1T3p/dndgRVZ8pfxWx3iA9ly3mUzW+l7ApbgFoiwN1eXn8tnuhe7VjeQHm92bDKkKqK6/9GTiOV
	nhkEV29PCa1WbcSqYBhBqh45YkDWo38XnKQK3/gFqD/R8nH6fX3zgWBCdN9veqyQ2PPR2Ix3+fz
	VDToSxs7W5JOQsJbvz4X8/X3kCo8e5qly48ZqfTOjsw8rWCQ9sQhLQTBjtjgXNoazzG5Bq03e46
	21uzCvzWMRjtE04aQIaFS6RO8xKp9AFG/I1w++CZMa6GwmaLj+saKWFvqAkg3bbgRE+hVtrQ==
X-Received: by 2002:a17:902:f70c:b0:2d7:107c:917b with SMTP id d9443c01a7336-2e5ff8215acmr14401515ad.0.1791354253676;
        Tue, 06 Oct 2026 23:24:13 -0700 (PDT)
Received: from [10.1.2.130] ([67.185.120.12])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2e60482ccb3sm5303515ad.51.2026.10.06.23.24.12
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 06 Oct 2026 23:24:13 -0700 (PDT)
From: Kir Kolyshkin <kolyshkin@gmail.com>
Date: Tue, 06 Oct 2026 23:23:57 -0700
Subject: [PATCH v3 2/2] selftests/filesystems: test
 OPEN_TREE_DROP_MNTNS_MOUNTS
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261006-nsfs-prune-rfc-v3-2-adb97ea52868@gmail.com>
References: <20261006-nsfs-prune-rfc-v3-0-adb97ea52868@gmail.com>
In-Reply-To: <20261006-nsfs-prune-rfc-v3-0-adb97ea52868@gmail.com>
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
 .../filesystems/open_tree_ns/open_tree_ns_test.c   | 193 +++++++++++++++++++++
 1 file changed, 193 insertions(+)

diff --git a/tools/testing/selftests/filesystems/open_tree_ns/open_tree_ns_test.c b/tools/testing/selftests/filesystems/open_tree_ns/open_tree_ns_test.c
index 82f3c8c02c9a..438054ab6a6a 100644
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
@@ -1004,4 +1009,192 @@ TEST_F(open_tree_ns_unbindable, recursive_skips_on_unbindable)
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
+			   AT_RECURSIVE | OPEN_TREE_CLOEXEC);
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
+	/* A non-recursive clone has no submounts, so there is nothing to drop. */
+	EXPECT_LT(sys_open_tree(AT_FDCWD, self->dir,
+				OPEN_TREE_CLONE | OPEN_TREE_DROP_MNTNS_MOUNTS |
+				OPEN_TREE_CLOEXEC), 0);
+	EXPECT_EQ(errno, EINVAL);
+	EXPECT_LT(sys_open_tree(AT_FDCWD, self->dir,
+				OPEN_TREE_NAMESPACE | OPEN_TREE_DROP_MNTNS_MOUNTS |
+				OPEN_TREE_CLOEXEC), 0);
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

