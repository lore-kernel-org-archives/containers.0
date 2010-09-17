From: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 1/2] nsproxy: add copy_namespaces_unattached
Date: Fri, 17 Sep 2010 10:16:57 -0500
Message-ID: <1284736618-27153-1-git-send-email-wad__17268.8462459066$1284736810$gmane$org@chromium.org>
References: <20100917152639.0e88341a@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100917152639.0e88341a-3rXA9MLqAseW/qJFnhkgxti2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Eugene Teo <eteo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

This changes adds copy_namespaces_unattached which provides similar
behavior to copy_namespaces() for clone, but is meant for use when a
new namespace needs to be derived from an existing process outside
of process creation.

The next patch in this series shows this function used in fs/exec.c to
insert the core_pattern pipe thread into the crashed processes
namespaces.

This patch is similar to the setns patches floated earlier this year,
but the goal is less lofty though not incompatible!

Any and all input, thoughts, etc will be appreciated.

Signed-off-by: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 include/linux/nsproxy.h |    2 ++
 kernel/nsproxy.c        |   39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index 7b370c7..4c823d2 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -63,6 +63,8 @@ static inline struct nsproxy *task_nsproxy(struct task_struct *tsk)
 }
 
 int copy_namespaces(unsigned long flags, struct task_struct *tsk);
+int copy_namespaces_unattached(unsigned long flags, struct task_struct *tsk,
+			       struct nsproxy **nsproxy, struct fs_struct **fs);
 void exit_task_namespaces(struct task_struct *tsk);
 void switch_task_namespaces(struct task_struct *tsk, struct nsproxy *new);
 void free_nsproxy(struct nsproxy *ns);
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index f74e6c0..ddaea4d 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -22,6 +22,7 @@
 #include <linux/pid_namespace.h>
 #include <net/net_namespace.h>
 #include <linux/ipc_namespace.h>
+#include <linux/fs_struct.h>
 
 static struct kmem_cache *nsproxy_cachep;
 
@@ -161,6 +162,44 @@ out:
 	return err;
 }
 
+/**
+ * copy_namespaces_unattached: creates a new nsproxy and fs from a given task
+ * @flags:	clone flags to change namespace creation/copy behavior
+ * @tsk:	task's namespace to base the nsproxy and fs on
+ * @nsproxy:	pointer which will contain the newly created nsproxy
+ * @fs:		pointer which will contain the newly created fs_struct
+ *
+ * Returns 0 on success and non-zero on failure.
+ *
+ * This function should aid in migrating processes across namespaces when after
+ * creation.
+ */
+int copy_namespaces_unattached(unsigned long flags, struct task_struct *tsk,
+			       struct nsproxy **nsproxy, struct fs_struct **fs)
+{
+	int err = 0;
+	if (!fs || !nsproxy) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	*fs = copy_fs_struct(tsk->fs);
+	if (!*fs) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	*nsproxy = create_new_namespaces(flags, tsk, *fs);
+	if (IS_ERR(*nsproxy)) {
+		err = PTR_ERR(*nsproxy);
+		free_fs_struct(*fs);
+		goto out;
+	}
+
+out:
+	return err;
+}
+
 void free_nsproxy(struct nsproxy *ns)
 {
 	if (ns->mnt_ns)
-- 
1.7.0.4
