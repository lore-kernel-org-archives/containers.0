Return-Path: <SRS0=YWEV=GP=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A06D3C433DB
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:14:24 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 427872311A
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:14:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 427872311A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 0FEBF86C0A;
	Tue, 12 Jan 2021 22:14:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id k4GfLJzqGgv8; Tue, 12 Jan 2021 22:14:22 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 09ABC86F8C;
	Tue, 12 Jan 2021 22:14:22 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id EA907C0893;
	Tue, 12 Jan 2021 22:14:21 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D14E5C013A
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:14:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id BB28281B81
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:14:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 6mwuFDZ5QYPu
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:14:19 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by whitealder.osuosl.org (Postfix) with ESMTPS id AFA67817F9
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:14:19 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kzRlS-0003bd-Sd; Tue, 12 Jan 2021 22:03:47 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v5 23/42] open: handle idmapped mounts
Date: Tue, 12 Jan 2021 23:01:05 +0100
Message-Id: <20210112220124.837960-24-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210112220124.837960-1-christian.brauner@ubuntu.com>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=YKSd0FdGGLgCSTeDw7b6sTvRU/kXPfMpmc0z0c+ceJs=;
 m=AxYKhdYprzCvMt0kry+LbZ/gM5Cfh7tpdts7ieUNsD0=;
 p=c80yLYHWwcOTQmoErBkESbLUftwV7AnXz3vjhvFqrkU=;
 g=84e0417ac78ec9ee77a9341d2daa78d7d94f34c8
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCX/4YtwAKCRCRxhvAZXjconyxAPsG/hp
 JWZxsQjrINS8IOFAvVcvXwvob/K7Zf8blrWRz0QD/b4f9FIXMTluFOVMjbOFVPWoZGN/zTSM4fsOy
 q2wulg0=
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

For core file operations such as changing directories or chrooting,
determining file access, changing mode or ownership the vfs will verify
that the caller is privileged over the inode. Extend the various helpers
to handle idmapped mounts. If the inode is accessed through an idmapped
mount it is mapped according to the mount's user namespace. Afterwards
the permissions checks are identical to non-idmapped mounts. When
changing file ownership we need to map the uid and gid from the mount's
user namespace. If the initial user namespace is passed nothing changes
so non-idmapped mounts will see identical behavior as before.

Cc: Christoph Hellwig <hch@lst.de>
Cc: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
unchanged

/* v3 */
- David Howells <dhowells@redhat.com>:
  - Remove mnt_idmapped() check after removing mnt_idmapped() helper in earlier
    patches.

/* v4 */
- Serge Hallyn <serge@hallyn.com>:
  - Use "mnt_userns" to refer to a vfsmount's userns everywhere to make
    terminology consistent.

/* v5 */
base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837

- Christoph Hellwig <hch@lst.de>:
  - Use new file_userns_helper().
