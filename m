From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] procfs: change the owner of non-dumpable and writeable
	files
Date: Fri, 20 Jan 2017 14:57:31 +1300
Message-ID: <87r33yv6gk.fsf@xmission.com>
References: <20170118040159.4751-1-asarai@suse.de>
	<20170119092930.GJ30786@dhcp22.suse.cz>
	<e7137350-b8a8-c7e5-e35d-8218a7df1147@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <e7137350-b8a8-c7e5-e35d-8218a7df1147-l3A5Bk7waGM@public.gmane.org> (Aleksa Sarai's
	message of "Fri, 20 Jan 2017 00:08:12 +1100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, dev-IGmTWi+3HBZvNhPySn5qfx2eb7JE58TQ@public.gmane.org, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Janis Danisevskis <jdanis-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


The patch under discussion just appears wrong.  Part of what we are
detecting when we ask if a task is dumpable is if a process might have
under gone a security transition.  If a process has undergone a security
transition (calling setuid or the like) it is quite possible that
everyone with it's current effective credentials should not be able
to access that process.

Please verify but the ptrace issue that allowed processes in a container
to call setns on our processes should be fixed as of 4.10-rc1.  And the
change has been marked for backporting.

AKA it should be this fix that removes the need for your dumpable setting.
Fixes: bfedb589252c ("mm: Add a user_ns owner to mm_struct and fix ptrace permission checks")

Now with that said I believe we want to add the following change now
that dumpable is user namespace relative.  That will use not the
GLOBAL_ROOT_UID/GID but instead uid and gid 0 in the namespace
that dumpable is relative too.

But ugh!  Your case is even more confused that I had first noticed.
Saying that a processes is undumpable is completely unnecessary
when you are entering into a new fresh user namespace.  Touching
setgroups at any point where there are other processes in the namespace
makes no sense whatsoever.  Clearing dumpable is to help not leak things
into a container when you call setns on a user namespace.

So my general impression of your use case is don't do that, it isn't
necessary and it causes you problems.

At the same time here is what I am looking at to better set the uids and
gids of proc files.

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Date: Tue, 3 Jan 2017 10:23:11 +1300
Subject: [PATCH] proc: Better ownership of files for non-dumpable tasks in user namespaces

Instead of making the files owned by the GLOBAL_ROOT_USER.  Make
non-dumpable files whose mm has always lived in a user namespace owned
by the user namespace root.  This allows the container root to have
things work as expected in a container.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/base.c     | 88 +++++++++++++++++++++++++++++++-----------------------
 fs/proc/fd.c       | 12 +-------
 fs/proc/internal.h | 16 ++--------
 3 files changed, 53 insertions(+), 63 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 8e7e61b28f31..e96487af2307 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1667,12 +1667,55 @@ const struct inode_operations proc_pid_link_inode_operations = {
 
 /* building an inode */
 
+void task_dump_owner(struct task_struct *task, mode_t mode,
+		     kuid_t *ruid, kgid_t *rgid)
+{
+	/* Depending on the state of dumpable compute who should own a
+	 * proc file for a task.
+	 */
+	const struct cred *cred;
+	kuid_t uid;
+	kgid_t gid;
+
+	/* Default to the tasks effective ownership */
+	rcu_read_lock();
+	cred = __task_cred(task);
+	uid = cred->euid;
+	gid = cred->egid;
+	rcu_read_unlock();
+
+	if (mode != (S_IFDIR|S_IRUGO|S_IXUGO)) {
+		struct mm_struct *mm;
+		task_lock(task);
+		mm = task->mm;
+		/* Make non-dumpable tasks owned by some root */
+		if (mm) {
+			if (get_dumpable(mm) != SUID_DUMP_USER) {
+				struct user_namespace *user_ns = mm->user_ns;
+
+				uid = make_kuid(user_ns, 0);
+				if (!uid_valid(uid))
+					uid = GLOBAL_ROOT_UID;
+
+				gid = make_kgid(user_ns, 0);
+				if (!gid_valid(gid))
+					gid = GLOBAL_ROOT_GID;
+			}
+		} else {
+			uid = GLOBAL_ROOT_UID;
+			gid = GLOBAL_ROOT_GID;
+		}
+		task_unlock(task);
+	}
+	*ruid = uid;
+	*rgid = gid;
+}
+
 struct inode *proc_pid_make_inode(struct super_block * sb,
 				  struct task_struct *task, umode_t mode)
 {
 	struct inode * inode;
 	struct proc_inode *ei;
-	const struct cred *cred;
 
 	/* We need a new inode */
 
@@ -1694,13 +1737,7 @@ struct inode *proc_pid_make_inode(struct super_block * sb,
 	if (!ei->pid)
 		goto out_unlock;
 
-	if (task_dumpable(task)) {
-		rcu_read_lock();
-		cred = __task_cred(task);
-		inode->i_uid = cred->euid;
-		inode->i_gid = cred->egid;
-		rcu_read_unlock();
-	}
+	task_dump_owner(task, 0, &inode->i_uid, &inode->i_gid);
 	security_task_to_inode(task, inode);
 
 out:
@@ -1715,7 +1752,6 @@ int pid_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
 	struct inode *inode = d_inode(dentry);
 	struct task_struct *task;
-	const struct cred *cred;
 	struct pid_namespace *pid = dentry->d_sb->s_fs_info;
 
 	generic_fillattr(inode, stat);
@@ -1733,12 +1769,7 @@ int pid_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 			 */
 			return -ENOENT;
 		}
-		if ((inode->i_mode == (S_IFDIR|S_IRUGO|S_IXUGO)) ||
-		    task_dumpable(task)) {
-			cred = __task_cred(task);
-			stat->uid = cred->euid;
-			stat->gid = cred->egid;
-		}
+		task_dump_owner(task, inode->i_mode, &stat->uid, &stat->gid);
 	}
 	rcu_read_unlock();
 	return 0;
@@ -1765,7 +1796,6 @@ int pid_revalidate(struct dentry *dentry, unsigned int flags)
 {
 	struct inode *inode;
 	struct task_struct *task;
-	const struct cred *cred;
 
 	if (flags & LOOKUP_RCU)
 		return -ECHILD;
@@ -1774,17 +1804,8 @@ int pid_revalidate(struct dentry *dentry, unsigned int flags)
 	task = get_proc_task(inode);
 
 	if (task) {
-		if ((inode->i_mode == (S_IFDIR|S_IRUGO|S_IXUGO)) ||
-		    task_dumpable(task)) {
-			rcu_read_lock();
-			cred = __task_cred(task);
-			inode->i_uid = cred->euid;
-			inode->i_gid = cred->egid;
-			rcu_read_unlock();
-		} else {
-			inode->i_uid = GLOBAL_ROOT_UID;
-			inode->i_gid = GLOBAL_ROOT_GID;
-		}
+		task_dump_owner(task, inode->i_mode, &inode->i_uid, &inode->i_gid);
+
 		inode->i_mode &= ~(S_ISUID | S_ISGID);
 		security_task_to_inode(task, inode);
 		put_task_struct(task);
@@ -1881,7 +1902,6 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 	bool exact_vma_exists = false;
 	struct mm_struct *mm = NULL;
 	struct task_struct *task;
-	const struct cred *cred;
 	struct inode *inode;
 	int status = 0;
 
@@ -1906,16 +1926,8 @@ static int map_files_d_revalidate(struct dentry *dentry, unsigned int flags)
 	mmput(mm);
 
 	if (exact_vma_exists) {
-		if (task_dumpable(task)) {
-			rcu_read_lock();
-			cred = __task_cred(task);
-			inode->i_uid = cred->euid;
-			inode->i_gid = cred->egid;
-			rcu_read_unlock();
-		} else {
-			inode->i_uid = GLOBAL_ROOT_UID;
-			inode->i_gid = GLOBAL_ROOT_GID;
-		}
+		task_dump_owner(task, 0, &inode->i_uid, &inode->i_gid);
+
 		security_task_to_inode(task, inode);
 		status = 1;
 	}
diff --git a/fs/proc/fd.c b/fs/proc/fd.c
index 4274f83bf100..00ce1531b2f5 100644
--- a/fs/proc/fd.c
+++ b/fs/proc/fd.c
@@ -84,7 +84,6 @@ static int tid_fd_revalidate(struct dentry *dentry, unsigned int flags)
 {
 	struct files_struct *files;
 	struct task_struct *task;
-	const struct cred *cred;
 	struct inode *inode;
 	unsigned int fd;
 
@@ -108,16 +107,7 @@ static int tid_fd_revalidate(struct dentry *dentry, unsigned int flags)
 				rcu_read_unlock();
 				put_files_struct(files);
 
-				if (task_dumpable(task)) {
-					rcu_read_lock();
-					cred = __task_cred(task);
-					inode->i_uid = cred->euid;
-					inode->i_gid = cred->egid;
-					rcu_read_unlock();
-				} else {
-					inode->i_uid = GLOBAL_ROOT_UID;
-					inode->i_gid = GLOBAL_ROOT_GID;
-				}
+				task_dump_owner(task, 0, &inode->i_uid, &inode->i_gid);
 
 				if (S_ISLNK(inode->i_mode)) {
 					unsigned i_mode = S_IFLNK;
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 2de5194ba378..e2c3c461fa20 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -97,20 +97,8 @@ static inline struct task_struct *get_proc_task(struct inode *inode)
 	return get_pid_task(proc_pid(inode), PIDTYPE_PID);
 }
 
-static inline int task_dumpable(struct task_struct *task)
-{
-	int dumpable = 0;
-	struct mm_struct *mm;
-
-	task_lock(task);
-	mm = task->mm;
-	if (mm)
-		dumpable = get_dumpable(mm);
-	task_unlock(task);
-	if (dumpable == SUID_DUMP_USER)
-		return 1;
-	return 0;
-}
+void task_dump_owner(struct task_struct *task, mode_t mode,
+		     kuid_t *ruid, kgid_t *rgid);
 
 static inline unsigned name_to_int(const struct qstr *qstr)
 {
-- 
2.10.1

Eric
