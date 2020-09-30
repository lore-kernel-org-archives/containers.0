Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F11A0C4363D
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 22:49:07 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5A5E720719
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 22:49:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="b9W9/WFA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A5E720719
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id B8F372277A;
	Wed, 30 Sep 2020 22:49:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id eKtB3ux90F-Q; Wed, 30 Sep 2020 22:49:05 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 0944C203AA;
	Wed, 30 Sep 2020 22:49:05 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id EF616C016F;
	Wed, 30 Sep 2020 22:49:04 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0808EC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:49:04 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id EAC4785D61
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:49:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 0wC5-_JuwSYK
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:49:03 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com
 [209.85.215.195])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 58D9985A76
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:49:03 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id 34so2194721pgo.13
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:49:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=VT2vDd9OB7uEL9vUlvmQWoFRKp72QNgXm7S/Mv4km2A=;
 b=b9W9/WFAa7j9YD1PJAI4yFg7dus7W0r/MW7Dboua7FmO8kMbs1gKAajU9Q2CldMKVq
 ScKuRCkr1vwZZCRbn/yF/6r9z2d5ANWOaT0AFusLzF4y5idwBkxeYt+G5BTv7KZAolR8
 6SxxMXSjfujZ2U/hIWKv0FguBBnmAB5AcFqfE=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=VT2vDd9OB7uEL9vUlvmQWoFRKp72QNgXm7S/Mv4km2A=;
 b=L9gvSeeobYeXrqrJmSTUGzm+lM3VZj1ES0NZ8BTc88Hv0oqKxfvyA3Y935ACzN5UOG
 u97Jz319NUYqGql3VPPtBRSzRf82aP3Kl+vrxudzSnKnHwctYNkkuqETuImhzHOce4Ou
 PouU9YnArOc5NaplsLHPkz5NORTNPVKL510tGVEJphlqivDEdf8aA7oJBZbdoI1+T3V5
 SVZKBIWsfsPBw5+dlYwu1RgwQGGWWjEbMJhZHtpMWSxGEruny5BmKtBqzPev1sMdki+3
 8BBB7QC2XIPBbD6J3HKC39hSFjnLaeuiru/RF4XDLFJPgqLYF3nkZ1GdPzL+/KQ2iVfS
 i48Q==
X-Gm-Message-State: AOAM533Gm6JCbAtC2vGeDLnO37MraiTTAOYZ5nbJ0uF0iycwQMreqmob
 rQ+1wBhkXqVkOkbh3lPYqL5fjw==
X-Google-Smtp-Source: ABdhPJwfSK5iNpfj80w0dYS73zpvMdKZB8MpSp2GpAdsedr4h3Z0FZm0dB+5To7uEo0x/wrmF8Kkpw==
X-Received: by 2002:a62:19c4:0:b029:13e:d13d:a0fd with SMTP id
 187-20020a6219c40000b029013ed13da0fdmr4271918pfz.25.1601506142852; 
 Wed, 30 Sep 2020 15:49:02 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id u10sm3674241pfn.122.2020.09.30.15.49.01
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 30 Sep 2020 15:49:02 -0700 (PDT)
Date: Wed, 30 Sep 2020 15:49:01 -0700
From: Kees Cook <keescook@chromium.org>
To: Jann Horn <jannh@google.com>
Subject: Re: [PATCH v3 seccomp 2/5] seccomp/cache: Add "emulator" to check if
 filter is constant allow
Message-ID: <202009301546.6B7D648F57@keescook>
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <b16456e8dbc378c41b73c00c56854a3c30580833.1601478774.git.yifeifz2@illinois.edu>
 <CAG48ez0Njm0oS+9k-cgUqzyUWXV=cHPope2Xe9vVNPUVZ1PB4w@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez0Njm0oS+9k-cgUqzyUWXV=cHPope2Xe9vVNPUVZ1PB4w@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, YiFei Zhu <yifeifz2@illinois.edu>,
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

On Thu, Oct 01, 2020 at 12:24:32AM +0200, Jann Horn wrote:
> On Wed, Sep 30, 2020 at 5:20 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> > SECCOMP_CACHE_NR_ONLY will only operate on syscalls that do not
> > access any syscall arguments or instruction pointer. To facilitate
> > this we need a static analyser to know whether a filter will
> > return allow regardless of syscall arguments for a given
> > architecture number / syscall number pair. This is implemented
> > here with a pseudo-emulator, and stored in a per-filter bitmap.
> >
> > Each common BPF instruction are emulated. Any weirdness or loading
> > from a syscall argument will cause the emulator to bail.
> >
> > The emulation is also halted if it reaches a return. In that case,
> > if it returns an SECCOMP_RET_ALLOW, the syscall is marked as good.
> >
> > Emulator structure and comments are from Kees [1] and Jann [2].
> >
> > Emulation is done at attach time. If a filter depends on more
> > filters, and if the dependee does not guarantee to allow the
> > syscall, then we skip the emulation of this syscall.
> >
> > [1] https://lore.kernel.org/lkml/20200923232923.3142503-5-keescook@chromium.org/
> > [2] https://lore.kernel.org/lkml/CAG48ez1p=dR_2ikKq=xVxkoGg0fYpTBpkhJSv1w-6BG=76PAvw@mail.gmail.com/
> [...]
> > +static void seccomp_cache_prepare_bitmap(struct seccomp_filter *sfilter,
> > +                                        void *bitmap, const void *bitmap_prev,
> > +                                        size_t bitmap_size, int arch)
> > +{
> > +       struct sock_fprog_kern *fprog = sfilter->prog->orig_prog;
> > +       struct seccomp_data sd;
> > +       int nr;
> > +
> > +       for (nr = 0; nr < bitmap_size; nr++) {
> > +               if (bitmap_prev && !test_bit(nr, bitmap_prev))
> > +                       continue;
> > +
> > +               sd.nr = nr;
> > +               sd.arch = arch;
> > +
> > +               if (seccomp_emu_is_const_allow(fprog, &sd))
> > +                       set_bit(nr, bitmap);
> 
> set_bit() is atomic, but since we only do this at filter setup, before
> the filter becomes globally visible, we don't need atomicity here. So
> this should probably use __set_bit() instead.

Oh yes, excellent point! That will speed this up a bit. When you do
this, please include a comment here describing why its safe to do it
non-atomic. :)

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
