Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32988C4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:36:30 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BEC2C20790
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:36:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEC2C20790
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id B921F203BA;
	Thu, 29 Oct 2020 00:36:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Zbb96yInzr0V; Thu, 29 Oct 2020 00:36:10 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 624922150A;
	Thu, 29 Oct 2020 00:36:07 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4D5C8C088B;
	Thu, 29 Oct 2020 00:36:07 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 94CE9C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:36:05 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 8EC2187476
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:36:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 9nijccpkVld2
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:36:04 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 02DC58739A
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:36:04 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kXvuc-0008Ep-NE; Thu, 29 Oct 2020 00:35:30 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH 11/34] acl: handle idmapped mounts
Date: Thu, 29 Oct 2020 01:32:29 +0100
Message-Id: <20201029003252.2128653-12-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.29.0
In-Reply-To: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Miklos Szeredi <miklos@szeredi.hu>, smbarber@chromium.org,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 Jann Horn <jannh@google.com>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
 Jonathan Corbet <corbet@lwn.net>, linux-unionfs@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-audit@redhat.com,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, Alban Crequy <alban@kinvolk.io>,
 linux-integrity@vger.kernel.org, Todd Kjos <tkjos@google.com>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

The posix acl permission checking helpers determine whether a caller is
privileged over an inode according to the acls associated with the
inode. Add helpers that make it possible to handle acls on idampped
mounts.

