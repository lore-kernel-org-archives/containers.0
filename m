Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5811C4727F
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:21:26 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4EC6C2076A
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:21:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="TZcivgXw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4EC6C2076A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id D933B86C0A;
	Wed, 30 Sep 2020 23:21:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ioz7mFdqJ5gd; Wed, 30 Sep 2020 23:21:25 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 2DC9186727;
	Wed, 30 Sep 2020 23:21:25 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 211A2C0889;
	Wed, 30 Sep 2020 23:21:25 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1CBD8C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:21:24 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 1421E85DF6
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:21:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id vM4REvAoDfRx
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:21:23 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com
 [209.85.215.193])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 6BC2F83742
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:21:23 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id e18so2302202pgd.4
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 16:21:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=x63BBbB7KwIQqJxUqTsIaDJvuWLQtOEVBES32Yy+YAo=;
 b=TZcivgXw3I1epH9uT9vdPCWx/4ExuFu3+g4x3a/AhrJ47vzwURw8KdgwcFvZLA4x6R
 N43c1jc09gyZaUIARtJRdVpNBz8HLiKvE3J/YzFFtLaGuQ5vdTXiZAYuWGd1EBHOC14M
 xS08nPZAgFW9Y6dbf3e9FfTYtNlPH/Srf7U4I=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=x63BBbB7KwIQqJxUqTsIaDJvuWLQtOEVBES32Yy+YAo=;
 b=dSwKMVYrhams4UoRzpTiM4nVVoyqpdg6vxIF9WCA3wTmdGBiIzJRTN9haapztPyuO0
 N6jyWuHy3kJUKmPCoLbnV3ajbYJrrG3A72lWzk0G9f3wubRaKA0qC4JvmAoYf2zGce+M
 0PfJ7XE8jTd+TkNElJSftBZ7q8+uK/NQprI7EANHUJXmkFWZBTCAuIehY8ULU6Lw1Pwu
 mtX/9uEftXSnFUZeoI3PmOajlRI4pS6NeVLLDL6acISgToXB8ptRpRPx35aGoz1AdhJR
 xVOmbQGzpaC5xoVoV6GZmbJR93aL8TrRGkV2Xd9fkw47DOe52pQLV/iy5Chv+UfjEqfP
 61rQ==
X-Gm-Message-State: AOAM531PZceUc3uDim7+KxsjAKvG382Lv96JTYE6XmbcRZ917gZ7T8Dv
 6qO78rf494JVOi8W/zJS21eT1w==
X-Google-Smtp-Source: ABdhPJxuU0x2CWFLEU2A+WDs32aP0TdSrFtCY2CLnbAl54vDjrmQMaeG/VBOLgLEbehuqlqMS0xYoQ==
X-Received: by 2002:a17:902:7002:b029:d2:950a:d82a with SMTP id
 y2-20020a1709027002b02900d2950ad82amr4444416plk.72.1601508082978; 
 Wed, 30 Sep 2020 16:21:22 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id 206sm3071721pgh.26.2020.09.30.16.21.21
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 30 Sep 2020 16:21:22 -0700 (PDT)
Date: Wed, 30 Sep 2020 16:21:21 -0700
From: Kees Cook <keescook@chromium.org>
To: Jann Horn <jannh@google.com>
Subject: Re: [PATCH v3 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Message-ID: <202009301612.E9DD7361@keescook>
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <d3d1c05ea0be2b192f480ec52ad64bffbb22dc9d.1601478774.git.yifeifz2@illinois.edu>
 <202009301554.590642EBE@keescook>
 <CAG48ez077wMkh-sJebjxd3nAmBsNRCF2U8Vmmy-Fc7dr8KRyqw@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez077wMkh-sJebjxd3nAmBsNRCF2U8Vmmy-Fc7dr8KRyqw@mail.gmail.com>
Cc: Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
 Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 the arch/x86 maintainers <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>,
 Tianyin Xu <tyxu@illinois.edu>, Valentin Rothberg <vrothber@redhat.com>,
 Borislav Petkov <bp@alien8.de>, Josep Torrellas <torrella@illinois.edu>,
 Thomas Gleixner <tglx@linutronix.de>, Will Drewry <wad@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 David Laight <David.Laight@aculab.com>, bpf <bpf@vger.kernel.org>
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

On Thu, Oct 01, 2020 at 01:08:04AM +0200, Jann Horn wrote:
> [adding x86 folks to enhance bikeshedding]
> 
> On Thu, Oct 1, 2020 at 12:59 AM Kees Cook <keescook@chromium.org> wrote:
> > On Wed, Sep 30, 2020 at 10:19:16AM -0500, YiFei Zhu wrote:
> > > From: YiFei Zhu <yifeifz2@illinois.edu>
> > >
> > > Currently the kernel does not provide an infrastructure to translate
> > > architecture numbers to a human-readable name. Translating syscall
> > > numbers to syscall names is possible through FTRACE_SYSCALL
> > > infrastructure but it does not provide support for compat syscalls.
> > >
> > > This will create a file for each PID as /proc/pid/seccomp_cache.
> > > The file will be empty when no seccomp filters are loaded, or be
> > > in the format of:
> > > <arch name> <decimal syscall number> <ALLOW | FILTER>
> > > where ALLOW means the cache is guaranteed to allow the syscall,
> > > and filter means the cache will pass the syscall to the BPF filter.
> > >
> > > For the docker default profile on x86_64 it looks like:
> > > x86_64 0 ALLOW
> > > x86_64 1 ALLOW
> > > x86_64 2 ALLOW
> > > x86_64 3 ALLOW
> > > [...]
> > > x86_64 132 ALLOW
> > > x86_64 133 ALLOW
> > > x86_64 134 FILTER
> > > x86_64 135 FILTER
> > > x86_64 136 FILTER
> > > x86_64 137 ALLOW
> > > x86_64 138 ALLOW
> > > x86_64 139 FILTER
> > > x86_64 140 ALLOW
> > > x86_64 141 ALLOW
> [...]
> > > diff --git a/arch/x86/include/asm/seccomp.h b/arch/x86/include/asm/seccomp.h
> > > index 7b3a58271656..33ccc074be7a 100644
> > > --- a/arch/x86/include/asm/seccomp.h
> > > +++ b/arch/x86/include/asm/seccomp.h
> > > @@ -19,13 +19,16 @@
> > >  #ifdef CONFIG_X86_64
> > >  # define SECCOMP_ARCH_DEFAULT                        AUDIT_ARCH_X86_64
> > >  # define SECCOMP_ARCH_DEFAULT_NR             NR_syscalls
> > > +# define SECCOMP_ARCH_DEFAULT_NAME           "x86_64"
> > >  # ifdef CONFIG_COMPAT
> > >  #  define SECCOMP_ARCH_COMPAT                        AUDIT_ARCH_I386
> > >  #  define SECCOMP_ARCH_COMPAT_NR             IA32_NR_syscalls
> > > +#  define SECCOMP_ARCH_COMPAT_NAME           "x86_32"
> >
> > I think this should be "ia32"? Is there a good definitive guide on this
> > naming convention?
> 
> "man 2 syscall" calls them "x86-64" and "i386". The syscall table
> files use ABI names "i386" and "64". The syscall stub prefixes use
> "x64" and "ia32".
> 
> I don't think we have a good consistent naming strategy here. :P

Agreed. And with "i386" being so hopelessly inaccurate, I prefer
"ia32" ... *shrug*

I would hope we don't have to be super-pedantic and call them "x86-64" and "IA-32". :P

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
