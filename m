Return-Path: <SRS0=XC5U=HX=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B77AC433DB
	for <containers@archiver.kernel.org>; Sun, 21 Feb 2021 22:20:27 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D753564DC3
	for <containers@archiver.kernel.org>; Sun, 21 Feb 2021 22:20:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D753564DC3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 7FA97832D4
	for <containers@archiver.kernel.org>; Sun, 21 Feb 2021 22:20:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 2xSHsKLdEJZE for <containers@archiver.kernel.org>;
	Sun, 21 Feb 2021 22:20:25 +0000 (UTC)
Received: by smtp1.osuosl.org (Postfix, from userid 1001)
	id 5C5BF832C6; Sun, 21 Feb 2021 22:20:24 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 97F1A8329E;
	Sun, 21 Feb 2021 22:20:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7B4ECC000A;
	Sun, 21 Feb 2021 22:20:21 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 323D4C0001
 for <containers@lists.linux-foundation.org>;
 Sun, 21 Feb 2021 22:20:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 181F685B2F
 for <containers@lists.linux-foundation.org>;
 Sun, 21 Feb 2021 22:20:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id cUuoZ7Bdlpuj
 for <containers@lists.linux-foundation.org>;
 Sun, 21 Feb 2021 22:20:19 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lj1-f178.google.com (mail-lj1-f178.google.com
 [209.85.208.178])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 57561859BA
 for <containers@lists.linux-foundation.org>;
 Sun, 21 Feb 2021 22:20:19 +0000 (UTC)
Received: by mail-lj1-f178.google.com with SMTP id q14so52705791ljp.4
 for <containers@lists.linux-foundation.org>;
 Sun, 21 Feb 2021 14:20:19 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=linux-foundation.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=1qgd2CaVptvTGUhKDlRkh0Z0LDGRbgbRYJVc77psjI0=;
 b=fQbjNDMH2LW1wJ6/r4mnToB2sVMQoAqDNnIZC0tTft5RHW4oL4vhaTeQgpZVKMxF30
 nT/00d78iK839oXEHN4u+yaZt1zEu/r+rdbRCiRpFFQ0sRSQ1Q8kcb6WJ03qin0IMNCZ
 KtNASVw7j3Rywzu1pVAHxoAg6F7vA+1EvIbPA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=1qgd2CaVptvTGUhKDlRkh0Z0LDGRbgbRYJVc77psjI0=;
 b=Fh1dYS6Hpb+XalFbA11WLZugRehtCefV27Ok4mOI6d01GqNc83yMt/muPyEqIsjwS6
 8gIiJ+t/Ff36TSJi4opLuvkREHJnE7/OXxn93yX0GjerD2tc9sevYLJZm2bi7H9mPL24
 wtw4qDplNKd1a1GGAcr6uICa+W3OYleAr1VcEhSQfT2HEO0fHylJIQ2NdQol/0GsHPPW
 Wa6Wp7eUjixwNTjLYAoOOBPpGv8p4cxsahM5/FkrsdPlfpPwu5FHU6bqaHrWUwolKxhm
 StARRYu9AUuIZbdd3r2JHV050WxqWlJiU9BMgp/FlRrMBiRBjFZuH6iX6HKzOQFZIXkO
 ATAA==
X-Gm-Message-State: AOAM530O6ICHP/YljBhWpcVT/D003Pfpj5WTw8kwOWZntTYn2TEd+yKO
 OzAnbqSMl5uM8cJcS35PhcjVvPCF8x3XcGAz
X-Google-Smtp-Source: ABdhPJzaCtszxD01WBiBRjazsYIU0A8Uh30ntprV+V7mBQoq1vySgEuNEitqS8+Sk+cLDOgMaL1vEw==
X-Received: by 2002:a2e:95ce:: with SMTP id y14mr8051767ljh.80.1613946017382; 
 Sun, 21 Feb 2021 14:20:17 -0800 (PST)
Received: from mail-lj1-f178.google.com (mail-lj1-f178.google.com.
 [209.85.208.178])
 by smtp.gmail.com with ESMTPSA id q14sm1682476lfu.196.2021.02.21.14.20.16
 for <containers@lists.linux-foundation.org>
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Sun, 21 Feb 2021 14:20:17 -0800 (PST)
Received: by mail-lj1-f178.google.com with SMTP id r11so8070404ljk.9
 for <containers@lists.linux-foundation.org>;
 Sun, 21 Feb 2021 14:20:16 -0800 (PST)
X-Received: by 2002:ac2:4acd:: with SMTP id m13mr6041704lfp.201.1613946016272; 
 Sun, 21 Feb 2021 14:20:16 -0800 (PST)
MIME-Version: 1.0
References: <cover.1613392826.git.gladkov.alexey@gmail.com>
In-Reply-To: <cover.1613392826.git.gladkov.alexey@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 21 Feb 2021 14:20:00 -0800
X-Gmail-Original-Message-ID: <CAHk-=wjsmAXyYZs+QQFQtY=w-pOOSWoi-ukvoBVVjBnb+v3q7A@mail.gmail.com>
Message-ID: <CAHk-=wjsmAXyYZs+QQFQtY=w-pOOSWoi-ukvoBVVjBnb+v3q7A@mail.gmail.com>
Subject: Re: [PATCH v6 0/7] Count rlimits in each user namespace
To: Alexey Gladkov <gladkov.alexey@gmail.com>
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
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

On Mon, Feb 15, 2021 at 4:42 AM Alexey Gladkov <gladkov.alexey@gmail.com> wrote:
>
> These patches are for binding the rlimit counters to a user in user namespace.

So this is now version 6, but I think the kernel test robot keeps
complaining about them causing KASAN issues.

The complaints seem to change, so I'm hoping they get fixed, but it
does seem like every version there's a new one. Hmm?

            Linus
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
