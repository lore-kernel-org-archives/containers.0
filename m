Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4622C4363D
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 22:01:18 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 56C48206D9
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 22:01:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="nsRbXiOR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56C48206D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id EC63885C8C;
	Wed, 30 Sep 2020 22:01:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id X-A0JrvcR8P4; Wed, 30 Sep 2020 22:01:17 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 37D6C85C62;
	Wed, 30 Sep 2020 22:01:17 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1D6FBC0889;
	Wed, 30 Sep 2020 22:01:17 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1472DC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:01:16 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id B43C0203C8
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:01:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id RapxMbeaGXDx
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:01:14 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f65.google.com (mail-ed1-f65.google.com
 [209.85.208.65])
 by silver.osuosl.org (Postfix) with ESMTPS id E4812203BA
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 22:01:13 +0000 (UTC)
Received: by mail-ed1-f65.google.com with SMTP id l17so3498948edq.12
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 15:01:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=y4YL+lNdGMsghFiiyVXUFYKr+d1Y4X0K0yYZxdRVN+Q=;
 b=nsRbXiOR1d5uOkP2Hn3WDkdiWl4FaafECWJk0Z0LoZJOdD4x9ju+bYpc03KEpkHcOP
 rNxeoWyFWXQKqM3JfgZE3Lgs8ZCa507m90YbFDJ1wlkj3LjbHj2Ar1OdxFJR8jxVEYhU
 lMqszQp89VwZ7BwQM+cnG427o+9/H4/nlbdxFPw2AwRRdc8xrPoNRv5Q/Prwpdg5PwR2
 7oWU4S9IDHEw5p40xcMbz47y8E5xLgug1W8vr8kTd1oIRGwRTHCHugrN4M9Zmn139XVk
 d0DU2DdpnThlnlZscBJgqBcghKwckBJQ21qz8AnqGSRjKsbsFL3FoaEiybGKfrqMpXzW
 FxiA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=y4YL+lNdGMsghFiiyVXUFYKr+d1Y4X0K0yYZxdRVN+Q=;
 b=D/l44FSudpCioHEfRd64HHmCbm1TBXL7L3jKmTsfETZdr7ssVS8qqb6YqS47EG2HUC
 ZML29Ceo5ffMrto+bsg5VN4JtPhKDjVp051J1QiWcLH7eZj/jTrosrWwrhQjw3KIE+d7
 dlcHUqxqIclbrzlnvOkfIHA9AxaBwnj6tpoxtuseOJTG7B1KKeTdnSMzI4oHaDgfG1JQ
 4CS29Tmuo0Kpj8Ts0FKnTJZt6TT8QQT3/qffzt7Xi7mZdaYAWlEDAmvmhxDm1BLtBsC+
 h6ZLwMOYPSwdleE6j4c/hGuCjfojEjpCNLZ19fIHgoba6GyGnRT3kooZRNnrK0BPY9ru
 cHhg==
X-Gm-Message-State: AOAM530cDmJE/FhZvM1e3Tyn95TKFAmIO3om38fynGGctO18vQCJZyeP
 WnPH0h8LrUqcuT0UJWjH0ptJg8X9lrN2WIGmfDcvuQ==
X-Google-Smtp-Source: ABdhPJx+r3ymqn4NTjaCSnTfnu9MJPet1q8fE2eAOfbo/VZn36pDDUmIF7542A/F5sgR+LytFnb9dd+ClgVFQzScsmw=
X-Received: by 2002:a50:fe98:: with SMTP id d24mr4937741edt.223.1601503272085; 
 Wed, 30 Sep 2020 15:01:12 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <d3d1c05ea0be2b192f480ec52ad64bffbb22dc9d.1601478774.git.yifeifz2@illinois.edu>
In-Reply-To: <d3d1c05ea0be2b192f480ec52ad64bffbb22dc9d.1601478774.git.yifeifz2@illinois.edu>
Date: Thu, 1 Oct 2020 00:00:46 +0200
Message-ID: <CAG48ez0whaSTobwnoJHW+Eyqg5a8H4JCO-KHrgsuNiEg0qbD3w@mail.gmail.com>
Subject: Re: [PATCH v3 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
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
> Currently the kernel does not provide an infrastructure to translate
> architecture numbers to a human-readable name. Translating syscall
> numbers to syscall names is possible through FTRACE_SYSCALL
> infrastructure but it does not provide support for compat syscalls.
>
> This will create a file for each PID as /proc/pid/seccomp_cache.
> The file will be empty when no seccomp filters are loaded, or be
> in the format of:
> <arch name> <decimal syscall number> <ALLOW | FILTER>
> where ALLOW means the cache is guaranteed to allow the syscall,
> and filter means the cache will pass the syscall to the BPF filter.
>
> For the docker default profile on x86_64 it looks like:
> x86_64 0 ALLOW
> x86_64 1 ALLOW
> x86_64 2 ALLOW
> x86_64 3 ALLOW
> [...]
> x86_64 132 ALLOW
> x86_64 133 ALLOW
> x86_64 134 FILTER
> x86_64 135 FILTER
> x86_64 136 FILTER
> x86_64 137 ALLOW
> x86_64 138 ALLOW
> x86_64 139 FILTER
> x86_64 140 ALLOW
> x86_64 141 ALLOW
> [...]

Oooh, neat! :) Thanks!

