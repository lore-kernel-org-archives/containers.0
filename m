Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE408C433E7
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 18:32:41 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 543C722284
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 18:32:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sNrNF6ck"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 543C722284
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id F0A4087722;
	Fri,  9 Oct 2020 18:32:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id RAv3xnBsOx6g; Fri,  9 Oct 2020 18:32:40 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 6DD01876E3;
	Fri,  9 Oct 2020 18:32:40 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 58C4CC016F;
	Fri,  9 Oct 2020 18:32:40 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 50BD2C0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 18:32:39 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 29CC12044D
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 18:32:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id JlVmgr2uFhLX
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 18:32:38 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com
 [209.85.215.194])
 by silver.osuosl.org (Postfix) with ESMTPS id 1ACC3203E9
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 18:32:38 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id g29so7897937pgl.2
 for <containers@lists.linux-foundation.org>;
 Fri, 09 Oct 2020 11:32:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=yXMI+PJKiZyAcZLy7HAh04DXC9PBpofk3SlWAnaKUzo=;
 b=sNrNF6ck7NJ2QfAd6RQi7Knon7r6ENYFOWVpv5tnOeOKqRvn+KzubtO6ebUIwOxTSL
 6LTsxmt+BXSNfjUdNzXi6nRS4tbViLgm9hgfrV5A9UTQKwpZ8HXPYF2ACfo8LlS77JmR
 yxQtnaW69CrshyvExgocB1z248AiO6z4ZwAvJaIhMpjmcoyeSBfso7HVf8hqHpCSMFda
 6o325i7ZzqR7iJ3Txs8/IBVF/pmXdK89XXURcwAQb2bj6sI/hdLn+E3p7fKMELUR1Lcj
 nOAll45kTvT8d0EdT3JuFtc8ICxZEY8yBMtiHqY1wNEX/2hHp/P615vKRkGhxZ0A4NQp
 Rlpw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=yXMI+PJKiZyAcZLy7HAh04DXC9PBpofk3SlWAnaKUzo=;
 b=LNRxiFmMGKPjkLYgCIuZKjI8Mn+Ss0u2pOb/6Eqh4YIhvdKb9NfQAwbdehH1bIQDCF
 ima/JcGSQRr2ZUJvgAJf0mB5k+RB2nwvOfIZv6+cyYbNA/kNt0euWYDlqa21h8Msvf0R
 T4DnybzPlmjtU0XEpL+NDfs4zusayVm8NeQc5Q7ettWHvmVv7yyS0Xw+DVYGwjpbUGoC
 GNkOJg6X1lPSn5SCQNA5ps9QHhbc9xEo31BoTMUBf06c9mRkWEqTdcBRGLBx/Q/BT2sR
 s1IS7pbtL9Xt7Y2F0raSP7WDu8Jgxwmv7rcVo3wQfwTwuwnUzK9D0K+Yqi6VpSs/mCm1
 04jA==
X-Gm-Message-State: AOAM532kLb+YMjsWDMsT6fPahnC7kXjMLmjyUvdmhLseKXclPpOms9B+
 TsDv7QGdECt1/Y/bsqdBa7ZRU3duKCEPeq5Z1JE=
X-Google-Smtp-Source: ABdhPJxciReanT1Tdqe2uibnZF7nLBpm1gqiuEy9LFZcUHLNw4KhnEvEKGdB/rXbOZcI4Bv2/uX73t0hHNm3BA+VqX8=
X-Received: by 2002:a63:1c19:: with SMTP id c25mr4487332pgc.66.1602268357586; 
 Fri, 09 Oct 2020 11:32:37 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <122e3e70cf775e461ebdfadb5fbb4b6813cca3dd.1602263422.git.yifeifz2@illinois.edu>
 <CALCETrUD7z3-zL_rATzTyDUzgerOzXJHdn-hntNMG=vnX8ZF2w@mail.gmail.com>
In-Reply-To: <CALCETrUD7z3-zL_rATzTyDUzgerOzXJHdn-hntNMG=vnX8ZF2w@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Fri, 9 Oct 2020 13:32:26 -0500
Message-ID: <CABqSeAS0WdkLHGMg3TRKkzsUE=JJYwY4iuBgYpdp-kLd9ASOfg@mail.gmail.com>
Subject: Re: [PATCH v4 seccomp 3/5] x86: Enable seccomp architecture tracking
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, LKML <linux-kernel@vger.kernel.org>,
 Hubertus Franke <frankeh@us.ibm.com>, David Laight <David.Laight@aculab.com>,
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Fri, Oct 9, 2020 at 12:25 PM Andy Lutomirski <luto@amacapital.net> wrote:
> Is the idea that any syscall that's out of range for this (e.g. all of
> the x32 syscalls) is unoptimized?  I'm okay with this, but I think it
> could use a comment.

Yes, any syscall number that is out of range is unoptimized. Where do
you think I should put a comment? seccomp_cache_check_allow_bitmap
above `if (unlikely(syscall_nr < 0 || syscall_nr >= bitmap_size))`,
with something like "any syscall number out of range is unoptimized"?

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
