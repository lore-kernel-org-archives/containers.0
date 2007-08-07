From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 24/25] sysfs: Implement sysfs_delete_link and
	sysfs_rename_link
Date: Tue, 07 Aug 2007 15:36:09 -0600
Message-ID: <m1abt3gh86.fsf_-_@ebiederm.dsl.xmission.com>
References: <11860582832964-git-send-email-htejun@gmail.com>
	<m1odhjjbij.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5s7jbh9.fsf_-_@ebiederm.dsl.xmission.com>
	<m1fy2vjbf9.fsf_-_@ebiederm.dsl.xmission.com>
	<m1bqdjjbcf.fsf_-_@ebiederm.dsl.xmission.com>
	<m17io7jba4.fsf_-_@ebiederm.dsl.xmission.com>
	<m13ayvjb82.fsf_-_@ebiederm.dsl.xmission.com>
	<m1y7gnhwm4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com>
	<m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com>
	<m1d4xzhwb2.fsf_-_@ebiederm.dsl.xmission.com>
	<m18x8nhw8r.fsf_-_@ebiederm.dsl.xmission.com>
	<m14pjbhw6y.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zm13ghlh.fsf_-_@ebiederm.dsl.xmission.com>
	<m1vebrghjg.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6mfghg9.fsf_-_@ebiederm.dsl.xmission.com>
	<m1myx3ghdt.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ir7rghbg.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejifgh98.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ejifgh98.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Tue, 07 Aug 2007 15:35:31 -0600")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, gregkh-l3A5Bk7waGM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


When removing a symlink sysfs_remove_link does not provide
enough information to figure out which tagged directory the symlink
falls in.  So I need sysfs_delete_link which is passed the target
of the symlink to delete.

Further half the time when we are removing a symlink the code is
actually renaming the symlink but not doing so explicitly because
we don't have a symlink rename method.  So I have added sysfs_rename_link
as well.

Both of these functions now have enough information to find a symlink
in a tagged directory.  The only restriction is that they must be called
before the target kobject is renamed or deleted.  If they are called
later I loose track of which tag the target kobject was marked with
and can no longer find the old symlink to remove it.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysfs/symlink.c    |   31 +++++++++++++++++++++++++++++++
 include/linux/sysfs.h |   18 ++++++++++++++++++
 2 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
index 99aaf6f..6476b8f 100644
--- a/fs/sysfs/symlink.c
+++ b/fs/sysfs/symlink.c
@@ -106,6 +106,21 @@ int sysfs_create_link(struct kobject * kobj, struct kobject * target, const char
 
 
 /**
+ *	sysfs_delete_link - remove symlink in object's directory.
+ *	@kobj:	object we're acting for.
+ *	@targ:	object we're pointing to.
+ *	@name:	name of the symlink to remove.
+ *
+ *	Unlike sysfs_remove_link sysfs_delete_link has enough information
+ *	to successfully delete symlinks in tagged directories.
+ */
+void sysfs_delete_link(struct kobject *kobj, struct kobject *targ,
+			const char *name)
+{
+	sysfs_hash_and_remove(targ, kobj->sd, name);
+}
+
+/**
  *	sysfs_remove_link - remove symlink in object's directory.
  *	@kobj:	object we're acting for.
  *	@name:	name of the symlink to remove.
@@ -116,6 +131,22 @@ void sysfs_remove_link(struct kobject * kobj, const char * name)
 	sysfs_hash_and_remove(kobj, kobj->sd, name);
 }
 
+/**
+ *	sysfs_rename_link - rename symlink in object's directory.
+ *	@kobj:	object we're acting for.
+ *	@targ:	object we're pointing to.
+ *	@old:	previous name of the symlink.
+ *	@new:	new name of the symlink.
+ *
+ *	A helper function for the common rename symlink idiom.
+ */
+int sysfs_rename_link(struct kobject *kobj, struct kobject *targ,
+			const char *old, const char *new)
+{
+	sysfs_delete_link(kobj, targ, old);
+	return sysfs_create_link(kobj, targ, new);
+}
+
 static int sysfs_get_target_path(struct sysfs_dirent * parent_sd,
 				 struct sysfs_dirent * target_sd, char *path)
 {
diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index 28c497e..90eb35e 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -129,6 +129,13 @@ sysfs_create_link(struct kobject * kobj, struct kobject * target, const char * n
 extern void
 sysfs_remove_link(struct kobject *, const char * name);
 
+extern int
+sysfs_rename_link(struct kobject *kobj, struct kobject *target,
+			const char *old_name, const char *new_name);
+
+extern void
+sysfs_delete_link(struct kobject *dir, struct kobject *targ, const char *name);
+
 int __must_check sysfs_create_bin_file(struct kobject *kobj,
 					struct bin_attribute *attr);
 void sysfs_remove_bin_file(struct kobject *kobj, struct bin_attribute *attr);
@@ -204,6 +211,17 @@ static inline void sysfs_remove_link(struct kobject * k, const char * name)
 	;
 }
 
+static inline int
+sysfs_rename_link(struct kobject * k, struct kobject *t,
+			const char *old_name, const char * new_name)
+{
+	return 0;
+}
+
+static inline void
+sysfs_delete_link(struct kobject *k, struct kobject *t, const char *name)
+{
+}
 
 static inline int sysfs_create_bin_file(struct kobject * k, struct bin_attribute * a)
 {
-- 
1.5.1.1.181.g2de0
