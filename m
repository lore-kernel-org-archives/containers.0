From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 02/11] procfs: Don't cache a pid in the root inode.
Date: Fri, 16 Nov 2012 08:35:41 -0800
Message-ID: <1353083750-3621-2-git-send-email-ebiederm@xmission.com>
References: <8739097bkk.fsf@xmission.com>
	<1353083750-3621-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353083750-3621-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Now that we have s_fs_info pointing to our pid namespace
the original reason for the proc root inode having a struct
pid is gone.

Caching a pid in the root inode has led to some complicated
code.  Now that we don't need the struct pid, just remove it.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/proc/base.c |   11 +----------
 fs/proc/root.c |    8 --------
 2 files changed, 1 insertions(+), 18 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index cbe454e..6177fc2 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2714,19 +2714,12 @@ static int fake_filldir(void *buf, const char *name, int namelen,
 /* for the /proc/ directory itself, after non-process stuff has been done */
 int proc_pid_readdir(struct file * filp, void * dirent, filldir_t filldir)
 {
-	unsigned int nr;
-	struct task_struct *reaper;
 	struct tgid_iter iter;
 	struct pid_namespace *ns;
 	filldir_t __filldir;
 
 	if (filp->f_pos >= PID_MAX_LIMIT + TGID_OFFSET)
-		goto out_no_task;
-	nr = filp->f_pos - FIRST_PROCESS_ENTRY;
-
-	reaper = get_proc_task(filp->f_path.dentry->d_inode);
-	if (!reaper)
-		goto out_no_task;
+		goto out;
 
 	ns = filp->f_dentry->d_sb->s_fs_info;
 	iter.task = NULL;
@@ -2747,8 +2740,6 @@ int proc_pid_readdir(struct file * filp, void * dirent, filldir_t filldir)
 	}
 	filp->f_pos = PID_MAX_LIMIT + TGID_OFFSET;
 out:
-	put_task_struct(reaper);
-out_no_task:
 	return 0;
 }
 
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 5da9849..13ef624 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -100,7 +100,6 @@ static struct dentry *proc_mount(struct file_system_type *fs_type,
 	int err;
 	struct super_block *sb;
 	struct pid_namespace *ns;
-	struct proc_inode *ei;
 	char *options;
 
 	if (flags & MS_KERNMOUNT) {
@@ -130,13 +129,6 @@ static struct dentry *proc_mount(struct file_system_type *fs_type,
 		sb->s_flags |= MS_ACTIVE;
 	}
 
-	ei = PROC_I(sb->s_root->d_inode);
-	if (!ei->pid) {
-		rcu_read_lock();
-		ei->pid = get_pid(find_pid_ns(1, ns));
-		rcu_read_unlock();
-	}
-
 	return dget(sb->s_root);
 }
 
-- 
1.7.5.4