> Suggested-by: Jann Horn <jannh@google.com>
> Link: https://lore.kernel.org/lkml/CAG48ez3Ofqp4crXGksLmZY6=fGrF_tWyUCg7PBkAetvbbOPeOA@mail.gmail.com/
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> ---
>  arch/Kconfig                   | 15 +++++++++++
>  arch/x86/include/asm/seccomp.h |  3 +++
>  fs/proc/base.c                 |  3 +++
>  include/linux/seccomp.h        |  5 ++++
>  kernel/seccomp.c               | 46 ++++++++++++++++++++++++++++++++++
>  5 files changed, 72 insertions(+)
>
> diff --git a/arch/Kconfig b/arch/Kconfig
> index ca867b2a5d71..b840cadcc882 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -478,6 +478,7 @@ config HAVE_ARCH_SECCOMP_CACHE_NR_ONLY
>           - all the requirements for HAVE_ARCH_SECCOMP_FILTER
>           - SECCOMP_ARCH_DEFAULT
>           - SECCOMP_ARCH_DEFAULT_NR
> +         - SECCOMP_ARCH_DEFAULT_NAME
>
>  config SECCOMP
>         prompt "Enable seccomp to safely execute untrusted bytecode"
> @@ -532,6 +533,20 @@ config SECCOMP_CACHE_NR_ONLY
>
>  endchoice
>
> +config DEBUG_SECCOMP_CACHE
> +       bool "Show seccomp filter cache status in /proc/pid/seccomp_cache"
> +       depends on SECCOMP_CACHE_NR_ONLY
> +       depends on PROC_FS
> +       help
> +         This is enables /proc/pid/seccomp_cache interface to monitor

nit: s/is enables/enables/

> +         seccomp cache data. The file format is subject to change. Reading
> +         the file requires CAP_SYS_ADMIN.
> +
> +         This option is for debugging only. Enabling present the risk that
> +         an adversary may be able to infer the seccomp filter logic.
> +
> +         If unsure, say N.
> +
[...]
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
[...]
> +int proc_pid_seccomp_cache(struct seq_file *m, struct pid_namespace *ns,
> +                          struct pid *pid, struct task_struct *task)
> +{
> +       struct seccomp_filter *f;
> +
> +       /*
> +        * We don't want some sandboxed process know what their seccomp
> +        * filters consist of.
> +        */
> +       if (!file_ns_capable(m->file, &init_user_ns, CAP_SYS_ADMIN))
> +               return -EACCES;
> +
> +       f = READ_ONCE(task->seccomp.filter);
> +       if (!f)
> +               return 0;

Hmm, this won't work, because the task could be exiting, and seccomp
filters are detached in release_task() (using
seccomp_filter_release()). And at the moment, seccomp_filter_release()
just locklessly NULLs out the tsk->seccomp.filter pointer and drops
the reference.

The locking here is kind of gross, but basically I think you can
change this code to use lock_task_sighand() / unlock_task_sighand()
(see the other examples in fs/proc/base.c), and bail out if
lock_task_sighand() returns NULL. And in seccomp_filter_release(), add
something like this:

/* We are effectively holding the siglock by not having any sighand. */
WARN_ON(tsk->sighand != NULL);

> +#ifdef SECCOMP_ARCH_DEFAULT
> +       proc_pid_seccomp_cache_arch(m, SECCOMP_ARCH_DEFAULT_NAME,
> +                                   f->cache.syscall_allow_default,
> +                                   SECCOMP_ARCH_DEFAULT_NR);
> +#endif /* SECCOMP_ARCH_DEFAULT */
> +
> +#ifdef SECCOMP_ARCH_COMPAT
> +       proc_pid_seccomp_cache_arch(m, SECCOMP_ARCH_COMPAT_NAME,
> +                                   f->cache.syscall_allow_compat,
> +                                   SECCOMP_ARCH_COMPAT_NR);
> +#endif /* SECCOMP_ARCH_COMPAT */
> +       return 0;
> +}
> +#endif /* CONFIG_DEBUG_SECCOMP_CACHE */
> --
> 2.28.0
>
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
