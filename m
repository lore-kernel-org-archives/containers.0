Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB858C55179
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 02:04:51 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EC925208C3
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 02:04:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC925208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 80F3487390;
	Thu, 29 Oct 2020 02:04:50 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 3fWpWIEbHY0H; Thu, 29 Oct 2020 02:04:49 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id B6F9C8710F;
	Thu, 29 Oct 2020 02:04:49 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9C432C0859;
	Thu, 29 Oct 2020 02:04:49 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 8B6FEC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 02:04:45 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 74A68214E9
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 02:04:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id w2vsDawf2XnB
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 02:04:44 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from new2-smtp.messagingengine.com (new2-smtp.messagingengine.com
 [66.111.4.224])
 by silver.osuosl.org (Postfix) with ESMTPS id 3040B214E6
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 02:04:43 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
 by mailnew.nyi.internal (Postfix) with ESMTP id 3AC9858029D;
 Wed, 28 Oct 2020 22:04:42 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
 by compute6.internal (MEProxy); Wed, 28 Oct 2020 22:04:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm1; bh=yHv/eZmJGG0yTkiPxiWa7rUEaHb
 08+3XQpgK4jmG0RU=; b=abqk8NbxiwIyvARFJAiYdmRbJsN+nsOdyAutyVtohmH
 a8TZYxpV3kcmA19zDid+b4EYYyJ0EGhQc0wjoa6KkoyXA6tJLPnk1Z4/HkbLzQk6
 C66zR/l0Cv79OmHFlihv9UorWtOARhO++6as0bT2gc6nI+ZPXenF7tI09a4StmCG
 dLcUG+/MQ3zE5N0KpwngeTEMO8KSV+ki+zKlV8uTjrwqAwAf7khdx/DwFuYrhY1+
 +51Yrte8riXXedY3fbzIvSf9W9A2Z00glwHmm5GVyvkcf0HgJfJMhK5OKDQuTNbJ
 5CFmnSP97R8bSCHah9S8atZuadpHCG4NrS5YK3eZaFQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=yHv/eZ
 mJGG0yTkiPxiWa7rUEaHb08+3XQpgK4jmG0RU=; b=cQEM8IKQvJ5742cTCUrKFm
 J0LwshoFOGdRh8dKwnIpJc4MN1YbYR5GZ6E5oRcbspcAeJfmi6fNlNl7X5/hd1IT
 rCVEV/YnRvk99s7AfcmQwmzaESZzm59f6/Kcj+wT1u+l3l4fzoNYMiezxXzFCufN
 AwPmJZPlCompQalfzN5Ss9WTo399nDhUz/HKQ7BJ+0I6gqrQNs1Do9/RpQCHYIkQ
 J5dmVq9g8YX+W0dDwY/2kUllddbRDHCh82gvQhSq5uNJ00pupU6oyDcAikJCfFeh
 nm50o1Ehz0axndt6M07icAdU3auC6oTsEqUBP6l0bxBb6zgdv7R4pIOc7Oe3mh1Q
 ==
X-ME-Sender: <xms:OSOaX5BJHeX6aqfP0w-d-xp7YzDritXjKEgD-iYPp4pWP_E6vxfB3A>
 <xme:OSOaX3jORdaad4tOvZykV2IFX_GXlpzb8vdFg8FvpVCteYmbpDB4UF4-yxcRlIbQO
 AecSCTjXW7Sei60k0w>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedujedrledvgdeilecutefuodetggdotefrodftvf
 curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
 uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
 fjughrpeffhffvuffkfhggtggujgesthdtredttddtvdenucfhrhhomhepvfihtghhohcu
 tehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrfgrth
 htvghrnhepffeukeekudejfefhjeevgeejgffhkefhffetleduvddufeekteelkeekhfef
 udejnecuffhomhgrihhnpehkvghrnhgvlhdrohhrghenucfkphepjeefrddvudejrddutd
 driedtnecuvehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehmrghilhhfrhhomhep
 thihtghhohesthihtghhohdrphhiiiiirg
