From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v2][PATCH 09/10] sysvipc-msq: checkpoint
Date: Tue,  7 Apr 2009 08:31:42 -0400
Message-ID: <1239107503-21941-10-git-send-email-orenl@cs.columbia.edu>
References: <1239107503-21941-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239107503-21941-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Checkpoint of sysvipc message-queues is performed by iterating through
all 'msq' objects and dumping the contents of each one. The message
queued on each 'msq' are dumped with that object.

Message of a specific queue get written one by one. The queue lock
cannot be held while dumping them, but the loop must be protected from
someone (who ?) writing or reading. To do that we grab the lock, then
hijack the entire chain of messages from the queue, drop the lock,
and then safely dump them in a loop. Finally, with the lock held, we
re-attach the chain while verifying that there isn't other (new) data
on that queue.

Writing the message contents themselves is straight forward. The code
is similar to that in ipc/msgutil.c, the main difference being that
we deal with kernel memory and not user memory.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/util_ipc.c          |    9 ++-
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |   18 ++++
 ipc/Makefile                   |    2 +-
 ipc/ckpt_msg.c                 |  204 ++++++++++++++++++++++++++++++++++++++++
 5 files changed, 232 insertions(+), 2 deletions(-)
 create mode 100644 ipc/ckpt_msg.c

diff --git a/checkpoint/util_ipc.c b/checkpoint/util_ipc.c
index 1b791f9..163a106 100644
--- a/checkpoint/util_ipc.c
+++ b/checkpoint/util_ipc.c
@@ -15,7 +15,14 @@
 
 int cr_write_ipcns(struct cr_ctx *ctx, struct ipc_namespace *ipc_ns)
 {
-	return cr_write_ipc_shm(ctx, ipc_ns);
+	int ret;
+
+	ret = cr_write_ipc_shm(ctx, ipc_ns);
+	if (ret < 0)
+		return ret;
+	ret = cr_write_ipc_msg(ctx, ipc_ns);
+
+	return ret;
 }
 
 int cr_read_ipcns(struct cr_ctx *ctx)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 0f49b68..16dd96d 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -155,6 +155,7 @@ extern int cr_write_ipc_shm(struct cr_ctx *ctx, struct ipc_namespace *ipcns);
 extern int cr_read_ipc_shm(struct cr_ctx *ctx);
 extern int cr_ipc_shm_attach(struct file *file,
 			     unsigned long addr, unsigned long flags);
