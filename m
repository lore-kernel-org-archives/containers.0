Return-Path: <SRS0=onox=GR=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59544C433E0
	for <containers@archiver.kernel.org>; Thu, 14 Jan 2021 17:56:00 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0221C23B54
	for <containers@archiver.kernel.org>; Thu, 14 Jan 2021 17:55:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0221C23B54
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 41AC986BE6;
	Thu, 14 Jan 2021 17:55:59 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id rz-NqdD2bv2F; Thu, 14 Jan 2021 17:55:56 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 4E7FC868F8;
	Thu, 14 Jan 2021 17:55:56 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 41497C088B;
	Thu, 14 Jan 2021 17:55:56 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id F3AB6C013A
 for <containers@lists.linux-foundation.org>;
 Thu, 14 Jan 2021 17:55:54 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id E47F286BA4
 for <containers@lists.linux-foundation.org>;
 Thu, 14 Jan 2021 17:55:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 9Pf04HW4Fnxr
 for <containers@lists.linux-foundation.org>;
 Thu, 14 Jan 2021 17:55:53 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by whitealder.osuosl.org (Postfix) with ESMTPS id A8BD8868F8
 for <containers@lists.linux-foundation.org>;
 Thu, 14 Jan 2021 17:55:53 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1l06pa-0006dG-Cq; Thu, 14 Jan 2021 17:54:46 +0000
Date: Thu, 14 Jan 2021 18:54:41 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: "Darrick J. Wong" <djwong@kernel.org>
Subject: Re: [PATCH v5 00/42] idmapped mounts
Message-ID: <20210114175441.v5cbtzad3ejjcjsw@wittgenstein>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
 <20210114171241.GA1164240@magnolia>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210114171241.GA1164240@magnolia>
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

On Thu, Jan 14, 2021 at 09:12:41AM -0800, Darrick J. Wong wrote:
> On Tue, Jan 12, 2021 at 11:00:42PM +0100, Christian Brauner wrote:
> > Hey everyone,
> > 
> > The only major change is the inclusion of hch's patch to port XFS to
> > support idmapped mounts. Thanks to Christoph for doing that work.
> 
> Yay :)
> 
> > (For a full list of major changes between versions see the end of this
> >  cover letter.
> >  Please also note the large xfstests testsuite in patch 42 that has been
> >  kept as part of this series. It verifies correct vfs behavior with and
> >  without idmapped mounts including covering newer vfs features such as
> >  io_uring.
> >  I currently still plan to target the v5.12 merge window.)
> > 
> > With this patchset we make it possible to attach idmappings to mounts,
> > i.e. simply put different bind mounts can expose the same file or
> > directory with different ownership.
> > Shifting of ownership on a per-mount basis handles a wide range of
> > long standing use-cases. Here are just a few:
> > - Shifting of a subset of ownership-less filesystems (vfat) for use by
> >   multiple users, effectively allowing for DAC on such devices
> >   (systemd, Android, ...)
> > - Allow remapping uid/gid on external filesystems or paths (USB sticks,
> >   network filesystem, ...) to match the local system's user and groups.
> >   (David Howells intends to port AFS as a first candidate.)
> > - Shifting of a container rootfs or base image without having to mangle
> >   every file (runc, Docker, containerd, k8s, LXD, systemd ...)
> > - Sharing of data between host or privileged containers with
> >   unprivileged containers (runC, Docker, containerd, k8s, LXD, ...)
> > - Data sharing between multiple user namespaces with incompatible maps
> >   (LXD, k8s, ...)
> 
> That sounds neat.  AFAICT, the VFS passes the filesystem a mount userns
> structure, which is then carried down the call stack to whatever
> functions actually care about mapping kernel [ug]ids to their ondisk
> versions?

Yes. This requires not too many changes to the actual filesystems as you
can see from the xfs conversion that Christoph has done.

> 
> Does quota still work after this patchset is applied?  There isn't any
> mention of that in the cover letter and I don't see a code patch, so
> does that mean everything just works?  I'm particularly curious about

The most interesting quota codepaths I audited are dquot_transfer that
transfers quota from one inode to another one during setattr. That
happens via a struct iattr which will already contain correctly
translated ia_uid and ia_gid values according to the mount the caller is
coming from. I'll take another close look at that now and add tests for
that if I can find some in xfstests.

> whether there can exist processes with CAP_SYS_ADMIN and an idmapped
> mount?  Syscalls like bulkstat and quotactl present file [ug]ids to

Yes, that should be possible.

> programs, but afaict there won't be any translating going on?

quotactl operates on the superblock. So the caller would need a mapping
in the user namespace of the superblock. That doesn't need to change.
But we could in the future extend this to be on a per-mount basis if
this was a desired use-case. I don't think it needs to happen right now
though.

> 
> (To be fair, bulkstat is an xfs-only thing, but quota control isn't.)

I'm certain we'll find more things to cover after the first version has
landed. :)
We for sure won't cover it all in the first iteration.

> 
> I'll start skimming the patchset...

Thanks!
Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
