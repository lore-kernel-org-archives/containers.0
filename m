Return-Path: <SRS0=zkWj=GV=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09BC2C433DB
	for <containers@archiver.kernel.org>; Mon, 18 Jan 2021 20:35:00 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A182B22CAD
	for <containers@archiver.kernel.org>; Mon, 18 Jan 2021 20:34:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A182B22CAD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 5842985B9D;
	Mon, 18 Jan 2021 20:34:59 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MNgJuDddsU5b; Mon, 18 Jan 2021 20:34:55 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 7A84F855F1;
	Mon, 18 Jan 2021 20:34:55 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4B633C088B;
	Mon, 18 Jan 2021 20:34:55 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 3C40FC013A
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 20:34:54 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 35598857D0
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 20:34:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id hIVDDR3Lasxq
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 20:34:50 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lj1-f173.google.com (mail-lj1-f173.google.com
 [209.85.208.173])
 by whitealder.osuosl.org (Postfix) with ESMTPS id B3D72855F1
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 20:34:49 +0000 (UTC)
Received: by mail-lj1-f173.google.com with SMTP id f17so19533917ljg.12
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 12:34:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=linux-foundation.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=s/gRDfD8YrbS3XwFv+1aIqhbdQ3uhWKzz+1gnqOggXc=;
 b=bt+FYJOGP9ZQRnSTHuwQLcEHZRbKmiPtmHbNsgK244Ouf8inj+gEKeqwbkLMxBsORz
 9XqHiL4j09NQl2Hbu7Zqohe8R4Mcab9BZ0x5QNfz6nqunlYqEM100bLwpChO1ztnC/8t
 YuMK5vRxoxly7Ufn/H5ahy9EptvTtBt/Xd6mM=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=s/gRDfD8YrbS3XwFv+1aIqhbdQ3uhWKzz+1gnqOggXc=;
 b=A23+QydwceGCZAGsfd8m1Ph5tkk7ZZugNTvGkhcUy9bWCgRSorTX41vQswIAsO1ZYQ
 3dMR2k3/WHh9ZiEtRB49c8bmD8tkF7NWbSpM/CfZtvIeh576fLF1GOvtiO7wUhwdUCCh
 yB3H4NpnTn9BG1d1ivuy0yykuDuMJVa9eRSyoIU7rtPMY4x6kFvuAjX4XyAjF/kDPgUS
 irjd7d8Wy97xCYtuzGpvi8kclG856yFEnGGnOUkWaZ9XLv0hTsMgTKtphG8jHNT1fLcV
 OQQfbPc6fmj5HUX6/9do68TwsA0tqY6Dn3sjmFjy96epEV7ErY68TS/PhwC9j89xj0VK
 3P2w==
X-Gm-Message-State: AOAM530iSopcbfzThw8rDWta2RVEF44Dv1nfGuPuZPRLSKqU8vMtwkJM
 wkEZ06QP0PVBaO1Y3Z+VCiNVwS41aVyaj0Kk
X-Google-Smtp-Source: ABdhPJymjfUNSu3+qI3DkaWwCKb/itjWqB7tN0MiFS9dd0SfM2XtjSxSnuU7OzyVMXKLCK4vuMDmfw==
X-Received: by 2002:a2e:b0e9:: with SMTP id h9mr564021ljl.64.1611002087225;
 Mon, 18 Jan 2021 12:34:47 -0800 (PST)
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com.
 [209.85.167.50])
 by smtp.gmail.com with ESMTPSA id d11sm2006531lfj.59.2021.01.18.12.34.45
 for <containers@lists.linux-foundation.org>
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Mon, 18 Jan 2021 12:34:46 -0800 (PST)
Received: by mail-lf1-f50.google.com with SMTP id o17so25936412lfg.4
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 12:34:45 -0800 (PST)
X-Received: by 2002:a19:8557:: with SMTP id h84mr336671lfd.201.1611002085703; 
 Mon, 18 Jan 2021 12:34:45 -0800 (PST)
MIME-Version: 1.0
References: <cover.1610722473.git.gladkov.alexey@gmail.com>
 <116c7669744404364651e3b380db2d82bb23f983.1610722473.git.gladkov.alexey@gmail.com>
 <CAHk-=wjsg0Lgf1Mh2UiJE4sqBDDo0VhFVBUbhed47ot2CQQwfQ@mail.gmail.com>
 <20210118194551.h2hrwof7b3q5vgoi@example.org>
In-Reply-To: <20210118194551.h2hrwof7b3q5vgoi@example.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 18 Jan 2021 12:34:29 -0800
X-Gmail-Original-Message-ID: <CAHk-=wiNpc5BS2BfZhdDqofJx1G=uasBa2Q1eY4cr8O59Rev2A@mail.gmail.com>
Message-ID: <CAHk-=wiNpc5BS2BfZhdDqofJx1G=uasBa2Q1eY4cr8O59Rev2A@mail.gmail.com>
Subject: Re: [RFC PATCH v3 1/8] Use refcount_t for ucounts reference counting
To: Alexey Gladkov <gladkov.alexey@gmail.com>
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Andrew Morton <akpm@linux-foundation.org>, io-uring <io-uring@vger.kernel.org>
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

On Mon, Jan 18, 2021 at 11:46 AM Alexey Gladkov
<gladkov.alexey@gmail.com> wrote:
>
> Sorry about that. I thought that this code is not needed when switching
> from int to refcount_t. I was wrong.

Well, you _may_ be right. I personally didn't check how the return
value is used.

I only reacted to "it certainly _may_ be used, and there is absolutely
no comment anywhere about why it wouldn't matter".

                 Linus
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
