Return-Path: <SRS0=6hu2=EJ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36B92C2D0A3
	for <containers@archiver.kernel.org>; Tue,  3 Nov 2020 13:00:39 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A657E20731
	for <containers@archiver.kernel.org>; Tue,  3 Nov 2020 13:00:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Lnt8Hjmu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A657E20731
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 1C9E486ACD;
	Tue,  3 Nov 2020 13:00:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mF3qPMNJP7es; Tue,  3 Nov 2020 13:00:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 034BC86A62;
	Tue,  3 Nov 2020 13:00:36 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id DA23CC0889;
	Tue,  3 Nov 2020 13:00:36 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id EBE51C0051
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:00:34 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id DF93186A91
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:00:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id SVdia+sHZtuo
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:00:34 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com
 [209.85.215.193])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 0640B86A62
 for <containers@lists.linux-foundation.org>;
 Tue,  3 Nov 2020 13:00:34 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id x13so13610692pgp.7
 for <containers@lists.linux-foundation.org>;
 Tue, 03 Nov 2020 05:00:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=cLOijGoctpVii6lG3GNscCwHl4zBjRguK02Pj+vC7Bo=;
 b=Lnt8Hjmu9dGoSLDAasF005iIBbNvJDUDXT2QOAwpwOqhEQdjNHVxckiiJFr8mU4us4
 ZfvZURxeeV5pnQwRthC7wy5OhPHWgFUG+/dOdwLIl0starUECLJ9LsqKhehkbUNWbd+W
 Gk40A7rI2KRJIH1RbJpPY9GOqOxSiWOz5ua9ugFXxzjUDbUsv8kMQdEWKNvX6VsLw7n/
 Z/wiuG6cRq9ieuH87Rmjj6KfKi8oWILHkl2ewcbROaYc73EbRg5fyydXWz+3H1wFoUe9
 y7HhwZtgPvyA5h3Hv1fhVJNm3akcVlQ9BYdE+WTW2Dmb7vNqchZ5wD9Su7dBPwQn1Tdu
 8I5g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=cLOijGoctpVii6lG3GNscCwHl4zBjRguK02Pj+vC7Bo=;
 b=lLtnYb7RBuSAe29LpnUKlG9siJP9wMhSkt3exDfBCGbkx/zIcgitn1u13owQiA1uhl
 5xINZzicpzctNadDP1YvkeLdYIxEPKq6lGGiNoKJCEjzSrn2LhwwLNdwPwsUNOdt0OUa
 lgB0F6/AKsqQrKC4vXRPFL8yGzKRvYac7dJn+AaDcFodbdRTk9MGDg/icRhYpkrCzv4w
 sDUn0f3mJc+AHw6M/07sAUr97Q1sOIl8l9/BqJcuseXaQnXuxoNUuNDuKhVejjfu9fpF
 4RYMYx/to5ytiSj2Rs9uIuS2+obQ7KnJsjM3V9hMyL7RQ7zQ+NGRQQoF2s2AekY1FMzL
 Efhw==
X-Gm-Message-State: AOAM5334DApXbLjfEJSNCpTWQIXEMOxuABaeaxHNfzgRiM+joCvZ8EKv
 mx5/oY2sWm5b7Xon9D4aJrJPtFpPRNTNhjDguGg=
X-Google-Smtp-Source: ABdhPJw+ttTwVOHCreEYANGBLEJOjyklNontnw0owjnvgHA5/sZlnEhBwxgZCZadbjBWnXjZWUz50lU3Vv1QK1Vv3D4=
X-Received: by 2002:a17:90a:f184:: with SMTP id
 bv4mr3599635pjb.1.1604408433473; 
 Tue, 03 Nov 2020 05:00:33 -0800 (PST)
MIME-Version: 1.0
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <c2077b8a86c6d82d611007d81ce81d32f718ec59.1602263422.git.yifeifz2@illinois.edu>
 <202010091613.B671C86@keescook>
 <CABqSeARZWBQrLkzd3ozF16ghkADQqcN4rUoJS2MKkd=73g4nVA@mail.gmail.com>
 <202010121556.1110776B83@keescook>
 <CABqSeAT2-vNVUrXSWiGp=cXCvz8LbOrTBo1GbSZP2Z+CKdegJA@mail.gmail.com>
 <CABqSeASc-3n_LXpYhb+PYkeAOsfSjih4qLMZ5t=q5yckv3w0nQ@mail.gmail.com>
 <202010221520.44C5A7833E@keescook>
 <CABqSeAT4L65_uS=45uxPZALKaDSDocMviMginLOV2N0h-e1AzA@mail.gmail.com>
 <202010231945.90FA4A4AA@keescook>
 <CABqSeAQ4cCwiPuXEeaGdErMmLDCGxJ-RgweAbUqdrdm+XJXxeg@mail.gmail.com>
