From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/9] cgroup: don't skip seq_open on write only opens on
	pidlist files
Date: Sun, 24 Nov 2013 17:11:28 -0500
Message-ID: <1385331096-7918-2-git-send-email-tj__881.345794960175$1385331118$gmane$org@kernel.org>
References: <1385331096-7918-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1385331096-7918-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, cgroup_pidlist_open() skips seq_open() and pidlist loading
if the file is opened write-only, which is a sensible optimization as
pidlist loading can be costly and there often are occasions where
tasks or cgroup.procs is opened write-only.  However, pidlist init and
release are planned to be moved to cgroup_pidlist_start/stop()
respectively which would make this optimization unnecessary.

This patch removes the optimization and always fully initializes
pidlist files regardless of open mode.  This will help moving pidlist
handling to start/stop by unifying rw paths and removes the need for
specifying cftype->release() in addition to .release in
cgroup_pidlist_operations as file->f_op is now always overridden.  As
pidlist files were the only user of cftype->release(), the next patch
will remove the method.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index be42967..61a5e2e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -3778,12 +3778,7 @@ static void cgroup_release_pid_array(struct cgroup_pidlist *l)
 static int cgroup_pidlist_release(struct inode *inode, struct file *file)
 {
 	struct cgroup_pidlist *l;
-	if (!(file->f_mode & FMODE_READ))
-		return 0;
-	/*
-	 * the seq_file will only be initialized if the file was opened for
-	 * reading; hence we check if it's not null only in that case.
-	 */
+
 	l = ((struct seq_file *)file->private_data)->private;
 	cgroup_release_pid_array(l);
 	return seq_release(inode, file);
@@ -3808,10 +3803,6 @@ static int cgroup_pidlist_open(struct file *file, enum cgroup_filetype type)
 	struct cgroup_pidlist *l;
 	int retval;
 
-	/* Nothing to do for write-only files */
-	if (!(file->f_mode & FMODE_READ))
-		return 0;
-
 	/* have the array populated */
 	retval = pidlist_array_load(cgrp, type, &l);
 	if (retval)
@@ -3891,7 +3882,6 @@ static struct cftype cgroup_base_files[] = {
 		.name = "cgroup.procs",
 		.open = cgroup_procs_open,
 		.write_u64 = cgroup_procs_write,
-		.release = cgroup_pidlist_release,
 		.mode = S_IRUGO | S_IWUSR,
 	},
 	{
@@ -3916,7 +3906,6 @@ static struct cftype cgroup_base_files[] = {
 		.flags = CFTYPE_INSANE,		/* use "procs" instead */
 		.open = cgroup_tasks_open,
 		.write_u64 = cgroup_tasks_write,
-		.release = cgroup_pidlist_release,
 		.mode = S_IRUGO | S_IWUSR,
 	},
 	{
-- 
1.8.4.2
