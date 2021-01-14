Return-Path: <SRS0=onox=GR=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9302BC433DB
	for <containers@archiver.kernel.org>; Thu, 14 Jan 2021 20:43:57 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2257323AFC
	for <containers@archiver.kernel.org>; Thu, 14 Jan 2021 20:43:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2257323AFC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id BE32D8745F;
	Thu, 14 Jan 2021 20:43:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id JxknWrQ1wZvX; Thu, 14 Jan 2021 20:43:56 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 44164873A3;
	Thu, 14 Jan 2021 20:43:56 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 29995C0893;
	Thu, 14 Jan 2021 20:43:56 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C2C8BC013A
 for <containers@lists.linux-foundation.org>;
 Thu, 14 Jan 2021 20:43:54 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id A95B7873A3
 for <containers@lists.linux-foundation.org>;
 Thu, 14 Jan 2021 20:43:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 7Fjg6HmrY2uB
 for <containers@lists.linux-foundation.org>;
 Thu, 14 Jan 2021 20:43:52 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.7.6
Received: from mail107.syd.optusnet.com.au (mail107.syd.optusnet.com.au
 [211.29.132.53])
 by hemlock.osuosl.org (Postfix) with ESMTP id 260F787397
 for <containers@lists.linux-foundation.org>;
 Thu, 14 Jan 2021 20:43:52 +0000 (UTC)
Received: from dread.disaster.area (pa49-179-167-107.pa.nsw.optusnet.com.au
 [49.179.167.107])
 by mail107.syd.optusnet.com.au (Postfix) with ESMTPS id 84A94D5E47A;
 Fri, 15 Jan 2021 07:43:35 +1100 (AEDT)
Received: from dave by dread.disaster.area with local (Exim 4.92.3)
 (envelope-from <david@fromorbit.com>)
 id 1l09Sw-006UW3-9I; Fri, 15 Jan 2021 07:43:34 +1100
Date: Fri, 15 Jan 2021 07:43:34 +1100
From: Dave Chinner <david@fromorbit.com>
To: "Darrick J. Wong" <djwong@kernel.org>
Subject: Re: [PATCH v5 00/42] idmapped mounts
Message-ID: <20210114204334.GK331610@dread.disaster.area>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
 <20210114171241.GA1164240@magnolia>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210114171241.GA1164240@magnolia>
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.3 cv=F8MpiZpN c=1 sm=1 tr=0 cx=a_idp_d
 a=+wqVUQIkAh0lLYI+QRsciw==:117 a=+wqVUQIkAh0lLYI+QRsciw==:17
 a=kj9zAlcOel0A:10 a=EmqxpYm9HcoA:10 a=7-415B0cAAAA:8
 a=In5g3teRgiYIkOrEuZ4A:9 a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>, David Howells <dhowells@redhat.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Paul Moore <paul@paul-moore.com>, Jonathan Corbet <corbet@lwn.net>,
 smbarber@chromium.org, Christoph Hellwig <hch@infradead.org>,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 linux-fsdevel@vger.kernel.org, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Seth Forshee <seth.forshee@canonical.com>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>, linux-xfs@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, Alban Crequy <alban@kinvolk.io>,
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
> 
> Does quota still work after this patchset is applied?  There isn't any
> mention of that in the cover letter and I don't see a code patch, so
> does that mean everything just works?  I'm particularly curious about
> whether there can exist processes with CAP_SYS_ADMIN and an idmapped
> mount?  Syscalls like bulkstat and quotactl present file [ug]ids to
> programs, but afaict there won't be any translating going on?

bulkstat is not allowed inside user namespaces. It's an init
namespace only thing because it provides unchecked/unbounded access
to all inodes in the filesystem, not just those contained within a
specific mount container.

Hence I don't think bulkstat output (and other initns+root only
filesystem introspection APIs) should be subject to or concerned
about idmapping.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
