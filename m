From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/13] cgroup: introduce cgroup_ino()
Date: Tue, 28 Jan 2014 18:54:42 -0500
Message-ID: <1390953285-16360-11-git-send-email-tj@kernel.org>
References: <1390953285-16360-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390953285-16360-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

mm/memory-failure.c::hwpoison_filter_task() has been reaching into
cgroup to extract the associated ino to be used as a filtering
criterion.  This is an implementation detail which shouldn't be
depended upon from outside cgroup proper and is about to change with
the scheduled kernfs conversion.

This patch introduces a proper interface to determine the associated
ino, cgroup_ino(), and updates hwpoison_filter_task() to use it
instead of reaching directly into cgroup.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Cc: Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/linux/cgroup.h | 9 +++++++++
 kernel/cgroup.c        | 5 ++++-
 mm/memory-failure.c    | 8 ++------
 3 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 1e4f9e2..15b7839 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -505,6 +505,15 @@ static inline const char *cgroup_name(const struct cgroup *cgrp)
 	return rcu_dereference(cgrp->name)->name;
 }
 
+/* returns ino associated with a cgroup, 0 indicates unmounted root */
+static inline ino_t cgroup_ino(struct cgroup *cgrp)
+{
+	if (cgrp->dentry)
+		return cgrp->dentry->d_inode->i_ino;
+	else
+		return 0;
+}
+
 static inline struct cgroup_subsys_state *seq_css(struct seq_file *seq)
 {
 	struct cgroup_open_file *of = seq->private;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5c35f00..a8a1adc 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -792,7 +792,10 @@ static struct inode *cgroup_new_inode(umode_t mode, struct super_block *sb)
 	struct inode *inode = new_inode(sb);
 
 	if (inode) {
-		inode->i_ino = get_next_ino();
+		do {
+			/* ino 0 is reserved for dummy_root */
+			inode->i_ino = get_next_ino();
+		} while (!inode->i_ino);
 		inode->i_mode = mode;
 		inode->i_uid = current_fsuid();
 		inode->i_gid = current_fsgid();
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 4f08a2d..9b5933c 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -145,14 +145,10 @@ static int hwpoison_filter_task(struct page *p)
 		return -EINVAL;
 
 	css = mem_cgroup_css(mem);
-	/* root_mem_cgroup has NULL dentries */
-	if (!css->cgroup->dentry)
-		return -EINVAL;
-
-	ino = css->cgroup->dentry->d_inode->i_ino;
+	ino = cgroup_ino(css->cgroup);
 	css_put(css);
 
-	if (ino != hwpoison_filter_memcg)
+	if (!ino || ino != hwpoison_filter_memcg)
 		return -EINVAL;
 
 	return 0;
-- 
1.8.5.3
