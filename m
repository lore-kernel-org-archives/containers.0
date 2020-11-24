Return-Path: <SRS0=/cWj=E6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FBAFC63798
	for <containers@archiver.kernel.org>; Tue, 24 Nov 2020 13:45:22 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C1C32208CA
	for <containers@archiver.kernel.org>; Tue, 24 Nov 2020 13:45:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1C32208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 3EB948551F;
	Tue, 24 Nov 2020 13:45:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QSxPQMbD1_nf; Tue, 24 Nov 2020 13:45:20 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B8D70854E0;
	Tue, 24 Nov 2020 13:45:20 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B2B49C163C;
	Tue, 24 Nov 2020 13:45:20 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 63241C0052
 for <containers@lists.linux-foundation.org>;
 Tue, 24 Nov 2020 13:45:19 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 5AD6887253
 for <containers@lists.linux-foundation.org>;
 Tue, 24 Nov 2020 13:45:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id TJ322-en+KLT
 for <containers@lists.linux-foundation.org>;
 Tue, 24 Nov 2020 13:45:18 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from new3-smtp.messagingengine.com (new3-smtp.messagingengine.com
 [66.111.4.229])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 95F4F87061
 for <containers@lists.linux-foundation.org>;
 Tue, 24 Nov 2020 13:45:18 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailnew.nyi.internal (Postfix) with ESMTP id BF80658088F;
 Tue, 24 Nov 2020 08:45:17 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
 by compute6.internal (MEProxy); Tue, 24 Nov 2020 08:45:17 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=ICi3xGmyU3rUTgE9Z8EkpSjYA46
 p82e0AHaf1vgqc2E=; b=cKsAEMFFYuOAZzrmzVuS6fDaUdnOlWfJzkxXkSJO9Qe
 4cPiabvCXG6yJevVlNt4UrBnhnM0oAjUCKFFTuiIP7KHkNqf6wAkJ1AGkr4y8R8F
 rshUTX7y/HGl4fDGx++8ZJ8B6vtl63FtXbpf/OVRf2eLIrr6d5Xgprn9bsV5H/hc
 9HhzXpI0HlbN51t3O3r9ZYlv9IOtYlExB/SMGqvdTunWU6XcwAgzBGlIQe2rSTW7
 X7ovYra3a1oSR47nZWVdudMNKQtPD32D8Y836jecithq2pdamn29HzkVmL8scqJb
 ewbh/XND3Cf49DNyIIsIt5so+/Xp0AT9ETHPbNNIZNA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=ICi3xG
 myU3rUTgE9Z8EkpSjYA46p82e0AHaf1vgqc2E=; b=rE0LoylzT/qyJu2DBs+yai
 0QTR0Lw04fwyDVaPS1SIlsrWZ3D8qygcvuLQ0lTlybxYdeskf/8F8p5IvV4QcJng
 q/1hU9484JxUfjHiQ7wTCfZZpvGcpjBBPrP/v1/XjQCkCieLN7ky9TWOnLfN42M3
 G74z61K75HbJqkrtvsc7O10emOLD9pKCmH2ZE0v63EaN1bs2NKDLdx5vv+4F4sXe
 qruYWcanFZ9LoRjo+8qZuQVKRGIdXmo0kzVF6DfbkMvZUdiH/ITNmdMY9WNO18iC
 HP+d5mUkfTPR/M4TP6ZK/VXAm/rZAl2sCZQ4h2xqevt37qG1w1zz1h8qTKXk6WNg
 ==
X-ME-Sender: <xms:aA69X0Br1YILh_lXkRpx6LvvNOyNIehv8gRzNfgaKgTD0Ir56Adu9g>
 <xme:aA69X2hGMBre_4tf5voL5KWoXk5miZboMJ_r4hRSR0iPmcgRrOeNHNz02iRiH6CaH
 FR43LExlh7_tn0p4Bg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrudegkedgheeiucetufdoteggodetrfdotf
 fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
 uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
 cujfgurhepfffhvffukfhfgggtuggjsehttdertddttddvnecuhfhrohhmpefvhigthhho
 ucetnhguvghrshgvnhcuoehthigthhhosehthigthhhordhpihiiiigrqeenucggtffrrg
 htthgvrhhnpeegkeefjeegkedtjefgfeduleekueetjeeghffhuefgffefleehgeeifedv
 gfethfenucfkphepuddvkedruddtjedrvdeguddrudeivdenucevlhhushhtvghrufhiii
 gvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehthigthhhosehthigthhhordhpihii
 iigr
X-ME-Proxy: <xmx:aA69X3nCD5UHn1DWni0QLB36nA7OKZhoPm3JyIpKOfV1C4IJ25HRZw>
 <xmx:aA69X6zv3RpXS_6aagJ9CwWeSqjxwh94E5ITSOnTET0v3RYeZzlCAA>
 <xmx:aA69X5RYpyxLz0joaGNnnGZ-97JJOnWWSeQhgTIfS8NjKJCfehMkgQ>
 <xmx:bQ69X5wpFI1gmfBKssSD-Pp-ZlRMS83wma-FmpyGoCDeYlEyJzhB7A>
