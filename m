From: "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCH] ns: move free_nsproxy() out of do_exit() path
Date: Fri, 13 Jul 2012 14:48:08 +0300
Message-ID: <1342180088-22647-1-git-send-email-kirill.shutemov@linux.intel.com>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Dmitry V. Levin" <ldv-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

free_nsproxy() is too heavy to be on exit path. Let's free namespaces
asynchronously to not block exit_group() syscall.

Microbenchmark:

: #define _GNU_SOURCE
: #include <unistd.h>
: #include <sched.h>
: #include <stdlib.h>
: #include <sys/wait.h>
:
: int
: main(void)
: {
:       int i;
:       for (i = 0; i < 1024; i++) {
:               if (fork()) {
:                       wait(NULL);
:                       continue;
:               }
:               unshare(CLONE_NEWIPC);
:               exit(0);
:       }
:       return 0;
: }

Before the patch:

real    0m8.335s
user    0m0.000s
sys     0m0.265s

After:

real    0m0.569s
user    0m0.001s
sys     0m0.154s

The patch also fixes bug with free namespace without synchronize_rcu() through
put_nsproxy().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
---

Serge, I've changed the patch a bit, but I hope I can reuse your Ack.

---
 include/linux/nsproxy.h |    1 +
 kernel/nsproxy.c        |   34 +++++++++++++++++++++++-----------
 2 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index cc37a55..1d26be7 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -24,6 +24,7 @@ struct fs_struct;
  */
 struct nsproxy {
 	atomic_t count;
+	struct work_struct free_nsproxy_work;
 	struct uts_namespace *uts_ns;
 	struct ipc_namespace *ipc_ns;
 	struct mnt_namespace *mnt_ns;
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index b576f7f..ebc7d40 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -41,13 +41,17 @@ struct nsproxy init_nsproxy = {
 #endif
 };
 
+static void free_nsproxy_work(struct work_struct *work);
+
 static inline struct nsproxy *create_nsproxy(void)
 {
 	struct nsproxy *nsproxy;
 
 	nsproxy = kmem_cache_alloc(nsproxy_cachep, GFP_KERNEL);
-	if (nsproxy)
+	if (nsproxy) {
 		atomic_set(&nsproxy->count, 1);
+		INIT_WORK(&nsproxy->free_nsproxy_work, free_nsproxy_work);
+	}
 	return nsproxy;
 }
 
@@ -166,6 +170,14 @@ out:
 
 void free_nsproxy(struct nsproxy *ns)
 {
+	/*
+	 * wait for others to get what they want from this nsproxy.
+	 *
+	 * cannot release this nsproxy via the call_rcu() since
+	 * put_mnt_ns() will want to sleep
+	 */
+	synchronize_rcu();
+
 	if (ns->mnt_ns)
 		put_mnt_ns(ns->mnt_ns);
 	if (ns->uts_ns)
@@ -178,6 +190,14 @@ void free_nsproxy(struct nsproxy *ns)
 	kmem_cache_free(nsproxy_cachep, ns);
 }
 
+static void free_nsproxy_work(struct work_struct *work)
+{
+	struct nsproxy *ns = container_of(work, struct nsproxy,
+			free_nsproxy_work);
+
+	free_nsproxy(ns);
+}
+
 /*
  * Called from unshare. Unshare all the namespaces part of nsproxy.
  * On success, returns the new nsproxy.
@@ -215,16 +235,8 @@ void switch_task_namespaces(struct task_struct *p, struct nsproxy *new)
 
 	rcu_assign_pointer(p->nsproxy, new);
 
-	if (ns && atomic_dec_and_test(&ns->count)) {
-		/*
-		 * wait for others to get what they want from this nsproxy.
-		 *
-		 * cannot release this nsproxy via the call_rcu() since
-		 * put_mnt_ns() will want to sleep
-		 */
-		synchronize_rcu();
-		free_nsproxy(ns);
-	}
+	if (ns && atomic_dec_and_test(&ns->count))
+		schedule_work(&ns->free_nsproxy_work);
 }
 
 void exit_task_namespaces(struct task_struct *p)
-- 
1.7.7.6
