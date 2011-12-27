From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: [PATCH 1/2] cgroup: mark cgroup_rmdir_waitq and cgroup_attach_proc()
	as static
Date: Tue, 27 Dec 2011 07:46:25 +0200
Message-ID: <1324964786-19052-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>

Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
---
 kernel/cgroup.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 4936d88..98990dd 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -938,7 +938,7 @@ static void cgroup_d_remove_dir(struct dentry *dentry)
  *
  * CGRP_WAIT_ON_RMDIR flag is set under cgroup's inode->i_mutex;
  */
-DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
+static DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
 
 static void cgroup_wakeup_rmdir_waiter(struct cgroup *cgrp)
 {
@@ -2070,7 +2070,7 @@ static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
  * Call holding cgroup_mutex and the group_rwsem of the leader. Will take
  * task_lock of each thread in leader's threadgroup individually in turn.
  */
-int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
+static int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 {
 	int retval, i, group_size, nr_migrating_tasks;
 	struct cgroup_subsys *ss, *failed_ss = NULL;
-- 
1.7.7.3
