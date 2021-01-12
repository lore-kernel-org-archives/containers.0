Return-Path: <SRS0=YWEV=GP=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 444D6C433DB
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:10:53 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E14CD2310A
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:10:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E14CD2310A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id C40D486961;
	Tue, 12 Jan 2021 22:10:52 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qO10EBJfi99A; Tue, 12 Jan 2021 22:10:51 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 892FE8691E;
	Tue, 12 Jan 2021 22:10:51 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 82697C0893;
	Tue, 12 Jan 2021 22:10:51 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 75C3FC013A
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:10:50 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 6143985514
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:10:50 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 1ENl5N9jOwi2
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:10:49 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by whitealder.osuosl.org (Postfix) with ESMTPS id C6BA985218
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:10:48 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kzRmH-0003bd-TY; Tue, 12 Jan 2021 22:04:38 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v5 41/42] tests: extend mount_setattr tests
Date: Tue, 12 Jan 2021 23:01:23 +0100
Message-Id: <20210112220124.837960-42-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210112220124.837960-1-christian.brauner@ubuntu.com>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=gsB0F4tYFtY1WQd5K2Z0+ctGmOzUbnRuW0+3Ck/htYc=;
 m=jEN6y0zKVYDloMbOykKZT4p5trwQi5DyANdO/ApLjNU=;
 p=xDp3Nc9lYz44q0tWxhi00UWe6R0gWTnGcv+mhD/g9QA=;
 g=0ab876a9484e0fe3209d4133c45d94062bc39a84
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCX/4YuQAKCRCRxhvAZXjcopO4APsElYZ
 UaYKJaD8Euyg2GgvCYax1QCnWmQ1282g613gQWwEAj3HK0YSkSjwtJH2/jcwhSZqIBAhu79CjBN+k
 TdCmIgU=
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>, linux-xfs@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, Alban Crequy <alban@kinvolk.io>,
 linux-integrity@vger.kernel.org,
 Linus Torvalds <torvalds@linux-foundation.org>, Todd Kjos <tkjos@google.com>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

Extend the mount_setattr test-suite to include tests for idmapped
mounts. Note, the main test-suite ist part of xfstests and is pretty
huge. These tests here just make sure that the syscalls bits work
correctly.

Cc: Christoph Hellwig <hch@lst.de>
Cc: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
patch introduced

/* v3 */
- Christoph Hellwig <hch@lst.de>, Darrick J. Wong <darrick.wong@oracle.com>:
  - Port main test-suite to xfstests.

/* v4 */
unchanged

/* v5 */
base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837
---
 .../mount_setattr/mount_setattr_test.c        | 483 ++++++++++++++++++
 1 file changed, 483 insertions(+)

diff --git a/tools/testing/selftests/mount_setattr/mount_setattr_test.c b/tools/testing/selftests/mount_setattr/mount_setattr_test.c
index 447b91c05cbd..4e94e566e040 100644
--- a/tools/testing/selftests/mount_setattr/mount_setattr_test.c
+++ b/tools/testing/selftests/mount_setattr/mount_setattr_test.c
@@ -108,15 +108,57 @@ struct mount_attr {
 	__u64 attr_set;
 	__u64 attr_clr;
 	__u64 propagation;
+	__u64 userns_fd;
 };
 #endif
 
+#ifndef __NR_open_tree
+	#if defined __alpha__
+		#define __NR_open_tree 538
+	#elif defined _MIPS_SIM
+		#if _MIPS_SIM == _MIPS_SIM_ABI32	/* o32 */
+			#define __NR_open_tree 4428
+		#endif
+		#if _MIPS_SIM == _MIPS_SIM_NABI32	/* n32 */
+			#define __NR_open_tree 6428
+		#endif
+		#if _MIPS_SIM == _MIPS_SIM_ABI64	/* n64 */
+			#define __NR_open_tree 5428
+		#endif
+	#elif defined __ia64__
+		#define __NR_open_tree (428 + 1024)
+	#else
+		#define __NR_open_tree 428
+	#endif
+#endif
+
+#ifndef MOUNT_ATTR_IDMAP
+#define MOUNT_ATTR_IDMAP 0x00100000
+#endif
+
 static inline int sys_mount_setattr(int dfd, const char *path, unsigned int flags,
 				    struct mount_attr *attr, size_t size)
 {
 	return syscall(__NR_mount_setattr, dfd, path, flags, attr, size);
 }
 
