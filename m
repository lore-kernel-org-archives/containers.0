Return-Path: <SRS0=+MRp=FC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B0B3C63777
	for <containers@archiver.kernel.org>; Sat, 28 Nov 2020 21:47:30 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B78A6221FF
	for <containers@archiver.kernel.org>; Sat, 28 Nov 2020 21:47:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B78A6221FF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 5F0FA87051;
	Sat, 28 Nov 2020 21:47:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id PPDj3hbsJZbh; Sat, 28 Nov 2020 21:47:28 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id A2EF187078;
	Sat, 28 Nov 2020 21:47:28 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9A5DEC1DA0;
	Sat, 28 Nov 2020 21:47:28 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A133DC0891
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 21:47:27 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 8F0DF86FE9
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 21:47:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id O3twv8vwpV1w
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 21:47:25 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 40FBF870CD
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 21:47:25 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kj82t-0002aM-LZ; Sat, 28 Nov 2020 21:46:19 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v3 17/38] namei: introduce struct renamedata
Date: Sat, 28 Nov 2020 22:35:06 +0100
Message-Id: <20201128213527.2669807-18-christian.brauner@ubuntu.com>
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

In order to handle idmapped mounts we will extend the vfs rename helper to
take two new arguments in follow up patches. Since this operations already
takes a bunch of arguments add a simple struct renamedata (based on struct
nameidata) and make the current helper use it before we extend it.

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
---
 fs/cachefiles/namei.c    |  9 +++++++--
 fs/ecryptfs/inode.c      | 10 +++++++---
 fs/namei.c               | 21 +++++++++++++++------
 fs/nfsd/vfs.c            |  8 +++++++-
 fs/overlayfs/overlayfs.h |  9 ++++++++-
 include/linux/fs.h       | 12 +++++++++++-
 6 files changed, 55 insertions(+), 14 deletions(-)

diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
index ecc8ecbbfa5a..7b987de0babe 100644
--- a/fs/cachefiles/namei.c
+++ b/fs/cachefiles/namei.c
@@ -412,9 +412,14 @@ static int cachefiles_bury_object(struct cachefiles_cache *cache,
 	if (ret < 0) {
 		cachefiles_io_error(cache, "Rename security error %d", ret);
 	} else {
+		struct renamedata rd = {
+			.old_dir	= d_inode(dir),
+			.old_dentry	= rep,
+			.new_dir	= d_inode(cache->graveyard),
+			.new_dentry	= grave,
+		};
 		trace_cachefiles_rename(object, rep, grave, why);
-		ret = vfs_rename(d_inode(dir), rep,
-				 d_inode(cache->graveyard), grave, NULL, 0);
+		ret = vfs_rename(&rd);
 		if (ret != 0 && ret != -ENOMEM)
 			cachefiles_io_error(cache,
 					    "Rename failed with error %d", ret);
diff --git a/fs/ecryptfs/inode.c b/fs/ecryptfs/inode.c
index d98448c75051..838949ede439 100644
--- a/fs/ecryptfs/inode.c
+++ b/fs/ecryptfs/inode.c
@@ -590,6 +590,7 @@ ecryptfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	struct dentry *lower_new_dir_dentry;
 	struct dentry *trap;
 	struct inode *target_inode;
+	struct renamedata rd = {};
 
 	if (flags)
 		return -EINVAL;
@@ -619,9 +620,12 @@ ecryptfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 		rc = -ENOTEMPTY;
 		goto out_lock;
 	}
-	rc = vfs_rename(d_inode(lower_old_dir_dentry), lower_old_dentry,
-			d_inode(lower_new_dir_dentry), lower_new_dentry,
-			NULL, 0);
+
+	rd.old_dir	= d_inode(lower_old_dir_dentry);
+	rd.old_dentry	= lower_old_dentry;
+	rd.new_dir	= d_inode(lower_new_dir_dentry);
+	rd.new_dentry	= lower_new_dentry;
+	rc = vfs_rename(&rd);
 	if (rc)
 		goto out_lock;
 	if (target_inode)
diff --git a/fs/namei.c b/fs/namei.c
index 4dc842d1cd3a..0a2450de83bb 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4256,12 +4256,15 @@ SYSCALL_DEFINE2(link, const char __user *, oldname, const char __user *, newname
  *	   ->i_mutex on parents, which works but leads to some truly excessive
  *	   locking].
  */
-int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
-	       struct inode *new_dir, struct dentry *new_dentry,
-	       struct inode **delegated_inode, unsigned int flags)
+int vfs_rename(struct renamedata *rd)
 {
 	int error;
 	struct user_namespace *user_ns = &init_user_ns;
+	struct inode *old_dir = rd->old_dir, *new_dir = rd->new_dir;
+	struct dentry *old_dentry = rd->old_dentry,
+		      *new_dentry = rd->new_dentry;
+	struct inode **delegated_inode = rd->delegated_inode;
+	unsigned int flags = rd->flags;
 	bool is_dir = d_is_dir(old_dentry);
 	struct inode *source = old_dentry->d_inode;
 	struct inode *target = new_dentry->d_inode;
@@ -4385,6 +4388,7 @@ EXPORT_SYMBOL(vfs_rename);
 static int do_renameat2(int olddfd, const char __user *oldname, int newdfd,
 			const char __user *newname, unsigned int flags)
 {
+	struct renamedata rd;
 	struct dentry *old_dentry, *new_dentry;
 	struct dentry *trap;
 	struct path old_path, new_path;
@@ -4490,9 +4494,14 @@ static int do_renameat2(int olddfd, const char __user *oldname, int newdfd,
 				     &new_path, new_dentry, flags);
 	if (error)
 		goto exit5;
-	error = vfs_rename(old_path.dentry->d_inode, old_dentry,
-			   new_path.dentry->d_inode, new_dentry,
-			   &delegated_inode, flags);
+
+	rd.old_dir	   = old_path.dentry->d_inode;
+	rd.old_dentry	   = old_dentry;
+	rd.new_dir	   = new_path.dentry->d_inode;
+	rd.new_dentry	   = new_dentry;
+	rd.delegated_inode = &delegated_inode;
+	rd.flags	   = flags;
+	error = vfs_rename(&rd);
 exit5:
 	dput(new_dentry);
 exit4:
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 9a0e0e5b34f5..3d7a8cd61098 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1787,7 +1787,13 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 		has_cached = true;
 		goto out_dput_old;
 	} else {
-		host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL, 0);
+		struct renamedata rd = {
+			.old_dir	= fdir,
+			.old_dentry	= odentry,
+			.new_dir	= tdir,
+			.new_dentry	= ndentry,
+		};
+		host_err = vfs_rename(&rd);
 		if (!host_err) {
 			host_err = commit_metadata(tfhp);
 			if (!host_err)
diff --git a/fs/overlayfs/overlayfs.h b/fs/overlayfs/overlayfs.h
index bf26fb3fa2c1..73da8710b0f0 100644
--- a/fs/overlayfs/overlayfs.h
+++ b/fs/overlayfs/overlayfs.h
@@ -212,9 +212,16 @@ static inline int ovl_do_rename(struct inode *olddir, struct dentry *olddentry,
 				unsigned int flags)
 {
 	int err;
+	struct renamedata rd = {
+		.old_dir 	= olddir,
+		.old_dentry 	= olddentry,
+		.new_dir 	= newdir,
+		.new_dentry 	= newdentry,
+		.flags 		= flags,
+	};
 
 	pr_debug("rename(%pd2, %pd2, 0x%x)\n", olddentry, newdentry, flags);
-	err = vfs_rename(olddir, olddentry, newdir, newdentry, NULL, flags);
+	err = vfs_rename(&rd);
 	if (err) {
 		pr_debug("...rename(%pd2, %pd2, ...) = %i\n",
 			 olddentry, newdentry, err);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 38aabad8f2aa..3a27d84df7fb 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1772,7 +1772,17 @@ extern int vfs_symlink(struct inode *, struct dentry *, const char *);
 extern int vfs_link(struct dentry *, struct inode *, struct dentry *, struct inode **);
 extern int vfs_rmdir(struct inode *, struct dentry *);
 extern int vfs_unlink(struct inode *, struct dentry *, struct inode **);
-extern int vfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *, struct inode **, unsigned int);
+
+struct renamedata {
+	struct inode *old_dir;
+	struct dentry *old_dentry;
+	struct inode *new_dir;
+	struct dentry *new_dentry;
+	struct inode **delegated_inode;
+	unsigned int flags;
+} __randomize_layout;
+
+extern int vfs_rename(struct renamedata *);
 
 static inline int vfs_whiteout(struct inode *dir, struct dentry *dentry)
 {
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
