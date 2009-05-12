From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] cr: child user namespace must grab ref to creator
Date: Tue, 12 May 2009 07:34:16 -0500
Message-ID: <20090512123416.GA29972@us.ibm.com>
References: <20090511160424.GA12234@us.ibm.com>
	<20090511160539.GD12286@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090511160539.GD12286-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

This applies on top of yesterday's patchset.

thanks,
-serge

From f70a08dc6abdba372e1b3e1f25aadb919d07b171 Mon Sep 17 00:00:00 2001
From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Tue, 12 May 2009 08:17:34 -0400
Subject: [PATCH 1/1] cr: child user namespace must grab ref to creator

With this change plus Oren's proposed fix to obj_put() after
obj_new() during restore_obj(), refcounting on user_ns and
user_struct should be completely correct.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/process.c |   24 +++---------------------
 1 files changed, 3 insertions(+), 21 deletions(-)

diff --git a/checkpoint/process.c b/checkpoint/process.c
index a469f46..a8cd674 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -569,27 +569,9 @@ static struct user_namespace *restore_read_userns(struct ckpt_ctx *ctx)
 	if (IS_ERR(ns))
 		return ns;
 
-	/* we need a way to keep track of the new_root just
-	 * until we alloc the  uid inthe userns which we
-	 * actually want.  Then we can do:
-	 *   if (uid == 0)
-	 *      new_user = new_root;
-	 *   else
-	 *      new_user = alloc_uid(ns, uid);
-	 *      free_uid(new_root);
-	 *      cred->user = new_user;
-	 * This is because new_root is right now the only
-	 * thing pinning the user_ns.
-	 * BUT I don't think I can just add it to the
-	 * objhash, bc then we use up an objref which we'll
-	 * need for the next real objhash object, right?
-	 * I suppose I could just add them to the top of
-	 * the objref space :)  (MAX_INT-1)
-	 *
-	 * For now, this code is just plain wrong bc it will
-	 * leak the user_ns and its root_user when the task
-	 * exits.  But, a leak is better than an OOPS...
-	 */
+	/* new_user_ns() doesn't bump creator's refcount */
+	get_uid(creator);
+
 	return ns;
 }
 
-- 
1.6.1
