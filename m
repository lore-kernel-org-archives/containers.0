From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 48/54] sysvipc-msq: checkpoint
Date: Tue, 28 Apr 2009 19:24:18 -0400
Message-ID: <1240961064-13991-49-git-send-email-orenl@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240961064-13991-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
 include/linux/checkpoint_hdr.h |   21 +++++-
 ipc/Makefile                   |    2 +-
 ipc/checkpoint.c               |    2 +-
 ipc/checkpoint_msg.c           |  164 ++++++++++++++++++++++++++++++++++++++++
 ipc/util.h                     |    2 +
 5 files changed, 188 insertions(+), 3 deletions(-)
 create mode 100644 ipc/checkpoint_msg.c

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 12a808c..bf34b08 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -70,6 +70,7 @@ enum {
 	CKPT_HDR_IPC = 401,
 	CKPT_HDR_IPC_SHM,
 	CKPT_HDR_IPC_MSG,
+	CKPT_HDR_IPC_MSG_MSG,
 	CKPT_HDR_IPC_SEM,
 
 	CKPT_HDR_TAIL = 5001
@@ -336,6 +337,25 @@ struct ckpt_hdr_ipc_shm {
 	__u32 objref;
 } __attribute__((aligned(8)));
 
+struct ckpt_hdr_ipc_msg {
+	struct ckpt_hdr h;
+	struct ckpt_hdr_ipc_perms perms;
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
+struct ckpt_hdr_ipc_msg_msg {
+	struct ckpt_hdr h;
+	__s32 m_type;
+	__u32 m_ts;
+} __attribute__((aligned(8)));
+
 
 #define CKPT_TST_OVERFLOW_16(a, b) \
 	((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
@@ -346,5 +366,4 @@ struct ckpt_hdr_ipc_shm {
 #define CKPT_TST_OVERFLOW_64(a, b) \
 	((sizeof(a) > sizeof(b)) && ((a) > LONG_MAX))
 
-
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/ipc/Makefile b/ipc/Makefile
index 7e23683..ca408ff 100644
--- a/ipc/Makefile
+++ b/ipc/Makefile
@@ -9,5 +9,5 @@ obj_mq-$(CONFIG_COMPAT) += compat_mq.o
 obj-$(CONFIG_POSIX_MQUEUE) += mqueue.o msgutil.o $(obj_mq-y)
 obj-$(CONFIG_IPC_NS) += namespace.o
 obj-$(CONFIG_POSIX_MQUEUE_SYSCTL) += mq_sysctl.o
-obj-$(CONFIG_CHECKPOINT) += checkpoint.o checkpoint_shm.o
+obj-$(CONFIG_CHECKPOINT) += checkpoint.o checkpoint_shm.o checkpoint_msg.o
 
diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index f951c1e..5f63300 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -99,11 +99,11 @@ int checkpoint_ipc_ns(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns)
 
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_SHM_IDS,
 				 CKPT_HDR_IPC_SHM, checkpoint_ipc_shm);
-#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		return ret;
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_MSG_IDS,
 				 CKPT_HDR_IPC_MSG, checkpoint_ipc_msg);
+#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		return ret;
 	ret = checkpoint_ipc_any(ctx, ipc_ns, IPC_SEM_IDS,
diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
new file mode 100644
index 0000000..f0b0921
--- /dev/null
+++ b/ipc/checkpoint_msg.c
@@ -0,0 +1,164 @@
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
+/* default debug level for output */
+#define CKPT_DFLAG  CKPT_DIPC
+
+#include <linux/mm.h>
+#include <linux/msg.h>
+#include <linux/rwsem.h>
+#include <linux/sched.h>
+#include <linux/syscalls.h>
+#include <linux/nsproxy.h>
+#include <linux/ipc_namespace.h>
+
+#include "util.h"
+
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+/************************************************************************
+ * ipc checkpoint
+ */
+
+static int fill_ipc_msg_hdr(struct ckpt_ctx *ctx,
+			    struct ckpt_hdr_ipc_msg *h,
+			    struct msg_queue *msq)
+{
+	int ret = 0;
+
+	ipc_lock_by_ptr(&msq->q_perm);
+
+	checkpoint_fill_ipc_perms(&h->perms, &msq->q_perm);
+
+	h->q_stime = msq->q_stime;
+	h->q_rtime = msq->q_rtime;
+	h->q_ctime = msq->q_ctime;
+	h->q_cbytes = msq->q_cbytes;
+	h->q_qnum = msq->q_qnum;
+	h->q_qbytes = msq->q_qbytes;
+	h->q_lspid = msq->q_lspid;
+	h->q_lrpid = msq->q_lrpid;
+
+	ipc_unlock(&msq->q_perm);
+
+	ckpt_debug("msg: lspid %d rspid %d qnum %lld qbytes %lld\n",
+		 h->q_lspid, h->q_lrpid, h->q_qnum, h->q_qbytes);
+
+	return ret;
+}
+
+static int checkpoint_msg_contents(struct ckpt_ctx *ctx, struct msg_msg *msg)
+{
+	struct ckpt_hdr_ipc_msg_msg *h;
+	struct msg_msgseg *seg;
+	int total, len;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_MSG_MSG);
+	if (!h)
+		return -ENOMEM;
+
+	h->m_type = msg->m_type;
+	h->m_ts = msg->m_ts;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	ckpt_hdr_put(ctx, h);
+	if (ret < 0)
+		return ret;
+
+	total = msg->m_ts;
+	len = min(total, (int) DATALEN_MSG);
+	ret = ckpt_write_buffer(ctx, (msg + 1), len);
+	if (ret < 0)
+		return ret;
+
+	seg = msg->next;
+	total -= len;
+
+	while (total) {
+		len = min(total, (int) DATALEN_SEG);
+		ret = ckpt_write_buffer(ctx, (seg + 1), len);
+		if (ret < 0)
+			break;
+		seg = seg->next;
+		total -= len;
+	}
+
+	return ret;
+}
+
+static int checkpoint_msg_queue(struct ckpt_ctx *ctx, struct msg_queue *msq)
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
+		ret = checkpoint_msg_contents(ctx, msg);
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
+int checkpoint_ipc_msg(int id, void *p, void *data)
+{
+	struct ckpt_hdr_ipc_msg *h;
+	struct ckpt_ctx *ctx = (struct ckpt_ctx *) data;
+	struct kern_ipc_perm *perm = (struct kern_ipc_perm *) p;
+	struct msg_queue *msq;
+	int ret;
+
+	msq = container_of(perm, struct msg_queue, q_perm);
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_IPC_MSG);
+	if (!h)
+		return -ENOMEM;
+
+	ret = fill_ipc_msg_hdr(ctx, h, msq);
+	if (ret < 0)
+		goto out;
+
+	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
+	if (ret < 0)
+		goto out;
+
+	if (h->q_qnum)
+		ret = checkpoint_msg_queue(ctx, msq);
+ out:
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/ipc/util.h b/ipc/util.h
index 09b9bdf..ab83ca3 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -196,6 +196,8 @@ extern int restore_load_ipc_perms(struct ckpt_hdr_ipc_perms *hh,
 
 extern int checkpoint_ipc_shm(int id, void *p, void *data);
 extern int restore_ipc_shm(struct ckpt_ctx *ctx);
+
+extern int checkpoint_ipc_msg(int id, void *p, void *data);
 #endif
 
 #endif
-- 
1.5.4.3
