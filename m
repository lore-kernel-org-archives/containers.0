From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 12/12] cgroup: unexport cgroup_css() and remove __file_cft()
Date: Thu, 15 Aug 2013 12:02:30 -0400
Message-ID: <1376582550-12548-13-git-send-email-tj__781.621333635662$1376582671$gmane$org@kernel.org>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1376582550-12548-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Now that cgroup_event is made memcg specific, the temporarily exported
functions are no longer necessary.  Unexport cgroup_css() and remove
__file_cft() which doesn't have any user left.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  5 -----
 kernel/cgroup.c        | 14 ++------------
 2 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index d2cad3f..f9a4194 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -899,11 +899,6 @@ unsigned short css_id(struct cgroup_subsys_state *css);
 struct cgroup_subsys_state *css_from_dir(struct dentry *dentry,
 					 struct cgroup_subsys *ss);
 
-/* XXX: temporary */
-struct cgroup_subsys_state *cgroup_css(struct cgroup *cgrp,
-				       struct cgroup_subsys *ss);
-struct cftype *__file_cft(struct file *file);
-
 #else /* !CONFIG_CGROUPS */
 
 static inline int cgroup_init_early(void) { return 0; }
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 4368a6c..1402366 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -202,8 +202,8 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
  * keep accessing it outside the said locks.  This function may return
  * %NULL if @cgrp doesn't have @subsys_id enabled.
  */
-struct cgroup_subsys_state *cgroup_css(struct cgroup *cgrp,
-				       struct cgroup_subsys *ss)
+static struct cgroup_subsys_state *cgroup_css(struct cgroup *cgrp,
+					      struct cgroup_subsys *ss)
 {
 	if (ss)
 		return rcu_dereference_check(cgrp->subsys[ss->subsys_id],
@@ -2634,16 +2634,6 @@ static struct dentry *cgroup_lookup(struct inode *dir, struct dentry *dentry, un
 	return NULL;
 }
 
-/*
- * Check if a file is a control file
- */
-struct cftype *__file_cft(struct file *file)
-{
-	if (file_inode(file)->i_fop != &cgroup_file_operations)
-		return ERR_PTR(-EINVAL);
-	return __d_cft(file->f_dentry);
-}
-
 static int cgroup_create_file(struct dentry *dentry, umode_t mode,
 				struct super_block *sb)
 {
-- 
1.8.3.1
