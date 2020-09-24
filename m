Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE225C47429
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 06:52:26 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 289172395A
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 06:52:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="IjvwHDuO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 289172395A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id A1BE92A0D9;
	Thu, 24 Sep 2020 06:52:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jQ-SxS8CtBkD; Thu, 24 Sep 2020 06:52:24 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 6926A204A4;
	Thu, 24 Sep 2020 06:52:24 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4BB1EC0859;
	Thu, 24 Sep 2020 06:52:24 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B6A37C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 06:52:22 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id ACA0886B11
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 06:52:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 3JGj6fyzI7Ms
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 06:52:22 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f65.google.com (mail-pj1-f65.google.com
 [209.85.216.65])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 0CB5186A8E
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 06:52:22 +0000 (UTC)
Received: by mail-pj1-f65.google.com with SMTP id q4so1150660pjh.5
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 23:52:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=7CCPIZlew0HbBYh6o4RhoViTEMk2IJj8qqgM/1ilcsk=;
 b=IjvwHDuOZhYxiKk5rGRzbTJSz4CvNMuL/Bw50mnVKKJCCmYCIkG3LPK+ZhEUhz0IBa
 Lc8PPhKv15Rlh/TOPi/5T/m+GGmJsh2KADJTPcnByV3mRN6f28st7i6o3/g6awYca3Al
 L3J+938e5086Ib68nasdGRrE3ACJ7GVaryhvU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=7CCPIZlew0HbBYh6o4RhoViTEMk2IJj8qqgM/1ilcsk=;
 b=gTTxPR4O8ruX03BcmxEngWh2tpE9FEDH/Jxxef0K9qZE/cE6apoK9CrYNwraVgFafW
 dPAE/ufbnJfqIhGXznFnkWK3YhDWDjI50sogLRhV6RYprOsIkrgabribtSk2LlV62409
 mM1tbYhyMIO2TzsAaLRfzQgtK6rWF2J9/Y5WTbKJWo//1yVbAH1GdidHBNE/WztoVZGF
 2VmkDckB6h0Gj15j9gXD7Llw0uqVCGyu5oks3bqecG9jRpmU5exlv9Ik33PFmuoTpq4I
 a1GY+pnTZruXtBxwu50aTdgELIr9G+lHpWvNlin91lO/1CLZQgn2VlJes9MaZLsnHAds
 d1QA==
X-Gm-Message-State: AOAM532fxjTMpPVZ6o9GB4wp0h+VfkKj3CeFkLyJ0fFVekg+zIZexb6N
 Pjj+hPNIFoKIRZbfp7cyVMXhhA==
X-Google-Smtp-Source: ABdhPJzq7ELh3YIQhcHZ8HdH22fqLwsTMjIs1wcWhiPUhmVT5b9cF8PzCaJcckm2GCQ9iHXVAQkEjw==
X-Received: by 2002:a17:90b:1216:: with SMTP id
 gl22mr2614202pjb.121.1600930341608; 
 Wed, 23 Sep 2020 23:52:21 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id y29sm1735134pfq.207.2020.09.23.23.52.20
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 23 Sep 2020 23:52:20 -0700 (PDT)
Date: Wed, 23 Sep 2020 23:52:19 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [RFC PATCH seccomp 0/2] seccomp: Add bitmap cache of
 arg-independent filter results that allow syscalls
Message-ID: <202009232348.448EC2088@keescook>
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <202009231224.21BCB3BC6@keescook>
 <CABqSeAR+69BQ7OKJ9o2DD1=uz8ZozY8ygu41oodn-GUYb_gVmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeAR+69BQ7OKJ9o2DD1=uz8ZozY8ygu41oodn-GUYb_gVmQ@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf <bpf@vger.kernel.org>,
 Tianyin Xu <tyxu@illinois.edu>
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

On Wed, Sep 23, 2020 at 05:54:51PM -0500, YiFei Zhu wrote:
> On Wed, Sep 23, 2020 at 2:26 PM Kees Cook <keescook@chromium.org> wrote:
> > Did you see the RFC series for this?
> >
> > https://lore.kernel.org/lkml/20200616074934.1600036-1-keescook@chromium.org/
> > [...]
> > Which also includes updated benchmarking:
> >
> > https://lore.kernel.org/lkml/20200616074934.1600036-6-keescook@chromium.org/
> 
> Nice. I was not aware of that series. Looking at it, it seems that our
> reasoning for checking arch and nr only, and verify if the filter
> accesses anything else, is the same. However, the approach in that RFC
> used was some page table dark magic, and it has been concluded that an
> emulator is superior. Was there a seperate patch series with emulator?
> If not, would you mind me cherry-picking some of your changes in that
> series?

I've sent that series refreshed with Jann's emulator now[1]. (Which I
see you've replied to as well, but I figured I'd just link these threads
for any future archaeology. ;)

> Also, I see that BPF_AND is said to be used in the discussion of the
> linked series. I think it wouldn't hurt to emulate a few BPF_ALU so
> I'll add that.

If you could add ALU|AND, that would get us complete coverage for
libseccomp and Chrome. I don't want the emulator to get any more complex
than that, as I view it as fairly high risk part. As you can see, I
tried really hard to _not_ use an emulator in the RFC. ;)

[1] https://lore.kernel.org/lkml/20200923232923.3142503-1-keescook@chromium.org/

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
