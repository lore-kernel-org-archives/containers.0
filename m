Return-Path: <SRS0=EloL=E5=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44CC5C2D0E4
	for <containers@archiver.kernel.org>; Mon, 23 Nov 2020 07:46:25 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BE8682073C
	for <containers@archiver.kernel.org>; Mon, 23 Nov 2020 07:46:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE8682073C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 47A1885FB4;
	Mon, 23 Nov 2020 07:46:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id pBDmGsRuLFDW; Mon, 23 Nov 2020 07:46:23 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 73BAF85FAE;
	Mon, 23 Nov 2020 07:46:23 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 59B09C0891;
	Mon, 23 Nov 2020 07:46:23 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 94CB4C0052
 for <containers@lists.linux-foundation.org>;
 Mon, 23 Nov 2020 07:46:22 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 7DE908667B
 for <containers@lists.linux-foundation.org>;
 Mon, 23 Nov 2020 07:46:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id EKngYWdSELoU
 for <containers@lists.linux-foundation.org>;
 Mon, 23 Nov 2020 07:46:21 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 5DB5B8653F
 for <containers@lists.linux-foundation.org>;
 Mon, 23 Nov 2020 07:46:21 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kh6X5-0007Jl-9M; Mon, 23 Nov 2020 07:45:07 +0000
Date: Mon, 23 Nov 2020 08:45:05 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH v2 14/39] commoncap: handle idmapped mounts
Message-ID: <20201123074505.ds5hpqo5kgyvjksb@wittgenstein>
References: <20201115103718.298186-1-christian.brauner@ubuntu.com>
 <20201115103718.298186-15-christian.brauner@ubuntu.com>
 <CAHC9VhRqk1WMXyHTsrLcJnpxMPgJs_CxeG2uCaaBGgHqK_jj=g@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAHC9VhRqk1WMXyHTsrLcJnpxMPgJs_CxeG2uCaaBGgHqK_jj=g@mail.gmail.com>
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Jonathan Corbet <corbet@lwn.net>,
 smbarber@chromium.org, Christoph Hellwig <hch@infradead.org>,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 Jann Horn <jannh@google.com>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>, linux-fsdevel@vger.kernel.org,
 Aleksa Sarai <cyphar@cyphar.com>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Seth Forshee <seth.forshee@canonical.com>,
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

On Sun, Nov 22, 2020 at 04:18:55PM -0500, Paul Moore wrote:
> On Sun, Nov 15, 2020 at 5:39 AM Christian Brauner
> <christian.brauner@ubuntu.com> wrote:
> > When interacting with user namespace and non-user namespace aware
> > filesystem capabilities the vfs will perform various security checks to
> > determine whether or not the filesystem capabilities can be used by the
> > caller (e.g. during exec), or even whether they need to be removed. The
> > main infrastructure for this resides in the capability codepaths but they
> > are called through the LSM security infrastructure even though they are not
> > technically an LSM or optional. This extends the existing security hooks
> > security_inode_removexattr(), security_inode_killpriv(),
> > security_inode_getsecurity() to pass down the mount's user namespace and
> > makes them aware of idmapped mounts.
> > In order to actually get filesystem capabilities from disk the capability
> > infrastructure exposes the get_vfs_caps_from_disk() helper. For user
> > namespace aware filesystem capabilities a root uid is stored alongside the
> > capabilities.
> > In order to determine whether the caller can make use of the filesystem
> > capability or whether it needs to be ignored it is translated according to
> > the superblock's user namespace. If it can be translated to uid 0 according
> > to that id mapping the caller can use the filesystem capabilities stored on
> > disk. If we are accessing the inode that holds the filesystem capabilities
> > through an idmapped mount we need to map the root uid according to the
> > mount's user namespace.
> > Afterwards the checks are identical to non-idmapped mounts. Reading
> > filesystem caps from disk enforces that the root uid associated with the
> > filesystem capability must have a mapping in the superblock's user
> > namespace and that the caller is either in the same user namespace or is a
> > descendant of the superblock's user namespace. For filesystems that are
> > mountable inside user namespace the container can just mount the filesystem
> > and won't usually need to idmap it. If it does create an idmapped mount it
> > can mark it with a user namespace it has created and which is therefore a
> > descendant of the s_user_ns. For filesystems that are not mountable inside
> > user namespaces the descendant rule is trivially true because the s_user_ns
> > will be the initial user namespace.
> >
> > If the initial user namespace is passed all operations are a nop so
> > non-idmapped mounts will not see a change in behavior and will also not see
> > any performance impact.
> >
> > Cc: Christoph Hellwig <hch@lst.de>
> > Cc: David Howells <dhowells@redhat.com>
> > Cc: Al Viro <viro@zeniv.linux.org.uk>
> > Cc: linux-fsdevel@vger.kernel.org
> > Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
> 
> ...
> 
> > diff --git a/kernel/auditsc.c b/kernel/auditsc.c
> > index 8dba8f0983b5..ddb9213a3e81 100644
> > --- a/kernel/auditsc.c
> > +++ b/kernel/auditsc.c
> > @@ -1944,7 +1944,7 @@ static inline int audit_copy_fcaps(struct audit_names *name,
> >         if (!dentry)
> >                 return 0;
> >
> > -       rc = get_vfs_caps_from_disk(dentry, &caps);
> > +       rc = get_vfs_caps_from_disk(&init_user_ns, dentry, &caps);
> >         if (rc)
> >                 return rc;
> >
> > @@ -2495,7 +2495,8 @@ int __audit_log_bprm_fcaps(struct linux_binprm *bprm,
> >         ax->d.next = context->aux;
> >         context->aux = (void *)ax;
> >
> > -       get_vfs_caps_from_disk(bprm->file->f_path.dentry, &vcaps);
> > +       get_vfs_caps_from_disk(mnt_user_ns(bprm->file->f_path.mnt),
> > +                              bprm->file->f_path.dentry, &vcaps);
> 
> As audit currently records information in the context of the
> initial/host namespace I'm guessing we don't want the mnt_user_ns()
> call above; it seems like &init_user_ns would be the right choice
> (similar to audit_copy_fcaps()), yes?

Ok, sounds good. It also makes the patchset simpler.
Note that I'm currently not on the audit mailing list so this is likely
not going to show up there.

(Fwiw, I responded to you in your other mail too.)

Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