Received: from cisco (unknown [128.107.241.162])
 by mail.messagingengine.com (Postfix) with ESMTPA id 5D0B13064AB4;
 Tue, 24 Nov 2020 08:45:06 -0500 (EST)
Date: Tue, 24 Nov 2020 08:44:59 -0500
From: Tycho Andersen <tycho@tycho.pizza>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v2 07/39] mount: attach mappings to mounts
Message-ID: <20201124134459.GB52954@cisco>
References: <20201115103718.298186-1-christian.brauner@ubuntu.com>
 <20201115103718.298186-8-christian.brauner@ubuntu.com>
 <20201123154719.GD4025434@cisco> <20201123162428.GA24807@cisco>
 <20201124123035.hbv4sstyoucht7xp@wittgenstein>
 <20201124133740.GA52954@cisco>
 <20201124134035.2l36avuaqp6gxyum@wittgenstein>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201124134035.2l36avuaqp6gxyum@wittgenstein>
Cc: Andy Lutomirski <luto@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 Christoph Hellwig <hch@infradead.org>, Alban Crequy <alban@kinvolk.io>,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 Jann Horn <jannh@google.com>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Lennart Poettering <lennart@poettering.net>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 containers@lists.linux-foundation.org, linux-security-module@vger.kernel.org,
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

On Tue, Nov 24, 2020 at 02:40:35PM +0100, Christian Brauner wrote:
> On Tue, Nov 24, 2020 at 08:37:40AM -0500, Tycho Andersen wrote:
> > On Tue, Nov 24, 2020 at 01:30:35PM +0100, Christian Brauner wrote:
> > > On Mon, Nov 23, 2020 at 11:24:28AM -0500, Tycho Andersen wrote:
> > > > On Mon, Nov 23, 2020 at 10:47:19AM -0500, Tycho Andersen wrote:
> > > > > On Sun, Nov 15, 2020 at 11:36:46AM +0100, Christian Brauner wrote:
> > > > > > +static inline struct user_namespace *mnt_user_ns(const struct vfsmount *mnt)
> > > > > > +{
> > > > > > +	return mnt->mnt_user_ns;
> > > > > > +}
> > > > > 
> > > > > I think you might want a READ_ONCE() here. Right now it seems ok, since the
> > > > > mnt_user_ns can't change, but if we ever allow it to change (and I see you have
> > > > > a idmapped_mounts_wip_v2_allow_to_change_idmapping branch on your public tree
> > > > > :D), the pattern of,
> > > > > 
> > > > >         user_ns = mnt_user_ns(path->mnt);
> > > > >         if (mnt_idmapped(path->mnt)) {
> > > > >                 uid = kuid_from_mnt(user_ns, uid);
> > > > >                 gid = kgid_from_mnt(user_ns, gid);
> > > > >         }
> > > > > 
> > > > > could race.
> > > > 
> > > > Actually, isn't a race possible now?
> > > > 
> > > > kuid_from_mnt(mnt_user_ns(path->mnt) /* &init_user_ns */);
> > > > WRITE_ONCE(mnt->mnt.mnt_user_ns, user_ns);
> > > > WRITE_ONCE(m->mnt.mnt_flags, flags);
> > > > kgid_from_mnt(mnt_user_ns(path->mnt) /* the right user ns */);
> > > > 
> > > > So maybe it should be:
> > > > 
> > > >          if (mnt_idmapped(path->mnt)) {
> > > >                  barrier();
> > > >                  user_ns = mnt_user_ns(path->mnt);
> > > >                  uid = kuid_from_mnt(user_ns, uid);
> > > >                  gid = kgid_from_mnt(user_ns, gid);
> > > >          }
> > > > 
> > > > since there's no data dependency between mnt_idmapped() and
> > > > mnt_user_ns()?
> > > 
> > > I think I had something to handle this case in another branch of mine.
> > > The READ_ONCE() you mentioned in another patch I had originally dropped
> > > because I wasn't sure whether it works on pointers but after talking to
> > > Jann and David it seems that it handles pointers fine.
> > > Let me take a look and fix it in the next version. I just finished
> > > porting the test suite to xfstests as Christoph requested and I'm
> > > looking at this now.
> > 
> > Another way would be to just have mnt_idmapped() test
> > mnt_user_ns() != &init_user_ns instead of the flags; then I think you
> > get the data dependency and thus correct ordering for free.
> 
> I indeed dropped mnt_idmapped() which is unnecessary. :)

It still might be a nice helper to prevent people from checking the
flags and forgetting that there's a memory ordering issue, though.

> I think we should still use smp_store_release() in mnt_user_ns() paired
> with smp_load_acquire() in do_idmap_mount() thought.

Sounds reasonable.

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
