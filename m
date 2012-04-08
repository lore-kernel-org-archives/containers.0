From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 38/43] userns: Convert proc to use kuid/kgid where appropriate
Date: Sat,  7 Apr 2012 22:15:34 -0700
Message-ID: <1333862139-31737-38-git-send-email-ebiederm__3606.59134244106$1333862167$gmane$org@xmission.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11unyn70b.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/array.c               |   10 ++++++++--
 fs/proc/base.c                |   16 ++++++++--------
 fs/proc/inode.c               |    4 ++--
 fs/proc/root.c                |    2 +-
 include/linux/pid_namespace.h |    2 +-
 include/linux/proc_fs.h       |    4 ++--
 6 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index 36a0a91..dc4c5a7 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -191,8 +191,14 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 		task_tgid_nr_ns(p, ns),
 		pid_nr_ns(pid, ns),
 		ppid, tpid,
-		cred->uid, cred->euid, cred->suid, cred->fsuid,
-		cred->gid, cred->egid, cred->sgid, cred->fsgid);
+		from_kuid_munged(user_ns, cred->uid),
+		from_kuid_munged(user_ns, cred->euid),
+		from_kuid_munged(user_ns, cred->suid),
+		from_kuid_munged(user_ns, cred->fsuid),
+		from_kgid_munged(user_ns, cred->gid),
+		from_kgid_munged(user_ns, cred->egid),
+		from_kgid_munged(user_ns, cred->sgid),
+		from_kgid_munged(user_ns, cred->fsgid));
 
 	task_lock(p);
 	if (p->files)
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 2ee514c..c479049 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1562,8 +1562,8 @@ int pid_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 	generic_fillattr(inode, stat);
 
 	rcu_read_lock();
-	stat->uid = 0;
-	stat->gid = 0;
+	stat->uid = GLOBAL_ROOT_UID;
+	stat->gid = GLOBAL_ROOT_GID;
 	task = pid_task(proc_pid(inode), PIDTYPE_PID);
 	if (task) {
 		if (!has_pid_permissions(pid, task, 2)) {
@@ -1623,8 +1623,8 @@ int pid_revalidate(struct dentry *dentry, struct nameidata *nd)
 			inode->i_gid = cred->egid;
 			rcu_read_unlock();
 		} else {
-			inode->i_uid = 0;
-			inode->i_gid = 0;
+			inode->i_uid = GLOBAL_ROOT_UID;
+			inode->i_gid = GLOBAL_ROOT_GID;
 		}
 		inode->i_mode &= ~(S_ISUID | S_ISGID);
 		security_task_to_inode(task, inode);
@@ -1811,8 +1811,8 @@ static int tid_fd_revalidate(struct dentry *dentry, struct nameidata *nd)
 					inode->i_gid = cred->egid;
 					rcu_read_unlock();
 				} else {
-					inode->i_uid = 0;
-					inode->i_gid = 0;
+					inode->i_uid = GLOBAL_ROOT_UID;
+					inode->i_gid = GLOBAL_ROOT_GID;
 				}
 				inode->i_mode &= ~(S_ISUID | S_ISGID);
 				security_task_to_inode(task, inode);
@@ -2061,8 +2061,8 @@ static int map_files_d_revalidate(struct dentry *dentry, struct nameidata *nd)
 			inode->i_gid = cred->egid;
 			rcu_read_unlock();
 		} else {
-			inode->i_uid = 0;
-			inode->i_gid = 0;
+			inode->i_uid = GLOBAL_ROOT_UID;
+			inode->i_gid = GLOBAL_ROOT_GID;
 		}
 		security_task_to_inode(task, inode);
 		status = 1;
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 205c922..554ecc5 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -108,8 +108,8 @@ static int proc_show_options(struct seq_file *seq, struct dentry *root)
 	struct super_block *sb = root->d_sb;
 	struct pid_namespace *pid = sb->s_fs_info;
 
-	if (pid->pid_gid)
-		seq_printf(seq, ",gid=%lu", (unsigned long)pid->pid_gid);
+	if (!gid_eq(pid->pid_gid, GLOBAL_ROOT_GID))
+		seq_printf(seq, ",gid=%u", from_kgid_munged(&init_user_ns, pid->pid_gid));
 	if (pid->hide_pid != 0)
 		seq_printf(seq, ",hidepid=%u", pid->hide_pid);
 
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 46a15d8..df4e456 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -67,7 +67,7 @@ static int proc_parse_options(char *options, struct pid_namespace *pid)
 		case Opt_gid:
 			if (match_int(&args[0], &option))
 				return 0;
-			pid->pid_gid = option;
+			pid->pid_gid = make_kgid(current_user_ns(), option);
 			break;
 		case Opt_hidepid:
 			if (match_int(&args[0], &option))
diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
index b067bd8..00474b0 100644
--- a/include/linux/pid_namespace.h
+++ b/include/linux/pid_namespace.h
@@ -31,7 +31,7 @@ struct pid_namespace {
 #ifdef CONFIG_BSD_PROCESS_ACCT
 	struct bsd_acct_struct *bacct;
 #endif
-	gid_t pid_gid;
+	kgid_t pid_gid;
 	int hide_pid;
 	int reboot;	/* group exit code if this pidns was rebooted */
 };
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 85c5073..3fd2e87 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -52,8 +52,8 @@ struct proc_dir_entry {
 	unsigned int low_ino;
 	umode_t mode;
 	nlink_t nlink;
-	uid_t uid;
-	gid_t gid;
+	kuid_t uid;
+	kgid_t gid;
 	loff_t size;
 	const struct inode_operations *proc_iops;
 	/*
-- 
1.7.2.5
