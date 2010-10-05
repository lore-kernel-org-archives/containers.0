From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [RFC V1] Replace pid_t in autofs4 with struct pid reference.
Date: Tue,  5 Oct 2010 19:28:16 +0200
Message-ID: <1286299696-13955-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Helmut Lichtenberg <heli-dxCdbQ03lbiELgA04lAiVw@public.gmane.org>, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
List-Id: containers.vger.kernel.org

I resurect and refreshed this old patch from
https://lists.linux-foundation.org/pipermail/containers/2007-February/003726.html

This patch makes automount to work within a container.

Make autofs4 container-friendly by caching struct pid reference rather
than pid_t and using pid_nr() to retreive a task's pid_t.

ChangeLog:

V1:
	- fixed pgrp option in parse_options
	- used get_task_pid(current, PIDTYPE_PGID) instead of task_pgrp
	- fixed how is passed the 'pgrp' argument autofs4_fill_super
	- fixed bad pid conversion, was pid_vnr not pid_nr in autofs4_wait
V0:
	- Refreshed against linux-next (added dev-ioctl.c)
	- Fix Eric Biederman's comments - Use find_get_pid() to hold a
	  reference to oz_pgrp and release while unmounting; separate out
	  changes to autofs and autofs4.
	- Also rollback my earlier change to autofs_wait_queue (pid and tgid
	  in the wait queue are just used to write to a userspace daemon's
	  pipe).
        - Fix Cedric's comments: retain old prototype of parse_options()
          and move necessary change to its caller.

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Ian Kent <raven-PKsaG3nR2I+sTnJN9+BGXg@public.gmane.org>
Cc: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Helmut Lichtenberg <heli-dxCdbQ03lbiELgA04lAiVw@public.gmane.org>
---
 fs/autofs4/autofs_i.h  |   31 +++++++++++++++++--------------
 fs/autofs4/dev-ioctl.c |   32 +++++++++++++++++++-------------
 fs/autofs4/inode.c     |   35 +++++++++++++++++++++++++----------
 fs/autofs4/root.c      |    3 ++-
 fs/autofs4/waitq.c     |    4 ++--
 5 files changed, 65 insertions(+), 40 deletions(-)

diff --git a/fs/autofs4/autofs_i.h b/fs/autofs4/autofs_i.h
index 3d283ab..bf2f9b1 100644
--- a/fs/autofs4/autofs_i.h
+++ b/fs/autofs4/autofs_i.h
@@ -39,25 +39,25 @@
 /* #define DEBUG */
 
 #ifdef DEBUG
