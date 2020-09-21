Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63013C4346E
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 18:38:46 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D63A6207BC
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 18:38:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="GKj3LJZb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D63A6207BC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 9511A84C4E;
	Mon, 21 Sep 2020 18:38:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id upXXrbLVl139; Mon, 21 Sep 2020 18:38:44 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 993988466C;
	Mon, 21 Sep 2020 18:38:44 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 90314C0859;
	Mon, 21 Sep 2020 18:38:44 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 51B78C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 18:38:43 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 3E37E2079A
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 18:38:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id PQjb7UqRDfe7
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 18:38:42 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com
 [209.85.208.65])
 by silver.osuosl.org (Postfix) with ESMTPS id D753E2076E
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 18:38:41 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id w1so13846722edr.3
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 11:38:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=C7G6A5IlEG2WC0nmoX7XdAtZ+v2I/zqqDO0euVW1SNE=;
 b=GKj3LJZbIecljJchWIPsVbgqFMg87glRuzFxDZUSnJCVadINrRQoPekzrtKM6pXFG4
 jWmJoGWdPsML6lH9FjKOKPIrPw63/cKOhXUp5e0TPpKeUNin829jFNlYXC5LjVUi7psX
 Q8fipqI46lZkA3SDqje4ta/W4Eh+vI3SKfAi5yGK5526zHVe4lUCgrqmAQiiqMQXKcXP
 2qWHELpxN3jG2I/YmRVE/92CZfYkjr2vDdMUrejhZq+rTTRxVVnar1vEZXkj/I4Nld8N
 b5fF2BDFiRGJmzlxKgzu9iX8XLxJoLdMWZl0/TkOILYMjMeMo1Mmy0vuKiMc4RKUduOk
 a9ew==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=C7G6A5IlEG2WC0nmoX7XdAtZ+v2I/zqqDO0euVW1SNE=;
 b=RgW1fuBDzG+J+9jzr8xZcsq3zPswfPNRTvfiiLiDs9i6rpOYA2ByJ0bmxPYS2w7JiP
 cir1B2pvO+WWlto5zEsnc2AQd5Bd872pLqDXVH6k/Y0Eyrv4MA7l6NhsjFpncYTtXU8x
 rtnSWzfq8OSczbdaEaPrpTFjjZ5NdGF6HEGkOsDOMtgYbQMX9x171eMWMCMpVzvUMMXD
 9lUDWL1cy2+aR/YMlCVx5MeOP8cwWh0ev5uQkAGOrLbn7QG/4Td0oB1itvmLlNJPpqcp
 xsmVaZ9EDOzDKVvGsugF1swkEKraXJsqg18gLJI5pTfkMivyhEELgtjUnF3d4JcBCglU
 oigw==
X-Gm-Message-State: AOAM531Qvb7bW9jPtdmwbenf/aGBa/lJ5n5K2vPYCd4gvyJQ9DrDXsVJ
 piCh3H6mJ0XOAZt5nG6NipIxzPMA0GUIC6RCTbsUbg==
X-Google-Smtp-Source: ABdhPJw1S/OudX6ksjY6lypppCEWZ0hIJHznPBazJowA/vFH3Ctsk57UwDR5UNDwwwTnZIA6s/67nZwO+5kWeI/4UA0=
X-Received: by 2002:a05:6402:176c:: with SMTP id
 da12mr281928edb.386.1600713520102; 
 Mon, 21 Sep 2020 11:38:40 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <6af89348c08a4820039e614a090d35aa1583acff.1600661419.git.yifeifz2@illinois.edu>
 <CAG48ez0OqZavgm0BkGjCAJUr5UfRgbeCbmLOZFJ=Rj46COcN3Q@mail.gmail.com>
In-Reply-To: <CAG48ez0OqZavgm0BkGjCAJUr5UfRgbeCbmLOZFJ=Rj46COcN3Q@mail.gmail.com>
Date: Mon, 21 Sep 2020 20:38:11 +0200
Message-ID: <CAG48ez0gBRvTEXX_L3881jQM8Aw6SURbMPafW18GihWe4ZmtmQ@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 1/2] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
To: YiFei Zhu <zhuyifei1999@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, YiFei Zhu <yifeifz2@illinois.edu>,
 kernel list <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf <bpf@vger.kernel.org>,
 Tianyin Xu <tyxu@illinois.edu>
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Mon, Sep 21, 2020 at 7:47 PM Jann Horn <jannh@google.com> wrote:
> On Mon, Sep 21, 2020 at 7:35 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> > SECCOMP_CACHE_NR_ONLY will only operate on syscalls that do not
> > access any syscall arguments or instruction pointer. To facilitate
> > this we need a static analyser to know whether a filter will
> > access. This is implemented here with a pseudo-emulator, and
> > stored in a per-filter bitmap. Each seccomp cBPF instruction,
> > aside from ALU (which should rarely be used in seccomp), gets a
> > naive best-effort emulation for each syscall number.
> >
> > The emulator works by following all possible (without SAT solving)
> > paths the filter can take. Every cBPF register / memory position
> > records whether that is a constant, and of so, the value of the
> > constant. Loading from struct seccomp_data is considered constant
> > if it is a syscall number, else it is an unknown. For each
> > conditional jump, if the both arguments can be resolved to a
> > constant, the jump is followed after computing the result of the
> > condition; else both directions are followed, by pushing one of
> > the next states to a linked list of next states to process. We
> > keep a finite number of pending states to process.
>
> Is this actually necessary, or can we just bail out on any branch that
> we can't statically resolve?

Aaaah, now I get what's going on. You statically compute a bitmask
that says whether a given syscall number always has a fixed result
*per architecture number*, and then use that later to decide whether
results can be cached for the combination of a specific seccomp filter
and a specific architecture number. Which mostly works, except that it
means you end up with weird per-thread caches and you get interference
between ABIs (so if a process e.g. filters the argument numbers for
syscall 123 in ABI 1, the results for syscall 123 in ABI 2 also can't
be cached).

Anyway, even though this works, I think it's the wrong way to go about it.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
