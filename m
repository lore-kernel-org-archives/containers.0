From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 06/14] sysfs: Rewrite sysfs_get_dentry
Date: Tue, 31 Jul 2007 04:27:17 -0600
Message-ID: <m1ejioswai.fsf_-_@ebiederm.dsl.xmission.com>
References: <1182446577.8138.29.camel@localhost> <46A425F9.1030008@gmail.com>
	<46AD8E92.7080002@suse.de> <46ADDC7F.1090306@sw.ru>
	<46ADE24E.8020502@suse.de> <46ADEE35.8000109@sw.ru>
	<46ADF003.3010100@suse.de> <m1ps29vqin.fsf@ebiederm.dsl.xmission.com>
	<m1k5shuugc.fsf@ebiederm.dsl.xmission.com> <46AEAF79.6080404@suse.de>
	<m1fy35uso4.fsf@ebiederm.dsl.xmission.com> <46AEBA87.6000400@suse.de>
	<m1bqdtt34l.fsf@ebiederm.dsl.xmission.com> <46AEEF75.2030101@suse.de>
	<46AEEFA6.4000901@suse.de>
	<m14pjkubd2.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zm1cswp0.fsf_-_@ebiederm.dsl.xmission.com>
	<m1vec0swmi.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6moswhr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1myxcswfr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ir80swdl.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ir80swdl.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Tue, 31 Jul 2007 04:25:26 -0600")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <teheo-l3A5Bk7waGM@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Currently sysfs_get_dentry is very hairy and requires all kinds
of locking magic.  This patch rewrites sysfs_get_dentry to
not use the cached sd->s_dentry, and instead simply lookup
and create dcache entries.

This lays the foundation for removing s_dentry and the
current hairy sysfs_assoc_lock logic.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysfs/dir.c |  117 +++++++++++++++++++++++--------------------------------
 1 files changed, 49 insertions(+), 68 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 6933f36..f22d60c 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -20,6 +20,8 @@ spinlock_t sysfs_assoc_lock = SPIN_LOCK_UNLOCKED;
 static spinlock_t sysfs_ino_lock = SPIN_LOCK_UNLOCKED;
 static DEFINE_IDA(sysfs_ino_ida);
 
+static void sysfs_attach_dentry(struct sysfs_dirent *sd, struct dentry *dentry);
+
 /**
  *	sysfs_link_sibling - link sysfs_dirent into sibling list
  *	@sd: sysfs_dirent of interest
@@ -66,10 +68,10 @@ void sysfs_unlink_sibling(struct sysfs_dirent *sd)
  *	sysfs_get_dentry - get dentry for the given sysfs_dirent
  *	@sd: sysfs_dirent of interest
  *
- *	Get dentry for @sd.  Dentry is looked up if currently not
- *	present.  This function climbs sysfs_dirent tree till it
- *	reaches a sysfs_dirent with valid dentry attached and descends
- *	down from there looking up dentry for each step.
+ *	Get dentry for @sd.
+ *
+ *	This function descends the sysfs dentry tree from the root
+ *	populating it if necessary until it reaches the dentry for @sd.
  *
  *	LOCKING:
  *	Kernel thread context (may sleep)
@@ -77,85 +79,58 @@ void sysfs_unlink_sibling(struct sysfs_dirent *sd)
  *	RETURNS:
  *	Pointer to found dentry on success, ERR_PTR() value on error.
  */
-struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
+struct dentry *__sysfs_get_dentry(struct sysfs_dirent *sd, int create)
 {
 	struct sysfs_dirent *cur;
 	struct dentry *parent_dentry, *dentry;
-	int i, depth;
-
-	/* Find the first parent which has valid s_dentry and get the
-	 * dentry.
-	 */
-	mutex_lock(&sysfs_mutex);
- restart0:
-	spin_lock(&sysfs_assoc_lock);
- restart1:
-	spin_lock(&dcache_lock);
-
-	dentry = NULL;
-	depth = 0;
-	cur = sd;
-	while (!cur->s_dentry || !cur->s_dentry->d_inode) {
-		if (cur->s_flags & SYSFS_FLAG_REMOVED) {
-			dentry = ERR_PTR(-ENOENT);
-			depth = 0;
-			break;
-		}
-		cur = cur->s_parent;
-		depth++;
-	}
-	if (!IS_ERR(dentry))
-		dentry = dget_locked(cur->s_dentry);
+	struct qstr name;
+	struct inode *inode;
 
-	spin_unlock(&dcache_lock);
-	spin_unlock(&sysfs_assoc_lock);
+	parent_dentry = NULL;
+	dentry = dget(sysfs_sb->s_root);
 
-	/* from the found dentry, look up depth times */
-	while (depth--) {
-		/* find and get depth'th ancestor */
-		for (cur = sd, i = 0; cur && i < depth; i++)
+	do {
+		/* Find the first ancestor I have not looked up */
+		cur = sd;
+		while (cur->s_parent != dentry->d_fsdata)
 			cur = cur->s_parent;
 
-		/* This can happen if tree structure was modified due
-		 * to move/rename.  Restart.
-		 */
-		if (i != depth) {
-			dput(dentry);
-			goto restart0;
-		}
-
-		sysfs_get(cur);
-
-		mutex_unlock(&sysfs_mutex);
-
 		/* look it up */
-		parent_dentry = dentry;
-		dentry = lookup_one_len_kern(cur->s_name, parent_dentry,
-					     strlen(cur->s_name));
 		dput(parent_dentry);
-
-		if (IS_ERR(dentry)) {
-			sysfs_put(cur);
-			return dentry;
+		parent_dentry = dentry;
+		name.name = cur->s_name;
+		name.len = strlen(cur->s_name);
+		dentry = d_hash_and_lookup(parent_dentry, &name);
+		if (dentry)
+			continue;
+		if (!create)
+			goto out;
+		dentry = d_alloc(parent_dentry, &name);
+		if (!dentry) {
+			dentry = ERR_PTR(-ENOMEM);
+			goto out;
 		}
-
-		mutex_lock(&sysfs_mutex);
-		spin_lock(&sysfs_assoc_lock);
-
-		/* This, again, can happen if tree structure has
-		 * changed and we looked up the wrong thing.  Restart.
-		 */
-		if (cur->s_dentry != dentry) {
+		inode = sysfs_get_inode(cur);
+		if (!inode) {
 			dput(dentry);
-			sysfs_put(cur);
-			goto restart1;
+			dentry = ERR_PTR(-ENOMEM);
+			goto out;
 		}
+		d_instantiate(dentry, inode);
+		sysfs_attach_dentry(cur, dentry);
+	} while (cur != sd);
 
-		spin_unlock(&sysfs_assoc_lock);
+out:
+	dput(parent_dentry);
+	return dentry;
+}
 
-		sysfs_put(cur);
-	}
+struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
+{
+	struct dentry *dentry;
 
+	mutex_lock(&sysfs_mutex);
+	dentry = __sysfs_get_dentry(sd, 1);
 	mutex_unlock(&sysfs_mutex);
 	return dentry;
 }
@@ -750,6 +725,12 @@ static struct dentry * sysfs_lookup(struct inode *dir, struct dentry *dentry,
 	struct inode *inode;
 
 	mutex_lock(&sysfs_mutex);
+
+	/* Guard against races with sysfs_get_dentry */
+	result = d_hash_and_lookup(dentry->d_parent, &dentry->d_name);
+	if (result)
+		goto out;
+
 	for (sd = parent_sd->s_children; sd; sd = sd->s_sibling) {
 		if (sysfs_type(sd) &&
 		    !strcmp(sd->s_name, dentry->d_name.name))
-- 
1.5.1.1.181.g2de0
