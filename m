Return-Path: <SRS0=7SHr=IO=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_RED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A267BC433E6
	for <containers@archiver.kernel.org>; Tue, 16 Mar 2021 19:33:03 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3F00164EB3
	for <containers@archiver.kernel.org>; Tue, 16 Mar 2021 19:33:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F00164EB3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id 0107B60716;
	Tue, 16 Mar 2021 19:33:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mHXNE2IK0OkL; Tue, 16 Mar 2021 19:33:02 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp3.osuosl.org (Postfix) with ESMTP id 08EDD606D0;
	Tue, 16 Mar 2021 19:33:02 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id BFE4AC000D;
	Tue, 16 Mar 2021 19:33:01 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7E3E0C000B
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 19:33:00 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 5E2456001B
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 19:33:00 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id UbefS2JxgmBe
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 19:32:59 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-pj1-x1029.google.com (mail-pj1-x1029.google.com
 [IPv6:2607:f8b0:4864:20::1029])
 by smtp3.osuosl.org (Postfix) with ESMTPS id B6CBE606D0
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 19:32:59 +0000 (UTC)
Received: by mail-pj1-x1029.google.com with SMTP id
 kk2-20020a17090b4a02b02900c777aa746fso16516pjb.3
 for <containers@lists.linux-foundation.org>;
 Tue, 16 Mar 2021 12:32:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=m51X9CHwtfCE5IH0P5AqXawZY6zUnwHs3ugCFSUHYWY=;
 b=O7izbeJETQwKGKZ937uPGZzffYmkBls3HZoWUKMlGCiundJ7Esi6XAj8SgsJvWW0bv
 EJUFAG+4vJqYaQUGivkM98LHXg2BKzD8QVMa4YwQpHq1qpaDrWp8lpCb3ag0Q4QiV/vF
 6tH4HcqcvVGLbNhOh8UgqfrH9b3TNRcSjeCPw=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=m51X9CHwtfCE5IH0P5AqXawZY6zUnwHs3ugCFSUHYWY=;
 b=I4didmp5gxP86TRpUmkEwVjqm1n8CtZiAo5iIezodLh6lJNfd/epM3EIjBCh5FEQB6
 AB5cGQRyjXKQl7hJWFjzPKvmctRcHqV851R9qtwf78GbdDK1bPkgMZ7PWIvC5Lk1uHGD
 sKtWRYwegRj/VM/Z2y4DrMwuNiDY9ZCSAqllefYqy8xXzF8qSJomEykNYrCOpuCW2ks/
 qIzWUXGbuWOdBEi9iqvWb3a0WXz7fRQXMdOOOlc3neNl72aRi9jYGbw/0RvZtb8c/dAE
 a0HhwEUuRF3OalDA8PFeZRyfake6jF30Gs70Q4bfplytv9UzQXvgZpnSCjR1gD6ZlIYu
 wAxw==
X-Gm-Message-State: AOAM532QexVvRIPCIevajoP68t2jm6UNVqSIhq0VQ0/DtVvCJJXgHCoz
 Ke8KQnXYl9cS9HxGut2V/IXGyg==
X-Google-Smtp-Source: ABdhPJymLmZUQcJf9mTPzHM6y4qPylvnlWR8uKp+iBIhoMb95+cXNuw7H/BK680P/1W8mJYXiVs6sg==
X-Received: by 2002:a17:902:c1d5:b029:e6:52e0:6bdd with SMTP id
 c21-20020a170902c1d5b02900e652e06bddmr902471plc.49.1615923179208; 
 Tue, 16 Mar 2021 12:32:59 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id fr23sm193056pjb.22.2021.03.16.12.32.58
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Tue, 16 Mar 2021 12:32:58 -0700 (PDT)
Date: Tue, 16 Mar 2021 12:32:57 -0700
From: Kees Cook <keescook@chromium.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v8 3/8] Use atomic_t for ucounts reference counting
Message-ID: <202103161229.75FDE42F@keescook>
References: <cover.1615372955.git.gladkov.alexey@gmail.com>
 <59ee3289194cd97d70085cce701bc494bfcb4fd2.1615372955.git.gladkov.alexey@gmail.com>
 <202103151426.ED27141@keescook>
 <CAHk-=wjYOCgM+mKzwTZwkDDg12DdYjFFkmoFKYLim7NFmR9HBg@mail.gmail.com>
 <202103161146.E118DE5@keescook>
 <CAHk-=wj7k2nCB8Q5kMYsYi1ajb99yZ-EYn_MYFMQ2bw3nWuT5Q@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAHk-=wj7k2nCB8Q5kMYsYi1ajb99yZ-EYn_MYFMQ2bw3nWuT5Q@mail.gmail.com>
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

On Tue, Mar 16, 2021 at 12:26:05PM -0700, Linus Torvalds wrote:
> Note that the above very intentionally does allow the "we can go over
> the limit" case for another reason: we still have that regular
> *unconditional* get_page(), that has a "I absolutely need a temporary
> ref to this page, but I know it's not some long-term thing that a user
> can force". That's not only our traditional model, but it's something
> that some kernel code simply does need, so it's a good feature in
> itself. That might be less of an issue for ucounts, but for pages, we
> somethines do have "I need to take a ref to this page just for my own
> use while I then drop the page lock and do something else".

Right, get_page() has a whole other set of requirements. :) I just
couldn't find the "we _must_ to get a reference to ucounts" code path,
so I was scratching my head.

> And it's possible that "refcount_t" could use that exact same model,
> and actually then offer that option that ucounts wants, of a "try to
> get a refcount, but if we have too many refcounts, then never mind, I
> can just return an error to user space instead".

Yeah, if there starts to be more of these cases, I think it'd be a
nice addition. And with the recent performance work Will Deacon did on
refcount_t, I think any general performance concerns are met now. But
I'd love to just leave refcount_t alone until we can really show a need
for an API change. :P

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
