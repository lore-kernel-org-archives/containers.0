Return-Path: <SRS0=rneQ=G2=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6FA8C433E0
	for <containers@archiver.kernel.org>; Sat, 23 Jan 2021 13:11:18 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2F02C22DBF
	for <containers@archiver.kernel.org>; Sat, 23 Jan 2021 13:11:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F02C22DBF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id CF56D86B1F;
	Sat, 23 Jan 2021 13:11:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id pe6lUFTNKnVQ; Sat, 23 Jan 2021 13:11:16 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 3BDD586B1D;
	Sat, 23 Jan 2021 13:11:16 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 31870C088B;
	Sat, 23 Jan 2021 13:11:16 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 2C4C2C013A
 for <containers@lists.linux-foundation.org>;
 Sat, 23 Jan 2021 13:11:15 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id D8C9C203D0
 for <containers@lists.linux-foundation.org>;
 Sat, 23 Jan 2021 13:11:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id bnoY8HdbKD1T
 for <containers@lists.linux-foundation.org>;
 Sat, 23 Jan 2021 13:11:13 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by silver.osuosl.org (Postfix) with ESMTPS id 6C1B620348
 for <containers@lists.linux-foundation.org>;
 Sat, 23 Jan 2021 13:11:13 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1l3Ify-0007vJ-RG; Sat, 23 Jan 2021 13:10:03 +0000
Date: Sat, 23 Jan 2021 14:09:58 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v6 05/39] namei: make permission helpers idmapped mount
 aware
Message-ID: <20210123130958.3t6kvgkl634njpsm@wittgenstein>
References: <20210121131959.646623-1-christian.brauner@ubuntu.com>
 <20210121131959.646623-6-christian.brauner@ubuntu.com>
 <20210122222632.GB25405@fieldses.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210122222632.GB25405@fieldses.org>
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 Alban Crequy <alban@kinvolk.io>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>, linux-xfs@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, linux-fsdevel@vger.kernel.org,
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

On Fri, Jan 22, 2021 at 05:26:32PM -0500, J. Bruce Fields wrote:
> If I NFS-exported an idmapped mount, I think I'd expect idmapped clients
> to see the mapped IDs.
> 
> Looks like that means taking the user namespace from the struct
> svc_export everwhere, for example:
> 
> On Thu, Jan 21, 2021 at 02:19:24PM +0100, Christian Brauner wrote:
> > index 66f2ef67792a..8d90796e236a 100644
> > --- a/fs/nfsd/nfsfh.c
> > +++ b/fs/nfsd/nfsfh.c
> > @@ -40,7 +40,8 @@ static int nfsd_acceptable(void *expv, struct dentry *dentry)
> >  		/* make sure parents give x permission to user */
> >  		int err;
> >  		parent = dget_parent(tdentry);
> > -		err = inode_permission(d_inode(parent), MAY_EXEC);
> > +		err = inode_permission(&init_user_ns,
> > +				       d_inode(parent), MAY_EXEC);
> 
> 		err = inode_permission(exp->ex_path.mnt->mnt_userns,
> 				      d_inode(parent, MAY_EXEC);

Hey Bruce, thanks! Imho, the clean approach for now is to not export
idmapped mounts until we have ported that part of nfs similar to what we
do for stacking filesystems for now. I've tested and taken this patch
into my tree:

---
From 7a6a53bca1ecd8db872de1ee81d1a57e1829e525 Mon Sep 17 00:00:00 2001
From: Christian Brauner <christian.brauner@ubuntu.com>
Date: Sat, 23 Jan 2021 12:00:02 +0100
Subject: [PATCH] nfs: do not export idmapped mounts

Prevent nfs from exporting idmapped mounts until we have ported it to
support exporting idmapped mounts.

Cc: Christoph Hellwig <hch@lst.de>
Cc: David Howells <dhowells@redhat.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */

/* v3 */

/* v4 */

/* v5 */

/* v5 */
patch introduced
base-commit: 19c329f6808995b142b3966301f217c831e7cf31
---
 fs/nfsd/export.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 81e7bb12aca6..e456421f68b4 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -369,8 +369,9 @@ static struct svc_export *svc_export_update(struct svc_export *new,
 					    struct svc_export *old);
 static struct svc_export *svc_export_lookup(struct svc_export *);
 
-static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
+static int check_export(struct path *path, int *flags, unsigned char *uuid)
 {
+	struct inode *inode = d_inode(path->dentry);
 
 	/*
 	 * We currently export only dirs, regular files, and (for v4
@@ -394,6 +395,7 @@ static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
 	 *       or an FSID number (so NFSEXP_FSID or ->uuid is needed).
 	 * 2:  We must be able to find an inode from a filehandle.
 	 *       This means that s_export_op must be set.
+	 * 3: We must not currently be on an idmapped mount.
 	 */
 	if (!(inode->i_sb->s_type->fs_flags & FS_REQUIRES_DEV) &&
 	    !(*flags & NFSEXP_FSID) &&
@@ -408,6 +410,11 @@ static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
 		return -EINVAL;
 	}
 
+	if (mnt_user_ns(path->mnt) != &init_user_ns) {
+		dprintk("exp_export: export of idmapped mounts not yet supported.\n");
+		return -EINVAL;
+	}
+
 	if (inode->i_sb->s_export_op->flags & EXPORT_OP_NOSUBTREECHK &&
 	    !(*flags & NFSEXP_NOSUBTREECHECK)) {
 		dprintk("%s: %s does not support subtree checking!\n",
@@ -636,8 +643,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 				goto out4;
 		}
 
-		err = check_export(d_inode(exp.ex_path.dentry), &exp.ex_flags,
-				   exp.ex_uuid);
+		err = check_export(&exp.ex_path, &exp.ex_flags, exp.ex_uuid);
 		if (err)
 			goto out4;
 		/*
-- 
2.30.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
