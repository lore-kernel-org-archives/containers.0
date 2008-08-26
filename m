From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH] cgroup(fix critical bug): new handling for tasks file
Date: Tue, 26 Aug 2008 09:47:58 +0800
Message-ID: <48B360CE.2010501__40391.0190835179$1219715544$gmane$org@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

In original code, we kmalloc a lot of memory when we open cgroup.tasks.
_This memory is allocated by kmalloc_, So this memory is not statistical
for this process or this user. This is a critical bug.

An unprivileged user(attacker) may use all his available processes
to enlarge cgroup.tasks file and use all his available open-files
to open cgroup.tasks many many times. Thus he will _steal_ a lot of
memory.
If the size of memory that he steal is large than system's memory,
the system will oops.

This script will show how many memory be used when open a file 1000 times
--------------------
#!/bin/sh

file=$1

use_mem=$(free -k | awk '{if(NR==2) print $3}')
i=24
while ((i<1024))
do
	eval "exec $i<$file"
	((i++))
done
use_mem_afer_open=$(free -k | awk '{if(NR==2) print $3}')
echo Use about $((use_mem_afer_open - use_mem))K physical memories \
	for open $file 1000 times
-----------------------
$ ./memory.sh /proc/cpuinfo
Use about 156K physical memories for open /proc/cpuinfo 1000 times
$ ./memory.sh /proc/cpuinfo
Use about 0K physical memories for open /proc/cpuinfo 1000 times
$ ./memory.sh /proc/cpuinfo
Use about -36K physical memories for open /proc/cpuinfo 1000 times
$ ./memory.sh /proc/cpuinfo
Use about 0K physical memories for open /proc/cpuinfo 1000 times
$ ./memory.sh /proc/cpuinfo
Use about 56K physical memories for open /proc/cpuinfo 1000 times
----------------------
$ wc -l /dev/cpuset/tasks
1163
$ ./memory.sh /dev/cpuset/tasks
Use about 7896K physical memories for open /dev/cpuset/tasks 1000 times
$ ./memory.sh /dev/cpuset/tasks
Use about 8008K physical memories for open /dev/cpuset/tasks 1000 times
$ ./memory.sh /dev/cpuset/tasks
Use about 8104K physical memories for open /dev/cpuset/tasks 1000 times
$ ./memory.sh /dev/cpuset/tasks
Use about 7756K physical memories for open /dev/cpuset/tasks 1000 times
$ ./memory.sh /dev/cpuset/tasks
Use about 8104K physical memories for open /dev/cpuset/tasks 1000 times
-----------------------

This patch will fix this bug and save memory when open tasks file twice
or more. All open files that open the same cgroup's tasks file
share the pids array.

some semantic meanings are changed:
1) cgroup's tasks file is nonseekable now.
2) dependent auto-updating:
   when this tasks file is opened again(by this process or others), the
   unread part of this file(unread pids) are updated.
   2.1) a task leave this cgroup when after open before read
	may not be read.
   2.2) a task enter this cgroup when after open before read
	may be read.

2.1)compare with the original semantic meaning:
pids of all tasks in this cgroup when opening will be read. Even this
taks has left when read.

testing after fix:

$ wc -l /dev/cpuset/tasks
1056 /dev/cpuset/tasks
$ ./memory.sh /dev/cpuset/tasks
Use about 112K physical memories for open /dev/cpuset/tasks 1000 times
$ ./memory.sh /dev/cpuset/tasks
Use about 120K physical memories for open /dev/cpuset/tasks 1000 times
$ ./memory.sh /dev/cpuset/tasks
Use about 52K physical memories for open /dev/cpuset/tasks 1000 times
$ ./memory.sh /dev/cpuset/tasks
Use about 16K physical memories for open /dev/cpuset/tasks 1000 times
$ ./memory.sh /dev/cpuset/tasks
Use about 32K physical memories for open /dev/cpuset/tasks 1000 times
$ ./memory.sh /dev/cpuset/tasks
Use about 8K physical memories for open /dev/cpuset/tasks 1000 times
$ ./memory.sh /dev/cpuset/tasks
Use about 120K physical memories for open /dev/cpuset/tasks 1000 times

these testes are also OK
$ dd  ifs=1  if=/dev/cpuset/tasks
$ dd  ifs=2  if=/dev/cpuset/tasks
$ dd  ifs=3  if=/dev/cpuset/tasks
...

