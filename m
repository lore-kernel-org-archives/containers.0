Return-Path: <SRS0=DMKn=EC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44E12C388F9
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 09:52:56 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 692A021D24
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 09:52:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 692A021D24
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id F21DE85653;
	Tue, 27 Oct 2020 09:52:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fRuulfeZ3mNX; Tue, 27 Oct 2020 09:52:54 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 0E4C08562D;
	Tue, 27 Oct 2020 09:52:54 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 018A9C0859;
	Tue, 27 Oct 2020 09:52:54 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1F501C0051
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 09:52:53 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 188AF20433
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 09:52:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id U2goltJZz0AH
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 09:52:51 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-oi1-f196.google.com (mail-oi1-f196.google.com
 [209.85.167.196])
 by silver.osuosl.org (Postfix) with ESMTPS id AE9272042A
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 09:52:51 +0000 (UTC)
Received: by mail-oi1-f196.google.com with SMTP id s21so688385oij.0
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 02:52:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=4k15uLlQPDyibib9c7Zvh6tW8H4LI+JfDQ0J2WXNZIA=;
 b=T4m23XjqApl33ljTmYnFFBiBBMoPXWc9w5KvCpyI+6Jh+j4USxV6WNRmb3vb7r4RoE
 u5eDyH6R+SCDpxbc/ed6n2RgiRkwJaZF3crH+hd/3NNknrbH63Ql8zA403usfZ/GWUMT
 IuASukyNdui8GzjdgJhsmKp6p3tA+IWPRksRq/FyISswwORKTv3S4VIJDYDYytLKcyGX
 6zuNUKlQ0/Nw1gig+0dhM3t7WxlzpY/+4hnH4NCQnzm2jMQ4CVm6LiBQ2lQfERhmg3Gp
 +QCU6PH4F0unm/SCHzV+gQ2TfF0zeF91AvJMQityTujO401bJhzsM0TGbe97SmYxcmjb
 GzAg==
X-Gm-Message-State: AOAM5303+qpbLroN6Iz5HI4RbEGMvAzWHpYcfj7XY/reO3AswcRugJlP
 TGVgl0UYqYtg1ceZVdx9v0tpKURtsXQ4PkPr4aw=
X-Google-Smtp-Source: ABdhPJy1dLvdgv16AoCtLqymByBSY+KWH3iutF2PlZlpY9aTJDLry4PFiC4VtXAbn52n7pE6xNSdtr52Vl0GaJY40Gk=
X-Received: by 2002:aca:f40c:: with SMTP id s12mr785596oih.153.1603792370966; 
 Tue, 27 Oct 2020 02:52:50 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <9ede6ef35c847e58d61e476c6a39540520066613.1600951211.git.yifeifz2@illinois.edu>
In-Reply-To: <9ede6ef35c847e58d61e476c6a39540520066613.1600951211.git.yifeifz2@illinois.edu>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 27 Oct 2020 10:52:39 +0100
Message-ID: <CAMuHMdXTLKr6pvoE+JAdn_P5kVxL6gx8PJ8mqfXcS+SF+pRbkQ@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 1/6] seccomp: Move config option SECCOMP to
 arch/Kconfig
To: YiFei Zhu <zhuyifei1999@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 containers@lists.linux-foundation.org, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
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

Hi Yifei,

On Thu, Sep 24, 2020 at 2:48 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> From: YiFei Zhu <yifeifz2@illinois.edu>
>
> In order to make adding configurable features into seccomp
> easier, it's better to have the options at one single location,
> considering easpecially that the bulk of seccomp code is
> arch-independent. An quick look also show that many SECCOMP
> descriptions are outdated; they talk about /proc rather than
> prctl.
>
> As a result of moving the config option and keeping it default
> on, architectures arm, arm64, csky, riscv, sh, and xtensa
> did not have SECCOMP on by default prior to this and SECCOMP will
> be default in this change.
>
> Architectures microblaze, mips, powerpc, s390, sh, and sparc
> have an outdated depend on PROC_FS and this dependency is removed
> in this change.
>
> Suggested-by: Jann Horn <jannh@google.com>
> Link: https://lore.kernel.org/lkml/CAG48ez1YWz9cnp08UZgeieYRhHdqh-ch7aNwc4JRBnGyrmgfMg@mail.gmail.com/
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>

Thanks for your patch. which is now commit 282a181b1a0d66de ("seccomp:
Move config option SECCOMP to arch/Kconfig") in v5.10-rc1.

> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -458,6 +462,23 @@ config HAVE_ARCH_SECCOMP_FILTER
>             results in the system call being skipped immediately.
>           - seccomp syscall wired up
>
> +config SECCOMP
> +       def_bool y
> +       depends on HAVE_ARCH_SECCOMP
> +       prompt "Enable seccomp to safely compute untrusted bytecode"
> +       help
> +         This kernel feature is useful for number crunching applications
> +         that may need to compute untrusted bytecode during their
> +         execution. By using pipes or other transports made available to
> +         the process as file descriptors supporting the read/write
> +         syscalls, it's possible to isolate those applications in
> +         their own address space using seccomp. Once seccomp is
> +         enabled via prctl(PR_SET_SECCOMP), it cannot be disabled
> +         and the task is only allowed to execute a few safe syscalls
> +         defined by each seccomp mode.
> +
> +         If unsure, say Y. Only embedded should say N here.
> +

Please tell me why SECCOMP is special, and deserves to default to be
enabled.  Is it really that critical, given only 13.5 (half of sparc
;-) out of 24
architectures implement support for it?

Thanks!

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
