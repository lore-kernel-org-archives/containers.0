Return-Path: <SRS0=XUta=D7=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B87EC55179
	for <containers@archiver.kernel.org>; Sat, 24 Oct 2020 02:51:47 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BA68A2225E
	for <containers@archiver.kernel.org>; Sat, 24 Oct 2020 02:51:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="KV9CaDvJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA68A2225E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 3AEE58715A;
	Sat, 24 Oct 2020 02:51:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Tkp39l6bSZXv; Sat, 24 Oct 2020 02:51:44 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id AC33C87149;
	Sat, 24 Oct 2020 02:51:44 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9F743C0052;
	Sat, 24 Oct 2020 02:51:44 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 5554AC0051
 for <containers@lists.linux-foundation.org>;
 Sat, 24 Oct 2020 02:51:43 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 4948087147
 for <containers@lists.linux-foundation.org>;
 Sat, 24 Oct 2020 02:51:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 3YqlU9qYDaUe
 for <containers@lists.linux-foundation.org>;
 Sat, 24 Oct 2020 02:51:42 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com
 [209.85.215.193])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 9AF4D87149
 for <containers@lists.linux-foundation.org>;
 Sat, 24 Oct 2020 02:51:42 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id b23so2736609pgb.3
 for <containers@lists.linux-foundation.org>;
 Fri, 23 Oct 2020 19:51:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=exQNVvRWJFpZVay5bCbuF8Chc+K90S79cyDW4pCR96s=;
 b=KV9CaDvJWjMnPRerYDVMgQAXXWpZHin64zb+D/uzzh1jn14cp0unh77C/PFSi1YRzK
 RZfD1gMNw3MWr1O3MZFrAq4q3G7PSiATA+70iI9uAQA2HKgtdZPU5ZKeEhN0FxWII7A1
 PAl5jVvc7Gf5OQwDzQpiXkqTFQP3OLcIftsxw=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=exQNVvRWJFpZVay5bCbuF8Chc+K90S79cyDW4pCR96s=;
 b=fi+ezBYZPC4hcuhOzQ+OAddnkvW4Zx1AP5cqUTwllT1WOuVr2bBeB/vdeg2AxBE2Nt
 GvGrS0fiPzz4r/s9tKxLyYSEHRJ7B1AyU7xjYxbQMhuoKRuFFwOEluxUWK/Xh32qc1r9
 6OLUxcRmdewAGsYURcGpYO7hn61QYGImBYGynSssHRg+VsCu6gqOJf1guvc0dLHy1RQL
 5IAXZZ/FuNjgU8yV0Yt4C3MWU+Lzv96MiDBVwJcl73+wteLwtgFCHhwU6qgqeHst49QD
 FubhgkPuRgjE9hTCzkshAegtFr3fz6yg+LG4CusLxWYIP1ccamsU8kfhjKOo8+WNxM11
 PRMw==
X-Gm-Message-State: AOAM533RbYcUkbojvxnIBegsEeJYZ80kJ4Qlmz5II3CvcQG6tg3nPIHQ
 HwpMj1sYHkmI+Y84NwBqMgBc5g==
X-Google-Smtp-Source: ABdhPJzyHxgz6MKrJyx7Q6S+HFMiDqjWeZc2uxi66QjlrB6Ze3vMN0w5ckv5WraSwYbQvKBy86p7Rg==
X-Received: by 2002:a63:f84c:: with SMTP id v12mr4442172pgj.125.1603507902217; 
 Fri, 23 Oct 2020 19:51:42 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id s20sm3363159pfu.112.2020.10.23.19.51.40
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Fri, 23 Oct 2020 19:51:41 -0700 (PDT)
Date: Fri, 23 Oct 2020 19:51:40 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v4 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Message-ID: <202010231945.90FA4A4AA@keescook>
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <c2077b8a86c6d82d611007d81ce81d32f718ec59.1602263422.git.yifeifz2@illinois.edu>
 <202010091613.B671C86@keescook>
 <CABqSeARZWBQrLkzd3ozF16ghkADQqcN4rUoJS2MKkd=73g4nVA@mail.gmail.com>
 <202010121556.1110776B83@keescook>
 <CABqSeAT2-vNVUrXSWiGp=cXCvz8LbOrTBo1GbSZP2Z+CKdegJA@mail.gmail.com>
 <CABqSeASc-3n_LXpYhb+PYkeAOsfSjih4qLMZ5t=q5yckv3w0nQ@mail.gmail.com>
 <202010221520.44C5A7833E@keescook>
 <CABqSeAT4L65_uS=45uxPZALKaDSDocMviMginLOV2N0h-e1AzA@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeAT4L65_uS=45uxPZALKaDSDocMviMginLOV2N0h-e1AzA@mail.gmail.com>
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

On Thu, Oct 22, 2020 at 06:40:08PM -0500, YiFei Zhu wrote:
> On Thu, Oct 22, 2020 at 5:32 PM Kees Cook <keescook@chromium.org> wrote:
> > I've been going back and forth on this, and I think what I've settled
> > on is I'd like to avoid new CONFIG dependencies just for this feature.
> > Instead, how about we just fill in SECCOMP_NATIVE and SECCOMP_COMPAT
> > for all the HAVE_ARCH_SECCOMP_FILTER architectures, and then the
> > cache reporting can be cleanly tied to CONFIG_SECCOMP_FILTER? It
> > should be relatively simple to extract those details and make
> > SECCOMP_ARCH_{NATIVE,COMPAT}_NAME part of the per-arch enabling patches?
> 
> Hmm. So I could enable the cache logic to every architecture (one
> patch per arch) that does not have the sparse syscall numbers, and
> then have the proc reporting after the arch patches? I could do that.
> I don't have test machines to run anything other than x86_64 or ia32,
> so they will need a closer look by people more familiar with those
> arches.

Cool, yes please. It looks like MIPS will need to be skipped for now. I
would have the debug cache reporting patch then depend on
!CONFIG_HAVE_SPARSE_SYSCALL_NR.

> > I'd still like to get more specific workload performance numbers too.
> > The microbenchmark is nice, but getting things like build times under
> > docker's default seccomp filter, etc would be lovely. I've almost gotten
> > there, but my benchmarks are still really noisy and CPU isolation
> > continues to frustrate me. :)
> 
> Ok, let me know if I can help.

Do you have a test environment where you can compare the before/after
of repeated kernel build times (or some other sufficiently
complex/interesting) workload under these conditions:

bare metal
docker w/ seccomp policy disabled
docker w/ default seccomp policy

This is what I've been trying to construct, but it's really noisy, so
I've been trying to pin CPUs and NUMA memory nodes, but it's not really
helping yet. :P

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
