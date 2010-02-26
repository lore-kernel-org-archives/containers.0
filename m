From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 01/12] Prepare to move ckpt_obj_ops definitions
Date: Fri, 26 Feb 2010 00:45:02 -0800
Message-ID: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc@us.ibm.com>
References: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1267173913-28084-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

We are going to distribute the contents of this array to their respective
kernel source files. For example, the signal and sighand ckpt_obj_ops will
go into kernel/signal.c.

Then each portion of the kernel will register its checkpoint objects and
their operations in their respective __init functions. This also eventually
gets rid of a bunch of function declarations in include/linux/checkpoint.h.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c |  420 ++++++++++++++++++++++++++------------------------
 1 files changed, 219 insertions(+), 201 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 693ad56..1ca7f47 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -25,9 +25,6 @@
 #include <linux/checkpoint_hdr.h>
 #include <net/sock.h>
 
-struct ckpt_obj;
-struct ckpt_obj_ops;
-
 /* object operations */
 struct ckpt_obj_ops {
 	char *obj_name;
@@ -44,7 +41,7 @@ struct ckpt_obj {
 	int objref;
 	int flags;
 	void *ptr;
-	struct ckpt_obj_ops *ops;
+	const struct ckpt_obj_ops *ops;
 	struct hlist_node hash;
 	struct hlist_node next;
 };
@@ -356,200 +353,222 @@ static void *restore_lsm_string_wrap(struct ckpt_ctx *ctx)
 	return (void *)restore_lsm_string(ctx);
 }
 
+/* ignored object */
+static const struct ckpt_obj_ops ckpt_obj_ignored_ops = {
+	.obj_name = "IGNORED",
+	.obj_type = CKPT_OBJ_IGNORE,
+	.ref_drop = obj_no_drop,
+	.ref_grab = obj_no_grab,
+};
 
