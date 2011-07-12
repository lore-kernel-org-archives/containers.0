From: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 02/14] allow root in container to copy namespaces
Date: Tue, 12 Jul 2011 23:30:40 +0000
Message-ID: <1310513452-13397-3-git-send-email-serge@hallyn.com>
References: <1310513452-13397-1-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1310513452-13397-1-git-send-email-serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Othewise nested containers with user namespaces won't be possible.

It's true that user namespaces are not yet fully isolated, but for
that same reason there are far worse things that root in a child
user ns can do.  Spawning a child user ns is not in itself bad.

This patch also allows setns for root in a container:
@Eric Biederman: are there gotchas in allowing setns from child
userns?

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/fork.c    |    4 ++--
 kernel/nsproxy.c |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 0276c30..01d7564 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1475,8 +1475,8 @@ long do_fork(unsigned long clone_flags,
 		/* hopefully this check will go away when userns support is
 		 * complete
 		 */
-		if (!capable(CAP_SYS_ADMIN) || !capable(CAP_SETUID) ||
-				!capable(CAP_SETGID))
+		if (!nsown_capable(CAP_SYS_ADMIN) || !nsown_capable(CAP_SETUID) ||
+				!nsown_capable(CAP_SETGID))
 			return -EPERM;
 	}
 
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index d6a00f3..a687405 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -134,7 +134,7 @@ int copy_namespaces(unsigned long flags, struct task_struct *tsk)
 				CLONE_NEWPID | CLONE_NEWNET)))
 		return 0;
 
-	if (!capable(CAP_SYS_ADMIN)) {
+	if (!nsown_capable(CAP_SYS_ADMIN)) {
 		err = -EPERM;
 		goto out;
 	}
@@ -191,7 +191,7 @@ int unshare_nsproxy_namespaces(unsigned long unshare_flags,
 			       CLONE_NEWNET)))
 		return 0;
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!nsown_capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
 	*new_nsp = create_new_namespaces(unshare_flags, current,
@@ -241,7 +241,7 @@ SYSCALL_DEFINE2(setns, int, fd, int, nstype)
 	struct file *file;
 	int err;
 
-	if (!capable(CAP_SYS_ADMIN))
+	if (!nsown_capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
 	file = proc_ns_fget(fd);
-- 
1.7.4.1
