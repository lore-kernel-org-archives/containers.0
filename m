From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 12/17][cr][v4]: Add ->fl_break_notified field.
Date: Mon, 16 Aug 2010 12:43:16 -0700
Message-ID: <1281987801-1293-13-git-send-email-sukadev__42554.8702748076$1281988211$gmane$org@linux.vnet.ibm.com>
References: <1281987801-1293-1-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1281987801-1293-1-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

The file_lock->fl_break_notified field will be used when checkpointing and
restarting a file-lease. It is needed if the application was checkpointed
during the lease-break-protocol, to "remember" if the application was notified
of the lease-break.

This patch just initializes the ->fl_break_notified field. It will be used
in a follow-on patch, when checkpoint/restart of file-leases are implemented.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/locks.c         |    7 +++++++
 include/linux/fs.h |    1 +
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 9a00876..b5eb4c0 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -185,6 +185,7 @@ void locks_init_lock(struct file_lock *fl)
 	fl->fl_flags = 0;
 	fl->fl_type = 0;
 	fl->fl_type_prev = 0;
+	fl->fl_break_notified = 0;
 	fl->fl_start = fl->fl_end = 0;
 	fl->fl_break_time = 0UL;
 	fl->fl_ops = NULL;
@@ -230,6 +231,7 @@ void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
 	new->fl_type = fl->fl_type;
 	new->fl_type_prev = fl->fl_type_prev;
 	new->fl_start = fl->fl_start;
+	new->fl_break_notified = fl->fl_break_notified;
 	new->fl_end = fl->fl_end;
 	new->fl_break_time = 0UL;
 	new->fl_ops = NULL;
@@ -458,6 +460,7 @@ static int lease_init(struct file *filp, int type, struct file_lock *fl)
 
 	fl->fl_file = filp;
 	fl->fl_flags = FL_LEASE;
+	fl->fl_break_notified = 0;
 	fl->fl_start = 0;
 	fl->fl_end = OFFSET_MAX;
 	fl->fl_ops = NULL;
@@ -1141,6 +1144,8 @@ int lease_modify(struct file_lock **before, int arg)
 	struct file_lock *fl = *before;
 	int error = assign_type(fl, arg);
 
+	fl->fl_break_notified = 0;
+
 	if (error)
 		return error;
 	locks_wake_up_blocks(fl);
@@ -1234,8 +1239,10 @@ int __break_lease(struct inode *inode, unsigned int mode)
 			fl->fl_type_prev = fl->fl_type;
 			fl->fl_type = future;
 			fl->fl_break_time = break_time;
+
 			/* lease must have lmops break callback */
 			fl->fl_lmops->fl_break(fl);
+			fl->fl_break_notified = 1;
 		}
 	}
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 299cc09..c21f002 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1067,6 +1067,7 @@ struct file_lock {
 	unsigned char fl_flags;
 	unsigned char fl_type;
 	unsigned char fl_type_prev;
+	unsigned char fl_break_notified;
 	unsigned int fl_pid;
 	struct pid *fl_nspid;
 	wait_queue_head_t fl_wait;
-- 
1.6.0.4
