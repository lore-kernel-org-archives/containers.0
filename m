Return-Path: <SRS0=NWjS=FF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AE9BC64E7A
	for <containers@archiver.kernel.org>; Tue,  1 Dec 2020 10:49:19 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A023F20674
	for <containers@archiver.kernel.org>; Tue,  1 Dec 2020 10:49:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A023F20674
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 4A18288086;
	Tue,  1 Dec 2020 10:49:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bIpj8nr6MNuj; Tue,  1 Dec 2020 10:49:15 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 1887687A23;
	Tue,  1 Dec 2020 10:49:15 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 021F6C163C;
	Tue,  1 Dec 2020 10:49:15 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 2812CC0052
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 10:49:13 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 2329A8567A
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 10:49:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id gjek-QjSE5yR
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 10:49:12 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 35C9B85643
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 10:49:12 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
 id 71BEF6736F; Tue,  1 Dec 2020 11:49:07 +0100 (CET)
Date: Tue, 1 Dec 2020 11:49:07 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v3 04/38] fs: add mount_setattr()
Message-ID: <20201201104907.GD27730@lst.de>
References: <20201128213527.2669807-1-christian.brauner@ubuntu.com>
 <20201128213527.2669807-5-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201128213527.2669807-5-christian.brauner@ubuntu.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>, Alban Crequy <alban@kinvolk.io>,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>, fstests@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, linux-fsdevel@vger.kernel.org,
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

Lots of crazy long lines in the patch.  Remember that you should only
go past 80 lines if it clearly improves readability, and I don't
think it does anywhere in here.

> index a7cd0f64faa4..a5a6c470dc07 100644
> --- a/fs/internal.h
> +++ b/fs/internal.h
> @@ -82,6 +82,14 @@ int may_linkat(struct path *link);
>  /*
>   * namespace.c
>   */
> +struct mount_kattr {
> +	unsigned int attr_set;
> +	unsigned int attr_clr;
> +	unsigned int propagation;
> +	unsigned int lookup_flags;
> +	bool recurse;
> +};

Even with the whole series applied this structure is only used in
namespace.c, so it might be worth moving there.

> +static inline int mnt_hold_writers(struct mount *mnt)
>  {
> -	int ret = 0;
> -
>  	mnt->mnt.mnt_flags |= MNT_WRITE_HOLD;
>  	/*
>  	 * After storing MNT_WRITE_HOLD, we'll read the counters. This store
> @@ -497,15 +495,29 @@ static int mnt_make_readonly(struct mount *mnt)
>  	 * we're counting up here.
>  	 */
>  	if (mnt_get_writers(mnt) > 0)
> -		ret = -EBUSY;
> -	else
> -		mnt->mnt.mnt_flags |= MNT_READONLY;
> +		return -EBUSY;
> +
> +	return 0;
> +}
> +
> +static inline void mnt_unhold_writers(struct mount *mnt)
> +{
>  	/*
>  	 * MNT_READONLY must become visible before ~MNT_WRITE_HOLD, so writers
>  	 * that become unheld will see MNT_READONLY.
>  	 */
>  	smp_wmb();
>  	mnt->mnt.mnt_flags &= ~MNT_WRITE_HOLD;
> +}
> +
> +static int mnt_make_readonly(struct mount *mnt)
> +{
> +	int ret;
> +
> +	ret = mnt_hold_writers(mnt);
> +	if (!ret)
> +		mnt->mnt.mnt_flags |= MNT_READONLY;
> +	mnt_unhold_writers(mnt);
>  	return ret;
>  }
>  
> @@ -3438,6 +3450,33 @@ SYSCALL_DEFINE5(mount, char __user *, dev_name, char __user *, dir_name,
>  	return ret;
>  }

This refactoring seems worth a little prep patch.

