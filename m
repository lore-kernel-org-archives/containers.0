Return-Path: <SRS0=+MRp=FC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28207C63777
	for <containers@archiver.kernel.org>; Sat, 28 Nov 2020 21:54:07 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B05D7208CA
	for <containers@archiver.kernel.org>; Sat, 28 Nov 2020 21:54:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B05D7208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 3B76687826;
	Sat, 28 Nov 2020 21:54:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QUg0Z+6f0Ute; Sat, 28 Nov 2020 21:54:05 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 7549D8780D;
	Sat, 28 Nov 2020 21:54:05 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 63086C0891;
	Sat, 28 Nov 2020 21:54:05 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 49558C0052
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 21:54:04 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 3752D870B3
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 21:54:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id f9w2dEG2zJWQ
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 21:54:03 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 8D9C4870B0
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 21:54:03 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kj83F-0002aM-Ku; Sat, 28 Nov 2020 21:46:41 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v3 25/38] init: handle idmapped mounts
Date: Sat, 28 Nov 2020 22:35:14 +0100
Message-Id: <20201128213527.2669807-26-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20201128213527.2669807-1-christian.brauner@ubuntu.com>
References: <20201128213527.2669807-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Cc: Andy Lutomirski <luto@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Lennart Poettering <lennart@poettering.net>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>, fstests@vger.kernel.org,
 linux-security-module@vger.kernel.org,
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

Enable the init helpers to handle idmapped mounts by passing down the mount's
user namespace. If the initial user namespace is passed nothing changes so
non-idmapped mounts will see identical behavior as before.

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
---
 fs/init.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/fs/init.c b/fs/init.c
index 76f493600030..41adfee75763 100644
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
@@ -190,7 +190,7 @@ int __init init_link(const char *oldname, const char *newname)
 	error = security_path_link(old_path.dentry, &new_path, new_dentry);
 	if (error)
 		goto out_dput;
-	error = vfs_link(old_path.dentry, &init_user_ns, 
+	error = vfs_link(old_path.dentry, mnt_user_ns(new_path.mnt),
 			 new_path.dentry->d_inode, new_dentry, NULL);
 out_dput:
 	done_path_create(&new_path, new_dentry);
@@ -210,7 +210,8 @@ int __init init_symlink(const char *oldname, const char *newname)
 		return PTR_ERR(dentry);
 	error = security_path_symlink(&path, dentry, oldname);
 	if (!error)
-		error = vfs_symlink(&init_user_ns, path.dentry->d_inode, dentry, oldname);
+		error = vfs_symlink(mnt_user_ns(path.mnt), path.dentry->d_inode,
+				    dentry, oldname);
 	done_path_create(&path, dentry);
 	return error;
 }
@@ -233,7 +234,8 @@ int __init init_mkdir(const char *pathname, umode_t mode)
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
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
