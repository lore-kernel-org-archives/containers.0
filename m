From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 5/6] define ckpt_obj_try_fetch
Date: Tue, 17 Nov 2009 19:53:32 -0600
Message-ID: <1258509213-15318-5-git-send-email-serue@us.ibm.com>
References: <1258509213-15318-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258509213-15318-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Which doesn't ckpt_err() on failure.  Also have callers which want
to, probe with _lite(), not ckpt_obj_fetch().

This is needed before the next patch, which will make ckpt_err()
with non-zero err bail a restart.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c       |   19 ++++++++++++-------
 checkpoint/signal.c        |   12 +++++++-----
 fs/pipe.c                  |    4 ++--
 include/linux/checkpoint.h |    2 ++
 mm/shmem.c                 |    2 +-
 5 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 2e50025..6b34426 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -999,20 +999,25 @@ int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr,
  *
  * [This is used during restart].
  */
-void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
+void *ckpt_obj_try_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
 {
 	struct ckpt_obj *obj;
 
 	obj = obj_find_by_objref(ctx, objref);
-	if (!obj) {
-		ckpt_err(ctx, -EINVAL, "%(O)No such object (type %d)\n",
-			 objref, type);
+	if (!obj)
 		return ERR_PTR(-EINVAL);
-	}
 	ckpt_debug("%s ref %d\n", obj->ops->obj_name, obj->objref);
 	if (obj->ops->obj_type == type)
 		return obj->ptr;
-	ckpt_err(ctx, -ENOMSG, "%(O)Hashed objed was type %d, not %d\n",
-		 objref, obj->ops->obj_type, type);
 	return ERR_PTR(-ENOMSG);
 }
+
+void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
+{
+	void *ret = ckpt_obj_try_fetch(ctx, objref, type);
+
+	if (unlikely(IS_ERR(ret)))
+		ckpt_err(ctx, PTR_ERR(ret), "%(O)Fetching object (type %d)\n",
+			 objref, type);
+	return ret;
+}
diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index 989b974..d8cb5d9 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -621,7 +621,7 @@ int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref)
 	struct signal_struct *signal;
 	int ret = 0;
 
-	signal = ckpt_obj_fetch(ctx, signal_objref, CKPT_OBJ_SIGNAL);
+	signal = ckpt_obj_try_fetch(ctx, signal_objref, CKPT_OBJ_SIGNAL);
 	if (!IS_ERR(signal)) {
 		/*
 		 * signal_struct is already shared properly as it is
@@ -629,15 +629,17 @@ int restore_obj_signal(struct ckpt_ctx *ctx, int signal_objref)
 		 * are already restore now, t->signal must match.
 		 */
 		if (signal != current->signal)
-			ret = -EINVAL;
-	} else if (PTR_ERR(signal) == -EINVAL) {
+			return -EINVAL;
+		return ret;
+	}
+
+	ret = PTR_ERR(signal);
+	if (ret == -EINVAL) {
 		/* first timer: add to hash and restore our t->signal */
 		ret = ckpt_obj_insert(ctx, current->signal,
 				      signal_objref, CKPT_OBJ_SIGNAL);
 		if (ret >= 0)
 			ret = restore_signal(ctx);
-	} else {
-		ret = PTR_ERR(signal);
 	}
 
 	return ret;
diff --git a/fs/pipe.c b/fs/pipe.c
index 65ad44e..7f350fc 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -919,7 +919,7 @@ struct file *pipe_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 	if (h->pipe_objref <= 0)
 		return ERR_PTR(-EINVAL);
 
-	file = ckpt_obj_fetch(ctx, h->pipe_objref, CKPT_OBJ_FILE);
+	file = ckpt_obj_try_fetch(ctx, h->pipe_objref, CKPT_OBJ_FILE);
 	/*
 	 * If ckpt_obj_fetch() returned ERR_PTR(-EINVAL), then this is
 	 * the first time we see this pipe so need to restore the
@@ -990,7 +990,7 @@ struct file *fifo_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
 	 * If ckpt_obj_fetch() returned ERR_PTR(-EINVAL), this is the
 	 * first time for this fifo.
 	 */
-	file = ckpt_obj_fetch(ctx, h->pipe_objref, CKPT_OBJ_FILE);
+	file = ckpt_obj_try_fetch(ctx, h->pipe_objref, CKPT_OBJ_FILE);
 	if (!IS_ERR(file))
 		first = 0;
 	else if (PTR_ERR(file) == -EINVAL)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 8fd6cba..65765af 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -132,6 +132,8 @@ extern int ckpt_obj_lookup(struct ckpt_ctx *ctx, void *ptr,
 			   enum obj_type type);
 extern int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 			       enum obj_type type, int *first);
+extern void *ckpt_obj_try_fetch(struct ckpt_ctx *ctx, int objref,
+			    enum obj_type type);
 extern void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref,
 			    enum obj_type type);
 extern int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr, int objref,
diff --git a/mm/shmem.c b/mm/shmem.c
index 2cfff8d..a0416d3 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2419,7 +2419,7 @@ int shmem_restore(struct ckpt_ctx *ctx,
 	struct file *file;
 	int ret = 0;
 
-	file = ckpt_obj_fetch(ctx, h->ino_objref, CKPT_OBJ_FILE);
+	file = ckpt_obj_try_fetch(ctx, h->ino_objref, CKPT_OBJ_FILE);
 	if (PTR_ERR(file) == -EINVAL)
 		file = NULL;
 	if (IS_ERR(file))
-- 
1.6.1
