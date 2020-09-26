Return-Path: <SRS0=QcxQ=DD=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AB44C2D0A8
	for <containers@archiver.kernel.org>; Sat, 26 Sep 2020 18:12:11 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A3E162073A
	for <containers@archiver.kernel.org>; Sat, 26 Sep 2020 18:12:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="syrFF3GZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3E162073A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id F12FD20407;
	Sat, 26 Sep 2020 18:12:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id dAQQA38Ahdqq; Sat, 26 Sep 2020 18:12:05 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 38962203CA;
	Sat, 26 Sep 2020 18:12:05 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 16945C0859;
	Sat, 26 Sep 2020 18:12:05 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 15038C0051
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 18:12:03 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 0150086489
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 18:12:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id F26Ep5akcL6r
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 18:12:02 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com
 [209.85.210.196])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 7440C8633E
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 18:12:02 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id o20so5902590pfp.11
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 11:12:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=KowdFI99SvwAHlmnquISweYZPA2kNBZ4Vy+1Sm1Ru5Y=;
 b=syrFF3GZ4vwOCTVvGBzGuHJ4tcSsvCEY7VnZU5FZQtDjapU5yYWoTukg/YbFCvyOJg
 1R7CkOr3meO9mL0s1bMniClEFzIlmODRBjafTC6oXho0L9KbcuKtKcSgsuuIbEOvHeXl
 O5h/Xqfj+cLXNLXaF79JK62/N9SjeS8W5mQw2r0Tuu+rfkfifKplqReHttHgGNDSlsic
 HAOssh01hbBRJI4TX+cbsO+bYKpU9wQblx3JlaoIkkKSgaDYgfIbe5UQJOxNuBcdTYAn
 dtMhzMWv6i+0HWW2pwD3bGOM/+eqS8iF1KLeTKLkYLQyqsK3w9bCIDV4aeG+10gzxV84
 s38g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=KowdFI99SvwAHlmnquISweYZPA2kNBZ4Vy+1Sm1Ru5Y=;
 b=pI8pTIXXkLOCYb4qrbeNK9DSlhSsZWJ7bVSOP1wZ4Fk2c1nhdPiw+Nfvbm8yUSvNRX
 eFdpiutswYqqdPuNnwI7QwX4J6OwGCwSFRRRAE+zr9zFjSwV+vjFts4mgkfHuYBt3O//
 BAhKA/27YGj+/OpK5VykCMUk8U0k88CqA6SAChABKWJ1mLwAfe/R0/zaZ3r2TKI23B19
 pPGAgB3wbbw04PaDOTb0iqwbIUJLn5bxbLVGiQ817RNnw3cS0XC1upFu1LcJuXJgbGA3
 BLir06U6c3MGn7IORTCfHCyoXFvBh21FALUDwEpup8GDIhwkiUjCHY69cfTNQDDE6cRb
 aGnw==
X-Gm-Message-State: AOAM531KdrJ9BaY62hdQZTFcJhPgS6HvrrSee0A54uXUUIL/oyVkR7Nj
 FqC1l6OBILifip9+6iDdsUjuxxMJOv5iGWR5Iwo=
X-Google-Smtp-Source: ABdhPJwoJr06rCvVUGsbVXGhb2eVCyD32tCStdaxN1THyxWAQGjxGs5gnWApkmotT1o0fcXz0+iU3rf5dfrHjHc2aOU=
X-Received: by 2002:a63:906:: with SMTP id 6mr3490414pgj.66.1601143922050;
 Sat, 26 Sep 2020 11:12:02 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <43039bb6-9d9f-b347-fa92-ea34ccc21d3d@rasmusvillemoes.dk>
 <CABqSeAQKksqM1SdsQMoR52AJ5CY0VE2tk8-TJaMuOrkCprQ0MQ@mail.gmail.com>
 <27b4ef86-fee5-fc35-993b-3352ce504c73@rasmusvillemoes.dk>
 <CABqSeATHtvA7qm7j_kxBsbxRCd5B=MHtxGdsYsXEJ-TRRYKTgA@mail.gmail.com>
In-Reply-To: <CABqSeATHtvA7qm7j_kxBsbxRCd5B=MHtxGdsYsXEJ-TRRYKTgA@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Sat, 26 Sep 2020 13:11:50 -0500
Message-ID: <CABqSeASMObs7HtwfM=ua9Tbx1mfHZaxCMWD6AP6-6hR4-Xcn=Q@mail.gmail.com>
Subject: Re: [PATCH v1 0/6] seccomp: Implement constant action bitmaps
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
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

On Fri, Sep 25, 2020 at 2:07 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> I'll try to profile the latter later on my qemu-kvm, with a recent
> libsecomp with binary tree and docker's profile, probably both direct
> filter attaches and filter attaches with fork(). I'm guessing if I
> have fork() the cost of fork() will overshadow seccomp() though.

I'm surprised. That is not the case as far as I can tell.

I wrote a benchmark [1] that would fork() and in the child attach a
seccomp filter, look at the CLOCK_MONOTONIC difference, then add it to
a struct timespec shared with the parent. It checks the difference
with the timespec before prctl and before fork. CLOCK_MONOTONIC
instead of CLOCK_PROCESS_CPUTIME_ID because of fork.

I ran `./seccomp_emu_bench 100000` in my qemu-kvm and here are the results:
without emulator:
Benchmarking 100000 syscalls...
19799663603 (19.8s)
seecomp attach without fork: 197996 ns
33911173847 (33.9s)
seecomp attach with fork: 339111 ns

with emulator:
Benchmarking 100000 syscalls...
54428289147 (54.4s)
seecomp attach without fork: 544282 ns
69494235408 (69.5s)
seecomp attach with fork: 694942 ns

fork seems to take around 150us, seccomp attach takes around 200us,
and the filter emulation overhead is around 350us. I had no idea that
fork was this fast. If I wrote my benchmark badly please criticise.

Given that we are doubling the time to fork() + seccomp attach filter,
I think yeah running the emulator on the first instance of a syscall,
holding a lock, is a much better idea. If I naively divide 350us by
the number of syscall + arch pairs emulated the overhead is less than
1 us and that should be okay since it only happens for the first
invocation of the particular syscall.

[1] https://gist.github.com/zhuyifei1999/d7bee62bea14187e150fef59db8e30b1

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
