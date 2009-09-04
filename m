From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/6] c/r: [pty 1/2] allow allocation of desired pty slave
Date: Fri,  4 Sep 2009 10:20:47 -0400
Message-ID: <1252074054-22241-3-git-send-email-orenl@librato.com>
References: <1252074054-22241-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1252074054-22241-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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

During restart, we need to allocate pty slaves with the same
identifiers as recorded during checkpoint. Modify the allocation code
to allow an in-kernel caller to request a specific slave identifier.

For this, add a new field to task_struct - 'required_id'. It will
hold the desired identifier when restoring a (master) pty.

The code in ptmx_open() will use this value only for tasks that try to
open /dev/ptmx that are restarting (PF_RESTARTING), and if the value
isn't CKPT_REQUIRED_NONE (-1).

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/sys.c           |    7 +++++++
 drivers/char/pty.c         |    9 +++++++--
 fs/devpts/inode.c          |   10 ++++++++--
 include/linux/checkpoint.h |    2 ++
 include/linux/devpts_fs.h  |    2 +-
 include/linux/sched.h      |    1 +
 6 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 525182a..3db18f7 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -339,6 +339,13 @@ SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
 	return ret;
 }
 
+static int __init checkpoint_init(void)
+{
+	init_task.required_id = CKPT_REQUIRED_NONE;
+	return 0;
+}
+__initcall(checkpoint_init);
+
 
 /* 'ckpt_debug_level' controls the verbosity level of c/r code */
 #ifdef CONFIG_CHECKPOINT_DEBUG
diff --git a/drivers/char/pty.c b/drivers/char/pty.c
index 6e6942c..326c2e9 100644
--- a/drivers/char/pty.c
+++ b/drivers/char/pty.c
@@ -633,12 +633,17 @@ static int __ptmx_open(struct inode *inode, struct file *filp)
 {
 	struct tty_struct *tty;
 	int retval;
-	int index;
+	int index = 0;
 
 	nonseekable_open(inode, filp);
 
+#ifdef CONFIG_CHECKPOINT
+	/* when restarting, request specific index */
+	if (current->flags & PF_RESTARTING)
+		index = (int) current->required_id;
+#endif
 	/* find a device that is not in use. */
-	index = devpts_new_index(inode);
+	index = devpts_new_index(inode, index);
 	if (index < 0)
 		return index;
 
diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 75efb02..8921726 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -433,7 +433,7 @@ static struct file_system_type devpts_fs_type = {
  * to the System V naming convention
  */
 
-int devpts_new_index(struct inode *ptmx_inode)
+int devpts_new_index(struct inode *ptmx_inode, int req_idx)
 {
 	struct super_block *sb = pts_sb_from_inode(ptmx_inode);
 	struct pts_fs_info *fsi = DEVPTS_SB(sb);
@@ -445,7 +445,8 @@ retry:
 		return -ENOMEM;
 
 	mutex_lock(&allocated_ptys_lock);
-	ida_ret = ida_get_new(&fsi->allocated_ptys, &index);
+	index = (req_idx >= 0 ? req_idx : 0);
+	ida_ret = ida_get_new_above(&fsi->allocated_ptys, index, &index);
 	if (ida_ret < 0) {
 		mutex_unlock(&allocated_ptys_lock);
 		if (ida_ret == -EAGAIN)
@@ -453,6 +454,11 @@ retry:
 		return -EIO;
 	}
 
+	if (req_idx >= 0 && index != req_idx) {
+		ida_remove(&fsi->allocated_ptys, index);
+		mutex_unlock(&allocated_ptys_lock);
+		return -EBUSY;
+	}
 	if (index >= pty_limit) {
 		ida_remove(&fsi->allocated_ptys, index);
 		mutex_unlock(&allocated_ptys_lock);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 1d050f8..473164e 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -46,6 +46,8 @@
 #define CHECKPOINT_USER_FLAGS		CHECKPOINT_SUBTREE
 #define RESTART_USER_FLAGS		(RESTART_TASKSELF | RESTART_FROZEN)
 
+#define CKPT_REQUIRED_NONE  ((unsigned long) -1L)
+
 extern void exit_checkpoint(struct task_struct *tsk);
 
 extern int ckpt_kwrite(struct ckpt_ctx *ctx, void *buf, int count);
diff --git a/include/linux/devpts_fs.h b/include/linux/devpts_fs.h
index 5ce0e5f..14948ee 100644
--- a/include/linux/devpts_fs.h
+++ b/include/linux/devpts_fs.h
@@ -17,7 +17,7 @@
 
 #ifdef CONFIG_UNIX98_PTYS
 
-int devpts_new_index(struct inode *ptmx_inode);
+int devpts_new_index(struct inode *ptmx_inode, int req_idx);
 void devpts_kill_index(struct inode *ptmx_inode, int idx);
 /* mknod in devpts */
 int devpts_pty_new(struct inode *ptmx_inode, struct tty_struct *tty);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0e67de7..f6f1350 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1481,6 +1481,7 @@ struct task_struct {
 #endif /* CONFIG_TRACING */
 #ifdef CONFIG_CHECKPOINT
 	struct ckpt_ctx *checkpoint_ctx;
+	unsigned long required_id;
 #endif
 };
 
-- 
1.6.0.4