>  
> +static int build_attr_flags(unsigned int attr_flags, unsigned int *flags)
> +{
> +	unsigned int aflags = 0;
> +
> +	if (attr_flags & ~(MOUNT_ATTR_RDONLY |
> +			   MOUNT_ATTR_NOSUID |
> +			   MOUNT_ATTR_NODEV |
> +			   MOUNT_ATTR_NOEXEC |
> +			   MOUNT_ATTR__ATIME |
> +			   MOUNT_ATTR_NODIRATIME))
> +		return -EINVAL;
> +
> +	if (attr_flags & MOUNT_ATTR_RDONLY)
> +		aflags |= MNT_READONLY;
> +	if (attr_flags & MOUNT_ATTR_NOSUID)
> +		aflags |= MNT_NOSUID;
> +	if (attr_flags & MOUNT_ATTR_NODEV)
> +		aflags |= MNT_NODEV;
> +	if (attr_flags & MOUNT_ATTR_NOEXEC)
> +		aflags |= MNT_NOEXEC;
> +	if (attr_flags & MOUNT_ATTR_NODIRATIME)
> +		aflags |= MNT_NODIRATIME;
> +
> +	*flags = aflags;
> +	return 0;
> +}

Same for adding this helper.

> +	*kattr = (struct mount_kattr){

Missing whitespace before the {.

> +	switch (attr->propagation) {
> +	case MAKE_PROPAGATION_UNCHANGED:
> +		kattr->propagation = 0;
> +		break;
> +	case MAKE_PROPAGATION_UNBINDABLE:
> +		kattr->propagation = MS_UNBINDABLE;
> +		break;
> +	case MAKE_PROPAGATION_PRIVATE:
> +		kattr->propagation = MS_PRIVATE;
> +		break;
> +	case MAKE_PROPAGATION_DEPENDENT:
> +		kattr->propagation = MS_SLAVE;
> +		break;
> +	case MAKE_PROPAGATION_SHARED:
> +		kattr->propagation = MS_SHARED;
> +		break;
> +	default:

Any reason to not just reuse the MS_* flags in the new API?  Yes, your
new names are more descriptive, but having different names for the same
thing is also rather confusing.

> +	if (upper_32_bits(attr->attr_set))
> +		return -EINVAL;
> +	if (build_attr_flags(lower_32_bits(attr->attr_set), &kattr->attr_set))
> +		return -EINVAL;
> +
> +	if (upper_32_bits(attr->attr_clr))
> +		return -EINVAL;
> +	if (build_attr_flags(lower_32_bits(attr->attr_clr), &kattr->attr_clr))
> +		return -EINVAL;

What is so magic about the upper and lower 32 bits?

> +		return -EINVAL;
> +	else if ((attr->attr_clr & MOUNT_ATTR__ATIME) &&
> +		 ((attr->attr_clr & MOUNT_ATTR__ATIME) != MOUNT_ATTR__ATIME))
> +		return -EINVAL;

No need for the else here.

That being said I'd reword the thing to be a little more obvious:

	if (attr->attr_clr & MOUNT_ATTR__ATIME) {
		if ((attr->attr_clr & MOUNT_ATTR__ATIME) != MOUNT_ATTR__ATIME)
			return -EINVAL;

		... code doing the update of the atime flags here
	} else {
		if (attr->attr_set & MOUNT_ATTR__ATIME)
			return -EINVAL;
	}


> +/* Change propagation through mount_setattr(). */
> +enum propagation_type {
> +	MAKE_PROPAGATION_UNCHANGED	= 0, /* Don't change mount propagation (default). */
> +	MAKE_PROPAGATION_UNBINDABLE	= 1, /* Make unbindable. */
> +	MAKE_PROPAGATION_PRIVATE	= 2, /* Do not receive or send mount events. */
> +	MAKE_PROPAGATION_DEPENDENT	= 3, /* Only receive mount events. */
> +	MAKE_PROPAGATION_SHARED		= 4, /* Send and receive mount events. */
> +};

FYI, in uapis using defines instead of enums is usually the better
choice, as that allows userspace to probe for later added defines.

But if we use MS_* here that would be void anyway.

> +/* List of all mount_attr versions. */
> +#define MOUNT_ATTR_SIZE_VER0	24 /* sizeof first published struct */
> +#define MOUNT_ATTR_SIZE_LATEST	MOUNT_ATTR_SIZE_VER0

The _LATEST things is pretty dangerous as there basically is no safe
and correct way for userspace to use it.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
