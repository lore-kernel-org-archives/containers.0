Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E88DC4727C
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 23:08:17 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A66AD21D7D
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 23:08:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r5sE+p/X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A66AD21D7D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 4D3962152A;
	Mon, 21 Sep 2020 23:08:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id iqNoCwqU2nh1; Mon, 21 Sep 2020 23:08:14 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id A810D21509;
	Mon, 21 Sep 2020 23:08:14 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 83FDEC0889;
	Mon, 21 Sep 2020 23:08:14 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E06CDC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 23:08:12 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id A2A132079A
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 23:08:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id zqhp0kQNRtrH
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 23:08:12 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com
 [209.85.210.193])
 by silver.osuosl.org (Postfix) with ESMTPS id E8D53203FA
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 23:08:11 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id d9so10654696pfd.3
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 16:08:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=lBfBHyTFdB0GrrgRVq0oHDvf2JAuR+4dHuUo0HlID4Y=;
 b=r5sE+p/X8SNAElkJRkDSnQzx0S4DN0CDeKyfqmDxEhZlwvq/R+7k9LVFWChxQ9/Hga
 ryFDidiT4m48YQgSv9p5hPAY5WUyK0H4Jht8r+Q3cO7M2jQjVIfPEhnC71loez6a2ipq
 dMrBgyUI+nW3kxCM9zHIor/Xs9tIECIXv/a8JZ5gyMxb36AWnjPChH2H4S4IzCHmeIp3
 l5XL4wmCg4NI91dhdx/ZR4y/2cpik2xT17+wTpZwnU9x1kVRkPwFJoQtgY4xswu0Zbm/
 cm/r1o+7/VvvbTq3+smZGlsE5EQSp1p2Ec+rWQn0Y8KDSY709ebTYxieGwqfr17B1NaT
 EVnw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=lBfBHyTFdB0GrrgRVq0oHDvf2JAuR+4dHuUo0HlID4Y=;
 b=TjWsec4rP4PLCp7iJo5OG7RHoG3bbce1OvYr+HNlBk7YmoB98bGZuQkVcf7oiLkafb
 PLq5SYoAzk0JTBPNKTO7xUlPSnGoZmR2SQfCUqMdc6DAxFNLr3GkO//yk6k0Z92F7B+I
 WHuNGaFQEcImZ9qCv+KOnEWibkB+XYDkDSN11OAe7MP7R40+9XiYftlIqtG8J9hTytB3
 tzpTemSLRhBzI6Nw1NFoBVkDaY0GKYuI6LfPHkQ0rcDlu1jQA1BtXPcTA5TbBabz2dri
 gvRd7OcXmA3NVkqvrgwamgPQ/ghMu/G4+Leme1+Q3cyUPjkvGKE5geYupxpMfgAxpYNV
 M9nQ==
X-Gm-Message-State: AOAM533QfsMMl3XORKNSK7USjUIgIZyLBo9B9TsFWSyAn9fNSo8J+zBt
 Xskh/Y1MLp4UzCG/hSd0YhUhLV4YBZSsu92EPwc=
X-Google-Smtp-Source: ABdhPJwy4fPLgzwON5U2AO0MT+kd18TdzvBlPldd1/YW/sgykFmO9ubSe4y6iUOpS3BqvX1ZvjhjxEcbVPrH0iq/ghM=
X-Received: by 2002:a17:902:ed4b:b029:d1:cbfc:6382 with SMTP id
 y11-20020a170902ed4bb02900d1cbfc6382mr1911724plb.24.1600729691515; Mon, 21
 Sep 2020 16:08:11 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <b792335294ee5598d0fb42702a49becbce2f925f.1600661419.git.yifeifz2@illinois.edu>
 <CAG48ez3k0_7Vev_O=uV_WVuUGK6BPA0RyrYXMYSDV4DTMMe26g@mail.gmail.com>
 <CABqSeAROcwq0ZGzWaxyPm+LDHu6T_8CD7_1c-hdhaMikr_ECCA@mail.gmail.com>
 <CAG48ez2HytqFaJ6V9iA6YZrbZU3kG4bB7nETMfHPt0-wd5D1jg@mail.gmail.com>
In-Reply-To: <CAG48ez2HytqFaJ6V9iA6YZrbZU3kG4bB7nETMfHPt0-wd5D1jg@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Mon, 21 Sep 2020 18:08:00 -0500
Message-ID: <CABqSeAQDpJZdAD42myca=3BAGAJ9VyDjvEiXfcH+p3m4eo_vBw@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 2/2] seccomp/cache: Cache filter results that
 allow syscalls
To: Jann Horn <jannh@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, YiFei Zhu <yifeifz2@illinois.edu>,
 kernel list <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
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

On Mon, Sep 21, 2020 at 5:58 PM Jann Horn <jannh@google.com> wrote:
> > I do agree that an immutable bitmask is faster and easier to reason
> > about its correctness. However, I did not find the "code to statically
> > evaluate the filter for all syscall numbers" while reading seccomp.c.
> > Would you give me a pointer to that and I will see how to best make
> > use of it?
>
> I'm talking about the code you're adding in the other patch ("[RFC
> PATCH seccomp 1/2] seccomp/cache: Add "emulator" to check if filter is
> arg-dependent"). Sorry, that was a bit unclear.

I see, building an immutable accept bitmask when preparing and then
just use that when running it. I guess if the arch number issue is
resolved this should be more doable. Will do.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