---
 fs/open.c | 29 ++++++++++++++++++++++-------
 1 file changed, 22 insertions(+), 7 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index a9f3a3b46ef1..ac26f0a363a0 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -401,6 +401,7 @@ static const struct cred *access_override_creds(void)
 
 static long do_faccessat(int dfd, const char __user *filename, int mode, int flags)
 {
+	struct user_namespace *mnt_userns;
 	struct path path;
 	struct inode *inode;
 	int res;
@@ -441,7 +442,8 @@ static long do_faccessat(int dfd, const char __user *filename, int mode, int fla
 			goto out_path_release;
 	}
 
-	res = inode_permission(&init_user_ns, inode, mode | MAY_ACCESS);
+	mnt_userns = mnt_user_ns(path.mnt);
+	res = inode_permission(mnt_userns, inode, mode | MAY_ACCESS);
 	/* SuS v2 requires we report a read only fs too */
 	if (res || !(mode & S_IWOTH) || special_file(inode->i_mode))
 		goto out_path_release;
@@ -489,6 +491,7 @@ SYSCALL_DEFINE2(access, const char __user *, filename, int, mode)
 
 SYSCALL_DEFINE1(chdir, const char __user *, filename)
 {
+	struct user_namespace *mnt_userns;
 	struct path path;
 	int error;
 	unsigned int lookup_flags = LOOKUP_FOLLOW | LOOKUP_DIRECTORY;
@@ -497,7 +500,8 @@ SYSCALL_DEFINE1(chdir, const char __user *, filename)
 	if (error)
 		goto out;
 
-	error = inode_permission(&init_user_ns, path.dentry->d_inode, MAY_EXEC | MAY_CHDIR);
+	mnt_userns = mnt_user_ns(path.mnt);
+	error = inode_permission(mnt_userns, path.dentry->d_inode, MAY_EXEC | MAY_CHDIR);
 	if (error)
 		goto dput_and_out;
 
@@ -515,6 +519,7 @@ SYSCALL_DEFINE1(chdir, const char __user *, filename)
 
 SYSCALL_DEFINE1(fchdir, unsigned int, fd)
 {
+	struct user_namespace *mnt_userns;
 	struct fd f = fdget_raw(fd);
 	int error;
 
@@ -526,7 +531,8 @@ SYSCALL_DEFINE1(fchdir, unsigned int, fd)
 	if (!d_can_lookup(f.file->f_path.dentry))
 		goto out_putf;
 
-	error = inode_permission(&init_user_ns, file_inode(f.file), MAY_EXEC | MAY_CHDIR);
+	mnt_userns = file_user_ns(f.file);
+	error = inode_permission(mnt_userns, file_inode(f.file), MAY_EXEC | MAY_CHDIR);
 	if (!error)
 		set_fs_pwd(current->fs, &f.file->f_path);
 out_putf:
@@ -537,6 +543,7 @@ SYSCALL_DEFINE1(fchdir, unsigned int, fd)
 
 SYSCALL_DEFINE1(chroot, const char __user *, filename)
 {
+	struct user_namespace *mnt_userns;
 	struct path path;
 	int error;
 	unsigned int lookup_flags = LOOKUP_FOLLOW | LOOKUP_DIRECTORY;
@@ -545,7 +552,8 @@ SYSCALL_DEFINE1(chroot, const char __user *, filename)
 	if (error)
 		goto out;
 
-	error = inode_permission(&init_user_ns, path.dentry->d_inode, MAY_EXEC | MAY_CHDIR);
+	mnt_userns = mnt_user_ns(path.mnt);
+	error = inode_permission(mnt_userns, path.dentry->d_inode, MAY_EXEC | MAY_CHDIR);
 	if (error)
 		goto dput_and_out;
 
@@ -570,6 +578,7 @@ SYSCALL_DEFINE1(chroot, const char __user *, filename)
 
 int chmod_common(const struct path *path, umode_t mode)
 {
+	struct user_namespace *mnt_userns;
 	struct inode *inode = path->dentry->d_inode;
 	struct inode *delegated_inode = NULL;
 	struct iattr newattrs;
@@ -585,7 +594,8 @@ int chmod_common(const struct path *path, umode_t mode)
 		goto out_unlock;
 	newattrs.ia_mode = (mode & S_IALLUGO) | (inode->i_mode & ~S_IALLUGO);
 	newattrs.ia_valid = ATTR_MODE | ATTR_CTIME;
-	error = notify_change(&init_user_ns, path->dentry, &newattrs, &delegated_inode);
+	mnt_userns = mnt_user_ns(path->mnt);
+	error = notify_change(mnt_userns, path->dentry, &newattrs, &delegated_inode);
 out_unlock:
 	inode_unlock(inode);
 	if (delegated_inode) {
@@ -646,6 +656,7 @@ SYSCALL_DEFINE2(chmod, const char __user *, filename, umode_t, mode)
 
 int chown_common(const struct path *path, uid_t user, gid_t group)
 {
+	struct user_namespace *mnt_userns;
 	struct inode *inode = path->dentry->d_inode;
 	struct inode *delegated_inode = NULL;
 	int error;
@@ -656,6 +667,10 @@ int chown_common(const struct path *path, uid_t user, gid_t group)
 	uid = make_kuid(current_user_ns(), user);
 	gid = make_kgid(current_user_ns(), group);
 
+	mnt_userns = mnt_user_ns(path->mnt);
+	uid = kuid_from_mnt(mnt_userns, uid);
+	gid = kgid_from_mnt(mnt_userns, gid);
+
 retry_deleg:
 	newattrs.ia_valid =  ATTR_CTIME;
 	if (user != (uid_t) -1) {
@@ -676,7 +691,7 @@ int chown_common(const struct path *path, uid_t user, gid_t group)
 	inode_lock(inode);
 	error = security_path_chown(path, uid, gid);
 	if (!error)
-		error = notify_change(&init_user_ns, path->dentry, &newattrs, &delegated_inode);
+		error = notify_change(mnt_userns, path->dentry, &newattrs, &delegated_inode);
 	inode_unlock(inode);
 	if (delegated_inode) {
 		error = break_deleg_wait(&delegated_inode);
@@ -1137,7 +1152,7 @@ struct file *filp_open(const char *filename, int flags, umode_t mode)
 {
 	struct filename *name = getname_kernel(filename);
 	struct file *file = ERR_CAST(name);
-	
+
 	if (!IS_ERR(name)) {
 		file = file_open_name(name, flags, mode);
 		putname(name);
-- 
2.30.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
