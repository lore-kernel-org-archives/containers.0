Return-Path: <SRS0=TA6K=DA=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A821EC4363D
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 22:55:07 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2DE9C208E4
	for <containers@archiver.kernel.org>; Wed, 23 Sep 2020 22:55:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oqxS8qNo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DE9C208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id B80F327422;
	Wed, 23 Sep 2020 22:55:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id w6jPQgmkRYpC; Wed, 23 Sep 2020 22:55:05 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 60145204F5;
	Wed, 23 Sep 2020 22:55:05 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 44A16C0859;
	Wed, 23 Sep 2020 22:55:05 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E566AC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 22:55:03 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id CE36286357
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 22:55:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Fw5YGfg9aqMs
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 22:55:03 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f66.google.com (mail-pj1-f66.google.com
 [209.85.216.66])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 67D79862AC
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 22:55:03 +0000 (UTC)
Received: by mail-pj1-f66.google.com with SMTP id v14so494137pjd.4
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 15:55:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=j5gedaAOsIrZq5PKp+0Jk61jv8ft5ubFJ6EeG7chCIU=;
 b=oqxS8qNogb1fOb/klYC76hy0bcc41q0PuzY3CDj6tCV0lcb956gAkHxiZj3rU9k0+8
 uZB7vX8Uma+S1r656ayq5CQA23gyP7By5daJaKsoZZgW7Q+/5Wvfl2f2tenLY8t8kreg
 XyxjAExc9P4c0jEkXHMJpwLc+oqXrcybu2y5hSOJiH4I64Uq3f96zEVLFA8Slrhw6yYc
 YBsho4nPU0JSMVcNrEt/+Y1wUZ6xZ/ULuH4Lsrf7xpRf1Na0AxY63IVz+RAq8GAO3KpO
 zWq8HFKk5yMQ7ezF454KzOahj6mNFd/SWrdIqK3isAyqBgayqQHSwVQLP5n3GbY11LkM
 XbBA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=j5gedaAOsIrZq5PKp+0Jk61jv8ft5ubFJ6EeG7chCIU=;
 b=GmVtArbp5cXJamABGWl76xStjM9VsUebkkYp+aj0bMM35RVcrvGNTdiZ6TLrS+A1RH
 vQwZC2hvY37NR42Aynit0UXgbbpR6df5gnkM66cUhQ2FIXPtQf3DKfanIxLS7tXX3/h1
 G4Bg5pv2dLut3S6QIlHfLQOH9xMevoPqX6aOP8HCtEJSMyrqNVG4Wj+8obhffIVMT3aD
 XxE2F9c4mTy2U86ofI2JJqOJ+T2yIlmYQXbFqNHIkTeZ0GLmtJQ9Vj9/a8pp7VHv7Aji
 1NRf/SUUCdkzsGjpEeCoHdEGFb4ZQ4BBWVV9dJL+AUd787dOjCrKH3KJprM/g4u99Qmr
 xzTQ==
X-Gm-Message-State: AOAM532L773PA/WyvJpdFCOhN4JR8PGLCT9sCjIdIi5buwK1sEd8FNFX
 pv5exKu3xwJ/oKhkv4pFozp7LwlCUAS22zs2FTY=
X-Google-Smtp-Source: ABdhPJwWSQ9+l2sCXZKxSDP+41/D+lmN46Z+3/yUp8q+V4zRWvBBiZCDqQZudlbnm+7yPGL7OLs4b0hruVR4z8E+SrQ=
X-Received: by 2002:a17:90b:3252:: with SMTP id
 jy18mr1305967pjb.1.1600901702921; 
 Wed, 23 Sep 2020 15:55:02 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <202009231224.21BCB3BC6@keescook>
In-Reply-To: <202009231224.21BCB3BC6@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Wed, 23 Sep 2020 17:54:51 -0500
Message-ID: <CABqSeAR+69BQ7OKJ9o2DD1=uz8ZozY8ygu41oodn-GUYb_gVmQ@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 0/2] seccomp: Add bitmap cache of
 arg-independent filter results that allow syscalls
To: Kees Cook <keescook@chromium.org>
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

On Wed, Sep 23, 2020 at 2:26 PM Kees Cook <keescook@chromium.org> wrote:
> Did you see the RFC series for this?
>
> https://lore.kernel.org/lkml/20200616074934.1600036-1-keescook@chromium.org/
> [...]
> Which also includes updated benchmarking:
>
> https://lore.kernel.org/lkml/20200616074934.1600036-6-keescook@chromium.org/

Nice. I was not aware of that series. Looking at it, it seems that our
reasoning for checking arch and nr only, and verify if the filter
accesses anything else, is the same. However, the approach in that RFC
used was some page table dark magic, and it has been concluded that an
emulator is superior. Was there a seperate patch series with emulator?
If not, would you mind me cherry-picking some of your changes in that
series?

Also, I see that BPF_AND is said to be used in the discussion of the
linked series. I think it wouldn't hurt to emulate a few BPF_ALU so
I'll add that.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
