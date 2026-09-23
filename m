Received: from mail-pj2-f16.google.com (mail-pj2-f16.google.com [74.125.227.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7BFDF57D23E
	for <containers@lists.linux.dev>; Wed, 23 Sep 2026 20:50:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790196637; cv=none; b=ZCwIc290XCufBFzJUtk5l0pcJic/+QOQ2dwdP74GDi2n5bYKZI2+5Ad2q2UZ1GFQjZ5zvYAeKZPys7QQoJPWFoE924QmWryiVIQ+hd1gBUKIjaZ1VDs8HdvBeni52NAyeUDn0NyD1B6jgHjMPWPr2ARBp6jFVurXfpjPKBf67HE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790196637; c=relaxed/simple;
	bh=IR+cFhBQfWRSdMGVpfuBcQw5kzuKhkM3dI8xg87PPUs=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=C/OkqvIExg4wqj6kZgZphnSU/r3RBSfhEloZMOPyg0hrf0+dypKR2KT3fHlxoNBJWGchTqvirfzBrGVyApP0s7+kzPgLT+2uOJ7rrAXnIGUxb4uNO6GyVLpoXGPQn6QQIfxru5zvQX/H2aVDivstMdevvzisecpd+k0JZ8Aiyt0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=B6ACN1Hh; arc=none smtp.client-ip=74.125.227.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="B6ACN1Hh"
Received: by mail-pj2-f16.google.com with SMTP id 98e67ed59e1d1-396ccd78e6eso558242a91.0
        for <containers@lists.linux.dev>; Wed, 23 Sep 2026 13:50:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790196635; x=1790801435; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=snlXyVmosKNHZDEUpSvbDeW3MROgMKqCzOa9/2l2FR4=;
        b=B6ACN1HhTlLOBtv6V+ZYPtXJ66haBYviPO0aCI/8qFADKZm1H7SoFnIzl2YNClw2vC
         A25s94T9ARmRRRq6y6f9jAgIdR752cau/x81g+3jRCi/uGZDjadcHms+UGQFUlA9mt8v
         qP6H6S4Fbe2arPJvwE4w3r1tijYiEjO2wCHakEoFdga6HzCNZLBuxp2+/BWVW9R1AWcd
         4err64pBQNQV+Chb36eBJJxL5br9cgz9nVvRfqJl+7/T2KqC12XKxLYcc8ukWmHAw6dV
         EJhgdRdohjJ4fT59aFhVH0CUBoDouq17LJ6efCRhxKi3/jcxrb/6Hg3mq1bVw8WNUS6L
         Fu8g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790196635; x=1790801435;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=snlXyVmosKNHZDEUpSvbDeW3MROgMKqCzOa9/2l2FR4=;
        b=pXZPtz+pvw60XgZO3rfkYT3b6+DhXQb5wPddmgRbhsEOABnzPpRKtZhTcK0bwpJTwV
         5o0tG05qklmWSJ44S123KNf55+hcWPXZokvuLk1/w9IIDb+bPuKivzubtio3HXZFrwv4
         4L+Zp4xwTQ0/727j+t72DD1Lco5kfP0kz7PUNzyl9LzSmOeb27Qsnzlx+/US4JTTA1Ze
         mLSXsN61X8lpSRdn/e8cDuSxi3Hhw2WcAj0Irbey5/+wj+eiApxB+BbFnW6Mg5VH/Y2d
         ihwxqUjE7vZvTZj8rbfkFFVRR1ArDQm2swIthZ8e1eH6SGFTmd/B5+RDp9WMlqmUS66w
         n5Ag==
X-Forwarded-Encrypted: i=1; AKwUvBzTLsLhHHNo524bIGdJwT9riQxoEU4xSwGwEgui16abu1d08qpCpNo6EMmZRwa7ZDPLoJEdtUj/5s2x@lists.linux.dev
X-Gm-Message-State: AFuF++mxqA9jBpGtEQ2WSUNxd9YNgOBonZGKxbdm17unCTGxO7oqVFcB
	J2MTz1xILAUjmg41mIyzc0nnhJ6QWNKkuYELnZRaeAq7Fm23jESF+M36
X-Gm-Gg: AYBFou0b9kcRspaQ8i1+4nvyrzv3K+oomOr8t+A3Jw9sa4Ri5ExbE0aZW585qU912DP
	27wR0gSCHkWCxTVB4ZarQDbfxpLtMTdyGGF7lEHgKqR+T5IGxJY8ykRHV+A2DgCF8xN+DMi1FsK
	MavGJevUIpJhLAZWwvd6awOkBVfX1lAKBh8VEoyi6HCVuldCOaaH9SStDZPpa+bGsqdopXLfI9n
	SLx0iawsVGrabs5UCMEQr6zwkJN9nCVfUBUUs56B/kI7ruYN/9HSa66+oTSCxm4yBzuSldtY8N4
	X+0lxjWBzmXXsBjy9kA3+6jKVzY+uPm03KaHmzaZUvZJtQuWulmAVBGRMtoYv38U5oNqjwuZ1yK
	CIpqyTEoVjDffQ6jIvbu94kqSXbsLgu1wDul29ejAZoiF23VfubegvHQ9N4nilLOTiEPWd3TadB
	Iwi7XhWNKDElaYYC603cBhL79d6Atgou0vjdBX9hNvSFi7pa2KIbRmn+RRldUs9Y4VeynF
X-Received: by 2002:a17:90b:3f4d:b0:39e:1bfa:c5f0 with SMTP id 98e67ed59e1d1-3a09860b2b7mr189257a91.5.1790196634676;
        Wed, 23 Sep 2026 13:50:34 -0700 (PDT)
Received: from kir-tp1.lan ([67.185.120.12])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3a096b8753csm896038a91.0.2026.09.23.13.50.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 23 Sep 2026 13:50:34 -0700 (PDT)
From: Kir Kolyshkin <kolyshkin@gmail.com>
To: Christian Brauner <brauner@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Aleksa Sarai <cyphar@cyphar.com>
Cc: Kir Kolyshkin <kolyshkin@gmail.com>,
	Jan Kara <jack@suse.cz>,
	Jeff Layton <jlayton@kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	David Howells <dhowells@redhat.com>,
	Amir Goldstein <amir73il@gmail.com>,
	Andrei Vagin <avagin@google.com>,
	Shuah Khan <shuah@kernel.org>,
	Giuseppe Scrivano <giuseppe@scrivano.org>,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	containers@lists.linux.dev
Subject: [RFC PATCH] mount: add OPEN_TREE_SKIP_MNTNS
Date: Wed, 23 Sep 2026 13:50:25 -0700
Message-ID: <20260923205028.711077-1-kolyshkin@gmail.com>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

crun, a container runtime, recently started using OPEN_TREE_NAMESPACE to
set up the container's mount namespace, and open_tree(OPEN_TREE_CLONE)
for the sources of its bind mounts.  This turns out not to work on hosts
that have a mount namespace pinned anywhere below such a source: the
recursive clone picks the pinned namespace up, and move_mount(2) then
refuses to attach the tree with ELOOP from check_for_nsfs_mounts().
This was reported to crun in [1].

The rule behind that goes back to commit 8823c079ba71 ("vfs: Add setns
support for the mount namespace"), which requires "all bind mounts be of
a younger mount namespace into an older mount namespace" so that mount
namespace reference loops cannot form.  OPEN_TREE_NAMESPACE ends up on
the wrong side of it by construction: the namespace it creates is younger
than everything else on the system, so from inside it every pinned
namespace is older.

By the time this fails there is nothing userspace can do.  setns() has
already run, so the host tree is unreachable by path; it is unreachable
through a fd saved beforehand as well, since mount(2) requires the source
to live in the current mount namespace; and the offending mounts cannot
be dropped from the detached copy first, because umount(2) requires
check_mnt().  So a runtime cannot fall back to the pivot_root() path at
that point -- it has to predict the situation before setns(), which is
what crun now does, at the cost of the optimization on every such host.

Every other path that crosses a mount namespace boundary already leaves
these mounts behind: copy_mnt_ns() passes CL_COPY_UNBINDABLE | CL_EXPIRE,
and create_new_namespace() passes no CL_COPY_MNT_NS_FILE either -- the
latter deliberately, per the comment added in commit 9b8a0ba68246
("mount: add OPEN_TREE_NAMESPACE"): "When creating a new mount namespace
we don't want to copy over mounts of mount namespaces to avoid the risk
of cycles".  Only get_detached_copy() asks for them, inherited from the
unconditional CL_COPY_MNT_NS_FILE that predates that exception.

Add a flag so a caller can ask for a clone without them, as suggested by
Aleksa when the exception was introduced [2]:

    I kind of think this is a somewhat theoretical issue but I don't
    think we'll be bitten by it. My gut feeling is that I'd prefer this
    to be an OPEN_TREE_* flag that you have to set (so we can support
    this in the future) but that's kinda ugly too...

Keep it opt-in rather than changing the default.  A clone attached in the
caller's own namespace, or in an older one, keeps such mounts usable, and
open_tree(OPEN_TREE_CLONE) plus move_mount(2) is what mount --rbind is
through a file descriptor, so dropping them by default would make
mount --rbind / /mnt silently lose /run/snapd/ns/*.mnt on a live system.
Only a caller heading into a younger namespace, where the tree is refused
anyway, has reason to ask for this.

With OPEN_TREE_NAMESPACE, which never copies these mounts, the flag is
accepted and has no effect, so a runtime can pass it unconditionally.
Locked nsfs mounts are skipped the same way copy_mnt_ns() already skips
them, so this exposes nothing new.

Link: https://github.com/containers/crun/issues/2262 [1]
Link: https://lore.kernel.org/all/2026-01-07-oldest-grim-captions-spills-ywC2O3@cyphar.com/ [2]
Assisted-by: Claude:claude-opus-5
Signed-off-by: Kir Kolyshkin <kolyshkin@gmail.com>
---
 fs/namespace.c                                |  14 +-
 include/uapi/linux/mount.h                    |   1 +
 .../open_tree_ns/open_tree_ns_test.c          | 183 ++++++++++++++++++
 3 files changed, 196 insertions(+), 2 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index ae5dc64f8b45..165750b3d666 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3062,7 +3062,8 @@ static struct mnt_namespace *get_detached_copy(const struct path *path, unsigned
 			ns->seq_origin = src_mnt_ns->ns.ns_id;
 	}
 
-	mnt = __do_loopback(path, (flags & AT_RECURSIVE), CL_COPY_MNT_NS_FILE);
+	mnt = __do_loopback(path, (flags & AT_RECURSIVE),
+			    (flags & OPEN_TREE_SKIP_MNTNS) ? 0 : CL_COPY_MNT_NS_FILE);
 	if (IS_ERR(mnt)) {
 		emptied_ns = ns;
 		return ERR_CAST(mnt);
@@ -3204,7 +3205,16 @@ static struct file *vfs_open_tree(int dfd, const char __user *filename, unsigned
 
 	if (flags & ~(AT_EMPTY_PATH | AT_NO_AUTOMOUNT | AT_RECURSIVE |
 		      AT_SYMLINK_NOFOLLOW | OPEN_TREE_CLONE |
-		      OPEN_TREE_CLOEXEC | OPEN_TREE_NAMESPACE))
+		      OPEN_TREE_CLOEXEC | OPEN_TREE_NAMESPACE |
+		      OPEN_TREE_SKIP_MNTNS))
+		return ERR_PTR(-EINVAL);
+
+	/*
+	 * Only meaningful when a tree is copied.  OPEN_TREE_NAMESPACE never
+	 * copies pinned mount namespaces, so there the flag is a no-op.
+	 */
+	if ((flags & OPEN_TREE_SKIP_MNTNS) &&
+	    !(flags & (OPEN_TREE_CLONE | OPEN_TREE_NAMESPACE)))
 		return ERR_PTR(-EINVAL);
 
 	if ((flags & (AT_RECURSIVE | OPEN_TREE_CLONE | OPEN_TREE_NAMESPACE)) ==
diff --git a/include/uapi/linux/mount.h b/include/uapi/linux/mount.h
index 2204708dbf7a..86082344fc0e 100644
--- a/include/uapi/linux/mount.h
+++ b/include/uapi/linux/mount.h
@@ -63,6 +63,7 @@
  */
 #define OPEN_TREE_CLONE		(1 << 0)	/* Clone the target tree and attach the clone */
 #define OPEN_TREE_NAMESPACE	(1 << 1)	/* Clone the target tree into a new mount namespace */
+#define OPEN_TREE_SKIP_MNTNS	(1 << 2)	/* Omit pinned mount namespaces from the clone */
 #define OPEN_TREE_CLOEXEC	O_CLOEXEC	/* Close the file on execve() */
 
 /*
diff --git a/tools/testing/selftests/filesystems/open_tree_ns/open_tree_ns_test.c b/tools/testing/selftests/filesystems/open_tree_ns/open_tree_ns_test.c
index 82f3c8c02c9a..5b95180a4582 100644
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
@@ -28,6 +29,10 @@
 #include "../utils.h"
 #include "../../kselftest_harness.h"
 
+#ifndef OPEN_TREE_SKIP_MNTNS
+#define OPEN_TREE_SKIP_MNTNS (1 << 2)
+#endif
+
 #ifndef OPEN_TREE_NAMESPACE
 #define OPEN_TREE_NAMESPACE	(1 << 1)
 #endif
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
+FIXTURE(open_tree_ns_skip_mntns)
+{
+	char dir[64];
+	char pin[PATH_MAX];
+	bool mounted;
+};
+
+FIXTURE_SETUP(open_tree_ns_skip_mntns)
+{
+	int fd, ret;
+
+	self->mounted = false;
+	snprintf(self->dir, sizeof(self->dir), "/tmp/open_tree_ns_skip_mntns.XXXXXX");
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
+			   OPEN_TREE_CLONE | OPEN_TREE_SKIP_MNTNS |
+			   OPEN_TREE_CLOEXEC);
+	if (fd < 0 && errno == EINVAL)
+		SKIP(return, "OPEN_TREE_SKIP_MNTNS not supported");
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
+FIXTURE_TEARDOWN(open_tree_ns_skip_mntns)
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
+TEST_F(open_tree_ns_skip_mntns, move_into_younger_namespace)
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
+				 OPEN_TREE_CLONE | OPEN_TREE_SKIP_MNTNS |
+				 AT_RECURSIVE | OPEN_TREE_CLOEXEC);
+	ASSERT_GE(clone_fd, 0);
+	EXPECT_EQ(move_into_namespace(clone_fd, ns_fd), 0);
+	close(clone_fd);
+
+	close(ns_fd);
+}
+
+TEST_F(open_tree_ns_skip_mntns, flag_combinations)
+{
+	int fd;
+
+	/* Nothing is copied, so there is nothing to skip. */
+	EXPECT_LT(sys_open_tree(AT_FDCWD, self->dir,
+				OPEN_TREE_SKIP_MNTNS | OPEN_TREE_CLOEXEC), 0);
+	EXPECT_EQ(errno, EINVAL);
+
+	/* OPEN_TREE_NAMESPACE never copies them; the flag is a no-op there. */
+	fd = sys_open_tree(AT_FDCWD, self->dir,
+			   OPEN_TREE_NAMESPACE | OPEN_TREE_SKIP_MNTNS |
+			   AT_RECURSIVE | OPEN_TREE_CLOEXEC);
+	EXPECT_GE(fd, 0);
+	if (fd >= 0)
+		close(fd);
+}
+
 TEST_HARNESS_MAIN
-- 
2.55.0

