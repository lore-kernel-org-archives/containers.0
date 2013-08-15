From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH cgroup/for-3.12 1/2] cgroup: fix subsystem file accesses on
	the root cgroup
Date: Thu, 15 Aug 2013 11:42:36 -0400
Message-ID: <20130815154236.GG14606@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From af8e64db96406f91746711260717c11584f90efd Mon Sep 17 00:00:00 2001
From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Thu, 15 Aug 2013 11:37:54 -0400

105347ba5 ("cgroup: make cgroup_file_open() rcu_read_lock() around
cgroup_css() and add cfent->css") added cfent->css to cache the
associted cgroup_subsys_state across file operations.

A cfent is associated with single css throughout its lifetime and the
origimal commit initialized the cache pointer during cgroup_add_file()
and verified that it matches the actual one in cgroup_file_open().
While this works fine for !root cgroups, it's broken for root cgroups
as files in a root cgroup are created before the css's are associated
with the cgroup and thus cgroup_css() call in cgroup_add_file()
returns NULL associating all cfents in the root cgroup with NULL css.
This makes cgroup_file_open() trigger WARN and fail with -ENODEV for
all !core subsystem files in the root cgroups.

There's no reason to initialize cfent->css separately from
cgroup_add_file().  As the association never changes,
cgroup_file_open() can set it unconditionally every time and
containing the logic in cgroup_file_open() makes more sense anyway as
the only reason it's necessary is file->private_data being already
occupied.

Fix it by setting cfent->css unconditionally from cgroup_file_open().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 66d0107..ab2a23f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2490,10 +2490,18 @@ static int cgroup_file_open(struct inode *inode, struct file *file)
 	}
 	rcu_read_unlock();
 
-	/* css should match @cfe->css, see cgroup_add_file() for details */
-	if (!css || WARN_ON_ONCE(css != cfe->css))
+	if (!css)
 		return -ENODEV;
 
+	/*
+	 * @cfe->css is used by read/write/close to determine the
+	 * associated css.  @file->private_data would be a better place but
+	 * that's already used by seqfile.  Multiple accessors may use it
+	 * simultaneously which is okay as the association never changes.
+	 */
+	WARN_ON_ONCE(cfe->css && cfe->css != css);
+	cfe->css = css;
+
 	if (cft->read_map || cft->read_seq_string) {
 		file->f_op = &cgroup_seqfile_operations;
 		err = single_open(file, cgroup_seqfile_show, cfe);
@@ -2772,18 +2780,6 @@ static int cgroup_add_file(struct cgroup *cgrp, struct cftype *cft)
 	dentry->d_fsdata = cfe;
 	simple_xattrs_init(&cfe->xattrs);
 
-	/*
-	 * cfe->css is used by read/write/close to determine the associated
-	 * css.  file->private_data would be a better place but that's
-	 * already used by seqfile.  Note that open will use the usual
-	 * cgroup_css() and css_tryget() to acquire the css and this
-	 * caching doesn't affect css lifetime management.
-	 */
-	if (cft->ss)
-		cfe->css = cgroup_css(cgrp, cft->ss->subsys_id);
-	else
-		cfe->css = &cgrp->dummy_css;
-
 	mode = cgroup_file_mode(cft);
 	error = cgroup_create_file(dentry, mode | S_IFREG, cgrp->root->sb);
 	if (!error) {
-- 
1.8.3.1
