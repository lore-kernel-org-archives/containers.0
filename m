Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A6A7C4727E
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 21:05:26 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A1720206E5
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 21:05:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="P/3XD2Cc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1720206E5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 7EDCF87247;
	Thu,  1 Oct 2020 21:05:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id kKxRp4aHeLxT; Thu,  1 Oct 2020 21:05:20 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id CE5D987245;
	Thu,  1 Oct 2020 21:05:20 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id C0C86C0889;
	Thu,  1 Oct 2020 21:05:20 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C0112C0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 21:05:19 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id AD11520459
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 21:05:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id puBK6bI7g2Up
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 21:05:15 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f196.google.com (mail-pg1-f196.google.com
 [209.85.215.196])
 by silver.osuosl.org (Postfix) with ESMTPS id 28F53203FE
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 21:05:15 +0000 (UTC)
Received: by mail-pg1-f196.google.com with SMTP id 5so5019103pgf.5
 for <containers@lists.linux-foundation.org>;
 Thu, 01 Oct 2020 14:05:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=sM/IKUxG7XXA4g0Q8PYm8FVn3Q1jvofvHy96zqP1SLI=;
 b=P/3XD2CcnLPmFvxK4ImVaO3KbIoepUZ+wnlZ+BJrjfWejmWXo3+ahVkBVF20sY057F
 Fd1Kw/TeSXQS1959lE8zRVGSGWl3cP2+jx0rn8Llzgc8rkxibWB/lNL4iSya5ndBfmVF
 zeb4jKfYxb7rziVYZ0e2NmWo678nIlOdBX9pE=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=sM/IKUxG7XXA4g0Q8PYm8FVn3Q1jvofvHy96zqP1SLI=;
 b=BdqoyiIfL+dWvJa4RRHDJbQ/U8sIx/YymOLLzAEmWNliGODv1718hDcCV6CNsVarUr
 n1wRPmjsRMbRwGBNatJmJbo2TBFzWYH0fGTNBGdXNZ4WX9iM8cCNLKDKmlYEGQVbDxVX
 piCN4DCiXBcKhecJmGptl5bRqI0LqF7h5bELw99UkHbvxw9wf6IcpsyhoqjdWKp1Q7/m
 Dn3UmJqSKZ+99LZ7PVTUnnd2wuhp51PeOfjdXdc5mmCUvF9q4Zo63Z0ZPpaVJFICKmOR
 H/dCMSNWlcF5YkuawC9qjb6D6SyPkoGyKBW1sfgT4aexb7m8EPmdm7qkBIGTKFsYQdnq
 0b6A==
X-Gm-Message-State: AOAM533pA6emUHi6S+0nFODPQo9OzTmaFGIX4jm5CWu8sULecDybFSUl
 wno4n4+wWOYLvyZjF234WOoyZQ==
X-Google-Smtp-Source: ABdhPJwZmuICO3eBgdFhAAtcI8VblpCzInUbkz0BCWOnju3Q9j3Bj5uX/6qFoIfg5eFpaOsfoEkjUQ==
X-Received: by 2002:aa7:9ac7:0:b029:152:ebb:cb42 with SMTP id
 x7-20020aa79ac70000b02901520ebbcb42mr4323742pfp.30.1601586314632; 
 Thu, 01 Oct 2020 14:05:14 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id h31sm6125512pgh.71.2020.10.01.14.05.13
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 01 Oct 2020 14:05:13 -0700 (PDT)
Date: Thu, 1 Oct 2020 14:05:12 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v3 seccomp 2/5] seccomp/cache: Add "emulator" to check if
 filter is constant allow
Message-ID: <202010011314.503D67209@keescook>
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <b16456e8dbc378c41b73c00c56854a3c30580833.1601478774.git.yifeifz2@illinois.edu>
 <202009301432.C862BBC4B@keescook>
 <CABqSeATqYuEAb=i1nxufbVQUWRw6FDbb9x0DYJz87U0RbQj14A@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeATqYuEAb=i1nxufbVQUWRw6FDbb9x0DYJz87U0RbQj14A@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, Tianyin Xu <tyxu@illinois.edu>
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

