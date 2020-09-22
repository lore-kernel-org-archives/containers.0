Return-Path: <SRS0=1mNv=C7=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 342CCC4727E
	for <containers@archiver.kernel.org>; Tue, 22 Sep 2020 00:47:56 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C7B1F23A61
	for <containers@archiver.kernel.org>; Tue, 22 Sep 2020 00:47:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QoYPjLe/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7B1F23A61
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 593F885DA0;
	Tue, 22 Sep 2020 00:47:55 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id vPDpbHMjbNjY; Tue, 22 Sep 2020 00:47:54 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id B71A085C92;
	Tue, 22 Sep 2020 00:47:54 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8F767C0859;
	Tue, 22 Sep 2020 00:47:54 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 20B1BC0051
 for <containers@lists.linux-foundation.org>;
 Tue, 22 Sep 2020 00:47:53 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 0136B20009
 for <containers@lists.linux-foundation.org>;
 Tue, 22 Sep 2020 00:47:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id lWbmqcjUTSxW
 for <containers@lists.linux-foundation.org>;
 Tue, 22 Sep 2020 00:47:52 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f67.google.com (mail-pj1-f67.google.com
 [209.85.216.67])
 by silver.osuosl.org (Postfix) with ESMTPS id 74A1720000
 for <containers@lists.linux-foundation.org>;
 Tue, 22 Sep 2020 00:47:52 +0000 (UTC)
Received: by mail-pj1-f67.google.com with SMTP id jw11so636031pjb.0
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 17:47:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=Dk2JCJ2SZ6GpJYMoGzni/oIIYiDZY1ODRMoXVmzNZcQ=;
 b=QoYPjLe/QzifVjP9iVSdsQqMOwCPQDJnLzm84s1PK7djJkuJAlInR+whcSRHmf8dtl
 9u3rTD9YqtwOjBYxtogsR84NYmTolHxp6V0DXGlbx4YVs6YeAxLgL8pYjJXjgJT6WbYP
 wi7jruk4eCPvjBvyClbVUiA/k14PGgvpgzqzlfmEiGLKukwWeIWs6f+tDOYGD95ep2bn
 gK6I/+JnpJ17J+YNgIEcUvg97LbTqa1ab0d2l7WXSM4IGbtbchGeVg6l/RaO2HBD7NCn
 vbZ8CUXi81QTMQ190hHaShg3CCkcpRFaUoVlKxbDK9n4FL9pKT4fwqLJTtOeE8l9cfRP
 uvWw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=Dk2JCJ2SZ6GpJYMoGzni/oIIYiDZY1ODRMoXVmzNZcQ=;
 b=rkPkw9JqX/el2o7GNt+Pm33e4w+xf8VdPu650345EMmQbVlcD34M7ArdTEVd177LJG
 42ENNbvQNyCHKd3I/TomKiSlu3MDkUBGw4F4x5+rz/UbXvDkeUvfjTfudpHpK5boNKCC
 E4q+7Q5CAE5rZMfZ7QrYk3kBnKR2oYg8myTxsrNX7NnKCvblbkoEnJ6rx0lzdRgwr9MB
 /OGFZPCLwfrqCxNHrsQVbbkztf9V9RPJJO0Gi3jmnvZbEFaOnKKuuXKOOSBlHsPMEASn
 mn8BmEwAsqxIrrsXIH9wPeURJ1+kQLkCSivSD3NL8xyvY57AeKPpyQeSx5dP3E1MH6jc
 Q6zg==
X-Gm-Message-State: AOAM533BbVIDRWX9jgN+itGMOwm/azD4SZRqdfbgbwXgOJDxdYlJeLVq
 /QNUBy7FHf+vH87z5scTmF+dGsVzy+j1de+WCQA=
X-Google-Smtp-Source: ABdhPJzLzwKoj33tYKE3Itz57p2WN73YOZdlgQ5pGlnh8VT2soITudx2eqBBtaTpt0lLo1CaOlFiuWyfu2copHBeHcQ=
X-Received: by 2002:a17:90b:3252:: with SMTP id
 jy18mr1563061pjb.1.1600735671956; 
 Mon, 21 Sep 2020 17:47:51 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <6af89348c08a4820039e614a090d35aa1583acff.1600661419.git.yifeifz2@illinois.edu>
 <CAG48ez0OqZavgm0BkGjCAJUr5UfRgbeCbmLOZFJ=Rj46COcN3Q@mail.gmail.com>
 <CABqSeAQhVFeG1Frvu60XfUnRQ78YRS2Uaw1EsBobKVku-vVoDQ@mail.gmail.com>
 <CAG48ez1YWz9cnp08UZgeieYRhHdqh-ch7aNwc4JRBnGyrmgfMg@mail.gmail.com>
In-Reply-To: <CAG48ez1YWz9cnp08UZgeieYRhHdqh-ch7aNwc4JRBnGyrmgfMg@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Mon, 21 Sep 2020 19:47:40 -0500
Message-ID: <CABqSeARpj-wRzS_bbfeD8=6LOQ64mdQR6DS5O2fSmCDTduFLGg@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 1/2] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
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

On Mon, Sep 21, 2020 at 7:26 PM Jann Horn <jannh@google.com> wrote:
> > In the initial RFC patch I only added to x86. I could add it to any
> > arch that has seccomp filters. Though, I'm wondering, why is SECCOMP
> > in the arch-specific Kconfigs?
>
> Ugh, yeah, the existing code is already bad... as far as I can tell,
> SECCOMP shouldn't be there, and instead the arch-specific Kconfig
> should define something like HAVE_ARCH_SECCOMP and then arch/Kconfig
> would define SECCOMP and let it depend on HAVE_ARCH_SECCOMP. It's
> really gross how the SECCOMP config description has been copypasted
> into a dozen different Kconfig files; and looking around a bit, you
> can actually see that e.g. s390 has an utterly outdated help text
> which still claims that seccomp is controlled via the ancient
> "/proc/<pid>/seccomp". I guess this very nicely illustrates why
> putting such options into arch-specific Kconfig is a bad idea. :P

Ah, time to fix this then.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
