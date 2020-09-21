Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECB80C4727D
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 22:51:11 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 69AFE23A63
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 22:51:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QUzlApk9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69AFE23A63
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id C8BE821503;
	Mon, 21 Sep 2020 22:51:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id DqmK+vjEXaGn; Mon, 21 Sep 2020 22:51:09 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 558C62052C;
	Mon, 21 Sep 2020 22:51:09 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3C72BC0859;
	Mon, 21 Sep 2020 22:51:09 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D17BDC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 22:51:07 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id B9D2E86378
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 22:51:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id EQpPSZMg42bP
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 22:51:07 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f65.google.com (mail-pj1-f65.google.com
 [209.85.216.65])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 0E8D88602E
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 22:51:07 +0000 (UTC)
Received: by mail-pj1-f65.google.com with SMTP id b17so516252pji.1
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 15:51:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=vGTBAGvWDFjbodpOJVDhuski4CeBWH0Uvr/+Kwfo5Oo=;
 b=QUzlApk96W2T2IaCs5WGQXm3ZTGAUMjBN/NJE6GKiP7ihH3Ebqvf1sHDE9qe4eUNlB
 tcBhVT3a9ZWJQvvKj20pUNmbF66KiPV+zPIn9Dd4lQLRM2xnQDH+SAkD5dugk079Dxdd
 DAsPEvRmAKxUcH/DWv5tqex3OSuRmnqd8/JaS18pmiTNeigKozmXI8D0cTk144lI/9QZ
 WCQCyMawJHanLv7XM+51axli469ZW0hFiWgZHdyfJGksgGrmtJ5rAUkCNGnWCbBzxxQN
 yH4Dm7doaWUhWhrbFqrbPgSS4pe2eiq/nbqCWensqlbCjVNAuzGC3mD6iot+s4WjMKVT
 sY4A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=vGTBAGvWDFjbodpOJVDhuski4CeBWH0Uvr/+Kwfo5Oo=;
 b=NBMLwMl2z8cOZbYSJ9NS9rHtdG5xztiQpDB1aOKCmdR3tfUhAibP7Hda/dEEul7hxI
 Dtp3f+xdhzyKXoPWzCPNmy0Yflb5LRNz8p+VNuj1iZtYecFkpTugLWHbl77ZFOsDTgOY
 yK/JnXWloiZchZz2+nJdKTyto4NXBNxKX6yCYiKPKNrwgS3PbRG/NKNgmwR6CdnuU0JZ
 3SgmKMmWEslsYhM1uC+xWq6l/w9X/g3dOFPc4TICR2O8jZa7Q8FX913/47oc5zoCmGGa
 Chwx3lFVdVod6gRd1J04T1w7FLJwjCcg9JMCIC7NnZeFakFstU7tVxYr66rukBMw8PuT
 2cWw==
X-Gm-Message-State: AOAM5308Q8jK03TB+A28bh35LSP0sddlhyrOMJ6RkBVOFfh2ICi8J1Zp
 rn+Dkhbe+oe+NZNmUd6sNJSyr3rKrwODky/gWeU=
X-Google-Smtp-Source: ABdhPJwIh4TG2lZRhS3+puFxuT098Mmba2FlJSMwTw8F7EzbCgRWoakQWoggppEyR++U27sLmfWb4dSxPkRHVJRWJEg=
X-Received: by 2002:a17:90b:4b82:: with SMTP id
 lr2mr1303431pjb.184.1600728666628; 
 Mon, 21 Sep 2020 15:51:06 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <b792335294ee5598d0fb42702a49becbce2f925f.1600661419.git.yifeifz2@illinois.edu>
 <CAG48ez3k0_7Vev_O=uV_WVuUGK6BPA0RyrYXMYSDV4DTMMe26g@mail.gmail.com>
In-Reply-To: <CAG48ez3k0_7Vev_O=uV_WVuUGK6BPA0RyrYXMYSDV4DTMMe26g@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Mon, 21 Sep 2020 17:50:55 -0500
Message-ID: <CABqSeAROcwq0ZGzWaxyPm+LDHu6T_8CD7_1c-hdhaMikr_ECCA@mail.gmail.com>
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

On Mon, Sep 21, 2020 at 1:09 PM Jann Horn <jannh@google.com> wrote:
>
> On Mon, Sep 21, 2020 at 7:35 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> [...]
> > We do this by creating a per-task bitmap of permitted syscalls.
> > If seccomp filter is invoked we check if it is cached and if so
> > directly return allow. Else we call into the cBPF filter, and if
> > the result is an allow then we cache the results.
>
> What? Why? We already have code to statically evaluate the filter for
> all syscall numbers. We should be using the results of that instead of
> re-running the filter and separately caching the results.
>
> > The cache is per-task
>
> Please don't. The static results are per-filter, so the bitmask(s)
> should also be per-filter and immutable.

I do agree that an immutable bitmask is faster and easier to reason
about its correctness. However, I did not find the "code to statically
evaluate the filter for all syscall numbers" while reading seccomp.c.
Would you give me a pointer to that and I will see how to best make
use of it?

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
