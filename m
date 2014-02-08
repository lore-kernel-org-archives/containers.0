From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/13] cgroup: update the meaning of cftype->max_write_len
Date: Sat,  8 Feb 2014 11:15:22 -0500
Message-ID: <1391876127-7134-9-git-send-email-tj__36584.6458393664$1391876218$gmane$org@kernel.org>
References: <1391876127-7134-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391876127-7134-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cftype->max_write_len is used to extend the maximum size of writes.
It's interpreted in such a way that the actual maximum size is one
less than the specified value.  The default size is defined by
CGROUP_LOCAL_BUFFER_SIZE.  Its interpretation is quite confusing - its
value is decremented by 1 and then compared for equality with max
size, which means that the actual default size is
CGROUP_LOCAL_BUFFER_SIZE - 2, which is 62 chars.

There's no point in having a limit that low.  Update its definition so
that it means the actual string length sans termination and anything
below PAGE_SIZE-1 is treated as PAGE_SIZE-1.

.max_write_len for "release_agent" is updated to PATH_MAX-1 and
cgroup_release_agent_write() is updated so that the redundant strlen()
check is removed and it uses strlcpy() instead of strcpy().
.max_write_len initializations in blk-throttle.c and cfq-iosched.c are
no longer necessary and removed.  The one in cpuset is kept unchanged
as it's an approximated value to begin with.

This will also make transition to kernfs smoother.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 block/blk-throttle.c   |  4 ----
 block/cfq-iosched.c    |  3 ---
 include/linux/cgroup.h |  5 +++--
 kernel/cgroup.c        | 18 ++++++++----------
 4 files changed, 11 insertions(+), 19 deletions(-)

diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index 1474c3a..861c363 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -1425,28 +1425,24 @@ static struct cftype throtl_files[] = {
 		.private = offsetof(struct throtl_grp, bps[READ]),
 		.seq_show = tg_print_conf_u64,
 		.write_string = tg_set_conf_u64,
-		.max_write_len = 256,
 	},
 	{
 		.name = "throttle.write_bps_device",
 		.private = offsetof(struct throtl_grp, bps[WRITE]),
 		.seq_show = tg_print_conf_u64,
 		.write_string = tg_set_conf_u64,
-		.max_write_len = 256,
 	},
 	{
 		.name = "throttle.read_iops_device",
 		.private = offsetof(struct throtl_grp, iops[READ]),
 		.seq_show = tg_print_conf_uint,
 		.write_string = tg_set_conf_uint,
-		.max_write_len = 256,
 	},
 	{
 		.name = "throttle.write_iops_device",
 		.private = offsetof(struct throtl_grp, iops[WRITE]),
 		.seq_show = tg_print_conf_uint,
 		.write_string = tg_set_conf_uint,
-		.max_write_len = 256,
 	},
 	{
 		.name = "throttle.io_service_bytes",
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 744833b..4611879 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1838,7 +1838,6 @@ static struct cftype cfq_blkcg_files[] = {
 		.flags = CFTYPE_ONLY_ON_ROOT,
 		.seq_show = cfqg_print_leaf_weight_device,
 		.write_string = cfqg_set_leaf_weight_device,
-		.max_write_len = 256,
 	},
 	{
 		.name = "weight",
@@ -1853,7 +1852,6 @@ static struct cftype cfq_blkcg_files[] = {
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.seq_show = cfqg_print_weight_device,
 		.write_string = cfqg_set_weight_device,
-		.max_write_len = 256,
 	},
 	{
 		.name = "weight",
@@ -1866,7 +1864,6 @@ static struct cftype cfq_blkcg_files[] = {
 		.name = "leaf_weight_device",
 		.seq_show = cfqg_print_leaf_weight_device,
 		.write_string = cfqg_set_leaf_weight_device,
-		.max_write_len = 256,
 	},
 	{
 		.name = "leaf_weight",
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 884d367..1e4f9e2 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -398,8 +398,9 @@ struct cftype {
 	umode_t mode;
 
 	/*
-	 * If non-zero, defines the maximum length of string that can
-	 * be passed to write_string; defaults to 64
+	 * The maximum length of string, excluding trailing nul, that can
+	 * be passed to write_string.  If < PAGE_SIZE-1, PAGE_SIZE-1 is
+	 * assumed.
 	 */
 	size_t max_write_len;
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5935c2f..1534542 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2211,13 +2211,14 @@ static int cgroup_procs_write(struct cgroup_subsys_state *css,
 static int cgroup_release_agent_write(struct cgroup_subsys_state *css,
 				      struct cftype *cft, const char *buffer)
 {
-	BUILD_BUG_ON(sizeof(css->cgroup->root->release_agent_path) < PATH_MAX);
-	if (strlen(buffer) >= PATH_MAX)
-		return -EINVAL;
+	struct cgroupfs_root *root = css->cgroup->root;
+
+	BUILD_BUG_ON(sizeof(root->release_agent_path) < PATH_MAX);
 	if (!cgroup_lock_live_group(css->cgroup))
 		return -ENODEV;
 	spin_lock(&release_agent_path_lock);
-	strcpy(css->cgroup->root->release_agent_path, buffer);
+	strlcpy(root->release_agent_path, buffer,
+		sizeof(root->release_agent_path));
 	spin_unlock(&release_agent_path_lock);
 	mutex_unlock(&cgroup_mutex);
 	return 0;
@@ -2243,20 +2244,17 @@ static int cgroup_sane_behavior_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-/* A buffer size big enough for numbers or short strings */
-#define CGROUP_LOCAL_BUFFER_SIZE 64
-
 static ssize_t cgroup_file_write(struct file *file, const char __user *userbuf,
 				 size_t nbytes, loff_t *ppos)
 {
 	struct cfent *cfe = __d_cfe(file->f_dentry);
 	struct cftype *cft = __d_cft(file->f_dentry);
 	struct cgroup_subsys_state *css = cfe->css;
-	size_t max_bytes = cft->max_write_len ?: CGROUP_LOCAL_BUFFER_SIZE - 1;
+	size_t max_bytes = max(cft->max_write_len, PAGE_SIZE);
 	char *buf;
 	int ret;
 
-	if (nbytes >= max_bytes)
+	if (nbytes > max_bytes)
 		return -E2BIG;
 
 	buf = kmalloc(nbytes + 1, GFP_KERNEL);
@@ -3917,7 +3915,7 @@ static struct cftype cgroup_base_files[] = {
 		.flags = CFTYPE_INSANE | CFTYPE_ONLY_ON_ROOT,
 		.seq_show = cgroup_release_agent_show,
 		.write_string = cgroup_release_agent_write,
-		.max_write_len = PATH_MAX,
+		.max_write_len = PATH_MAX - 1,
 	},
 	{ }	/* terminate */
 };
-- 
1.8.5.3
