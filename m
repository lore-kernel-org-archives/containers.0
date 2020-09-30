Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F17EC4363D
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:08:37 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 54D512076A
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:08:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="HIKXee3A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54D512076A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id D9C05227AD;
	Wed, 30 Sep 2020 23:08:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4uUe9ORQQgET; Wed, 30 Sep 2020 23:08:34 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 67ED220345;
	Wed, 30 Sep 2020 23:08:34 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4DD24C016F;
	Wed, 30 Sep 2020 23:08:34 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4650AC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:08:33 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 3EC9187234
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:08:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id K09Ctp5SC8KC
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:08:32 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f66.google.com (mail-ej1-f66.google.com
 [209.85.218.66])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 3F4D7871AD
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:08:32 +0000 (UTC)
Received: by mail-ej1-f66.google.com with SMTP id p15so5221931ejm.7
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 16:08:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=oSjyCndmSDw71eE/BIT10kmAi2CWzQm4Fdkl0rDwsVs=;
 b=HIKXee3AjLR1yKNiCxpi/lY3cYYCKNhBnzExJFzXfKnsypgwzwfgjzM0tb17O4Vgyp
 lhgXkKM9j2PeIgZpOnVu++oMi7gJvxIjizwMo703OTz8iXPRoqS8aax65sRSbVXVQhaN
 tvjeuhg5mYZ8mUI0vBLvW61A38C6uccE8YKBXI8V0m4NvbBCXtfIlsDBT4jZHcnedOEg
 PO51mrwjnCCJ8TSH0ZBojL0RZxbyHtHcw2Xb7KRra7wZgBheblTerBSatg5051UvvYcT
 ITGkQ01vRidlmaOwJA9wdrUJhVLTQwm8L4zEsmgVhT/kFZfXhq9Mntu4wkm3OmlCTSg/
 IPLQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=oSjyCndmSDw71eE/BIT10kmAi2CWzQm4Fdkl0rDwsVs=;
 b=h5vJ3RN391BVSj/+C5Zuf3pSEgVAR5o7hogEXYRDEKre3d8+YTZxEo/AWlYTcFVWEp
 jAxZnH+VuGA4qApbLd2JOlP5zCnfkTPBJvkRLzplZtdgaszQfPAvv48ZTa7m5JA5BSiL
 1teCN/rVKbk7Y8Psaxf/TwD6Es6ztoo27M1jGoCUYjBLSkZ6oZMgoLa4qIUqznNPZTKO
 mYiIxRK3ghMQBAc1EBf93d5vcQQJ1uUIi6iiCgrWK6MsjgLtgRq06kpmGGCvLY4RE+79
 roQen6MvyQltk/Arsx3t5pJh5wZJyCDPfWQBbSb31kH4wEmACYQb13KwnCww9VaDYbjA
 0EQA==
X-Gm-Message-State: AOAM533flOV5GM2Yd+S9ZvH+lj/tXTI1KuMSFFFAQmrCa5SdVD8XsKBA
 JWdV+IHvkM5+3wcrvFpJ0XGcGPwPn17W1PUCnSVzYg==
X-Google-Smtp-Source: ABdhPJyC+4DouNB+AJFTmGjbAtJDvRkfFxZToj/svy2V/efpofZpBJvCX/A3ee/XkublfA579qMlv91dBfLYJ/TEfyE=
X-Received: by 2002:a17:906:33c8:: with SMTP id
 w8mr574212eja.233.1601507310348; 
 Wed, 30 Sep 2020 16:08:30 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <d3d1c05ea0be2b192f480ec52ad64bffbb22dc9d.1601478774.git.yifeifz2@illinois.edu>
 <202009301554.590642EBE@keescook>
In-Reply-To: <202009301554.590642EBE@keescook>
Date: Thu, 1 Oct 2020 01:08:04 +0200
Message-ID: <CAG48ez077wMkh-sJebjxd3nAmBsNRCF2U8Vmmy-Fc7dr8KRyqw@mail.gmail.com>
Subject: Re: [PATCH v3 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
To: Kees Cook <keescook@chromium.org>
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

[adding x86 folks to enhance bikeshedding]

On Thu, Oct 1, 2020 at 12:59 AM Kees Cook <keescook@chromium.org> wrote:
> On Wed, Sep 30, 2020 at 10:19:16AM -0500, YiFei Zhu wrote:
> > From: YiFei Zhu <yifeifz2@illinois.edu>
> >
> > Currently the kernel does not provide an infrastructure to translate
> > architecture numbers to a human-readable name. Translating syscall
> > numbers to syscall names is possible through FTRACE_SYSCALL
> > infrastructure but it does not provide support for compat syscalls.
> >
> > This will create a file for each PID as /proc/pid/seccomp_cache.
> > The file will be empty when no seccomp filters are loaded, or be
> > in the format of:
> > <arch name> <decimal syscall number> <ALLOW | FILTER>
> > where ALLOW means the cache is guaranteed to allow the syscall,
> > and filter means the cache will pass the syscall to the BPF filter.
> >
> > For the docker default profile on x86_64 it looks like:
> > x86_64 0 ALLOW
> > x86_64 1 ALLOW
> > x86_64 2 ALLOW
> > x86_64 3 ALLOW
> > [...]
> > x86_64 132 ALLOW
> > x86_64 133 ALLOW
> > x86_64 134 FILTER
> > x86_64 135 FILTER
> > x86_64 136 FILTER
> > x86_64 137 ALLOW
> > x86_64 138 ALLOW
> > x86_64 139 FILTER
> > x86_64 140 ALLOW
> > x86_64 141 ALLOW
[...]
> > diff --git a/arch/x86/include/asm/seccomp.h b/arch/x86/include/asm/seccomp.h
> > index 7b3a58271656..33ccc074be7a 100644
> > --- a/arch/x86/include/asm/seccomp.h
> > +++ b/arch/x86/include/asm/seccomp.h
> > @@ -19,13 +19,16 @@
> >  #ifdef CONFIG_X86_64
> >  # define SECCOMP_ARCH_DEFAULT                        AUDIT_ARCH_X86_64
> >  # define SECCOMP_ARCH_DEFAULT_NR             NR_syscalls
> > +# define SECCOMP_ARCH_DEFAULT_NAME           "x86_64"
> >  # ifdef CONFIG_COMPAT
> >  #  define SECCOMP_ARCH_COMPAT                        AUDIT_ARCH_I386
> >  #  define SECCOMP_ARCH_COMPAT_NR             IA32_NR_syscalls
> > +#  define SECCOMP_ARCH_COMPAT_NAME           "x86_32"
>
> I think this should be "ia32"? Is there a good definitive guide on this
> naming convention?

"man 2 syscall" calls them "x86-64" and "i386". The syscall table
files use ABI names "i386" and "64". The syscall stub prefixes use
"x64" and "ia32".

I don't think we have a good consistent naming strategy here. :P
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
