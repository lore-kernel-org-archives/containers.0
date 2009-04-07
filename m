From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v2][PATCH 10/10] sysvipc-msq: restart
Date: Tue,  7 Apr 2009 08:31:43 -0400
Message-ID: <1239107503-21941-11-git-send-email-orenl@cs.columbia.edu>
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

The namespace is restored by creating each 'msq' object read from
the checkpoint image.

Message of a specific queue are first read and chained together on
a temporary list, and once done are attached atomically as a whole
to the newly created message queue ('msq').

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/rstr_file.c     |    1 -
 checkpoint/util_ipc.c      |    9 ++-
 include/linux/checkpoint.h |    1 +
 ipc/ckpt_msg.c             |  210 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 219 insertions(+), 2 deletions(-)

diff --git a/checkpoint/rstr_file.c b/checkpoint/rstr_file.c
index cf3bece..845a5cd 100644
--- a/checkpoint/rstr_file.c
+++ b/checkpoint/rstr_file.c
@@ -399,7 +399,6 @@ int cr_read_fd_table(struct cr_ctx *ctx)
 			break;
 	}
 
-	ret = 0;
  out:
 	cr_hbuf_put(ctx, sizeof(*hh));
 	return ret;
diff --git a/checkpoint/util_ipc.c b/checkpoint/util_ipc.c
index 163a106..9a4e37d 100644
--- a/checkpoint/util_ipc.c
+++ b/checkpoint/util_ipc.c
@@ -27,7 +27,14 @@ int cr_write_ipcns(struct cr_ctx *ctx, struct ipc_namespace *ipc_ns)
 
 int cr_read_ipcns(struct cr_ctx *ctx)
 {
-	return cr_read_ipc_shm(ctx);
+	int ret;
+
+	ret = cr_read_ipc_shm(ctx);
+	if (ret < 0)
+		return ret;
+	ret = cr_read_ipc_msg(ctx);
+
+	return ret;
 }
 
 void cr_fill_ipc_perms(struct cr_hdr_ipc_perms *hh, struct kern_ipc_perm *perm)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 16dd96d..898176c 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -156,6 +156,7 @@ extern int cr_read_ipc_shm(struct cr_ctx *ctx);
 extern int cr_ipc_shm_attach(struct file *file,
 			     unsigned long addr, unsigned long flags);
 extern int cr_write_ipc_msg(struct cr_ctx *ctx, struct ipc_namespace *ipcns);
+extern int cr_read_ipc_msg(struct cr_ctx *ctx);
 #endif
 
 
diff --git a/ipc/ckpt_msg.c b/ipc/ckpt_msg.c
index 5e11253..eebbf06 100644
--- a/ipc/ckpt_msg.c
+++ b/ipc/ckpt_msg.c
@@ -202,3 +202,213 @@ int cr_write_ipc_msg(struct cr_ctx *ctx, struct ipc_namespace *ipcns)
 	up_read(&msg_ids->rw_mutex);
 	return ret;
 }
