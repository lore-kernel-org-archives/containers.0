From: ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
Subject: [PATCH 02/10] Introduce mm_has_pending_aio() helper
Date: Mon, 28 Feb 2011 17:40:24 -0600
Message-ID: <1298936432-29607-3-git-send-email-ntl@pobox.com>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1298936432-29607-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Support for AIO is on the to-do list, but until that is implemented,
checkpoint will have to fail if a mm_struct has outstanding AIO
contexts.  Add a mm_has_pending_aio() helper function for this
purpose.

Based on original "check_for_outstanding_aio" patch by Serge Hallyn.

Signed-off-by: Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
[ntl: changed name and return type to clearly express semantics]
[ntl: added kerneldoc]
Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 fs/aio.c            |   27 +++++++++++++++++++++++++++
 include/linux/aio.h |    2 ++
 2 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 8c8f6c5..1acbc99 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -1847,3 +1847,30 @@ SYSCALL_DEFINE5(io_getevents, aio_context_t, ctx_id,
 	asmlinkage_protect(5, ret, ctx_id, min_nr, nr, events, timeout);
 	return ret;
 }
+
+/**
+ * mm_has_pending_aio() - check for outstanding AIO operations
+ * @mm:		The mm_struct to check.
+ *
+ * Returns true if there is at least one non-dead kioctx on
+ * @mm->ioctx_list.  Note that the result of this function is
+ * unreliable unless the caller has ensured that new requests cannot
+ * be submitted against @mm (e.g. through freezing the associated
+ * tasks).
+ */
+bool mm_has_pending_aio(struct mm_struct *mm)
+{
+	struct kioctx *ctx;
+	struct hlist_node *n;
+	bool has_aio = false;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(ctx, n, &mm->ioctx_list, list) {
+		if (!ctx->dead) {
+			has_aio = true;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	return has_aio;
+}
diff --git a/include/linux/aio.h b/include/linux/aio.h
index 7a8db41..39d9936 100644
--- a/include/linux/aio.h
+++ b/include/linux/aio.h
@@ -214,6 +214,7 @@ struct mm_struct;
 extern void exit_aio(struct mm_struct *mm);
 extern long do_io_submit(aio_context_t ctx_id, long nr,
 			 struct iocb __user *__user *iocbpp, bool compat);
+extern bool mm_has_pending_aio(struct mm_struct *mm);
 #else
 static inline ssize_t wait_on_sync_kiocb(struct kiocb *iocb) { return 0; }
 static inline int aio_put_req(struct kiocb *iocb) { return 0; }
@@ -224,6 +225,7 @@ static inline void exit_aio(struct mm_struct *mm) { }
 static inline long do_io_submit(aio_context_t ctx_id, long nr,
 				struct iocb __user * __user *iocbpp,
 				bool compat) { return 0; }
+static inline bool mm_has_pending_aio(struct mm_struct *mm) { return false; }
 #endif /* CONFIG_AIO */
 
 static inline struct kiocb *list_kiocb(struct list_head *h)
-- 
1.7.4
