From: Balaji Rao <balajirrao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] trivial containers comment fixed
Date: Sat, 22 Sep 2007 12:04:04 +0530
Message-ID: <20070922063403.GA7286@sriram.theyogi.co.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Balaji Rao <balajirao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Index: linux-2.6.23-rc6-mm1/kernel/container.c
===================================================================
--- linux-2.6.23-rc6-mm1.orig/kernel/container.c
+++ linux-2.6.23-rc6-mm1/kernel/container.c
@@ -1974,7 +1974,7 @@ static void init_container_css(struct co
 /*
  *	container_create - create a container
  *	parent:	container that will be parent of the new container.
- *	name:		name of the new container. Will be strcpy'ed.
+ *	dentry:		dentry of the new container.
  *	mode:		mode to set on new inode
  *
  *	Must be called with the mutex on the parent inode held
-- 
regards,
balaji rao

All religions, arts and sciences are branches of the same tree. All these aspirations are directed toward ennobling man's life, lifting it from the sphere of mere physical existence and leading the individual towards freedom.
