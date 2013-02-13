From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 17/85] coda: Restrict coda messages to the initial pid
	namespace
Date: Wed, 13 Feb 2013 09:51:06 -0800
Message-ID: <1360777934-5663-17-git-send-email-ebiederm__669.922508723353$1360778333$gmane$org@xmission.com>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1360777934-5663-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Jan Harkes <jaharkes-ETDLCGt7PQU3uPMLIKxrzw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Remove the slight chance that pids in coda messages will be
interpreted in the wrong pid namespace.

- Explicitly send all pids in coda messages in the initial pid
  namespace.
- Only allow mounts from processes in the initial pid namespace.
- Only allow processes in the initial pid namespace to open the coda
  character device to communicate with coda.

Cc: Jan Harkes <jaharkes-ETDLCGt7PQU3uPMLIKxrzw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/coda/inode.c  |    4 ++++
 fs/coda/psdev.c  |    4 ++++
 fs/coda/upcall.c |    4 ++--
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/coda/inode.c b/fs/coda/inode.c
index be2aa49..77bbaf4 100644
--- a/fs/coda/inode.c
+++ b/fs/coda/inode.c
@@ -20,6 +20,7 @@
 #include <linux/file.h>
 #include <linux/vfs.h>
 #include <linux/slab.h>
+#include <linux/pid_namespace.h>
 
 #include <asm/uaccess.h>
 
@@ -157,6 +158,9 @@ static int coda_fill_super(struct super_block *sb, void *data, int silent)
 	int error;
 	int idx;
 
+	if (task_active_pid_ns(current) != &init_pid_ns)
+		return -EINVAL;
+
 	idx = get_device_index((struct coda_mount_data *) data);
 
 	/* Ignore errors in data, for backward compatibility */
diff --git a/fs/coda/psdev.c b/fs/coda/psdev.c
index 761d5b3..dd60f90 100644
--- a/fs/coda/psdev.c
+++ b/fs/coda/psdev.c
@@ -37,6 +37,7 @@
 #include <linux/list.h>
 #include <linux/mutex.h>
 #include <linux/device.h>
+#include <linux/pid_namespace.h>
 #include <asm/io.h>
 #include <asm/poll.h>
 #include <asm/uaccess.h>
@@ -266,6 +267,9 @@ static int coda_psdev_open(struct inode * inode, struct file * file)
 	struct venus_comm *vcp;
 	int idx, err;
 
+	if (task_active_pid_ns(current) != &init_pid_ns)
+		return -EINVAL;
+
 	idx = iminor(inode);
 	if (idx < 0 || idx >= MAX_CODADEVS)
 		return -ENODEV;
diff --git a/fs/coda/upcall.c b/fs/coda/upcall.c
index 0c68fd3..5c6d2cd 100644
--- a/fs/coda/upcall.c
+++ b/fs/coda/upcall.c
@@ -50,8 +50,8 @@ static void *alloc_upcall(int opcode, int size)
 		return ERR_PTR(-ENOMEM);
 
         inp->ih.opcode = opcode;
-	inp->ih.pid = current->pid;
-	inp->ih.pgid = task_pgrp_nr(current);
+	inp->ih.pid = task_pid_nr_ns(current, &init_pid_ns);
+	inp->ih.pgid = task_pgrp_nr_ns(current, &init_pid_ns);
 	inp->ih.uid = current_fsuid();
 
 	return (void*)inp;
-- 
1.7.5.4