In-Reply-To: <CABqSeAQ4cCwiPuXEeaGdErMmLDCGxJ-RgweAbUqdrdm+XJXxeg@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Tue, 3 Nov 2020 07:00:22 -0600
Message-ID: <CABqSeATiV0sQvqpvCuqkOXNbjetY=1=6ry_SciMVmo63W9A88A@mail.gmail.com>
Subject: Re: [PATCH v4 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
To: Kees Cook <keescook@chromium.org>
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

On Fri, Oct 30, 2020 at 7:18 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> I got a bare metal test machine with Intel(R) Xeon(R) CPU E5-2660 v3 @
> 2.60GHz, running Ubuntu 18.04. Test kernels are compiled at
> 57a339117e52 ("selftests/seccomp: Compare bitmap vs filter overhead")
> and 3650b228f83a ("Linux 5.10-rc1"), built with Ubuntu's
> 5.3.0-64-generic's config, then `make olddefconfig`. "Mitigations off"
> indicate the kernel was booted with "nospectre_v2 nospectre_v1
> no_stf_barrier tsx=off tsx_async_abort=off".
>
> The benchmark was single-job make on x86_64 defconfig of 5.9.1, with
> CPU affinity to set only processor #0. Raw results are appended below.
> Each boot is tested by running the build directly and inside docker,
> with and without seccomp. The commands used are attached below. Each
> test is 4 trials, with the middle two (non-minimum, non-maximum) wall
> clock time averaged. Results summary:
>
>                 Mitigations On                  Mitigations Off
>                 With Cache      Without Cache   With Cache      Without Cache
> Native          18:17.38        18:13.78        18:16.08        18:15.67
> D. no seccomp   18:15.54        18:17.71        18:17.58        18:16.75
> D. + seccomp    20:42.47        20:45.04        18:47.67        18:49.01
>
> To be honest, I'm somewhat surprised that it didn't produce as much of
> a dent in the seccomp overhead in this macro benchmark as I had
> expected.

My peers pointed out that in my previous benchmark there are still a
few mitigations left on, and suggested to use "noibrs noibpb nopti
nospectre_v2 nospectre_v1 l1tf=off nospec_store_bypass_disable
no_stf_barrier mds=off tsx=on tsx_async_abort=off mitigations=off".
Results with "Mitigations Off" updated:

                        Mitigations On            Mitigations Off
                With Cache      Without Cache   With Cache      Without Cache
Native          18:17.38        18:13.78        17:43.42        17:47.68
D. no seccomp   18:15.54        18:17.71        17:34.59        17:37.54
D. + seccomp    20:42.47        20:45.04        17:35.70        17:37.16

Whether seccomp is on or off seems not to make much of a difference
for this benchmark. Bitmap being enabled does seem to decrease the
overall compilation time but it also affects where seccomp is off, so
the speedup is probably from other factors. We are thinking about
using more syscall-intensive workloads, such as httpd.

Thugh, this does make me wonder, where does the 3-minute overhead with
seccomp with mitigations come from? Is it data cache misses? If that
is the case, can we somehow preload the seccomp bitmap cache maybe? I
mean, mitigations only cause around half a minute slowdown without
seccomp but seccomp somehow amplify the slowdown with an additional
2.5 minutes, so something must be off here.

This is the raw output for the time commands:

==== with cache, mitigations off ====

947.02user 108.62system 17:47.65elapsed 98%CPU (0avgtext+0avgdata
239804maxresident)k
25112inputs+217152outputs (166major+51934447minor)pagefaults 0swaps

947.91user 108.20system 17:46.53elapsed 99%CPU (0avgtext+0avgdata
239576maxresident)k
0inputs+217152outputs (0major+51941524minor)pagefaults 0swaps

948.33user 108.70system 17:47.72elapsed 98%CPU (0avgtext+0avgdata
239604maxresident)k
0inputs+217152outputs (0major+51938566minor)pagefaults 0swaps

948.65user 108.81system 17:48.41elapsed 98%CPU (0avgtext+0avgdata
239692maxresident)k
0inputs+217152outputs (0major+51935349minor)pagefaults 0swaps


932.12user 113.68system 17:37.24elapsed 98%CPU (0avgtext+0avgdata
239660maxresident)k
0inputs+217152outputs (0major+51547571minor)pagefaults 0swap

931.69user 114.12system 17:37.84elapsed 98%CPU (0avgtext+0avgdata
239448maxresident)k
0inputs+217152outputs (0major+51539964minor)pagefaults 0swaps

932.25user 113.39system 17:37.75elapsed 98%CPU (0avgtext+0avgdata
239372maxresident)k
0inputs+217152outputs (0major+51538018minor)pagefaults 0swaps

931.09user 114.25system 17:37.34elapsed 98%CPU (0avgtext+0avgdata
239508maxresident)k
0inputs+217152outputs (0major+51537700minor)pagefaults 0swaps


929.96user 113.42system 17:36.23elapsed 98%CPU (0avgtext+0avgdata
239448maxresident)k
984inputs+217152outputs (22major+51544059minor)pagefaults 0swaps

929.73user 115.13system 17:38.09elapsed 98%CPU (0avgtext+0avgdata
239464maxresident)k
0inputs+217152outputs (0major+51540259minor)pagefaults 0swaps

930.13user 112.71system 17:36.17elapsed 98%CPU (0avgtext+0avgdata
239620maxresident)k
0inputs+217152outputs (0major+51540623minor)pagefaults 0swaps

930.57user 113.02system 17:49.70elapsed 97%CPU (0avgtext+0avgdata
239432maxresident)k
0inputs+217152outputs (0major+51537776minor)pagefaults 0swaps

==== without cache, mitigations off ====

947.59user 108.06system 17:44.56elapsed 99%CPU (0avgtext+0avgdata
239484maxresident)k
25112inputs+217152outputs (167major+51938723minor)pagefaults 0swaps

947.95user 108.58system 17:43.40elapsed 99%CPU (0avgtext+0avgdata
239580maxresident)k
0inputs+217152outputs (0major+51943434minor)pagefaults 0swaps

948.54user 106.62system 17:42.39elapsed 99%CPU (0avgtext+0avgdata
239608maxresident)k
0inputs+217152outputs (0major+51936408minor)pagefaults 0swaps

947.85user 107.92system 17:43.44elapsed 99%CPU (0avgtext+0avgdata
239656maxresident)k
0inputs+217152outputs (0major+51931633minor)pagefaults 0swaps


931.28user 111.16system 17:33.59elapsed 98%CPU (0avgtext+0avgdata
239440maxresident)k
0inputs+217152outputs (0major+51543540minor)pagefaults 0swaps

930.21user 112.56system 17:34.20elapsed 98%CPU (0avgtext+0avgdata
239400maxresident)k
0inputs+217152outputs (0major+51539699minor)pagefaults 0swaps

930.16user 113.74system 17:35.06elapsed 98%CPU (0avgtext+0avgdata
239344maxresident)k
0inputs+217152outputs (0major+51543072minor)pagefaults 0swaps

930.17user 112.77system 17:34.98elapsed 98%CPU (0avgtext+0avgdata
239176maxresident)k
0inputs+217152outputs (0major+51540777minor)pagefaults 0swaps


931.92user 113.31system 17:36.05elapsed 98%CPU (0avgtext+0avgdata
239520maxresident)k
984inputs+217152outputs (22major+51534636minor)pagefaults 0swaps

931.14user 112.81system 17:35.35elapsed 98%CPU (0avgtext+0avgdata
239524maxresident)k
0inputs+217152outputs (0major+51549007minor)pagefaults 0swaps

930.93user 114.56system 17:37.72elapsed 98%CPU (0avgtext+0avgdata
239360maxresident)k
0inputs+217152outputs (0major+51542191minor)pagefaults 0swaps

932.26user 111.54system 17:35.36elapsed 98%CPU (0avgtext+0avgdata
239572maxresident)k
0inputs+217152outputs (0major+51537921minor)pagefaults 0swaps

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
