Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 285E0C4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 02:27:56 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 73B2320735
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 02:27:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73B2320735
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id DBC288711E;
	Thu, 29 Oct 2020 02:27:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fyhsXiwdSZ7e; Thu, 29 Oct 2020 02:27:53 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id E2AFD870CD;
	Thu, 29 Oct 2020 02:27:53 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id BC272C088B;
	Thu, 29 Oct 2020 02:27:53 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id ADE15C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 02:27:52 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 9052785FA2
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 02:27:52 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id mJ0_HbshgWaF
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 02:27:51 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.7.6
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au
 [211.29.132.246])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 2530485EC4
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 02:27:51 +0000 (UTC)
Received: from dread.disaster.area (pa49-179-6-140.pa.nsw.optusnet.com.au
 [49.179.6.140])
 by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 5E73A58C9C6;
 Thu, 29 Oct 2020 13:27:34 +1100 (AEDT)
Received: from dave by dread.disaster.area with local (Exim 4.92.3)
 (envelope-from <david@fromorbit.com>)
 id 1kXxf3-005Q9Q-Vd; Thu, 29 Oct 2020 13:27:33 +1100
Date: Thu, 29 Oct 2020 13:27:33 +1100
From: Dave Chinner <david@fromorbit.com>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH 00/34] fs: idmapped mounts
Message-ID: <20201029022733.GB306023@dread.disaster.area>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.3 cv=YKPhNiOx c=1 sm=1 tr=0 cx=a_idp_d
 a=uDU3YIYVKEaHT0eX+MXYOQ==:117 a=uDU3YIYVKEaHT0eX+MXYOQ==:17
 a=8nJEP1OIZ-IA:10 a=afefHYAZSVUA:10 a=7-415B0cAAAA:8
 a=7FRnUTRuY4COAZBt7UUA:9 a=wPNLvfGTeEIA:10 a=biEYGPWJfzWAr4FL6Ov7:22
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
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Thu, Oct 29, 2020 at 01:32:18AM +0100, Christian Brauner wrote:
> Hey everyone,
> =

> I vanished for a little while to focus on this work here so sorry for
> not being available by mail for a while.
> =

> Since quite a long time we have issues with sharing mounts between
> multiple unprivileged containers with different id mappings, sharing a
> rootfs between multiple containers with different id mappings, and also
> sharing regular directories and filesystems between users with different
> uids and gids. The latter use-cases have become even more important with
> the availability and adoption of systemd-homed (cf. [1]) to implement
> portable home directories.
> =

> The solutions we have tried and proposed so far include the introduction
> of fsid mappings, a tiny overlay based filesystem, and an approach to
> call override creds in the vfs. None of these solutions have covered all
> of the above use-cases.
> =

> The solution proposed here has it's origins in multiple discussions
> during Linux Plumbers 2017 during and after the end of the containers
> microconference.
> To the best of my knowledge this involved Aleksa, St=E9phane, Eric, David,
> James, and myself. A variant of the solution proposed here has also been
> discussed, again to the best of my knowledge, after a Linux conference
> in St. Petersburg in Russia between Christoph, Tycho, and myself in 2017
> after Linux Plumbers.
> I've taken the time to finally implement a working version of this
> solution over the last weeks to the best of my abilities. Tycho has
> signed up for this sligthly crazy endeavour as well and he has helped
> with the conversion of the xattr codepaths.
> =

> The core idea is to make idmappings a property of struct vfsmount
> instead of tying it to a process being inside of a user namespace which
> has been the case for all other proposed approaches.
> It means that idmappings become a property of bind-mounts, i.e. each
> bind-mount can have a separate idmapping. This has the obvious advantage
> that idmapped mounts can be created inside of the initial user
> namespace, i.e. on the host itself instead of requiring the caller to be
> located inside of a user namespace. This enables such use-cases as e.g.
> making a usb stick available in multiple locations with different
> idmappings (see the vfat port that is part of this patch series).
> =

> The vfsmount struct gains a new struct user_namespace member. The
> idmapping of the user namespace becomes the idmapping of the mount. A
> caller that is either privileged with respect to the user namespace of
> the superblock of the underlying filesystem or a caller that is
> privileged with respect to the user namespace a mount has been idmapped
> with can create a new bind-mount and mark it with a user namespace. The
> user namespace the mount will be marked with can be specified by passing
> a file descriptor refering to the user namespace as an argument to the
> new mount_setattr() syscall together with the new MOUNT_ATTR_IDMAP flag.
> By default vfsmounts are marked with the initial user namespace and no
> behavioral or performance changes should be observed. All mapping
> operations are nops for the initial user namespace.
> =

> When a file/inode is accessed through an idmapped mount the i_uid and
> i_gid of the inode will be remapped according to the user namespace the
> mount has been marked with. When a new object is created based on the
> fsuid and fsgid of the caller they will similarly be remapped according
> to the user namespace of the mount they care created from.
> =

> This means the user namespace of the mount needs to be passed down into
> a few relevant inode_operations. This mostly includes inode operations
> that create filesystem objects or change file attributes.

That's really quite ... messy.

Maybe I'm missing something, but if you have the user_ns to be used
for the VFS operation we are about to execute then why can't we use
the same model as current_fsuid/current_fsgid() for passing the
filesystem credentials down to the filesystem operations?  i.e.
attach it to the current->cred->fs_userns, and then the filesystem
code that actually needs to know the current userns can call
current_fs_user_ns() instead of current_user_ns().  i.e.

#define current_fs_user_ns()	\
	(current->cred->fs_userns ? current->cred->fs_userns \
				  : current->cred->userns)

At this point, the filesystem will now always have the correct
userns it is supposed to use for mapping the uid/gid, right?

Also, if we are passing work off to worker threads, duplicating
the current creds will capture this information and won't leave
random landmines where stuff doesn't work as it should because the
worker thread is unaware of the userns that it is supposed to be
doing filesytsem operations under...

Cheers,

Dave.
-- =

Dave Chinner
david@fromorbit.com
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
