From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/4] cgroup: move the one-off opts sanity check in
	cgroup_root_from_opts() to parse_cgroupfs_options()
Date: Tue, 28 Jan 2014 10:32:05 -0500
Message-ID: <1390923125-4369-5-git-send-email-tj@kernel.org>
References: <1390923125-4369-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390923125-4369-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

cgroup_root_from_opts() checks whether (!opts->subsys_mask &&
!opts->none) and returns NULL if so.  After that, if allocation fails,
returns ERR_PTR(-ENOMEM).  The caller, cgroup_mount(), doesn't treat
NULL as an error but set opts.new_root to NULL; however, later on,
cgroup_set_super() fails with -EINVAL if new_root is NULL.

This is one bizarre error handling sequence especially when all other
opts sanity checks including the very close (!opts->subsys_mask &&
!opts->name) check are done in parse_cgroupfs_options().

Let's move the one-off check in cgroup_root_from_opts() to
parse_cgroupfs_options() where it can be combined with the
(!opts->subsys_mask && !opts->name) check.  cgroup_root_from_opts() is
updated to return NULL on memory allocation failure.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 19 ++++++-------------
 1 file changed, 6 insertions(+), 13 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b0e030f..5c8fe40 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1265,10 +1265,10 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 		return -EINVAL;
 
 	/*
-	 * We either have to specify by name or by subsystems. (So all
-	 * empty hierarchies must have a name).
+	 * We either have to specify by name or by subsystems.  All empty
+	 * hierarchies must have a name and also "none" option specified.
 	 */
-	if (!opts->subsys_mask && !opts->name)
+	if (!opts->subsys_mask && (!opts->name || !opts->none))
 		return -EINVAL;
 
 	return 0;
@@ -1417,12 +1417,9 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
 {
 	struct cgroupfs_root *root;
 
-	if (!opts->subsys_mask && !opts->none)
-		return NULL;
-
 	root = kzalloc(sizeof(*root), GFP_KERNEL);
 	if (!root)
-		return ERR_PTR(-ENOMEM);
+		return NULL;
 
 	init_cgroup_root(root);
 
@@ -1461,10 +1458,6 @@ static int cgroup_set_super(struct super_block *sb, void *data)
 	int ret;
 	struct cgroup_sb_opts *opts = data;
 
-	/* If we don't have a new root, we can't set up a new sb */
-	if (!opts->new_root)
-		return -EINVAL;
-
 	BUG_ON(!opts->subsys_mask && !opts->none);
 
 	ret = set_anon_super(sb, NULL);
@@ -1532,8 +1525,8 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	 * reusing an existing hierarchy.
 	 */
 	new_root = cgroup_root_from_opts(&opts);
-	if (IS_ERR(new_root)) {
-		ret = PTR_ERR(new_root);
+	if (!new_root) {
+		ret = -ENOMEM;
 		goto out_err;
 	}
 	opts.new_root = new_root;
-- 
1.8.5.3
