From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] user-c/r: get rid of ckpt_hdr_vpids - can be inferred
	at restart
Date: Tue, 30 Mar 2010 14:39:36 -0500
Message-ID: <20100330193936.GA12037@us.ibm.com>
References: <1269930734-6887-1-git-send-email-orenl@cs.columbia.edu>
	<1269930734-6887-2-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1269930734-6887-2-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> And some cleanup of recent nested-pids work, and re-generate
> user headers.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

...

> @@ -2721,26 +2716,28 @@ static int assign_vpids(struct ckpt_ctx *ctx)
> 
>  static int ckpt_read_vpids(struct ckpt_ctx *ctx)
>  {
> -	struct ckpt_hdr_vpids *h;
> -	int len, ret;
> +	int i, len, ret;
> 
> -	h = (struct ckpt_hdr_vpids *) ctx->vpids;
> -	ret = ckpt_read_obj_type(ctx, h, sizeof(*h), CKPT_HDR_VPIDS);
> -	if (ret < 0)
> -		return ret;
> +	for (i = 0; i < ctx->tasks_nr; i++)

s/tasks_nr/pids_nr/

With that applied,

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Tested-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Or:

From 13053aac0bfdd88ea10ffd601bbf43452bf0226e Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 30 Mar 2010 15:37:47 -0400
Subject: [PATCH user-cr] fix ckpt_read_vpids

tasks_nr is still 0 at this point.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 restart.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/restart.c b/restart.c
index e7c874b..b26d79a 100644
--- a/restart.c
+++ b/restart.c
@@ -2373,7 +2373,7 @@ static int ckpt_read_vpids(struct ckpt_ctx *ctx)
 {
 	int i, len, ret;
 
-	for (i = 0; i < ctx->tasks_nr; i++)
+	for (i = 0; i < ctx->pids_nr; i++)
 		ctx->vpids_nr += ctx->pids_arr[i].depth;
 
 	ckpt_dbg("number of vpids: %d\n", ctx->vpids_nr);
-- 
1.7.0
