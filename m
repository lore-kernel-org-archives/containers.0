From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 10/17][cr][v4]: Initialize ->fl_break_time to 0
Date: Mon, 16 Aug 2010 12:43:14 -0700
Message-ID: <1281987801-1293-11-git-send-email-sukadev__37258.200630504$1281988268$gmane$org@linux.vnet.ibm.com>
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

Explicitly initialize ->fl_break_time to 0 in locks_init_lock() and
__locks_copy_lock(). ->fl_break_time will be later used during
checkpoint/restart of an applicaton that has a file-lease.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fs/locks.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index c62ab7f..0bd5af7 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -185,6 +185,7 @@ void locks_init_lock(struct file_lock *fl)
 	fl->fl_flags = 0;
 	fl->fl_type = 0;
 	fl->fl_start = fl->fl_end = 0;
+	fl->fl_break_time = 0UL;
 	fl->fl_ops = NULL;
 	fl->fl_lmops = NULL;
 }
@@ -228,6 +229,7 @@ void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
 	new->fl_type = fl->fl_type;
 	new->fl_start = fl->fl_start;
 	new->fl_end = fl->fl_end;
+	new->fl_break_time = 0UL;
 	new->fl_ops = NULL;
 	new->fl_lmops = NULL;
 }
-- 
1.6.0.4
