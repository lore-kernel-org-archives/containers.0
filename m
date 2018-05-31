From: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Subject: [PATCH v3 4/4] seccomp: add support for passing fds via USER_NOTIF
Date: Thu, 31 May 2018 08:49:49 -0600
Message-ID: <20180531144949.24995-5-tycho__39243.5453054079$1527778491$gmane$org@tycho.ws>
References: <20180531144949.24995-1-tycho@tycho.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180531144949.24995-1-tycho-E0fblnxP3wo@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: "Tobin C . Harding" <me-xzjC0nNlxno@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Id: containers.vger.kernel.org

The idea here is that the userspace handler should be able to pass an fd
back to the trapped task, for example so it can be returned from socket().

I've proposed one API here, but I'm open to other options. In particular,
this only lets you return an fd from a syscall, which may not be enough in
all cases. For example, if an fd is written to an output parameter instead
of returned, the current API can't handle this. Another case is that
netlink takes as input fds sometimes (IFLA_NET_NS_FD, e.g.). If netlink
ever decides to install an fd and output it, we wouldn't be able to handle
this either.

Still, the vast majority of interesting cases are covered by this API, so
perhaps it is Enough.

I've left it as a separate commit for two reasons:
  * It illustrates the way in which we would grow struct seccomp_notif and
    struct seccomp_notif_resp without using netlink
  * It shows just how little code is needed to accomplish this :)

v2: new in v2
v3: no changes

Signed-off-by: Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
CC: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
CC: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
CC: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
CC: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
CC: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
CC: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
CC: Tyler Hicks <tyhicks-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
CC: Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
---
 include/uapi/linux/seccomp.h                  |   2 +
 kernel/seccomp.c                              |  49 +++++++-
 tools/testing/selftests/seccomp/seccomp_bpf.c | 112 ++++++++++++++++++
 3 files changed, 161 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/seccomp.h b/include/uapi/linux/seccomp.h
