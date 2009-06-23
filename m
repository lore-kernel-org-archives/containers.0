From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] cr: uts: don't deref h after freeing
Date: Tue, 23 Jun 2009 14:37:02 -0500
Message-ID: <20090623193702.GA25291@us.ibm.com>
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
To: Nathan T Lynch <natlynch-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Don't pass h->xyz_len etc as lengths after freeing h!  Send
the result of sizeof(name->xyz) directly.

Changelog: Jun 23: resend with new description which accurately
	describes what is being fixed (figured out by Nathan Lynch).

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/namespace.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/checkpoint/namespace.c b/checkpoint/namespace.c
index 5726acb..8206aee 100644
--- a/checkpoint/namespace.c
+++ b/checkpoint/namespace.c
@@ -46,22 +46,22 @@ static int do_checkpoint_uts_ns(struct ckpt_ctx *ctx,
 		return ret;
 
 	down_read(&uts_sem);
-	ret = ckpt_write_string(ctx, name->sysname, h->sysname_len);
+	ret = ckpt_write_string(ctx, name->sysname, sizeof(name->sysname));
 	if (ret < 0)
 		goto up;
-	ret = ckpt_write_string(ctx, name->nodename, h->nodename_len);
+	ret = ckpt_write_string(ctx, name->nodename, sizeof(name->nodename));
 	if (ret < 0)
 		goto up;
-	ret = ckpt_write_string(ctx, name->release, h->release_len);
+	ret = ckpt_write_string(ctx, name->release, sizeof(name->release));
 	if (ret < 0)
 		goto up;
-	ret = ckpt_write_string(ctx, name->version, h->version_len);
+	ret = ckpt_write_string(ctx, name->version, sizeof(name->version));
 	if (ret < 0)
 		goto up;
-	ret = ckpt_write_string(ctx, name->machine, h->machine_len);
+	ret = ckpt_write_string(ctx, name->machine, sizeof(name->machine));
 	if (ret < 0)
 		goto up;
-	ret = ckpt_write_string(ctx, name->domainname, h->domainname_len);
+	ret = ckpt_write_string(ctx, name->domainname, sizeof(name->domainname));
  up:
 	up_read(&uts_sem);
 	return ret;
-- 
1.6.1