+extern int cr_write_ipc_msg(struct cr_ctx *ctx, struct ipc_namespace *ipcns);
 #endif
 
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index b93b2fc..92b0336 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -66,6 +66,7 @@ enum {
 	CR_HDR_IPC = 401,
 	CR_HDR_IPC_SHM,
 	CR_HDR_IPC_MSG,
+	CR_HDR_IPC_MSG_MSG,
 	CR_HDR_IPC_SEM,
 
 	CR_HDR_TAIL = 5001
@@ -269,4 +270,21 @@ struct cr_hdr_ipc_shm {
 	__u32 objref;
 } __attribute__((aligned(8)));
 
+struct cr_hdr_ipc_msg {
+	struct cr_hdr_ipc_perms perms;
+	__u64 q_stime;
+	__u64 q_rtime;
+	__u64 q_ctime;
+	__u64 q_cbytes;
+	__u64 q_qnum;
+	__u64 q_qbytes;
+	__s32 q_lspid;
+	__s32 q_lrpid;
+} __attribute__((aligned(8)));
+
+struct cr_hdr_ipc_msg_msg {
+	__s32 m_type;
+	__u32 m_ts;
+} __attribute__((aligned(8)));
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/ipc/Makefile b/ipc/Makefile
index 0789ec8..aa20c76 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -8,5 +8,5 @@ obj-$(CONFIG_SYSVIPC_SYSCTL) += ipc_sysctl.o
 obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
-obj-$(CONFIG_CHECKPOINT) += ckpt_shm.o
+obj-$(CONFIG_CHECKPOINT) += ckpt_shm.o ckpt_msg.o
 
diff --git a/ipc/ckpt_msg.c b/ipc/ckpt_msg.c
new file mode 100644
index 0000000..5e11253
--- /dev/null
+++ b/ipc/ckpt_msg.c
@@ -0,0 +1,204 @@
+/*
+ *  Checkpoint/restart - dump state of sysvipc msg
+ *
+ *  Copyright (C) 2009 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/mm.h>
+#include <linux/msg.h>
+#include <linux/shmem_fs.h>
+#include <linux/hugetlb.h>
+#include <linux/rwsem.h>
+#include <linux/sched.h>
+#include <linux/syscalls.h>
+#include <linux/nsproxy.h>
+#include <linux/ipc_namespace.h>
+
+#include <linux/msg.h>	/* needed for util.h that uses 'struct msg_msg' */
+#include "util.h"
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/************************************************************************
+ * ipc checkpoint
+ */
+
+static int cr_fill_ipc_msg_hdr(struct cr_ctx *ctx,
+			       struct cr_hdr_ipc_msg *hh,
+			       struct msg_queue *msq)
+{
+	int ret = 0;
+
+	ipc_lock_by_ptr(&msq->q_perm);
+
+	cr_fill_ipc_perms(&hh->perms, &msq->q_perm);
+
+	hh->q_stime = msq->q_stime;
+	hh->q_rtime = msq->q_rtime;
+	hh->q_ctime = msq->q_ctime;
+	hh->q_cbytes = msq->q_cbytes;
+	hh->q_qnum = msq->q_qnum;
+	hh->q_qbytes = msq->q_qbytes;
+	hh->q_lspid = msq->q_lspid;
+	hh->q_lrpid = msq->q_lrpid;
+
+	ipc_unlock(&msq->q_perm);
+
+	cr_debug("msg: lspid %d rspid %d qnum %lld qbytes %lld\n",
+		 hh->q_lspid, hh->q_lrpid, hh->q_qnum, hh->q_qbytes);
+
+	return ret;
+}
+
+static int cr_write_msg_contents(struct cr_ctx *ctx, struct msg_msg *msg)
+{
+	struct cr_hdr h;
+	struct cr_hdr_ipc_msg_msg *hh;
+	struct msg_msgseg *seg;
+	int total, len;
+	int ret;
+
+	h.type = CR_HDR_IPC_MSG_MSG;
+	h.len = sizeof(*hh);
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+
+	hh->m_type = msg->m_type;
+	hh->m_ts = msg->m_ts;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		return ret;
+
+	total = msg->m_ts;
+	len = min(total, (int) DATALEN_MSG);
+	ret = cr_write_buffer(ctx, (msg + 1), len);
+	if (ret < 0)
+		return ret;
+
+	seg = msg->next;
+	total -= len;
+
+	while (total) {
+		len = min(total, (int) DATALEN_SEG);
+		ret = cr_write_buffer(ctx, (seg + 1), len);
+		if (ret < 0)
+			break;
+		seg = seg->next;
+		total -= len;
+	}
+
+	return ret;
+}
+
+static int cr_write_msg_queue(struct cr_ctx *ctx, struct msg_queue *msq)
+{
+	struct list_head messages;
+	struct msg_msg *msg;
+	int ret = -EBUSY;
+
+	/*
+	 * Scanning the msq requires the lock, but then we can't write
+	 * data out from inside. Instead, we grab the lock, remove all
+	 * messages to our own list, drop the lock, write the messages,
+	 * and finally re-attach the them to the msq with the lock taken.
+	 */
+	ipc_lock_by_ptr(&msq->q_perm);
+	if (!list_empty(&msq->q_receivers))
+		goto unlock;
+	if (!list_empty(&msq->q_senders))
+		goto unlock;
+	if (list_empty(&msq->q_messages))
+		goto unlock;
+	/* temporarily take out all messages */
+	INIT_LIST_HEAD(&messages);
+	list_splice_init(&msq->q_messages, &messages);
+ unlock:
+	ipc_unlock(&msq->q_perm);
+
+	list_for_each_entry(msg, &messages, m_list) {
+		ret = cr_write_msg_contents(ctx, msg);
+		if (ret < 0)
+			break;
+	}
+
+	/* put all the messages back in */
+	ipc_lock_by_ptr(&msq->q_perm);
+	list_splice(&messages, &msq->q_messages);
+	ipc_unlock(&msq->q_perm);
+
+	return ret;
+}
+
+static int cr_do_write_ipc_msg(int id, void *p, void *data)
+{
+	struct cr_hdr h;
+	struct cr_hdr_ipc_msg *hh;
+	struct cr_ctx *ctx = (struct cr_ctx *) data;
+	struct kern_ipc_perm *perm = (struct kern_ipc_perm *) p;
+	struct msg_queue *msq;
+	int ret;
+
+	msq = container_of(perm, struct msg_queue, q_perm);
+
+	h.type = CR_HDR_IPC_MSG;
+	h.len = sizeof(*hh);
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+
+	ret = cr_fill_ipc_msg_hdr(ctx, hh, msq);
+	if (ret < 0)
+		goto out;
+
+	ret = cr_write_obj(ctx, &h, hh);
+	if (ret < 0)
+		goto out;
+
+	if (hh->q_qnum)
+		ret = cr_write_msg_queue(ctx, msq);
+
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+int cr_write_ipc_msg(struct cr_ctx *ctx, struct ipc_namespace *ipcns)
+{
+	struct cr_hdr h;
+	struct cr_hdr_ipc *hh;
+	struct ipc_ids *msg_ids = &ipcns->ids[IPC_MSG_IDS];
+	int ret = -ENOMEM;
+
+	down_read(&msg_ids->rw_mutex);
+
+	h.type = CR_HDR_IPC;
+	h.len = sizeof(*hh);
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		goto out;
+
+	hh->ipc_type = CR_HDR_IPC_MSG;
+	hh->ipc_count = msg_ids->in_use;
+	cr_debug("msg: count %d\n", hh->ipc_count);
+
+	ret = cr_write_obj(ctx, &h, hh);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	if (ret < 0)
+		goto out;
+
+	ret = idr_for_each(&msg_ids->ipcs_idr, cr_do_write_ipc_msg, ctx);
+	cr_debug("msg: ret %d\n", ret);
+
+ out:
+	up_read(&msg_ids->rw_mutex);
+	return ret;
+}
-- 
1.5.4.3
