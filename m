Return-Path: <SRS0=LQYp=EV=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D523C2D0E4
	for <containers@archiver.kernel.org>; Sun, 15 Nov 2020 10:43:12 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F1DC623A32
	for <containers@archiver.kernel.org>; Sun, 15 Nov 2020 10:43:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1DC623A32
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id D3B66872B9;
	Sun, 15 Nov 2020 10:43:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LfyMN7Pujldh; Sun, 15 Nov 2020 10:43:10 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id C7437872B7;
	Sun, 15 Nov 2020 10:43:10 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B3FE1C0891;
	Sun, 15 Nov 2020 10:43:10 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D36D4C07FF
 for <containers@lists.linux-foundation.org>;
 Sun, 15 Nov 2020 10:43:09 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id CD25685E6D
 for <containers@lists.linux-foundation.org>;
 Sun, 15 Nov 2020 10:43:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id DVCP6C2uqT4g
 for <containers@lists.linux-foundation.org>;
 Sun, 15 Nov 2020 10:43:08 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id C07F885E69
 for <containers@lists.linux-foundation.org>;
 Sun, 15 Nov 2020 10:43:08 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1keFRm-0000Kt-LI; Sun, 15 Nov 2020 10:39:50 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 31/39] audit: handle idmapped mounts
Date: Sun, 15 Nov 2020 11:37:10 +0100
Message-Id: <20201115103718.298186-32-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20201115103718.298186-1-christian.brauner@ubuntu.com>
References: <20201115103718.298186-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 Jann Horn <jannh@google.com>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
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

Audit will sometimes log the inode's i_uid and i_gid. Enable audit to log the
mapped inode when it is accessed from an idmapped mount.

Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
unchanged
---
 fs/namei.c            | 14 +++++++-------
 include/linux/audit.h | 10 ++++++----
 ipc/mqueue.c          |  8 ++++----
 kernel/auditsc.c      | 26 ++++++++++++++------------
 4 files changed, 31 insertions(+), 27 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 1d6a0da8bf81..976ee05c5027 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -986,7 +986,7 @@ static inline int may_follow_link(struct nameidata *nd, const struct inode *inod
 	if (nd->flags & LOOKUP_RCU)
 		return -ECHILD;
 
-	audit_inode(nd->name, nd->stack[0].link.dentry, 0);
+	audit_inode(nd->name, user_ns, nd->stack[0].link.dentry, 0);
 	audit_log_path_denied(AUDIT_ANOM_LINK, "follow_link");
 	return -EACCES;
 }
