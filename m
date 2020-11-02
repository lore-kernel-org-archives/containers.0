Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94533C00A89
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 13:30:05 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D65B3223B0
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 13:30:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D65B3223B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 653B486E14;
	Mon,  2 Nov 2020 13:30:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id OUeXVtOp9eXy; Mon,  2 Nov 2020 13:30:03 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 6034A86E19;
	Mon,  2 Nov 2020 13:30:03 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 454BDC088B;
	Mon,  2 Nov 2020 13:30:03 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 723AEC0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 13:30:01 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 63CEC86854
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 13:30:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id NgJ2VuMOwgzC
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 13:30:00 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 32B108681C
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 13:30:00 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kZZtu-0007a7-Ep; Mon, 02 Nov 2020 13:29:34 +0000
Date: Mon, 2 Nov 2020 14:29:32 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 05/34] fs: introduce MOUNT_ATTR_IDMAP
Message-ID: <20201102132932.pseijsddvxo5hgpf@wittgenstein>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <20201029003252.2128653-6-christian.brauner@ubuntu.com>
 <20201101144544.GC23378@infradead.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201101144544.GC23378@infradead.org>
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

On Sun, Nov 01, 2020 at 02:45:44PM +0000, Christoph Hellwig wrote:
> On Thu, Oct 29, 2020 at 01:32:23AM +0100, Christian Brauner wrote:
> > Introduce a new mount bind mount property to allow idmapping mounts. The
> > MOUNT_ATTR_IDMAP flag can be set via the new mount_setattr() syscall
> > together with a file descriptor referring to a user namespace.
> 
> Shouldn't this go to the end of the series once all the infrastructure
> is in place?

Yeah, good idea. (I mostly did it to keep compile-times short when
rebasing.)

> 
> > +config IDMAP_MOUNTS
> > +	bool "Support id mappings per mount"
> > +	default n
> 
> n is the default default.

Ah, thanks.

> 
> But why do we need a config option here anyway?

My main concern was people complaining about code they want to compile
out. I've been burnt by that before but I'm happy to remove the config
option and make this unconditional.

> 
> > +#ifdef CONFIG_IDMAP_MOUNTS
> > +		if (kattr->attr_set & MNT_IDMAPPED) {
> > +			struct user_namespace *user_ns;
> > +			struct vfsmount *vmnt;
> 
> All the code here looks like it should go into a helper.

Will do.

> 
> > +				struct user_namespace *user_ns = READ_ONCE(m->mnt.mnt_user_ns);
> > +				WRITE_ONCE(m->mnt.mnt_user_ns, get_user_ns(kattr->userns));
> 
> More unreadable long lines.

Will wrap. I have somewhat adapted to the more lax 100 limit but I'm
happy to stick to 80.

> 
> > +	if (attr->attr_set & MOUNT_ATTR_IDMAP) {
> > +		struct ns_common *ns;
> > +		struct user_namespace *user_ns;
> > +		struct file *file;
> > +
> > +		file = fget(attr->userns);
> 
> The code here looks like another candidate for a self contained helper.

Noted.

> 
> > +
> > +static inline struct user_namespace *mnt_user_ns(const struct vfsmount *mnt)
> > +{
> > +#ifdef CONFIG_IDMAP_MOUNTS
> > +	return READ_ONCE(mnt->mnt_user_ns);
> > +#else
> > +	return &init_user_ns;
> > +#endif
> 
> How is the READ_ONCE on a pointer going to work?

Honestly, this is me following a pattern I've seen in other places and
it's mostly about visually indicating concurrency but I'll drop it.

Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
