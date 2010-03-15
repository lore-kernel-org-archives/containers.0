From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] make uts_ns=n compile
Date: Mon, 15 Mar 2010 17:50:18 -0500
Message-ID: <20100315225018.GA2544@us.ibm.com>
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

One of those unfortunate patches that turns out hard to read, but
it just moves the #ifdef'd part of do_restore_uts_ns into
ifdef'd helpers.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/namespace.c |   50 +++++++++++++++++++++++++++++++----------------
 1 files changed, 33 insertions(+), 17 deletions(-)

diff --git a/checkpoint/namespace.c b/checkpoint/namespace.c
index 4b3ac5a..3bd8e85 100644
--- a/checkpoint/namespace.c
+++ b/checkpoint/namespace.c
@@ -53,22 +53,17 @@ int checkpoint_uts_ns(struct ckpt_ctx *ctx, void *ptr)
 	return do_checkpoint_uts_ns(ctx, (struct uts_namespace *) ptr);
 }
 
-static struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
+#ifdef CONFIG_UTS_NS
+static inline struct uts_namespace *ckpt_do_copy_uts_ns(struct ckpt_ctx *ctx,
+		struct ckpt_hdr_utsns *h)
 {
-	struct ckpt_hdr_utsns *h;
-	struct uts_namespace *uts_ns = NULL;
-	struct new_utsname *name;
-
-	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
-	if (IS_ERR(h))
-		return (struct uts_namespace *) h;
+	struct new_utsname *name = NULL;
+	struct uts_namespace *uts_ns;
 
-#ifdef CONFIG_UTS_NS
 	uts_ns = create_uts_ns();
-	if (!uts_ns) {
-		uts_ns = ERR_PTR(-ENOMEM);
-		goto out;
-	}
+	if (!uts_ns)
+		return ERR_PTR(-ENOMEM);
+
 	down_read(&uts_sem);
 	name = &uts_ns->name;
 	memcpy(name->sysname, h->sysname, sizeof(name->sysname));
@@ -78,16 +73,37 @@ static struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
 	memcpy(name->machine, h->machine, sizeof(name->machine));
 	memcpy(name->domainname, h->domainname, sizeof(name->domainname));
 	up_read(&uts_sem);
+	return uts_ns;
+}
 #else
+static inline struct uts_namespace *ckpt_do_copy_uts_ns(struct ckpt_ctx *ctx,
+		struct ckpt_hdr_utsns *h)
+{
+	struct uts_namespace *uts_ns;
+
 	/* complain if image contains multiple namespaces */
-	if (ctx->stats.uts_ns) {
-		uts_ns = ERR_PTR(-EEXIST);
-		goto out;
-	}
+	if (ctx->stats.uts_ns)
+		return ERR_PTR(-EEXIST);
+
 	uts_ns = current->nsproxy->uts_ns;
 	get_uts_ns(uts_ns);
+	return uts_ns;
+}
 #endif
 
+static struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_utsns *h;
+	struct uts_namespace *uts_ns;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_UTS_NS);
+	if (IS_ERR(h))
+		return (struct uts_namespace *) h;
+
+	uts_ns = ckpt_do_copy_uts_ns(ctx, h);
+	if (IS_ERR(uts_ns))
+		goto out;
+
 	ctx->stats.uts_ns++;
  out:
 	ckpt_hdr_put(ctx, h);
-- 
1.6.1