X-ME-Proxy: <xmx:OSOaX0kROVGSWNsU7yYsd5AgAlMMUwZSSfYKd92DQTSFMpZ86D7l_w>
 <xmx:OSOaXzxeA10T-ifJeGU0IkEaPLVxkJ-4dEgxxXGdjRiCCF4Xg8juUQ>
 <xmx:OSOaX-TLrMTZeVjt4J_cWl_rPrL-7ULRJSKRdMe2dwqUDMIvmZeJTQ>
 <xmx:OiOaX6pDbiI7Bi0HGKV-EQLFQbrudEukTLd4GOcP5qn75dSesR5vgQ>
Received: from cisco (c-73-217-10-60.hsd1.co.comcast.net [73.217.10.60])
 by mail.messagingengine.com (Postfix) with ESMTPA id E7A50328005A;
 Wed, 28 Oct 2020 22:04:39 -0400 (EDT)
Date: Wed, 28 Oct 2020 20:04:38 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Jann Horn <jannh@google.com>
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
Message-ID: <20201029020438.GA25673@cisco>
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
 Robert Sesek <rsesek@google.com>,
 Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>,
 bpf <bpf@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>,
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

On Thu, Oct 29, 2020 at 02:42:58AM +0100, Jann Horn wrote:
> On Mon, Oct 26, 2020 at 10:55 AM Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
> >        static bool
> >        getTargetPathname(struct seccomp_notif *req, int notifyFd,
> >                          char *path, size_t len)
> >        {
> >            char procMemPath[PATH_MAX];
> >
> >            snprintf(procMemPath, sizeof(procMemPath), "/proc/%d/mem", req->pid);
> >
> >            int procMemFd = open(procMemPath, O_RDONLY);
> >            if (procMemFd == -1)
> >                errExit("\tS: open");
> >
> >            /* Check that the process whose info we are accessing is still alive.
> >               If the SECCOMP_IOCTL_NOTIF_ID_VALID operation (performed
> >               in checkNotificationIdIsValid()) succeeds, we know that the
> >               /proc/PID/mem file descriptor that we opened corresponds to the
> >               process for which we received a notification. If that process
> >               subsequently terminates, then read() on that file descriptor
> >               will return 0 (EOF). */
> >
> >            checkNotificationIdIsValid(notifyFd, req->id);
> >
> >            /* Read bytes at the location containing the pathname argument
> >               (i.e., the first argument) of the mkdir(2) call */
> >
> >            ssize_t nread = pread(procMemFd, path, len, req->data.args[0]);
> >            if (nread == -1)
> >                errExit("pread");
> 
> As discussed at
> <https://lore.kernel.org/r/CAG48ez0m4Y24ZBZCh+Tf4ORMm9_q4n7VOzpGjwGF7_Fe8EQH=Q@mail.gmail.com>,
> we need to re-check checkNotificationIdIsValid() after reading remote
> memory but before using the read value in any way. Otherwise, the
> syscall could in the meantime get interrupted by a signal handler, the
> signal handler could return, and then the function that performed the
> syscall could free() allocations or return (thereby freeing buffers on
> the stack).
> 
> In essence, this pread() is (unavoidably) a potential use-after-free
> read; and to make that not have any security impact, we need to check
> whether UAF read occurred before using the read value. This should
> probably be called out elsewhere in the manpage, too...
> 
> Now, of course, **reading** is the easy case. The difficult case is if
> we have to **write** to the remote process... because then we can't
> play games like that. If we write data to a freed pointer, we're
> screwed, that's it. (And for somewhat unrelated bonus fun, consider
> that /proc/$pid/mem is originally intended for process debugging,
> including installing breakpoints, and will therefore happily write
> over "readonly" private mappings, such as typical mappings of
> executable code.)
> 
> So, uuuuh... I guess if anyone wants to actually write memory back to
> the target process, we'd better come up with some dedicated API for
> that, using an ioctl on the seccomp fd that magically freezes the

By freeze here you mean a killable wait instead of an interruptible
wait, right?

Not that I'm interested in actually doing this, just want to make sure
I understand correctly :)

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
