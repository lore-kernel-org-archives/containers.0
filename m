From: Serge Hallyn <serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] use ckpt_err in ckpt_read_obj_type()
Date: Mon, 16 Nov 2009 15:00:31 -0600
Message-ID: <1258405231-13784-3-git-send-email-serge@us.ibm.com>
References: <1258405231-13784-1-git-send-email-serge@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1258405231-13784-1-git-send-email-serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/restart.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 4af4647..b684d7a 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -416,11 +416,16 @@ void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type)
 	BUG_ON(!len);
 
 	h = ckpt_read_obj(ctx, len, len);
-	if (IS_ERR(h))
+	if (IS_ERR(h)) {
+		ckpt_err(ctx, PTR_ERR(h), "Looking for type %d in ckptfile\n",
+			 type);
 		return h;
+	}
 
 	if (h->type != type) {
 		ckpt_hdr_put(ctx, h);
+		ckpt_err(ctx, -EINVAL, "Next object was type %d, not %d\n",
+			h->type, type);
 		h = ERR_PTR(-EINVAL);
 	}
 
-- 
1.6.1
