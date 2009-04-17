From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] c/r: Take uts_sem during checkpoint (v2)
Date: Fri, 17 Apr 2009 07:27:18 -0700
Message-ID: <1239978438-5719-1-git-send-email-danms@us.ibm.com>
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

Fix the potential for breakage if our UTS changes during checkpoint
by grabbing uts_sem and copying those strings to temporary buffers.

Cc: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Changes in v2:
  - Be less stupid about holding the system-wide uts_sem during
    checkpoint (!)
  - Don't hold it during restart
  - Hold uts_sem only while copying out the strings
  - Calculate the length of the saved buffers outside of the semaphore and
    avoid the duplicate _len variables by cleaning up the cr_hdr_utsns
    after the cr_write_string() of the two buffers
---
 checkpoint/ckpt_task.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/checkpoint/ckpt_task.c b/checkpoint/ckpt_task.c
index 4d19e31..30858d2 100644
--- a/checkpoint/ckpt_task.c
+++ b/checkpoint/ckpt_task.c
@@ -171,8 +171,8 @@ static int cr_write_utsns(struct cr_ctx *ctx, struct uts_namespace *uts_ns)
 {
 	struct cr_hdr h;
 	struct cr_hdr_utsns *hh;
-	int domainname_len;
-	int nodename_len;
+	char nodename[__NEW_UTS_LEN + 1];
+	char domainname[__NEW_UTS_LEN + 1];
 	int ret;
 
 	h.type = CR_HDR_UTSNS;
@@ -182,22 +182,25 @@ static int cr_write_utsns(struct cr_ctx *ctx, struct uts_namespace *uts_ns)
 	if (!hh)
 		return -ENOMEM;
 
-	nodename_len = strlen(uts_ns->name.nodename) + 1;
-	domainname_len = strlen(uts_ns->name.domainname) + 1;
+	down_read(&uts_sem);
+	memcpy(nodename, uts_ns->name.nodename, sizeof(nodename));
+	memcpy(domainname, uts_ns->name.domainname, sizeof(nodename));
+	up_read(&uts_sem);
 
-	hh->nodename_len = nodename_len;
-	hh->domainname_len = domainname_len;
+	hh->nodename_len = strlen(nodename) + 1;
+	hh->domainname_len = strlen(domainname) + 1;
 
 	ret = cr_write_obj(ctx, &h, hh);
-	cr_hbuf_put(ctx, sizeof(*hh));
 	if (ret < 0)
-		return ret;
+		goto out;
 
-	ret = cr_write_string(ctx, uts_ns->name.nodename, nodename_len);
+	ret = cr_write_string(ctx, nodename, hh->nodename_len);
 	if (ret < 0)
-		return ret;
+		goto out;
 
-	ret = cr_write_string(ctx, uts_ns->name.domainname, domainname_len);
+	ret = cr_write_string(ctx, domainname, hh->domainname_len);
+ out:
+ 	cr_hbuf_put(ctx, sizeof(*hh));
 	return ret;
 }
 
-- 
1.5.6.3
