Return-Path: <SRS0=kdfE=IN=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_RED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39EEEC433DB
	for <containers@archiver.kernel.org>; Mon, 15 Mar 2021 22:19:42 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A75A664F0C
	for <containers@archiver.kernel.org>; Mon, 15 Mar 2021 22:19:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A75A664F0C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id 59B4560653;
	Mon, 15 Mar 2021 22:19:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id H02Ex5M5DnAD; Mon, 15 Mar 2021 22:19:40 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp3.osuosl.org (Postfix) with ESMTP id 54E80606AE;
	Mon, 15 Mar 2021 22:19:40 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 28E30C000B;
	Mon, 15 Mar 2021 22:19:40 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [IPv6:2605:bc80:3010::138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0E58FC0001
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Mar 2021 22:19:39 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id E68EF8376B
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Mar 2021 22:19:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp1.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=linux-foundation.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id egU_a3-f31cS
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Mar 2021 22:19:38 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-lf1-x12d.google.com (mail-lf1-x12d.google.com
 [IPv6:2a00:1450:4864:20::12d])
 by smtp1.osuosl.org (Postfix) with ESMTPS id 1F90983709
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Mar 2021 22:19:38 +0000 (UTC)
Received: by mail-lf1-x12d.google.com with SMTP id u4so59376640lfs.0
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Mar 2021 15:19:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=linux-foundation.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=JHuD9L12GwXv9CMjuewy7NJi4UEeZj8gMIMY0fXoMjo=;
 b=S+PBvkiNvoS7h8zAD5cjsSRJz4FVPn0bUbOW1vAx3cSOxv0XYlgWOMD63ht2EW+UvG
 WqRwvdt1hEocnp30SVofJDviTh5NFMlDuAZFdZ0CFQTPQzKAvpCn4FZXTYX5F2Q7x0TA
 w6hkZe/5rBy3BNMBjtwIU8r7P3WUEjnalDrr4=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=JHuD9L12GwXv9CMjuewy7NJi4UEeZj8gMIMY0fXoMjo=;
 b=CH05C7Ku6SvZa9ykVPj3WIihUFgXl76jEjjRzep/zxHKOZzYtDKsjHt+QmVfD334Sh
 mSV2MGTl7KxH95tudGrjvuvDsY61xJ89t9zTfioEKyG3Cads94cXTdtN0cZp6fl81u2w
 PDXLwGH9KcXns+i3OnJF3glKp0+5se40aorgHJkkViKLtxqQeKoAm0BhtzSSBzBamaFE
 +uQbiFvnj2hAVnuFFBd9Th7WA4DrxIZjrOCjB+6auRAipHn3dVfUuZtFFiDMNHjELFNi
 7/2OjQlFPrIMjolyo5lgKkda0yYhac9LZus0xwM/ZSpxR7JQUyYSSqU/TZVHBxCVpX4/
 h6uw==
X-Gm-Message-State: AOAM530NRxtZ4pdeL3jr3guSoloNFXiNo8zrFF5O77cPabEtKm/3YvyY
 9M2/mzRrgLhADAn/qchCDqzihI6EP5Fy6T0t
X-Google-Smtp-Source: ABdhPJzs7YYxG4gcZDue1c4ROUKjjIccmdCkyt/ANwqqdwbiC7ff6BUb7F9NkVdidtZU3/e6pFkhnw==
X-Received: by 2002:a19:2402:: with SMTP id k2mr9935983lfk.138.1615846775369; 
 Mon, 15 Mar 2021 15:19:35 -0700 (PDT)
Received: from mail-lj1-f180.google.com (mail-lj1-f180.google.com.
 [209.85.208.180])
 by smtp.gmail.com with ESMTPSA id k6sm2817130lfg.28.2021.03.15.15.19.33
 for <containers@lists.linux-foundation.org>
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Mon, 15 Mar 2021 15:19:34 -0700 (PDT)
Received: by mail-lj1-f180.google.com with SMTP id f16so18145413ljm.1
 for <containers@lists.linux-foundation.org>;
 Mon, 15 Mar 2021 15:19:33 -0700 (PDT)
X-Received: by 2002:a2e:a589:: with SMTP id m9mr729361ljp.220.1615846773296;
 Mon, 15 Mar 2021 15:19:33 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1615372955.git.gladkov.alexey@gmail.com>
 <59ee3289194cd97d70085cce701bc494bfcb4fd2.1615372955.git.gladkov.alexey@gmail.com>
 <202103151426.ED27141@keescook>
In-Reply-To: <202103151426.ED27141@keescook>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 15 Mar 2021 15:19:17 -0700
X-Gmail-Original-Message-ID: <CAHk-=wjYOCgM+mKzwTZwkDDg12DdYjFFkmoFKYLim7NFmR9HBg@mail.gmail.com>
Message-ID: <CAHk-=wjYOCgM+mKzwTZwkDDg12DdYjFFkmoFKYLim7NFmR9HBg@mail.gmail.com>
Subject: Re: [PATCH v8 3/8] Use atomic_t for ucounts reference counting
To: Kees Cook <keescook@chromium.org>
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

On Mon, Mar 15, 2021 at 3:03 PM Kees Cook <keescook@chromium.org> wrote:
>
> On Wed, Mar 10, 2021 at 01:01:28PM +0100, Alexey Gladkov wrote:
> > The current implementation of the ucounts reference counter requires the
> > use of spin_lock. We're going to use get_ucounts() in more performance
> > critical areas like a handling of RLIMIT_SIGPENDING.
>
> This really looks like it should be refcount_t.

No.

refcount_t didn't have the capabilities required.

It just saturates, and doesn't have the "don't do this" case, which
the ucounts case *DOES* have.

In other words, refcount_t is entirely misdesigned for this - because
it's literally designed for "people can't handle overflow, so we warn
and saturate".

ucounts can never saturate, because they replace saturation with
"don't do that then".

In other words, ucounts work like the page counts do (which also don't
saturate, they just say "ok, you can't get a reference".

I know you are attached to refcounts, but really: they are not only
more expensive, THEY LITERALLY DO THE WRONG THING.

           Linus
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