and testes for complex open/read sequence(multi-thread) are OK.

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index c98dd7c..5e88178 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -15,6 +15,7 @@
 #include <linux/rcupdate.h>
 #include <linux/cgroupstats.h>
 #include <linux/prio_heap.h>
+#include <linux/rwsem.h>
 
 #ifdef CONFIG_CGROUPS
 
@@ -137,6 +138,12 @@ struct cgroup {
 	 * release_list_lock
 	 */
 	struct list_head release_list;
+
+	/* tasks file handling */
+	struct rw_semaphore pids_mutex;
+	int pids_use_count;
+	int pids_length;
+	pid_t *tasks_pids;
 };
 
 /* A css_set is a structure holding pointers to a set of
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 13932ab..3c87f20 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1997,15 +1997,13 @@ int cgroup_scan_tasks(struct cgroup_scanner *scan)
  * but we cannot guarantee that the information we produce is correct
  * unless we produce it entirely atomically.
  *
- * Upon tasks file open(), a struct ctr_struct is allocated, that
- * will have a pointer to an array (also allocated here).  The struct
+ * Upon tasks file open(), a struct ctr_struct is allocated.  The struct
  * ctr_struct * is stored in file->private_data.  Its resources will
- * be freed by release() when the file is closed.  The array is used
- * to sprintf the PIDs and then used by read().
+ * be freed by release() when the file is closed.
  */
 struct ctr_struct {
-	char *buf;
-	int bufsz;
+	pid_t last_pid; /* last read pid for tasks file */
+	int unconsumed; /* bytes unconsumed for last_pid */
 };
 
 /*
@@ -2089,21 +2087,6 @@ static int cmppid(const void *a, const void *b)
 }
 
 /*
- * Convert array 'a' of 'npids' pid_t's to a string of newline separated
- * decimal pids in 'buf'.  Don't write more than 'sz' chars, but return
- * count 'cnt' of how many chars would be written if buf were large enough.
- */
-static int pid_array_to_buf(char *buf, int sz, pid_t *a, int npids)
-{
-	int cnt = 0;
-	int i;
-
-	for (i = 0; i < npids; i++)
-		cnt += snprintf(buf + cnt, max(sz - cnt, 0), "%d\n", a[i]);
-	return cnt;
-}
-
-/*
  * Handle an open on 'tasks' file.  Prepare a buffer listing the
  * process id's of tasks currently attached to the cgroup being opened.
  *
@@ -2115,7 +2098,6 @@ static int cgroup_tasks_open(struct inode *unused, struct file *file)
 	struct ctr_struct *ctr;
 	pid_t *pidarray;
 	int npids;
-	char c;
 
 	if (!(file->f_mode & FMODE_READ))
 		return 0;
@@ -2123,6 +2105,8 @@ static int cgroup_tasks_open(struct inode *unused, struct file *file)
 	ctr = kmalloc(sizeof(*ctr), GFP_KERNEL);
 	if (!ctr)
 		goto err0;
+	ctr->last_pid = 0;
+	ctr->unconsumed = 0;
 
 	/*
 	 * If cgroup gets more users after we read count, we won't have
@@ -2139,47 +2123,120 @@ static int cgroup_tasks_open(struct inode *unused, struct file *file)
 		npids = pid_array_load(pidarray, npids, cgrp);
 		sort(pidarray, npids, sizeof(pid_t), cmppid, NULL);
 
-		/* Call pid_array_to_buf() twice, first just to get bufsz */
-		ctr->bufsz = pid_array_to_buf(&c, sizeof(c), pidarray, npids) + 1;
-		ctr->buf = kmalloc(ctr->bufsz, GFP_KERNEL);
-		if (!ctr->buf)
-			goto err2;
-		ctr->bufsz = pid_array_to_buf(ctr->buf, ctr->bufsz, pidarray, npids);
-
-		kfree(pidarray);
-	} else {
-		ctr->buf = NULL;
-		ctr->bufsz = 0;
+		down_write(&cgrp->pids_mutex);
+		if (cgrp->tasks_pids)
+			kfree(cgrp->tasks_pids);
+		cgrp->tasks_pids = pidarray;
+		cgrp->pids_length = npids;
+		cgrp->pids_use_count++;
+		up_write(&cgrp->pids_mutex);
 	}
 	file->private_data = ctr;
