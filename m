Return-Path: <SRS0=KOwt=DF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5CA4C2D0A8
	for <containers@archiver.kernel.org>; Mon, 28 Sep 2020 20:04:56 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 54FD92076D
	for <containers@archiver.kernel.org>; Mon, 28 Sep 2020 20:04:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="E4DiKgHZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54FD92076D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id D147886FAC;
	Mon, 28 Sep 2020 20:04:55 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id o2YbMe2lyo69; Mon, 28 Sep 2020 20:04:55 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 3E6CC86F6A;
	Mon, 28 Sep 2020 20:04:55 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1F091C1AD7;
	Mon, 28 Sep 2020 20:04:55 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 3F520C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 28 Sep 2020 20:04:54 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 25DD186F6A
 for <containers@lists.linux-foundation.org>;
 Mon, 28 Sep 2020 20:04:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id iQcM0DAnPRvX
 for <containers@lists.linux-foundation.org>;
 Mon, 28 Sep 2020 20:04:52 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com
 [209.85.215.195])
 by hemlock.osuosl.org (Postfix) with ESMTPS id E095486F21
 for <containers@lists.linux-foundation.org>;
 Mon, 28 Sep 2020 20:04:52 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id x16so1850658pgj.3
 for <containers@lists.linux-foundation.org>;
 Mon, 28 Sep 2020 13:04:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=DrORwxFSTGYgq7rDpyN+PgrRRMbvRryObis6SlzlegQ=;
 b=E4DiKgHZ8+3lgXItSKuRg/Zp0KCE480TlXTghysXO3BoLDWSNo77w7adL5ZNKFzaJt
 JrIB8dlPqKMbNAPQuhOffpeY5lxUoDQaCkYU7Gb2rde/d/IV3kPzLjUCB6bh4IovYwuN
 dW8ea1YKN4Z7HbEGJI1W39qM7Swg4rgPmsp04=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=DrORwxFSTGYgq7rDpyN+PgrRRMbvRryObis6SlzlegQ=;
 b=JXRPROcQhCKW5RaxM/quLazzRlEUyWCTbPN+tpyqsyVIMjWEwRenyDy4NAr7gc6msj
 OGGcxVnrb7xboIEaN6doZSqPmdsgrW70/QVpF0mdP6B9AJoDOSwcIu3clSTNYvQgKBFT
 XcOhVxEl0NjrymBcmGf6N3gmtqmZhlJkon6mzFMuzY8zwn1D+cszzDwp1oRixdwNkFOi
 7wr/nh/lfxXv9QvMxj8Nqv/vnIQf2d390Bv+uUX0fxz6dy7VNbr038cNh4Yc0f/zl3x4
 B9dLo14aQVP6I8zNABzpZzsCke0SWisSxzegEWj7/GdEnLtLQt2lX29tmR8Y2daOqfLy
 Dnnw==
X-Gm-Message-State: AOAM530qlg0z+SbBo6RQW8oajsG+P6cdpM5Jq9QZkEFqAP35Nxv1Ov/l
 t7BOrUnCTV78bmZ1jyD85iY5RQ==
X-Google-Smtp-Source: ABdhPJxeNwqKkdDur1frnecEaZEFzGE9kbnLnamH2R59vj03CRfItMAxTnbIVtTMyXXwLb+Jai9NWg==
X-Received: by 2002:aa7:99c2:0:b029:142:440b:fa28 with SMTP id
 v2-20020aa799c20000b0290142440bfa28mr961093pfi.30.1601323492379; 
 Mon, 28 Sep 2020 13:04:52 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id w203sm2928796pff.0.2020.09.28.13.04.51
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Mon, 28 Sep 2020 13:04:51 -0700 (PDT)
Date: Mon, 28 Sep 2020 13:04:50 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v1 0/6] seccomp: Implement constant action bitmaps
Message-ID: <202009281259.D7D18AE95@keescook>
References: <20200923232923.3142503-1-keescook@chromium.org>
 <43039bb6-9d9f-b347-fa92-ea34ccc21d3d@rasmusvillemoes.dk>
 <CABqSeAQKksqM1SdsQMoR52AJ5CY0VE2tk8-TJaMuOrkCprQ0MQ@mail.gmail.com>
 <27b4ef86-fee5-fc35-993b-3352ce504c73@rasmusvillemoes.dk>
 <CABqSeATHtvA7qm7j_kxBsbxRCd5B=MHtxGdsYsXEJ-TRRYKTgA@mail.gmail.com>
 <CABqSeASMObs7HtwfM=ua9Tbx1mfHZaxCMWD6AP6-6hR4-Xcn=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeASMObs7HtwfM=ua9Tbx1mfHZaxCMWD6AP6-6hR4-Xcn=Q@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Will Drewry <wad@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Rasmus Villemoes <linux@rasmusvillemoes.dk>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf <bpf@vger.kernel.org>,
 Tianyin Xu <tyxu@illinois.edu>, kernel list <linux-kernel@vger.kernel.org>
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

On Sat, Sep 26, 2020 at 01:11:50PM -0500, YiFei Zhu wrote:
> On Fri, Sep 25, 2020 at 2:07 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> > I'll try to profile the latter later on my qemu-kvm, with a recent
> > libsecomp with binary tree and docker's profile, probably both direct
> > filter attaches and filter attaches with fork(). I'm guessing if I
> > have fork() the cost of fork() will overshadow seccomp() though.
> 
> I'm surprised. That is not the case as far as I can tell.
> 
> I wrote a benchmark [1] that would fork() and in the child attach a
> seccomp filter, look at the CLOCK_MONOTONIC difference, then add it to
> a struct timespec shared with the parent. It checks the difference
> with the timespec before prctl and before fork. CLOCK_MONOTONIC
> instead of CLOCK_PROCESS_CPUTIME_ID because of fork.
> 
> I ran `./seccomp_emu_bench 100000` in my qemu-kvm and here are the results:
> without emulator:
> Benchmarking 100000 syscalls...
> 19799663603 (19.8s)
> seecomp attach without fork: 197996 ns
> 33911173847 (33.9s)
> seecomp attach with fork: 339111 ns
> 
> with emulator:
> Benchmarking 100000 syscalls...
> 54428289147 (54.4s)
> seecomp attach without fork: 544282 ns
> 69494235408 (69.5s)
> seecomp attach with fork: 694942 ns
> 
> fork seems to take around 150us, seccomp attach takes around 200us,
> and the filter emulation overhead is around 350us. I had no idea that
> fork was this fast. If I wrote my benchmark badly please criticise.

You're calling clock_gettime() inside your loop. That might change the
numbers. Why not just measure outside the loop, or better yet, use
"perf" to measure the time in prctl().

> Given that we are doubling the time to fork() + seccomp attach filter,
> I think yeah running the emulator on the first instance of a syscall,
> holding a lock, is a much better idea. If I naively divide 350us by
> the number of syscall + arch pairs emulated the overhead is less than
> 1 us and that should be okay since it only happens for the first
> invocation of the particular syscall.
> 
> [1] https://gist.github.com/zhuyifei1999/d7bee62bea14187e150fef59db8e30b1

Regardless, let's take things one step at a time. First, let's do
the simplest version of the feature, and then let's look at further
optimizations.

Can you send a v3 and we can continue from there?

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
