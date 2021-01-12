Return-Path: <SRS0=YWEV=GP=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A034DC433E0
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:14:42 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 305F72311A
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:14:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 305F72311A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id ED6E386FB0;
	Tue, 12 Jan 2021 22:14:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VgDZX3Ms+EkV; Tue, 12 Jan 2021 22:14:41 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 3236D86A07;
	Tue, 12 Jan 2021 22:14:41 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1FC97C0893;
	Tue, 12 Jan 2021 22:14:41 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1C5C6C013A
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:14:40 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 1571286B58
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:14:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id L6IHgcVwUw5k
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:14:38 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by hemlock.osuosl.org (Postfix) with ESMTPS id CC58286A07
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:14:38 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kzRlP-0003bd-Ug; Tue, 12 Jan 2021 22:03:44 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v5 22/42] open: handle idmapped mounts in do_truncate()
Date: Tue, 12 Jan 2021 23:01:04 +0100
Message-Id: <20210112220124.837960-23-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210112220124.837960-1-christian.brauner@ubuntu.com>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=luWr+VA/K8XJzgT4gX4nqMzEuQJylBRV32CcnmZlQJ8=;
 m=zihUaivpqCA4dvvv7oCB94rDjzWEIICAfJJq/K4EDho=;
 p=KfbmBmgWHl85flKsZy/AbgNujB/mqkPONcX1pd32kPc=;
 g=7e679aa791c5fb9885f599cc34e763b93247e60a
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCX/4YtwAKCRCRxhvAZXjcoqZdAP48OLZ
 aDDiOtxK0vClMT+iUjL5k3mIGJsk5lM/T5tH6/QD+KWIm8W5oXr/5hZUtS+8tH3pBZHZJzfiy1jyl
 hF94pA0=
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>, linux-xfs@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, Alban Crequy <alban@kinvolk.io>,
 linux-integrity@vger.kernel.org,
 Linus Torvalds <torvalds@linux-foundation.org>, Todd Kjos <tkjos@google.com>
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

When truncating files the vfs will verify that the caller is privileged
over the inode. Extend it to handle idmapped mounts. If the inode is
accessed through an idmapped mount it is mapped according to the mount's
user namespace. Afterwards the permissions checks are identical to
non-idmapped mounts. If the initial user namespace is passed nothing
changes so non-idmapped mounts will see identical behavior as before.

Cc: Christoph Hellwig <hch@lst.de>
Cc: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
unchanged

/* v3 */
unchanged

/* v4 */
- Serge Hallyn <serge@hallyn.com>:
  - Use "mnt_userns" to refer to a vfsmount's userns everywhere to make
    terminology consistent.

/* v5 */
base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837

- Christoph Hellwig <hch@lst.de>:
  - Use new file_userns_helper().
---
 fs/coredump.c      | 14 ++++++++++----
 fs/inode.c         | 13 +++++++++----
 fs/namei.c         |  6 +++---
 fs/open.c          | 21 +++++++++++++--------
 include/linux/fs.h |  4 ++--
 5 files changed, 37 insertions(+), 21 deletions(-)

diff --git a/fs/coredump.c b/fs/coredump.c
index a2f6ecc8e345..929d3f3bbe21 100644
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -703,6 +703,7 @@ void do_coredump(const kernel_siginfo_t *siginfo)
 			goto close_fail;
 		}
 	} else {
+		struct user_namespace *mnt_userns;
 		struct inode *inode;
 		int open_flags = O_CREAT | O_RDWR | O_NOFOLLOW |
 				 O_LARGEFILE | O_EXCL;
@@ -780,13 +781,14 @@ void do_coredump(const kernel_siginfo_t *siginfo)
 		 * a process dumps core while its cwd is e.g. on a vfat
 		 * filesystem.
 		 */
-		if (!uid_eq(inode->i_uid, current_fsuid()))
+		mnt_userns = file_user_ns(cprm.file);
+		if (!uid_eq(i_uid_into_mnt(mnt_userns, inode), current_fsuid()))
 			goto close_fail;
 		if ((inode->i_mode & 0677) != 0600)
 			goto close_fail;
 		if (!(cprm.file->f_mode & FMODE_CAN_WRITE))
 			goto close_fail;
-		if (do_truncate(cprm.file->f_path.dentry, 0, 0, cprm.file))
+		if (do_truncate(mnt_userns, cprm.file->f_path.dentry, 0, 0, cprm.file))
 			goto close_fail;
 	}
 
@@ -930,8 +932,12 @@ void dump_truncate(struct coredump_params *cprm)
 
 	if (file->f_op->llseek && file->f_op->llseek != no_llseek) {
 		offset = file->f_op->llseek(file, 0, SEEK_CUR);
-		if (i_size_read(file->f_mapping->host) < offset)
-			do_truncate(file->f_path.dentry, offset, 0, file);
+		if (i_size_read(file->f_mapping->host) < offset) {
+			struct user_namespace *mnt_userns;
+
+			mnt_userns = file_user_ns(file);
+			do_truncate(mnt_userns, file->f_path.dentry, offset, 0, file);
+		}
 	}
 }
 EXPORT_SYMBOL(dump_truncate);
diff --git a/fs/inode.c b/fs/inode.c
index 46116ef44c9f..aefcfd31a9c7 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1903,7 +1903,8 @@ int dentry_needs_remove_privs(struct dentry *dentry)
 	return mask;
 }
 
