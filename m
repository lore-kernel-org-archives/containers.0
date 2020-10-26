Return-Path: <SRS0=D+Sq=EB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D637C4363A
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 14:30:47 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7C08F20878
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 14:30:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JnQ0MIpC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C08F20878
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 1260D2046D;
	Mon, 26 Oct 2020 14:30:46 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZcvZXIioXaw1; Mon, 26 Oct 2020 14:30:45 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 067212E0EE;
	Mon, 26 Oct 2020 14:30:45 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E09ACC0859;
	Mon, 26 Oct 2020 14:30:44 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 8E0AFC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 14:30:43 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 7405785F81
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 14:30:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id qySPI8q2hHLr
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 14:30:42 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ot1-f65.google.com (mail-ot1-f65.google.com
 [209.85.210.65])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id B567385F98
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 14:30:42 +0000 (UTC)
Received: by mail-ot1-f65.google.com with SMTP id b2so7585456ots.5
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 07:30:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:reply-to:from:date:message-id
 :subject:to:cc;
 bh=+62REvLl90oSoyuDks7xdfiXCVRonn7cl65cbO1ln/E=;
 b=JnQ0MIpC39NGj7T4hBFlbdnbI8BIWOudxMb9DwRB+2vErYWqGaeDk6rew3qbtnq6zE
 xTQK3COatM2HRhx7Xj9lHlrGrcm71hnK8BNlqHvJIskesC/YoT/AlMOcjB5nyYP/qEr5
 nGqst5eVhCd7URgCMzm/Z1ajkuwlpxD5SqPAKMFSs8E/vhjMV8gwqMpNkgRp9Bp6Xpn4
 RRyiGkWI03aSsA5qqbLzT5bAviyyV57u+uzzZa6LYP23zz1MUbbGQTIEtIrCFOljySFY
 9LUzk5kBx9rPqA30qiWylDiDgAPXMjP9b5T3y/ZQo5jB7TcU7uUb3usgvmVod9XA6i/4
 aeSw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:reply-to
 :from:date:message-id:subject:to:cc;
 bh=+62REvLl90oSoyuDks7xdfiXCVRonn7cl65cbO1ln/E=;
 b=o9H6wdG3yRqrTcKyi+Zg4CcZG8KqBAH4+WSIFlhJFnBy6ELGH7XtN/r8f2hBbrGnc6
 CgS9mU5dfJQbG2j0FjofkfLEK0RHDCuIqNE+pV8rkGzx5O5NS5I9kiXDq2Vt/I6ekCWK
 8fKftkg/2deXcEBYzKMQquYPQybucxih7Is2WhQZ51HX90E8jb2YUm3aWS7QYAObhlLj
 NRdiMff6w3RszkNYwcfbMnazInHNrD2rxDgzi4IgVb9MfoT5vE3XP/BRLqqNxQwucbk3
 1LMgMtcqL+XIP2xgcRVhp+hhMwhiH56o39isEVayMjPyoaqn/dbxcNnCtAzaIK/4Ircw
 5FOg==
X-Gm-Message-State: AOAM531MBy14H5Y8/GrLfgHrWv9KLJEjBsLKcNdqRlPdCohwROArN8MZ
 HYSaZvYJUhd0py/FlcR2hV8lP3XgCDDSgmyl0P0=
X-Google-Smtp-Source: ABdhPJwW15tzyEC/krpp35iEMIIcjSyagUOGYZYuoOMQvqf+nEg1onUBKRqqUolszW2AyHG3hi9a91s1aH2f5EGSzME=
X-Received: by 2002:a05:6830:22eb:: with SMTP id
 t11mr13557647otc.114.1603722641926; 
 Mon, 26 Oct 2020 07:30:41 -0700 (PDT)
MIME-Version: 1.0
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <20201026135418.GN1884107@cisco>
In-Reply-To: <20201026135418.GN1884107@cisco>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Mon, 26 Oct 2020 15:30:29 +0100
Message-ID: <CAKgNAkgbvuEJ0rkLrZGgCf0OTC8YH2vxemNic8SsDxjh=Z22uw@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
To: Tycho Andersen <tycho@tycho.pizza>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
 Robert Sesek <rsesek@google.com>,
 Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, lkml <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>, bpf <bpf@vger.kernel.org>,
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
Reply-To: mtk.manpages@gmail.com
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

Hi Tycho,

Thanks for getting back to me.

On Mon, 26 Oct 2020 at 14:54, Tycho Andersen <tycho@tycho.pizza> wrote:
>
> On Mon, Oct 26, 2020 at 10:55:04AM +0100, Michael Kerrisk (man-pages) wrote:
> > Hi all (and especially Tycho and Sargun),
> >
> > Following review comments on the first draft (thanks to Jann, Kees,
> > Christian and Tycho), I've made a lot of changes to this page.
> > I've also added a few FIXMEs relating to outstanding API issues.
> > I'd like a second pass review of the page before I release it.
> > But also, this mail serves as a way of noting the outstanding API
> > issues.
> >
> > Tycho: I still have an outstanding question for you at [2].
> > [2] https://lore.kernel.org/linux-man/8f20d586-9609-ef83-c85a-272e37e684d8@gmail.com/
>
> I don't have that thread in my inbox any more, but I can reply here:
> no, I don't know any users of this info, but I also don't anticipate
> knowing how people will all use this feature :)

Yes, but my questions were:

[[
[1] So, I think maybe I now understand what you intended with setting
POLLOUT: the notification has been received ("read") and now the
FD can be used to NOTIFY_SEND ("write") a response. Right?

[2] If that's correct, I don't have a problem with it. I just wonder:
is it useful? IOW: are there situations where the process doing the
NOTIFY_SEND might want to test for POLLOUT because the it doesn't
know whether a NOTIFY_RECV has occurred?
]]

So, do I understand right in [1]? (The implication from your reply is
yes, but I want to be sure...)

For [2], my question was not about users, but *use cases*. The
question I asked myself is: why does the feature exist? Hence my
question [2] reworded: "when you designed this, did you have in mind
scenarios here the process doing the NOTIFY_SEND might need to test
for POLLOUT because it doesn't know whether a NOTIFY_RECV has
occurred?"

Thanks,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
