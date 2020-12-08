Return-Path: <SRS0=pVZl=FM=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AF39C433FE
	for <containers@archiver.kernel.org>; Tue,  8 Dec 2020 10:38:09 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 85402221F7
	for <containers@archiver.kernel.org>; Tue,  8 Dec 2020 10:38:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85402221F7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 0BF4687545;
	Tue,  8 Dec 2020 10:38:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id k2bcCtNrr4gv; Tue,  8 Dec 2020 10:38:07 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 5EFC68753D;
	Tue,  8 Dec 2020 10:38:07 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 430C0C0893;
	Tue,  8 Dec 2020 10:38:07 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 69DABC013B
 for <containers@lists.linux-foundation.org>;
 Tue,  8 Dec 2020 10:38:05 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 4AEF187542
 for <containers@lists.linux-foundation.org>;
 Tue,  8 Dec 2020 10:38:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id hzdlujY6WgMl
 for <containers@lists.linux-foundation.org>;
 Tue,  8 Dec 2020 10:38:04 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 57A4A8753D
 for <containers@lists.linux-foundation.org>;
 Tue,  8 Dec 2020 10:38:04 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kmaMp-0003ta-EI; Tue, 08 Dec 2020 10:37:11 +0000
Date: Tue, 8 Dec 2020 11:37:07 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v4 06/40] fs: add mount_setattr()
Message-ID: <20201208103707.px6buexwuusn6d3f@wittgenstein>
References: <20201203235736.3528991-1-christian.brauner@ubuntu.com>
 <20201203235736.3528991-7-christian.brauner@ubuntu.com>
 <20201207171456.GC13614@lst.de>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201207171456.GC13614@lst.de>
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
 Stephen Smalley <stephen.smalley.work@gmail.com>,
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

On Mon, Dec 07, 2020 at 06:14:56PM +0100, Christoph Hellwig wrote:
> > +	switch (attr->propagation) {
> > +	case 0:
> > +		kattr->propagation = 0;
> > +		break;
> > +	case MS_UNBINDABLE:
> > +		kattr->propagation = MS_UNBINDABLE;
> > +		break;
> > +	case MS_PRIVATE:
> > +		kattr->propagation = MS_PRIVATE;
> > +		break;
> > +	case MS_SLAVE:
> > +		kattr->propagation = MS_SLAVE;
> > +		break;
> > +	case MS_SHARED:
> > +		kattr->propagation = MS_SHARED;
> > +		break;
> > +	default:
> > +		return -EINVAL;
> > +	}
> 
> This can be shortened to:
> 
> #define MOUNT_SETATTR_PROPAGATION_FLAGS \
> 	(MS_UNBINDABLE | MS_PRIVATE | MS_SLAVE | MS_SHARED)
> 
> 	if (attr->propagation & ~MOUNT_SETATTR_PROPAGATION_FLAGS)
> 		return -EINVAL;
> 	if (hweight32(attr->propagation & MOUNT_SETATTR_PROPAGATION_FLAGS) > 1)
> 		return -EINVAL;
> 	kattr->propagation = attr->propagation;

Looks good! I've applied that.

> 
> > +asmlinkage long sys_mount_setattr(int dfd, const char __user *path, unsigned int flags,
> 
> Overly long line.

Folded after @path now.

> 
> Otherwise looks good:
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks, I've pushed out the changes to:
https://git.kernel.org/brauner/h/idmapped_mounts
the original v4 can now be found at:
https://git.kernel.org/brauner/h/idmapped_mounts_v4

You want a v5 with the changes you requested before you continue
reviewing? Otherwise I'll just let you go through v4.

Thanks!
Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