-static int __remove_privs(struct dentry *dentry, int kill)
+static int __remove_privs(struct user_namespace *mnt_userns, struct dentry *dentry,
+			  int kill)
 {
 	struct iattr newattrs;
 
@@ -1912,7 +1913,7 @@ static int __remove_privs(struct dentry *dentry, int kill)
 	 * Note we call this on write, so notify_change will not
 	 * encounter any conflicting delegations:
 	 */
-	return notify_change(&init_user_ns, dentry, &newattrs, NULL);
+	return notify_change(mnt_userns, dentry, &newattrs, NULL);
 }
 
 /*
@@ -1938,8 +1939,12 @@ int file_remove_privs(struct file *file)
 	kill = dentry_needs_remove_privs(dentry);
 	if (kill < 0)
 		return kill;
-	if (kill)
-		error = __remove_privs(dentry, kill);
+	if (kill) {
+		struct user_namespace *mnt_userns;
+
+		mnt_userns = file_user_ns(file);
+		error = __remove_privs(mnt_userns, dentry, kill);
+	}
 	if (!error)
 		inode_has_no_xattr(inode);
 
diff --git a/fs/namei.c b/fs/namei.c
index e085831c6b85..016d52fda656 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3013,9 +3013,9 @@ static int handle_truncate(struct file *filp)
 	if (!error)
 		error = security_path_truncate(path);
 	if (!error) {
-		error = do_truncate(path->dentry, 0,
-				    ATTR_MTIME|ATTR_CTIME|ATTR_OPEN,
-				    filp);
+		error = do_truncate(file_user_ns(filp),
+				    path->dentry, 0,
+				    ATTR_MTIME | ATTR_CTIME | ATTR_OPEN, filp);
 	}
 	put_write_access(inode);
 	return error;
diff --git a/fs/open.c b/fs/open.c
index bae00ee63af8..a9f3a3b46ef1 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -35,8 +35,8 @@
 
 #include "internal.h"
 
-int do_truncate(struct dentry *dentry, loff_t length, unsigned int time_attrs,
-	struct file *filp)
+int do_truncate(struct user_namespace *mnt_userns, struct dentry *dentry,
+		loff_t length, unsigned int time_attrs, struct file *filp)
 {
 	int ret;
 	struct iattr newattrs;
@@ -61,13 +61,14 @@ int do_truncate(struct dentry *dentry, loff_t length, unsigned int time_attrs,
 
 	inode_lock(dentry->d_inode);
 	/* Note any delegations or leases have already been broken: */
-	ret = notify_change(&init_user_ns, dentry, &newattrs, NULL);
+	ret = notify_change(mnt_userns, dentry, &newattrs, NULL);
 	inode_unlock(dentry->d_inode);
 	return ret;
 }
 
 long vfs_truncate(const struct path *path, loff_t length)
 {
+	struct user_namespace *mnt_userns;
 	struct inode *inode;
 	long error;
 
@@ -83,7 +84,8 @@ long vfs_truncate(const struct path *path, loff_t length)
 	if (error)
 		goto out;
 
-	error = inode_permission(&init_user_ns, inode, MAY_WRITE);
+	mnt_userns = mnt_user_ns(path->mnt);
+	error = inode_permission(mnt_userns, inode, MAY_WRITE);
 	if (error)
 		goto mnt_drop_write_and_out;
 
@@ -107,7 +109,7 @@ long vfs_truncate(const struct path *path, loff_t length)
 	if (!error)
 		error = security_path_truncate(path);
 	if (!error)
-		error = do_truncate(path->dentry, length, 0, NULL);
+		error = do_truncate(mnt_userns, path->dentry, length, 0, NULL);
 
 put_write_and_out:
 	put_write_access(inode);
@@ -186,13 +188,16 @@ long do_sys_ftruncate(unsigned int fd, loff_t length, int small)
 	/* Check IS_APPEND on real upper inode */
 	if (IS_APPEND(file_inode(f.file)))
 		goto out_putf;
-
 	sb_start_write(inode->i_sb);
 	error = locks_verify_truncate(inode, f.file, length);
 	if (!error)
 		error = security_path_truncate(&f.file->f_path);
-	if (!error)
-		error = do_truncate(dentry, length, ATTR_MTIME|ATTR_CTIME, f.file);
+	if (!error) {
+		struct user_namespace *mnt_userns;
+
+		mnt_userns = file_user_ns(f.file);
+		error = do_truncate(mnt_userns, dentry, length, ATTR_MTIME | ATTR_CTIME, f.file);
+	}
 	sb_end_write(inode->i_sb);
 out_putf:
 	fdput(f);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e74995558c31..168b8d3f5afb 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2584,8 +2584,8 @@ struct filename {
 static_assert(offsetof(struct filename, iname) % sizeof(long) == 0);
 
 extern long vfs_truncate(const struct path *, loff_t);
-extern int do_truncate(struct dentry *, loff_t start, unsigned int time_attrs,
-		       struct file *filp);
+extern int do_truncate(struct user_namespace *, struct dentry *, loff_t start,
+		       unsigned int time_attrs, struct file *filp);
 extern int vfs_fallocate(struct file *file, int mode, loff_t offset,
 			loff_t len);
 extern long do_sys_open(int dfd, const char __user *filename, int flags,
-- 
2.30.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
