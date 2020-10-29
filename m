Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CD9EC4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 16:23:25 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B879520704
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 16:23:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B879520704
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hallyn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 224A186657;
	Thu, 29 Oct 2020 16:23:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id GsGZv7zCZpVQ; Thu, 29 Oct 2020 16:23:22 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 65358860D6;
	Thu, 29 Oct 2020 16:23:22 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 46EE0C0859;
	Thu, 29 Oct 2020 16:23:22 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1E44EC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:23:21 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 0C95086B80
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:23:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 5j0UoGt6kQ-P
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:23:19 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 7DAC386B5A
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:23:19 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
 id C24CF11F1; Thu, 29 Oct 2020 11:23:17 -0500 (CDT)
Date: Thu, 29 Oct 2020 11:23:17 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Tycho Andersen <tycho@tycho.pizza>
Subject: Re: [PATCH 00/34] fs: idmapped mounts
Message-ID: <20201029162317.GA12461@mail.hallyn.com>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <87pn51ghju.fsf@x220.int.ebiederm.org>
 <20201029161231.GA108315@cisco>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201029161231.GA108315@cisco>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Andy Lutomirski <luto@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 David Howells <dhowells@redhat.com>, Andreas Dilger <adilger.kernel@dilger.ca>,
 Miklos Szeredi <miklos@szeredi.hu>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>, Alban Crequy <alban@kinvolk.io>,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 Jann Horn <jannh@google.com>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Lennart Poettering <lennart@poettering.net>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 containers@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>,
 linux-unionfs@vger.kernel.org, linux-security-module@vger.kernel.org,
 linux-audit@redhat.com, "Eric W. Biederman" <ebiederm@xmission.com>,
 linux-api@vger.kernel.org, Casey Schaufler <casey@schaufler-ca.com>,
 linux-fsdevel@vger.kernel.org, linux-integrity@vger.kernel.org,
 Stephen Smalley <stephen.smalley.work@gmail.com>, Todd Kjos <tkjos@google.com>
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

On Thu, Oct 29, 2020 at 10:12:31AM -0600, Tycho Andersen wrote:
> Hi Eric,
> 
> On Thu, Oct 29, 2020 at 10:47:49AM -0500, Eric W. Biederman wrote:
> > Christian Brauner <christian.brauner@ubuntu.com> writes:
> > 
> > > Hey everyone,
> > >
> > > I vanished for a little while to focus on this work here so sorry for
> > > not being available by mail for a while.
> > >
> > > Since quite a long time we have issues with sharing mounts between
> > > multiple unprivileged containers with different id mappings, sharing a
> > > rootfs between multiple containers with different id mappings, and also
> > > sharing regular directories and filesystems between users with different
> > > uids and gids. The latter use-cases have become even more important with
> > > the availability and adoption of systemd-homed (cf. [1]) to implement
> > > portable home directories.
> > 
> > Can you walk us through the motivating use case?
> > 
> > As of this year's LPC I had the distinct impression that the primary use
> > case for such a feature was due to the RLIMIT_NPROC problem where two
> > containers with the same users still wanted different uid mappings to
> > the disk because the users were conflicting with each other because of
> > the per user rlimits.
> > 
> > Fixing rlimits is straight forward to implement, and easier to manage
> > for implementations and administrators.
> 
> Our use case is to have the same directory exposed to several
> different containers which each have disjoint ID mappings.
> 
> > Reading up on systemd-homed it appears to be a way to have encrypted
> > home directories.  Those home directories can either be encrypted at the
> > fs or at the block level.  Those home directories appear to have the
> > goal of being luggable between systems.  If the systems in question
> > don't have common administration of uids and gids after lugging your
> > encrypted home directory to another system chowning the files is
> > required.
> > 
> > Is that the use case you are looking at removing the need for
> > systemd-homed to avoid chowning after lugging encrypted home directories
> > from one system to another?  Why would it be desirable to avoid the
> > chown?
> 
> Not just systemd-homed, but LXD has to do this, as does our
> application at Cisco, and presumably others.
> 
> Several reasons:
> 
> * the chown is slow
> * the chown requires somewhere to write the delta in metadata (e.g. an
>   overlay workdir, or an LV or something), and there are N copies of
>   this delta, one for each container.
> * it means we need to have a +w filesystem at some point during
>   execution.
> * it's ugly :). Conceptually, the kernel solves the uid shifting
>   problem for us for most other kernel subsystems (including in a
>   limited way fscaps) by configuring a user namespace. It feels like
>   we should be able to do the same with the VFS.

And chown prevents the same inode from being shared by different
containers through different id mappings.  You can overlay, but then
they can't actually share updates.

-serge
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
