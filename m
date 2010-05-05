From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][cr][PATCH  1/6] Move file_lock macros into linux/fs.h
Date: Tue, 4 May 2010 22:30:49 -0700
Message-ID: <20100505053049.GA20993__40325.8262704641$1273037119$gmane$org@us.ibm.com>
References: <20100505053016.GA20483@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100505053016.GA20483-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From 3c9fd11b0bdd12ba7b3f78e7fc810f1d83ca6986 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Thu, 29 Apr 2010 23:33:39 -0700
Subject: [RFC][cr][PATCH  1/6] Move file_lock macros into linux/fs.h

Move IS_POSIX(), IS_FLOCK(), IS_LEASE() and 'for_each_lock()' into
include/linux/fs.h since these are also needed to checkpoint/restart
file-locks.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/locks.c         |    7 -------
 include/linux/fs.h |    7 +++++++
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 9cd859e..da53795 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -130,16 +130,9 @@
 
 #include <asm/uaccess.h>
 
-#define IS_POSIX(fl)	(fl->fl_flags & FL_POSIX)
-#define IS_FLOCK(fl)	(fl->fl_flags & FL_FLOCK)
-#define IS_LEASE(fl)	(fl->fl_flags & FL_LEASE)
-
 int leases_enable = 1;
 int lease_break_time = 45;
 
-#define for_each_lock(inode, lockp) \
-	for (lockp = &inode->i_flock; *lockp != NULL; lockp = &(*lockp)->fl_next)
-
 static LIST_HEAD(file_lock_list);
 static LIST_HEAD(blocked_list);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ee725ff..909a535 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1088,6 +1088,13 @@ struct file_lock {
 	} fl_u;
 };
 
+#define IS_POSIX(fl)	(fl->fl_flags & FL_POSIX)
+#define IS_FLOCK(fl)	(fl->fl_flags & FL_FLOCK)
+#define IS_LEASE(fl)	(fl->fl_flags & FL_LEASE)
+
+#define for_each_lock(inode, lockp) \
+	for (lockp = &inode->i_flock; *lockp != NULL; lockp = &(*lockp)->fl_next)
+
 /* The following constant reflects the upper bound of the file/locking space */
 #ifndef OFFSET_MAX
 #define INT_LIMIT(x)	(~((x)1 << (sizeof(x)*8 - 1)))
-- 
1.6.0.4
