Return-Path: <SRS0=7SHr=IO=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_RED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11358C433DB
	for <containers@archiver.kernel.org>; Tue, 16 Mar 2021 18:49:27 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 97DBC6511A
	for <containers@archiver.kernel.org>; Tue, 16 Mar 2021 18:49:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97DBC6511A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 53D4F43010;
	Tue, 16 Mar 2021 18:49:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8bG0CKfykZwS; Tue, 16 Mar 2021 18:49:25 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp2.osuosl.org (Postfix) with ESMTP id 507AE414DB;
	Tue, 16 Mar 2021 18:49:25 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 23608C000C;
	Tue, 16 Mar 2021 18:49:25 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1DEBCC000A
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 18:49:24 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id E9FD44EC76
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 18:49:23 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp4.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=chromium.org
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id kHbGYqTXw3oL
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 18:49:23 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-pj1-x102b.google.com (mail-pj1-x102b.google.com
 [IPv6:2607:f8b0:4864:20::102b])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 3263F4EC26
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 18:49:23 +0000 (UTC)
Received: by mail-pj1-x102b.google.com with SMTP id gb6so11117502pjb.0
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 11:49:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=Ywai4YPe6URsofe8kbvRJ5BLerohwMgOUz2A+yTu1V8=;
 b=Gi/mZifZtaRGM1hAEWLLYtHoNGjeBYezFLY4Ub3n4u88qoaWqF2dg8531Bz2gbABn6
 FO4WtNeX0KhGduNg1GnpbY9Y/CIeAnzjNt9lLhqJ3bQiOEJ4BtAToC4VblibmRyuvANn
 uwgAnFSNL24Cp92te+97NTCIADTkE1HxM61l4=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=Ywai4YPe6URsofe8kbvRJ5BLerohwMgOUz2A+yTu1V8=;
 b=L0h7g4Bm/P9QUyRwWlF0BSbSdJooi82I94FqZOUhyiZcc/MwWKg7uFdasQLhIwIVvv
 Lkq9qhkQoUp40oYIKNSJP5Z9u8rxmlApgQzWUHS361zMNdmseiFpWqEpUutgqedr64iS
 rKJ6AvOUz2co7pdpw3SE6YlSbT1G+VQpSVr+lgkrxMlb63Pf/SpZW02m5npY++7w/h0m
 tMcCj71nfgJr2dSTy9IM1hgrUKSta82ytq8mmc4YNNKvt18R8gy0BTl+ZWNfbPuqYTgd
 iLJ76SWp9yDl9/5jgfCzddQHpT+HyAoi1G4WqkTD/hOVCk+8UvQMGAxBKqre5VAFVNzB
 Cmsw==
X-Gm-Message-State: AOAM5334/pPGgf7GmZAXDoZOobqyi/p20iELMnwHNIUXr9oxZLZ0iUx2
 OVbhwliKGuxjBHzNoyRKViWLLA==
X-Google-Smtp-Source: ABdhPJz3uNdO8WaSSFDiiPWSz3MOZAP5SYHuuEd9I+bSp0sGeAPb9gjvi+a+I3tMUX5HzOo1dk+55Q==
X-Received: by 2002:a17:902:7612:b029:e5:f0dd:8667 with SMTP id
 k18-20020a1709027612b02900e5f0dd8667mr739777pll.59.1615920562658; 
 Tue, 16 Mar 2021 11:49:22 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id a30sm2800263pfr.66.2021.03.16.11.49.21
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Tue, 16 Mar 2021 11:49:21 -0700 (PDT)
Date: Tue, 16 Mar 2021 11:49:20 -0700
From: Kees Cook <keescook@chromium.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v8 3/8] Use atomic_t for ucounts reference counting
Message-ID: <202103161146.E118DE5@keescook>
References: <cover.1615372955.git.gladkov.alexey@gmail.com>
 <59ee3289194cd97d70085cce701bc494bfcb4fd2.1615372955.git.gladkov.alexey@gmail.com>
 <202103151426.ED27141@keescook>
 <CAHk-=wjYOCgM+mKzwTZwkDDg12DdYjFFkmoFKYLim7NFmR9HBg@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAHk-=wjYOCgM+mKzwTZwkDDg12DdYjFFkmoFKYLim7NFmR9HBg@mail.gmail.com>
Cc: Jens Axboe <axboe@kernel.dk>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Andrew Morton <akpm@linux-foundation.org>, Alexey Gladkov <legion@kernel.org>,
 io-uring <io-uring@vger.kernel.org>
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

On Mon, Mar 15, 2021 at 03:19:17PM -0700, Linus Torvalds wrote:
> It just saturates, and doesn't have the "don't do this" case, which
> the ucounts case *DOES* have.

Right -- I saw that when digging through the thread. I'm honestly
curious, though, why did the 0-day bot find a boot crash? (I can't
imagine ucounts wrapped in 0.4 seconds.) So it looked like an
increment-from-zero case, which seems like it would be a bug?

> I know you are attached to refcounts, but really: they are not only
> more expensive, THEY LITERALLY DO THE WRONG THING.

Heh, right -- I'm not arguing that refcount_t MUST be used, I just didn't
see the code path that made them unsuitable: hitting INT_MAX - 128 seems
very hard to do. Anyway, I'll go study it more to try to understand what
I'm missing.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
