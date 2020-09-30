Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6598FC4363D
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 22:25:05 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A849120719
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 22:25:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="TaMaeVg9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A849120719
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 3C07987227;
	Wed, 30 Sep 2020 22:25:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id aPmqLfuPnOYe; Wed, 30 Sep 2020 22:25:03 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 4C4678721E;
	Wed, 30 Sep 2020 22:25:03 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 32EE6C016F;
	Wed, 30 Sep 2020 22:25:03 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0AEE7C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:25:02 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id E938E86819
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:25:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ypaZNZIxK2R6
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:25:00 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f67.google.com (mail-ej1-f67.google.com
 [209.85.218.67])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 8686086791
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:25:00 +0000 (UTC)
Received: by mail-ej1-f67.google.com with SMTP id j11so5183800ejk.0
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:25:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=KwjzYmhHb/l5tPkyGm+gWxyB3dKnDLT96damvVDsJ2o=;
 b=TaMaeVg9pan0BW7Akk6/bQquEKr7WnaOhi8gWvSoFshHON6Z74AABiNZztSTaCTogI
 qcX7baxYxrulvGyDRZTM4bOhqpi0Sqza7QEDiz2rMZJ1EO73ptKJa4+1P98+vP6Ew7xK
 LEzbLI+LRCtpYBYt9ofUPwxVymoVTFDdpGnSucOjI7Zacw1Gco3t6vRlLt9OuQja6AMJ
 OjLIUusdonw9sNDn7NsiKujPO7Y/Fh6L89W3AWXDeWbLe7fsimcVZuFyFq3IziQnjhG2
 +lGUtU2S6fhEnlpGkuF+RMWZl0Jg3W5ZGxhNGSCKsM26TJaMdAznAWum0J+/CdK6Dcc0
 Q/Uw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=KwjzYmhHb/l5tPkyGm+gWxyB3dKnDLT96damvVDsJ2o=;
 b=nbWJYAUedkPfTf0CABd+i2qfsFuwHlo4PFxPu19JBd5AZSWv/54ElYpSx89dPOwsrl
 v7YFfTDl9s6pclpDmi+TCY4g40GnHY20zQ5VnYPJF/GzWF5a5c1r/XNv3Tj2B9FHygNc
 f22XwWYKopxPiWzfGKb4ivgO8CqIqSdISa2j3saL4yTA07db4hx/sRC6JH7yeCJsU6R0
 m6/3nxNaM+EhC5ft3zWw7c1+lWk75Owc/biE+e4uOw2cDZONrBFvArNjBQIqGpnPC/m9
 EmsHfEIa6f573oOvy2BNl3YFj9C6hwN/INQHzqrTo7tVfx+y8neZUNXV6cLVVHxvXmjG
 3B7w==
X-Gm-Message-State: AOAM531nrp/F6hkvC+kHzLBp5Zg1iFHHefzWWWMlv0d4Nb2PUl22RJ8G
 ue14uJgx+ILxG6+CNE9KMZn7DvQRjvhwBY9omAygvg==
X-Google-Smtp-Source: ABdhPJwf2Ih9sOkNH0XKF+uPNFVAplx37AhDqvFCkipTk5tzsR8+wlzRLDPvzToK+HK8NAJ25kPUij91WMm94qh9eCg=
X-Received: by 2002:a17:906:9389:: with SMTP id
 l9mr5200759ejx.537.1601504698740; 
 Wed, 30 Sep 2020 15:24:58 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <b16456e8dbc378c41b73c00c56854a3c30580833.1601478774.git.yifeifz2@illinois.edu>
In-Reply-To: <b16456e8dbc378c41b73c00c56854a3c30580833.1601478774.git.yifeifz2@illinois.edu>
Date: Thu, 1 Oct 2020 00:24:32 +0200
Message-ID: <CAG48ez0Njm0oS+9k-cgUqzyUWXV=cHPope2Xe9vVNPUVZ1PB4w@mail.gmail.com>
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

On Wed, Sep 30, 2020 at 5:20 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> SECCOMP_CACHE_NR_ONLY will only operate on syscalls that do not
> access any syscall arguments or instruction pointer. To facilitate
> this we need a static analyser to know whether a filter will
> return allow regardless of syscall arguments for a given
> architecture number / syscall number pair. This is implemented
> here with a pseudo-emulator, and stored in a per-filter bitmap.
>
> Each common BPF instruction are emulated. Any weirdness or loading
> from a syscall argument will cause the emulator to bail.
>
> The emulation is also halted if it reaches a return. In that case,
> if it returns an SECCOMP_RET_ALLOW, the syscall is marked as good.
>
> Emulator structure and comments are from Kees [1] and Jann [2].
>
> Emulation is done at attach time. If a filter depends on more
> filters, and if the dependee does not guarantee to allow the
> syscall, then we skip the emulation of this syscall.
>
> [1] https://lore.kernel.org/lkml/20200923232923.3142503-5-keescook@chromium.org/
> [2] https://lore.kernel.org/lkml/CAG48ez1p=dR_2ikKq=xVxkoGg0fYpTBpkhJSv1w-6BG=76PAvw@mail.gmail.com/
[...]
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 1ab22869a765..ff5289228ea5 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -150,6 +150,7 @@ config X86
>         select HAVE_ARCH_COMPAT_MMAP_BASES      if MMU && COMPAT
>         select HAVE_ARCH_PREL32_RELOCATIONS
>         select HAVE_ARCH_SECCOMP_FILTER
> +       select HAVE_ARCH_SECCOMP_CACHE_NR_ONLY
>         select HAVE_ARCH_THREAD_STRUCT_WHITELIST
>         select HAVE_ARCH_STACKLEAK
>         select HAVE_ARCH_TRACEHOOK

If you did the architecture enablement for X86 later in the series,
you could move this part over into that patch, that'd be cleaner.

> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index ae6b40cc39f4..f09c9e74ae05 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -143,6 +143,37 @@ struct notification {
>         struct list_head notifications;
>  };
>
> +#ifdef CONFIG_SECCOMP_CACHE_NR_ONLY
> +/**
> + * struct seccomp_cache_filter_data - container for cache's per-filter data
> + *
> + * Tis struct is ordered to minimize padding holes.

I think this comment can probably go away, there isn't really much
trickery around padding holes in the struct as it is now.

> + * @syscall_allow_default: A bitmap where each bit represents whether the
> + *                        filter willalways allow the syscall, for the

nit: s/willalways/will always/

[...]
> +static void seccomp_cache_prepare_bitmap(struct seccomp_filter *sfilter,
> +                                        void *bitmap, const void *bitmap_prev,
> +                                        size_t bitmap_size, int arch)
> +{
> +       struct sock_fprog_kern *fprog = sfilter->prog->orig_prog;
> +       struct seccomp_data sd;
> +       int nr;
> +
> +       for (nr = 0; nr < bitmap_size; nr++) {
> +               if (bitmap_prev && !test_bit(nr, bitmap_prev))
> +                       continue;
> +
> +               sd.nr = nr;
> +               sd.arch = arch;
> +
> +               if (seccomp_emu_is_const_allow(fprog, &sd))
> +                       set_bit(nr, bitmap);

set_bit() is atomic, but since we only do this at filter setup, before
the filter becomes globally visible, we don't need atomicity here. So
this should probably use __set_bit() instead.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
