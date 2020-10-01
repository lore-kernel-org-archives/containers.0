Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77794C4727E
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 23:19:34 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C3065206E3
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 23:19:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3065206E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 547A3869CF;
	Thu,  1 Oct 2020 23:19:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id WC1a3SkR0+Qv; Thu,  1 Oct 2020 23:19:32 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 45B8B86984;
	Thu,  1 Oct 2020 23:19:32 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 201DFC016F;
	Thu,  1 Oct 2020 23:19:32 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0BE54C0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 23:19:31 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id EDE41869CF
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 23:19:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id x8xMKIVNXGRa
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 23:19:29 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from wnew4-smtp.messagingengine.com (wnew4-smtp.messagingengine.com
 [64.147.123.18])
 by whitealder.osuosl.org (Postfix) with ESMTPS id B77AE86984
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 23:19:29 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailnew.west.internal (Postfix) with ESMTP id EC59BC3C;
 Thu,  1 Oct 2020 19:19:27 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
 by compute6.internal (MEProxy); Thu, 01 Oct 2020 19:19:29 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=Tlpv2xmpynLkoXih5aMS72+SXJr
 nQuj1c9PDv1ck7SY=; b=kAnlT5uGdLP7ZHMd/rvKFoooU2LN0P/lAm1T9lGIii9
 PlCZZtGPEs9KopNalPJ1js1pctZjbJG4+5VJZLd8xgcuUGD0lB/o+gjOI3PoE73A
 nSqQ8Q2QI14dzUcuv4Hwp/f4mNOKSvcc9D+iZEFSmXXjz2Ju79+QQTCRoVI59MEK
 7AyZnYv/jn1FG+eg/72B5jYTQXhk6l1OG6/5PFZQ3LB1lWqU/ngZesv0afOq9ZAF
 CsTk9T9YJGSpNOkdPBuDpt28Y325ugCfTNwVuV9dqB78wiXr2JqhYumstJ+GmL6c
 qvl6DNKFjMKNoYCK6El7NsIsEq+/eBUSSNnHpQTCIYA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; bh=Tlpv2x
 mpynLkoXih5aMS72+SXJrnQuj1c9PDv1ck7SY=; b=YrtEbGU8zOV9obkWiyW83q
 2/eRqrLFuyhY7NReqTCUbwQ7+FodkpbVtxmew6Som6zYQUaIomR8EYreLV8eapAm
 6eqGej3Y2c/lQ3mp+GOtMZaYOZh1dKAE9GAY91Mcpu/ZE3Gbn/trgk/Eg2ckRKQ3
 u9WKLIwQqFn7UaWcFpr8q1hvzwhv3AdLOOGOJkWexZtKEP/WjJJV658CIVbvgMqr
 YHVIMeNYI7n+WwIQSuwqsSnZutV3t1bKVzE2kH9biteKEDTnOQMzCTYYlON9leAk
 kN4jD+zpv0yD+uFQanaCNkUrUsXTe9pf4CMFQrYR4OzXt//2ig8vm0kiE+XhTutQ
 ==
X-ME-Sender: <xms:_GN2Xzs6msGZQcTc-fvlIrR2UVr99TDXZStlH0IZnic86NoRJ9NPyA>
 <xme:_GN2X0fpVR9i1T8XP7djV_kaeiQZhH1h01l6t-qwoijMuqjFD1aCLiPiwHtgtc9jX
 kcZaodCQWqkpJQDJRc>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrfeehgddujecutefuodetggdotefrodftvf
 curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
 uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
 fjughrpeffhffvuffkfhggtggujgesthdtredttddtvdenucfhrhhomhepvfihtghhohcu
 tehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrfgrth
 htvghrnhepffekueefveeufefhhfelieffheeludeitdelkefhieejleeiffejvdelieeg
 udeunecuffhomhgrihhnpehkvghrnhgvlhdrohhrghdpmhgrnhejrdhorhhgnecukfhppe
 duvdekrddutdejrddvgedurdduieejnecuvehluhhsthgvrhfuihiivgeptdenucfrrghr
 rghmpehmrghilhhfrhhomhepthihtghhohesthihtghhohdrphhiiiiirg
