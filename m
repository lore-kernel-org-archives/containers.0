Return-Path: <SRS0=zkWj=GV=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96773C433DB
	for <containers@archiver.kernel.org>; Mon, 18 Jan 2021 19:15:20 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3431821D42
	for <containers@archiver.kernel.org>; Mon, 18 Jan 2021 19:15:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3431821D42
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id DA4D086F5F;
	Mon, 18 Jan 2021 19:15:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id EyeljRYaBlAZ; Mon, 18 Jan 2021 19:15:19 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 51F1386D92;
	Mon, 18 Jan 2021 19:15:19 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3D4FFC08A1;
	Mon, 18 Jan 2021 19:15:19 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0B2E7C013A
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 19:15:18 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 03F9020423
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 19:15:18 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 9vfwS+gfYsSF
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 19:15:09 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f47.google.com (mail-lf1-f47.google.com
 [209.85.167.47])
 by silver.osuosl.org (Postfix) with ESMTPS id 1D55D20424
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 19:15:09 +0000 (UTC)
Received: by mail-lf1-f47.google.com with SMTP id s26so25567628lfc.8
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 11:15:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=linux-foundation.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=/nyXt2BwkLcSSRby7WCMrmE+WdBMXZvF9/GDTDgxsVY=;
 b=FgEuPeyIPamZN1Ti5cyla9+JQiWchG5usHW0nz7RiFfN4ZG12cH4uk+0GptG8B/IWA
 J+9VHvATxzV0qZoPxsaWt52OJ2WeDAZZ0Ey4l9G4Byauek/KmFoS0wtarV9C1U/vQhcp
 zDcDF/LIEdOs4AuBkR07AWCI6pKVrt2L/RMZY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=/nyXt2BwkLcSSRby7WCMrmE+WdBMXZvF9/GDTDgxsVY=;
 b=IM0CsI6HdBRxeiatklUFaRF5B0D8sSSvb0QFUDrCChJs2L0Ip4v8CUkkXu60ivHbVG
 TkiiSBhhL4LVtBTM3sib5rzHwQMyUgIXRJKe+B8NO8j5DL+ZZaVmG8IX0S6NBcP+xBaa
 CWSzFlSi3Wipffcs0FD14NLSi6wI9w1rXr963jbMRWOV5TtvmHVjuFW3nMdKecbWIH58
 GxLu0FWgTuzdKsi5/apIQhWxptqeGNqCDm4R2stMrS/L1wPHyX+PuiqZFUxEqdCEoZ6x
 aJpRw/dJU6kmkfc+sLPACwZQv+WoOqFwxZ80dp46EL6OOHkkNOL62qp1VYa/2DpfCSJW
 +S9w==
X-Gm-Message-State: AOAM531qdqOauLtH0/L1/IX9XZ+bzxXXzgujAVB5cWpy8Uqni0HuCTGA
 xBqrB3qEJsSSAGbBRdcMrwklbnsXj+QE3yTe
X-Google-Smtp-Source: ABdhPJwAnaaDmaFtzhQNXW0lPSgB8F5/Nd9KjX/64gWWXDFiAjy0K4ebqc0rU3QluHw6SDTZ6FYg3Q==
X-Received: by 2002:a19:197:: with SMTP id 145mr248680lfb.352.1610997306458;
 Mon, 18 Jan 2021 11:15:06 -0800 (PST)
Received: from mail-lf1-f53.google.com (mail-lf1-f53.google.com.
 [209.85.167.53])
 by smtp.gmail.com with ESMTPSA id e20sm1755005lja.123.2021.01.18.11.15.04
 for <containers@lists.linux-foundation.org>
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Mon, 18 Jan 2021 11:15:05 -0800 (PST)
Received: by mail-lf1-f53.google.com with SMTP id m25so25562002lfc.11
 for <containers@lists.linux-foundation.org>;
 Mon, 18 Jan 2021 11:15:04 -0800 (PST)
X-Received: by 2002:a05:6512:a8c:: with SMTP id
 m12mr234936lfu.253.1610997304440; 
 Mon, 18 Jan 2021 11:15:04 -0800 (PST)
MIME-Version: 1.0
References: <cover.1610722473.git.gladkov.alexey@gmail.com>
 <116c7669744404364651e3b380db2d82bb23f983.1610722473.git.gladkov.alexey@gmail.com>
In-Reply-To: <116c7669744404364651e3b380db2d82bb23f983.1610722473.git.gladkov.alexey@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 18 Jan 2021 11:14:48 -0800
X-Gmail-Original-Message-ID: <CAHk-=wjsg0Lgf1Mh2UiJE4sqBDDo0VhFVBUbhed47ot2CQQwfQ@mail.gmail.com>
Message-ID: <CAHk-=wjsg0Lgf1Mh2UiJE4sqBDDo0VhFVBUbhed47ot2CQQwfQ@mail.gmail.com>
Subject: Re: [RFC PATCH v3 1/8] Use refcount_t for ucounts reference counting
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

On Fri, Jan 15, 2021 at 6:59 AM Alexey Gladkov <gladkov.alexey@gmail.com> wrote:
>
> @@ -152,10 +153,7 @@ static struct ucounts *get_ucounts(struct user_namespace *ns, kuid_t uid)
>                         ucounts = new;
>                 }
>         }
> -       if (ucounts->count == INT_MAX)
> -               ucounts = NULL;
> -       else
> -               ucounts->count += 1;
> +       refcount_inc(&ucounts->count);
>         spin_unlock_irq(&ucounts_lock);
>         return ucounts;
>  }

This is wrong.

It used to return NULL when the count saturated.

Now it just silently saturates.

I'm not sure how many people care, but that NULL return ends up being
returned quite widely (through "inc_uncount()" and friends).

The fact that this has no commit message at all to explain what it is
doing and why is also a grounds for just NAK.

           Linus
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