+
+/************************************************************************
+ * ipc restart
+ */
+
+static int cr_load_ipc_msg_hdr(struct cr_ctx *ctx,
+			       struct cr_hdr_ipc_msg *hh,
+			       struct msg_queue *msq)
+{
+	int ret = 0;
+
+	ret = cr_load_ipc_perms(&hh->perms, &msq->q_perm);
+	if (ret < 0)
+		return ret;
+
+	cr_debug("msq: lspid %d lrpid %d qnum %lld qbytes %lld\n",
+		 hh->q_lspid, hh->q_lrpid, hh->q_qnum, hh->q_qbytes);
+
+	if (hh->q_lspid < 0 || hh->q_lrpid < 0)
+		return -EINVAL;
+
+	msq->q_stime = hh->q_stime;
+	msq->q_rtime = hh->q_rtime;
+	msq->q_ctime = hh->q_ctime;
+	msq->q_lspid = hh->q_lspid;
+	msq->q_lrpid = hh->q_lrpid;
+
+	return 0;
+}
+
+static struct msg_msg *cr_read_msg_contents_one(struct cr_ctx *ctx)
+{
+	struct cr_hdr_ipc_msg_msg *hh;
+	struct msg_msg *msg = NULL;
+	struct msg_msgseg *seg, **pseg;
+	int total, len;
+	int ret;
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return ERR_PTR(-ENOMEM);
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_IPC_MSG_MSG);
+	if (ret < 0)
+		goto out;
+
+	ret = -EINVAL;
+	if (hh->m_type < 1)
+		goto out;
+	if (hh->m_ts > current->nsproxy->ipc_ns->msg_ctlmax)
+		goto out;
+
+	total = hh->m_ts;
+	len = min(total, (int) DATALEN_MSG);
+	ret = -ENOMEM;
+	msg = kmalloc(sizeof(*msg) + len, GFP_KERNEL);
+	if (!msg)
+		goto out;
+	msg->next = NULL;
+	pseg = &msg->next;
+
+	ret = cr_read_buffer_len(ctx, (msg + 1), len);
+	if (ret < 0)
+		goto out;
+
+	total -= len;
+	while (total) {
+		len = min(total, (int) DATALEN_SEG);
+		ret = -ENOMEM;
+		seg = kmalloc(sizeof(*seg) + len, GFP_KERNEL);
+		if (!seg)
+			goto out;
+		seg->next = NULL;
+		*pseg = seg;
+		pseg = &seg->next;
+
+		ret = cr_read_buffer_len(ctx, (seg + 1), len);
+		if (ret < 0)
+			goto out;
+	}
+
+	msg->m_type = hh->m_type;
+	msg->m_ts = hh->m_ts;
+	return msg;
+
+ out:
+	if (msg)
+		free_msg(msg);
+	return ERR_PTR(ret);
+}
+
+static int cr_read_msg_contents(struct cr_ctx *ctx,
+				struct list_head *queue, unsigned long qnum)
+{
+	struct msg_msg *msg, *tmp;
+	int ret = 0;
+
+	INIT_LIST_HEAD(queue);
+
+	while (qnum--) {
+		msg = cr_read_msg_contents_one(ctx);
+		if (IS_ERR(msg))
+			goto fail;
+		list_add_tail(&msg->m_list, queue);
+	}
+
+	return 0;
+
+ fail:
+	ret = PTR_ERR(msg);
+	list_for_each_entry_safe(msg, tmp, queue, m_list)
+		free_msg(msg);
+	return ret;
+}
+
+static int cr_do_read_ipc_msg(struct cr_ctx *ctx)
+{
+	struct cr_hdr_ipc_msg *hh;
+	struct kern_ipc_perm *perms;
+	struct msg_queue *msq;
+	struct ipc_ids *msg_ids = &current->nsproxy->ipc_ns->ids[IPC_MSG_IDS];
+	struct list_head messages;
+	int msgflag;
+	int ret;
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_IPC_MSG);
+	if (ret < 0)
+		goto out;
+	ret = -EINVAL;
+	if (hh->perms.id < 0)
+		goto out;
+
+	/* read queued messages into temporary queue */
+	ret = cr_read_msg_contents(ctx, &messages, hh->q_qnum);
+	if (ret < 0)
+		goto out;
+
+	/* restore the message queue now */
+	msgflag = hh->perms.mode | IPC_CREAT | IPC_EXCL;
+	cr_debug("msg: do_msgget key %d flag %#x id %d\n",
+		 hh->perms.key, msgflag, hh->perms.id);
+	ret = do_msgget(hh->perms.key, msgflag, hh->perms.id);
+	cr_debug("shm: do_msgget ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	down_write(&msg_ids->rw_mutex);
+	ret = -EIDRM;
+	perms = ipc_lock(msg_ids, hh->perms.id);
+	if (IS_ERR(perms)) {	/* this should not happen .. but be safe */
+		up_write(&msg_ids->rw_mutex);
+		ret = PTR_ERR(perms);
+		goto out;
+	}
+
+	msq = container_of(perms, struct msg_queue, q_perm);
+	ret = cr_load_ipc_msg_hdr(ctx, hh, msq);
+	if (ret < 0) {
+		cr_debug("msq: need to remove (%d)\n", ret);
+		freeque(current->nsproxy->ipc_ns, perms);
+		up_write(&msg_ids->rw_mutex);
+		goto out;
+	}
+
+	/* attach queued messages we read before */
+	if (list_empty(&msq->q_messages))
+		list_splice_init(&messages, &msq->q_messages);
+	else
+		ret = -EBUSY;
+
+	ipc_unlock(perms);
+	up_write(&msg_ids->rw_mutex);
+ out:
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
+
+int cr_read_ipc_msg(struct cr_ctx *ctx)
+{
+	struct cr_hdr_ipc *hh;
+	int n, ret;
+
+	hh = cr_hbuf_get(ctx, sizeof(*hh));
+	if (!hh)
+		return -ENOMEM;
+
+	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_IPC);
+	if (ret < 0)
+		goto out;
+
+	cr_debug("msg: count %d\n", hh->ipc_count);
+
+	ret = -EINVAL;
+	if (hh->ipc_type != CR_HDR_IPC_MSG)
+		goto out;
+
+	ret = 0;
+	for (n = 0; n < hh->ipc_count; n++) {
+		ret = cr_do_read_ipc_msg(ctx);
+		if (ret < 0)
+			goto out;
+	}
+
+ out:
+	cr_debug("msg: ret %d\n", ret);
+	cr_hbuf_put(ctx, sizeof(*hh));
+	return ret;
+}
-- 
1.5.4.3
