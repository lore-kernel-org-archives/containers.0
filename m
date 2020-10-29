Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC637C4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:36:33 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6A89120790
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:36:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A89120790
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 388D2203EF;
	Thu, 29 Oct 2020 00:36:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Ms54fr69uuDx; Thu, 29 Oct 2020 00:36:24 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 9C18E21505;
	Thu, 29 Oct 2020 00:36:17 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 95F64C1ADB;
	Thu, 29 Oct 2020 00:36:17 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id BE4F6C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:36:16 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id AD13E868F5
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:36:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id dBSelqDsj7di
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:36:16 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id DD15C8643D
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:36:15 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kXvur-0008Ep-3m; Thu, 29 Oct 2020 00:35:45 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH 19/34] namei: add lookup helpers with idmapped mounts aware
 permission checking
Date: Thu, 29 Oct 2020 01:32:37 +0100
Message-Id: <20201029003252.2128653-20-christian.brauner@ubuntu.com>
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

The lookup_one_len(), lookup_one_len_unlocked(), and lookup_positive_unlocked()
helpers are used by filesystems targeted in this first iteration to lookup
dentries if the caller is privileged over the inode of the base dentry. Add
three new helpers lookup_one_len_mapped(), lookup_one_len_mapped_unlocked(),
and lookup_one_len_mapped_unlocked() to handle idmapped mounts. If the inode is
accessed through an idmapped mount it is mapped according to the mount's user
namespace. Afterwards the permissions checks are identical to non-idmapped
mounts. If the initial user namespace is passed all mapping operations are a
nop so non-idmapped mounts will not see a change in behavior and will also not
see any performance impact. It also means that the non-idmapped-mount aware
helpers can be implemented on top of their idmapped-mount aware counterparts by
passing the initial user namespace.

Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
 fs/namei.c            | 47 ++++++++++++++++++++++++++++++++-----------
 include/linux/namei.h |  6 ++++++
 2 files changed, 41 insertions(+), 12 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index a8a3de936cfc..7901ea09e80e 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2517,8 +2517,9 @@ int vfs_path_lookup(struct dentry *dentry, struct vfsmount *mnt,
 }
 EXPORT_SYMBOL(vfs_path_lookup);
 
-static int lookup_one_len_common(const char *name, struct dentry *base,
-				 int len, struct qstr *this)
+static int lookup_one_len_common(const char *name, struct dentry *base, int len,
+				 struct qstr *this,
+				 struct user_namespace *mnt_user_ns)
 {
 	this->name = name;
 	this->len = len;
@@ -2546,7 +2547,7 @@ static int lookup_one_len_common(const char *name, struct dentry *base,
 			return err;
 	}
 
-	return inode_permission(base->d_inode, MAY_EXEC);
+	return mapped_inode_permission(mnt_user_ns, base->d_inode, MAY_EXEC);
 }
 
 /**
@@ -2570,7 +2571,7 @@ struct dentry *try_lookup_one_len(const char *name, struct dentry *base, int len
 
 	WARN_ON_ONCE(!inode_is_locked(base->d_inode));
 
-	err = lookup_one_len_common(name, base, len, &this);
+	err = lookup_one_len_common(name, base, len, &this, &init_user_ns);
 	if (err)
 		return ERR_PTR(err);
 
@@ -2589,7 +2590,8 @@ EXPORT_SYMBOL(try_lookup_one_len);
  *
  * The caller must hold base->i_mutex.
  */
-struct dentry *lookup_one_len(const char *name, struct dentry *base, int len)
+struct dentry *lookup_one_len_mapped(const char *name, struct dentry *base, int len,
+				 struct user_namespace *mnt_user_ns)
 {
 	struct dentry *dentry;
 	struct qstr this;
@@ -2597,13 +2599,19 @@ struct dentry *lookup_one_len(const char *name, struct dentry *base, int len)
 
 	WARN_ON_ONCE(!inode_is_locked(base->d_inode));
 
-	err = lookup_one_len_common(name, base, len, &this);
+	err = lookup_one_len_common(name, base, len, &this, mnt_user_ns);
 	if (err)
 		return ERR_PTR(err);
 
 	dentry = lookup_dcache(&this, base, 0);
 	return dentry ? dentry : __lookup_slow(&this, base, 0);
 }
