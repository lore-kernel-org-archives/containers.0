Return-Path: <SRS0=2jwm=EH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 106DDC5DF9D
	for <containers@archiver.kernel.org>; Sun,  1 Nov 2020 14:42:19 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8F42E22253
	for <containers@archiver.kernel.org>; Sun,  1 Nov 2020 14:42:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RTKMydVt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F42E22253
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 2C9D920401;
	Sun,  1 Nov 2020 14:42:18 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Jte9RbYVeI1F; Sun,  1 Nov 2020 14:42:17 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 2D0D82013C;
	Sun,  1 Nov 2020 14:42:17 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1CFC6C088B;
	Sun,  1 Nov 2020 14:42:17 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C2945C0051
 for <containers@lists.linux-foundation.org>;
 Sun,  1 Nov 2020 14:42:14 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id B5AFE878B9
 for <containers@lists.linux-foundation.org>;
 Sun,  1 Nov 2020 14:42:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id im6UorHLZ43C
 for <containers@lists.linux-foundation.org>;
 Sun,  1 Nov 2020 14:42:13 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 7DA68878B7
 for <containers@lists.linux-foundation.org>;
 Sun,  1 Nov 2020 14:42:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
 References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
 Content-Transfer-Encoding:Content-ID:Content-Description;
 bh=JLQ1tQXc9bAL3Tc10fp3l/hgY8fF0ZkXSA4m3zd3IYM=; b=RTKMydVtbSPCwZGEemrV2Qaq7t
 ZlkjBevTM42JrP+u77IXmMh8iPEGF6aqpVgKyc6AUjmGP+mqol7anlD9ldBfIgYJAhRuSrV0new+H
 YSIqTXP3bAuELZ527GOXoMFavVhV0IJzIkBfzs2KQzeEn0ZQWDkrPH6UapYvgzp7rsxp0bksTKGBj
 vvTUjJaB6biygJluyLveCHr/mpIsrKXfJBrAaQoMTYuPQzq9DY8anRXKCMpkKGnpJ2UOskRcAQWLn
 sRKALkArBQDn9PfEAPB7vrAnaUbFoETA7stMPHzH3xyjePWgxRox5oXiVfyZUrT/lheIvlD97cB9p
 g6+8nZfA==;
Received: from hch by casper.infradead.org with local (Exim 4.92.3 #3 (Red Hat
 Linux)) id 1kZEXc-0006Hp-5O; Sun, 01 Nov 2020 14:41:08 +0000
Date: Sun, 1 Nov 2020 14:41:08 +0000
From: Christoph Hellwig <hch@infradead.org>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH 01/34] namespace: take lock_mount_hash() directly when
 changing flags
Message-ID: <20201101144108.GA23378@infradead.org>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <20201029003252.2128653-2-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201029003252.2128653-2-christian.brauner@ubuntu.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by
 casper.infradead.org. See http://www.infradead.org/rpr.html
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Miklos Szeredi <miklos@szeredi.hu>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Seth Forshee <seth.forshee@canonical.com>,
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

> index cebaa3e81794..20ee291a7af4 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -463,7 +463,6 @@ static int mnt_make_readonly(struct mount *mnt)
>  {
>  	int ret = 0;
>  
> -	lock_mount_hash();

What about adding a lockdep_assert_lock_held in all the functions
that used to take the lock to document the assumptions?

>  static int __mnt_unmake_readonly(struct mount *mnt)
>  {
> -	lock_mount_hash();
>  	mnt->mnt.mnt_flags &= ~MNT_READONLY;
> -	unlock_mount_hash();
>  	return 0;

This helper is rather pointless now.

>  static void set_mount_attributes(struct mount *mnt, unsigned int mnt_flags)
>  {
> -	lock_mount_hash();
>  	mnt_flags |= mnt->mnt.mnt_flags & ~MNT_USER_SETTABLE_MASK;
>  	mnt->mnt.mnt_flags = mnt_flags;
>  	touch_mnt_namespace(mnt->mnt_ns);
> -	unlock_mount_hash();

In linux-next there is an additional notify_mount after the unlock here.

Also while you touch this lock_mount_hash/unlock_mount_hash could be
moved to namespace.c and maked static now.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
