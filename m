From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 16/27] userns: Convert vfs posix_acl support to use kuids and
	kgids
Date: Wed, 19 Sep 2012 18:52:18 -0700
Message-ID: <1348105949-25454-16-git-send-email-ebiederm@xmission.com>
References: <871uhx1n71.fsf@xmission.com>
	<1348105949-25454-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348105949-25454-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

- In setxattr if we are setting a posix acl convert uids and gids from
  the current user namespace into the initial user namespace, before
  the xattrs are passed to the underlying filesystem.

  Untranslatable uids and gids are represented as -1 which
  posix_acl_from_xattr will represent as INVALID_UID or INVALID_GID.
  posix_acl_valid will fail if an acl from userspace has any
  INVALID_UID or INVALID_GID values.  In net this guarantees that
  untranslatable posix acls will not be stored by filesystems.

- In getxattr if we are reading a posix acl convert uids and gids from
  the initial user namespace into the current user namespace.

  Uids and gids that can not be tranlsated into the current user namespace
  will be represented as -1.

- Replace e_id in struct posix_acl_entry with an anymouns union of
  e_uid and e_gid.  For the short term retain the e_id field
  until all of the users are converted.

- Don't set struct posix_acl.e_id in the cases where the acl type
  does not use e_id.  Greatly reducing the use of ACL_UNDEFINED_ID.

