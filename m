From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 09/14] sysfs: Move all of sysfs_move_dir under sysfs_mutex
Date: Tue, 31 Jul 2007 04:33:36 -0600
Message-ID: <m11weosvzz.fsf_-_@ebiederm.dsl.xmission.com>
References: <1182446577.8138.29.camel@localhost> <46ADE24E.8020502@suse.de>
	<46ADEE35.8000109@sw.ru> <46ADF003.3010100@suse.de>
	<m1ps29vqin.fsf@ebiederm.dsl.xmission.com>
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
	<m1ejioswai.fsf_-_@ebiederm.dsl.xmission.com>
	<m1abtcsw8w.fsf_-_@ebiederm.dsl.xmission.com>
	<m16440sw6d.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m16440sw6d.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Tue, 31 Jul 2007 04:29:46 -0600")
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


This patch modifies sysfs_move_dir to perform all of it's
operations under the sysfs_mutex.  By looking for conflicts
using sysfs_find_dirent we accidentally moving something
onto a name that already exists but just not in the dcache
right now.

Two s_dentry usages are killed.

And it has probably become unnecessary to grab i_mutex at
all but I'm not brave enough to do that just yet.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysfs/dir.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 8e614d3..ed2e6f3 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -897,7 +897,7 @@ int sysfs_move_dir(struct kobject *kobj, struct kobject *new_parent_kobj)
 		error = PTR_ERR(old_dentry);
 		goto out_dput;
 	}
-	old_parent = sd->s_parent->s_dentry;
+	old_parent = old_dentry->d_parent;
 
 	new_parent = sysfs_get_dentry(new_parent_sd);
 	if (IS_ERR(new_parent)) {
@@ -915,29 +915,31 @@ again:
 		mutex_unlock(&old_parent->d_inode->i_mutex);
 		goto again;
 	}
+	mutex_lock(&sysfs_mutex);
 
-	new_dentry = lookup_one_len(kobj->name, new_parent, strlen(kobj->name));
-	if (IS_ERR(new_dentry)) {
-		error = PTR_ERR(new_dentry);
+	error = -EEXIST;
+	if (sysfs_find_dirent(new_parent_sd, kobj->name))
 		goto out_unlock;
-	} else
-		error = 0;
+
+	error = -ENOMEM;
+	new_dentry = d_alloc_name(new_parent, kobj->name);
+	if (!new_dentry)
+		goto out_unlock;
+
+	error = 0;
 	d_add(new_dentry, NULL);
-	d_move(sd->s_dentry, new_dentry);
+	d_move(old_dentry, new_dentry);
 	dput(new_dentry);
 
 	/* Remove from old parent's list and insert into new parent's list. */
-	mutex_lock(&sysfs_mutex);
-
 	sysfs_unlink_sibling(sd);
 	sysfs_get(new_parent_sd);
 	sysfs_put(sd->s_parent);
 	sd->s_parent = new_parent_sd;
 	sysfs_link_sibling(sd);
 
-	mutex_unlock(&sysfs_mutex);
-
  out_unlock:
+	mutex_unlock(&sysfs_mutex);
 	mutex_unlock(&new_parent->d_inode->i_mutex);
 	mutex_unlock(&old_parent->d_inode->i_mutex);
  out_dput:
-- 
1.5.1.1.181.g2de0
