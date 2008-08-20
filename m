From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC v2][PATCH 9/9] remove ->cksum field
Date: Wed, 20 Aug 2008 12:26:08 -0700
Message-ID: <20080820192608.CEBC256B__48707.910886924$1219260615$gmane$org@nimitz>
References: <20080820192557.98788FAB@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080820192557.98788FAB@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


This is unused so far.  We'll add it back later.

---

 oren-cr.git-dave/checkpoint/checkpoint.c |    2 --
 oren-cr.git-dave/checkpoint/ckpt_hdr.h   |    1 -
 oren-cr.git-dave/checkpoint/restart.c    |    3 +--
 3 files changed, 1 insertion(+), 5 deletions(-)

diff -puN checkpoint/checkpoint.c~remove-unused-cksum checkpoint/checkpoint.c
--- oren-cr.git/checkpoint/checkpoint.c~remove-unused-cksum	2008-08-20 12:12:51.000000000 -0700
+++ oren-cr.git-dave/checkpoint/checkpoint.c	2008-08-20 12:12:51.000000000 -0700
@@ -125,8 +125,6 @@ static int cr_write_tail(struct cr_ctx *
 	h.id = 0;
 
 	hh->magic = CR_HEADER_MAGIC;
-	hh->cksum[0] = 1;
-       	hh->cksum[1] = 1;	/* TBD ... */
 
 	ret = cr_write_obj(ctx, &h, hh);
 	kfree(hh);
diff -puN checkpoint/ckpt_hdr.h~remove-unused-cksum checkpoint/ckpt_hdr.h
--- oren-cr.git/checkpoint/ckpt_hdr.h~remove-unused-cksum	2008-08-20 12:12:51.000000000 -0700
+++ oren-cr.git-dave/checkpoint/ckpt_hdr.h	2008-08-20 12:12:51.000000000 -0700
@@ -43,7 +43,6 @@ struct cr_hdr_head {
 
 struct cr_hdr_tail {
 	__u32 magic;
-	__u32 cksum[2];
 };
 
 struct cr_hdr_task {
diff -puN checkpoint/restart.c~remove-unused-cksum checkpoint/restart.c
--- oren-cr.git/checkpoint/restart.c~remove-unused-cksum	2008-08-20 12:12:51.000000000 -0700
+++ oren-cr.git-dave/checkpoint/restart.c	2008-08-20 12:12:51.000000000 -0700
@@ -113,8 +113,7 @@ static int cr_read_tail(struct cr_ctx *c
 	if (ret < 0)
 		return ret;
 
-	if (hh->magic != CR_HEADER_MAGIC ||
-	    hh->cksum[0] != 1 || hh->cksum[1] != 1)
+	if (hh->magic != CR_HEADER_MAGIC)
 		return -EINVAL;
 
 	kfree(hh);
_
