Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BA17C4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:36:04 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 86A7E20790
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:36:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86A7E20790
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 903AD865C1;
	Thu, 29 Oct 2020 00:36:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0b485Rinaiot; Thu, 29 Oct 2020 00:36:00 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id DFF8C86505;
	Thu, 29 Oct 2020 00:35:59 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id CB311C1ADB;
	Thu, 29 Oct 2020 00:35:59 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E679FC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:35:56 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id D46C1203BA
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:35:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id UFPC3DzTD8Ux
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:35:55 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by silver.osuosl.org (Postfix) with ESMTPS id 07DF4203EF
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:35:55 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kXvuX-0008Ep-FF; Thu, 29 Oct 2020 00:35:25 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH 08/34] namei: add idmapped mount aware permission helpers
Date: Thu, 29 Oct 2020 01:32:26 +0100
Message-Id: <20201029003252.2128653-9-christian.brauner@ubuntu.com>
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

The two helpers inode_permission() and generic_permission() are used by
the vfs to perform basic permission checking by verifying that the
caller is privileged over an inode. In order to handle idmapped mount we
add the two helpers mapped_inode_permission() to
mapped_generic_permission() which take a user namespace argument. On
idmapped mounts the two new helpers will make sure to map the inode
according to the mount's user namespace and then peform identical
permission checks to inode_permission() and generic_permission(). If the
initial user namespace is passed mapped_inode_permission() and
mapped_generic_permission() are identical to inode_permission() and
generic_permission() so there will be no performance impact on
non-idmapped mounts. This also means that the inode_permission() and
generic_permission() helpers can be implemented on top of
mapped_inode_permission() and mapped_generic_permission() respectively
by just passing in the initial user namespace so no code is
unnecessarily duplicated.

Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
 fs/namei.c                | 71 ++++++++++++++++++++++++++++-----------
 fs/posix_acl.c            | 16 ++++++---
 include/linux/fs.h        |  2 ++
 include/linux/posix_acl.h |  4 ++-
 4 files changed, 67 insertions(+), 26 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index d4a6dd772303..2635f6a57de5 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -259,7 +259,7 @@ void putname(struct filename *name)
 		__putname(name);
 }
 
-static int check_acl(struct inode *inode, int mask)
+static int check_acl(struct user_namespace *user_ns, struct inode *inode, int mask)
 {
 #ifdef CONFIG_FS_POSIX_ACL
 	struct posix_acl *acl;
@@ -271,14 +271,14 @@ static int check_acl(struct inode *inode, int mask)
 		/* no ->get_acl() calls in RCU mode... */
 		if (is_uncached_acl(acl))
 			return -ECHILD;
-	        return posix_acl_permission(inode, acl, mask);
+	        return posix_acl_permission(user_ns, inode, acl, mask);
 	}
 
 	acl = get_acl(inode, ACL_TYPE_ACCESS);
 	if (IS_ERR(acl))
 		return PTR_ERR(acl);
 	if (acl) {
-	        int error = posix_acl_permission(inode, acl, mask);
+	        int error = posix_acl_permission(user_ns, inode, acl, mask);
 	        posix_acl_release(acl);
 	        return error;
 	}
@@ -293,12 +293,14 @@ static int check_acl(struct inode *inode, int mask)
  * Note that the POSIX ACL check cares about the MAY_NOT_BLOCK bit,
  * for RCU walking.
  */
