Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4115EC4346E
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 00:16:23 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 936F123977
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 00:16:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="F0LNJat7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 936F123977
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 302EB2E120;
	Fri, 25 Sep 2020 00:16:22 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QyxI1GcAZngy; Fri, 25 Sep 2020 00:16:21 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 6DDDB20413;
	Fri, 25 Sep 2020 00:16:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 519F2C0859;
	Fri, 25 Sep 2020 00:16:21 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 87A8BC0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 00:16:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 6B95D86C5A
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 00:16:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id lu8Tf9ZEhIo2
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 00:16:19 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com
 [209.85.208.65])
 by whitealder.osuosl.org (Postfix) with ESMTPS id DE13386B05
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 00:16:18 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id ay8so687508edb.8
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 17:16:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=7xIf+Wd02QlRb8dihS/DiLbBEmJ1zW6xAEVbZ5dS26E=;
 b=F0LNJat78CdDpEaqZQuJ1tqYitJYzbyqPAVCgU18z7GFkfA1gi8abPuI4hVEqqNjrO
 7qCIQUkxAI8zgQLp6PDo1dx9GDy0tpvikrn94cKA25Mw9Wd+CoYHKC1yZ9q7T16cQQTP
 H/U9JPG7AON51/TYdL6xeqM6iEgi+a5lpR/BMpU/gSs626kra6z2IKHMZURbKhbDWw58
 6hjmQKMFCy0B2LOAm2Bil0vYBlPkNu7nqxMWYn/VdN+36tDP8DNnEU9pi+Ogx8r10v1s
 Lg4LyJNKT6TRNahT1JulTgdRE1uBn1YZNSvD0yr2jskQl+ue+H+AxIuqrs1ABIGv450a
 0QMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=7xIf+Wd02QlRb8dihS/DiLbBEmJ1zW6xAEVbZ5dS26E=;
 b=Z8zJH6fOFmC5eBrIse7lDEVaJw+gggb9zM5fUVTq4B3Udb6VdLLNFBLNC16/iyP+1h
 bOfbWtyc8kU2NarsMTcyORa2TDWbbz1RT7OtAMW97ckpdTjjn1rEFBX2mk14g/CK8xG0
 BLtuB5nyZBvnqe5QIdROT/K1YHulIo0mLLnkazhBE0+Un37qCZqv3AQap/R0znB+Ceot
 bJAh9MNhf0DF5EEbG54T+1nAmsPBVqYlv62VRxA0dGj3+ERvyEYkJ7gqqsLCepu2nD3s
 YTw2ePbMKU1SbNciJILzjeoBXvdlsbPFBeBpU6wQJrzylglhZtwdw7nO0xHrgV350Gew
 Jqqw==
X-Gm-Message-State: AOAM531rdbQUdF/riw2Lqkjb0Tcga/h2H9u61+HAE14eWZ++58LqLUIc
 ynA9i6ZFxV6mCieeyBoIt6L9xeTxI5geiggYPooKOg==
X-Google-Smtp-Source: ABdhPJxKKrQDdHZi95Ynf871qKWysLRg5gjvkYXRdU159HiWVv61BCzjOFRKE4h3CAptn9KbJU134l/l0xSFubL6Qkw=
X-Received: by 2002:a05:6402:176c:: with SMTP id
 da12mr1354480edb.386.1600992977013; 
 Thu, 24 Sep 2020 17:16:17 -0700 (PDT)
MIME-Version: 1.0
References: <b792335294ee5598d0fb42702a49becbce2f925f.1600661419.git.yifeifz2@illinois.edu>
 <202009241658.A062D6AE@keescook>
In-Reply-To: <202009241658.A062D6AE@keescook>
Date: Fri, 25 Sep 2020 02:15:50 +0200
Message-ID: <CAG48ez2R1fF2kAUc7vOOFgaE482jA94Lx+0oWiy6M5JeM2HtvA@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 2/6] asm/syscall.h: Add syscall_arches[] array
To: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Fri, Sep 25, 2020 at 2:01 AM Kees Cook <keescook@chromium.org> wrote:
> 2) seccomp needs to handle "multiplexed" tables like x86_x32 (distros
>    haven't removed CONFIG_X86_X32 widely yet, so it is a reality that
>    it must be dealt with), which means seccomp's idea of the arch
>    "number" can't be the same as the AUDIT_ARCH.

Sure, distros ship it; but basically nobody uses it, it doesn't have
to be fast. As long as we don't *break* it, everything's fine. And if
we ignore the existence of X32 in the fastpath, that'll just mean that
syscalls with the X32 marker bit always hit the seccomp slowpath
(because it'll look like the syscall number is out-of-bounds ) - no
problem.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