index 8160e6cad528..3124427219cb 100644
--- a/include/uapi/linux/seccomp.h
+++ b/include/uapi/linux/seccomp.h
@@ -71,6 +71,8 @@ struct seccomp_notif_resp {
 	__u64 id;
 	__s32 error;
 	__s64 val;
+	__u8 return_fd;
+	__u32 fd;
 };
 
 #endif /* _UAPI_LINUX_SECCOMP_H */
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 6dc99c65c2f4..2ee958b3efde 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -77,6 +77,8 @@ struct seccomp_knotif {
 	/* The return values, only valid when in SECCOMP_NOTIFY_REPLIED */
 	int error;
 	long val;
+	struct file *file;
+	unsigned int flags;
 
 	/* Signals when this has entered SECCOMP_NOTIFY_REPLIED */
 	struct completion ready;
@@ -780,10 +782,32 @@ static void seccomp_do_user_notification(int this_syscall,
 			goto remove_list;
 	}
 
-	ret = n.val;
-	err = n.error;
+	if (n.file) {
+		int fd;
+
+		fd = get_unused_fd_flags(n.flags);
+		if (fd < 0) {
+			err = fd;
+			ret = -1;
+			goto remove_list;
+		}
+
+		ret = fd;
+		err = 0;
+
+		fd_install(fd, n.file);
+		/* Don't fput, since fd has a reference now */
+		n.file = NULL;
+	} else {
+		ret = n.val;
+		err = n.error;
+	}
+
 
 remove_list:
+	if (n.file)
+		fput(n.file);
+
 	list_del(&n.list);
 out:
 	mutex_unlock(&match->notify_lock);
@@ -1598,6 +1622,27 @@ static ssize_t seccomp_notify_write(struct file *file, const char __user *buf,
 	knotif->state = SECCOMP_NOTIFY_REPLIED;
 	knotif->error = resp.error;
 	knotif->val = resp.val;
+
+	if (resp.return_fd) {
+		struct fd fd;
+
+		/*
+		 * This is a little hokey: we need a real fget() (i.e. not
+		 * __fget_light(), which is what fdget does), but we also need
+		 * the flags from strcut fd. So, we get it, put it, and get it
+		 * again for real.
+		 */
+		fd = fdget(resp.fd);
+		knotif->flags = fd.flags;
+		fdput(fd);
+
+		knotif->file = fget(resp.fd);
+		if (!knotif->file) {
+			ret = -EBADF;
+			goto out;
+		}
+	}
+
 	complete(&knotif->ready);
 out:
 	mutex_unlock(&filter->notify_lock);
diff --git a/tools/testing/selftests/seccomp/seccomp_bpf.c b/tools/testing/selftests/seccomp/seccomp_bpf.c
index 07984f7bd601..b9a4f676566d 100644
--- a/tools/testing/selftests/seccomp/seccomp_bpf.c
+++ b/tools/testing/selftests/seccomp/seccomp_bpf.c
@@ -167,6 +167,8 @@ struct seccomp_notif_resp {
 	__u64 id;
 	__s32 error;
 	__s64 val;
+	__u8 return_fd;
+	__u32 fd;
 };
 #endif
 
@@ -3176,6 +3178,116 @@ TEST(get_user_notification_ptrace)
 	close(listener);
 }
 
+TEST(user_notification_pass_fd)
+{
+	pid_t pid;
+	int status, listener;
+	int sk_pair[2];
+	char c;
+	struct seccomp_notif req = {};
+	struct seccomp_notif_resp resp = {};
+	long ret;
+
+	ASSERT_EQ(socketpair(PF_LOCAL, SOCK_SEQPACKET, 0, sk_pair), 0);
+
+	pid = fork();
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		int fd;
+		char buf[16];
+
+		EXPECT_EQ(user_trap_syscall(__NR_getpid, 0), 0);
+
+		/* Signal we're ready and have installed the filter. */
+		EXPECT_EQ(write(sk_pair[1], "J", 1), 1);
+
+		EXPECT_EQ(read(sk_pair[1], &c, 1), 1);
+		EXPECT_EQ(c, 'H');
+		close(sk_pair[1]);
+
+		/* An fd from getpid(). Let the games begin. */
+		fd = syscall(__NR_getpid);
+		EXPECT_GT(fd, 0);
+		EXPECT_EQ(read(fd, buf, sizeof(buf)), 12);
+		close(fd);
+
+		exit(strcmp("hello world", buf));
+	}
+
+	EXPECT_EQ(read(sk_pair[0], &c, 1), 1);
+	EXPECT_EQ(c, 'J');
+
+	EXPECT_EQ(ptrace(PTRACE_ATTACH, pid), 0);
+	EXPECT_EQ(waitpid(pid, NULL, 0), pid);
+	listener = ptrace(PTRACE_SECCOMP_GET_LISTENER, pid, 0);
+	EXPECT_GE(listener, 0);
+	EXPECT_EQ(ptrace(PTRACE_DETACH, pid, NULL, 0), 0);
+
+	/* Now signal we are done installing so it can do a getpid */
+	EXPECT_EQ(write(sk_pair[0], "H", 1), 1);
+	close(sk_pair[0]);
+
+	/* Make a new socket pair so we can send half across */
+	EXPECT_EQ(socketpair(PF_LOCAL, SOCK_SEQPACKET, 0, sk_pair), 0);
+
+	ret = read_notif(listener, &req);
+	EXPECT_EQ(ret, sizeof(req));
+	EXPECT_EQ(errno, 0);
+
+	resp.id = req.id;
+	resp.return_fd = 1;
+	resp.fd = sk_pair[1];
+	EXPECT_EQ(write(listener, &resp, sizeof(resp)), sizeof(resp));
+	close(sk_pair[1]);
+
+	EXPECT_EQ(write(sk_pair[0], "hello world\0", 12), 12);
+	close(sk_pair[0]);
+
+	EXPECT_EQ(waitpid(pid, &status, 0), pid);
+	EXPECT_EQ(true, WIFEXITED(status));
+	EXPECT_EQ(0, WEXITSTATUS(status));
+	close(listener);
+}
+
+TEST(user_notification_struct_size_mismatch)
+{
+	pid_t pid;
+	long ret;
+	int status, listener, len;
+	struct seccomp_notif req;
+	struct seccomp_notif_resp resp;
+
+	listener = user_trap_syscall(__NR_getpid,
+				     SECCOMP_FILTER_FLAG_GET_LISTENER);
+	EXPECT_GE(listener, 0);
+
+	pid = fork();
+	ASSERT_GE(pid, 0);
+
+	if (pid == 0) {
+		ret = syscall(__NR_getpid);
+		exit(ret != USER_NOTIF_MAGIC);
+	}
+
+	EXPECT_EQ(read(listener, &req, sizeof(req)), sizeof(req));
+
+	resp.id = req.id;
+	resp.error = 0;
+	resp.val = USER_NOTIF_MAGIC;
+
+	/*
+	 * Only write a partial structure: this is what was available before we
+	 * had fd support.
+	 */
+	len = offsetof(struct seccomp_notif_resp, val) + sizeof(resp.val);
+	EXPECT_EQ(write(listener, &resp, len), len);
+
+	EXPECT_EQ(waitpid(pid, &status, 0), pid);
+	EXPECT_EQ(true, WIFEXITED(status));
+	EXPECT_EQ(0, WEXITSTATUS(status));
+}
+
 /*
  * TODO:
  * - add microbenchmarks
-- 
2.17.0