On Thu, Oct 01, 2020 at 06:52:50AM -0500, YiFei Zhu wrote:
> On Wed, Sep 30, 2020 at 5:40 PM Kees Cook <keescook@chromium.org> wrote:
> > The guiding principle with seccomp's designs is to always make things
> > _more_ restrictive, never less. While we can never escape the
> > consequences of having seccomp_is_const_allow() report the wrong
> > answer, we can at least follow the basic principles, hopefully
> > minimizing the impact.
> >
> > When the bitmap starts with "always allowed" and we only flip it towards
> > "run full filters", we're only ever making things more restrictive. If
> > we instead go from "run full filters" towards "always allowed", we run
> > the risk of making things less restrictive. For example: a process that
> > maliciously adds a filter that the emulator mistakenly evaluates to
> > "always allow" doesn't suddenly cause all the prior filters to stop running.
> > (i.e. this isolates the flaw outcome, and doesn't depend on the early
> > "do not emulate if we already know we have to run filters" case before
> > the emulation call: there is no code path that allows the cache to
> > weaken: it can only maintain it being wrong).
> >
> > Without any seccomp filter installed, all syscalls are "always allowed"
> > (from the perspective of the seccomp boundary), so the default of the
> > cache needs to be "always allowed".
> 
> I cannot follow this. If a 'process that maliciously adds a filter
> that the emulator mistakenly evaluates to "always allow" doesn't
> suddenly cause all the prior filters to stop running', hence, you
> want, by default, the cache to be as transparent as possible. You
> would lift the restriction if and only if you are absolutely sure it
> does not cause an impact.

Yes, right now, the v3 code pattern is entirely safe.

> 
> In this patch, if there are prior filters, it goes through this logic:
> 
>         if (bitmap_prev && !test_bit(nr, bitmap_prev))
>             continue;
> 
> Hence, if the malicious filter were to happen, and prior filters were
> supposed to run, then seccomp_is_const_allow is simply not invoked --
> what it returns cannot be used maliciously by an adversary.

Right, but we depend on that test always doing the correct thing (and
continuing to do so into the future). I'm looking at this from the
perspective of future changes, maintenance, etc. I want the actions to
match the design principles as closely as possible so that future
evolutions of the code have lower risk to bugs causing security
failures. Right now, the code is simple. I want to design this so that
when it is complex, it will still fail toward safety in the face of
bugs.

> >         if (bitmap_prev) {
> >                 /* The new filter must be as restrictive as the last. */
> >                 bitmap_copy(bitmap, bitmap_prev, bitmap_size);
> >         } else {
> >                 /* Before any filters, all syscalls are always allowed. */
> >                 bitmap_fill(bitmap, bitmap_size);
> >         }
> >
> >         for (nr = 0; nr < bitmap_size; nr++) {
> >                 /* No bitmap change: not a cacheable action. */
> >                 if (!test_bit(nr, bitmap_prev) ||
> >                         continue;
> >
> >                 /* No bitmap change: continue to always allow. */
> >                 if (seccomp_is_const_allow(fprog, &sd))
> >                         continue;
> >
> >                 /* Not a cacheable action: always run filters. */
> >                 clear_bit(nr, bitmap);
> 
> I'm not strongly against this logic. I just feel unconvinced that this
> is any different with a slightly increased complexity.

I'd prefer this way because for the loop, the tests, and the results only
make the bitmap more restrictive. The worst thing a bug in here can do is
leave the bitmap unchanged (which is certainly bad), but it can't _undo_
an earlier restriction.

The proposed loop's leading test_bit() becomes only an optimization,
rather than being required for policy enforcement.

In other words, I prefer:

	inherit all prior prior bitmap restrictions
	for all syscalls
		if this filter not restricted
			continue
		set bitmap restricted

	within this loop (where the bulk of future logic may get added),
	the worse-case future bug-induced failure mode for the syscall
	bitmap is "skip *this* filter".


Instead of:

	set bitmap all restricted
	for all syscalls
		if previous bitmap not restricted and
		   filter not restricted
			set bitmap unrestricted

	within this loop the worst-case future bug-induced failure mode
	for the syscall bitmap is "skip *all* filters".




Or, to reword again, this:

	retain restrictions from previous caching decisions
	for all syscalls
		[evaluate this filter, maybe continue]
		set restricted

instead of:

	set new cache to all restricted
	for all syscalls
		[evaluate prior cache and this filter, maybe continue]
		set unrestricted

I expect the future code changes for caching to be in the "evaluate"
step, so I'd like the code designed to make things MORE restrictive not
less from the start, and remove any prior cache state tests from the
loop.

At the end of the day I believe changing the design like this now lays
the groundwork to the caching mechanism being more robust against having
future bugs introduce security flaws.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
