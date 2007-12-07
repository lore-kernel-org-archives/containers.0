From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] [PATCH 6/8] userns: agp: remove uid comparison as security
	check
Date: Fri, 7 Dec 2007 13:15:08 -0600
Message-ID: <20071207191508.GF10432@sergelap.austin.ibm.com>
References: <20071207191259.GA10293@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20071207191259.GA10293-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

From d4ca1a9749c5b40325ec2db9fcde2f2cbd0e0978 Mon Sep 17 00:00:00 2001
From: sergeh-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org <sergeh-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Wed, 5 Dec 2007 13:55:36 -0800
Subject: [RFC] [PATCH 6/8] userns: agp: remove uid comparison as security check

In the face of user namespaces, a uid==0 check for security is
not safe.  Switch to a capability check.

I'm not sure I picked the right capability, but this being AGP
CAP_SYS_RAWIO seemed to make sense.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 drivers/char/agp/frontend.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/char/agp/frontend.c b/drivers/char/agp/frontend.c
index 9bd5a95..55d7a82 100644
--- a/drivers/char/agp/frontend.c
+++ b/drivers/char/agp/frontend.c
@@ -689,7 +689,7 @@ static int agp_open(struct inode *inode, struct file *file)
 	set_bit(AGP_FF_ALLOW_CLIENT, &priv->access_flags);
 	priv->my_pid = current->pid;
 
-	if ((current->uid == 0) || (current->suid == 0)) {
+	if (capable(CAP_SYS_RAWIO)) {
 		/* Root priv, can be controller */
 		set_bit(AGP_FF_ALLOW_CONTROLLER, &priv->access_flags);
 	}
-- 
1.5.1
