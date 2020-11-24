Return-Path: <SRS0=/cWj=E6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20AEDC2D0E4
	for <containers@archiver.kernel.org>; Tue, 24 Nov 2020 13:37:57 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 567B220708
	for <containers@archiver.kernel.org>; Tue, 24 Nov 2020 13:37:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 567B220708
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id C9FD686418;
	Tue, 24 Nov 2020 13:37:55 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0yQ-AuzfCoL0; Tue, 24 Nov 2020 13:37:51 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id A2D1F86151;
	Tue, 24 Nov 2020 13:37:51 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6FC67C163C;
	Tue, 24 Nov 2020 13:37:51 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B76FDC0052
 for <containers@lists.linux-foundation.org>;
 Tue, 24 Nov 2020 13:37:50 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id A83CB87021
 for <containers@lists.linux-foundation.org>;
 Tue, 24 Nov 2020 13:37:50 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id no6mxiQLNN+g
 for <containers@lists.linux-foundation.org>;
 Tue, 24 Nov 2020 13:37:50 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from new3-smtp.messagingengine.com (new3-smtp.messagingengine.com
 [66.111.4.229])
 by hemlock.osuosl.org (Postfix) with ESMTPS id DECF18701F
 for <containers@lists.linux-foundation.org>;
 Tue, 24 Nov 2020 13:37:49 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailnew.nyi.internal (Postfix) with ESMTP id 03CF5580256;
 Tue, 24 Nov 2020 08:37:48 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
 by compute6.internal (MEProxy); Tue, 24 Nov 2020 08:37:48 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=uv9+67CM32DtT2uoIG78LMUWQ3F
 HveZ09a8+wzAIcWA=; b=U/eyAQRLfVtaavmRhsvScBWLPCTFD0bLl9KkSzkoKyS
 gt5U01e3oaGk/jyy4pFMZ+8ulVBYbhJ8c0He8zilnyxyhkiV0WyFr8llB8DTiWhH
 CDKLtOuXaE67sqCSund2C9w/kOkpoWWv6hUE4hL0OjEgQKAKdCTBviAY/louk6Zb
 N/p6amzuGCcdXyIQk8RsAV+8n2tpAqL7B/aM6y69xAzIOHA9psGEEboJuMCHeAE+
 jVHJwS7X+LCzPXoVa9C5QCzm6ipPQqv387BswVul6TH/6zrMqRVKw6pJGGGydknF
 i1x5wVjity2yfp1j5RaYEuCaa0K36QjODnlRiW/j6KA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=uv9+67
 CM32DtT2uoIG78LMUWQ3FHveZ09a8+wzAIcWA=; b=LR5KZzQogEx5iAx+dyRx8m
 u5g0sIQeoqpxT0fTAYAc75OENu09NNEM13reHtwurFeIiHJ22QQd8OxFKGcNAzZQ
 ABzWnoaouJveA7adqKYcx/vKlnGaprrJznYk78r9qijnjJx/R6dnismRi2oEf2pp
 Drb2oeFws50oL5Zm6xg+cvf3sBBYivD9fC+E4WreC3TzyFGn4all4cC0hscvkr67
 /3MByqSnDYjaHMTLkvtV+F8lIHSnJTLkZ+0EFPhcAuIQuDuGPnQhAOIbyiH5t7u3
 Y9ibRHo/V84c70JWJLcryClLgpvZEUFj2V1Z2/5deS1r0aYQFgby0kF2SlUq8FJw
 ==
X-ME-Sender: <xms:pwy9X5M_ACo94HsBXsgyImOEMRQQoFdFcq3EtlqTaaxCCd4BFzqDEQ>
 <xme:pwy9X78_s3hE_ElDASGb77BlytsqcsGg0zcssDlDU4Ql_Rt9XrsR3cNACtn39HvvT
 UHmjDHy5ArSpL-fn54>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrudegkedgheegucetufdoteggodetrfdotf
 fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
 uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
 cujfgurhepfffhvffukfhfgggtuggjsehttdertddttddvnecuhfhrohhmpefvhigthhho
 ucetnhguvghrshgvnhcuoehthigthhhosehthigthhhordhpihiiiigrqeenucggtffrrg
 htthgvrhhnpeegkeefjeegkedtjefgfeduleekueetjeeghffhuefgffefleehgeeifedv
 gfethfenucfkphepgeejrddvtddurdeghedrvddtvdenucevlhhushhtvghrufhiiigvpe
 dtnecurfgrrhgrmhepmhgrihhlfhhrohhmpehthigthhhosehthigthhhordhpihiiiigr