X-ME-Proxy: <xmx:_WN2X2x1_h2CgyVYMYJ__5ZQsJVg8mJwYeL-PB1IWWsQgXXX-SgZJw>
 <xmx:_WN2XyNzSo_4tRUgtRsA5dgdIXms__i3HRiu9OJJXqkRXyJHA5g2zQ>
 <xmx:_WN2Xz88rKAopdVohxCpJmT0eZAeVp1v0A4t1z4FgpG57OH2ZuwSRg>
 <xmx:_mN2X3VXO3K-T_QMDwDJynXQdD85L8b36S_Vdf3u9tGGk1FuRsduqJHSVVlBJ2Rp>
Received: from cisco (unknown [128.107.241.167])
 by mail.messagingengine.com (Postfix) with ESMTPA id A1E8A3280066;
 Thu,  1 Oct 2020 19:19:22 -0400 (EDT)
Date: Thu, 1 Oct 2020 17:19:15 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Sargun Dhillon <sargun@sargun.me>
Subject: Re: For review: seccomp_user_notif(2) manual page
Message-ID: <20201001231915.GA16219@cisco>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <CAMp4zn9XA-z_6UKvWkFh_U2wPRjZF3=QvrXX7EikO5AEovCWBA@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAMp4zn9XA-z_6UKvWkFh_U2wPRjZF3=QvrXX7EikO5AEovCWBA@mail.gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>,
 Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, bpf@vger.kernel.org,
 Andy Lutomirski <luto@amacapital.net>,
 Christian Brauner <christian@brauner.io>
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

On Thu, Oct 01, 2020 at 02:06:10PM -0700, Sargun Dhillon wrote:
> On Wed, Sep 30, 2020 at 4:07 AM Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
> >
> > Hi Tycho, Sargun (and all),
> >
> > I knew it would be a big ask, but below is kind of the manual page
> > I was hoping you might write [1] for the seccomp user-space notification
> > mechanism. Since you didn't (and because 5.9 adds various new pieces
> > such as SECCOMP_ADDFD_FLAG_SETFD and SECCOMP_IOCTL_NOTIF_ADDFD
> > that also will need documenting [2]), I did :-). But of course I may
> > have made mistakes...
> >
> > I've shown the rendered version of the page below, and would love
> > to receive review comments from you and others, and acks, etc.
> >
> > There are a few FIXMEs sprinkled into the page, including one
> > that relates to what appears to me to be a misdesign (possibly
> > fixable) in the operation of the SECCOMP_IOCTL_NOTIF_RECV
> > operation. I would be especially interested in feedback on that
> > FIXME, and also of course the other FIXMEs.
> >
> > The page includes an extensive (albeit slightly contrived)
> > example program, and I would be happy also to receive comments
> > on that program.
> >
> > The page source currently sits in a branch (along with the text
> > that you sent me for the seccomp(2) page) at
> > https://git.kernel.org/pub/scm/docs/man-pages/man-pages.git/log/?h=seccomp_user_notif
> >
> > Thanks,
> >
> > Michael
> >
> > [1] https://lore.kernel.org/linux-man/2cea5fec-e73e-5749-18af-15c35a4bd23c@gmail.com/#t
> > [2] Sargun, can you prepare something on SECCOMP_ADDFD_FLAG_SETFD
> >     and SECCOMP_IOCTL_NOTIF_ADDFD to be added to this page?
> >
> > ====
> >
> > --
> > Michael Kerrisk
> > Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> > Linux/UNIX System Programming Training: http://man7.org/training/
> 
> Should we consider the SECCOMP_GET_NOTIF_SIZES dance to be "deprecated" at
> this point, given that the extensible ioctl mechanism works? If we add
> new fields to the
> seccomp datastructures, we would move them from fixed-size ioctls, to
> variable sized
> ioctls that encode the datastructure size / length?
> 
> -- This is mostly a question for Kees and Tycho.

It will tell you how big struct seccomp_data in the currently running
kernel is, so it still seems useful/necessary to me, unless there's
another way to figure that out.

But I agree, I don't think the intent is to add anything else to
struct seccomp_notif. (I don't know that it ever was.)

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
