Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05E37C4727D
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 23:44:31 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6938C23A65
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 23:44:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vEGvA95P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6938C23A65
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id C38F720778;
	Mon, 21 Sep 2020 23:44:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id k-U4nMC75XGL; Mon, 21 Sep 2020 23:44:28 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id B97D220530;
	Mon, 21 Sep 2020 23:44:28 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id AB682C0889;
	Mon, 21 Sep 2020 23:44:28 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 25DB6C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 23:44:27 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 14C7E8501A
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 23:44:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id OOtDLP-2G-SY
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 23:44:25 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com
 [209.85.215.193])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 2EB8184FF9
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 23:44:25 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id 7so10381653pgm.11
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 16:44:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=f8AZNe0yh+nr0Q+aU3EvTJPeuK86gAHOuWijIQhouP8=;
 b=vEGvA95PpAmbmXF/2pU8BaNMqZ5N1inrv9uju3AMOs5CulSDiskwgzFOBntcsI93QM
 yEjo2q9ircjzU7d1ufiagzwfnhKETg/PR8JvFmoclPzGhNPiyn9ANKeTMV9FlDHSM66O
 XoJ2QE+VcS9nST+vtUdxDzWpjzprT84+NULHJb7LPVe+Rq0sasjVAZR2yJ9NUdKBxgEk
 j5AP6emS5GZFCLp2qarNt8/8hgbxgcfv6d0dzn9myFt0mQOAEgORS5vXiesu+pwlxwGR
 LEsz4OcwMCvbZPND10wv//eJ2zOoVof7pjh3A/QMY825eKu324F0hjRDez+cdVTXz8RF
 4SLw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=f8AZNe0yh+nr0Q+aU3EvTJPeuK86gAHOuWijIQhouP8=;
 b=ECl3zVbDtOATbd1pRgSoa4zQI68WJmCW8fqXQ6cVre7KsTxQiqVqZa8/6BTr3vEDSY
 HUJB1TZ3kRn3/R/XGKx2YjSXDAZMWvUmNJ0vUdvD1B+Qm3ky3bfsmlYN2ZdD7cyRGjq/
 0+iAfK3ovYLh8VV764+qr3j8sNOMDsg6JjOApc8eXRpntlc5tRNtAbxmq088a7nEA6NR
 3e4tYErkrCSATtUzKv8Wcgqlb7tPZCG6SyJEMx+TALe3HKnO+pjHGyhgMnTZXOx/mBTX
 siS+Qtd7gwljFE/Z3d8CN5s6/L+gsphGKTsEDdPorapEuhx9CMhiPPQ/+yI7YOJ8ZSBA
 s8Jw==
X-Gm-Message-State: AOAM532rA+aDyzUao5+TlleyZtvmYkuLwlq1u8gQ54p7CNMnqOUFA24N
 w2mDRJXiiUyXpcHHRDuZ6OpLomxJmG698Fd0pQ0=
X-Google-Smtp-Source: ABdhPJz+byc0Fo9qwVi1m/19ewyehzO4HVj6Nm3myh1IDrLqLENEXpuSUgTX/J1/uhN/HgHUxQ0lni+/Gp6neZQXKB0=
X-Received: by 2002:a17:902:7445:b029:d1:dea3:a3ca with SMTP id
 e5-20020a1709027445b02900d1dea3a3camr2074614plt.19.1600731864616; Mon, 21 Sep
 2020 16:44:24 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <6af89348c08a4820039e614a090d35aa1583acff.1600661419.git.yifeifz2@illinois.edu>
 <CAG48ez0OqZavgm0BkGjCAJUr5UfRgbeCbmLOZFJ=Rj46COcN3Q@mail.gmail.com>
In-Reply-To: <CAG48ez0OqZavgm0BkGjCAJUr5UfRgbeCbmLOZFJ=Rj46COcN3Q@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Mon, 21 Sep 2020 18:44:13 -0500
Message-ID: <CABqSeAQhVFeG1Frvu60XfUnRQ78YRS2Uaw1EsBobKVku-vVoDQ@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 1/2] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
To: Jann Horn <jannh@google.com>
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Mon, Sep 21, 2020 at 12:47 PM Jann Horn <jannh@google.com> wrote:
> Is this actually necessary, or can we just bail out on any branch that
> we can't statically resolve?

I think after we do enumerate the arch numbers it would make much more
sense. Since if there is a branch after arch number and syscall
numbers are fixed we can assume that the return values will be
different if one or the other case is followed.

> Also: If it turns out that the time spent in seccomp_cache_prepare()
> is measurable for large filters, a possible improvement would be to
> keep track of the last syscall number for which the result would be
> the same as for the current one, such that instead of evaluating the
> filter for one instruction at a time, it would effectively be
> evaluated for a range at a time. That should be pretty straightforward
> to implement, I think.

My concern was more of the possibly-exponential amount of time &
memory needed to evaluate an adversarial filter containing full of
unresolveable branches, hence the max pending states. If we never
follow both branches then evaluation should not be much of a concern.

> > +       depends on SECCOMP
> > +       depends on SECCOMP_FILTER
>
> SECCOMP_FILTER already depends on SECCOMP, so the "depends on SECCOMP"
> line is unnecessary.

The reason that this is here is because of the looks in menuconfig.
SECCOMP is the direct previous entry, so if this depends on SECCOMP
then the config would be indented. Is this looks not worth keeping or
is there some better way to do this?

> > +       help
> > +         Seccomp filters can potentially incur large overhead for each
> > +         system call. This can alleviate some of the overhead.
> > +
> > +         If in doubt, select 'none'.
>
> This should not be in arch/x86. Other architectures, such as arm64,
> should also be able to use this without extra work.

In the initial RFC patch I only added to x86. I could add it to any
arch that has seccomp filters. Though, I'm wondering, why is SECCOMP
in the arch-specific Kconfigs?

> I think we should probably just bail out if we see anything that's
> BPF_ST/BPF_STX. I've never seen seccomp filters that actually use that
> part of cBPF.
>
> But in case we do need this, maybe instead of using "2 +" for all
> these things, the cBPF memory slots should be in a separate array.

Ok I'll just bail.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
