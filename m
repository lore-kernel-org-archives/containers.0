Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C84ABC4727D
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 22:58:29 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5817F2076E
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 22:58:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="LOgAOhIu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5817F2076E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id D08148711E;
	Mon, 21 Sep 2020 22:58:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id br7WEoiN2UHs; Mon, 21 Sep 2020 22:58:28 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 40A7D87118;
	Mon, 21 Sep 2020 22:58:28 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3C640C0859;
	Mon, 21 Sep 2020 22:58:28 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1DB4FC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 22:58:27 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 06B0621503
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 22:58:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id HLIWI7WMcUr4
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 22:58:26 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com
 [209.85.208.67])
 by silver.osuosl.org (Postfix) with ESMTPS id D657D2052C
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 22:58:25 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id n13so14350102edo.10
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 15:58:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=F406dxOGL4KIyo3r913T2qYQFJYxNBYaxUNYOkHvtJo=;
 b=LOgAOhIuOtK3NEGs5lfUfr3Z1we8cm+fSTqcM/nC5XdWVc8G8zUtABSkKkmAQ52+H1
 1c+W8yeUe6zOPyRAQkzv3YmZ68wzpCBSZbYpsAWqo96ic0X65rNdGYH8LmIb255U+BxI
 AcFVi2WBYPbN5eWFHSV+GoQejC0hhUjgTozpchXclGf2pMYARIw5Nn8kswl3yTi8QH3C
 /ZfNRcxgNstUkYZjsvuhuq1/CuGAyIibmjz/JC+desNVgZG3j59Jh+dsDzUufv5E4g2T
 7ubxNAIyknRIdYm8G4IcLOiL79DsMCINz7MAtuidpGEXowsl8CAhQTvDIVfsZbFNiQOz
 m26A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=F406dxOGL4KIyo3r913T2qYQFJYxNBYaxUNYOkHvtJo=;
 b=gLLtNG64A9oBdJFFaA9UX9k+IxQnhmqJ5U3k0qG+Kbo5pqBdQfyYoihYt6X+RkLmJp
 mborYlCmI56zCnUKspfhpGp3ehb270kbI8j+quwVWKqneY6HDg48N6oQOjFOI7D2QBj+
 I0oSEXmJx33H6cbvQq64rZyu3Mr0O98JsAiiR3qufKqSooU9fvUzc7rOXI1KBlc3f+9x
 J8zXjFFPV2MYtDizPZcDPhJVBgED5iqAcAa6MZJB6klBX47AW9RKPRId2NPEoIER93nr
 QCy7noY7y2ApOck379uagMFameYQBMefT7XxCcgYiS+rWdXXV+uaNsqWJ2bMFq+zWTHd
 XOLg==
X-Gm-Message-State: AOAM5303b4AY0LuoZkEfGaSvKYnSS6fBOxHzVnh1kjXKnK6pDdyIr8LU
 tQQZgnQbQ5YU3SOOhvi0K6Ycu5IQlCX/RihxeC/c1w==
X-Google-Smtp-Source: ABdhPJzKQ8pt68rKwhcn6462p221HnYSc7PT1gfTLQQr7Dyyt5sp+3GSHllwhbLNcRdd6ZR5P19GP5X7qwPc+u0bf/A=
X-Received: by 2002:a05:6402:cba:: with SMTP id
 cn26mr1188410edb.230.1600729104142; 
 Mon, 21 Sep 2020 15:58:24 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <b792335294ee5598d0fb42702a49becbce2f925f.1600661419.git.yifeifz2@illinois.edu>
 <CAG48ez3k0_7Vev_O=uV_WVuUGK6BPA0RyrYXMYSDV4DTMMe26g@mail.gmail.com>
 <CABqSeAROcwq0ZGzWaxyPm+LDHu6T_8CD7_1c-hdhaMikr_ECCA@mail.gmail.com>
In-Reply-To: <CABqSeAROcwq0ZGzWaxyPm+LDHu6T_8CD7_1c-hdhaMikr_ECCA@mail.gmail.com>
Date: Tue, 22 Sep 2020 00:57:58 +0200
Message-ID: <CAG48ez2HytqFaJ6V9iA6YZrbZU3kG4bB7nETMfHPt0-wd5D1jg@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 2/2] seccomp/cache: Cache filter results that
 allow syscalls
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

On Tue, Sep 22, 2020 at 12:51 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> On Mon, Sep 21, 2020 at 1:09 PM Jann Horn <jannh@google.com> wrote:
> >
> > On Mon, Sep 21, 2020 at 7:35 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> > [...]
> > > We do this by creating a per-task bitmap of permitted syscalls.
> > > If seccomp filter is invoked we check if it is cached and if so
> > > directly return allow. Else we call into the cBPF filter, and if
> > > the result is an allow then we cache the results.
> >
> > What? Why? We already have code to statically evaluate the filter for
> > all syscall numbers. We should be using the results of that instead of
> > re-running the filter and separately caching the results.
> >
> > > The cache is per-task
> >
> > Please don't. The static results are per-filter, so the bitmask(s)
> > should also be per-filter and immutable.
>
> I do agree that an immutable bitmask is faster and easier to reason
> about its correctness. However, I did not find the "code to statically
> evaluate the filter for all syscall numbers" while reading seccomp.c.
> Would you give me a pointer to that and I will see how to best make
> use of it?

I'm talking about the code you're adding in the other patch ("[RFC
PATCH seccomp 1/2] seccomp/cache: Add "emulator" to check if filter is
arg-dependent"). Sorry, that was a bit unclear.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