X-ME-Proxy: <xmx:pwy9X4QWDM2nHwbiJORO4fga02ADLx16tq-gRl9xj2Y-LPG1Ku8VHg>
 <xmx:pwy9X1ua86jK84g-oXIqHQMRutsT-qo273xGyCA0Y2oiXCI5FYQYBg>
 <xmx:pwy9Xxc_jj4nBsFlFglvzIkTQjBqKui0TagunPBlh3tKCIFjbAhe1w>
 <xmx:qwy9X__qsMIWsaR5_7GrnO7gNxT5VH0YIx4udN-wMcwRrXSRAhsoqA>
Received: from cisco (unknown [47.201.45.202])
 by mail.messagingengine.com (Postfix) with ESMTPA id D78B7328005E;
 Tue, 24 Nov 2020 08:37:41 -0500 (EST)
Date: Tue, 24 Nov 2020 08:37:40 -0500
From: Tycho Andersen <tycho@tycho.pizza>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v2 07/39] mount: attach mappings to mounts
Message-ID: <20201124133740.GA52954@cisco>
References: <20201115103718.298186-1-christian.brauner@ubuntu.com>
 <20201115103718.298186-8-christian.brauner@ubuntu.com>
 <20201123154719.GD4025434@cisco> <20201123162428.GA24807@cisco>
 <20201124123035.hbv4sstyoucht7xp@wittgenstein>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201124123035.hbv4sstyoucht7xp@wittgenstein>
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

On Tue, Nov 24, 2020 at 01:30:35PM +0100, Christian Brauner wrote:
> On Mon, Nov 23, 2020 at 11:24:28AM -0500, Tycho Andersen wrote:
> > On Mon, Nov 23, 2020 at 10:47:19AM -0500, Tycho Andersen wrote:
> > > On Sun, Nov 15, 2020 at 11:36:46AM +0100, Christian Brauner wrote:
> > > > +static inline struct user_namespace *mnt_user_ns(const struct vfsmount *mnt)
> > > > +{
> > > > +	return mnt->mnt_user_ns;
> > > > +}
> > > 
> > > I think you might want a READ_ONCE() here. Right now it seems ok, since the
> > > mnt_user_ns can't change, but if we ever allow it to change (and I see you have
> > > a idmapped_mounts_wip_v2_allow_to_change_idmapping branch on your public tree
> > > :D), the pattern of,
> > > 
> > >         user_ns = mnt_user_ns(path->mnt);
> > >         if (mnt_idmapped(path->mnt)) {
> > >                 uid = kuid_from_mnt(user_ns, uid);
> > >                 gid = kgid_from_mnt(user_ns, gid);
> > >         }
> > > 
> > > could race.
> > 
> > Actually, isn't a race possible now?
> > 
> > kuid_from_mnt(mnt_user_ns(path->mnt) /* &init_user_ns */);
> > WRITE_ONCE(mnt->mnt.mnt_user_ns, user_ns);
> > WRITE_ONCE(m->mnt.mnt_flags, flags);
> > kgid_from_mnt(mnt_user_ns(path->mnt) /* the right user ns */);
> > 
> > So maybe it should be:
> > 
> >          if (mnt_idmapped(path->mnt)) {
> >                  barrier();
> >                  user_ns = mnt_user_ns(path->mnt);
> >                  uid = kuid_from_mnt(user_ns, uid);
> >                  gid = kgid_from_mnt(user_ns, gid);
> >          }
> > 
> > since there's no data dependency between mnt_idmapped() and
> > mnt_user_ns()?
> 
> I think I had something to handle this case in another branch of mine.
> The READ_ONCE() you mentioned in another patch I had originally dropped
> because I wasn't sure whether it works on pointers but after talking to
> Jann and David it seems that it handles pointers fine.
> Let me take a look and fix it in the next version. I just finished
> porting the test suite to xfstests as Christoph requested and I'm
> looking at this now.

Another way would be to just have mnt_idmapped() test
mnt_user_ns() != &init_user_ns instead of the flags; then I think you
get the data dependency and thus correct ordering for free.

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
