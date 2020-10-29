Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0315DC2D0A3
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 21:04:05 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2204520790
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 21:04:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2204520790
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 5A71186B75;
	Thu, 29 Oct 2020 21:04:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id CJ6YSX1pytij; Thu, 29 Oct 2020 21:04:01 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B8E8385D44;
	Thu, 29 Oct 2020 21:04:01 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9CF0FC0859;
	Thu, 29 Oct 2020 21:04:01 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id BD7D1C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 21:04:00 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id AFE0D8753F
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 21:04:00 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id rzU80yyval7X
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 21:03:59 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from new3-smtp.messagingengine.com (new3-smtp.messagingengine.com
 [66.111.4.229])
 by hemlock.osuosl.org (Postfix) with ESMTPS id A5C2C8753D
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 21:03:58 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailnew.nyi.internal (Postfix) with ESMTP id AC1F958082E;
 Thu, 29 Oct 2020 17:03:57 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
 by compute6.internal (MEProxy); Thu, 29 Oct 2020 17:03:57 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=OFDRTCtnKdzjskJAELoL2NDWdi7
 W9Q1qkTpEeba42A8=; b=Zq0S8hfa/XWJW/whuWujAhD8l7azs2tc2OdTi3i7tN9
 CGs0K/UKQqYNXx/Cg3D6rZspjB2Zj8LjRbv9mDWjAvrjzuFJIKM4fQzzSl0Y39Ap
 cuJQYZctelJaVhle1nzdW1+PHIkKlhVRv/+r6otFzLpUCVSeawdXhqEybv4yivXb
 yQ5qfwHYHzrdujoa5KF9QsSqbIusAskcTk3qh1xGzxT1/7CY+DogGBt2ZBi3HhEj
 JTiYdrnvpXsoFZhpQint9HVjiSRoBeKWL84GMB6tbsUdyjWd+gn2/AZEPExtldRp
 /zamW/MtCki4RQZVOOmytbCLSPG5/CZIZ6PlKn60NXA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=OFDRTC
 tnKdzjskJAELoL2NDWdi7W9Q1qkTpEeba42A8=; b=E5CpsRaZ0Tu2T2+hCD8mYQ
 X9oeG43tBge60tzVd6VRQddyyhVFUex3CtnjLD+YBLNxQQpOLjSp+Yn1tnh4Mncw
 eVJbR3z+eKgepaJRPyfGW2HfvHk0AqPMMomB6Ir+7VFm8mqLLbecB8eQ+D/uHRb0
 hRK0GMutxRx/VTkEeesPHZXB+JsPd8Gx9wYmqeDdbO4tYNO58nEU6PjSe+pOGyC4
 MXoGpjO/88pfncvo8CLL28wYyNS6ynoihvm7n0YpHIj4POBD53r28olAXFeioq5y
 84dCumtDjpmEVakC9wyYsIL23I2Z13KmtRk6Nx2XZ27pnxVsGA6Avs+EpclY9adA
 ==
X-ME-Sender: <xms:OS6bX17y2rChRn6myfBFu8PJ72ZKrV9ueWGDwCpnQ0VLe5o9QzKRgw>
 <xme:OS6bXy7Clz2wduRmpz7a2ekaV7sgjKgDOZgPpTfIMOyea9lOp3bnYEkrgy7DMBTl7
 uhbvm4xTOy6HzKzCYM>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrleefgddugeefucetufdoteggodetrfdotf
 fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
 uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
 cujfgurhepfffhvffukfhfgggtuggjsehttdertddttddvnecuhfhrohhmpefvhigthhho
 ucetnhguvghrshgvnhcuoehthigthhhosehthigthhhordhpihiiiigrqeenucggtffrrg
 htthgvrhhnpeegkeefjeegkedtjefgfeduleekueetjeeghffhuefgffefleehgeeifedv
 gfethfenucfkphepuddvkedruddtjedrvdeguddrudekieenucevlhhushhtvghrufhiii
 gvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehthigthhhosehthigthhhordhpihii
 iigr
X-ME-Proxy: <xmx:OS6bX8dZ22_VtTfHRy8ro-DqoWupaN92F8fkrD12QX4SEnF8i26igA>
 <xmx:OS6bX-JvZU0o5gMwGrx8SkROSlmlRdlNaZDQ3hePbM1NKqUIl2xMmQ>
 <xmx:OS6bX5JzUXOe-tzqUlu14Hzeo18Gz9w2oUbIjHk8py9nASNnAUuHpQ>
 <xmx:PS6bX1qdvuSj9JeN5gin3MrPvQhViju6wyRCtD8hM7P1OMUsqzhP2w>
