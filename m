Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CE47C433DF
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 20:59:49 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8D3E622259
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 20:59:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="0WbDWoyJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D3E622259
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 2B7842E15A;
	Fri,  9 Oct 2020 20:59:48 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8tbQ7hsWLi9P; Fri,  9 Oct 2020 20:59:47 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 8CB7020476;
	Fri,  9 Oct 2020 20:59:47 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7CA36C016F;
	Fri,  9 Oct 2020 20:59:47 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id DDC47C0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 20:59:45 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id D0622871F0
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 20:59:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 58rGAuiGY-S8
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 20:59:45 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 70C65871EE
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 20:59:45 +0000 (UTC)
Received: from mail-wr1-f41.google.com (mail-wr1-f41.google.com
 [209.85.221.41])
 (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
 (No client certificate requested)
 by mail.kernel.org (Postfix) with ESMTPSA id B5A5F222EA
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 20:59:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
 s=default; t=1602277185;
 bh=K2FMVcPnwpnFdFTH0nWKguSV5alJGPLhcP/xaLhn8SY=;
 h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
 b=0WbDWoyJhSvlQ/9KmhcYAraUDQn9/GNW1Dgw0FK6r6Kx9ocUAq9ltOKxoWihM/jJM
 9+PDgGyjK9I7t+Oag/P2EdOyb2jiNSR0r7uB4kouuLpmbA2wzxPexcXryPXXZBpSlp
 STMGl7CsXcGiTdduLMw4vkXoQtfsyhpJ6E0mJsgQ=
Received: by mail-wr1-f41.google.com with SMTP id t9so11637015wrq.11
 for <containers@lists.linux-foundation.org>;
 Fri, 09 Oct 2020 13:59:44 -0700 (PDT)
X-Gm-Message-State: AOAM531/yNEYUhZZbuBHUQRWiGEGTC16D4znRfMAZEcnNGHTcQmFU/j1
 c1/ARM91o01UAlRe2TXV3t3x7fjrnThED1iUhQNAEQ==
X-Google-Smtp-Source: ABdhPJxJKqPctdujsV6zYIcj1iFFsZubnKUTdB+gOUvULrurNfsxzHCDMX9gfPQHrqmvwfwZlZHma48kDaamaiRKqbs=
X-Received: by 2002:a05:6000:1202:: with SMTP id
 e2mr16591334wrx.75.1602277183196; 
 Fri, 09 Oct 2020 13:59:43 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <122e3e70cf775e461ebdfadb5fbb4b6813cca3dd.1602263422.git.yifeifz2@illinois.edu>
 <CALCETrUD7z3-zL_rATzTyDUzgerOzXJHdn-hntNMG=vnX8ZF2w@mail.gmail.com>
 <CABqSeAS0WdkLHGMg3TRKkzsUE=JJYwY4iuBgYpdp-kLd9ASOfg@mail.gmail.com>
In-Reply-To: <CABqSeAS0WdkLHGMg3TRKkzsUE=JJYwY4iuBgYpdp-kLd9ASOfg@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 9 Oct 2020 13:59:31 -0700
X-Gmail-Original-Message-ID: <CALCETrUcsQhYM3+y+geFNmVzscv30Rg=8P50zNtEpLBgEwf9Pg@mail.gmail.com>
Message-ID: <CALCETrUcsQhYM3+y+geFNmVzscv30Rg=8P50zNtEpLBgEwf9Pg@mail.gmail.com>
Subject: Re: [PATCH v4 seccomp 3/5] x86: Enable seccomp architecture tracking
To: YiFei Zhu <zhuyifei1999@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, LKML <linux-kernel@vger.kernel.org>,
 Hubertus Franke <frankeh@us.ibm.com>, David Laight <David.Laight@aculab.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
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

On Fri, Oct 9, 2020 at 11:32 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
>
> On Fri, Oct 9, 2020 at 12:25 PM Andy Lutomirski <luto@amacapital.net> wrote:
> > Is the idea that any syscall that's out of range for this (e.g. all of
> > the x32 syscalls) is unoptimized?  I'm okay with this, but I think it
> > could use a comment.
>
> Yes, any syscall number that is out of range is unoptimized. Where do
> you think I should put a comment? seccomp_cache_check_allow_bitmap
> above `if (unlikely(syscall_nr < 0 || syscall_nr >= bitmap_size))`,
> with something like "any syscall number out of range is unoptimized"?
>

I was imagining a comment near the new macros explaining that this is
the range of syscalls that seccomp will optimize, that behavior is
still correct (albeit slower) for out of range syscalls, and that x32
is intentionally not optimized.

This avoids people like future me reading this code, not remembering
the context, and thinking it looks buggy.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
