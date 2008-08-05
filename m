From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [RFC][PATCH 3/6] Move 'allocated_ptys' to sb->s_s_fs_info
Date: Mon, 4 Aug 2008 18:23:27 -0700
Message-ID: <20080805012327.GC15360@us.ibm.com>
References: <20080805011844.GA14940@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080805011844.GA14940-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org
Cc: "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC][PATCH 3/6] Move 'allocated_ptys' to sb->s_s_fs_info

To enable multiple mounts of devpts, 'allocated_ptys' must be a per-mount
variable rather than a global variable.  This patch moves 'allocated_ptys'
into the super_block's s_fs_info.

---
 fs/devpts/inode.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 46 insertions(+), 7 deletions(-)

Index: linux-2.6.26-rc8-mm1/fs/devpts/inode.c
===================================================================
--- linux-2.6.26-rc8-mm1.orig/fs/devpts/inode.c	2008-08-04 02:08:43.000000000 -0700
+++ linux-2.6.26-rc8-mm1/fs/devpts/inode.c	2008-08-04 02:08:50.000000000 -0700
@@ -28,8 +28,11 @@
 
 #define DEVPTS_DEFAULT_MODE 0600
 
+struct pts_fs_info {
+	struct idr allocated_ptys;
+};
+
 extern int pty_limit;			/* Config limit on Unix98 ptys */
-static DEFINE_IDR(allocated_ptys);
 static DEFINE_MUTEX(allocated_ptys_lock);
 
 static struct vfsmount *devpts_mnt;
@@ -125,6 +128,19 @@ static const struct super_operations dev
 	.show_options	= devpts_show_options,
 };
 
+static void *new_pts_fs_info(void)
+{
+	struct pts_fs_info *fsi;
+
+	fsi = kmalloc(sizeof(struct pts_fs_info), GFP_KERNEL);
+	if (fsi) {
+		idr_init(&fsi->allocated_ptys);
+	}
+	printk(KERN_ERR "new_pts_fs_info(): Returning fsi %p\n", fsi);
+	return fsi;
+}
+
+
 static int
 devpts_fill_super(struct super_block *s, void *data, int silent)
 {
@@ -135,10 +151,14 @@ devpts_fill_super(struct super_block *s,
 	s->s_magic = DEVPTS_SUPER_MAGIC;
 	s->s_op = &devpts_sops;
 	s->s_time_gran = 1;
+	s->s_fs_info = new_pts_fs_info();
+
+	if (!s->s_fs_info)
+		goto fail;
 
 	inode = new_inode(s);
 	if (!inode)
-		goto fail;
+		goto free_fsi;
 	inode->i_ino = 1;
 	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
 	inode->i_blocks = 0;
@@ -154,6 +174,9 @@ devpts_fill_super(struct super_block *s,
 	
 	printk("devpts: get root dentry failed\n");
 	iput(inode);
+
+free_fsi:
+	kfree(s->s_fs_info);
 fail:
 	return -ENOMEM;
 }
@@ -164,11 +187,22 @@ static int devpts_get_sb(struct file_sys
 	return get_sb_single(fs_type, flags, data, devpts_fill_super, mnt);
 }
 
+
+static void devpts_kill_sb(struct super_block *sb)
+{
+	struct pts_fs_info *fsi = sb->s_fs_info;	// rcu ?
+
+	//idr_destroy(&fsi->allocated_ptys);
+	kfree(fsi);
+
+	kill_anon_super(sb);
+}
+
 static struct file_system_type devpts_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "devpts",
 	.get_sb		= devpts_get_sb,
-	.kill_sb	= kill_anon_super,
+	.kill_sb	= devpts_kill_sb,
 };
 
 /*
@@ -187,14 +221,16 @@ int devpts_new_index(struct inode *inode
 {
 	int index;
 	int idr_ret;
+	struct super_block *sb = pts_sb_from_inode(inode);
+	struct pts_fs_info *fsi = sb->s_fs_info; 	// need rcu ?
 
 retry:
-	if (!idr_pre_get(&allocated_ptys, GFP_KERNEL)) {
+	if (!idr_pre_get(&fsi->allocated_ptys, GFP_KERNEL)) {
 		return -ENOMEM;
 	}
 
 	mutex_lock(&allocated_ptys_lock);
-	idr_ret = idr_get_new(&allocated_ptys, NULL, &index);
+	idr_ret = idr_get_new(&fsi->allocated_ptys, NULL, &index);
 	if (idr_ret < 0) {
 		mutex_unlock(&allocated_ptys_lock);
 		if (idr_ret == -EAGAIN)
@@ -203,7 +239,7 @@ retry:
 	}
 
 	if (index >= pty_limit) {
-		idr_remove(&allocated_ptys, index);
+		idr_remove(&fsi->allocated_ptys, index);
 		mutex_unlock(&allocated_ptys_lock);
 		return -EIO;
 	}
@@ -213,8 +249,11 @@ retry:
 
 void devpts_kill_index(struct inode *inode, int idx)
 {
+	struct super_block *sb = pts_sb_from_inode(inode);
+	struct pts_fs_info *fsi = sb->s_fs_info; 	// need rcu ?
+
 	mutex_lock(&allocated_ptys_lock);
-	idr_remove(&allocated_ptys, idx);
+	idr_remove(&fsi->allocated_ptys, idx);
 	mutex_unlock(&allocated_ptys_lock);
 }
