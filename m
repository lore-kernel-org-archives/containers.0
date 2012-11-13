From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 14/17] cgroup: use mutex_trylock() when grabbing i_mutex of a
	new cgroup directory
Date: Mon, 12 Nov 2012 19:01:41 -0800
Message-ID: <1352775704-9023-15-git-send-email-tj__47719.6145490327$1352775818$gmane$org@kernel.org>
References: <1352775704-9023-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1352775704-9023-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

All cgroup directory i_mutexes nest outside cgroup_mutex; however, new
directory creation is a special case.  A new cgroup directory is
created while holding cgroup_mutex.  Populating the new directory
requires both the new directory's i_mutex and cgroup_mutex.  Because
all directory i_mutexes nest outside cgroup_mutex, grabbing both
requires releasing cgroup_mutex first, which isn't a good idea as the
new cgroup isn't yet ready to be manipulated by other cgroup
opreations.

This is worked around by grabbing the new directory's i_mutex while
holding cgroup_mutex before making it visible.  As there's no other
user at that point, grabbing the i_mutex under cgroup_mutex can't lead
to deadlock.

cgroup_create_file() was using I_MUTEX_CHILD to tell lockdep not to
worry about the reverse locking order; however, this creates pseudo
locking dependency cgroup_mutex -> I_MUTEX_CHILD, which isn't true -
all directory i_mutexes are still nested outside cgroup_mutex.  This
pseudo locking dependency can lead to spurious lockdep warnings.

Use mutex_trylock() instead.  This will always succeed and lockdep
doesn't create any locking dependency for it.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b42f63f..8ad5e76 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2657,9 +2657,15 @@ static int cgroup_create_file(struct dentry *dentry, umode_t mode,
 		inc_nlink(inode);
 		inc_nlink(dentry->d_parent->d_inode);
 
-		/* start with the directory inode held, so that we can
-		 * populate it without racing with another mkdir */
-		mutex_lock_nested(&inode->i_mutex, I_MUTEX_CHILD);
+		/*
+		 * Control reaches here with cgroup_mutex held.
+		 * @inode->i_mutex should nest outside cgroup_mutex but we
+		 * want to populate it immediately without releasing
+		 * cgroup_mutex.  As @inode isn't visible to anyone else
+		 * yet, trylock will always succeed without affecting
+		 * lockdep checks.
+		 */
+		WARN_ON_ONCE(!mutex_trylock(&inode->i_mutex));
 	} else if (S_ISREG(mode)) {
 		inode->i_size = 0;
 		inode->i_fop = &cgroup_file_operations;
-- 
1.7.11.7