+	nonseekable_open(unused, file);
 	return 0;
 
-err2:
-	kfree(pidarray);
 err1:
 	kfree(ctr);
 err0:
 	return -ENOMEM;
 }
 
+#define PIDBUF_LEN 128
 static ssize_t cgroup_tasks_read(struct cgroup *cgrp,
 				    struct cftype *cft,
 				    struct file *file, char __user *buf,
 				    size_t nbytes, loff_t *ppos)
 {
 	struct ctr_struct *ctr = file->private_data;
+	pid_t pid = ctr->last_pid;
+	int unconsumed = ctr->unconsumed;
+
+	int index = 0, end;
+	char pidbuf[PIDBUF_LEN];
+	int buf_count, total_count = 0;
+
+	down_read(&cgrp->pids_mutex);
+
+	/* write the unconsumed part of last pid to buf */
+	if (unconsumed > 0) {
+		int byte_start;
+		buf_count = snprintf(pidbuf, PIDBUF_LEN, "%d\n", pid);
+		byte_start = buf_count - unconsumed;
+		total_count = min(unconsumed, (int)nbytes);
+		if (copy_to_user(buf, pidbuf + byte_start, total_count)) {
+			total_count = -EFAULT;
+			goto done;
+		}
+		if (total_count == nbytes) {
+			ctr->unconsumed = unconsumed - total_count;
+			goto done;
+		}
+	}
 
-	return simple_read_from_buffer(buf, nbytes, ppos, ctr->buf, ctr->bufsz);
+	/*
+	 * binary search (upper-bound version):
+	 * find minimum index that cgrp->tasks_pids[index] > pid or
+	 * index = cgrp->pids_length
+	 */
+	end = cgrp->pids_length;
+	while (index < end) {
+		int mid = (index + end) / 2;
+		if (cgrp->tasks_pids[mid] <= pid)
+			index = mid + 1;
+		else
+			end = mid;
+	}
+
+	/* write pids to buf */
+	pid = cgrp->tasks_pids[cgrp->pids_length - 1];
+	unconsumed = 0;
+	while (index < cgrp->pids_length && total_count < nbytes) {
+		buf_count = 0;
+		while (index < cgrp->pids_length) {
+			int len = snprintf(pidbuf + buf_count,
+					PIDBUF_LEN - buf_count, "%d\n",
+					cgrp->tasks_pids[index]);
+			if ((buf_count + len) > PIDBUF_LEN)
+				break;
+			buf_count += len;
+			if (total_count + buf_count >= nbytes) {
+				pid = cgrp->tasks_pids[index];
+				unconsumed = total_count + buf_count - nbytes;
+				buf_count = nbytes - total_count;
+				break;
+			}
+			index++;
+		}
+		if (copy_to_user(buf + total_count, pidbuf, buf_count)) {
+			total_count = -EFAULT;
+			goto done;
+		}
+		total_count += buf_count;
+	}
+	ctr->last_pid = pid;
+	ctr->unconsumed = unconsumed;
+
+done:
+	up_read(&cgrp->pids_mutex);
+	return total_count;
 }
 
 static int cgroup_tasks_release(struct inode *unused_inode,
 					struct file *file)
 {
+	struct cgroup *cgrp = __d_cgrp(file->f_dentry->d_parent);
 	struct ctr_struct *ctr;
 
 	if (file->f_mode & FMODE_READ) {
+		down_write(&cgrp->pids_mutex);
+		if (!--cgrp->pids_use_count) {
+			kfree(cgrp->tasks_pids);
+			cgrp->tasks_pids = NULL;
+			cgrp->pids_length = 0;
+		}
+		up_write(&cgrp->pids_mutex);
+
 		ctr = file->private_data;
-		kfree(ctr->buf);
 		kfree(ctr);
 	}
 	return 0;
@@ -2304,6 +2361,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	INIT_LIST_HEAD(&cgrp->children);
 	INIT_LIST_HEAD(&cgrp->css_sets);
 	INIT_LIST_HEAD(&cgrp->release_list);
+	init_rwsem(&cgrp->pids_mutex);
 
 	cgrp->parent = parent;
 	cgrp->root = parent->root;
