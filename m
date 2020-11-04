Return-Path: <SRS0=KLId=EK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AFA6C2D0A3
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 00:29:45 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 130A6223EA
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 00:29:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="H5API/cU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 130A6223EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id ACC3C8722B;
	Wed,  4 Nov 2020 00:29:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id b81uNkya4rnO; Wed,  4 Nov 2020 00:29:43 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 11AFA871C3;
	Wed,  4 Nov 2020 00:29:43 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id F145AC0889;
	Wed,  4 Nov 2020 00:29:42 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 733F5C0051
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 00:29:41 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 651DE8726F
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 00:29:41 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id H0vSyBDcC+j2
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 00:29:40 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com
 [209.85.214.195])
 by hemlock.osuosl.org (Postfix) with ESMTPS id BC5B28725D
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 00:29:40 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id t6so9401213plq.11
 for <containers@lists.linux-foundation.org>;
 Tue, 03 Nov 2020 16:29:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=F06dNnLo5pVFz2CmGuB3AtlTt9h+PO3FFpFt/YqI8Cg=;
 b=H5API/cU2kCLm/rlmuWDHVdK/0fMqgPkW2hN+G7SbD2sk7CpKG1mpmYyfaYlF/fKt7
 wFOtq7PtHhIJM/OthEAdxoACuFnD193rR3n0aUSNCkpr6WyyGgMbqvIVCI2RbqO/ZU+S
 u/ysWEXSnty3nhLrLjTspLlf7adjMgKSny6Lc=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=F06dNnLo5pVFz2CmGuB3AtlTt9h+PO3FFpFt/YqI8Cg=;
 b=ZH65RRfYS0uN5lkZ9sZTkTL5Mjzs3t/TOKsS84QzRnXhj++ZcyF+WwuWa4CH+5xltt
 B1WJf3Gm7LUh6+1BvrGHEsj/unLDHZe8qhjBz76SxvveITKXtyGlqqpYU9DAQLtL2g+q
 alvswR6pOgxBYD+KZYCyI209KKhHXJMnfVeRtZgzu+/rh54fu0MRxAoHBOKWyjmAUV2K
 RaEX0M78C9wz7hC3YFYWLdr3g3pR5kSJ7AZZ5fNr2s1aV8EZKmqno1PsH0uiBSHw8xmw
 pcD5Y5pQ2+Yx1FK7if0iuQ7p6P3OC0PLv2ZHy6GdqVQU227w0OGSzuuBOY9oJYfU42Xu
 EQuQ==
X-Gm-Message-State: AOAM5311lx4qTkONBLiAYjB5D6p+7+zoPHfweUbCceLHSE+DUZvmWGeQ
 YYqp5391CdDelBpTuQq2HEie3A==
X-Google-Smtp-Source: ABdhPJx8PYXz0HMlsmRPwbUvWUVC3l2Awz7GVLjlBRUJvcJR3PRRG641cCj38glJarsx77xPHhgOPg==
X-Received: by 2002:a17:902:bd83:b029:d6:c53f:a771 with SMTP id
 q3-20020a170902bd83b02900d6c53fa771mr13437431pls.23.1604449780276; 
 Tue, 03 Nov 2020 16:29:40 -0800 (PST)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id w63sm271309pfc.120.2020.11.03.16.29.38
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Tue, 03 Nov 2020 16:29:39 -0800 (PST)
Date: Tue, 3 Nov 2020 16:29:38 -0800
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v4 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Message-ID: <202011031612.6AA505157@keescook>
References: <202010091613.B671C86@keescook>
 <CABqSeARZWBQrLkzd3ozF16ghkADQqcN4rUoJS2MKkd=73g4nVA@mail.gmail.com>
 <202010121556.1110776B83@keescook>
 <CABqSeAT2-vNVUrXSWiGp=cXCvz8LbOrTBo1GbSZP2Z+CKdegJA@mail.gmail.com>
 <CABqSeASc-3n_LXpYhb+PYkeAOsfSjih4qLMZ5t=q5yckv3w0nQ@mail.gmail.com>
 <202010221520.44C5A7833E@keescook>
 <CABqSeAT4L65_uS=45uxPZALKaDSDocMviMginLOV2N0h-e1AzA@mail.gmail.com>
 <202010231945.90FA4A4AA@keescook>
 <CABqSeAQ4cCwiPuXEeaGdErMmLDCGxJ-RgweAbUqdrdm+XJXxeg@mail.gmail.com>
 <CABqSeATiV0sQvqpvCuqkOXNbjetY=1=6ry_SciMVmo63W9A88A@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeATiV0sQvqpvCuqkOXNbjetY=1=6ry_SciMVmo63W9A88A@mail.gmail.com>
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

On Tue, Nov 03, 2020 at 07:00:22AM -0600, YiFei Zhu wrote:
> My peers pointed out that in my previous benchmark there are still a
> few mitigations left on, and suggested to use "noibrs noibpb nopti
> nospectre_v2 nospectre_v1 l1tf=off nospec_store_bypass_disable
> no_stf_barrier mds=off tsx=on tsx_async_abort=off mitigations=off".
> Results with "Mitigations Off" updated:
> 
>                         Mitigations On            Mitigations Off
>                 With Cache      Without Cache   With Cache      Without Cache
> Native          18:17.38        18:13.78        17:43.42        17:47.68
> D. no seccomp   18:15.54        18:17.71        17:34.59        17:37.54
> D. + seccomp    20:42.47        20:45.04        17:35.70        17:37.16
> 
> Whether seccomp is on or off seems not to make much of a difference
> for this benchmark. Bitmap being enabled does seem to decrease the
> overall compilation time but it also affects where seccomp is off, so
> the speedup is probably from other factors. We are thinking about
> using more syscall-intensive workloads, such as httpd.

Yeah, this is very interesting. That there is anything measurably _slower_
with the cache is surprising. Though with only 4 runs, I wonder if it's
still noisy? What happens at 10 runs -- more importantly what is the
standard deviation?

> Thugh, this does make me wonder, where does the 3-minute overhead with
> seccomp with mitigations come from? Is it data cache misses? If that
> is the case, can we somehow preload the seccomp bitmap cache maybe? I
> mean, mitigations only cause around half a minute slowdown without
> seccomp but seccomp somehow amplify the slowdown with an additional
> 2.5 minutes, so something must be off here.

I assume this is from Indirect Branch Prediction Barrier (IBPB) and
Single Threaded Indirect Branch Prediction (STIBP) (which get enabled
for threads under seccomp by default).

Try booting with "spectre_v2_user=prctl"

https://www.kernel.org/doc/html/latest/admin-guide/hw-vuln/spectre.html#spectre-mitigation-control-command-line

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
