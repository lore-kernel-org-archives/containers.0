Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB80BC4727E
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 21:08:42 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4958E206FA
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 21:08:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="phZLfcc1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4958E206FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id EDCB58731B;
	Thu,  1 Oct 2020 21:08:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Ef4wfDb4l3NH; Thu,  1 Oct 2020 21:08:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 5EAD087247;
	Thu,  1 Oct 2020 21:08:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 45598C0889;
	Thu,  1 Oct 2020 21:08:37 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B68A6C0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 21:08:36 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 20FF620366
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 21:08:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 7EPq2CDMcyy4
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 21:08:34 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f66.google.com (mail-ej1-f66.google.com
 [209.85.218.66])
 by silver.osuosl.org (Postfix) with ESMTPS id 673CE20341
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 21:08:34 +0000 (UTC)
Received: by mail-ej1-f66.google.com with SMTP id i26so10107575ejb.12
 for <containers@lists.linux-foundation.org>;
 Thu, 01 Oct 2020 14:08:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=9xdqL6cUOxwNImAGbPqaJhmve2+c4zuAd6VkudhDv6E=;
 b=phZLfcc15Ka79PK3Ed6XBrK4N+ZNchA2bFO86TvVtOc950Psuk0y9/kQKkWgIvDSeN
 YjyuXO1K1p828Tf5OE/n0pHfpEA5q7Ti5DgUsCXz/b+lrDR3AIwZAZ5aFFmCwZxDQexR
 yiLOLcKi2SsRwqqdkcZX/NSe/StY1Vj+XY8mTic9gwB2uPErgZO4Or8u5UDVhhrxIPgl
 kUME/C0aR0S9tpgl96xnwhvLswQrUQ7hxN3ARq1prxVE/GoF1dmHi+a8V7BzMCHVB6Gt
 1c4gbLgTOkQ/FDI7bEwUfnqk/2GMkmm+DoOLn4VtQnptPaX5XUxk2PTcyV1juD/vL0VF
 uCIg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=9xdqL6cUOxwNImAGbPqaJhmve2+c4zuAd6VkudhDv6E=;
 b=aqHCNhIKMZ6ExM/FkdtXUagUmygbbLZnAROFGohhwxYniOiD6f6ldNSOmPNWidQXc1
 Mo7LeQIrxOK01ECLxZWSha1QcrUNkOY803qYlR29KvFp/+jJVM33xQrPzPBkom8p3WHj
 gyK9YgiORyZPF0WzcjGwelWlXkY5GyR9h6lIPQ7FphBNuoWwuAD9AQE7lrQtGKAMjwuN
 T8b5c9FP0SdPqT7tgEU2S7F3Jf6AgunM6ARe98mJx/sn+9hYaYqRD0tjmSbB0kiCT4L4
 AB2CE2l1TQme4KKQpiGOF1yfVgwtUxgJZYbjxfR7bUT/YOivazH/fCFA5zN+2r3c2SFV
 xlXA==
X-Gm-Message-State: AOAM532v14JRhnItHDjU4tubtFLljnR769GrgemS4P9aRjIy9MCIpCHx
 UFEdmFphGRPhPjhv2VMKpTW7gmpZHi9DWMTKyoqb/g==
X-Google-Smtp-Source: ABdhPJzGyqh4BsNemw68IZ7SVTAL/f1eGkoGoEq0lnwW+GNAxVmMi5sF8Ujp23KKrSIiuA0CtJc5Iz8q63h4ADYqoDo=
X-Received: by 2002:a17:906:980f:: with SMTP id
 lm15mr10444403ejb.184.1601586512571; 
 Thu, 01 Oct 2020 14:08:32 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <b16456e8dbc378c41b73c00c56854a3c30580833.1601478774.git.yifeifz2@illinois.edu>
 <CAG48ez0Njm0oS+9k-cgUqzyUWXV=cHPope2Xe9vVNPUVZ1PB4w@mail.gmail.com>
 <CABqSeASwCXaP_vNe1=E3EeWAApFYiB1S5xEb9BdH10b0rn0Q6A@mail.gmail.com>
In-Reply-To: <CABqSeASwCXaP_vNe1=E3EeWAApFYiB1S5xEb9BdH10b0rn0Q6A@mail.gmail.com>
Date: Thu, 1 Oct 2020 23:08:06 +0200
Message-ID: <CAG48ez2HSYocuJhR1uo4Ei8x8jPtUkYRYVWPuiJscEJdbckONw@mail.gmail.com>
Subject: Re: [PATCH v3 seccomp 2/5] seccomp/cache: Add "emulator" to check if
 filter is constant allow
To: YiFei Zhu <zhuyifei1999@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
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

On Thu, Oct 1, 2020 at 1:28 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> On Wed, Sep 30, 2020 at 5:24 PM Jann Horn <jannh@google.com> wrote:
> > If you did the architecture enablement for X86 later in the series,
> > you could move this part over into that patch, that'd be cleaner.
>
> As in, patch 1: bitmap check logic. patch 2: emulator. patch 3: enable for x86?

Yeah.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
