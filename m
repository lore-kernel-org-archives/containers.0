From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] c/r: Take uts_sem during checkpoint and restart
Date: Thu, 16 Apr 2009 08:59:45 -0700
Message-ID: <1239897585-19246-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Fix the potential for breakage if our UTS changes during checkpoint or
restart by grabbing uts_sem during these operations.

Cc: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/ckpt_task.c |   12 ++++++++----
 checkpoint/rstr_task.c |   17 +++++++++++------
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/checkpoint/ckpt_task.c b/checkpoint/ckpt_task.c
index 4d19e31..589f304 100644
--- a/checkpoint/ckpt_task.c
+++ b/checkpoint/ckpt_task.c
@@ -173,14 +173,16 @@ static int cr_write_utsns(struct cr_ctx *ctx, struct uts_namespace *uts_ns)
 	struct cr_hdr_utsns *hh;
 	int domainname_len;
 	int nodename_len;
-	int ret;
+	int ret = -ENOMEM;
+
+ 	down_read(&uts_sem);
 
 	h.type = CR_HDR_UTSNS;
 	h.len = sizeof(*hh);
 
 	hh = cr_hbuf_get(ctx, sizeof(*hh));
 	if (!hh)
-		return -ENOMEM;
+		goto out;
 
 	nodename_len = strlen(uts_ns->name.nodename) + 1;
 	domainname_len = strlen(uts_ns->name.domainname) + 1;
@@ -191,13 +193,15 @@ static int cr_write_utsns(struct cr_ctx *ctx, struct uts_namespace *uts_ns)
 	ret = cr_write_obj(ctx, &h, hh);
 	cr_hbuf_put(ctx, sizeof(*hh));
 	if (ret < 0)
-		return ret;
+		goto out;
 
 	ret = cr_write_string(ctx, uts_ns->name.nodename, nodename_len);
 	if (ret < 0)
-		return ret;
+		goto out;
 
 	ret = cr_write_string(ctx, uts_ns->name.domainname, domainname_len);
+ out:
+	up_read(&uts_sem);
 	return ret;
 }
 
diff --git a/checkpoint/rstr_task.c b/checkpoint/rstr_task.c
index fe5c059..ccf60f8 100644
--- a/checkpoint/rstr_task.c
+++ b/checkpoint/rstr_task.c
@@ -171,32 +171,37 @@ static int cr_read_utsns(struct cr_ctx *ctx)
 {
 	struct cr_hdr_utsns *hh;
 	struct uts_namespace *ns;
-	int ret;
+	int ret = -ENOMEM;
+
+	down_write(&uts_sem);
 
 	hh = cr_hbuf_get(ctx, sizeof(*hh));
 	if (!hh)
-		return -ENOMEM;
+		goto out;
 
 	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_UTSNS);
 	if (ret < 0)
-		goto out;
+		goto out_hbuf;
 
 	ret = -EINVAL;
 	if (hh->nodename_len > sizeof(ns->name.nodename) ||
 	    hh->domainname_len > sizeof(ns->name.domainname))
-		goto out;
+		goto out_hbuf;
 
 	ns = current->nsproxy->uts_ns;
 
 	memset(ns->name.nodename, 0, sizeof(ns->name.nodename));
 	ret = cr_read_string(ctx, ns->name.nodename, hh->nodename_len);
 	if (ret < 0)
-		goto out;
+		goto out_hbuf;
 
 	memset(ns->name.domainname, 0, sizeof(ns->name.domainname));
 	ret = cr_read_string(ctx, ns->name.domainname, hh->domainname_len);
+
+ out_hbuf:
+ 	cr_hbuf_put(ctx, sizeof(*hh));
  out:
-	cr_hbuf_put(ctx, sizeof(*hh));
+	up_write(&uts_sem);
 	return ret;
 }
 
-- 
1.5.6.3
