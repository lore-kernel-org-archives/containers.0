From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/5][v5][cr]: Move file_lock macros into linux/fs.h
Date: Thu, 28 Oct 2010 23:16:37 -0700
Message-ID: <1288333001-28838-2-git-send-email-sukadev__29266.1004503772$1288332609$gmane$org@linux.vnet.ibm.com>
References: <1288333001-28838-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1288333001-28838-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

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
