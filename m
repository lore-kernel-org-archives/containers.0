From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 08/11] udpate kernel headers: support for pids objects
Date: Mon,  7 Feb 2011 12:21:29 -0500
Message-ID: <1297099292-18772-9-git-send-email-orenl@cs.columbia.edu>
References: <1297099292-18772-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1297099292-18772-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

---
 include/linux/checkpoint_hdr.h |   29 ++++++++++++++++++++++++-----
 1 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index f7c4d9a..227bfbe 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -94,7 +94,9 @@ enum {
 	CKPT_HDR_SECURITY,
 #define CKPT_HDR_SECURITY CKPT_HDR_SECURITY
 
-	CKPT_HDR_TREE = 101,
+	CKPT_HDR_PIDS = 101,
+#define CKPT_HDR_PIDS CKPT_HDR_PIDS
+	CKPT_HDR_TREE,
 #define CKPT_HDR_TREE CKPT_HDR_TREE
 	CKPT_HDR_TASK,
 #define CKPT_HDR_TASK CKPT_HDR_TASK
@@ -232,6 +234,8 @@ struct ckpt_hdr_objref {
 enum obj_type {
 	CKPT_OBJ_IGNORE = 0,
 #define CKPT_OBJ_IGNORE CKPT_OBJ_IGNORE
+	CKPT_OBJ_PID,
+#define CKPT_OBJ_PID CKPT_OBJ_PID
 	CKPT_OBJ_INODE,
 #define CKPT_OBJ_INODE CKPT_OBJ_INODE
 	CKPT_OBJ_FILE_TABLE,
@@ -343,24 +347,39 @@ struct ckpt_hdr_container {
 	 */
 } __attribute__((aligned(8)));;
 
+/* pids array */
+struct ckpt_hdr_pids {
+	struct ckpt_hdr h;
+	__u32 nr_pids;
+	__u32 nr_vpids;
+	__u32 offset;
+} __attribute__((aligned(8)));
+
+struct ckpt_pids {
+	__u32 depth;
+	__s32 numbers[1];
+} __attribute__((aligned(8)));
+
 /* task tree */
 struct ckpt_hdr_tree {
 	struct ckpt_hdr h;
-	__s32 nr_tasks;
+	__u32 nr_tasks;
 } __attribute__((aligned(8)));
 
-struct ckpt_pids {
+struct ckpt_task_pids {
 	/* These pids are in the root_nsproxy's pid ns */
 	__s32 vpid;
 	__s32 vppid;
 	__s32 vtgid;
 	__s32 vpgid;
 	__s32 vsid;
-	__s32 depth; /* pid namespace depth relative to container init */
+	__u32 depth;
 } __attribute__((aligned(8)));
 
 /* pids */
-#define CKPT_PID_NULL -1
+/* (negative but not valid error) */
+#define CKPT_PID_NULL (-4096) /* null pid pointer */
+#define CKPT_PID_ROOT (-4097) /* pid same as root task */
 
 /* task data */
 struct ckpt_hdr_task {
-- 
1.7.1
