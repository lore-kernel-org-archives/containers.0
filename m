From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 09/11] userns: Convert ubifs to use kuid/kgid
Date: Fri, 21 Sep 2012 18:35:10 -0700
Message-ID: <1348277712-30055-9-git-send-email-ebiederm@xmission.com>
References: <877grmj115.fsf@xmission.com>
	<1348277712-30055-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348277712-30055-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Artem Bityutskiy <dedekind1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Adrian Hunter <adrian.hunter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Artem Bityutskiy <dedekind1-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Adrian Hunter <adrian.hunter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ubifs/budget.c  |    4 ++--
 fs/ubifs/debug.c   |    4 ++--
 fs/ubifs/journal.c |    4 ++--
 fs/ubifs/sb.c      |    4 ++--
 fs/ubifs/super.c   |    4 ++--
 fs/ubifs/ubifs.h   |    4 ++--
 init/Kconfig       |    1 -
 7 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/fs/ubifs/budget.c b/fs/ubifs/budget.c
index bc4f94b..969489e 100644
--- a/fs/ubifs/budget.c
+++ b/fs/ubifs/budget.c
@@ -272,8 +272,8 @@ long long ubifs_calc_available(const struct ubifs_info *c, int min_idx_lebs)
  */
 static int can_use_rp(struct ubifs_info *c)
 {
-	if (current_fsuid() == c->rp_uid || capable(CAP_SYS_RESOURCE) ||
-	    (c->rp_gid != 0 && in_group_p(c->rp_gid)))
+	if (uid_eq(current_fsuid(), c->rp_uid) || capable(CAP_SYS_RESOURCE) ||
+	    (!gid_eq(c->rp_gid, GLOBAL_ROOT_GID) && in_group_p(c->rp_gid)))
 		return 1;
 	return 0;
 }
diff --git a/fs/ubifs/debug.c b/fs/ubifs/debug.c
index bb31672..340d1af 100644
--- a/fs/ubifs/debug.c
+++ b/fs/ubifs/debug.c
@@ -243,8 +243,8 @@ void ubifs_dump_inode(struct ubifs_info *c, const struct inode *inode)
 	printk(KERN_ERR "\tsize           %llu\n",
 	       (unsigned long long)i_size_read(inode));
 	printk(KERN_ERR "\tnlink          %u\n", inode->i_nlink);
-	printk(KERN_ERR "\tuid            %u\n", (unsigned int)inode->i_uid);
-	printk(KERN_ERR "\tgid            %u\n", (unsigned int)inode->i_gid);
+	printk(KERN_ERR "\tuid            %u\n", (unsigned int)i_uid_read(inode));
+	printk(KERN_ERR "\tgid            %u\n", (unsigned int)i_gid_read(inode));
 	printk(KERN_ERR "\tatime          %u.%u\n",
 	       (unsigned int)inode->i_atime.tv_sec,
 	       (unsigned int)inode->i_atime.tv_nsec);
diff --git a/fs/ubifs/journal.c b/fs/ubifs/journal.c
index 12c0f15..afaad07 100644
--- a/fs/ubifs/journal.c
+++ b/fs/ubifs/journal.c
@@ -469,8 +469,8 @@ static void pack_inode(struct ubifs_info *c, struct ubifs_ino_node *ino,
 	ino->ctime_nsec = cpu_to_le32(inode->i_ctime.tv_nsec);
 	ino->mtime_sec  = cpu_to_le64(inode->i_mtime.tv_sec);
 	ino->mtime_nsec = cpu_to_le32(inode->i_mtime.tv_nsec);
-	ino->uid   = cpu_to_le32(inode->i_uid);
-	ino->gid   = cpu_to_le32(inode->i_gid);
+	ino->uid   = cpu_to_le32(i_uid_read(inode));
+	ino->gid   = cpu_to_le32(i_gid_read(inode));
 	ino->mode  = cpu_to_le32(inode->i_mode);
 	ino->flags = cpu_to_le32(ui->flags);
 	ino->size  = cpu_to_le64(ui->ui_size);
diff --git a/fs/ubifs/sb.c b/fs/ubifs/sb.c
index 15e2fc5..52c21f4 100644
--- a/fs/ubifs/sb.c
+++ b/fs/ubifs/sb.c
@@ -611,8 +611,8 @@ int ubifs_read_superblock(struct ubifs_info *c)
 	c->fanout        = le32_to_cpu(sup->fanout);
 	c->lsave_cnt     = le32_to_cpu(sup->lsave_cnt);
 	c->rp_size       = le64_to_cpu(sup->rp_size);
-	c->rp_uid        = le32_to_cpu(sup->rp_uid);
-	c->rp_gid        = le32_to_cpu(sup->rp_gid);
+	c->rp_uid        = make_kuid(&init_user_ns, le32_to_cpu(sup->rp_uid));
+	c->rp_gid        = make_kgid(&init_user_ns, le32_to_cpu(sup->rp_gid));
 	sup_flags        = le32_to_cpu(sup->flags);
 	if (!c->mount_opts.override_compr)
 		c->default_compr = le16_to_cpu(sup->default_compr);
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index 1c766c3..f39bad9 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -130,8 +130,8 @@ struct inode *ubifs_iget(struct super_block *sb, unsigned long inum)
 
 	inode->i_flags |= (S_NOCMTIME | S_NOATIME);
 	set_nlink(inode, le32_to_cpu(ino->nlink));
-	inode->i_uid   = le32_to_cpu(ino->uid);
-	inode->i_gid   = le32_to_cpu(ino->gid);
+	i_uid_write(inode, le32_to_cpu(ino->uid));
+	i_gid_write(inode, le32_to_cpu(ino->gid));
 	inode->i_atime.tv_sec  = (int64_t)le64_to_cpu(ino->atime_sec);
 	inode->i_atime.tv_nsec = le32_to_cpu(ino->atime_nsec);
 	inode->i_mtime.tv_sec  = (int64_t)le64_to_cpu(ino->mtime_sec);
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index 1e5a086..64f2367 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -1426,8 +1426,8 @@ struct ubifs_info {
 
 	long long rp_size;
 	long long report_rp_size;
-	uid_t rp_uid;
-	gid_t rp_gid;
+	kuid_t rp_uid;
+	kgid_t rp_gid;
 
 	/* The below fields are used only during mounting and re-mounting */
 	unsigned int empty:1;
diff --git a/init/Kconfig b/init/Kconfig
index d88f945..21adc1c 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -939,7 +939,6 @@ config UIDGID_CONVERTED
 	depends on NFSD = n
 	depends on NFS_FS = n
 	depends on OCFS2_FS = n
-	depends on UBIFS_FS = n
 	depends on UDF_FS = n
 	depends on UFS_FS = n
 	depends on XFS_FS = n
-- 
1.7.5.4