-static struct ckpt_obj_ops ckpt_obj_ops[] = {
-	/* ignored object */
-	{
-		.obj_name = "IGNORED",
-		.obj_type = CKPT_OBJ_IGNORE,
-		.ref_drop = obj_no_drop,
-		.ref_grab = obj_no_grab,
-	},
-	/* inode object */
-	{
-		.obj_name = "INODE",
-		.obj_type = CKPT_OBJ_INODE,
-		.ref_drop = obj_inode_drop,
-		.ref_grab = obj_inode_grab,
-	},
-	/* files_struct object */
-	{
-		.obj_name = "FILE_TABLE",
-		.obj_type = CKPT_OBJ_FILE_TABLE,
-		.ref_drop = obj_file_table_drop,
-		.ref_grab = obj_file_table_grab,
-		.ref_users = obj_file_table_users,
-		.checkpoint = checkpoint_file_table,
-		.restore = restore_file_table,
-	},
-	/* file object */
-	{
-		.obj_name = "FILE",
-		.obj_type = CKPT_OBJ_FILE,
-		.ref_drop = obj_file_drop,
-		.ref_grab = obj_file_grab,
-		.ref_users = obj_file_users,
-		.checkpoint = checkpoint_file,
-		.restore = restore_file,
-	},
-	/* mm object */
-	{
-		.obj_name = "MM",
-		.obj_type = CKPT_OBJ_MM,
-		.ref_drop = obj_mm_drop,
-		.ref_grab = obj_mm_grab,
-		.ref_users = obj_mm_users,
-		.checkpoint = checkpoint_mm,
-		.restore = restore_mm,
-	},
-	/* fs object */
-	{
-		.obj_name = "FS",
-		.obj_type = CKPT_OBJ_FS,
-		.ref_drop = obj_fs_drop,
-		.ref_grab = obj_fs_grab,
-		.ref_users = obj_fs_users,
-		.checkpoint = checkpoint_fs,
-		.restore = restore_fs,
-	},
-	/* sighand object */
-	{
-		.obj_name = "SIGHAND",
-		.obj_type = CKPT_OBJ_SIGHAND,
-		.ref_drop = obj_sighand_drop,
-		.ref_grab = obj_sighand_grab,
-		.ref_users = obj_sighand_users,
-		.checkpoint = checkpoint_sighand,
-		.restore = restore_sighand,
-	},
-	/* signal object */
-	{
-		.obj_name = "SIGNAL",
-		.obj_type = CKPT_OBJ_SIGNAL,
-		.ref_drop = obj_no_drop,
-		.ref_grab = obj_no_grab,
-	},
-	/* ns object */
-	{
-		.obj_name = "NSPROXY",
-		.obj_type = CKPT_OBJ_NS,
-		.ref_drop = obj_ns_drop,
-		.ref_grab = obj_ns_grab,
-		.ref_users = obj_ns_users,
-		.checkpoint = checkpoint_ns,
-		.restore = restore_ns,
-	},
-	/* uts_ns object */
-	{
-		.obj_name = "UTS_NS",
-		.obj_type = CKPT_OBJ_UTS_NS,
-		.ref_drop = obj_uts_ns_drop,
-		.ref_grab = obj_uts_ns_grab,
-		.ref_users = obj_uts_ns_users,
-		.checkpoint = checkpoint_uts_ns,
-		.restore = restore_uts_ns,
-	},
-	/* ipc_ns object */
-	{
-		.obj_name = "IPC_NS",
-		.obj_type = CKPT_OBJ_IPC_NS,
-		.ref_drop = obj_ipc_ns_drop,
-		.ref_grab = obj_ipc_ns_grab,
-		.ref_users = obj_ipc_ns_users,
-		.checkpoint = checkpoint_ipc_ns,
-		.restore = restore_ipc_ns,
-	},
-	/* mnt_ns object */
-	{
-		.obj_name = "MOUNTS NS",
-		.obj_type = CKPT_OBJ_MNT_NS,
-		.ref_grab = obj_mnt_ns_grab,
-		.ref_drop = obj_mnt_ns_drop,
-		.ref_users = obj_mnt_ns_users,
-	},
-	/* user_ns object */
-	{
-		.obj_name = "USER_NS",
-		.obj_type = CKPT_OBJ_USER_NS,
-		.ref_drop = obj_userns_drop,
-		.ref_grab = obj_userns_grab,
-		.checkpoint = checkpoint_userns,
-		.restore = restore_userns,
-	},
-	/* struct cred */
-	{
-		.obj_name = "CRED",
-		.obj_type = CKPT_OBJ_CRED,
-		.ref_drop = obj_cred_drop,
-		.ref_grab = obj_cred_grab,
-		.checkpoint = checkpoint_cred,
-		.restore = restore_cred,
-	},
-	/* user object */
-	{
-		.obj_name = "USER",
-		.obj_type = CKPT_OBJ_USER,
-		.ref_drop = obj_user_drop,
-		.ref_grab = obj_user_grab,
-		.checkpoint = checkpoint_user,
-		.restore = restore_user,
-	},
-	/* struct groupinfo */
-	{
-		.obj_name = "GROUPINFO",
-		.obj_type = CKPT_OBJ_GROUPINFO,
-		.ref_drop = obj_groupinfo_drop,
-		.ref_grab = obj_groupinfo_grab,
-		.checkpoint = checkpoint_groupinfo,
-		.restore = restore_groupinfo,
-	},
-	/* sock object */
-	{
-		.obj_name = "SOCKET",
-		.obj_type = CKPT_OBJ_SOCK,
-		.ref_drop = obj_sock_drop,
-		.ref_grab = obj_sock_grab,
-		.ref_users = obj_sock_users,
-		.checkpoint = checkpoint_sock,
-		.restore = restore_sock,
-	},
-	/* struct tty_struct */
-	{
-		.obj_name = "TTY",
-		.obj_type = CKPT_OBJ_TTY,
-		.ref_drop = obj_tty_drop,
-		.ref_grab = obj_tty_grab,
-		.ref_users = obj_tty_users,
-		.checkpoint = checkpoint_tty,
-		.restore = restore_tty,
-	},
-	/*
-	 * LSM void *security on objhash - at checkpoint
-	 * We don't take a ref because we won't be doing
-	 * anything more with this void* - unless we happen
-	 * to run into it again through some other objects's
-	 * ->security (in which case that object has it pinned).
-	 */
-	{
-		.obj_name = "SECURITY PTR",
-		.obj_type = CKPT_OBJ_SECURITY_PTR,
-		.ref_drop = obj_no_drop,
-		.ref_grab = obj_no_grab,
-	},
-	/*
-	 * LSM security strings - at restart
-	 * This is a struct which we malloc during restart and
-	 * must be freed (by objhash cleanup) at the end of
-	 * restart
-	 */
-	{
-		.obj_name = "SECURITY STRING",
-		.obj_type = CKPT_OBJ_SECURITY,
-		.ref_grab = lsm_string_grab,
-		.ref_drop = lsm_string_drop,
-		.checkpoint = checkpoint_lsm_string,
-		.restore = restore_lsm_string_wrap,
-	},
+/* inode object */
+static const struct ckpt_obj_ops ckpt_obj_inode_ops = {
+	.obj_name = "INODE",
+	.obj_type = CKPT_OBJ_INODE,
+	.ref_drop = obj_inode_drop,
+	.ref_grab = obj_inode_grab,
+};
+
+/* files_struct object */
+static const struct ckpt_obj_ops ckpt_obj_files_struct_ops = {
+	.obj_name = "FILE_TABLE",
+	.obj_type = CKPT_OBJ_FILE_TABLE,
+	.ref_drop = obj_file_table_drop,
+	.ref_grab = obj_file_table_grab,
+	.ref_users = obj_file_table_users,
+	.checkpoint = checkpoint_file_table,
+	.restore = restore_file_table,
+};
+/* file object */
+static const struct ckpt_obj_ops ckpt_obj_file_ops = {
+	.obj_name = "FILE",
+	.obj_type = CKPT_OBJ_FILE,
+	.ref_drop = obj_file_drop,
+	.ref_grab = obj_file_grab,
+	.ref_users = obj_file_users,
+	.checkpoint = checkpoint_file,
+	.restore = restore_file,
+};
+/* mm object */
+static const struct ckpt_obj_ops ckpt_obj_mm_ops = {
+	.obj_name = "MM",
+	.obj_type = CKPT_OBJ_MM,
+	.ref_drop = obj_mm_drop,
+	.ref_grab = obj_mm_grab,
+	.ref_users = obj_mm_users,
+	.checkpoint = checkpoint_mm,
+	.restore = restore_mm,
+};
+/* fs object */
+static const struct ckpt_obj_ops ckpt_obj_fs_ops = {
+	.obj_name = "FS",
+	.obj_type = CKPT_OBJ_FS,
+	.ref_drop = obj_fs_drop,
+	.ref_grab = obj_fs_grab,
+	.ref_users = obj_fs_users,
+	.checkpoint = checkpoint_fs,
+	.restore = restore_fs,
+};
+/* sighand object */
+static const struct ckpt_obj_ops ckpt_obj_sighand_ops = {
+	.obj_name = "SIGHAND",
+	.obj_type = CKPT_OBJ_SIGHAND,
+	.ref_drop = obj_sighand_drop,
+	.ref_grab = obj_sighand_grab,
+	.ref_users = obj_sighand_users,
+	.checkpoint = checkpoint_sighand,
+	.restore = restore_sighand,
+};
+/* signal object */
+static const struct ckpt_obj_ops ckpt_obj_signal_ops = {
+	.obj_name = "SIGNAL",
+	.obj_type = CKPT_OBJ_SIGNAL,
+	.ref_drop = obj_no_drop,
+	.ref_grab = obj_no_grab,
+};
+/* ns object */
+static const struct ckpt_obj_ops ckpt_obj_nsproxy_ops = {
+	.obj_name = "NSPROXY",
+	.obj_type = CKPT_OBJ_NS,
+	.ref_drop = obj_ns_drop,
+	.ref_grab = obj_ns_grab,
+	.ref_users = obj_ns_users,
+	.checkpoint = checkpoint_ns,
+	.restore = restore_ns,
+};
+/* uts_ns object */
+static const struct ckpt_obj_ops ckpt_obj_uts_ns_ops = {
+	.obj_name = "UTS_NS",
+	.obj_type = CKPT_OBJ_UTS_NS,
+	.ref_drop = obj_uts_ns_drop,
+	.ref_grab = obj_uts_ns_grab,
+	.ref_users = obj_uts_ns_users,
+	.checkpoint = checkpoint_uts_ns,
+	.restore = restore_uts_ns,
+};
+/* ipc_ns object */
+static const struct ckpt_obj_ops ckpt_obj_ipc_ns_ops = {
+	.obj_name = "IPC_NS",
+	.obj_type = CKPT_OBJ_IPC_NS,
+	.ref_drop = obj_ipc_ns_drop,
+	.ref_grab = obj_ipc_ns_grab,
+	.ref_users = obj_ipc_ns_users,
+	.checkpoint = checkpoint_ipc_ns,
+	.restore = restore_ipc_ns,
+};
+/* mnt_ns object */
+static const struct ckpt_obj_ops ckpt_obj_mnt_ns_ops = {
+	.obj_name = "MOUNTS NS",
+	.obj_type = CKPT_OBJ_MNT_NS,
+	.ref_grab = obj_mnt_ns_grab,
+	.ref_drop = obj_mnt_ns_drop,
+	.ref_users = obj_mnt_ns_users,
+};
+/* user_ns object */
+static const struct ckpt_obj_ops ckpt_obj_user_ns_ops = {
+	.obj_name = "USER_NS",
+	.obj_type = CKPT_OBJ_USER_NS,
+	.ref_drop = obj_userns_drop,
+	.ref_grab = obj_userns_grab,
+	.checkpoint = checkpoint_userns,
+	.restore = restore_userns,
+};
+/* struct cred */
+static const struct ckpt_obj_ops ckpt_obj_cred_ops = {
+	.obj_name = "CRED",
+	.obj_type = CKPT_OBJ_CRED,
+	.ref_drop = obj_cred_drop,
+	.ref_grab = obj_cred_grab,
+	.checkpoint = checkpoint_cred,
+	.restore = restore_cred,
+};
+/* user object */
+static const struct ckpt_obj_ops ckpt_obj_user_ops = {
+	.obj_name = "USER",
+	.obj_type = CKPT_OBJ_USER,
+	.ref_drop = obj_user_drop,
+	.ref_grab = obj_user_grab,
+	.checkpoint = checkpoint_user,
+	.restore = restore_user,
+};
+/* struct groupinfo */
+static const struct ckpt_obj_ops ckpt_obj_groupinfo_ops = {
+	.obj_name = "GROUPINFO",
+	.obj_type = CKPT_OBJ_GROUPINFO,
+	.ref_drop = obj_groupinfo_drop,
+	.ref_grab = obj_groupinfo_grab,
+	.checkpoint = checkpoint_groupinfo,
+	.restore = restore_groupinfo,
+};
+/* sock object */
+static const struct ckpt_obj_ops ckpt_obj_sock_ops = {
+	.obj_name = "SOCKET",
+	.obj_type = CKPT_OBJ_SOCK,
+	.ref_drop = obj_sock_drop,
+	.ref_grab = obj_sock_grab,
+	.ref_users = obj_sock_users,
+	.checkpoint = checkpoint_sock,
+	.restore = restore_sock,
+};
+/* struct tty_struct */
+static const struct ckpt_obj_ops ckpt_obj_tty_ops = {
+	.obj_name = "TTY",
+	.obj_type = CKPT_OBJ_TTY,
+	.ref_drop = obj_tty_drop,
+	.ref_grab = obj_tty_grab,
+	.ref_users = obj_tty_users,
+	.checkpoint = checkpoint_tty,
+	.restore = restore_tty,
+};
+/*
+ * LSM void *security on objhash - at checkpoint
+ * We don't take a ref because we won't be doing
+ * anything more with this void* - unless we happen
+ * to run into it again through some other objects's
+ * ->security (in which case that object has it pinned).
+ */
+static const struct ckpt_obj_ops ckpt_obj_security_ptr_ops = {
+	.obj_name = "SECURITY PTR",
+	.obj_type = CKPT_OBJ_SECURITY_PTR,
+	.ref_drop = obj_no_drop,
+	.ref_grab = obj_no_grab,
+};
+/*
+ * LSM security strings - at restart
+ * This is a struct which we malloc during restart and
+ * must be freed (by objhash cleanup) at the end of
+ * restart
+ */
+static const struct ckpt_obj_ops ckpt_obj_security_strings_ops = {
+	.obj_name = "SECURITY STRING",
+	.obj_type = CKPT_OBJ_SECURITY,
+	.ref_grab = lsm_string_grab,
+	.ref_drop = lsm_string_drop,
+	.checkpoint = checkpoint_lsm_string,
+	.restore = restore_lsm_string_wrap,
+};
+
+static const struct ckpt_obj_ops *ckpt_obj_ops[] = {
+	[CKPT_OBJ_IGNORE] = &ckpt_obj_ignored_ops,
+	[CKPT_OBJ_INODE] = &ckpt_obj_inode_ops,
+	[CKPT_OBJ_FILE_TABLE] = &ckpt_obj_files_struct_ops,
+	[CKPT_OBJ_FILE] = &ckpt_obj_file_ops,
+	[CKPT_OBJ_MM] = &ckpt_obj_mm_ops,
+	[CKPT_OBJ_FS] = &ckpt_obj_fs_ops,
+	[CKPT_OBJ_SIGHAND] = &ckpt_obj_sighand_ops,
+	[CKPT_OBJ_SIGNAL] = &ckpt_obj_signal_ops,
+	[CKPT_OBJ_NS] = &ckpt_obj_nsproxy_ops,
+	[CKPT_OBJ_UTS_NS] = &ckpt_obj_uts_ns_ops,
+	[CKPT_OBJ_IPC_NS] = &ckpt_obj_ipc_ns_ops,
+	[CKPT_OBJ_MNT_NS] = &ckpt_obj_mnt_ns_ops,
+	[CKPT_OBJ_USER_NS] = &ckpt_obj_mnt_ns_ops,
+	[CKPT_OBJ_CRED] = &ckpt_obj_cred_ops,
+	[CKPT_OBJ_USER] = &ckpt_obj_user_ops,
+	[CKPT_OBJ_GROUPINFO] = &ckpt_obj_groupinfo_ops,
+	[CKPT_OBJ_SOCK] = &ckpt_obj_sock_ops,
+	[CKPT_OBJ_TTY] = &ckpt_obj_tty_ops,
+	[CKPT_OBJ_SECURITY_PTR] = &ckpt_obj_security_ptr_ops,
+	[CKPT_OBJ_SECURITY] = &ckpt_obj_security_strings_ops,
 };
 
 
@@ -652,7 +671,7 @@ static inline int obj_alloc_objref(struct ckpt_ctx *ctx)
 static struct ckpt_obj *obj_new(struct ckpt_ctx *ctx, void *ptr,
 				int objref, enum obj_type type)
 {
-	struct ckpt_obj_ops *ops = &ckpt_obj_ops[type];
+	const struct ckpt_obj_ops *ops = ckpt_obj_ops[type];
 	struct ckpt_obj *obj;
 	int i, ret;
 
@@ -1041,7 +1060,7 @@ int ckpt_obj_visited(struct ckpt_ctx *ctx)
  */
 int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h)
 {
-	struct ckpt_obj_ops *ops;
+	const struct ckpt_obj_ops *ops;
 	struct ckpt_obj *obj;
 	void *ptr = NULL;
 
@@ -1051,7 +1070,7 @@ int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_objref *h)
 	if (h->objref <= 0)
 		return -EINVAL;
 
-	ops = &ckpt_obj_ops[h->objtype];
+	ops = ckpt_obj_ops[h->objtype];
 	BUG_ON(ops->obj_type != h->objtype);
 
 	if (ops->restore)
@@ -1209,4 +1228,3 @@ out:
 	ckpt_hdr_put(ctx, h);
 	return l;
 }
-
-- 
1.6.3.3
