Return-Path: <SRS0=zK8s=D5=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24322C388F9
	for <containers@archiver.kernel.org>; Thu, 22 Oct 2020 23:40:25 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 760C724641
	for <containers@archiver.kernel.org>; Thu, 22 Oct 2020 23:40:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ud7rmALA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 760C724641
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id DFC26204D5;
	Thu, 22 Oct 2020 23:40:23 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id OihwGdWB7k8g; Thu, 22 Oct 2020 23:40:22 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 0643120472;
	Thu, 22 Oct 2020 23:40:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D6624C0052;
	Thu, 22 Oct 2020 23:40:21 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 3A291C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 23:40:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 21B1087234
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 23:40:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id hYK3TacoC-Vh
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 23:40:19 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com
 [209.85.215.193])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 98F2985FEF
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 23:40:19 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id s22so2004334pga.9
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 16:40:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=rfUKMVhWjeKZKSXLZk5xBVJ8e0dc1yuWDXn4EN8WMMU=;
 b=ud7rmALAARbu3oqKs/0tzFST86D3Pnf0VohdjqbSUsNO3zlhE5AP/MrJ47b4kSvX2Y
 xyngFQZLQtUAslg59RtfMY2ljTToPi+/zvwpwNgbZqE4O2YsEghEf/pkMxMevIvn3FLl
 L4Uh8kmJyAXgM8cgqPGV6hDCgIpv9vqoDWV+7+xXJRSXWABMP2QdX32A+iNGZQtNMBIO
 Zq/vZhwrllluWPBwA4TvP4dCjf9AShkcwFIEzO91Nm00LTrASqifV1h0VY+ltJOBhpId
 prFvLAf7kc3bcq/cUG3ObocpG7NyplLaNZi+DrDYv4+lagdRedtMgntT3E6x5C1qGqCV
 dHtQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=rfUKMVhWjeKZKSXLZk5xBVJ8e0dc1yuWDXn4EN8WMMU=;
 b=m9YhKRpYduG0wqkNgkEOcWkgirg3u65MDmLWwCPmVS7JMedaG4B6W9F7J7hmoLF9lF
 ZR73hnHRUZzjvk3UAdjRVAdbWh3EgOL2ggpQ+USqs+rOaUPNWDLrCDhSgpLR8vgrg4Wg
 69NnLhStzhH0ELTziPw+HyDD7YXiqj7+aIIq7+d6lUCpt4C6GD+d33k6kf+u2h5rLAb8
 a36lhYU8CO0NByTtLCcw8Xz059q0TIZ5xG/h6lMT/krif383tQ+6OKqrvyca5Ze0+aU6
 5N1r5aouVJ1mL1rqmYbeswQ/oK/GvZyg0kK/zxe3TDigL2l1hl7kjM7UT+9d6riA7OSk
 Q59w==
X-Gm-Message-State: AOAM531i3geHZ/4Uof54eRi59LPkayWcmzemKxnQXWKwXCmJZd0Jlw+y
 kJCPgJMguq3fpbFPPnCQa66isQPz/xzsBK2pqcQ=
X-Google-Smtp-Source: ABdhPJykfsSN5dzMGjSyvmeb7kY08iyuowCm7UjuXfZLsjz2nFbvRBAd/WNQYohVqj2bEWN0ASrE45/fY7d/UdH6dPY=
X-Received: by 2002:a17:90a:4313:: with SMTP id
 q19mr4588300pjg.184.1603410019174; 
 Thu, 22 Oct 2020 16:40:19 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <c2077b8a86c6d82d611007d81ce81d32f718ec59.1602263422.git.yifeifz2@illinois.edu>
 <202010091613.B671C86@keescook>
 <CABqSeARZWBQrLkzd3ozF16ghkADQqcN4rUoJS2MKkd=73g4nVA@mail.gmail.com>
 <202010121556.1110776B83@keescook>
 <CABqSeAT2-vNVUrXSWiGp=cXCvz8LbOrTBo1GbSZP2Z+CKdegJA@mail.gmail.com>
 <CABqSeASc-3n_LXpYhb+PYkeAOsfSjih4qLMZ5t=q5yckv3w0nQ@mail.gmail.com>
 <202010221520.44C5A7833E@keescook>
In-Reply-To: <202010221520.44C5A7833E@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 22 Oct 2020 18:40:08 -0500
Message-ID: <CABqSeAT4L65_uS=45uxPZALKaDSDocMviMginLOV2N0h-e1AzA@mail.gmail.com>
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

On Thu, Oct 22, 2020 at 5:32 PM Kees Cook <keescook@chromium.org> wrote:
> I've been going back and forth on this, and I think what I've settled
> on is I'd like to avoid new CONFIG dependencies just for this feature.
> Instead, how about we just fill in SECCOMP_NATIVE and SECCOMP_COMPAT
> for all the HAVE_ARCH_SECCOMP_FILTER architectures, and then the
> cache reporting can be cleanly tied to CONFIG_SECCOMP_FILTER? It
> should be relatively simple to extract those details and make
> SECCOMP_ARCH_{NATIVE,COMPAT}_NAME part of the per-arch enabling patches?

Hmm. So I could enable the cache logic to every architecture (one
patch per arch) that does not have the sparse syscall numbers, and
then have the proc reporting after the arch patches? I could do that.
I don't have test machines to run anything other than x86_64 or ia32,
so they will need a closer look by people more familiar with those
arches.

> I'd still like to get more specific workload performance numbers too.
> The microbenchmark is nice, but getting things like build times under
> docker's default seccomp filter, etc would be lovely. I've almost gotten
> there, but my benchmarks are still really noisy and CPU isolation
> continues to frustrate me. :)

Ok, let me know if I can help.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
