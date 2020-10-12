Return-Path: <SRS0=82Ss=DT=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99C7CC433DF
	for <containers@archiver.kernel.org>; Mon, 12 Oct 2020 06:50:40 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 24B20206B5
	for <containers@archiver.kernel.org>; Mon, 12 Oct 2020 06:50:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="O+439ox2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24B20206B5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id D0E5085D48;
	Mon, 12 Oct 2020 06:50:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oFvpw78g2JyP; Mon, 12 Oct 2020 06:50:39 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 1D4FB85EA5;
	Mon, 12 Oct 2020 06:50:28 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 057CFC0052;
	Mon, 12 Oct 2020 06:50:28 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 63D4FC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 06:50:27 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 49A2D873A5
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 06:50:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id zrkR+JuqsEHi
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 06:50:24 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f68.google.com (mail-ej1-f68.google.com
 [209.85.218.68])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 34CD087353
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 06:50:24 +0000 (UTC)
Received: by mail-ej1-f68.google.com with SMTP id a3so21586647ejy.11
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 23:50:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=vioP1tNDAwc//TCk7A/UlbXm8YsyMW81aBUSwcUWM5M=;
 b=O+439ox2/Jk704Wg3CCUuHHBA7dCtS4tZf+rbJq812ZTK0+aViDD/HY0/QxPd0NQUF
 ngHa2P6lniSz1x39IKz9kkJx3LLfC44s2/JJskJsdLcsascUYtB8fvFbW2NUKmgYpA5Q
 qL9WLDhxkbA2zZxRNrznWAIqkL2ei6gdtH+l382VbGUXGyDlZfX1JuQlmj8y4p6Pv7Ya
 PCb7RLzFG3YZKtxf36SIr0kXRSp+EPs53UzJcQpDQjjPS1FfrR29JMJjOQ8qQg6Vn8KF
 8bEv0NFsREh+8yHvWjRy47WCNFi88C5LcrjZPuN4J2StRjzSrBdFLJaQj2bNrzV9tws4
 /EJA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=vioP1tNDAwc//TCk7A/UlbXm8YsyMW81aBUSwcUWM5M=;
 b=PoMkuoxrjQzisnFjna2wufX/7ilNBAEytNDVXOL1MUDYjnXz3aTEbPwM9q+RMXAHAS
 xqxfRq89V2yMJD27dY5xcY8x93vXJbVZPe5QM4bW3ObYC403PAe4V9Uk3ykbYqdw7qsc
 VlGxbXC5GB/dP+dxJO5GYnIDpcThKY5V8Klbr2U8j8h5qFcpqd+RbD+7jYNpEgfnfumE
 0f5rW6ZrVvZsvQvAwDz3lhjd5vskN2cDfOXlPOj6QrgmGC+d7y0HzyCMxIqFyuEuUh0K
 Cj5Cis8kOltft7pIEqS4ZbtgaobcQrf2SpTbfsZW7raOrLehLDOvUYwz7UguAbwv+K8+
 PQjQ==
X-Gm-Message-State: AOAM532+bTBPL+3v5FEUVLs7Dw5brexN5jPtvH7ttkLIxUT9KXH4MBlt
 Lflbx7jgrmTqW0wCFs1m2WzFTgz608eeERjfA/Cz3Q==
X-Google-Smtp-Source: ABdhPJzYaWjiwBqQdkgZXF5RmmS6lKqELWb+eu4uskyaPAI9Y5OYW6sBjC5cuQA2JEIpD6mhLt5FrKCkzBDIlZmzlPM=
X-Received: by 2002:a17:906:c0d1:: with SMTP id
 bn17mr15283227ejb.114.1602485422519; 
 Sun, 11 Oct 2020 23:50:22 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1602431034.git.yifeifz2@illinois.edu>
 <4706b0ff81f28b498c9012fd3517fe88319e7c42.1602431034.git.yifeifz2@illinois.edu>
In-Reply-To: <4706b0ff81f28b498c9012fd3517fe88319e7c42.1602431034.git.yifeifz2@illinois.edu>
Date: Mon, 12 Oct 2020 08:49:56 +0200
Message-ID: <CAG48ez2rutKsgpvYeN+TqmhkJe4U7Sxr0oqyrjhUQaePGZg4uA@mail.gmail.com>
Subject: Re: [PATCH v5 seccomp 5/5] seccomp/cache: Report cache data through
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

On Sun, Oct 11, 2020 at 5:48 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
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

Reviewed-by: Jann Horn <jannh@google.com>
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