-static int acl_permission_check(struct inode *inode, int mask)
+static int acl_permission_check(struct user_namespace *user_ns, struct inode *inode, int mask)
 {
 	unsigned int mode = inode->i_mode;
+	kuid_t i_uid;
 
 	/* Are we the owner? If so, ACL's don't matter */
-	if (likely(uid_eq(current_fsuid(), inode->i_uid))) {
+	i_uid = i_uid_into_mnt(user_ns, inode);
+	if (likely(uid_eq(current_fsuid(), i_uid))) {
 		mask &= 7;
 		mode >>= 6;
 		return (mask & ~mode) ? -EACCES : 0;
@@ -306,7 +308,7 @@ static int acl_permission_check(struct inode *inode, int mask)
 
 	/* Do we have ACL's? */
 	if (IS_POSIXACL(inode) && (mode & S_IRWXG)) {
-		int error = check_acl(inode, mask);
+		int error = check_acl(user_ns, inode, mask);
 		if (error != -EAGAIN)
 			return error;
 	}
@@ -320,7 +322,8 @@ static int acl_permission_check(struct inode *inode, int mask)
 	 * about? Need to check group ownership if so.
 	 */
 	if (mask & (mode ^ (mode >> 3))) {
-		if (in_group_p(inode->i_gid))
+		kgid_t kgid = i_gid_into_mnt(user_ns, inode);
+		if (in_group_p(kgid))
 			mode >>= 3;
 	}
 
@@ -329,7 +332,7 @@ static int acl_permission_check(struct inode *inode, int mask)
 }
 
 /**
- * generic_permission -  check for access rights on a Posix-like filesystem
+ * mapped_generic_permission -  check for access rights on a Posix-like filesystem
  * @inode:	inode to check access rights for
  * @mask:	right to check for (%MAY_READ, %MAY_WRITE, %MAY_EXEC,
  *		%MAY_NOT_BLOCK ...)
@@ -343,24 +346,25 @@ static int acl_permission_check(struct inode *inode, int mask)
  * request cannot be satisfied (eg. requires blocking or too much complexity).
  * It would then be called again in ref-walk mode.
  */
-int generic_permission(struct inode *inode, int mask)
+int mapped_generic_permission(struct user_namespace *user_ns, struct inode *inode,
+			  int mask)
 {
 	int ret;
 
 	/*
 	 * Do the basic permission checks.
 	 */
-	ret = acl_permission_check(inode, mask);
+	ret = acl_permission_check(user_ns, inode, mask);
 	if (ret != -EACCES)
 		return ret;
 
 	if (S_ISDIR(inode->i_mode)) {
 		/* DACs are overridable for directories */
 		if (!(mask & MAY_WRITE))
-			if (capable_wrt_inode_uidgid(inode,
-						     CAP_DAC_READ_SEARCH))
+			if (capable_wrt_mapped_inode_uidgid(user_ns, inode,
+							    CAP_DAC_READ_SEARCH))
 				return 0;
-		if (capable_wrt_inode_uidgid(inode, CAP_DAC_OVERRIDE))
+		if (capable_wrt_mapped_inode_uidgid(user_ns, inode, CAP_DAC_OVERRIDE))
 			return 0;
 		return -EACCES;
 	}
@@ -370,7 +374,8 @@ int generic_permission(struct inode *inode, int mask)
 	 */
 	mask &= MAY_READ | MAY_WRITE | MAY_EXEC;
 	if (mask == MAY_READ)
-		if (capable_wrt_inode_uidgid(inode, CAP_DAC_READ_SEARCH))
+		if (capable_wrt_mapped_inode_uidgid(user_ns, inode,
+						    CAP_DAC_READ_SEARCH))
 			return 0;
 	/*
 	 * Read/write DACs are always overridable.
@@ -378,11 +383,18 @@ int generic_permission(struct inode *inode, int mask)
 	 * at least one exec bit set.
 	 */
 	if (!(mask & MAY_EXEC) || (inode->i_mode & S_IXUGO))
-		if (capable_wrt_inode_uidgid(inode, CAP_DAC_OVERRIDE))
+		if (capable_wrt_mapped_inode_uidgid(user_ns, inode,
+						    CAP_DAC_OVERRIDE))
 			return 0;
 
 	return -EACCES;
 }
+EXPORT_SYMBOL(mapped_generic_permission);
+
+int generic_permission(struct inode *inode, int mask)
+{
+	return mapped_generic_permission(&init_user_ns, inode, mask);
+}
 EXPORT_SYMBOL(generic_permission);
 
 /*
@@ -391,7 +403,7 @@ EXPORT_SYMBOL(generic_permission);
  * flag in inode->i_opflags, that says "this has not special
  * permission function, use the fast case".
  */
-static inline int do_inode_permission(struct inode *inode, int mask)
+static inline int do_inode_permission(struct user_namespace *user_ns, struct inode *inode, int mask)
 {
 	if (unlikely(!(inode->i_opflags & IOP_FASTPERM))) {
 		if (likely(inode->i_op->permission))
@@ -402,7 +414,7 @@ static inline int do_inode_permission(struct inode *inode, int mask)
 		inode->i_opflags |= IOP_FASTPERM;
 		spin_unlock(&inode->i_lock);
 	}
-	return generic_permission(inode, mask);
+	return mapped_generic_permission(user_ns, inode, mask);
 }
 
 /**
@@ -426,7 +438,9 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
 }
 
 /**
- * inode_permission - Check for access rights to a given inode
+ * mapped_inode_permission - Check for access rights to a given inode as seen from
+ *			 a given user namespace
+ * @userns: The user namespace the inode is seen from
  * @inode: Inode to check permission on
  * @mask: Right to check for (%MAY_READ, %MAY_WRITE, %MAY_EXEC)
  *
@@ -436,7 +450,7 @@ static int sb_permission(struct super_block *sb, struct inode *inode, int mask)
  *
  * When checking for MAY_APPEND, MAY_WRITE must also be set in @mask.
  */
-int inode_permission(struct inode *inode, int mask)
+int mapped_inode_permission(struct user_namespace *user_ns, struct inode *inode, int mask)
 {
 	int retval;
 
@@ -460,7 +474,7 @@ int inode_permission(struct inode *inode, int mask)
 			return -EACCES;
 	}
 
-	retval = do_inode_permission(inode, mask);
+	retval = do_inode_permission(user_ns, inode, mask);
 	if (retval)
 		return retval;
 
@@ -470,6 +484,23 @@ int inode_permission(struct inode *inode, int mask)
 
 	return security_inode_permission(inode, mask);
 }
+EXPORT_SYMBOL(mapped_inode_permission);
+
+/**
+ * inode_permission - Check for access rights to a given inode
+ * @inode: Inode to check permission on
+ * @mask: Right to check for (%MAY_READ, %MAY_WRITE, %MAY_EXEC)
+ *
+ * Check for read/write/execute permissions on an inode.  We use fs[ug]id for
+ * this, letting us set arbitrary permissions for filesystem access without
+ * changing the "normal" UIDs which are used for other things.
+ *
+ * When checking for MAY_APPEND, MAY_WRITE must also be set in @mask.
+ */
+int inode_permission(struct inode *inode, int mask)
+{
+	return mapped_inode_permission(&init_user_ns, inode, mask);
+}
 EXPORT_SYMBOL(inode_permission);
 
 /**
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 95882b3f5f62..f15b6ad35ec3 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -345,10 +345,12 @@ EXPORT_SYMBOL(posix_acl_from_mode);
  * by the acl. Returns -E... otherwise.
  */
 int
-posix_acl_permission(struct inode *inode, const struct posix_acl *acl, int want)
+posix_acl_permission(struct user_namespace *user_ns, struct inode *inode, const struct posix_acl *acl, int want)
 {
 	const struct posix_acl_entry *pa, *pe, *mask_obj;
 	int found = 0;
+	kuid_t uid;
+	kgid_t gid;
 
 	want &= MAY_READ | MAY_WRITE | MAY_EXEC;
 
@@ -356,22 +358,26 @@ posix_acl_permission(struct inode *inode, const struct posix_acl *acl, int want)
                 switch(pa->e_tag) {
                         case ACL_USER_OBJ:
 				/* (May have been checked already) */
-				if (uid_eq(inode->i_uid, current_fsuid()))
+				uid = i_uid_into_mnt(user_ns, inode);
+				if (uid_eq(uid, current_fsuid()))
                                         goto check_perm;
                                 break;
                         case ACL_USER:
-				if (uid_eq(pa->e_uid, current_fsuid()))
+				uid = kuid_into_mnt(user_ns, pa->e_uid);
+				if (uid_eq(uid, current_fsuid()))
                                         goto mask;
 				break;
                         case ACL_GROUP_OBJ:
-                                if (in_group_p(inode->i_gid)) {
+				gid = i_gid_into_mnt(user_ns, inode);
+                                if (in_group_p(gid)) {
 					found = 1;
 					if ((pa->e_perm & want) == want)
 						goto mask;
                                 }
 				break;
                         case ACL_GROUP:
-				if (in_group_p(pa->e_gid)) {
+				gid = kgid_into_mnt(user_ns, pa->e_gid);
+				if (in_group_p(gid)) {
 					found = 1;
 					if ((pa->e_perm & want) == want)
 						goto mask;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8a891b80d0b4..750ca4b3d89f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2820,7 +2820,9 @@ static inline int bmap(struct inode *inode,  sector_t *block)
 
 extern int notify_change(struct dentry *, struct iattr *, struct inode **);
 extern int inode_permission(struct inode *, int);
+extern int mapped_inode_permission(struct user_namespace *, struct inode *, int);
 extern int generic_permission(struct inode *, int);
+extern int mapped_generic_permission(struct user_namespace *, struct inode *, int);
 extern int __check_sticky(struct inode *dir, struct inode *inode);
 
 static inline bool execute_ok(struct inode *inode)
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 90797f1b421d..8276baefed13 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -15,6 +15,8 @@
 #include <linux/refcount.h>
 #include <uapi/linux/posix_acl.h>
 
+struct user_namespace;
+
 struct posix_acl_entry {
 	short			e_tag;
 	unsigned short		e_perm;
@@ -62,7 +64,7 @@ posix_acl_release(struct posix_acl *acl)
 extern void posix_acl_init(struct posix_acl *, int);
 extern struct posix_acl *posix_acl_alloc(int, gfp_t);
 extern int posix_acl_valid(struct user_namespace *, const struct posix_acl *);
-extern int posix_acl_permission(struct inode *, const struct posix_acl *, int);
+extern int posix_acl_permission(struct user_namespace *, struct inode *, const struct posix_acl *, int);
 extern struct posix_acl *posix_acl_from_mode(umode_t, gfp_t);
 extern int posix_acl_equiv_mode(const struct posix_acl *, umode_t *);
 extern int __posix_acl_create(struct posix_acl **, gfp_t, umode_t *);
-- 
2.29.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
