Return-Path: <SRS0=YWEV=GP=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09DD8C433DB
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:16:26 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AC02923122
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:16:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC02923122
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 8A08D8560F;
	Tue, 12 Jan 2021 22:16:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yCHza6uVDakQ; Tue, 12 Jan 2021 22:16:24 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 3431E85620;
	Tue, 12 Jan 2021 22:16:24 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 22B17C0893;
	Tue, 12 Jan 2021 22:16:24 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 43865C013A
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:16:23 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 31DCE860EF
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:16:23 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id MlJzgu-4B9aF
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:16:22 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 610E9847C4
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:16:22 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kzRlg-0003bd-7c; Tue, 12 Jan 2021 22:04:00 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v5 28/42] init: handle idmapped mounts
Date: Tue, 12 Jan 2021 23:01:10 +0100
Message-Id: <20210112220124.837960-29-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210112220124.837960-1-christian.brauner@ubuntu.com>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=K1Mmb+2iBnpojBmIU4SJaafXPX8O2CFx1CDw+utpuOU=;
 m=xvNrFhQ1y2dLwavhTa/L5ycYJlSyn9UahBsh8fnhzMg=;
 p=T84ylcJgm7jErZy8A3A4JEJzeX2Sy/VPnkeSnFEr7Mg=;
 g=463fa33c5c532e8c7af638fb27b57db52004da88
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCX/4YuAAKCRCRxhvAZXjcop8AAQCXD3D
 4M62CMgvA6omdkdSEWaz7FL2OLzNdBtMvfUobNgEA/4AMHFZRBaM4sgnQsdBwRx8Ot748zQ6VHemO
 ok8YmwI=
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

Enable the init helpers to handle idmapped mounts by passing down the
mount's user namespace. If the initial user namespace is passed nothing
changes so non-idmapped mounts will see identical behavior as before.

Cc: Christoph Hellwig <hch@lst.de>
Cc: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
patch introduced

/* v3 */
unchanged

/* v4 */
unchanged

/* v5 */
base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837
---
 fs/init.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/fs/init.c b/fs/init.c
index 06d8e52ce18e..1db2b392e4e6 100644
--- a/fs/init.c
+++ b/fs/init.c
@@ -49,7 +49,7 @@ int __init init_chdir(const char *filename)
 	error = kern_path(filename, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &path);
 	if (error)
 		return error;
-	error = inode_permission(&init_user_ns, path.dentry->d_inode,
+	error = inode_permission(mnt_user_ns(path.mnt), path.dentry->d_inode,
 				 MAY_EXEC | MAY_CHDIR);
 	if (!error)
 		set_fs_pwd(current->fs, &path);
@@ -65,7 +65,7 @@ int __init init_chroot(const char *filename)
 	error = kern_path(filename, LOOKUP_FOLLOW | LOOKUP_DIRECTORY, &path);
 	if (error)
 		return error;
-	error = inode_permission(&init_user_ns, path.dentry->d_inode,
+	error = inode_permission(mnt_user_ns(path.mnt), path.dentry->d_inode,
 				 MAY_EXEC | MAY_CHDIR);
 	if (error)
 		goto dput_and_out;
@@ -120,7 +120,7 @@ int __init init_eaccess(const char *filename)
 	error = kern_path(filename, LOOKUP_FOLLOW, &path);
 	if (error)
 		return error;
-	error = inode_permission(&init_user_ns, d_inode(path.dentry),
+	error = inode_permission(mnt_user_ns(path.mnt), d_inode(path.dentry),
 				 MAY_ACCESS);
 	path_put(&path);
 	return error;
@@ -160,8 +160,8 @@ int __init init_mknod(const char *filename, umode_t mode, unsigned int dev)
 		mode &= ~current_umask();
 	error = security_path_mknod(&path, dentry, mode, dev);
 	if (!error)
-		error = vfs_mknod(&init_user_ns, path.dentry->d_inode, dentry,
-				  mode, new_decode_dev(dev));
+		error = vfs_mknod(mnt_user_ns(path.mnt), path.dentry->d_inode,
+				  dentry, mode, new_decode_dev(dev));
 	done_path_create(&path, dentry);
 	return error;
 }
@@ -170,6 +170,7 @@ int __init init_link(const char *oldname, const char *newname)
 {
 	struct dentry *new_dentry;
 	struct path old_path, new_path;
+	struct user_namespace *mnt_userns;
 	int error;
 
 	error = kern_path(oldname, 0, &old_path);
@@ -184,14 +185,15 @@ int __init init_link(const char *oldname, const char *newname)
 	error = -EXDEV;
 	if (old_path.mnt != new_path.mnt)
 		goto out_dput;
-	error = may_linkat(&init_user_ns, &old_path);
+	mnt_userns = mnt_user_ns(new_path.mnt);
+	error = may_linkat(mnt_userns, &old_path);
 	if (unlikely(error))
 		goto out_dput;
 	error = security_path_link(old_path.dentry, &new_path, new_dentry);
 	if (error)
 		goto out_dput;
-	error = vfs_link(old_path.dentry, &init_user_ns,
-			 new_path.dentry->d_inode, new_dentry, NULL);
+	error = vfs_link(old_path.dentry, mnt_userns, new_path.dentry->d_inode,
+			 new_dentry, NULL);
 out_dput:
 	done_path_create(&new_path, new_dentry);
 out:
@@ -210,7 +212,8 @@ int __init init_symlink(const char *oldname, const char *newname)
 		return PTR_ERR(dentry);
 	error = security_path_symlink(&path, dentry, oldname);
 	if (!error)
-		error = vfs_symlink(&init_user_ns, path.dentry->d_inode, dentry, oldname);
+		error = vfs_symlink(mnt_user_ns(path.mnt), path.dentry->d_inode,
+				    dentry, oldname);
 	done_path_create(&path, dentry);
 	return error;
 }
@@ -233,7 +236,8 @@ int __init init_mkdir(const char *pathname, umode_t mode)
 		mode &= ~current_umask();
 	error = security_path_mkdir(&path, dentry, mode);
 	if (!error)
-		error = vfs_mkdir(&init_user_ns, path.dentry->d_inode, dentry, mode);
+		error = vfs_mkdir(mnt_user_ns(path.mnt), path.dentry->d_inode,
+				  dentry, mode);
 	done_path_create(&path, dentry);
 	return error;
 }
-- 
2.30.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
