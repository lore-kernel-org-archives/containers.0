From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [C/R v20][PATCH 85/96] c/r: preliminary support mounts namespace
Date: Thu, 18 Mar 2010 21:00:01 -0400
Message-ID: <1268960401-16680-18-git-send-email-orenl__48865.9197152176$1268961338$gmane$org@cs.columbia.edu>
References: <1268960401-16680-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1268960401-16680-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andreas Dilger <adilger-xsfywfwIY+M@public.gmane.org>
List-Id: containers.vger.kernel.org

We only allow c/r when all processes shared a single mounts ns.

We do intend to implement c/r of mounts and mounts namespaces in the
kernel.  It shouldn't be ugly or complicate locking to do so.  Just
haven't gotten around to it. A more complete solution is more than we
want to take on now for v19.

But we'd like as much as possible for everything which we don't
support, to not be checkpointable, since not doing so has in the past
invited slanderous accusations of being a toy implementation :)

Meanwhile, we get the following:
1) Checkpoint bails if not all tasks share the same mnt-ns
2) Leak detection works for full container checkpoint

On restart, all tasks inherit the same mnt-ns of the coordinator, by
default. A follow-up patch to user-cr will add a new switch to the
'restart' to request a CLONE_NEWMNT flag when creating the root-task
of the restart.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c           |   25 +++++++++++++++++++++++++
 include/linux/checkpoint.h     |    2 +-
 include/linux/checkpoint_hdr.h |    4 ++++
 kernel/nsproxy.c               |   16 +++++++++++++---
 4 files changed, 43 insertions(+), 4 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 5c4749d..42998b2 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -19,6 +19,7 @@
 #include <linux/sched.h>
 #include <linux/ipc_namespace.h>
 #include <linux/user_namespace.h>
+#include <linux/mnt_namespace.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 #include <net/sock.h>
@@ -214,6 +215,22 @@ static int obj_ipc_ns_users(void *ptr)
 	return atomic_read(&((struct ipc_namespace *) ptr)->count);
 }
 
+static int obj_mnt_ns_grab(void *ptr)
+{
+	get_mnt_ns((struct mnt_namespace *) ptr);
+	return 0;
+}
+
+static void obj_mnt_ns_drop(void *ptr, int lastref)
+{
+	put_mnt_ns((struct mnt_namespace *) ptr);
+}
+
+static int obj_mnt_ns_users(void *ptr)
+{
+	return atomic_read(&((struct mnt_namespace *) ptr)->count);
+}
+
 static int obj_cred_grab(void *ptr)
 {
 	get_cred((struct cred *) ptr);
@@ -411,6 +428,14 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
 		.checkpoint = checkpoint_ipc_ns,
 		.restore = restore_ipc_ns,
 	},
+	/* mnt_ns object */
+	{
+		.obj_name = "MOUNTS NS",
+		.obj_type = CKPT_OBJ_MNT_NS,
+		.ref_grab = obj_mnt_ns_grab,
+		.ref_drop = obj_mnt_ns_drop,
+		.ref_users = obj_mnt_ns_users,
+	},
 	/* user_ns object */
 	{
 		.obj_name = "USER_NS",
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 3e0937a..64b4b8a 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -10,7 +10,7 @@
  *  distribution for more details.
  */
 
-#define CHECKPOINT_VERSION  4
+#define CHECKPOINT_VERSION  5
 
 /* checkpoint user flags */
 #define CHECKPOINT_SUBTREE	0x1
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 4dc852d..28dfc36 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -90,6 +90,8 @@ enum {
 #define CKPT_HDR_UTS_NS CKPT_HDR_UTS_NS
 	CKPT_HDR_IPC_NS,
 #define CKPT_HDR_IPC_NS CKPT_HDR_IPC_NS
+	CKPT_HDR_MNT_NS,
+#define CKPT_HDR_MNT_NS CKPT_HDR_MNT_NS
 	CKPT_HDR_CAPABILITIES,
 #define CKPT_HDR_CAPABILITIES CKPT_HDR_CAPABILITIES
 	CKPT_HDR_USER_NS,
@@ -216,6 +218,8 @@ enum obj_type {
 #define CKPT_OBJ_UTS_NS CKPT_OBJ_UTS_NS
 	CKPT_OBJ_IPC_NS,
 #define CKPT_OBJ_IPC_NS CKPT_OBJ_IPC_NS
+	CKPT_OBJ_MNT_NS,
+#define CKPT_OBJ_MNT_NS CKPT_OBJ_MNT_NS
 	CKPT_OBJ_USER_NS,
 #define CKPT_OBJ_USER_NS CKPT_OBJ_USER_NS
 	CKPT_OBJ_CRED,
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 17b048e..0da0d83 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -255,10 +255,17 @@ int ckpt_collect_ns(struct ckpt_ctx *ctx, struct task_struct *t)
 	 * ipc_ns (shm) may keep references to files: if this is the
 	 * first time we see this ipc_ns (ret > 0), proceed inside.
 	 */
-	if (ret)
+	if (ret) {
 		ret = ckpt_collect_ipc_ns(ctx, nsproxy->ipc_ns);
+		if (ret < 0)
+			goto out;
+	}
 
-	/* TODO: collect other namespaces here */
+	ret = ckpt_obj_collect(ctx, nsproxy->mnt_ns, CKPT_OBJ_MNT_NS);
+	if (ret < 0)
+		goto out;
+
+	ret = 0;
  out:
 	put_nsproxy(nsproxy);
 	return ret;
@@ -282,7 +289,10 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
 		goto out;
 	h->ipc_objref = ret;
 
-	/* TODO: Write other namespaces here */
+	/* FIXME: for now, only marked visited to pacify leaks */
+	ret = ckpt_obj_visit(ctx, nsproxy->mnt_ns, CKPT_OBJ_MNT_NS);
+	if (ret < 0)
+		goto out;
 
 	ret = ckpt_write_obj(ctx, &h->h);
  out:
-- 
1.6.3.3