+EXPORT_SYMBOL(lookup_one_len_mapped);
+
+struct dentry *lookup_one_len(const char *name, struct dentry *base, int len)
+{
+	return lookup_one_len_mapped(name, base, len, &init_user_ns);
+}
 EXPORT_SYMBOL(lookup_one_len);
 
 /**
@@ -2618,14 +2626,14 @@ EXPORT_SYMBOL(lookup_one_len);
  * Unlike lookup_one_len, it should be called without the parent
  * i_mutex held, and will take the i_mutex itself if necessary.
  */
-struct dentry *lookup_one_len_unlocked(const char *name,
-				       struct dentry *base, int len)
+struct dentry *lookup_one_len_mapped_unlocked(const char *name, struct dentry *base,
+					  int len, struct user_namespace *mnt_user_ns)
 {
 	struct qstr this;
 	int err;
 	struct dentry *ret;
 
-	err = lookup_one_len_common(name, base, len, &this);
+	err = lookup_one_len_common(name, base, len, &this, mnt_user_ns);
 	if (err)
 		return ERR_PTR(err);
 
@@ -2634,6 +2642,13 @@ struct dentry *lookup_one_len_unlocked(const char *name,
 		ret = lookup_slow(&this, base, 0);
 	return ret;
 }
+EXPORT_SYMBOL(lookup_one_len_mapped_unlocked);
+
+struct dentry *lookup_one_len_unlocked(const char *name,
+				       struct dentry *base, int len)
+{
+	return lookup_one_len_mapped_unlocked(name, base, len, &init_user_ns);
+}
 EXPORT_SYMBOL(lookup_one_len_unlocked);
 
 /*
@@ -2644,16 +2659,24 @@ EXPORT_SYMBOL(lookup_one_len_unlocked);
  * need to be very careful; pinned positives have ->d_inode stable, so
  * this one avoids such problems.
  */
-struct dentry *lookup_positive_unlocked(const char *name,
-				       struct dentry *base, int len)
+struct dentry *lookup_positive_mapped_unlocked(const char *name,
+					   struct dentry *base, int len,
+					   struct user_namespace *mnt_user_ns)
 {
-	struct dentry *ret = lookup_one_len_unlocked(name, base, len);
+	struct dentry *ret = lookup_one_len_mapped_unlocked(name, base, len, mnt_user_ns);
 	if (!IS_ERR(ret) && d_flags_negative(smp_load_acquire(&ret->d_flags))) {
 		dput(ret);
 		ret = ERR_PTR(-ENOENT);
 	}
 	return ret;
 }
+EXPORT_SYMBOL(lookup_positive_mapped_unlocked);
+
+struct dentry *lookup_positive_unlocked(const char *name,
+				       struct dentry *base, int len)
+{
+	return lookup_positive_mapped_unlocked(name, base, len, &init_user_ns);
+}
 EXPORT_SYMBOL(lookup_positive_unlocked);
 
 #ifdef CONFIG_UNIX98_PTYS
diff --git a/include/linux/namei.h b/include/linux/namei.h
index a4bb992623c4..42dbe4c2653a 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -68,8 +68,14 @@ extern struct dentry *kern_path_locked(const char *, struct path *);
 
 extern struct dentry *try_lookup_one_len(const char *, struct dentry *, int);
 extern struct dentry *lookup_one_len(const char *, struct dentry *, int);
+extern struct dentry *lookup_one_len_mapped(const char *, struct dentry *, int,
+					struct user_namespace *);
 extern struct dentry *lookup_one_len_unlocked(const char *, struct dentry *, int);
+extern struct dentry *lookup_one_len_mapped_unlocked(const char *, struct dentry *,
+						 int, struct user_namespace *);
 extern struct dentry *lookup_positive_unlocked(const char *, struct dentry *, int);
+extern struct dentry *lookup_positive_mapped_unlocked(const char *, struct dentry *,
+						  int, struct user_namespace *);
 
 extern int follow_down_one(struct path *);
 extern int follow_down(struct path *);
-- 
2.29.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
