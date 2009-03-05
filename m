From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 08/11] expose file checkpointability and reasoning in
	/proc
Date: Thu, 05 Mar 2009 08:39:09 -0800
Message-ID: <20090305163909.4204C711@kernel>
References: <20090305163857.0C18F3FD@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090305163857.0C18F3FD@kernel>
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
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


This is the first in a set of things that checked to
ensure that a process or entire container is
able to be checkpointed.


Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---

 linux-2.6.git-dave/fs/proc/base.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff -puN fs/proc/base.c~proc-part-of-f_op-conversion fs/proc/base.c
--- linux-2.6.git/fs/proc/base.c~proc-part-of-f_op-conversion	2009-03-05 08:37:03.000000000 -0800
+++ linux-2.6.git-dave/fs/proc/base.c	2009-03-05 08:37:03.000000000 -0800
@@ -80,6 +80,7 @@
 #include <linux/oom.h>
 #include <linux/elf.h>
 #include <linux/pid_namespace.h>
+#include <linux/checkpoint.h>
 #include "internal.h"
 
 /* NOTE:
@@ -1645,6 +1646,7 @@ out:
 
 static void proc_fd_write_info(struct file *file, char *info)
 {
+	int checkpointable = 0;
 	int max = PROC_FDINFO_MAX;
 	int p = 0;
 	if (!info)
@@ -1652,6 +1654,12 @@ static void proc_fd_write_info(struct fi
 
 	p += scnprintf(info+p, max-p, "pos:\t%lli\n", (long long) file->f_pos);
 	p += scnprintf(info+p, max-p, "flags:\t0%o\n", file->f_flags);
+
+	if (file->f_op->checkpoint)
+		checkpointable = 1;
+	p += scnprintf(info+p, max-p, "checkpointable:\t%d", checkpointable);
+	if (!checkpointable)
+		p += cr_explain_file(file, info+p, max-p);
 }
 
 static int proc_fd_info(struct inode *inode, struct path *path, char *info)
_
