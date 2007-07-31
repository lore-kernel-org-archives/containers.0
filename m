From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 02/14] sysfs: In sysfs_lookup protect s_parent with
	sysfs_mutex
Date: Tue, 31 Jul 2007 04:20:05 -0600
Message-ID: <m1vec0swmi.fsf_-_@ebiederm.dsl.xmission.com>
References: <1182446577.8138.29.camel@localhost>
	<m1zm1t2e92.fsf_-_@ebiederm.dsl.xmission.com>
	<46A3B449.3090409@gmail.com> <20070722202508.GA18018@suse.de>
	<m17iosw075.fsf@ebiederm.dsl.xmission.com>
	<46A425F9.1030008@gmail.com> <46AD8E92.7080002@suse.de>
	<46ADDC7F.1090306@sw.ru> <46ADE24E.8020502@suse.de>
	<46ADEE35.8000109@sw.ru> <46ADF003.3010100@suse.de>
	<m1ps29vqin.fsf@ebiederm.dsl.xmission.com>
	<m1k5shuugc.fsf@ebiederm.dsl.xmission.com> <46AEAF79.6080404@suse.de>
	<m1fy35uso4.fsf@ebiederm.dsl.xmission.com> <46AEBA87.6000400@suse.de>
	<m1bqdtt34l.fsf@ebiederm.dsl.xmission.com> <46AEEF75.2030101@suse.de>
	<46AEEFA6.4000901@suse.de>
	<m14pjkubd2.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zm1cswp0.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1zm1cswp0.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Tue, 31 Jul 2007 04:18:35 -0600")
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


It turns out we have been being silly and have failed to
protect ourselves against races between sysfs_lookup
and operations that modify the sysfs directory like sysfs_readdir
and create_dir.

So this patch modifies sysfs_lookup to grab sysfs_mutex before
walking the parent->s_children list.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysfs/dir.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 40b9efe..b27a38c 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -756,11 +756,13 @@ static struct dentry * sysfs_lookup(struct inode *dir, struct dentry *dentry,
 				struct nameidata *nd)
 {
 	struct sysfs_dirent * parent_sd = dentry->d_parent->d_fsdata;
+	struct dentry *result = NULL;
 	struct sysfs_dirent * sd;
 	struct bin_attribute *bin_attr;
 	struct inode *inode;
 	int found = 0;
 
+	mutex_lock(&sysfs_mutex);
 	for (sd = parent_sd->s_children; sd; sd = sd->s_sibling) {
 		if (sysfs_type(sd) &&
 		    !strcmp(sd->s_name, dentry->d_name.name)) {
@@ -771,14 +773,14 @@ static struct dentry * sysfs_lookup(struct inode *dir, struct dentry *dentry,
 
 	/* no such entry */
 	if (!found)
-		return NULL;
+		goto out;
 
 	/* attach dentry and inode */
 	inode = sysfs_get_inode(sd);
-	if (!inode)
-		return ERR_PTR(-ENOMEM);
-
-	mutex_lock(&sysfs_mutex);
+	if (!inode) {
+		result = ERR_PTR(-ENOMEM);
+		goto out;
+	}
 
 	if (inode->i_state & I_NEW) {
 		/* initialize inode according to type */
@@ -808,9 +810,10 @@ static struct dentry * sysfs_lookup(struct inode *dir, struct dentry *dentry,
 	sysfs_instantiate(dentry, inode);
 	sysfs_attach_dentry(sd, dentry);
 
+out:
 	mutex_unlock(&sysfs_mutex);
 
-	return NULL;
+	return result;
 }
 
 const struct inode_operations sysfs_dir_inode_operations = {
-- 
1.5.1.1.181.g2de0
