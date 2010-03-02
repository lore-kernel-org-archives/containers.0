From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: fix "scheduling in atomic" while restoring ipc shm
Date: Tue, 2 Mar 2010 11:48:55 -0600
Message-ID: <20100302174855.GA16352@us.ibm.com>
References: <201002241902.19623@zigzag.lvk.cs.msu.su>
	<1267054267-2819-1-git-send-email-orenl@cs.columbia.edu>
	<4B85E62B.90804@cs.columbia.edu>
	<201003021750.47123@zigzag.lvk.cs.msu.su>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201003021750.47123-G0jJXfdb3EhtNF42gJWJKsm+4N3/VObd@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Nikita V. Youshchenko" <yoush-/llMDZXAvAOHXe+LvDLADg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, leo-n4oKp6kCDthKyFCjRbgQbg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Nikita V. Youshchenko (yoush-/llMDZXAvAOHXe+LvDLADg@public.gmane.org):
> > Hi Nikita,
> >
> > Thanks for the report and the analysis. It actually helped to
> > pinpoint a couple of other minor issues in the code. This patch
> > should fix all of these.
> >
> > Oren.
> 
> Hi Oren.
> 
> With ckpt-v19 plus this patch applied, we still are getting a kernel
> crash, with BUG() fired at
> +       ipc = idr_find(&msg_ids->ipcs_idr, h->perms.id);
> +       BUG_ON(!ipc);
> added by the patch.
> 
> By looking at the code, I can't understand how this idr_find() can at
> all succeed, if the namespace it is looking in was just created and
> is empty.
> 
> What code adds object in question into this idr?

The do_semget() in ipc/checkpoint_sem.c:restore_ipc_sem() does that.
At the very least Oren's comment was wrong in that perms->seq will
not get restored unless we continue to do it explicitly.  With the
following trivial patch I sometimes get success, but usually not.
Still trying to find what's up...

From 809cc2f1eccc39d45a145e280b6d992e4fa1e683 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 2 Mar 2010 05:43:21 -0600
Subject: [PATCH 1/1] restore perm->seq

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 ipc/checkpoint.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
index 06027c2..f865471 100644
--- a/ipc/checkpoint.c
+++ b/ipc/checkpoint.c
@@ -210,6 +210,7 @@ int restore_load_ipc_perms(struct ckpt_ctx *ctx,
 	perm->cuid = h->cuid;
 	perm->cgid = h->cgid;
 	perm->mode = h->mode;
+	perm->seq = h->seq;
 
 	return security_restore_obj(ctx, (void *)perm,
 				    CKPT_SECURITY_IPC,
-- 
1.6.0.6


-serge
