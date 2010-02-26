From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 02/12] Add ability to register checkpoint obj ops
Date: Fri, 26 Feb 2010 00:45:03 -0800
Message-ID: <5d3d0d1f5d294ccd13453a19c15828faa789bb0f.1267173752.git.matthltc@us.ibm.com>
References: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
	<3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

The array indices are allocated staticly by the CKPT_OBJ_* enums in
include/linux/checkpoint_hdr.h. There's no sanity checking here but
if it's desirable we can do checks like:

	BUG_ON(ops->obj_type >= CKPT_OBJ_MAX);       /* bounds check */
	BUG_ON(ckpt_obj_ops[ops->obj_type] != NULL); /* Something has
				already registered or (also bad) re-registration				is occurring. */

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c             |   16 +++++-----------
 include/linux/checkpoint.h       |    6 ++++++
 include/linux/checkpoint_types.h |   11 +++++++++++
 3 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 1ca7f47..832520d 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -25,17 +25,6 @@
 #include <linux/checkpoint_hdr.h>
 #include <net/sock.h>
 
-/* object operations */
-struct ckpt_obj_ops {
-	char *obj_name;
-	enum obj_type obj_type;
-	void (*ref_drop)(void *ptr, int lastref);
-	int (*ref_grab)(void *ptr);
-	int (*ref_users)(void *ptr);
-	int (*checkpoint)(struct ckpt_ctx *ctx, void *ptr);
-	void *(*restore)(struct ckpt_ctx *ctx);
-};
-
 struct ckpt_obj {
 	int users;
 	int objref;
@@ -571,6 +560,11 @@ static const struct ckpt_obj_ops *ckpt_obj_ops[] = {
 	[CKPT_OBJ_SECURITY] = &ckpt_obj_security_strings_ops,
 };
 
+void register_checkpoint_obj(const struct ckpt_obj_ops *ops)
+{
+	ckpt_obj_ops[ops->obj_type] = ops;
+}
+
 
 #define CKPT_OBJ_HASH_NBITS  10
 #define CKPT_OBJ_HASH_TOTAL  (1UL << CKPT_OBJ_HASH_NBITS)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 7101d6f..e4d668a 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -485,6 +485,12 @@ extern void _ckpt_msg_complete(struct ckpt_ctx *ctx);
 	_do_ckpt_msg(ctx, err, "[E @ %s:%d]" fmt, __func__, __LINE__, ##args); \
 } while (0)
 
+struct ckpt_obj_ops;
+extern void register_checkpoint_obj(const struct ckpt_obj_ops *ops);
+#else
+struct ckpt_obj_ops;
+static inline void register_checkpoint_obj(const struct ckpt_obj_ops *ops)
+{}
 #endif /* CONFIG_CHECKPOINT */
 #endif /* __KERNEL__ */
 
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index 5d5e00d..94e6e37 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -23,6 +23,17 @@
 #include <linux/wait.h>
 #include <linux/security.h>
 
+/* object operations */
+struct ckpt_obj_ops {
+	char *obj_name;
+	int obj_type;
+	void (*ref_drop)(void *ptr, int lastref);
+	int (*ref_grab)(void *ptr);
+	int (*ref_users)(void *ptr);
+	int (*checkpoint)(struct ckpt_ctx *ctx, void *ptr);
+	void *(*restore)(struct ckpt_ctx *ctx);
+};
+
 struct ckpt_stats {
 	int uts_ns;
 	int ipc_ns;
-- 
1.6.3.3
