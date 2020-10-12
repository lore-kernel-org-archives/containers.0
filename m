Return-Path: <SRS0=82Ss=DT=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A6D4C433DF
	for <containers@archiver.kernel.org>; Mon, 12 Oct 2020 22:57:43 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D805320725
	for <containers@archiver.kernel.org>; Mon, 12 Oct 2020 22:57:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="JJQ4S6hW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D805320725
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 346498798C;
	Mon, 12 Oct 2020 22:57:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xNK1KmfrxvcP; Mon, 12 Oct 2020 22:57:41 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 084948738A;
	Mon, 12 Oct 2020 22:57:41 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id DFC3BC0052;
	Mon, 12 Oct 2020 22:57:40 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 28E25C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 22:57:40 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 0E6AE274ED
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 22:57:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id IZYUAw--PC-v
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 22:57:39 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com
 [209.85.210.195])
 by silver.osuosl.org (Postfix) with ESMTPS id F16D423504
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 22:57:38 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id k8so15139745pfk.2
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 15:57:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=ho1l607OAVVmLnoWlMqhfwRhJkqSim+LddBz61r0Qos=;
 b=JJQ4S6hWNOQEK+Sy3Y+6MHvE6gOOcxmTo+VnXkRAr4YZg1jAzA2NjbHn3GiUPeK8gf
 0ipw1LXDfr3tEdWE6dRrL6M12460zyb+sjoMJRNxEoEbW1Tj6e5VYs12zu49n5jFE+ag
 LA//Dq0oC90jGuPSuhQwam8VrIDDiTx3NpK3M=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=ho1l607OAVVmLnoWlMqhfwRhJkqSim+LddBz61r0Qos=;
 b=pAwL0x43TJOIvAS4FxYImf7kZko56Z+MFgpj73Pmu6clBOB2JvP+l5DxLuufP+pEyB
 jiwAgSNkB2eLclOmy/sIMETkV3mtD1tUAoPiL9f3jDisdtyDGngL8Kad+M4CBMk3L1y1
 iya4pBl45AAlDJvj1OC4OoO7KcpCWmhgMDAxvTynTCQWpHJMHeg/s95MFISHSE5PSCSu
 j1HS2MGjQZ7IyMlWUWVRSB49xm/uRREJpD4/7K8nDuz+oK5qBN64aBmViZ2rMWqUdESO
 RciIdnw8CsHrRbLNJmecRKPBtBboYd1Vb1OFw2K9mAzFel/0ZGlS25akVd/dQAO3HqxC
 g9OA==
X-Gm-Message-State: AOAM533ELXM7/UFcDyyK5Ej1qABJ+LWtGelAq7+3Ce4U9s1CWbTN8sq+
 Hb2h+sUYk0uwqxRU8syjApRamQ==
X-Google-Smtp-Source: ABdhPJxRLYOMHo59Ns0oO1+b1TTIgg1tJPZTI/F+6kwXefZKFzuOW2ptOTYCFNOKi97y0iBzVBYADg==
X-Received: by 2002:a17:90a:a782:: with SMTP id
 f2mr2869911pjq.50.1602543458516; 
 Mon, 12 Oct 2020 15:57:38 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id j6sm20479216pfi.129.2020.10.12.15.57.36
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Mon, 12 Oct 2020 15:57:37 -0700 (PDT)
Date: Mon, 12 Oct 2020 15:57:36 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v4 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Message-ID: <202010121556.1110776B83@keescook>
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <c2077b8a86c6d82d611007d81ce81d32f718ec59.1602263422.git.yifeifz2@illinois.edu>
 <202010091613.B671C86@keescook>
 <CABqSeARZWBQrLkzd3ozF16ghkADQqcN4rUoJS2MKkd=73g4nVA@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeARZWBQrLkzd3ozF16ghkADQqcN4rUoJS2MKkd=73g4nVA@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Sat, Oct 10, 2020 at 08:26:16AM -0500, YiFei Zhu wrote:
> On Fri, Oct 9, 2020 at 6:14 PM Kees Cook <keescook@chromium.org> wrote:
> > HAVE_ARCH_SECCOMP_CACHE isn't used any more. I think this was left over
> > from before.
> 
> Oh, I was meant to add this to the dependencies of
> SECCOMP_CACHE_DEBUG. Is this something that would make sense?

I think it's fine to just have this "dangle" with a help text update of
"if seccomp action caching is supported by the architecture, provide the
/proc/$pid ..."

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
