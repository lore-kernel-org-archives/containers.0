From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: mktree.c does not compile with v14 ?
Date: Mon, 30 Mar 2009 18:47:06 -0700
Message-ID: <87ab72h3ad.fsf@caffeine.danplanet.com>
References: <20090331005703.GA19223@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090331005703.GA19223-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Sukadev Bhattiprolu's
	message of "Mon, 30 Mar 2009 17:57:03 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Suka,

SB> I am trying to compile mktree.c with [v14-rc1] but get this:

I had the same problem and had to fix up mktree.c a bit.  Oren said he
had a fix for this, but I haven't seen it yet.  So, I've included mine
at the bottom in case it helps.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 mktree.c |   27 ++++++++++++++++++---------
 1 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/mktree.c b/mktree.c
index c97c2de..65a0fdc 100644
--- a/mktree.c
+++ b/mktree.c
@@ -560,18 +560,24 @@ static int cr_read_head(struct cr_ctx *ctx)
 	if (ret < 0)
 		return ret;
 
-	len = hh->uts_len;
+	len = hh->uts_release_len + hh->uts_version_len + hh->uts_machine_len;
 	if (len < 0 || len > BUFSIZE / 4)
 		return -EINVAL;
 	ptr = (char *) (hh + 1);
 
-	ret = cr_read_obj_buffer(ctx, ptr, len);
+	len = 0;
+
+	ret = cr_read_obj_buffer(ctx, ptr, hh->uts_release_len);
 	if (ret < 0)
 		return ret;
-	ret = cr_read_obj_buffer(ctx, ptr + len, len);
+	len += hh->uts_release_len;
+
+	ret = cr_read_obj_buffer(ctx, ptr + len, hh->uts_version_len);
 	if (ret < 0)
 		return ret;
-	ret = cr_read_obj_buffer(ctx, ptr + 2*len, len);
+	len += hh->uts_version_len;
+
+	ret = cr_read_obj_buffer(ctx, ptr + len, hh->uts_machine_len);
 	if (ret < 0)
 		return ret;
 
@@ -627,7 +633,7 @@ static int cr_write_head(struct cr_ctx *ctx)
 	struct cr_hdr h;
 	struct cr_hdr_head *hh;
 	char *ptr;
-	int len, ret;
+	int len = 0, ret;
 
 	h.type = CR_HDR_HEAD;
 	h.len = sizeof(*hh);
@@ -636,16 +642,19 @@ static int cr_write_head(struct cr_ctx *ctx)
 	if (ret < 0)
 		return ret;
 
-	len = hh->uts_len;
 	ptr = (char *) (hh + 1);
 
-	ret = cr_write_obj_buffer(ctx, ptr, len);
+	ret = cr_write_obj_buffer(ctx, ptr, hh->uts_release_len);
 	if (ret < 0)
 		return ret;
-	ret = cr_write_obj_buffer(ctx, ptr + len, len);
+	len += hh->uts_release_len;
+
+	ret = cr_write_obj_buffer(ctx, ptr + len, hh->uts_version_len);
 	if (ret < 0)
 		return ret;
-	ret = cr_write_obj_buffer(ctx, ptr + 2*len, len);
+	len += hh->uts_version_len;
+
+	ret = cr_write_obj_buffer(ctx, ptr + len, hh->uts_machine_len);
 
 	return ret;
 }
-- 
1.5.6.3
