Return-Path: <SRS0=BFUz=E4=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FDF5C5519F
	for <containers@archiver.kernel.org>; Sun, 22 Nov 2020 21:19:15 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D41F620782
	for <containers@archiver.kernel.org>; Sun, 22 Nov 2020 21:19:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=paul-moore-com.20150623.gappssmtp.com header.i=@paul-moore-com.20150623.gappssmtp.com header.b="SbzxRegB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D41F620782
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=paul-moore.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 74C3884414;
	Sun, 22 Nov 2020 21:19:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nI-igkA485Z7; Sun, 22 Nov 2020 21:19:12 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 89A9E85450;
	Sun, 22 Nov 2020 21:19:12 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6CE40C0891;
	Sun, 22 Nov 2020 21:19:12 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 14C1AC0052
 for <containers@lists.linux-foundation.org>;
 Sun, 22 Nov 2020 21:19:11 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 0F5848543A
 for <containers@lists.linux-foundation.org>;
 Sun, 22 Nov 2020 21:19:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id pANM2AK471fA
 for <containers@lists.linux-foundation.org>;
 Sun, 22 Nov 2020 21:19:09 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com
 [209.85.208.65])
 by whitealder.osuosl.org (Postfix) with ESMTPS id BD21E8547B
 for <containers@lists.linux-foundation.org>;
 Sun, 22 Nov 2020 21:19:08 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id d18so15095543edt.7
 for <containers@lists.linux-foundation.org>;
 Sun, 22 Nov 2020 13:19:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=paul-moore-com.20150623.gappssmtp.com; s=20150623;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=TnYAfYzK9z2CU6n9f6EQEQr3kUIpHz74aN1sscdy0dE=;
 b=SbzxRegB0eYgWQjrzVNZhGj7xGAuKSyhCYUAI+WyaPpWKWhEN6iqWX+bEcJKbYoB0L
 e+h2FSiOvFHziiUa44whQFraYTHOU8p50iPMrz8231dDk9fhDLvFKe/Cjby4M/d+4U6r
 W07v+9gVUkUhjxH3Geo4u+yVOo02UkCH74LdJNvQKI4YCSBilG3kHI2Y62XjETJSZ/uX
 MlbS32EkSSCU1n+fb8kYyduz0/3kWYDqvMuc0IaCRimx25Yqqx0UR7QjDDjbfQt8oUSD
 2DZTJmGkdogVeaLOCgp12rxjJJwbqtgcnvKaMV8RD8yIeQUYlTY9lypDDNNSf4zLZOfd
 JgQQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=TnYAfYzK9z2CU6n9f6EQEQr3kUIpHz74aN1sscdy0dE=;
 b=fqJhwj7M4bD+q00QpegMGwlUNENGTFGn9i8t5aAkBAcS2p24uOUhwXSUt84SUW3fi5
 qWRiwBLPyo0kBOaqrU4FwqLiMMAsEZflYQvq/jQdq3bgTAUOeX1Hrz9SBCWo7mlxL9tt
 UkEmf+ZF9efZvsukNoxEhftig0pakbu42o/EypIsPBChs2ImjTbY9X7hlB0DzR6+L35a
 tLGKUD2ZCLyLUC1W9eTtkbC8NJkhP2qrffjQWY7bgENcN9ihGuJM2sQvcS+cejIOQALC
 wI7Gj1mws4j6XK4FsSDlCH3tlyq31GDrP6of+jy3AtdJRxb+10vBrqKPW610n/TRG0P8
 9FcA==
X-Gm-Message-State: AOAM533oytQEg15qXxsIw7oLlxkW1+5Mg1K6d9uM8Wy1ZT834T//+Z6U
 fLnQswubn2CKbQM3/s0dRFhx4XxzUVulfY/ClTj0
X-Google-Smtp-Source: ABdhPJxWDVFzpcLiB/ip+VH1A679zZkgv5lzs7PTKex+TlERHeuhuyes1CoTwmWTuMvWpYfUdNgQEs+SrGqG31WGjjs=
X-Received: by 2002:aa7:de01:: with SMTP id h1mr44059484edv.269.1606079946987; 
 Sun, 22 Nov 2020 13:19:06 -0800 (PST)
