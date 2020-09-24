Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ED6EC4363D
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 00:46:18 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DF1B6221EB
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 00:46:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="Jm4qQfsF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF1B6221EB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 7A9B386A3F;
	Thu, 24 Sep 2020 00:46:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 3-o3NtZn0GlE; Thu, 24 Sep 2020 00:46:14 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id D461886A25;
	Thu, 24 Sep 2020 00:46:14 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id BDFD7C0859;
	Thu, 24 Sep 2020 00:46:14 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E4CECC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 00:46:13 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id D03E486A27
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 00:46:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id TW-PjEmPNmHW
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 00:46:13 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f65.google.com (mail-ej1-f65.google.com
 [209.85.218.65])
 by whitealder.osuosl.org (Postfix) with ESMTPS id DF83E86A25
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 00:46:12 +0000 (UTC)
Received: by mail-ej1-f65.google.com with SMTP id p9so2094958ejf.6
 for <containers@lists.linux-foundation.org>;
 Wed, 23 Sep 2020 17:46:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=IRg8bdIf5EpG+3h++Ew0iu9r6E0witVaxm9lrud8jnM=;
 b=Jm4qQfsFbsCSvqsbWq7VzfNoNGVob5/4BshRZEiIMaLEiUAXQkk+Y3gcARpDMXU77J
 RNaw2tpVInTue7BsyBCtZUkwt1eYCijqBRs3vrwEJYWjEAwHJ8jLeLp72F/ENGNnzE/G
 EKLslOPjHX6mp2Z2Qnz3aMgbngWhizN8kdzLcINc5IUUtx9RxOv0ebO8UbHBC6gSmDIu
 FMCxqDS4rALBmlhRBAReUsXiYxckjsgN9L9hJAj6XCsRyzlTxLl/Flt+z8WTU64FZVbm
 sP3KAo4BFVXnMvrmr7UNX6TFr6Ec+XsfqaoZ3kZpDC57gQ1BxVuKxSN63q3jyaZxfJpd
 B6Hw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=IRg8bdIf5EpG+3h++Ew0iu9r6E0witVaxm9lrud8jnM=;
 b=r+QBA72GZFMcKZbpxMPuiJRpZ6ZKO2YubEcbzFIp7Oq54xH7Oiz1LAAU5liem6Aj+0
 a2TShE7+PwK6SHc99SleaXm/dRlG021G+6CLVsD7xg8SNIm2ST9GPA8pfS9Qd65pB1g6
 Wxj1O/qFI9ynRhn98DzXkQ6mW610K5Lg2x6mbklATIRfKy0wMLbRKzIbSU+WNu55eKAd
 eFkdiJts+zXgxwsMOB0vJawVz9A95vnOD3YAxADRCL9xS9e2G4Rf6T8Wgrv281+AmLEY
 A5OdkVA6pWDsJY26ROw20I3xPYuCvGVNde9Ov9PvmXJlSw+2MGGh2SxwiMfcMqBaUba3
 02nw==
X-Gm-Message-State: AOAM532x53SatpqCoR5IgnIpZjJyYe9lKMPmeMnt53D3t5dvlY5PAWsG
 hdWOJrOWmSnddS+Cjvcd94AkXz4TZpMxpNIgBB6ddA==
X-Google-Smtp-Source: ABdhPJzzIXGNXnvZht8wsxEFTZoPCFI82VwWeUCzB6ZEDBf5qTi4KSqQ4F0OnePwzJ5/m1L4tVXPR+clKCQEE2r6v2g=
X-Received: by 2002:a17:906:f6c9:: with SMTP id
 jo9mr2116692ejb.233.1600908371207; 
 Wed, 23 Sep 2020 17:46:11 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-3-keescook@chromium.org>
In-Reply-To: <20200923232923.3142503-3-keescook@chromium.org>
Date: Thu, 24 Sep 2020 02:45:45 +0200
Message-ID: <CAG48ez1BXWdWA5zPzOD21bQ4RsHQ6bSDWR8soTkkNphJ=zdHWw@mail.gmail.com>
Subject: Re: [PATCH 2/6] x86: Enable seccomp architecture tracking
To: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, Tianyin Xu <tyxu@illinois.edu>,
 kernel list <linux-kernel@vger.kernel.org>
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

On Thu, Sep 24, 2020 at 1:29 AM Kees Cook <keescook@chromium.org> wrote:
> Provide seccomp internals with the details to calculate which syscall
> table the running kernel is expecting to deal with. This allows for
> efficient architecture pinning and paves the way for constant-action
> bitmaps.
[...]
> diff --git a/arch/x86/include/asm/seccomp.h b/arch/x86/include/asm/seccomp.h
[...]
> +#ifdef CONFIG_X86_64
[...]
> +#else /* !CONFIG_X86_64 */
> +# define SECCOMP_ARCH                                  AUDIT_ARCH_I386
> +#endif

If we are on a 32-bit kernel, performing architecture number checks in
the kernel is completely pointless, because we know that there is only
a single architecture identifier under which syscalls can happen.

While this patch is useful for enabling the bitmap logic in the
following patches, I think it adds unnecessary overhead in the context
of the previous patch.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
