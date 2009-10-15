From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cr: add container configuration header
Date: Thu, 15 Oct 2009 13:48:27 -0500
Message-ID: <20091015184827.GA30444@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Add a container configuration section to the checkpoint header.
This will contain information such as the LSM name and policy
identifier, potentially network interface and container-wide
mounts.

[ pulled out of the LSM c/r patchset ]

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Documentation/checkpoint/readme.txt |   36 ++++++++++++++++++++++++++++++++--
 checkpoint/checkpoint.c             |   18 +++++++++++++++++
 checkpoint/restart.c                |   18 +++++++++++++++++
 include/linux/checkpoint.h          |    2 +-
 include/linux/checkpoint_hdr.h      |    7 ++++++
 5 files changed, 77 insertions(+), 4 deletions(-)

diff --git a/Documentation/checkpoint/readme.txt b/Documentation/checkpoint/readme.txt
index 571c469..3eb3dfa 100644
--- a/Documentation/checkpoint/readme.txt
+++ b/Documentation/checkpoint/readme.txt
@@ -161,9 +161,10 @@ in-userspace conversion tools.
 
 The general format of the checkpoint image is as follows:
 1. Image header
-2. Task hierarchy
-3. Tasks' state
-4. Image trailer
+2. Container configuration
+3. Task hierarchy
+4. Tasks' state
+5. Image trailer
 
 The image always begins with a general header that holds a magic
 number, an architecture identifier (little endian format), a format
@@ -172,6 +173,11 @@ version number (@rev), followed by information about the kernel
 checkpoint and the flags given to sys_checkpoint(). This header is
 followed by an arch-specific header.
 
+The container configuration section contains details about the
+security (LSM) configuration.  Network configuration and
+container-wide mounts may also go here, so that the userspace
+restart coordinator can re-create a suitable environment.
+
 The task hierarchy comes next so that userspace tools can read it
 early (even from a stream) and re-create the restarting tasks. This is
 basically an array of all checkpointed tasks, and their relationships
@@ -333,6 +339,30 @@ So that's why we don't want CAP_SYS_ADMIN required up-front. That way
 we will be forced to more carefully review each of those features.
 However, this can be controlled with a sysctl-variable.
 
+LSM
+===
+
+Security modules use custom labels on subjects and objects to
+further mediate access decisions beyond DAC controls.  When
+checkpoint applications, these labels are [ work in progress ]
+checkpointed along with the objects.  At restart, the
+RESTART_KEEP_LSM flag tells the kernel whether re-created objects
+whould keep their checkpointed labels, or get automatically
+recalculated labels.  Since checkpointed labels will only make
+sense to the same LSM which was active at checkpoint time,
+sys_restart() with the RESTART_KEEP_LSM flag will fail with
+-EINVAL if the LSM active at restart is not the same as that
+active at checkpoint.  If RESTART_KEEP_LSM is not specified,
+then objects will be given whatever default labels the LSM and
+their optional policy decide.  Of course, when RESTART_KEEP_LSM
+is specified, the LSM may choose a different label than the
+checkpointed one, or fail the entire restart if the caller
+does not have permission to create objects with the checkpointed
+label.
+
+It should always be safe to take a checkpoint of an application
+under LSM_1, and restart it without the RESTART_KEEP_LSM flag
+under LSM_2.
 
 Kernel interfaces
 =================
diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 5a76d2b..6eb8f3b 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -354,6 +354,21 @@ static int checkpoint_write_header(struct ckpt_ctx *ctx)
 	return checkpoint_write_header_arch(ctx);
 }
 
+/* write the container configuration section */
+static int checkpoint_container(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_container *h;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_CONTAINER);
+	if (!h)
+		return -ENOMEM;
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
 /* write the checkpoint trailer */
 static int checkpoint_write_tail(struct ckpt_ctx *ctx)
 {
@@ -765,6 +780,9 @@ long do_checkpoint(struct ckpt_ctx *ctx, pid_t pid)
 	ret = checkpoint_write_header(ctx);
 	if (ret < 0)
 		goto out;
+	ret = checkpoint_container(ctx);
+	if (ret < 0)
+		goto out;
 	ret = checkpoint_tree(ctx);
 	if (ret < 0)
 		goto out;
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 6679472..32a9fc5 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -624,6 +624,20 @@ static int restore_read_header(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+/* read the container configuration section */
+static int restore_container(struct ckpt_ctx *ctx)
+{
+	int ret = 0;
+	struct ckpt_hdr_container *h;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_CONTAINER);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+	ckpt_hdr_put(ctx, h);
+
+	return ret;
+}
+
 /* read the checkpoint trailer */
 static int restore_read_tail(struct ckpt_ctx *ctx)
 {
@@ -1162,6 +1176,10 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 	ckpt_debug("restore header: %d\n", ret);
 	if (ret < 0)
 		return ret;
+	ret = restore_container(ctx);
+	ckpt_debug("restore container: %d\n", ret);
+	if (ret < 0)
+		return ret;
 	ret = restore_read_tree(ctx);
 	ckpt_debug("restore tree: %d\n", ret);
 	if (ret < 0)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 4b61378..914176c 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -10,7 +10,7 @@
  *  distribution for more details.
  */
 
-#define CHECKPOINT_VERSION  2
+#define CHECKPOINT_VERSION  3
 
 /* checkpoint user flags */
 #define CHECKPOINT_SUBTREE	0x1
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index ca2500d..ff2e4aa 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -63,6 +63,8 @@ enum {
 #define CKPT_HDR_HEADER CKPT_HDR_HEADER
 	CKPT_HDR_HEADER_ARCH,
 #define CKPT_HDR_HEADER_ARCH CKPT_HDR_HEADER_ARCH
+	CKPT_HDR_CONTAINER,
+#define CKPT_HDR_CONTAINER CKPT_HDR_CONTAINER
 	CKPT_HDR_BUFFER,
 #define CKPT_HDR_BUFFER CKPT_HDR_BUFFER
 	CKPT_HDR_STRING,
@@ -247,6 +249,11 @@ struct ckpt_const {
 	__u16 tty_termios_ncc;
 } __attribute__((aligned(8)));
 
+/* container configuration section header */
+struct ckpt_hdr_container {
+	struct ckpt_hdr h;
+};
+
 /* checkpoint image header */
 struct ckpt_hdr_header {
 	struct ckpt_hdr h;
-- 
1.6.1