@@ -2398,7 +2398,7 @@ int filename_lookup(int dfd, struct filename *name, unsigned flags,
 		retval = path_lookupat(&nd, flags | LOOKUP_REVAL, path);
 
 	if (likely(!retval))
-		audit_inode(name, path->dentry,
+		audit_inode(name, mnt_user_ns(path->mnt), path->dentry,
 			    flags & LOOKUP_MOUNTPOINT ? AUDIT_INODE_NOEVAL : 0);
 	restore_nameidata();
 	putname(name);
@@ -2440,7 +2440,7 @@ static struct filename *filename_parentat(int dfd, struct filename *name,
 	if (likely(!retval)) {
 		*last = nd.last;
 		*type = nd.last_type;
-		audit_inode(name, parent->dentry, AUDIT_INODE_PARENT);
+		audit_inode(name, mnt_user_ns(parent->mnt), parent->dentry, AUDIT_INODE_PARENT);
 	} else {
 		putname(name);
 		name = ERR_PTR(retval);
@@ -3194,7 +3194,7 @@ static const char *open_last_lookups(struct nameidata *nd,
 			if (unlikely(error))
 				return ERR_PTR(error);
 		}
-		audit_inode(nd->name, dir, AUDIT_INODE_PARENT);
+		audit_inode(nd->name, mnt_user_ns(nd->path.mnt), dir, AUDIT_INODE_PARENT);
 		/* trailing slashes? */
 		if (unlikely(nd->last.name[nd->last.len]))
 			return ERR_PTR(-EISDIR);
@@ -3260,7 +3260,7 @@ static int do_open(struct nameidata *nd,
 			return error;
 	}
 	if (!(file->f_mode & FMODE_CREATED))
-		audit_inode(nd->name, nd->path.dentry, 0);
+		audit_inode(nd->name, mnt_user_ns(nd->path.mnt), nd->path.dentry, 0);
 	if (open_flag & O_CREAT) {
 		if ((open_flag & O_EXCL) && !(file->f_mode & FMODE_CREATED))
 			return -EEXIST;
@@ -3362,7 +3362,7 @@ static int do_tmpfile(struct nameidata *nd, unsigned flags,
 		goto out2;
 	dput(path.dentry);
 	path.dentry = child;
-	audit_inode(nd->name, child, 0);
+	audit_inode(nd->name, user_ns, child, 0);
 	/* Don't check for other permissions, the inode was just created */
 	error = may_open(&path, 0, op->open_flag);
 	if (error)
@@ -3381,7 +3381,7 @@ static int do_o_path(struct nameidata *nd, unsigned flags, struct file *file)
 	struct path path;
 	int error = path_lookupat(nd, flags, &path);
 	if (!error) {
-		audit_inode(nd->name, path.dentry, 0);
+		audit_inode(nd->name, mnt_user_ns(path.mnt), path.dentry, 0);
 		error = vfs_open(&path, file);
 		path_put(&path);
 	}
diff --git a/include/linux/audit.h b/include/linux/audit.h
index b3d859831a31..217d2b0c273e 100644
--- a/include/linux/audit.h
+++ b/include/linux/audit.h
@@ -293,8 +293,8 @@ extern void __audit_syscall_exit(int ret_success, long ret_value);
 extern struct filename *__audit_reusename(const __user char *uptr);
 extern void __audit_getname(struct filename *name);
 extern void __audit_getcwd(void);
-extern void __audit_inode(struct filename *name, const struct dentry *dentry,
-				unsigned int flags);
+extern void __audit_inode(struct filename *name, struct user_namespace *user_ns,
+			  const struct dentry *dentry, unsigned int flags);
 extern void __audit_file(const struct file *);
 extern void __audit_inode_child(struct inode *parent,
 				const struct dentry *dentry,
@@ -357,10 +357,11 @@ static inline void audit_getcwd(void)
 		__audit_getcwd();
 }
 static inline void audit_inode(struct filename *name,
+				struct user_namespace *user_ns,
 				const struct dentry *dentry,
 				unsigned int aflags) {
 	if (unlikely(!audit_dummy_context()))
-		__audit_inode(name, dentry, aflags);
+		__audit_inode(name, user_ns, dentry, aflags);
 }
 static inline void audit_file(struct file *file)
 {
@@ -371,7 +372,7 @@ static inline void audit_inode_parent_hidden(struct filename *name,
 						const struct dentry *dentry)
 {
 	if (unlikely(!audit_dummy_context()))
-		__audit_inode(name, dentry,
+		__audit_inode(name, &init_user_ns, dentry,
 				AUDIT_INODE_PARENT | AUDIT_INODE_HIDDEN);
 }
 static inline void audit_inode_child(struct inode *parent,
@@ -587,6 +588,7 @@ static inline void audit_getname(struct filename *name)
 static inline void audit_getcwd(void)
 { }
 static inline void audit_inode(struct filename *name,
+				struct user_namespace *user_ns,
 				const struct dentry *dentry,
 				unsigned int aflags)
 { }
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 5008e87b026d..f3943b2cc003 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -849,8 +849,8 @@ static void remove_notification(struct mqueue_inode_info *info)
 	info->notify_user_ns = NULL;
 }
 
-static int prepare_open(struct dentry *dentry, int oflag, int ro,
-			umode_t mode, struct filename *name,
+static int prepare_open(struct user_namespace *user_ns, struct dentry *dentry,
+			int oflag, int ro, umode_t mode, struct filename *name,
 			struct mq_attr *attr)
 {
 	static const int oflag2acc[O_ACCMODE] = { MAY_READ, MAY_WRITE,
@@ -867,7 +867,7 @@ static int prepare_open(struct dentry *dentry, int oflag, int ro,
 				  mqueue_create_attr, attr);
 	}
 	/* it already existed */
-	audit_inode(name, dentry, 0);
+	audit_inode(name, user_ns, dentry, 0);
 	if ((oflag & (O_CREAT|O_EXCL)) == (O_CREAT|O_EXCL))
 		return -EEXIST;
 	if ((oflag & O_ACCMODE) == (O_RDWR | O_WRONLY))
@@ -903,7 +903,7 @@ static int do_mq_open(const char __user *u_name, int oflag, umode_t mode,
 		goto out_putfd;
 	}
 	path.mnt = mntget(mnt);
-	error = prepare_open(path.dentry, oflag, ro, mode, name, attr);
+	error = prepare_open(mnt_user_ns(path.mnt), path.dentry, oflag, ro, mode, name, attr);
 	if (!error) {
 		struct file *file = dentry_open(&path, oflag, current_cred());
 		if (!IS_ERR(file))
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index ddb9213a3e81..348e6048f1b7 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1936,6 +1936,7 @@ void __audit_getname(struct filename *name)
 }
 
 static inline int audit_copy_fcaps(struct audit_names *name,
+				   struct user_namespace *user_ns,
 				   const struct dentry *dentry)
 {
 	struct cpu_vfs_cap_data caps;
@@ -1944,7 +1945,7 @@ static inline int audit_copy_fcaps(struct audit_names *name,
 	if (!dentry)
 		return 0;
 
-	rc = get_vfs_caps_from_disk(&init_user_ns, dentry, &caps);
+	rc = get_vfs_caps_from_disk(user_ns, dentry, &caps);
 	if (rc)
 		return rc;
 
@@ -1960,21 +1961,22 @@ static inline int audit_copy_fcaps(struct audit_names *name,
 
 /* Copy inode data into an audit_names. */
 static void audit_copy_inode(struct audit_names *name,
-			     const struct dentry *dentry,
-			     struct inode *inode, unsigned int flags)
+			     struct user_namespace *user_ns,
+			     const struct dentry *dentry, struct inode *inode,
+			     unsigned int flags)
 {
 	name->ino   = inode->i_ino;
 	name->dev   = inode->i_sb->s_dev;
 	name->mode  = inode->i_mode;
-	name->uid   = inode->i_uid;
-	name->gid   = inode->i_gid;
+	name->uid   = i_uid_into_mnt(user_ns, inode);
+	name->gid   = i_gid_into_mnt(user_ns, inode);
 	name->rdev  = inode->i_rdev;
 	security_inode_getsecid(inode, &name->osid);
 	if (flags & AUDIT_INODE_NOEVAL) {
 		name->fcap_ver = -1;
 		return;
 	}
-	audit_copy_fcaps(name, dentry);
+	audit_copy_fcaps(name, user_ns, dentry);
 }
 
 /**
@@ -1983,8 +1985,8 @@ static void audit_copy_inode(struct audit_names *name,
  * @dentry: dentry being audited
  * @flags: attributes for this particular entry
  */
-void __audit_inode(struct filename *name, const struct dentry *dentry,
-		   unsigned int flags)
+void __audit_inode(struct filename *name, struct user_namespace *user_ns,
+		   const struct dentry *dentry, unsigned int flags)
 {
 	struct audit_context *context = audit_context();
 	struct inode *inode = d_backing_inode(dentry);
@@ -2078,12 +2080,12 @@ void __audit_inode(struct filename *name, const struct dentry *dentry,
 		n->type = AUDIT_TYPE_NORMAL;
 	}
 	handle_path(dentry);
-	audit_copy_inode(n, dentry, inode, flags & AUDIT_INODE_NOEVAL);
+	audit_copy_inode(n, user_ns, dentry, inode, flags & AUDIT_INODE_NOEVAL);
 }
 
 void __audit_file(const struct file *file)
 {
-	__audit_inode(NULL, file->f_path.dentry, 0);
+	__audit_inode(NULL, mnt_user_ns(file->f_path.mnt), file->f_path.dentry, 0);
 }
 
 /**
@@ -2175,7 +2177,7 @@ void __audit_inode_child(struct inode *parent,
 		n = audit_alloc_name(context, AUDIT_TYPE_PARENT);
 		if (!n)
 			return;
-		audit_copy_inode(n, NULL, parent, 0);
+		audit_copy_inode(n, &init_user_ns, NULL, parent, 0);
 	}
 
 	if (!found_child) {
@@ -2194,7 +2196,7 @@ void __audit_inode_child(struct inode *parent,
 	}
 
 	if (inode)
-		audit_copy_inode(found_child, dentry, inode, 0);
+		audit_copy_inode(found_child, &init_user_ns, dentry, inode, 0);
 	else
 		found_child->ino = AUDIT_INO_UNSET;
 }
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
