Return-Path: <SRS0=zK8s=D5=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AED4C388F9
	for <containers@archiver.kernel.org>; Thu, 22 Oct 2020 22:32:39 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D264F24655
	for <containers@archiver.kernel.org>; Thu, 22 Oct 2020 22:32:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="bIdceANe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D264F24655
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 690918355C;
	Thu, 22 Oct 2020 22:32:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VhqUn_c48ZpK; Thu, 22 Oct 2020 22:32:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B21F5872D0;
	Thu, 22 Oct 2020 22:32:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 95EE8C08A1;
	Thu, 22 Oct 2020 22:32:37 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D7D4AC0052
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 22:32:35 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id A125620361
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 22:32:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Os0dHHZrJVRa
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 22:32:34 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com
 [209.85.214.193])
 by silver.osuosl.org (Postfix) with ESMTPS id 1DFA21FC94
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 22:32:34 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id t4so1715955plq.13
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 15:32:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=WP7MQH1ssAvDqFVXPY7V60qwcY9Im9dBsz5m4rL+ry8=;
 b=bIdceANej9lvuMPIaaLVFAdg2WqmqLlyNevfjw/ZimJhZx7nxKRHwJNp8tRnvP/ZX5
 C7E2p+hF/bFjvlQn97TfVSBWGRz53q2S8l2zRujVs8nBmbydDrs0P99KtLU2wmGowHSg
 8zkarDzOOeyc/ekBsYRaTSB22cjwUsXuLoCWo=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=WP7MQH1ssAvDqFVXPY7V60qwcY9Im9dBsz5m4rL+ry8=;
 b=qXX0cvl495E9E0C0UZ637motPz9iiXR05r3mdHu9b35iWd9BkUzhgyw/HDxwknaKh1
 OyD6KMRhJPur7FMh6rDwsgAdzVNL9tM4ri/I2bilb3uhW5A0FoITjnvhajPnf1WtbpeO
 lRTEo2P9+6R2cPy9n2r7FDZPl0sj0aKpmyNjyYRWpQaa9Zdf9ZojpoxVTiva+IVK8QEF
 BzEfSbDsZ5Z8IM2pOnQXW70OIL4mVXOt4fLAzso0EcpLn2eExwL7vL3YCWGUTwgx3u/w
 xya0QjdcIjZrX/HkBH3Jb+v83MdpQtmLtPUAcaaOY2pewMzwEDZnEt1uwN2Pe2p4jyN9
 ae7g==
X-Gm-Message-State: AOAM530ESYNLDSW5UYt0Ryk8LVs8s6p2uLPizuIi6X7pFIjo5sqTSdGa
 6YIAkqF+7sEqze06kYKUUfK5Fw==
X-Google-Smtp-Source: ABdhPJx9pRKL66H6CiwdaLL0xcN1gIQVhntB/+tpFfDzpc1b3GAd8xuM23vsryV1EPMtKne4pmJn8A==
X-Received: by 2002:a17:902:ee52:b029:d5:dd2d:df92 with SMTP id
 18-20020a170902ee52b02900d5dd2ddf92mr4667294plo.37.1603405953445; 
 Thu, 22 Oct 2020 15:32:33 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id u65sm3394821pfc.11.2020.10.22.15.32.32
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 22 Oct 2020 15:32:32 -0700 (PDT)
Date: Thu, 22 Oct 2020 15:32:31 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v4 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Message-ID: <202010221520.44C5A7833E@keescook>
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <c2077b8a86c6d82d611007d81ce81d32f718ec59.1602263422.git.yifeifz2@illinois.edu>
 <202010091613.B671C86@keescook>
 <CABqSeARZWBQrLkzd3ozF16ghkADQqcN4rUoJS2MKkd=73g4nVA@mail.gmail.com>
 <202010121556.1110776B83@keescook>
 <CABqSeAT2-vNVUrXSWiGp=cXCvz8LbOrTBo1GbSZP2Z+CKdegJA@mail.gmail.com>
 <CABqSeASc-3n_LXpYhb+PYkeAOsfSjih4qLMZ5t=q5yckv3w0nQ@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeASc-3n_LXpYhb+PYkeAOsfSjih4qLMZ5t=q5yckv3w0nQ@mail.gmail.com>
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

On Thu, Oct 22, 2020 at 03:52:20PM -0500, YiFei Zhu wrote:
> On Mon, Oct 12, 2020 at 7:31 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> >
> > On Mon, Oct 12, 2020 at 5:57 PM Kees Cook <keescook@chromium.org> wrote:
> > > I think it's fine to just have this "dangle" with a help text update of
> > > "if seccomp action caching is supported by the architecture, provide the
> > > /proc/$pid ..."
> >
> > I think it would be weird if someone sees this help text and wonder...
> > "hmm does my architecture support seccomp action caching" and without
> > a clear pointer to how seccomp action cache works, goes and compiles
> > the kernel with this config option on for the purpose of knowing if
> > their arch supports it... Or, is it a common practice in the kernel to
> > leave dangling configs?
> 
> Bump, in case this question was missed.

I've been going back and forth on this, and I think what I've settled
on is I'd like to avoid new CONFIG dependencies just for this feature.
Instead, how about we just fill in SECCOMP_NATIVE and SECCOMP_COMPAT
for all the HAVE_ARCH_SECCOMP_FILTER architectures, and then the
cache reporting can be cleanly tied to CONFIG_SECCOMP_FILTER? It
should be relatively simple to extract those details and make
SECCOMP_ARCH_{NATIVE,COMPAT}_NAME part of the per-arch enabling patches?

> I don't really want to miss the 5.10 merge window...

Sorry, the 5.10 merge window is already closed for stuff that hasn't
already been in -next. Most subsystem maintainers (myself included)
don't take new features into their trees between roughly N-rc6 and
(N+1)-rc1. My plan is to put this in my -next tree after -rc1 is released
(expected to be Oct 25th).

I'd still like to get more specific workload performance numbers too.
The microbenchmark is nice, but getting things like build times under
docker's default seccomp filter, etc would be lovely. I've almost gotten
there, but my benchmarks are still really noisy and CPU isolation
continues to frustrate me. :)

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
