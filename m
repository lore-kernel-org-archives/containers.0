Return-Path: <SRS0=+MRp=FC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEAE7C63777
	for <containers@archiver.kernel.org>; Sat, 28 Nov 2020 21:54:11 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7D53720857
	for <containers@archiver.kernel.org>; Sat, 28 Nov 2020 21:54:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D53720857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 5674287BA5;
	Sat, 28 Nov 2020 21:54:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zPIRp79EgUMv; Sat, 28 Nov 2020 21:54:10 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 8F2C887BE3;
	Sat, 28 Nov 2020 21:54:10 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7D288C0891;
	Sat, 28 Nov 2020 21:54:10 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 8D488C0052
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 21:54:09 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 7C2F186C4D
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 21:54:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id pYIDTyI-b0Yl
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 21:54:08 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id C27C386C1B
 for <containers@lists.linux-foundation.org>;
 Sat, 28 Nov 2020 21:54:08 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kj83S-0002aM-8k; Sat, 28 Nov 2020 21:46:54 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v3 30/38] apparmor: handle idmapped mounts
Date: Sat, 28 Nov 2020 22:35:19 +0100
Message-Id: <20201128213527.2669807-31-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20201128213527.2669807-1-christian.brauner@ubuntu.com>
References: <20201128213527.2669807-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Cc: Andy Lutomirski <luto@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Paul Moore <paul@paul-moore.com>, Jonathan Corbet <corbet@lwn.net>,
 smbarber@chromium.org, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
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

The i_uid and i_gid are only ever used when logging for AppArmor. This is
already broken in a bunch of places where the global root id is reported
instead of the i_uid or i_gid of the file. Nonetheless, be kind and log the
mapped inode if we're coming from an idmapped mount. If the initial user
namespace is passed nothing changes so non-idmapped mounts will see identical
behavior as before.

Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
unchanged

/* v3 */
unchanged
---
 security/apparmor/domain.c |  9 ++++++---
 security/apparmor/file.c   |  5 ++++-
 security/apparmor/lsm.c    | 12 ++++++++----
 3 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/security/apparmor/domain.c b/security/apparmor/domain.c
index 16f184bc48de..4f997dba4573 100644
--- a/security/apparmor/domain.c
+++ b/security/apparmor/domain.c
@@ -10,12 +10,14 @@
 
 #include <linux/errno.h>
 #include <linux/fdtable.h>
+#include <linux/fs.h>
 #include <linux/file.h>
 #include <linux/mount.h>
 #include <linux/syscalls.h>
 #include <linux/tracehook.h>
 #include <linux/personality.h>
 #include <linux/xattr.h>
+#include <linux/user_namespace.h>
 
 #include "include/audit.h"
 #include "include/apparmorfs.h"
@@ -858,8 +860,10 @@ int apparmor_bprm_creds_for_exec(struct linux_binprm *bprm)
 	const char *info = NULL;
 	int error = 0;
 	bool unsafe = false;
+	struct user_namespace *user_ns = mnt_user_ns(bprm->file->f_path.mnt);
+	kuid_t i_uid = i_uid_into_mnt(user_ns, file_inode(bprm->file));
 	struct path_cond cond = {
-		file_inode(bprm->file)->i_uid,
+		i_uid,
 		file_inode(bprm->file)->i_mode
 	};
 
@@ -967,8 +971,7 @@ int apparmor_bprm_creds_for_exec(struct linux_binprm *bprm)
 	error = fn_for_each(label, profile,
 			aa_audit_file(profile, &nullperms, OP_EXEC, MAY_EXEC,
 				      bprm->filename, NULL, new,
-				      file_inode(bprm->file)->i_uid, info,
-				      error));
+				      i_uid, info, error));
 	aa_put_label(new);
 	goto done;
 }
diff --git a/security/apparmor/file.c b/security/apparmor/file.c
index 92acf9a49405..d6d9e71f1900 100644
--- a/security/apparmor/file.c
+++ b/security/apparmor/file.c
@@ -11,6 +11,8 @@
 #include <linux/tty.h>
 #include <linux/fdtable.h>
 #include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/mount.h>
 
 #include "include/apparmor.h"
 #include "include/audit.h"
@@ -508,8 +510,9 @@ static int __file_path_perm(const char *op, struct aa_label *label,
 {
 	struct aa_profile *profile;
 	struct aa_perms perms = {};
+	struct user_namespace *user_ns = mnt_user_ns(file->f_path.mnt);
 	struct path_cond cond = {
-		.uid = file_inode(file)->i_uid,
+		.uid = i_uid_into_mnt(user_ns, file_inode(file)),
 		.mode = file_inode(file)->i_mode
 	};
 	char *buffer;
diff --git a/security/apparmor/lsm.c b/security/apparmor/lsm.c
index ffeaee5ed968..ece9afc3994f 100644
--- a/security/apparmor/lsm.c
+++ b/security/apparmor/lsm.c
@@ -224,7 +224,8 @@ static int common_perm(const char *op, const struct path *path, u32 mask,
  */
 static int common_perm_cond(const char *op, const struct path *path, u32 mask)
 {
-	struct path_cond cond = { d_backing_inode(path->dentry)->i_uid,
+	struct user_namespace *user_ns = mnt_user_ns(path->mnt);
+	struct path_cond cond = { i_uid_into_mnt(user_ns, d_backing_inode(path->dentry)),
 				  d_backing_inode(path->dentry)->i_mode
 	};
 
@@ -266,12 +267,13 @@ static int common_perm_rm(const char *op, const struct path *dir,
 			  struct dentry *dentry, u32 mask)
 {
 	struct inode *inode = d_backing_inode(dentry);
+	struct user_namespace *user_ns = mnt_user_ns(dir->mnt);
 	struct path_cond cond = { };
 
 	if (!inode || !path_mediated_fs(dentry))
 		return 0;
 
-	cond.uid = inode->i_uid;
+	cond.uid = i_uid_into_mnt(user_ns, inode);
 	cond.mode = inode->i_mode;
 
 	return common_perm_dir_dentry(op, dir, dentry, mask, &cond);
@@ -361,11 +363,12 @@ static int apparmor_path_rename(const struct path *old_dir, struct dentry *old_d
 
 	label = begin_current_label_crit_section();
 	if (!unconfined(label)) {
+		struct user_namespace *user_ns = mnt_user_ns(old_dir->mnt);
 		struct path old_path = { .mnt = old_dir->mnt,
 					 .dentry = old_dentry };
 		struct path new_path = { .mnt = new_dir->mnt,
 					 .dentry = new_dentry };
-		struct path_cond cond = { d_backing_inode(old_dentry)->i_uid,
+		struct path_cond cond = { i_uid_into_mnt(user_ns, d_backing_inode(old_dentry)),
 					  d_backing_inode(old_dentry)->i_mode
 		};
 
@@ -420,8 +423,9 @@ static int apparmor_file_open(struct file *file)
 
 	label = aa_get_newest_cred_label(file->f_cred);
 	if (!unconfined(label)) {
+		struct user_namespace *user_ns = mnt_user_ns(file->f_path.mnt);
 		struct inode *inode = file_inode(file);
-		struct path_cond cond = { inode->i_uid, inode->i_mode };
+		struct path_cond cond = { i_uid_into_mnt(user_ns, inode), inode->i_mode };
 
 		error = aa_path_perm(OP_OPEN, label, &file->f_path, 0,
 				     aa_map_file_to_perms(file), &cond);
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
