Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40758C4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 16:12:59 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 689DF20756
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 16:12:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 689DF20756
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id C1A1A228D1;
	Thu, 29 Oct 2020 16:12:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id CJAYMspujjyV; Thu, 29 Oct 2020 16:12:56 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 9CD4422882;
	Thu, 29 Oct 2020 16:12:56 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 848A4C0859;
	Thu, 29 Oct 2020 16:12:56 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1E53AC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:12:50 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id ED22222882
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:12:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 1gt9fAYkvy8k
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:12:48 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from new2-smtp.messagingengine.com (new2-smtp.messagingengine.com
 [66.111.4.224])
 by silver.osuosl.org (Postfix) with ESMTPS id 84589214E6
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:12:47 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailnew.nyi.internal (Postfix) with ESMTP id B0FBF5804FF;
 Thu, 29 Oct 2020 12:12:46 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
 by compute6.internal (MEProxy); Thu, 29 Oct 2020 12:12:46 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=P3H7++7ohzwZSKiHclbUQW/pMpP
 PM20RUjr0vwjcWzg=; b=VqvJSZ+kgIjRhSMPuWkM6YDE/D3rMX51krN86qvnJFe
 t6L535e5BA2QStoJNA+RVyjzabqEhG71JqaO8WygfImxQh3eO1yugw0cQ1f6/D+x
 RJexaRl01JGjPuy/2u6p8WNqwmoLDrYVXirpwkW6CARwo1XBL/tHokqmLv9XA7P0
 +XoDDFcT5mKTfv1i+F2R9/0hJxKL1XjAqBalnIM8t/eWmA6yiiGa0FGhpTG4ufEp
 lfhwTZOqp+2S51/B5u5aJ/pENKIphC8kl/VWMjGFXuE7O2ob2N9SbbFl4mIAxpTc
 kcFRmk4CDbfmHIuu4hwDJSdzhnnkE6MCHGPoEtZoT3g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=P3H7++
 7ohzwZSKiHclbUQW/pMpPPM20RUjr0vwjcWzg=; b=VVcaB5NGGIJcsOhylpxvG0
 bLg15EM9sLyc2RFlaetZFjZKrqRXmUGVDf8SOxHf3wiquxJ0IwJH2GHpPq+yC9WI
 cxz0rmI1YyRnm4vAnIO6GHZzQaEo9n/7wN2rhet2cRJz5kQORYp/lmtEykF75MXZ
 +NLlMV6RpzG1nrCk+HlYmTunosJx/zPfuTBBXJyl4je+GoS/Ma4peQqAU82BKcwe
 PEkDHsg8LAdPvheLOizq40ovpG1xkaLFlNXsXyPiOcfEjdT2bpPAO+UW/pIQq8n7
 mnKW4d4DHVWWeKZVASrueo9c0cQR3Rucq15+HFqGHcOx+GO97bpfi2P1vQt+5Xyw
 ==
X-ME-Sender: <xms:--maX1rRqh0KZqhW2Z7AyHuUczn1x4P54yW4xoJjtIvU8RXplx_bpg>
 <xme:--maX3obwGzTVn7GWYS9M-wUqz0RyVfrkjHeqp8s9uRiWiqwUN7ugUfFTHl1nJC26
 n999TfXwYrqieojFDg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrleefgdekhecutefuodetggdotefrodftvf
 curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
 uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
 fjughrpeffhffvuffkfhggtggujgesthdtredttddtvdenucfhrhhomhepvfihtghhohcu
 tehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrfgrth
 htvghrnhepgeekfeejgeektdejgfefudelkeeuteejgefhhfeugffffeelheegieefvdfg
 tefhnecukfhppeduvdekrddutdejrddvgedurddukeeinecuvehluhhsthgvrhfuihiivg
 eptdenucfrrghrrghmpehmrghilhhfrhhomhepthihtghhohesthihtghhohdrphhiiiii
 rg
X-ME-Proxy: <xmx:--maXyOnU_7UhZ-YvhBzWFdOwzcv_cNigldRxHNCNMr2-4CZbRCHjQ>
 <xmx:--maXw4I7yR7n7WnkXxmWYWw4VuZwzEwIdGko1LoNHqvTr-P-7Sapw>
 <xmx:--maX07GLkgGUsr8nVTJ2ATGLIXkf77Pl8NtPTfVnJwTVe_bdrRUpg>
 <xmx:_umaX5bZNLZmlDR8-RmfzykMWB-vuW5GetrVaQslKzFmb-l9WfgQDA>
Received: from cisco (unknown [128.107.241.186])
 by mail.messagingengine.com (Postfix) with ESMTPA id 925993280064;
 Thu, 29 Oct 2020 12:12:37 -0400 (EDT)
Date: Thu, 29 Oct 2020 10:12:31 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH 00/34] fs: idmapped mounts
Message-ID: <20201029161231.GA108315@cisco>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
 <87pn51ghju.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <87pn51ghju.fsf@x220.int.ebiederm.org>
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

On Thu, Oct 29, 2020 at 10:47:49AM -0500, Eric W. Biederman wrote:
> Christian Brauner <christian.brauner@ubuntu.com> writes:
> 
> > Hey everyone,
> >
> > I vanished for a little while to focus on this work here so sorry for
> > not being available by mail for a while.
> >
> > Since quite a long time we have issues with sharing mounts between
> > multiple unprivileged containers with different id mappings, sharing a
> > rootfs between multiple containers with different id mappings, and also
> > sharing regular directories and filesystems between users with different
> > uids and gids. The latter use-cases have become even more important with
> > the availability and adoption of systemd-homed (cf. [1]) to implement
> > portable home directories.
> 
> Can you walk us through the motivating use case?
> 
> As of this year's LPC I had the distinct impression that the primary use
> case for such a feature was due to the RLIMIT_NPROC problem where two
> containers with the same users still wanted different uid mappings to
> the disk because the users were conflicting with each other because of
> the per user rlimits.
> 
> Fixing rlimits is straight forward to implement, and easier to manage
> for implementations and administrators.

Our use case is to have the same directory exposed to several
different containers which each have disjoint ID mappings.

> Reading up on systemd-homed it appears to be a way to have encrypted
> home directories.  Those home directories can either be encrypted at the
> fs or at the block level.  Those home directories appear to have the
> goal of being luggable between systems.  If the systems in question
> don't have common administration of uids and gids after lugging your
> encrypted home directory to another system chowning the files is
> required.
> 
> Is that the use case you are looking at removing the need for
> systemd-homed to avoid chowning after lugging encrypted home directories
> from one system to another?  Why would it be desirable to avoid the
> chown?

Not just systemd-homed, but LXD has to do this, as does our
application at Cisco, and presumably others.

Several reasons:

* the chown is slow
* the chown requires somewhere to write the delta in metadata (e.g. an
  overlay workdir, or an LV or something), and there are N copies of
  this delta, one for each container.
* it means we need to have a +w filesystem at some point during
  execution.
* it's ugly :). Conceptually, the kernel solves the uid shifting
  problem for us for most other kernel subsystems (including in a
  limited way fscaps) by configuring a user namespace. It feels like
  we should be able to do the same with the VFS.

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