+#ifndef OPEN_TREE_CLONE
+#define OPEN_TREE_CLONE 1
+#endif
+
+#ifndef OPEN_TREE_CLOEXEC
+#define OPEN_TREE_CLOEXEC O_CLOEXEC
+#endif
+
+#ifndef AT_RECURSIVE
+#define AT_RECURSIVE 0x8000 /* Apply to the entire subtree */
+#endif
+
+static inline int sys_open_tree(int dfd, const char *filename, unsigned int flags)
+{
+	return syscall(__NR_open_tree, dfd, filename, flags);
+}
+
 static ssize_t write_nointr(int fd, const void *buf, size_t count)
 {
 	ssize_t ret;
@@ -938,4 +980,445 @@ TEST_F(mount_setattr, wrong_mount_namespace)
 	ASSERT_EQ(errno, EINVAL);
 }
 
+FIXTURE(mount_setattr_idmapped) {
+};
+
+FIXTURE_SETUP(mount_setattr_idmapped)
+{
+	int img_fd = -EBADF;
+
+	ASSERT_EQ(unshare(CLONE_NEWNS), 0);
+
+	ASSERT_EQ(mount(NULL, "/", NULL, MS_REC | MS_PRIVATE, 0), 0);
+
+	(void)umount2("/mnt", MNT_DETACH);
+	(void)umount2("/tmp", MNT_DETACH);
+
+	ASSERT_EQ(mount("testing", "/tmp", "tmpfs", MS_NOATIME | MS_NODEV,
+			"size=100000,mode=700"), 0);
+
+	ASSERT_EQ(mkdir("/tmp/B", 0777), 0);
+	ASSERT_EQ(mknodat(-EBADF, "/tmp/B/b", S_IFREG | 0644, 0), 0);
+	ASSERT_EQ(chown("/tmp/B/b", 0, 0), 0);
+
+	ASSERT_EQ(mount("testing", "/tmp/B", "tmpfs", MS_NOATIME | MS_NODEV,
+			"size=100000,mode=700"), 0);
+
+	ASSERT_EQ(mkdir("/tmp/B/BB", 0777), 0);
+	ASSERT_EQ(mknodat(-EBADF, "/tmp/B/BB/b", S_IFREG | 0644, 0), 0);
+	ASSERT_EQ(chown("/tmp/B/BB/b", 0, 0), 0);
+
+	ASSERT_EQ(mount("testing", "/tmp/B/BB", "tmpfs", MS_NOATIME | MS_NODEV,
+			"size=100000,mode=700"), 0);
+
+	ASSERT_EQ(mount("testing", "/mnt", "tmpfs", MS_NOATIME | MS_NODEV,
+			"size=100000,mode=700"), 0);
+
+	ASSERT_EQ(mkdir("/mnt/A", 0777), 0);
+
+	ASSERT_EQ(mount("testing", "/mnt/A", "tmpfs", MS_NOATIME | MS_NODEV,
+			"size=100000,mode=700"), 0);
+
+	ASSERT_EQ(mkdir("/mnt/A/AA", 0777), 0);
+
+	ASSERT_EQ(mount("/tmp", "/mnt/A/AA", NULL, MS_BIND | MS_REC, NULL), 0);
+
+	ASSERT_EQ(mkdir("/mnt/B", 0777), 0);
+
+	ASSERT_EQ(mount("testing", "/mnt/B", "ramfs",
+			MS_NOATIME | MS_NODEV | MS_NOSUID, 0), 0);
+
+	ASSERT_EQ(mkdir("/mnt/B/BB", 0777), 0);
+
+	ASSERT_EQ(mount("testing", "/tmp/B/BB", "devpts",
+			MS_RELATIME | MS_NOEXEC | MS_RDONLY, 0), 0);
+
+	ASSERT_EQ(mkdir("/mnt/C", 0777), 0);
+	ASSERT_EQ(mkdir("/mnt/D", 0777), 0);
+	img_fd = openat(-EBADF, "/mnt/C/ext4.img", O_CREAT | O_WRONLY, 0600);
+	ASSERT_GE(img_fd, 0);
+	ASSERT_EQ(ftruncate(img_fd, 1024 * 2048), 0);
+	ASSERT_EQ(system("mkfs.ext4 -q /mnt/C/ext4.img"), 0);
+	ASSERT_EQ(system("mount -o loop -t ext4 /mnt/C/ext4.img /mnt/D/"), 0);
+	ASSERT_EQ(close(img_fd), 0);
+}
+
+FIXTURE_TEARDOWN(mount_setattr_idmapped)
+{
+	(void)umount2("/mnt/A", MNT_DETACH);
+	(void)umount2("/tmp", MNT_DETACH);
+}
+
+/**
+ * Validate that negative fd values are rejected.
+ */
+TEST_F(mount_setattr_idmapped, invalid_fd_negative)
+{
+	struct mount_attr attr = {
+		.attr_set	= MOUNT_ATTR_IDMAP,
+		.userns_fd	= -EBADF,
+	};
+
+	if (!mount_setattr_supported())
+		SKIP(return, "mount_setattr syscall not supported");
+
+	ASSERT_NE(sys_mount_setattr(-1, "/", 0, &attr, sizeof(attr)), 0) {
+		TH_LOG("failure: created idmapped mount with negative fd");
+	}
+}
+
+/**
+ * Validate that excessively large fd values are rejected.
+ */
+TEST_F(mount_setattr_idmapped, invalid_fd_large)
+{
+	struct mount_attr attr = {
+		.attr_set	= MOUNT_ATTR_IDMAP,
+		.userns_fd	= INT64_MAX,
+	};
+
+	if (!mount_setattr_supported())
+		SKIP(return, "mount_setattr syscall not supported");
+
+	ASSERT_NE(sys_mount_setattr(-1, "/", 0, &attr, sizeof(attr)), 0) {
+		TH_LOG("failure: created idmapped mount with too large fd value");
+	}
+}
+
+/**
+ * Validate that closed fd values are rejected.
+ */
+TEST_F(mount_setattr_idmapped, invalid_fd_closed)
+{
+	int fd;
+	struct mount_attr attr = {
+		.attr_set = MOUNT_ATTR_IDMAP,
+	};
+
+	if (!mount_setattr_supported())
+		SKIP(return, "mount_setattr syscall not supported");
+
+	fd = open("/dev/null", O_RDONLY | O_CLOEXEC);
+	ASSERT_GE(fd, 0);
+	ASSERT_GE(close(fd), 0);
+
+	attr.userns_fd = fd;
+	ASSERT_NE(sys_mount_setattr(-1, "/", 0, &attr, sizeof(attr)), 0) {
+		TH_LOG("failure: created idmapped mount with closed fd");
+	}
+}
+
+/**
+ * Validate that the initial user namespace is rejected.
+ */
+TEST_F(mount_setattr_idmapped, invalid_fd_initial_userns)
+{
+	int open_tree_fd = -EBADF;
+	struct mount_attr attr = {
+		.attr_set = MOUNT_ATTR_IDMAP,
+	};
+
+	if (!mount_setattr_supported())
+		SKIP(return, "mount_setattr syscall not supported");
+
+	open_tree_fd = sys_open_tree(-EBADF, "/mnt/D",
+				     AT_NO_AUTOMOUNT |
+				     AT_SYMLINK_NOFOLLOW |
+				     OPEN_TREE_CLOEXEC | OPEN_TREE_CLONE);
+	ASSERT_GE(open_tree_fd, 0);
+
+	attr.userns_fd = open("/proc/1/ns/user", O_RDONLY | O_CLOEXEC);
+	ASSERT_GE(attr.userns_fd, 0);
+	ASSERT_NE(sys_mount_setattr(open_tree_fd, "", AT_EMPTY_PATH, &attr, sizeof(attr)), 0);
+	ASSERT_EQ(errno, EPERM);
+	ASSERT_EQ(close(attr.userns_fd), 0);
+	ASSERT_EQ(close(open_tree_fd), 0);
+}
+
+static int map_ids(pid_t pid, unsigned long nsid, unsigned long hostid,
+		   unsigned long range)
+{
+	char map[100], procfile[256];
+
+	snprintf(procfile, sizeof(procfile), "/proc/%d/uid_map", pid);
+	snprintf(map, sizeof(map), "%lu %lu %lu", nsid, hostid, range);
+	if (write_file(procfile, map, strlen(map)))
+		return -1;
+
+
+	snprintf(procfile, sizeof(procfile), "/proc/%d/gid_map", pid);
+	snprintf(map, sizeof(map), "%lu %lu %lu", nsid, hostid, range);
+	if (write_file(procfile, map, strlen(map)))
+		return -1;
+
+	return 0;
+}
+
+#define __STACK_SIZE (8 * 1024 * 1024)
+static pid_t do_clone(int (*fn)(void *), void *arg, int flags)
+{
+	void *stack;
+
+	stack = malloc(__STACK_SIZE);
+	if (!stack)
+		return -ENOMEM;
+
+#ifdef __ia64__
+	return __clone2(fn, stack, __STACK_SIZE, flags | SIGCHLD, arg, NULL);
+#else
+	return clone(fn, stack + __STACK_SIZE, flags | SIGCHLD, arg, NULL);
+#endif
+}
+
+static int get_userns_fd_cb(void *data)
+{
+	return kill(getpid(), SIGSTOP);
+}
+
+static int wait_for_pid(pid_t pid)
+{
+	int status, ret;
+
+again:
+	ret = waitpid(pid, &status, 0);
+	if (ret == -1) {
+		if (errno == EINTR)
+			goto again;
+
+		return -1;
+	}
+
+	if (!WIFEXITED(status))
+		return -1;
+
+	return WEXITSTATUS(status);
+}
+
+static int get_userns_fd(unsigned long nsid, unsigned long hostid, unsigned long range)
+{
+	int ret;
+	pid_t pid;
+	char path[256];
+
+	pid = do_clone(get_userns_fd_cb, NULL, CLONE_NEWUSER);
+	if (pid < 0)
+		return -errno;
+
+	ret = map_ids(pid, nsid, hostid, range);
+	if (ret < 0)
+		return ret;
+
+	snprintf(path, sizeof(path), "/proc/%d/ns/user", pid);
+	ret = open(path, O_RDONLY | O_CLOEXEC);
+	kill(pid, SIGKILL);
+	wait_for_pid(pid);
+	return ret;
+}
+
+/**
+ * Validate that an attached mount in our mount namespace can be idmapped.
+ * (The kernel enforces that the mount's mount namespace and the caller's mount
+ *  namespace match.)
+ */
+TEST_F(mount_setattr_idmapped, attached_mount_inside_current_mount_namespace)
+{
+	int open_tree_fd = -EBADF;
+	struct mount_attr attr = {
+		.attr_set = MOUNT_ATTR_IDMAP,
+	};
+
+	if (!mount_setattr_supported())
+		SKIP(return, "mount_setattr syscall not supported");
+
+	open_tree_fd = sys_open_tree(-EBADF, "/mnt/D",
+				     AT_EMPTY_PATH |
+				     AT_NO_AUTOMOUNT |
+				     AT_SYMLINK_NOFOLLOW |
+				     OPEN_TREE_CLOEXEC);
+	ASSERT_GE(open_tree_fd, 0);
+
+	attr.userns_fd	= get_userns_fd(0, 10000, 10000);
+	ASSERT_GE(attr.userns_fd, 0);
+	ASSERT_EQ(sys_mount_setattr(open_tree_fd, "", AT_EMPTY_PATH, &attr, sizeof(attr)), 0);
+	ASSERT_EQ(close(attr.userns_fd), 0);
+	ASSERT_EQ(close(open_tree_fd), 0);
+}
+
+/**
+ * Validate that idmapping a mount is rejected if the mount's mount namespace
+ * and our mount namespace don't match.
+ * (The kernel enforces that the mount's mount namespace and the caller's mount
+ *  namespace match.)
+ */
+TEST_F(mount_setattr_idmapped, attached_mount_outside_current_mount_namespace)
+{
+	int open_tree_fd = -EBADF;
+	struct mount_attr attr = {
+		.attr_set = MOUNT_ATTR_IDMAP,
+	};
+
+	if (!mount_setattr_supported())
+		SKIP(return, "mount_setattr syscall not supported");
+
+	open_tree_fd = sys_open_tree(-EBADF, "/mnt/D",
+				     AT_EMPTY_PATH |
+				     AT_NO_AUTOMOUNT |
+				     AT_SYMLINK_NOFOLLOW |
+				     OPEN_TREE_CLOEXEC);
+	ASSERT_GE(open_tree_fd, 0);
+
+	ASSERT_EQ(unshare(CLONE_NEWNS), 0);
+
+	attr.userns_fd	= get_userns_fd(0, 10000, 10000);
+	ASSERT_GE(attr.userns_fd, 0);
+	ASSERT_NE(sys_mount_setattr(open_tree_fd, "", AT_EMPTY_PATH, &attr,
+				    sizeof(attr)), 0);
+	ASSERT_EQ(close(attr.userns_fd), 0);
+	ASSERT_EQ(close(open_tree_fd), 0);
+}
+
+/**
+ * Validate that an attached mount in our mount namespace can be idmapped.
+ */
+TEST_F(mount_setattr_idmapped, detached_mount_inside_current_mount_namespace)
+{
+	int open_tree_fd = -EBADF;
+	struct mount_attr attr = {
+		.attr_set = MOUNT_ATTR_IDMAP,
+	};
+
+	if (!mount_setattr_supported())
+		SKIP(return, "mount_setattr syscall not supported");
+
+	open_tree_fd = sys_open_tree(-EBADF, "/mnt/D",
+				     AT_EMPTY_PATH |
+				     AT_NO_AUTOMOUNT |
+				     AT_SYMLINK_NOFOLLOW |
+				     OPEN_TREE_CLOEXEC |
+				     OPEN_TREE_CLONE);
+	ASSERT_GE(open_tree_fd, 0);
+
+	/* Changing mount properties on a detached mount. */
+	attr.userns_fd	= get_userns_fd(0, 10000, 10000);
+	ASSERT_GE(attr.userns_fd, 0);
+	ASSERT_EQ(sys_mount_setattr(open_tree_fd, "",
+				    AT_EMPTY_PATH, &attr, sizeof(attr)), 0);
+	ASSERT_EQ(close(attr.userns_fd), 0);
+	ASSERT_EQ(close(open_tree_fd), 0);
+}
+
+/**
+ * Validate that a detached mount not in our mount namespace can be idmapped.
+ */
+TEST_F(mount_setattr_idmapped, detached_mount_outside_current_mount_namespace)
+{
+	int open_tree_fd = -EBADF;
+	struct mount_attr attr = {
+		.attr_set = MOUNT_ATTR_IDMAP,
+	};
+
+	if (!mount_setattr_supported())
+		SKIP(return, "mount_setattr syscall not supported");
+
+	open_tree_fd = sys_open_tree(-EBADF, "/mnt/D",
+				     AT_EMPTY_PATH |
+				     AT_NO_AUTOMOUNT |
+				     AT_SYMLINK_NOFOLLOW |
+				     OPEN_TREE_CLOEXEC |
+				     OPEN_TREE_CLONE);
+	ASSERT_GE(open_tree_fd, 0);
+
+	ASSERT_EQ(unshare(CLONE_NEWNS), 0);
+
+	/* Changing mount properties on a detached mount. */
+	attr.userns_fd	= get_userns_fd(0, 10000, 10000);
+	ASSERT_GE(attr.userns_fd, 0);
+	ASSERT_EQ(sys_mount_setattr(open_tree_fd, "",
+				    AT_EMPTY_PATH, &attr, sizeof(attr)), 0);
+	ASSERT_EQ(close(attr.userns_fd), 0);
+	ASSERT_EQ(close(open_tree_fd), 0);
+}
+
+/**
+ * Validate that currently changing the idmapping of an idmapped mount fails.
+ */
+TEST_F(mount_setattr_idmapped, change_idmapping)
+{
+	int open_tree_fd = -EBADF;
+	struct mount_attr attr = {
+		.attr_set = MOUNT_ATTR_IDMAP,
+	};
+
+	if (!mount_setattr_supported())
+		SKIP(return, "mount_setattr syscall not supported");
+
+	open_tree_fd = sys_open_tree(-EBADF, "/mnt/D",
+				     AT_EMPTY_PATH |
+				     AT_NO_AUTOMOUNT |
+				     AT_SYMLINK_NOFOLLOW |
+				     OPEN_TREE_CLOEXEC |
+				     OPEN_TREE_CLONE);
+	ASSERT_GE(open_tree_fd, 0);
+
+	attr.userns_fd	= get_userns_fd(0, 10000, 10000);
+	ASSERT_GE(attr.userns_fd, 0);
+	ASSERT_EQ(sys_mount_setattr(open_tree_fd, "",
+				    AT_EMPTY_PATH, &attr, sizeof(attr)), 0);
+	ASSERT_EQ(close(attr.userns_fd), 0);
+
+	/* Change idmapping on a detached mount that is already idmapped. */
+	attr.userns_fd	= get_userns_fd(0, 20000, 10000);
+	ASSERT_GE(attr.userns_fd, 0);
+	ASSERT_NE(sys_mount_setattr(open_tree_fd, "", AT_EMPTY_PATH, &attr, sizeof(attr)), 0);
+	ASSERT_EQ(close(attr.userns_fd), 0);
+	ASSERT_EQ(close(open_tree_fd), 0);
+}
+
+static bool expected_uid_gid(int dfd, const char *path, int flags,
+			     uid_t expected_uid, gid_t expected_gid)
+{
+	int ret;
+	struct stat st;
+
+	ret = fstatat(dfd, path, &st, flags);
+	if (ret < 0)
+		return false;
+
+	return st.st_uid == expected_uid && st.st_gid == expected_gid;
+}
+
+TEST_F(mount_setattr_idmapped, idmap_mount_tree_invalid)
+{
+	int open_tree_fd = -EBADF;
+	struct mount_attr attr = {
+		.attr_set = MOUNT_ATTR_IDMAP,
+	};
+
+	if (!mount_setattr_supported())
+		SKIP(return, "mount_setattr syscall not supported");
+
+	ASSERT_EQ(expected_uid_gid(-EBADF, "/tmp/B/b", 0, 0, 0), 0);
+	ASSERT_EQ(expected_uid_gid(-EBADF, "/tmp/B/BB/b", 0, 0, 0), 0);
+
+	open_tree_fd = sys_open_tree(-EBADF, "/mnt/A",
+				     AT_RECURSIVE |
+				     AT_EMPTY_PATH |
+				     AT_NO_AUTOMOUNT |
+				     AT_SYMLINK_NOFOLLOW |
+				     OPEN_TREE_CLOEXEC |
+				     OPEN_TREE_CLONE);
+	ASSERT_GE(open_tree_fd, 0);
+
+	attr.userns_fd	= get_userns_fd(0, 10000, 10000);
+	ASSERT_GE(attr.userns_fd, 0);
+	ASSERT_NE(sys_mount_setattr(open_tree_fd, "", AT_EMPTY_PATH, &attr, sizeof(attr)), 0);
+	ASSERT_EQ(close(attr.userns_fd), 0);
+	ASSERT_EQ(close(open_tree_fd), 0);
+
+	ASSERT_EQ(expected_uid_gid(-EBADF, "/tmp/B/b", 0, 0, 0), 0);
+	ASSERT_EQ(expected_uid_gid(-EBADF, "/tmp/B/BB/b", 0, 0, 0), 0);
+	ASSERT_EQ(expected_uid_gid(open_tree_fd, "B/b", 0, 0, 0), 0);
+	ASSERT_EQ(expected_uid_gid(open_tree_fd, "B/BB/b", 0, 0, 0), 0);
+}
+
 TEST_HARNESS_MAIN
-- 
2.30.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
