From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 7/8] add c/r info to fdinfo
Date: Fri, 27 Feb 2009 12:34:34 -0800
Message-ID: <20090227203434.D4729F99@kernel>
References: <20090227203425.F3B51176@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090227203425.F3B51176@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


Use the new checkpoint/restart file functions to query
and report on each fd in the /proc/$$/fdinfo/X file.

This should provide an easy way to examine processes
at runtime to see what exactly is causing their inability
to checkpoint.

Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 linux-2.6.git-dave/fs/proc/base.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff -puN fs/proc/base.c~add-cr-part-to-fdinfo fs/proc/base.c
--- linux-2.6.git/fs/proc/base.c~add-cr-part-to-fdinfo	2009-02-27 12:07:40.000000000 -0800
+++ linux-2.6.git-dave/fs/proc/base.c	2009-02-27 12:07:40.000000000 -0800
@@ -80,6 +80,7 @@
 #include <linux/oom.h>
 #include <linux/elf.h>
 #include <linux/pid_namespace.h>
+#include <linux/checkpoint.h>
 #include "internal.h"
 
 /* NOTE:
@@ -1636,6 +1637,7 @@ out:
 
 static void proc_fd_write_info(struct file *file, char *info)
 {
+	int checkpointable;
 	int max = PROC_FDINFO_MAX;
 	int p = 0;
 	if (!info)
@@ -1643,6 +1645,12 @@ static void proc_fd_write_info(struct fi
 
 	p += snprintf(info+p, max-p, "pos:\t%lli\n", (long long) file->f_pos);
 	p += snprintf(info+p, max-p, "flags:\t0%o\n", file->f_flags);
+
+	checkpointable = cr_file_supported(file);
+	p += snprintf(info+p, max-p, "checkpointable:\t%d", checkpointable);
+	if (!checkpointable)
+		p += cr_explain_file(file, info+p, max-p);
+	p += snprintf(info+p, max-p, "\n");
 }
 
 static int proc_fd_info(struct inode *inode, struct path *path, char *info)
_
