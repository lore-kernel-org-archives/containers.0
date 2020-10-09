Return-Path: <SRS0=NhOQ=DQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F12EC433DF
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 21:45:33 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8F36522251
	for <containers@archiver.kernel.org>; Fri,  9 Oct 2020 21:45:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="VeVHFmly"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F36522251
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 1B62C20035;
	Fri,  9 Oct 2020 21:45:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id GR7Hkd4-jQ77; Fri,  9 Oct 2020 21:45:31 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 5E1E420014;
	Fri,  9 Oct 2020 21:45:31 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 45E6AC07FF;
	Fri,  9 Oct 2020 21:45:31 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 811C4C0051
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 21:45:29 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 6EA53877F9
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 21:45:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id eHM7P56uKkpv
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 21:45:28 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f67.google.com (mail-ej1-f67.google.com
 [209.85.218.67])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 73AA2877FD
 for <containers@lists.linux-foundation.org>;
 Fri,  9 Oct 2020 21:45:28 +0000 (UTC)
Received: by mail-ej1-f67.google.com with SMTP id md26so15167966ejb.10
 for <containers@lists.linux-foundation.org>;
 Fri, 09 Oct 2020 14:45:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=M3QASBM0PyBqWV4qYi2/juWl30Ro5T5ehsILkUh0Mms=;
 b=VeVHFmlydw44XMQ0jlUmjz9257sBoMcSb5kNBMm+/I8yNF1mq+Isl0FguqOpyiZKE/
 Y+aPx4AUvkVLLePrLlaTWIQ31nAAC9X4APGGLo3mVwcz+Vy9L7qQXJU9USVA/1alpFOc
 igtne+lu0FvEXxR4DTncx4DdoY4ADZqHTALlTUsbGyugfoOvGSc2sMtuIop4N0/FZhQQ
 esRZ6kzNRqnZ5zg27AN3U6lj8G19zmAlHXNVazZJ+AbThUZjti1lfTGrMftco6w+V00D
 yQ7y3Ce6BYhi1fynlsr0e4dzvttbb8ZD+yXjcskUQwKBwsX8dRJR8UY+UiO3wVY/Xywj
 xSRA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=M3QASBM0PyBqWV4qYi2/juWl30Ro5T5ehsILkUh0Mms=;
 b=JZ0w19xbBL9i4WLuRaqU3h0Q4g94fuScYozSGShKjTl6Kcjs/SFOD1EApGyWRlE3gm
 PIaQ9PbK5e/lS/cbUxFCqD7altSja7bik/8atZ4VRDLpAoKjpsBS/dXolkerDQAJqMdl
 cfPZC2YUZ2S5AsCP/5g9/lxgWHBKKHbfduJvwh7SfzJEGd/Kngg11pOnU4UHWst62g+u
 sQJ0I/fk/yU0rMW7h+C2oLzEqgfbKPUzSFy1g1FOzeQHsVkDNtT6uo7Avaal/iwHDX0I
 3/OyrsKhFqn263b0Zm5raw9gBhwve8Cu6K3AjXuaczCZYGOkDONydivWne4YRrk7hcV/
 6z4A==
X-Gm-Message-State: AOAM530q2jVWn0tQq68nZJY+9HfWpn1NdeeVavLfloSksNwtEGnZEMCG
 YLnvvlQEtVLU8knr0GczC9oqv1lHF48aAYqUWawFj0B89OI=
X-Google-Smtp-Source: ABdhPJztbhpbmafO850DZApEDfDuxUWnWBQzmSIKVH0rtmX0BAQpAcxDEIMOsnGY2/dfOkAseQk1kA6/YYaTTgip9Yc=
X-Received: by 2002:a17:906:394:: with SMTP id
 b20mr15967989eja.513.1602279926518; 
 Fri, 09 Oct 2020 14:45:26 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <c2077b8a86c6d82d611007d81ce81d32f718ec59.1602263422.git.yifeifz2@illinois.edu>
In-Reply-To: <c2077b8a86c6d82d611007d81ce81d32f718ec59.1602263422.git.yifeifz2@illinois.edu>
Date: Fri, 9 Oct 2020 23:45:00 +0200
Message-ID: <CAG48ez1zQkoFMpFaxnL-xmzdkJZ+KN-CcEnyvB6ZpPCfwb4=bg@mail.gmail.com>
Subject: Re: [PATCH v4 seccomp 5/5] seccomp/cache: Report cache data through
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

On Fri, Oct 9, 2020 at 7:15 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
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
>
> This file is guarded by CONFIG_SECCOMP_CACHE_DEBUG with a default
> of N because I think certain users of seccomp might not want the
> application to know which syscalls are definitely usable. For
> the same reason, it is also guarded by CAP_SYS_ADMIN.
>
> Suggested-by: Jann Horn <jannh@google.com>
> Link: https://lore.kernel.org/lkml/CAG48ez3Ofqp4crXGksLmZY6=fGrF_tWyUCg7PBkAetvbbOPeOA@mail.gmail.com/
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
[...]
> diff --git a/arch/Kconfig b/arch/Kconfig
[...]
> +config SECCOMP_CACHE_DEBUG
> +       bool "Show seccomp filter cache status in /proc/pid/seccomp_cache"
> +       depends on SECCOMP
> +       depends on SECCOMP_FILTER
> +       depends on PROC_FS
> +       help
> +         This is enables /proc/pid/seccomp_cache interface to monitor

nit: s/This is enables/This enables the/

> +         seccomp cache data. The file format is subject to change. Reading
> +         the file requires CAP_SYS_ADMIN.
> +
> +         This option is for debugging only. Enabling present the risk that

nit: *presents

> +         an adversary may be able to infer the seccomp filter logic.

[...]
> +int proc_pid_seccomp_cache(struct seq_file *m, struct pid_namespace *ns,
> +                          struct pid *pid, struct task_struct *task)
> +{
> +       struct seccomp_filter *f;
> +       unsigned long flags;
> +
> +       /*
> +        * We don't want some sandboxed process know what their seccomp

s/know/to know/

> +        * filters consist of.
> +        */
> +       if (!file_ns_capable(m->file, &init_user_ns, CAP_SYS_ADMIN))
> +               return -EACCES;
> +
> +       if (!lock_task_sighand(task, &flags))
> +               return 0;

maybe return -ESRCH here so that userspace can distinguish between an
exiting process and a process with no filters?

> +       f = READ_ONCE(task->seccomp.filter);
> +       if (!f) {
> +               unlock_task_sighand(task, &flags);
> +               return 0;
> +       }
[...]
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
