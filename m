From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH V6 02/10] proc_ns: define PROC_*_INIT_INO in terms of
	PROC_DYNAMIC_FIRST
Date: Fri, 17 Apr 2015 03:35:49 -0400
Message-ID: <5a5ff7532b7cf37bead4d442c718961cc5a18e75.1429252659.git.rgb@redhat.com>
References: <cover.1429252659.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cover.1429252659.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <cover.1429252659.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
References: <cover.1429252659.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Since PROC_*_INIT_INO are all defined relative to PROC_DYNAMIC_FIRST, make it
explicit.

Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 fs/proc/generic.c       |    3 +--
 include/linux/proc_ns.h |    9 +++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index b7f268e..9f7726a 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -11,6 +11,7 @@
 #include <linux/errno.h>
 #include <linux/time.h>
 #include <linux/proc_fs.h>
+#include <linux/proc_ns.h>
 #include <linux/stat.h>
 #include <linux/mm.h>
 #include <linux/module.h>
@@ -121,8 +122,6 @@ static int xlate_proc_name(const char *name, struct proc_dir_entry **ret,
 static DEFINE_IDA(proc_inum_ida);
 static DEFINE_SPINLOCK(proc_inum_lock); /* protects the above */
 
-#define PROC_DYNAMIC_FIRST 0xF0000000U
-
 /*
  * Return an inode number between PROC_DYNAMIC_FIRST and
  * 0xffffffff, or zero on failure.
diff --git a/include/linux/proc_ns.h b/include/linux/proc_ns.h
index 09ff93c..340372b 100644
--- a/include/linux/proc_ns.h
+++ b/include/linux/proc_ns.h
@@ -32,12 +32,13 @@ extern const struct proc_ns_operations *ns_entries[];
 /*
  * We always define these enumerators
  */
+#define PROC_DYNAMIC_FIRST 0xF0000000U
 enum {
 	PROC_ROOT_INO		= 1,
-	PROC_IPC_INIT_INO	= 0xEFFFFFFFU,
-	PROC_UTS_INIT_INO	= 0xEFFFFFFEU,
-	PROC_USER_INIT_INO	= 0xEFFFFFFDU,
-	PROC_PID_INIT_INO	= 0xEFFFFFFCU,
+	PROC_IPC_INIT_INO	= PROC_DYNAMIC_FIRST - 1,
+	PROC_UTS_INIT_INO	= PROC_DYNAMIC_FIRST - 2,
+	PROC_USER_INIT_INO	= PROC_DYNAMIC_FIRST - 3,
+	PROC_PID_INIT_INO	= PROC_DYNAMIC_FIRST - 4,
 };
 
 #ifdef CONFIG_PROC_FS
-- 
1.7.1