Received: from cisco (unknown [128.107.241.186])
 by mail.messagingengine.com (Postfix) with ESMTPA id 3EF4D328005A;
 Thu, 29 Oct 2020 17:03:46 -0400 (EDT)
Date: Thu, 29 Oct 2020 15:03:44 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH 00/34] fs: idmapped mounts
Message-ID: <20201029210344.GA135035@cisco>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <87pn51ghju.fsf@x220.int.ebiederm.org>
 <20201029161231.GA108315@cisco>
 <87blglc77y.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <87blglc77y.fsf@x220.int.ebiederm.org>
Cc: Andy Lutomirski <luto@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>, Miklos Szeredi <miklos@szeredi.hu>,
 smbarber@chromium.org, Christoph Hellwig <hch@infradead.org>,
 Casey Schaufler <casey@schaufler-ca.com>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Lennart Poettering <lennart@poettering.net>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 containers@lists.linux-foundation.org, Jonathan Corbet <corbet@lwn.net>,
 linux-unionfs@vger.kernel.org, linux-security-module@vger.kernel.org,
 linux-audit@redhat.com, linux-api@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, Alban Crequy <alban@kinvolk.io>,
 linux-integrity@vger.kernel.org,
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

Hi Eric,

On Thu, Oct 29, 2020 at 11:44:33AM -0500, Eric W. Biederman wrote:
> Tycho Andersen <tycho@tycho.pizza> writes:
> 
> > Hi Eric,
> >
> > On Thu, Oct 29, 2020 at 10:47:49AM -0500, Eric W. Biederman wrote:
> >> Christian Brauner <christian.brauner@ubuntu.com> writes:
> >> 
> >> > Hey everyone,
> >> >
> >> > I vanished for a little while to focus on this work here so sorry for
> >> > not being available by mail for a while.
> >> >
> >> > Since quite a long time we have issues with sharing mounts between
> >> > multiple unprivileged containers with different id mappings, sharing a
> >> > rootfs between multiple containers with different id mappings, and also
> >> > sharing regular directories and filesystems between users with different
> >> > uids and gids. The latter use-cases have become even more important with
> >> > the availability and adoption of systemd-homed (cf. [1]) to implement
> >> > portable home directories.
> >> 
> >> Can you walk us through the motivating use case?
> >> 
> >> As of this year's LPC I had the distinct impression that the primary use
> >> case for such a feature was due to the RLIMIT_NPROC problem where two
> >> containers with the same users still wanted different uid mappings to
> >> the disk because the users were conflicting with each other because of
> >> the per user rlimits.
> >> 
> >> Fixing rlimits is straight forward to implement, and easier to manage
> >> for implementations and administrators.
> >
> > Our use case is to have the same directory exposed to several
> > different containers which each have disjoint ID mappings.
> 
> Why do the you have disjoint ID mappings for the users that are writing
> to disk with the same ID?

We don't today; right now we have a service that runs as root, since
that's the only thing that can be made to work. See below...

> >> Reading up on systemd-homed it appears to be a way to have encrypted
> >> home directories.  Those home directories can either be encrypted at the
> >> fs or at the block level.  Those home directories appear to have the
> >> goal of being luggable between systems.  If the systems in question
> >> don't have common administration of uids and gids after lugging your
> >> encrypted home directory to another system chowning the files is
> >> required.
> >> 
> >> Is that the use case you are looking at removing the need for
> >> systemd-homed to avoid chowning after lugging encrypted home directories
> >> from one system to another?  Why would it be desirable to avoid the
> >> chown?
> >
> > Not just systemd-homed, but LXD has to do this,
> 
> I asked why the same disk users are assigned different kuids and the
> only reason I have heard that LXD does this is the RLIMIT_NPROC problem.
> 
> Perhaps there is another reason.
> 
> In part this is why I am eager to hear peoples use case, and why I was
> trying very hard to make certain we get the requirements.
> 
> I want the real requirements though and some thought, not just we did
> this and it hurts.  Changning the uids on write is a very hard problem,
> and not just in implementating it but also in maintaining and
> understanding what is going on.

We have N services which we don't want to be able to talk to each
other, so we run them in containers with isolated uid maps. However,
we do want them to be able to share a single directory of metadata.
We'd like to bind mount this directory into each container with the
correct user ns mapping to accomplish this; this is the primary driver
for putting the parameterization on the struct vfsmount.

We could map some shared uid into all the containers. But then we have
to have some service running as root in the containers to shuttle the
data back and forth between the shared uid the uid of the actual
service.

So goals are:

* directory shared between containers
* containers can talk to this directory as "normal" uids, so there's
  no data shuttling
* container's rootfs is still disjoint, so writes by "normal" uids in
  each container are disjoint from the other and they can't talk
  except via the shared directory

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
