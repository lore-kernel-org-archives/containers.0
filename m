Return-Path: <SRS0=YWEV=GP=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33F73C433E0
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:15:34 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C630A23122
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:15:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C630A23122
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 428A58560F;
	Tue, 12 Jan 2021 22:15:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id lwyrpc4t+Bmx; Tue, 12 Jan 2021 22:15:32 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id A13A9855E1;
	Tue, 12 Jan 2021 22:15:32 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8E228C0893;
	Tue, 12 Jan 2021 22:15:32 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id CC414C013A
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:15:30 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id C31E68560F
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:15:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 37qNyZLS4g3y
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:15:30 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by whitealder.osuosl.org (Postfix) with ESMTPS id F23DB855E1
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:15:29 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kzRlu-0003bd-T8; Tue, 12 Jan 2021 22:04:15 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v5 33/42] apparmor: handle idmapped mounts
Date: Tue, 12 Jan 2021 23:01:15 +0100
Message-Id: <20210112220124.837960-34-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210112220124.837960-1-christian.brauner@ubuntu.com>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=GtgWex55B/vr9cqlh7J1mRZi5HqOLuyw4/kbMFcnj44=;
 m=Q5L3+S6uMNfe06nKUTXtIKS5PrHz/ZnhwCjAid9lFbw=;
 p=J20qmlPkYZL+wxjaJC67jWA3EV8DnQILMlq1X9O05zU=;
 g=89ccfa3ded0a3bad947410be86c8179674d8f439
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCX/4YuAAKCRCRxhvAZXjcovWfAP434jG
 OozLelJRLwS5VVUjLPWx7UGVUe2krUFPLFnICrwEAzj0T9w7Qgbpfuhx2qFw/ljWyiC2cvisR9ADl
 G3Re9AE=
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Paul Moore <paul@paul-moore.com>, Jonathan Corbet <corbet@lwn.net>,
 smbarber@chromium.org, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
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

The i_uid and i_gid are only ever used when logging for AppArmor. This
is already broken in a bunch of places where the global root id is
reported instead of the i_uid or i_gid of the file. Nonetheless, be kind
and log the mapped inode if we're coming from an idmapped mount. If the
initial user namespace is passed nothing changes so non-idmapped mounts
will see identical behavior as before.

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
 security/apparmor/domain.c |  9 ++++++---
 security/apparmor/file.c   |  5 ++++-
 security/apparmor/lsm.c    | 12 ++++++++----
 3 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/security/apparmor/domain.c b/security/apparmor/domain.c
index 16f184bc48de..9a1b31655d9e 100644
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
+	struct user_namespace *mnt_userns = file_user_ns(bprm->file);
+	kuid_t i_uid = i_uid_into_mnt(mnt_userns, file_inode(bprm->file));
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
index 92acf9a49405..a00db7eaefc8 100644
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
+	struct user_namespace *mnt_userns = file_user_ns(file);
 	struct path_cond cond = {
-		.uid = file_inode(file)->i_uid,
+		.uid = i_uid_into_mnt(mnt_userns, file_inode(file)),
 		.mode = file_inode(file)->i_mode
 	};
 	char *buffer;
diff --git a/security/apparmor/lsm.c b/security/apparmor/lsm.c
index 1b0aba8eb723..7468d23c136e 100644
--- a/security/apparmor/lsm.c
+++ b/security/apparmor/lsm.c
@@ -224,7 +224,8 @@ static int common_perm(const char *op, const struct path *path, u32 mask,
  */
 static int common_perm_cond(const char *op, const struct path *path, u32 mask)
 {
-	struct path_cond cond = { d_backing_inode(path->dentry)->i_uid,
+	struct user_namespace *mnt_userns = mnt_user_ns(path->mnt);
+	struct path_cond cond = { i_uid_into_mnt(mnt_userns, d_backing_inode(path->dentry)),
 				  d_backing_inode(path->dentry)->i_mode
 	};
 
@@ -266,12 +267,13 @@ static int common_perm_rm(const char *op, const struct path *dir,
 			  struct dentry *dentry, u32 mask)
 {
 	struct inode *inode = d_backing_inode(dentry);
+	struct user_namespace *mnt_userns = mnt_user_ns(dir->mnt);
 	struct path_cond cond = { };
 
 	if (!inode || !path_mediated_fs(dentry))
 		return 0;
 
-	cond.uid = inode->i_uid;
+	cond.uid = i_uid_into_mnt(mnt_userns, inode);
 	cond.mode = inode->i_mode;
 
 	return common_perm_dir_dentry(op, dir, dentry, mask, &cond);
@@ -361,11 +363,12 @@ static int apparmor_path_rename(const struct path *old_dir, struct dentry *old_d
 
 	label = begin_current_label_crit_section();
 	if (!unconfined(label)) {
+		struct user_namespace *mnt_userns = mnt_user_ns(old_dir->mnt);
 		struct path old_path = { .mnt = old_dir->mnt,
 					 .dentry = old_dentry };
 		struct path new_path = { .mnt = new_dir->mnt,
 					 .dentry = new_dentry };
-		struct path_cond cond = { d_backing_inode(old_dentry)->i_uid,
+		struct path_cond cond = { i_uid_into_mnt(mnt_userns, d_backing_inode(old_dentry)),
 					  d_backing_inode(old_dentry)->i_mode
 		};
 
@@ -420,8 +423,9 @@ static int apparmor_file_open(struct file *file)
 
 	label = aa_get_newest_cred_label(file->f_cred);
 	if (!unconfined(label)) {
+		struct user_namespace *mnt_userns = file_user_ns(file);
 		struct inode *inode = file_inode(file);
-		struct path_cond cond = { inode->i_uid, inode->i_mode };
+		struct path_cond cond = { i_uid_into_mnt(mnt_userns, inode), inode->i_mode };
 
 		error = aa_path_perm(OP_OPEN, label, &file->f_path, 0,
 				     aa_map_file_to_perms(file), &cond);
-- 
2.30.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
