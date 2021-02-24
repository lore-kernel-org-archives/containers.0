Return-Path: <SRS0=nBW1=H2=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 386D9C433DB
	for <containers@archiver.kernel.org>; Wed, 24 Feb 2021 19:17:48 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8C9DE64E90
	for <containers@archiver.kernel.org>; Wed, 24 Feb 2021 19:17:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C9DE64E90
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 2364E4314F;
	Wed, 24 Feb 2021 19:17:47 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VbUZSmH9ghve; Wed, 24 Feb 2021 19:17:46 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp2.osuosl.org (Postfix) with ESMTP id 2D2ED430BE;
	Wed, 24 Feb 2021 19:17:46 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 076A8C000B;
	Wed, 24 Feb 2021 19:17:46 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id ED733C0001
 for <containers@lists.linux-foundation.org>;
 Wed, 24 Feb 2021 19:17:44 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id CF1A76F6AE
 for <containers@lists.linux-foundation.org>;
 Wed, 24 Feb 2021 19:17:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp3.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=linux-foundation.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id M7r-FwxqHqRa
 for <containers@lists.linux-foundation.org>;
 Wed, 24 Feb 2021 19:17:43 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from mail-lj1-f173.google.com (mail-lj1-f173.google.com
 [209.85.208.173])
 by smtp3.osuosl.org (Postfix) with ESMTPS id 8C8D76F6AD
 for <containers@lists.linux-foundation.org>;
 Wed, 24 Feb 2021 19:17:43 +0000 (UTC)
Received: by mail-lj1-f173.google.com with SMTP id m11so2853105lji.10
 for <containers@lists.linux-foundation.org>;
 Wed, 24 Feb 2021 11:17:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=linux-foundation.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=LsetPJB5m47FCg13KC6GjSTLKBsPDI7MuzXhPKMTnS4=;
 b=g0wCVRLuZhRAZSx2tZaeQKkHmjHJt6HcVeX1wF81XK3ID/P21CzwT5FyHF6bzyJiaK
 7Wbpg65iES9Lwj24IG8yT/fkKOgtfPxfvdKC+qXihnsfhzxP5qlnVz0sgNHOO9KXWCV6
 eIoO/wnpUtMRNAs14sprZgujgxrvqBNk1ASSY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=LsetPJB5m47FCg13KC6GjSTLKBsPDI7MuzXhPKMTnS4=;
 b=CrwsFHJxRnib9scV+QglqkawTVts97v+VOIw0LJ4/OF3aYMTKB6wxT1DcyfZeJW0HE
 rRNpzai2AN1SCe6YebOTe1e1LpzlxNxOdC75cCei9v/yBi3EijS9E309s/11apGgrewN
 5TByygpBcCjonyT4d3WeWy/jLTcowL85rqO2T7roz6o+UeSyVGKiuzyc16N6CY3ouIc1
 OwkiEn/QTqqwC3EBSmxd/jZ3szV0slbeCZECGx1cCCKvC9YaTKahPnH+p4WrUHzMFHrQ
 K4qeXyFIaYn9FkBsYYEOVa268ZZG68mstkkkHSFcEWhxvIh44s/825Fq42w0iji4FcTM
 Gk4Q==
X-Gm-Message-State: AOAM533PXP4R/U+ENnFLzh20qGwkYvw9oZFMqvCvf9QRbsVIrLtnmPl+
 MHdOQuQk7HG9iTaTZAJHPkOW/LE937WI6PUn
X-Google-Smtp-Source: ABdhPJx8e/TaB4jLt5UBAvVf8y6Rq4LsYo5B5nL67mwyL8cX2K7/K1RCkhQyaoLYe4eLq30A6JYLHQ==
X-Received: by 2002:a2e:b806:: with SMTP id u6mr3251506ljo.99.1614194260684;
 Wed, 24 Feb 2021 11:17:40 -0800 (PST)
Received: from mail-lj1-f182.google.com (mail-lj1-f182.google.com.
 [209.85.208.182])
 by smtp.gmail.com with ESMTPSA id v72sm658108lfa.77.2021.02.24.11.17.40
 for <containers@lists.linux-foundation.org>
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Wed, 24 Feb 2021 11:17:40 -0800 (PST)
Received: by mail-lj1-f182.google.com with SMTP id y7so3703378lji.7
 for <containers@lists.linux-foundation.org>;
 Wed, 24 Feb 2021 11:17:40 -0800 (PST)
X-Received: by 2002:a05:6512:a8c:: with SMTP id
 m12mr20000602lfu.253.1614193859813; 
 Wed, 24 Feb 2021 11:10:59 -0800 (PST)
MIME-Version: 1.0
References: <20210224051845.GB6114@xsang-OptiPlex-9020>
 <m1czwpl83q.fsf@fess.ebiederm.org>
 <20210224183828.j6uut6sholeo2fzh@example.org>
In-Reply-To: <20210224183828.j6uut6sholeo2fzh@example.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 24 Feb 2021 11:10:43 -0800
X-Gmail-Original-Message-ID: <CAHk-=wh3wVpx97e=n2D98W+PSDWUkQrX3O+c7n7MGRbn_k9JMg@mail.gmail.com>
Message-ID: <CAHk-=wh3wVpx97e=n2D98W+PSDWUkQrX3O+c7n7MGRbn_k9JMg@mail.gmail.com>
Subject: Re: d28296d248: stress-ng.sigsegv.ops_per_sec -82.7% regression
To: Alexey Gladkov <gladkov.alexey@gmail.com>
Cc: Jens Axboe <axboe@kernel.dk>, Feng Tang <feng.tang@intel.com>,
 0day robot <lkp@intel.com>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>,
 lkp@lists.01.org, kernel test robot <oliver.sang@intel.com>,
 "Eric W. Biederman" <ebiederm@xmission.com>, "Huang,
 Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>,
 zhengjun.xing@intel.com, io-uring <io-uring@vger.kernel.org>,
 Kees Cook <keescook@chromium.org>
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

On Wed, Feb 24, 2021 at 10:38 AM Alexey Gladkov
<gladkov.alexey@gmail.com> wrote:
>
> One of the reasons for this is that I rolled back the patch that changed
> the ucounts.count type to atomic_t. Now get_ucounts() is forced to use a
> spin_lock to increase the reference count.

Yeah, that definitely should be an atomic type, since the extended use
of ucounts clearly puts way too much pressure on that ucount lock.

I remember complaining about one version of that patch, but my
complaint wasabout it changing semantics of the saturation logic (and
I think it was also wrong because it still kept the spinlock for
get_ucounts(), so it didn't even take advantage of the atomic
refcount).

Side note: I don't think a refcount_t" is necessarily the right thing
to do, since the ucount reference counter does its own saturation
logic, and the refcount_t version is imho not great.

So it probably just needs to use an atomic_t, and do the saturation
thing manually.

Side note: look at try_get_page(). That one actually does refcounting
with overflow protection better than refcount_t, in my opinion. But I
am obviously biased, since I wrote it ;)

See commits

    88b1a17dfc3e mm: add 'try_get_page()' helper function
    f958d7b528b1 mm: make page ref count overflow check tighter and
more explicit

with that "page->_recount" being just a regular atomic_t.

            Linus
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
