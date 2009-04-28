From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14][PATCH 49/54] sysvipc-msq: restart
Date: Tue, 28 Apr 2009 19:24:19 -0400
Message-ID: <1240961064-13991-50-git-send-email-orenl@cs.columbia.edu>
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

The namespace is restored by creating each 'msq' object read from
the checkpoint image.

Message of a specific queue are first read and chained together on
a temporary list, and once done are attached atomically as a whole
to the newly created message queue ('msq').

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 ipc/checkpoint.c     |    4 +-
 ipc/checkpoint_msg.c |  196 ++++++++++++++++++++++++++++++++++++++++++++++++++
 ipc/util.h           |    1 +
 3 files changed, 199 insertions(+), 2 deletions(-)

diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 5f63300..dfd3286 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -211,11 +211,11 @@ static int do_restore_ipc_ns(struct ckpt_ctx *ctx)
 
 	ret = restore_ipc_any(ctx, IPC_SHM_IDS,
 			      CKPT_HDR_IPC_SHM, restore_ipc_shm);
-#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		goto out;
-	ret = ckpt_read_ipc_any(ctx, IPC_MSG_IDS,
+	ret = restore_ipc_any(ctx, IPC_MSG_IDS,
 			      CKPT_HDR_IPC_MSG, restore_ipc_msg);
+#if 0 /* NEXT FEW PATCHES */
 	if (ret < 0)
 		goto out;
 	ret = restore_ipc_any(ctx, IPC_SEM_IDS,
diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
index f0b0921..a4099e5 100644
--- a/ipc/checkpoint_msg.c
+++ b/ipc/checkpoint_msg.c
@@ -162,3 +162,199 @@ int checkpoint_ipc_msg(int id, void *p, void *data)
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
+
+
+/************************************************************************
+ * ipc restart
+ */
+
+static int load_ipc_msg_hdr(struct ckpt_ctx *ctx,
+			    struct ckpt_hdr_ipc_msg *h,
+			    struct msg_queue *msq)
+{
+	int ret = 0;
+
+	ret = restore_load_ipc_perms(&h->perms, &msq->q_perm);
+	if (ret < 0)
+		return ret;
+
+	ckpt_debug("msq: lspid %d lrpid %d qnum %lld qbytes %lld\n",
+		 h->q_lspid, h->q_lrpid, h->q_qnum, h->q_qbytes);
+
+	if (h->q_lspid < 0 || h->q_lrpid < 0)
+		return -EINVAL;
+
+	msq->q_stime = h->q_stime;
+	msq->q_rtime = h->q_rtime;
+	msq->q_ctime = h->q_ctime;
+	msq->q_lspid = h->q_lspid;
+	msq->q_lrpid = h->q_lrpid;
+
+	return 0;
+}
+
+static struct msg_msg *restore_msg_contents_one(struct ckpt_ctx *ctx, int *clen)
+{
+	struct ckpt_hdr_ipc_msg_msg *h;
+	struct msg_msg *msg = NULL;
+	struct msg_msgseg *seg, **pseg;
+	int total, len;
+	int ret;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC_MSG_MSG);
+	if (IS_ERR(h))
+		return (struct msg_msg *) h;
+
+	ret = -EINVAL;
+	if (h->m_type < 1)
+		goto out;
+	if (h->m_ts > current->nsproxy->ipc_ns->msg_ctlmax)
+		goto out;
+
+	total = h->m_ts;
+	len = min(total, (int) DATALEN_MSG);
+	msg = kmalloc(sizeof(*msg) + len, GFP_KERNEL);
+	if (!msg) {
+		ret = -ENOMEM;
+		goto out;
+	}
+	msg->next = NULL;
+	pseg = &msg->next;
+
+	ret = _ckpt_read_buffer(ctx, (msg + 1), len);
+	if (ret < 0)
+		goto out;
+
+	total -= len;
+	while (total) {
+		len = min(total, (int) DATALEN_SEG);
+		seg = kmalloc(sizeof(*seg) + len, GFP_KERNEL);
+		if (!seg) {
+			ret = -ENOMEM;
+			goto out;
+		}
+		seg->next = NULL;
+		*pseg = seg;
+		pseg = &seg->next;
+
+		ret = _ckpt_read_buffer(ctx, (seg + 1), len);
+		if (ret < 0)
+			goto out;
+		total -= len;
+	}
+
+	msg->m_type = h->m_type;
+	msg->m_ts = h->m_ts;
+	*clen = h->m_ts;
+ out:
+	if (ret < 0 && msg) {
+		free_msg(msg);
+		msg = ERR_PTR(ret);
+	}
+	ckpt_hdr_put(ctx, h);
+	return msg;
+}
+
+static inline void free_msg_list(struct list_head *queue)
+{
+	struct msg_msg *msg, *tmp;
+
+	list_for_each_entry_safe(msg, tmp, queue, m_list)
+		free_msg(msg);
+}
+
+static int restore_msg_contents(struct ckpt_ctx *ctx, struct list_head *queue,
+				unsigned long qnum, unsigned long *cbytes)
+{
+	struct msg_msg *msg;
+	int clen = 0;
+	int ret = 0;
+
+	INIT_LIST_HEAD(queue);
+
+	*cbytes = 0;
+	while (qnum--) {
+		msg = restore_msg_contents_one(ctx, &clen);
+		if (IS_ERR(msg))
+			goto fail;
+		list_add_tail(&msg->m_list, queue);
+		*cbytes += clen;
+	}
+	return 0;
+ fail:
+	ret = PTR_ERR(msg);
+	free_msg_list(queue);
+	return ret;
+}
+
+int restore_ipc_msg(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_ipc_msg *h;
+	struct kern_ipc_perm *perms;
+	struct msg_queue *msq;
+	struct ipc_ids *msg_ids = &current->nsproxy->ipc_ns->ids[IPC_MSG_IDS];
+	struct list_head messages;
+	unsigned long cbytes;
+	int msgflag;
+	int ret;
+
+	INIT_LIST_HEAD(&messages);
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_IPC_MSG);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	ret = -EINVAL;
+	if (h->perms.id < 0)
+		goto out;
+
+	/* read queued messages into temporary queue */
+	ret = restore_msg_contents(ctx, &messages, h->q_qnum, &cbytes);
+	if (ret < 0)
+		goto out;
+
+	ret = -EINVAL;
+	if (h->q_cbytes != cbytes)
+		goto out;
+
+	/* restore the message queue */
+	msgflag = h->perms.mode | IPC_CREAT | IPC_EXCL;
+	ckpt_debug("msg: do_msgget key %d flag %#x id %d\n",
+		 h->perms.key, msgflag, h->perms.id);
+	ret = do_msgget(h->perms.key, msgflag, h->perms.id);
+	ckpt_debug("msg: do_msgget ret %d\n", ret);
+	if (ret < 0)
+		goto out;
+
+	down_write(&msg_ids->rw_mutex);
+
+	/* we are the sole owners/users of this ipc_ns, it can't go away */
+	perms = ipc_lock(msg_ids, h->perms.id);
+	BUG_ON(IS_ERR(perms));	/* ipc_ns is private to us */
+
+	msq = container_of(perms, struct msg_queue, q_perm);
+	BUG_ON(!list_empty(&msq->q_messages));	/* ipc_ns is private to us */
+
+	/* attach queued messages we read before */
+	list_splice_init(&messages, &msq->q_messages);
+
+	/* adjust msq and namespace statistics */
+	atomic_add(h->q_cbytes, &current->nsproxy->ipc_ns->msg_bytes);
+	atomic_add(h->q_qnum, &current->nsproxy->ipc_ns->msg_hdrs);
+	msq->q_cbytes = h->q_cbytes;
+	msq->q_qbytes = h->q_qbytes;
+	msq->q_qnum = h->q_qnum;
+
+	ret = load_ipc_msg_hdr(ctx, h, msq);
+	ipc_unlock(perms);
+
+	if (ret < 0) {
+		ckpt_debug("msq: need to remove (%d)\n", ret);
+		freeque(current->nsproxy->ipc_ns, perms);
+	}
+	up_write(&msg_ids->rw_mutex);
+ out:
+	free_msg_list(&messages);  /* no-op if all ok, else cleanup msgs */
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
diff --git a/ipc/util.h b/ipc/util.h
index ab83ca3..1e464fd 100644
--- a/ipc/util.h
+++ b/ipc/util.h
@@ -198,6 +198,7 @@ extern int checkpoint_ipc_shm(int id, void *p, void *data);
 extern int restore_ipc_shm(struct ckpt_ctx *ctx);
 
 extern int checkpoint_ipc_msg(int id, void *p, void *data);
+extern int restore_ipc_msg(struct ckpt_ctx *ctx);
 #endif
 
 #endif
-- 
1.5.4.3
