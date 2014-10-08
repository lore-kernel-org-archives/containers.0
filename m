From: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH RFC] setns: return 0 directly if try to reassociate with
	current namespace
Date: Wed, 8 Oct 2014 17:13:07 +0800
Message-ID: <1412759587-21320-1-git-send-email-chenhanxiao@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

We could use setns to join the current ns,
which did a lot of unnecessary work.
This patch will check this senario and
return 0 directly.

Signed-off-by: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/nsproxy.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index ef42d0a..66eea63 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -236,6 +236,34 @@ SYSCALL_DEFINE2(setns, int, fd, int, nstype)
 	ops = ei->ns_ops;
 	if (nstype && (ops->type != nstype))
 		goto out;
+	switch (ops->type) {
+	case CLONE_NEWIPC:
+		if (ei->ns == tsk->nsproxy->ipc_ns)
+			return 0;
+		break;
+	case CLONE_NEWNET:
+		if (ei->ns == tsk->nsproxy->net_ns)
+			return 0;
+		break;
+	case CLONE_NEWNS:
+		if (ei->ns == tsk->nsproxy->mnt_ns)
+			return 0;
+		break;
+	case CLONE_NEWPID:
+		if (ei->ns == tsk->nsproxy->pid_ns_for_children)
+			return 0;
+		break;
+	case CLONE_NEWUSER:
+		if (ei->ns == current_user_ns())
+			return 0;
+		break;
+	case CLONE_NEWUTS:
+		if (ei->ns == tsk->nsproxy->uts_ns)
+			return 0;
+		break;
+	default:
+		goto out;
+	}
 
 	new_nsproxy = create_new_namespaces(0, tsk, current_user_ns(), tsk->fs);
 	if (IS_ERR(new_nsproxy)) {
-- 
1.9.0
