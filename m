Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89444C4727E
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 21:28:59 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DE77120796
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 21:28:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=sargun.me header.i=@sargun.me header.b="tkrBQe3E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE77120796
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 9642E872EA;
	Thu,  1 Oct 2020 21:28:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id h0NGFlnC1AUT; Thu,  1 Oct 2020 21:28:53 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id B088B872E7;
	Thu,  1 Oct 2020 21:28:53 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 98DC9C016F;
	Thu,  1 Oct 2020 21:28:53 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id AC46AC0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 21:28:51 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 94F9B84078
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 21:28:51 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id JtfC2FKQBFAY
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 21:28:47 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lj1-f195.google.com (mail-lj1-f195.google.com
 [209.85.208.195])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id A953784032
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 21:28:46 +0000 (UTC)
Received: by mail-lj1-f195.google.com with SMTP id y4so82257ljk.8
 for <containers@lists.linux-foundation.org>;
 Thu, 01 Oct 2020 14:28:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=GJfQdlSGvnYX8WTWiSSvgRRMTzNs36g2ODPiTwjRAs8=;
 b=tkrBQe3EU3XlxTk9RswYWhAU4d1iEgcKP+mNKsyk7QnifbEkLUVCT/Bz9HiE4WZDH9
 kPwoGKUUr+ktBtCxlwk704U4nOoVOcFG4gZqxD8/WNDpZpcxtCXcBKHmqjgCOI2sZjKz
 RIHBYbLW3UYEy3kwlVU6CHuZOl2ouk0fj2blw=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=GJfQdlSGvnYX8WTWiSSvgRRMTzNs36g2ODPiTwjRAs8=;
 b=Ufa6xysjFaNqrd5CM+gpGf70EH3mY2d8dHfdlE+DE3WSC0T2O5sXB0PtpcPghHM8p8
 HcVaH4hOqF+/4Hr3gkBE+ZU99oW2fc+PFGV78Pq7ZHjQezOenffWpfn1M9L7RBGwiAze
 R048p5bxaEcrMHMKe8Go1o92/de2goID01dScOeIBP+9V/5MlYTCNzFCtR/4QDNX6BR6
 zO5ne2US6gbL6X9/2xSe9wJc6wAZ9755DBk2B2/EQhAvpW+t8MhCpKgd9ZKCxb7r3EIz
 bunVnn0HDGYO9or9VCd+pb8dHgNpLR+bLAA5ZZGbVMiTHydCsCHOM6WFnm7ihL9vXQj3
 1N5A==
X-Gm-Message-State: AOAM533I3MW6QzkyCTaEqu3xaehWkjSf3fZoqfFuRS4jLnhtF/ZRhdSx
 uCy0/iPvc2GkDbMj7UEBmI7j0cZA37LZ0LFhTauHs3564gGW44sQ
X-Google-Smtp-Source: ABdhPJwvS6nNR0DvYHDBM04oUTIB+MUropRM/aV9HBVmK+CT5YH4iBVjeeDR8WdQ3dsdp+vdjAc8sF9ARo7WZujAD1Q=
X-Received: by 2002:a17:906:3e0c:: with SMTP id
 k12mr10020262eji.189.1601586407475; 
 Thu, 01 Oct 2020 14:06:47 -0700 (PDT)
MIME-Version: 1.0
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
In-Reply-To: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
From: Sargun Dhillon <sargun@sargun.me>
Date: Thu, 1 Oct 2020 14:06:10 -0700
Message-ID: <CAMp4zn9XA-z_6UKvWkFh_U2wPRjZF3=QvrXX7EikO5AEovCWBA@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, Jann Horn <jannh@google.com>,
 Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
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

On Wed, Sep 30, 2020 at 4:07 AM Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
>
> Hi Tycho, Sargun (and all),
>
> I knew it would be a big ask, but below is kind of the manual page
> I was hoping you might write [1] for the seccomp user-space notification
> mechanism. Since you didn't (and because 5.9 adds various new pieces
> such as SECCOMP_ADDFD_FLAG_SETFD and SECCOMP_IOCTL_NOTIF_ADDFD
> that also will need documenting [2]), I did :-). But of course I may
> have made mistakes...
>
> I've shown the rendered version of the page below, and would love
> to receive review comments from you and others, and acks, etc.
>
> There are a few FIXMEs sprinkled into the page, including one
> that relates to what appears to me to be a misdesign (possibly
> fixable) in the operation of the SECCOMP_IOCTL_NOTIF_RECV
> operation. I would be especially interested in feedback on that
> FIXME, and also of course the other FIXMEs.
>
> The page includes an extensive (albeit slightly contrived)
> example program, and I would be happy also to receive comments
> on that program.
>
> The page source currently sits in a branch (along with the text
> that you sent me for the seccomp(2) page) at
> https://git.kernel.org/pub/scm/docs/man-pages/man-pages.git/log/?h=seccomp_user_notif
>
> Thanks,
>
> Michael
>
> [1] https://lore.kernel.org/linux-man/2cea5fec-e73e-5749-18af-15c35a4bd23c@gmail.com/#t
> [2] Sargun, can you prepare something on SECCOMP_ADDFD_FLAG_SETFD
>     and SECCOMP_IOCTL_NOTIF_ADDFD to be added to this page?
>
> ====
>
> --
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Linux/UNIX System Programming Training: http://man7.org/training/

Should we consider the SECCOMP_GET_NOTIF_SIZES dance to be "deprecated" at
this point, given that the extensible ioctl mechanism works? If we add
new fields to the
seccomp datastructures, we would move them from fixed-size ioctls, to
variable sized
ioctls that encode the datastructure size / length?

-- This is mostly a question for Kees and Tycho.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
