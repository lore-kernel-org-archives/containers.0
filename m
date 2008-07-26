From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 5/6] user namespaces: refuse create in other user_ns
Date: Fri, 25 Jul 2008 19:28:01 -0500
Message-ID: <20080726002801.GE29874@us.ibm.com>
References: <20080726002700.GA29686@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080726002700.GA29686-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

From 4d2c23452a67e25856893ab16fefd0f6e5aa58df Mon Sep 17 00:00:00 2001
From: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date: Thu, 24 Jul 2008 06:37:43 -0500
Subject: [PATCH 5/6] user namespaces: refuse create in other user_ns

Refuse writing to a directory in another user_ns.  We can't
support file creation because we wouldn't know who should own
the file.  This refuses file deletion as well - which I think
is the sensible thing to do.

File writing is still allowed if the 'user other' permissions
include write.  That again probably makes sense for logging
and such.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/namei.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index adf5f1b..b39a990 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -213,6 +213,12 @@ int generic_permission(struct inode *inode, int mask,
 
 check:
 	/*
+	 * Can't write to a directory in another user_ns
+	 * We wouldn't know who to make the owner!
+	 */
+	if (!same_userns && S_ISDIR(inode->i_mode) && (mask&MAY_WRITE))
+		return -EACCES;
+	/*
 	 * If the DACs are ok we don't need any capability check.
 	 */
 	if (((mode & mask & (MAY_READ|MAY_WRITE|MAY_EXEC)) == mask))
-- 
1.5.4.3