The vfs and the filesystems targeted by this first iteration make use of
posix_acl_fix_xattr_from_user() and posix_acl_fix_xattr_to_user() to
translate basic posix access and default permissions such as the
ACL_USER and ACL_GROUP type according to the initial user namespace (or
the superblock's user namespace) to and from the caller's current user
namespace. Adapt these two helpers to handle idmapped mounts whereby we
either shift from or into the mount's user namespace depending on in
which direction we're translating.
Similarly, cap_convert_nscap() is used by the vfs to translate user
namespace and non-user namespace aware filesystem capabilities from the
superblock's user namespace to the caller's user namespace. Enable it to
handle idmapped mounts by accounting for the mount's user namespace.

In addition the fileystems targeted in the first iteration of this patch
series make use of the posix_acl_chmod() and, posix_acl_update_mode()
helpers. Both helpers perform permission checks on the target inode. Add
two new helpers posix_mapped_acl_chmod() and
posix_mapped_acl_update_mode() to handle idmapped mounts. These two
helpers are called when acls are set by the respective filesystems to
handle this case we add a new ->set_mapped() method to struct
xattr_handler which passes the mount's user namespace down.

To this end the standard posix access and default attribute handlers
posix_acl_access_xattr_handler and posix_acl_default_xattr_handler gain
a new posix_acl_xattr_set_mapped() callback which serves as the
implemtation of the newly added ->set_mapped() method in struct
xattr_handler. This callback maps the inode according to the mount's
user namespace but otherwise performs identical checks as its
non-idmapped aware counterpart.

If the initial user namespace is passed to any of the new helpers the
permission checking is identical to their non-idmapped aware
counterparts without any performance impact. This means that the
non-idmapped aware helpers can simply be implemented on top of their
idmapped-mount aware counterparts by passing the initial user namespace
without any change in behavior or performance.

Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
 fs/posix_acl.c                  | 110 ++++++++++++++++++++++++++------
 fs/xattr.c                      |   6 +-
 include/linux/capability.h      |   3 +-
 include/linux/posix_acl.h       |  10 +++
 include/linux/posix_acl_xattr.h |  12 ++--
 include/linux/xattr.h           |   6 ++
 security/commoncap.c            |  15 +++--
 7 files changed, 128 insertions(+), 34 deletions(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index f15b6ad35ec3..665eb7921e1c 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -558,7 +558,7 @@ __posix_acl_chmod(struct posix_acl **acl, gfp_t gfp, umode_t mode)
 EXPORT_SYMBOL(__posix_acl_chmod);
 
 int
-posix_acl_chmod(struct inode *inode, umode_t mode)
+posix_mapped_acl_chmod(struct user_namespace *user_ns, struct inode *inode, umode_t mode)
 {
 	struct posix_acl *acl;
 	int ret = 0;
@@ -582,6 +582,12 @@ posix_acl_chmod(struct inode *inode, umode_t mode)
 	posix_acl_release(acl);
 	return ret;
 }
+
+int
+posix_acl_chmod(struct inode *inode, umode_t mode)
+{
+	return posix_mapped_acl_chmod(&init_user_ns, inode, mode);
+}
 EXPORT_SYMBOL(posix_acl_chmod);
 
 int
@@ -636,7 +642,8 @@ posix_acl_create(struct inode *dir, umode_t *mode,
 EXPORT_SYMBOL_GPL(posix_acl_create);
 
 /**
- * posix_acl_update_mode  -  update mode in set_acl
+ * posix_mapped_acl_update_mode  -  update mode in set_acl
+ * @user_ns: user namespace the inode is accessed from
  * @inode: target inode
  * @mode_p: mode (pointer) for update
  * @acl: acl pointer
@@ -650,8 +657,9 @@ EXPORT_SYMBOL_GPL(posix_acl_create);
  *
  * Called from set_acl inode operations.
  */
-int posix_acl_update_mode(struct inode *inode, umode_t *mode_p,
-			  struct posix_acl **acl)
+int posix_mapped_acl_update_mode(struct user_namespace *user_ns,
+			     struct inode *inode, umode_t *mode_p,
+			     struct posix_acl **acl)
 {
 	umode_t mode = inode->i_mode;
 	int error;
@@ -661,12 +669,34 @@ int posix_acl_update_mode(struct inode *inode, umode_t *mode_p,
 		return error;
 	if (error == 0)
 		*acl = NULL;
-	if (!in_group_p(inode->i_gid) &&
-	    !capable_wrt_inode_uidgid(inode, CAP_FSETID))
+	if (!in_group_p(i_gid_into_mnt(user_ns, inode)) &&
+	    !capable_wrt_mapped_inode_uidgid(user_ns, inode, CAP_FSETID))
 		mode &= ~S_ISGID;
 	*mode_p = mode;
 	return 0;
 }
+EXPORT_SYMBOL(posix_mapped_acl_update_mode);
+
+/**
+ * posix_acl_update_mode  -  update mode in set_acl
+ * @inode: target inode
+ * @mode_p: mode (pointer) for update
+ * @acl: acl pointer
+ *
+ * Update the file mode when setting an ACL: compute the new file permission
+ * bits based on the ACL.  In addition, if the ACL is equivalent to the new
+ * file mode, set *@acl to NULL to indicate that no ACL should be set.
+ *
+ * As with chmod, clear the setgid bit if the caller is not in the owning group
+ * or capable of CAP_FSETID (see inode_change_ok).
+ *
+ * Called from set_acl inode operations.
+ */
+int posix_acl_update_mode(struct inode *inode, umode_t *mode_p,
+			  struct posix_acl **acl)
+{
+	return posix_mapped_acl_update_mode(&init_user_ns, inode, mode_p, acl);
+}
 EXPORT_SYMBOL(posix_acl_update_mode);
 
 /*
@@ -674,7 +704,8 @@ EXPORT_SYMBOL(posix_acl_update_mode);
  */
 static void posix_acl_fix_xattr_userns(
 	struct user_namespace *to, struct user_namespace *from,
-	void *value, size_t size)
+	struct user_namespace *mnt_user_ns,
+	void *value, size_t size, bool from_user)
 {
 	struct posix_acl_xattr_header *header = value;
 	struct posix_acl_xattr_entry *entry = (void *)(header + 1), *end;
@@ -699,10 +730,18 @@ static void posix_acl_fix_xattr_userns(
 		switch(le16_to_cpu(entry->e_tag)) {
 		case ACL_USER:
 			uid = make_kuid(from, le32_to_cpu(entry->e_id));
+			if (from_user)
+				uid = kuid_from_mnt(mnt_user_ns, uid);
+			else
+				uid = kuid_into_mnt(mnt_user_ns, uid);
 			entry->e_id = cpu_to_le32(from_kuid(to, uid));
 			break;
 		case ACL_GROUP:
 			gid = make_kgid(from, le32_to_cpu(entry->e_id));
+			if (from_user)
+				gid = kgid_from_mnt(mnt_user_ns, gid);
+			else
+				gid = kgid_into_mnt(mnt_user_ns, gid);
 			entry->e_id = cpu_to_le32(from_kgid(to, gid));
 			break;
 		default:
@@ -711,21 +750,25 @@ static void posix_acl_fix_xattr_userns(
 	}
 }
 
-void posix_acl_fix_xattr_from_user(void *value, size_t size)
+void posix_acl_fix_xattr_from_user(struct user_namespace *mnt_user_ns,
+				   void *value, size_t size)
 {
 	struct user_namespace *user_ns = current_user_ns();
-	if (user_ns == &init_user_ns)
+	if ((user_ns == &init_user_ns) && (mnt_user_ns == &init_user_ns))
 		return;
-	posix_acl_fix_xattr_userns(&init_user_ns, user_ns, value, size);
+	posix_acl_fix_xattr_userns(&init_user_ns, user_ns, mnt_user_ns, value, size, true);
 }
+EXPORT_SYMBOL(posix_acl_fix_xattr_from_user);
 
-void posix_acl_fix_xattr_to_user(void *value, size_t size)
+void posix_acl_fix_xattr_to_user(struct user_namespace *mnt_user_ns,
+				 void *value, size_t size)
 {
 	struct user_namespace *user_ns = current_user_ns();
-	if (user_ns == &init_user_ns)
+	if ((user_ns == &init_user_ns) && (mnt_user_ns == &init_user_ns))
 		return;
-	posix_acl_fix_xattr_userns(user_ns, &init_user_ns, value, size);
+	posix_acl_fix_xattr_userns(user_ns, &init_user_ns, mnt_user_ns, value, size, false);
 }
+EXPORT_SYMBOL(posix_acl_fix_xattr_to_user);
 
 /*
  * Convert from extended attribute to in-memory representation.
@@ -863,8 +906,9 @@ posix_acl_xattr_get(const struct xattr_handler *handler,
 	return error;
 }
 
-int
-set_posix_acl(struct inode *inode, int type, struct posix_acl *acl)
+static int
+set_posix_mapped_acl(struct user_namespace *user_ns, struct inode *inode,
+		 int type, struct posix_acl *acl)
 {
 	if (!IS_POSIXACL(inode))
 		return -EOPNOTSUPP;
@@ -873,7 +917,7 @@ set_posix_acl(struct inode *inode, int type, struct posix_acl *acl)
 
 	if (type == ACL_TYPE_DEFAULT && !S_ISDIR(inode->i_mode))
 		return acl ? -EACCES : 0;
-	if (!inode_owner_or_capable(inode))
+	if (!mapped_inode_owner_or_capable(user_ns, inode))
 		return -EPERM;
 
 	if (acl) {
@@ -883,13 +927,21 @@ set_posix_acl(struct inode *inode, int type, struct posix_acl *acl)
 	}
 	return inode->i_op->set_acl(inode, acl, type);
 }
+
+int
+set_posix_acl(struct inode *inode, int type, struct posix_acl *acl)
+{
+
+	return set_posix_mapped_acl(&init_user_ns, inode, type, acl);
+}
 EXPORT_SYMBOL(set_posix_acl);
 
 static int
-posix_acl_xattr_set(const struct xattr_handler *handler,
-		    struct dentry *unused, struct inode *inode,
-		    const char *name, const void *value,
-		    size_t size, int flags)
+posix_acl_xattr_set_mapped(const struct xattr_handler *handler,
+			   struct user_namespace *user_ns,
+			   struct dentry *unused, struct inode *inode,
+			   const char *name, const void *value, size_t size,
+			   int flags)
 {
 	struct posix_acl *acl = NULL;
 	int ret;
@@ -899,11 +951,21 @@ posix_acl_xattr_set(const struct xattr_handler *handler,
 		if (IS_ERR(acl))
 			return PTR_ERR(acl);
 	}
-	ret = set_posix_acl(inode, handler->flags, acl);
+	ret = set_posix_mapped_acl(user_ns, inode, handler->flags, acl);
 	posix_acl_release(acl);
 	return ret;
 }
 
+static int
+posix_acl_xattr_set(const struct xattr_handler *handler,
+		    struct dentry *unused, struct inode *inode,
+		    const char *name, const void *value,
+		    size_t size, int flags)
+{
+	return posix_acl_xattr_set_mapped(handler, &init_user_ns, unused, inode,
+					  name, value, size, flags);
+}
+
 static bool
 posix_acl_xattr_list(struct dentry *dentry)
 {
@@ -916,6 +978,9 @@ const struct xattr_handler posix_acl_access_xattr_handler = {
 	.list = posix_acl_xattr_list,
 	.get = posix_acl_xattr_get,
 	.set = posix_acl_xattr_set,
+#ifdef CONFIG_IDMAP_MOUNTS
+	.set_mapped = posix_acl_xattr_set_mapped,
+#endif
 };
 EXPORT_SYMBOL_GPL(posix_acl_access_xattr_handler);
 
@@ -925,6 +990,9 @@ const struct xattr_handler posix_acl_default_xattr_handler = {
 	.list = posix_acl_xattr_list,
 	.get = posix_acl_xattr_get,
 	.set = posix_acl_xattr_set,
+#ifdef CONFIG_IDMAP_MOUNTS
+	.set_mapped = posix_acl_xattr_set_mapped,
+#endif
 };
 EXPORT_SYMBOL_GPL(posix_acl_default_xattr_handler);
 
diff --git a/fs/xattr.c b/fs/xattr.c
index cd7a563e8bcd..96ff53b42251 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -536,9 +536,9 @@ setxattr(struct dentry *d, const char __user *name, const void __user *value,
 		}
 		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
 		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
-			posix_acl_fix_xattr_from_user(kvalue, size);
+			posix_acl_fix_xattr_from_user(&init_user_ns, kvalue, size);
 		else if (strcmp(kname, XATTR_NAME_CAPS) == 0) {
-			error = cap_convert_nscap(d, &kvalue, size);
+			error = cap_convert_nscap(&init_user_ns, d, &kvalue, size);
 			if (error < 0)
 				goto out;
 			size = error;
@@ -636,7 +636,7 @@ getxattr(struct dentry *d, const char __user *name, void __user *value,
 	if (error > 0) {
 		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
 		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
-			posix_acl_fix_xattr_to_user(kvalue, error);
+			posix_acl_fix_xattr_to_user(&init_user_ns, kvalue, error);
 		if (size && copy_to_user(value, kvalue, error))
 			error = -EFAULT;
 	} else if (error == -ERANGE && size >= XATTR_SIZE_MAX) {
diff --git a/include/linux/capability.h b/include/linux/capability.h
index 308d88096745..7e9277d64024 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -274,6 +274,7 @@ static inline bool checkpoint_restore_ns_capable(struct user_namespace *ns)
 /* audit system wants to get cap info from files as well */
 extern int get_vfs_caps_from_disk(const struct dentry *dentry, struct cpu_vfs_cap_data *cpu_caps);
 
-extern int cap_convert_nscap(struct dentry *dentry, void **ivalue, size_t size);
+extern int cap_convert_nscap(struct user_namespace *user_ns,
+			     struct dentry *dentry, void **ivalue, size_t size);
 
 #endif /* !_LINUX_CAPABILITY_H */
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 8276baefed13..1ab19ded39fd 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -75,9 +75,13 @@ extern int set_posix_acl(struct inode *, int, struct posix_acl *);
 
 #ifdef CONFIG_FS_POSIX_ACL
 extern int posix_acl_chmod(struct inode *, umode_t);
+extern int posix_mapped_acl_chmod(struct user_namespace *, struct inode *, umode_t);
 extern int posix_acl_create(struct inode *, umode_t *, struct posix_acl **,
 		struct posix_acl **);
 extern int posix_acl_update_mode(struct inode *, umode_t *, struct posix_acl **);
+extern int posix_mapped_acl_update_mode(struct user_namespace *user_ns,
+				    struct inode *inode, umode_t *mode_p,
+				    struct posix_acl **acl);
 
 extern int simple_set_acl(struct inode *, struct posix_acl *, int);
 extern int simple_acl_create(struct inode *, struct inode *);
@@ -99,6 +103,12 @@ static inline int posix_acl_chmod(struct inode *inode, umode_t mode)
 	return 0;
 }
 
+static inline int posix_mapped_acl_chmod(struct user_namespace *user_ns,
+				     struct inode *inode, umode_t mode)
+{
+	return 0;
+}
+
 #define simple_set_acl		NULL
 
 static inline int simple_acl_create(struct inode *dir, struct inode *inode)
diff --git a/include/linux/posix_acl_xattr.h b/include/linux/posix_acl_xattr.h
index 2387709991b5..9fdac573e1cb 100644
--- a/include/linux/posix_acl_xattr.h
+++ b/include/linux/posix_acl_xattr.h
@@ -33,13 +33,17 @@ posix_acl_xattr_count(size_t size)
 }
 
 #ifdef CONFIG_FS_POSIX_ACL
-void posix_acl_fix_xattr_from_user(void *value, size_t size);
-void posix_acl_fix_xattr_to_user(void *value, size_t size);
+void posix_acl_fix_xattr_from_user(struct user_namespace *mnt_user_ns,
+				   void *value, size_t size);
+void posix_acl_fix_xattr_to_user(struct user_namespace *mnt_user_ns,
+				 void *value, size_t size);
 #else
-static inline void posix_acl_fix_xattr_from_user(void *value, size_t size)
+static inline void posix_acl_fix_xattr_from_user(struct user_namespace *mnt_user_ns,
+						 void *value, size_t size)
 {
 }
-static inline void posix_acl_fix_xattr_to_user(void *value, size_t size)
+static inline void posix_acl_fix_xattr_to_user(struct user_namespace *mnt_user_ns,
+					       void *value, size_t size)
 {
 }
 #endif
diff --git a/include/linux/xattr.h b/include/linux/xattr.h
index 10b4dc2709f0..908441e74f51 100644
--- a/include/linux/xattr.h
+++ b/include/linux/xattr.h
@@ -37,6 +37,12 @@ struct xattr_handler {
 	int (*set)(const struct xattr_handler *, struct dentry *dentry,
 		   struct inode *inode, const char *name, const void *buffer,
 		   size_t size, int flags);
+#ifdef CONFIG_IDMAP_MOUNTS
+	int (*set_mapped)(const struct xattr_handler *,
+			  struct user_namespace *user_ns, struct dentry *dentry,
+			  struct inode *inode, const char *name,
+			  const void *buffer, size_t size, int flags);
+#endif
 };
 
 const char *xattr_full_name(const struct xattr_handler *, const char *);
diff --git a/security/commoncap.c b/security/commoncap.c
index 59bf3c1674c8..21f2ff7c346b 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -451,15 +451,18 @@ int cap_inode_getsecurity(struct inode *inode, const char *name, void **buffer,
 }
 
 static kuid_t rootid_from_xattr(const void *value, size_t size,
-				struct user_namespace *task_ns)
+				struct user_namespace *task_ns,
+				struct user_namespace *user_ns)
 {
 	const struct vfs_ns_cap_data *nscap = value;
+	kuid_t rootkid;
 	uid_t rootid = 0;
 
 	if (size == XATTR_CAPS_SZ_3)
 		rootid = le32_to_cpu(nscap->rootid);
 
-	return make_kuid(task_ns, rootid);
+	rootkid = make_kuid(task_ns, rootid);
+	return kuid_from_mnt(user_ns, rootkid);
 }
 
 static bool validheader(size_t size, const struct vfs_cap_data *cap)
@@ -473,7 +476,8 @@ static bool validheader(size_t size, const struct vfs_cap_data *cap)
  *
  * If all is ok, we return the new size, on error return < 0.
  */
-int cap_convert_nscap(struct dentry *dentry, void **ivalue, size_t size)
+int cap_convert_nscap(struct user_namespace *user_ns, struct dentry *dentry,
+		      void **ivalue, size_t size)
 {
 	struct vfs_ns_cap_data *nscap;
 	uid_t nsrootid;
@@ -489,14 +493,14 @@ int cap_convert_nscap(struct dentry *dentry, void **ivalue, size_t size)
 		return -EINVAL;
 	if (!validheader(size, cap))
 		return -EINVAL;
-	if (!capable_wrt_inode_uidgid(inode, CAP_SETFCAP))
+	if (!capable_wrt_mapped_inode_uidgid(user_ns, inode, CAP_SETFCAP))
 		return -EPERM;
 	if (size == XATTR_CAPS_SZ_2)
 		if (ns_capable(inode->i_sb->s_user_ns, CAP_SETFCAP))
 			/* user is privileged, just write the v2 */
 			return size;
 
-	rootid = rootid_from_xattr(*ivalue, size, task_ns);
+	rootid = rootid_from_xattr(*ivalue, size, task_ns, user_ns);
 	if (!uid_valid(rootid))
 		return -EINVAL;
 
@@ -520,6 +524,7 @@ int cap_convert_nscap(struct dentry *dentry, void **ivalue, size_t size)
 	*ivalue = nscap;
 	return newsize;
 }
+EXPORT_SYMBOL(cap_convert_nscap);
 
 /*
  * Calculate the new process capability sets from the capability sets attached
-- 
2.29.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