MIME-Version: 1.0
References: <20201115103718.298186-1-christian.brauner@ubuntu.com>
 <20201115103718.298186-15-christian.brauner@ubuntu.com>
In-Reply-To: <20201115103718.298186-15-christian.brauner@ubuntu.com>
From: Paul Moore <paul@paul-moore.com>
Date: Sun, 22 Nov 2020 16:18:55 -0500
Message-ID: <CAHC9VhRqk1WMXyHTsrLcJnpxMPgJs_CxeG2uCaaBGgHqK_jj=g@mail.gmail.com>
Subject: Re: [PATCH v2 14/39] commoncap: handle idmapped mounts
To: Christian Brauner <christian.brauner@ubuntu.com>
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

On Sun, Nov 15, 2020 at 5:39 AM Christian Brauner
<christian.brauner@ubuntu.com> wrote:
> When interacting with user namespace and non-user namespace aware
> filesystem capabilities the vfs will perform various security checks to
> determine whether or not the filesystem capabilities can be used by the
> caller (e.g. during exec), or even whether they need to be removed. The
> main infrastructure for this resides in the capability codepaths but they
> are called through the LSM security infrastructure even though they are not
> technically an LSM or optional. This extends the existing security hooks
> security_inode_removexattr(), security_inode_killpriv(),
> security_inode_getsecurity() to pass down the mount's user namespace and
> makes them aware of idmapped mounts.
> In order to actually get filesystem capabilities from disk the capability
> infrastructure exposes the get_vfs_caps_from_disk() helper. For user
> namespace aware filesystem capabilities a root uid is stored alongside the
> capabilities.
> In order to determine whether the caller can make use of the filesystem
> capability or whether it needs to be ignored it is translated according to
> the superblock's user namespace. If it can be translated to uid 0 according
> to that id mapping the caller can use the filesystem capabilities stored on
> disk. If we are accessing the inode that holds the filesystem capabilities
> through an idmapped mount we need to map the root uid according to the
> mount's user namespace.
> Afterwards the checks are identical to non-idmapped mounts. Reading
> filesystem caps from disk enforces that the root uid associated with the
> filesystem capability must have a mapping in the superblock's user
> namespace and that the caller is either in the same user namespace or is a
> descendant of the superblock's user namespace. For filesystems that are
> mountable inside user namespace the container can just mount the filesystem
> and won't usually need to idmap it. If it does create an idmapped mount it
> can mark it with a user namespace it has created and which is therefore a
> descendant of the s_user_ns. For filesystems that are not mountable inside
> user namespaces the descendant rule is trivially true because the s_user_ns
> will be the initial user namespace.
>
> If the initial user namespace is passed all operations are a nop so
> non-idmapped mounts will not see a change in behavior and will also not see
> any performance impact.
>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: David Howells <dhowells@redhat.com>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: linux-fsdevel@vger.kernel.org
> Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>

...

> diff --git a/kernel/auditsc.c b/kernel/auditsc.c
> index 8dba8f0983b5..ddb9213a3e81 100644
> --- a/kernel/auditsc.c
> +++ b/kernel/auditsc.c
> @@ -1944,7 +1944,7 @@ static inline int audit_copy_fcaps(struct audit_names *name,
>         if (!dentry)
>                 return 0;
>
> -       rc = get_vfs_caps_from_disk(dentry, &caps);
> +       rc = get_vfs_caps_from_disk(&init_user_ns, dentry, &caps);
>         if (rc)
>                 return rc;
>
> @@ -2495,7 +2495,8 @@ int __audit_log_bprm_fcaps(struct linux_binprm *bprm,
>         ax->d.next = context->aux;
>         context->aux = (void *)ax;
>
> -       get_vfs_caps_from_disk(bprm->file->f_path.dentry, &vcaps);
> +       get_vfs_caps_from_disk(mnt_user_ns(bprm->file->f_path.mnt),
> +                              bprm->file->f_path.dentry, &vcaps);

As audit currently records information in the context of the
initial/host namespace I'm guessing we don't want the mnt_user_ns()
call above; it seems like &init_user_ns would be the right choice
(similar to audit_copy_fcaps()), yes?

>         ax->fcap.permitted = vcaps.permitted;
>         ax->fcap.inheritable = vcaps.inheritable;

-- 
paul moore
www.paul-moore.com
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
