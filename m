Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 775EDC00A89
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 13:34:01 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DCEDA223B0
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 13:34:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCEDA223B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 3EE02866D1;
	Mon,  2 Nov 2020 13:34:00 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ABeApWXHspxU; Mon,  2 Nov 2020 13:33:59 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 1493386663;
	Mon,  2 Nov 2020 13:33:59 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id F225BC088B;
	Mon,  2 Nov 2020 13:33:58 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B315EC0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 13:33:57 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 97CAB86663
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 13:33:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id fq55TbqEsadS
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 13:33:57 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 0007386519
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 13:33:56 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kZZxl-0007ym-Lt; Mon, 02 Nov 2020 13:33:33 +0000
Date: Mon, 2 Nov 2020 14:33:31 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/34] namespace: take lock_mount_hash() directly when
 changing flags
Message-ID: <20201102133331.66v4hxtmlnjrucnn@wittgenstein>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <20201029003252.2128653-2-christian.brauner@ubuntu.com>
 <20201101144108.GA23378@infradead.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201101144108.GA23378@infradead.org>
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Miklos Szeredi <miklos@szeredi.hu>, smbarber@chromium.org,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 Jann Horn <jannh@google.com>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>, linux-fsdevel@vger.kernel.org,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
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

On Sun, Nov 01, 2020 at 02:41:08PM +0000, Christoph Hellwig wrote:
> > index cebaa3e81794..20ee291a7af4 100644
> > --- a/fs/namespace.c
> > +++ b/fs/namespace.c
> > @@ -463,7 +463,6 @@ static int mnt_make_readonly(struct mount *mnt)
> >  {
> >  	int ret = 0;
> >  
> > -	lock_mount_hash();
> 
> What about adding a lockdep_assert_lock_held in all the functions
> that used to take the lock to document the assumptions?

Good idea and will do. I wanted to do this but then didn't because I
haven't seen widespread use of lockdep assert in fs/namespace.c.

> 
> >  static int __mnt_unmake_readonly(struct mount *mnt)
> >  {
> > -	lock_mount_hash();
> >  	mnt->mnt.mnt_flags &= ~MNT_READONLY;
> > -	unlock_mount_hash();
> >  	return 0;
> 
> This helper is rather pointless now.

Ok, will remove.

> 
> >  static void set_mount_attributes(struct mount *mnt, unsigned int mnt_flags)
> >  {
> > -	lock_mount_hash();
> >  	mnt_flags |= mnt->mnt.mnt_flags & ~MNT_USER_SETTABLE_MASK;
> >  	mnt->mnt.mnt_flags = mnt_flags;
> >  	touch_mnt_namespace(mnt->mnt_ns);
> > -	unlock_mount_hash();
> 
> In linux-next there is an additional notify_mount after the unlock here.

Thanks! I can try rebasing on -next.

> 
> Also while you touch this lock_mount_hash/unlock_mount_hash could be
> moved to namespace.c and maked static now.

Ok, will try to do that.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
