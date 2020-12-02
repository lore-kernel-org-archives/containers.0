Return-Path: <SRS0=YKjC=FG=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F18F0C64E7C
	for <containers@archiver.kernel.org>; Wed,  2 Dec 2020 09:58:46 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 328F920679
	for <containers@archiver.kernel.org>; Wed,  2 Dec 2020 09:58:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 328F920679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 877C38729B;
	Wed,  2 Dec 2020 09:58:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id M9T32BDb09m6; Wed,  2 Dec 2020 09:58:44 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id C65C087276;
	Wed,  2 Dec 2020 09:58:44 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A8C00C0859;
	Wed,  2 Dec 2020 09:58:44 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D0514C0052
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Dec 2020 09:58:42 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id A9C702E1D6
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Dec 2020 09:58:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id CK7Qf3GpCvJx
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Dec 2020 09:58:41 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by silver.osuosl.org (Postfix) with ESMTPS id 8E518203A7
 for <containers@lists.linux-foundation.org>;
 Wed,  2 Dec 2020 09:58:41 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kkOtQ-0004uq-9l; Wed, 02 Dec 2020 09:57:48 +0000
Date: Wed, 2 Dec 2020 10:57:45 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v3 04/38] fs: add mount_setattr()
Message-ID: <20201202095745.bhazopysyw5kbiee@wittgenstein>
References: <20201128213527.2669807-1-christian.brauner@ubuntu.com>
 <20201128213527.2669807-5-christian.brauner@ubuntu.com>
 <20201201104907.GD27730@lst.de>
 <20201202094218.ym5zqnulwz6gj6eo@wittgenstein>
 <20201202094751.GA6129@lst.de> <20201202095547.GA6408@lst.de>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201202095547.GA6408@lst.de>
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Paul Moore <paul@paul-moore.com>, Jonathan Corbet <corbet@lwn.net>,
 smbarber@chromium.org, Christoph Hellwig <hch@infradead.org>,
 Alban Crequy <alban@kinvolk.io>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
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

On Wed, Dec 02, 2020 at 10:55:47AM +0100, Christoph Hellwig wrote:
> On Wed, Dec 02, 2020 at 10:47:51AM +0100, Christoph Hellwig wrote:
> > On Wed, Dec 02, 2020 at 10:42:18AM +0100, Christian Brauner wrote:
> > > > > +	if (upper_32_bits(attr->attr_set))
> > > > > +		return -EINVAL;
> > > > > +	if (build_attr_flags(lower_32_bits(attr->attr_set), &kattr->attr_set))
> > > > > +		return -EINVAL;
> > > > > +
> > > > > +	if (upper_32_bits(attr->attr_clr))
> > > > > +		return -EINVAL;
> > > > > +	if (build_attr_flags(lower_32_bits(attr->attr_clr), &kattr->attr_clr))
> > > > > +		return -EINVAL;
> > > > 
> > > > What is so magic about the upper and lower 32 bits?
> > > 
> > > Nothing apart from the fact that they arent't currently valid. I can
> > > think about reworking these lines. Or do you already have a preferred
> > > way of doing this in mind?
> > 
> > Just turn the attr_flags argument to build_attr_flags into a u64 and
> > the first sanity check there will catch all invalid flags, no matter
> > where they are places.  That should also generate more efficient code.
> 
> And while we're at it:  the check for valid flags in the current
> code is a little weird, given that build_attr_flags checks for
> them, and but sys_fsmount also has its own slightly narrower checks.
> 
> I think it might make sense to split the validity check out of
> build_attr_flags. E.g. something like:

Sounds good!
If we make this a preparatory patch do you want to be recorded in the
author field?

> 
> static unsigned int attr_flags_to_mnt_flags(u64 attr_flags)
> {
> 	unsigned int mnt_flags = 0;
> 
> 	if (attr_flags & MOUNT_ATTR_RDONLY)
> 		mnt_flags |= MNT_READONLY;
> 	if (attr_flags & MOUNT_ATTR_NOSUID)
> 		mnt_flags |= MNT_NOSUID;
> 	if (attr_flags & MOUNT_ATTR_NODEV)
> 		mnt_flags |= MNT_NODEV;
> 	if (attr_flags & MOUNT_ATTR_NOEXEC)
> 		mnt_flags |= MNT_NOEXEC;
> 	if (attr_flags & MOUNT_ATTR_NODIRATIME)
> 		mnt_flags |= MNT_NODIRATIME;
> 
> 	return mnt_flags;
> }
> 
> #define MOUNT_SETATTR_VALID_FLAGS \
> 	(MOUNT_ATTR_RDONLY | MOUNT_ATTR_NOSUID | MOUNT_ATTR_NODEV | \
> 	 MOUNT_ATTR_NOEXEC | MOUNT_ATTR__ATIME | MOUNT_ATTR_NODIRATIME | \
> 	 MOUNT_ATTR_IDMAP)
> 
> static int build_mount_kattr(const struct mount_attr *attr, size_t usize,
> 			     struct mount_kattr *kattr, unsigned int flags)
> {
> 	...
> 
> 	if ((attr->attr_set | attr->attr_clr) & ~MOUNT_SETATTR_VALID_FLAGS)
> 		return -EINVAL;
> 	kattr->attr_set = attr_flags_to_mnt_flags(attr->attr_set);
> 	kattr->attr_clr = attr_flags_to_mnt_flags(attr->attr_clr);
> 	...
> }
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
