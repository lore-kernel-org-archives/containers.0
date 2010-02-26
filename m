From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 11/12] Move user namespace ckpt_obj_ops
Date: Fri, 26 Feb 2010 00:45:12 -0800
Message-ID: <7b96f1f6619a80594d0316016939eacfa04962be.1267173752.git.matthltc@us.ibm.com>
References: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
	<3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc@us.ibm.com>
	<5d3d0d1f5d294ccd13453a19c15828faa789bb0f.1267173752.git.matthltc@us.ibm.com>
	<06ebd7532cbaeb5d2b13fc7b02db194840098b6d.1267173752.git.matthltc@us.ibm.com>
	<e3af5631e13c748bb0cc16fb9281b582f4d8d079.1267173752.git.matthltc@us.ibm.com>
	<4f4de129024a206dad6ef5484d3eed3b8426d16d.1267173752.git.matthltc@us.ibm.com>
	<d07190b20cd4f1db380c11e1baaa337a814626f6.1267173752.git.matthltc@us.ibm.com>
	<6351cfb95abae11068f8e4d8a700562ac0bd211d.1267173752.git.matthltc@us.ibm.com>
	<385a4b0ab0cf5cf2bf2fc33a8668ae0d98c45687.1267173752.git.matthltc@us.ibm.com>
	<c3d5659bdb38b39c1542d9c87381579cfd9ad5ba.1267173752.git.matthltc@us.ibm.com>
	<a400fe6d2e9e15803dd364cb551e34d6ba75b099.1267173752.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <a400fe6d2e9e15803dd364cb551e34d6ba75b099.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

IMPORTANT: Removes the ability to checkpoint/restore an initial user
namespace when CONFIG_USER_NS is not selected.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/Makefile            |    3 +-
 checkpoint/namespace.c         |   59 ----------------------------------------
 checkpoint/objhash.c           |   20 -------------
 include/linux/user_namespace.h |    1 -
 kernel/user_namespace.c        |   26 +++++++++++++++++
 5 files changed, 27 insertions(+), 82 deletions(-)
 delete mode 100644 checkpoint/namespace.c

diff --git a/checkpoint/Makefile b/checkpoint/Makefile
index 9571af3..5aa6a75 100644
--- a/checkpoint/Makefile
+++ b/checkpoint/Makefile
@@ -7,5 +7,4 @@ obj-$(CONFIG_CHECKPOINT) += \
 	objhash.o \
 	checkpoint.o \
 	restart.o \
-	process.o \
-	namespace.o
+	process.o
diff --git a/checkpoint/namespace.c b/checkpoint/namespace.c
deleted file mode 100644
index 538bd4a..0000000
--- a/checkpoint/namespace.c
+++ /dev/null
@@ -1,59 +0,0 @@
-/*
- *  Checkpoint namespaces
- *
- *  Copyright (C) 2009 Oren Laadan
- *
- *  This file is subject to the terms and conditions of the GNU General Public
- *  License.  See the file COPYING in the main directory of the Linux
- *  distribution for more details.
- */
-
-/* default debug level for output */
-#define CKPT_DFLAG  CKPT_DSYS
-
-#include <linux/nsproxy.h>
-#include <linux/user_namespace.h>
-
-#include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
-
-/*
- * user_ns  -  trivial checkpoint/restore for !CONFIG_USER_NS case
- */
-#ifndef CONFIG_USER_NS
-int checkpoint_userns(struct ckpt_ctx *ctx, void *ptr)
-{
-	struct ckpt_hdr_user_ns *h;
-	int ret;
-
-	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_USER_NS);
-	if (!h)
-		return -ENOMEM;
-	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
-	ckpt_hdr_put(ctx, h);
-	return ret;
-}
-
-void *restore_userns(struct ckpt_ctx *ctx)
-{
-	struct ckpt_hdr_user_ns *h;
-	struct user_namespace *ns;
-
-	/* complain if image contains multiple namespaces */
-	if (ctx->stats.user_ns)
-		return ERR_PTR(-EEXIST);
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_USER_NS);
-	if (IS_ERR(h))
-		return ERR_PTR(PTR_ERR(h));
-
-	if (h->creator_ref)
-		ns = ERR_PTR(-EINVAL);
-	else
-		ns = get_user_ns(current_user_ns());
-
-	ctx->stats.user_ns++;
-	ckpt_hdr_put(ctx, h);
-	return ns;
-}
-#endif
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 5678943..70c54f5 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -167,17 +167,6 @@ static void obj_user_drop(void *ptr, int lastref)
 	free_uid((struct user_struct *) ptr);
 }
 
-static int obj_userns_grab(void *ptr)
-{
-	get_user_ns((struct user_namespace *) ptr);
-	return 0;
-}
-
-static void obj_userns_drop(void *ptr, int lastref)
-{
-	put_user_ns((struct user_namespace *) ptr);
-}
-
 static int obj_groupinfo_grab(void *ptr)
 {
 	get_group_info((struct group_info *) ptr);
@@ -332,15 +321,6 @@ static const struct ckpt_obj_ops ckpt_obj_mnt_ns_ops = {
 	.ref_drop = obj_mnt_ns_drop,
 	.ref_users = obj_mnt_ns_users,
 };
-/* user_ns object */
-static const struct ckpt_obj_ops ckpt_obj_user_ns_ops = {
-	.obj_name = "USER_NS",
-	.obj_type = CKPT_OBJ_USER_NS,
-	.ref_drop = obj_userns_drop,
-	.ref_grab = obj_userns_grab,
-	.checkpoint = checkpoint_userns,
-	.restore = restore_userns,
-};
 /* struct cred */
 static const struct ckpt_obj_ops ckpt_obj_cred_ops = {
 	.obj_name = "CRED",
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index f6ea75d..96a74bc 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -59,7 +59,6 @@ static inline int create_user_ns(struct cred *new)
 static inline void put_user_ns(struct user_namespace *ns)
 {
 }
-
 #endif
 
 #endif /* _LINUX_USER_H */
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 3a35b50..f279942 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -191,4 +191,30 @@ void *restore_userns(struct ckpt_ctx *ctx)
 {
 	return (void *) do_restore_userns(ctx);
 }
+
+static int obj_userns_grab(void *ptr)
+{
+	get_user_ns((struct user_namespace *) ptr);
+	return 0;
+}
+
+static void obj_userns_drop(void *ptr, int lastref)
+{
+	put_user_ns((struct user_namespace *) ptr);
+}
+
+static const struct ckpt_obj_ops ckpt_obj_user_ns_ops = {
+	.obj_name = "USER_NS",
+	.obj_type = CKPT_OBJ_USER_NS,
+	.ref_drop = obj_userns_drop,
+	.ref_grab = obj_userns_grab,
+	.checkpoint = checkpoint_userns,
+	.restore = restore_userns,
+};
+
+int __init userns_init(void)
+{
+	register_checkpoint_obj(&ckpt_obj_user_ns_ops);
+	return 0;
+}
 #endif
-- 
1.6.3.3