- Rework the ordering checks in posix_acl_valid so that I use kuid_t
  and kgid_t types throughout the code, and so that I don't need
  arithmetic on uid and gid types.

Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/posix_acl.c                  |   30 ++++++------
 fs/xattr.c                      |    7 +++
 fs/xattr_acl.c                  |   90 ++++++++++++++++++++++++++++++++++++--
 include/linux/posix_acl.h       |    8 +++-
 include/linux/posix_acl_xattr.h |   12 +++++
 5 files changed, 126 insertions(+), 21 deletions(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 5e325a4..8bd2135 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -78,7 +78,8 @@ posix_acl_valid(const struct posix_acl *acl)
 {
 	const struct posix_acl_entry *pa, *pe;
 	int state = ACL_USER_OBJ;
-	unsigned int id = 0;  /* keep gcc happy */
+	kuid_t prev_uid = INVALID_UID;
+	kgid_t prev_gid = INVALID_GID;
 	int needs_mask = 0;
 
 	FOREACH_ACL_ENTRY(pa, acl, pe) {
@@ -87,7 +88,6 @@ posix_acl_valid(const struct posix_acl *acl)
 		switch (pa->e_tag) {
 			case ACL_USER_OBJ:
 				if (state == ACL_USER_OBJ) {
-					id = 0;
 					state = ACL_USER;
 					break;
 				}
@@ -96,16 +96,17 @@ posix_acl_valid(const struct posix_acl *acl)
 			case ACL_USER:
 				if (state != ACL_USER)
 					return -EINVAL;
-				if (pa->e_id == ACL_UNDEFINED_ID ||
-				    pa->e_id < id)
+				if (!uid_valid(pa->e_uid))
 					return -EINVAL;
-				id = pa->e_id + 1;
+				if (uid_valid(prev_uid) &&
+				    uid_lte(pa->e_uid, prev_uid))
+					return -EINVAL;
+				prev_uid = pa->e_uid;
 				needs_mask = 1;
 				break;
 
 			case ACL_GROUP_OBJ:
 				if (state == ACL_USER) {
-					id = 0;
 					state = ACL_GROUP;
 					break;
 				}
@@ -114,10 +115,12 @@ posix_acl_valid(const struct posix_acl *acl)
 			case ACL_GROUP:
 				if (state != ACL_GROUP)
 					return -EINVAL;
-				if (pa->e_id == ACL_UNDEFINED_ID ||
-				    pa->e_id < id)
+				if (!gid_valid(pa->e_gid))
+					return -EINVAL;
+				if (gid_valid(prev_gid) &&
+				    gid_lte(pa->e_gid, prev_gid))
 					return -EINVAL;
-				id = pa->e_id + 1;
+				prev_gid = pa->e_gid;
 				needs_mask = 1;
 				break;
 
@@ -195,15 +198,12 @@ posix_acl_from_mode(umode_t mode, gfp_t flags)
 		return ERR_PTR(-ENOMEM);
 
 	acl->a_entries[0].e_tag  = ACL_USER_OBJ;
-	acl->a_entries[0].e_id   = ACL_UNDEFINED_ID;
 	acl->a_entries[0].e_perm = (mode & S_IRWXU) >> 6;
 
 	acl->a_entries[1].e_tag  = ACL_GROUP_OBJ;
-	acl->a_entries[1].e_id   = ACL_UNDEFINED_ID;
 	acl->a_entries[1].e_perm = (mode & S_IRWXG) >> 3;
 
 	acl->a_entries[2].e_tag  = ACL_OTHER;
-	acl->a_entries[2].e_id   = ACL_UNDEFINED_ID;
 	acl->a_entries[2].e_perm = (mode & S_IRWXO);
 	return acl;
 }
@@ -224,11 +224,11 @@ posix_acl_permission(struct inode *inode, const struct posix_acl *acl, int want)
                 switch(pa->e_tag) {
                         case ACL_USER_OBJ:
 				/* (May have been checked already) */
-				if (inode->i_uid == current_fsuid())
+				if (uid_eq(inode->i_uid, current_fsuid()))
                                         goto check_perm;
                                 break;
                         case ACL_USER:
-				if (pa->e_id == current_fsuid())
+				if (uid_eq(pa->e_uid, current_fsuid()))
                                         goto mask;
 				break;
                         case ACL_GROUP_OBJ:
@@ -239,7 +239,7 @@ posix_acl_permission(struct inode *inode, const struct posix_acl *acl, int want)
                                 }
 				break;
                         case ACL_GROUP:
-                                if (in_group_p(pa->e_id)) {
+				if (in_group_p(pa->e_gid)) {
 					found = 1;
 					if ((pa->e_perm & want) == want)
 						goto mask;
diff --git a/fs/xattr.c b/fs/xattr.c
index 4d45b71..c111745 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -20,6 +20,7 @@
 #include <linux/fsnotify.h>
 #include <linux/audit.h>
 #include <linux/vmalloc.h>
+#include <linux/posix_acl_xattr.h>
 
 #include <asm/uaccess.h>
 
@@ -347,6 +348,9 @@ setxattr(struct dentry *d, const char __user *name, const void __user *value,
 			error = -EFAULT;
 			goto out;
 		}
+		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
+		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
+			posix_acl_fix_xattr_from_user(kvalue, size);
 	}
 
 	error = vfs_setxattr(d, kname, kvalue, size, flags);
@@ -450,6 +454,9 @@ getxattr(struct dentry *d, const char __user *name, void __user *value,
 
 	error = vfs_getxattr(d, kname, kvalue, size);
 	if (error > 0) {
+		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
+		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
+			posix_acl_fix_xattr_to_user(kvalue, size);
 		if (size && copy_to_user(value, kvalue, error))
 			error = -EFAULT;
 	} else if (error == -ERANGE && size >= XATTR_SIZE_MAX) {
diff --git a/fs/xattr_acl.c b/fs/xattr_acl.c
index 69d06b0..bf472ca 100644
--- a/fs/xattr_acl.c
+++ b/fs/xattr_acl.c
@@ -9,7 +9,65 @@
 #include <linux/fs.h>
 #include <linux/posix_acl_xattr.h>
 #include <linux/gfp.h>
+#include <linux/user_namespace.h>
 
+/*
+ * Fix up the uids and gids in posix acl extended attributes in place.
+ */
+static void posix_acl_fix_xattr_userns(
+	struct user_namespace *to, struct user_namespace *from,
+	void *value, size_t size)
+{
+	posix_acl_xattr_header *header = (posix_acl_xattr_header *)value;
+	posix_acl_xattr_entry *entry = (posix_acl_xattr_entry *)(header+1), *end;
+	int count;
+	kuid_t uid;
+	kgid_t gid;
+
+	if (!value)
+		return;
+	if (size < sizeof(posix_acl_xattr_header))
+		return;
+	if (header->a_version != cpu_to_le32(POSIX_ACL_XATTR_VERSION))
+		return;
+
+	count = posix_acl_xattr_count(size);
+	if (count < 0)
+		return;
+	if (count == 0)
+		return;
+
+	for (end = entry + count; entry != end; entry++) {
+		switch(le16_to_cpu(entry->e_tag)) {
+		case ACL_USER:
+			uid = make_kuid(from, le32_to_cpu(entry->e_id));
+			entry->e_id = cpu_to_le32(from_kuid(to, uid));
+			break;
+		case ACL_GROUP:
+			gid = make_kgid(from, le32_to_cpu(entry->e_id));
+			entry->e_id = cpu_to_le32(from_kuid(to, uid));
+			break;
+		default:
+			break;
+		}
+	}
+}
+
+void posix_acl_fix_xattr_from_user(void *value, size_t size)
+{
+	struct user_namespace *user_ns = current_user_ns();
+	if (user_ns == &init_user_ns)
+		return;
+	posix_acl_fix_xattr_userns(&init_user_ns, user_ns, value, size);
+}
+
+void posix_acl_fix_xattr_to_user(void *value, size_t size)
+{
+	struct user_namespace *user_ns = current_user_ns();
+	if (user_ns == &init_user_ns)
+		return;
+	posix_acl_fix_xattr_userns(user_ns, &init_user_ns, value, size);
+}
 
 /*
  * Convert from extended attribute to in-memory representation.
@@ -50,12 +108,21 @@ posix_acl_from_xattr(const void *value, size_t size)
 			case ACL_GROUP_OBJ:
 			case ACL_MASK:
 			case ACL_OTHER:
-				acl_e->e_id = ACL_UNDEFINED_ID;
 				break;
 
 			case ACL_USER:
+				acl_e->e_uid =
+					make_kuid(&init_user_ns,
+						  le32_to_cpu(entry->e_id));
+				if (!uid_valid(acl_e->e_uid))
+					goto fail;
+				break;
 			case ACL_GROUP:
-				acl_e->e_id = le32_to_cpu(entry->e_id);
+				acl_e->e_gid =
+					make_kgid(&init_user_ns,
+						  le32_to_cpu(entry->e_id));
+				if (!gid_valid(acl_e->e_gid))
+					goto fail;
 				break;
 
 			default:
@@ -89,9 +156,22 @@ posix_acl_to_xattr(const struct posix_acl *acl, void *buffer, size_t size)
 	ext_acl->a_version = cpu_to_le32(POSIX_ACL_XATTR_VERSION);
 
 	for (n=0; n < acl->a_count; n++, ext_entry++) {
-		ext_entry->e_tag  = cpu_to_le16(acl->a_entries[n].e_tag);
-		ext_entry->e_perm = cpu_to_le16(acl->a_entries[n].e_perm);
-		ext_entry->e_id   = cpu_to_le32(acl->a_entries[n].e_id);
+		const struct posix_acl_entry *acl_e = &acl->a_entries[n];
+		ext_entry->e_tag  = cpu_to_le16(acl_e->e_tag);
+		ext_entry->e_perm = cpu_to_le16(acl_e->e_perm);
+		switch(acl_e->e_tag) {
+		case ACL_USER:
+			ext_entry->e_id =
+				cpu_to_le32(from_kuid(&init_user_ns, acl_e->e_uid));
+			break;
+		case ACL_GROUP:
+			ext_entry->e_id =
+				cpu_to_le32(from_kgid(&init_user_ns, acl_e->e_gid));
+			break;
+		default:
+			ext_entry->e_id = cpu_to_le32(ACL_UNDEFINED_ID);
+			break;
+		}
 	}
 	return real_size;
 }
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 11bad91..7931efe 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -36,7 +36,13 @@
 struct posix_acl_entry {
 	short			e_tag;
 	unsigned short		e_perm;
-	unsigned int		e_id;
+	union {
+		kuid_t		e_uid;
+		kgid_t		e_gid;
+#ifndef CONFIG_UIDGID_STRICT_TYPE_CHECKS
+		unsigned int	e_id;
+#endif
+	};
 };
 
 struct posix_acl {
diff --git a/include/linux/posix_acl_xattr.h b/include/linux/posix_acl_xattr.h
index 6e53c34..8bd5fcf 100644
--- a/include/linux/posix_acl_xattr.h
+++ b/include/linux/posix_acl_xattr.h
@@ -52,6 +52,18 @@ posix_acl_xattr_count(size_t size)
 	return size / sizeof(posix_acl_xattr_entry);
 }
 
+#ifdef CONFIG_FS_POSIX_ACL
+void posix_acl_fix_xattr_from_user(void *value, size_t size);
+void posix_acl_fix_xattr_to_user(void *value, size_t size);
+#else
+static inline void posix_acl_fix_xattr_from_user(void *value, size_t size)
+{
+}
+static inline void posix_acl_fix_xattr_to_user(void *value, size_t size)
+{
+}
+#endif
+
 struct posix_acl *posix_acl_from_xattr(const void *value, size_t size);
 int posix_acl_to_xattr(const struct posix_acl *acl, void *buffer, size_t size);
 
-- 
1.7.5.4
