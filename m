From: Waiman Long <Waiman.Long-VXdhtT5mjnY@public.gmane.org>
Subject: [PATCH v3 23/25] cgroup: Change how dentry's d_lock field is accessed
Date: Wed,  3 Jul 2013 16:22:06 -0400
Message-ID: <1372882926-23239-1-git-send-email-Waiman.Long@hp.com>
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
To: Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Miklos Szeredi <mszeredi-AlSwsSmVLrQ@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Cc: Waiman Long <Waiman.Long-VXdhtT5mjnY@public.gmane.org>, Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>, Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, "Chandramouleeswaran,
	Aswin" <aswin-VXdhtT5mjnY@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Norton,
	Scott J" <scott.norton-VXdhtT5mjnY@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Because of the changes made in dcache.h header file, files that
use the d_lock field of the dentry structure need to be changed
accordingly. All the d_lock's spin_lock() and spin_unlock() calls
are replaced by the corresponding d_lock() and d_unlock() calls.
There is no change in logic and everything should just work.

Signed-off-by: Waiman Long <Waiman.Long-VXdhtT5mjnY@public.gmane.org>
---
 kernel/cgroup.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a7c9e6d..8935c05 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -974,11 +974,11 @@ static void cgroup_d_remove_dir(struct dentry *dentry)
 	cgroup_clear_directory(dentry, true, root->subsys_mask);
 
 	parent = dentry->d_parent;
-	spin_lock(&parent->d_lock);
-	spin_lock_nested(&dentry->d_lock, DENTRY_D_LOCK_NESTED);
+	d_lock(parent);
+	d_lock_nested(dentry, DENTRY_D_LOCK_NESTED);
 	list_del_init(&dentry->d_u.d_child);
-	spin_unlock(&dentry->d_lock);
-	spin_unlock(&parent->d_lock);
+	d_unlock(dentry);
+	d_unlock(parent);
 	remove_dir(dentry);
 }
 
@@ -1783,7 +1783,7 @@ static struct kobject *cgroup_kobj;
  * Writes path of cgroup into buf.  Returns 0 on success, -errno on error.
  *
  * We can't generate cgroup path using dentry->d_name, as accessing
- * dentry->name must be protected by irq-unsafe dentry->d_lock or parent
+ * dentry->name must be protected by irq-unsafe d_ret_lock(dentry) or parent
  * inode's i_mutex, while on the other hand cgroup_path() can be called
  * with some irq-safe spinlocks held.
  */
-- 
1.7.1