-#define DPRINTK(fmt, args...)				\
-do {							\
-	printk(KERN_DEBUG "pid %d: %s: " fmt "\n",	\
-		current->pid, __func__, ##args);	\
+#define DPRINTK(fmt, args...)				     \
+do {							     \
+	printk(KERN_DEBUG "pid %d: %s: " fmt "\n",	     \
+	       pid_nr(task_pid(current)), __func__, ##args); \
 } while (0)
 #else
 #define DPRINTK(fmt, args...) do {} while (0)
 #endif
 
-#define AUTOFS_WARN(fmt, args...)			\
-do {							\
-	printk(KERN_WARNING "pid %d: %s: " fmt "\n",	\
-		current->pid, __func__, ##args);	\
+#define AUTOFS_WARN(fmt, args...)			     \
+do {							     \
+	printk(KERN_WARNING "pid %d: %s: " fmt "\n",	     \
+	       pid_nr(task_pid(current)), __func__, ##args); \
 } while (0)
 
-#define AUTOFS_ERROR(fmt, args...)			\
-do {							\
-	printk(KERN_ERR "pid %d: %s: " fmt "\n",	\
-		current->pid, __func__, ##args);	\
+#define AUTOFS_ERROR(fmt, args...)			     \
+do {						             \
+	printk(KERN_ERR "pid %d: %s: " fmt "\n",	     \
+	       pid_nr(task_pid(current)), __func__, ##args); \
 } while (0)
 
 /* Unified info structure.  This is pointed to by both the dentry and
@@ -122,7 +122,7 @@ struct autofs_sb_info {
 	u32 magic;
 	int pipefd;
 	struct file *pipe;
-	pid_t oz_pgrp;
+	struct pid *oz_pgrp;
 	int catatonic;
 	int version;
 	int sub_version;
@@ -156,7 +156,10 @@ static inline struct autofs_info *autofs4_dentry_ino(struct dentry *dentry)
    filesystem without "magic".) */
 
 static inline int autofs4_oz_mode(struct autofs_sb_info *sbi) {
-	return sbi->catatonic || task_pgrp_nr(current) == sbi->oz_pgrp;
+	struct pid *pgrp = get_task_pid(current, PIDTYPE_PGID);
+	bool oz_mode = sbi->catatonic || sbi->oz_pgrp == pgrp;
+	put_pid(pgrp);
+	return oz_mode;
 }
 
 /* Does a dentry have some pending activity? */
diff --git a/fs/autofs4/dev-ioctl.c b/fs/autofs4/dev-ioctl.c
index eff9a41..7db3b73 100644
--- a/fs/autofs4/dev-ioctl.c
+++ b/fs/autofs4/dev-ioctl.c
@@ -360,6 +360,7 @@ static int autofs_dev_ioctl_setpipefd(struct file *fp,
 {
 	int pipefd;
 	int err = 0;
+	struct file *pipe;
 
 	if (param->setpipefd.pipefd == -1)
 		return -EINVAL;
@@ -368,22 +369,27 @@ static int autofs_dev_ioctl_setpipefd(struct file *fp,
 
 	mutex_lock(&sbi->wq_mutex);
 	if (!sbi->catatonic) {
-		mutex_unlock(&sbi->wq_mutex);
-		return -EBUSY;
-	} else {
-		struct file *pipe = fget(pipefd);
-		if (!pipe->f_op || !pipe->f_op->write) {
-			err = -EPIPE;
-			fput(pipe);
-			goto out;
-		}
-		sbi->oz_pgrp = task_pgrp_nr(current);
-		sbi->pipefd = pipefd;
-		sbi->pipe = pipe;
-		sbi->catatonic = 0;
+		err = -EBUSY;
+		goto out;
+	}
+
+	pipe = fget(pipefd);
+	if (!pipe->f_op || !pipe->f_op->write) {
+		err = -EPIPE;
+		fput(pipe);
+		goto out;
 	}
+
+	sbi->pipefd = pipefd;
+	sbi->pipe = pipe;
+	sbi->catatonic = 0;
 out:
 	mutex_unlock(&sbi->wq_mutex);
+	if (!err) {
+		put_pid(sbi->oz_pgrp);
+		sbi->oz_pgrp = get_task_pid(current, PIDTYPE_PGID);
+	}
+
 	return err;
 }
 
diff --git a/fs/autofs4/inode.c b/fs/autofs4/inode.c
index 821b2b9..01d1515 100644
--- a/fs/autofs4/inode.c
+++ b/fs/autofs4/inode.c
@@ -112,6 +112,7 @@ void autofs4_kill_sb(struct super_block *sb)
 	/* Free wait queues, close pipe */
 	autofs4_catatonic_mode(sbi);
 
+	put_pid(sbi->oz_pgrp);
 	sb->s_fs_info = NULL;
 	kfree(sbi);
 
@@ -133,7 +134,7 @@ static int autofs4_show_options(struct seq_file *m, struct vfsmount *mnt)
 		seq_printf(m, ",uid=%u", root_inode->i_uid);
 	if (root_inode->i_gid != 0)
 		seq_printf(m, ",gid=%u", root_inode->i_gid);
-	seq_printf(m, ",pgrp=%d", sbi->oz_pgrp);
+	seq_printf(m, ",pgrp=%d", pid_vnr(sbi->oz_pgrp));
 	seq_printf(m, ",timeout=%lu", sbi->exp_timeout/HZ);
 	seq_printf(m, ",minproto=%d", sbi->min_proto);
 	seq_printf(m, ",maxproto=%d", sbi->max_proto);
@@ -170,15 +171,16 @@ static const match_table_t tokens = {
 };
 
 static int parse_options(char *options, int *pipefd, uid_t *uid, gid_t *gid,
-		pid_t *pgrp, unsigned int *type, int *minproto, int *maxproto)
+			 struct pid **oz_pgrp, unsigned int *type,
+			 int *minproto, int *maxproto)
 {
 	char *p;
 	substring_t args[MAX_OPT_ARGS];
+	struct pid *pgrp;
 	int option;
 
 	*uid = current_uid();
 	*gid = current_gid();
-	*pgrp = task_pgrp_nr(current);
 
 	*minproto = AUTOFS_MIN_PROTO_VERSION;
 	*maxproto = AUTOFS_MAX_PROTO_VERSION;
@@ -212,7 +214,17 @@ static int parse_options(char *options, int *pipefd, uid_t *uid, gid_t *gid,
 		case Opt_pgrp:
 			if (match_int(args, &option))
 				return 1;
-			*pgrp = option;
+
+			rcu_read_lock();
+			pgrp = find_vpid(option);
+			if (pgrp) {
+				put_pid(*oz_pgrp);
+				*oz_pgrp = get_pid(pgrp);
+			}
+			rcu_read_unlock();
+
+			if (!pgrp)
+				return 1;
 			break;
 		case Opt_minproto:
 			if (match_int(args, &option))
@@ -275,7 +287,7 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
 	sbi->pipe = NULL;
 	sbi->catatonic = 1;
 	sbi->exp_timeout = 0;
-	sbi->oz_pgrp = task_pgrp_nr(current);
+	sbi->oz_pgrp = get_task_pid(current, PIDTYPE_PGID);
 	sbi->sb = s;
 	sbi->version = 0;
 	sbi->sub_version = 0;
@@ -299,7 +311,8 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
 	 */
 	ino = autofs4_mkroot(sbi);
 	if (!ino)
-		goto fail_free;
+		goto fail_put_pid;
+
 	root_inode = autofs4_get_inode(s, ino);
 	if (!root_inode)
 		goto fail_ino;
@@ -342,9 +355,9 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
 		sbi->version = sbi->max_proto;
 	sbi->sub_version = AUTOFS_PROTO_SUBVERSION;
 
-	DPRINTK("pipe fd = %d, pgrp = %u", pipefd, sbi->oz_pgrp);
+	DPRINTK("pipe fd = %d, pgrp = %u", pipefd, pid_nr(sbi->oz_pgrp));
+
 	pipe = fget(pipefd);
-	
 	if (!pipe) {
 		printk("autofs: could not open pipe file descriptor\n");
 		goto fail_dput;
@@ -370,13 +383,15 @@ fail_fput:
 	/* fall through */
 fail_dput:
 	dput(root);
-	goto fail_free;
+	goto fail_put_pid;
 fail_iput:
 	printk("autofs: get root dentry failed\n");
 	iput(root_inode);
 fail_ino:
 	kfree(ino);
-fail_free:
+fail_put_pid:
+	put_pid(sbi->oz_pgrp);
+
 	kfree(sbi);
 	s->s_fs_info = NULL;
 fail_unlock:
diff --git a/fs/autofs4/root.c b/fs/autofs4/root.c
index d5c1401..45c6bc2 100644
--- a/fs/autofs4/root.c
+++ b/fs/autofs4/root.c
@@ -541,7 +541,8 @@ static struct dentry *autofs4_lookup(struct inode *dir, struct dentry *dentry, s
 	oz_mode = autofs4_oz_mode(sbi);
 
 	DPRINTK("pid = %u, pgrp = %u, catatonic = %d, oz_mode = %d",
-		 current->pid, task_pgrp_nr(current), sbi->catatonic, oz_mode);
+		pid_nr(task_pid(current)), task_pgrp_nr(current),
+		sbi->catatonic, oz_mode);
 
 	active = autofs4_lookup_active(dentry);
 	if (active) {
diff --git a/fs/autofs4/waitq.c b/fs/autofs4/waitq.c
index 2341375..e3ce7fe 100644
--- a/fs/autofs4/waitq.c
+++ b/fs/autofs4/waitq.c
@@ -387,8 +387,8 @@ int autofs4_wait(struct autofs_sb_info *sbi, struct dentry *dentry,
 		wq->ino = autofs4_get_ino(sbi);
 		wq->uid = current_uid();
 		wq->gid = current_gid();
-		wq->pid = current->pid;
-		wq->tgid = current->tgid;
+		wq->pid = pid_vnr(task_pid(current));
+		wq->tgid = pid_vnr(task_tgid(current));
 		wq->status = -EINTR; /* Status return if interrupted */
 		wq->wait_ctr = 2;
 		mutex_unlock(&sbi->wq_mutex);
-- 
1.7.0.4
