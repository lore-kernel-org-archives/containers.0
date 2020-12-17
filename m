Return-Path: <SRS0=jS4c=FV=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EDEAC4361B
	for <containers@archiver.kernel.org>; Thu, 17 Dec 2020 18:34:59 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2245F2389F
	for <containers@archiver.kernel.org>; Thu, 17 Dec 2020 18:34:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2245F2389F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id B241987AA8;
	Thu, 17 Dec 2020 18:34:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id CTFZEMK-fxUz; Thu, 17 Dec 2020 18:34:56 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id C653587AA0;
	Thu, 17 Dec 2020 18:34:56 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id AC842C0893;
	Thu, 17 Dec 2020 18:34:56 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id DD319C013B
 for <containers@lists.linux-foundation.org>;
 Thu, 17 Dec 2020 18:34:54 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id C75F58768B
 for <containers@lists.linux-foundation.org>;
 Thu, 17 Dec 2020 18:34:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id K+w-o5QDxtSx
 for <containers@lists.linux-foundation.org>;
 Thu, 17 Dec 2020 18:34:50 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f49.google.com (mail-pj1-f49.google.com
 [209.85.216.49])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 80B2F873FE
 for <containers@lists.linux-foundation.org>;
 Thu, 17 Dec 2020 18:34:50 +0000 (UTC)
Received: by mail-pj1-f49.google.com with SMTP id z12so4118665pjn.1
 for <containers@lists.linux-foundation.org>;
 Thu, 17 Dec 2020 10:34:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=im+tZE/kWm/ZYSPYhJ4SO9Qym9+PRjpn700kp4DBAS8=;
 b=FQzovURv8bA6Lx3cQIIXpJewCy4TM5boS6zU16dq/LKS3boHJ4pUrZApa66UZzb/+c
 RpT2UlDCXIaqUTTBnin9bzjgxz4HrIkSj97aiBbvJKVnHxZ0Oo3YwkJ3AxPNs7uLB3WE
 JAREWoaAiCNffkYS9FPXb6ATVq0H8eUa/AQ1UKztU75+MN0V/O0l+JB1AgiadqzujsgL
 tzPsT0upVO9DuFoM7lrsOoQ7jbVdb/4hzOfnymU3D3NrachozPpPW9OLL3ec/IuBIw2X
 7eIGg20lBao9pO9kDnSL2pMaAQYyw+vwjzt3AhfD8+9+kEYz2ogPFaH+qX5N+moHaDT4
 g5OQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=im+tZE/kWm/ZYSPYhJ4SO9Qym9+PRjpn700kp4DBAS8=;
 b=M8+gitcavgtvw1JvJl9geE4SYaOdx1hg/8JrIVZulBa9YHXpjPKe8aAuJ3wLNh0Ux1
 vdidQHu+8Ne1npPp8pXRuJJF2ZlfXe1m+eJJ0E2ezrATOoSLptKJfqLvT6Mvq97cKnYa
 coV2qAEKYjHlFHBe8dXMQNPDQ+/qTs5h2udtghFQZfLU8/N6iaVWpzRY7KacGkEgPczL
 NzhNHnyQDIWUPMJXw0DjD5Kdz9N7SFvLPQX4jyFaX5k5WXYOqgmE8df8RT8ZTJXxQZbo
 Yv1Toi0LfClYYM8xRqS7PMZG2fnnIxo5Y7pv6/66hU5bk5acvOsPuuZHtfvjkUFlsZNK
 YFUg==
X-Gm-Message-State: AOAM531//TqBTn7hcpQ1fObidiEE1rNhUQvh0ZtnsByUnAVrN7aUStGl
 Z8dvDpBiuopzsxFqMIHS7yYCQyF8rerUP9eJr6U=
X-Google-Smtp-Source: ABdhPJwOSQIe23TJljX/SbIcNXl50XKjszrEFNraiEVK67gWjnJ97PCFnGYsDQ/8nukeG47lVxPUC1QJ2b/ituOwIjs=
X-Received: by 2002:a17:90a:3cc6:: with SMTP id
 k6mr494700pjd.204.1608230090020; 
 Thu, 17 Dec 2020 10:34:50 -0800 (PST)
MIME-Version: 1.0
References: <cover.1602431034.git.yifeifz2@illinois.edu>
 <4706b0ff81f28b498c9012fd3517fe88319e7c42.1602431034.git.yifeifz2@illinois.edu>
 <CAMuHMdVU1BhmwMiHKDYmnyRHtQfeMtwtwkFLQwinfBPto-rtOQ@mail.gmail.com>
In-Reply-To: <CAMuHMdVU1BhmwMiHKDYmnyRHtQfeMtwtwkFLQwinfBPto-rtOQ@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 17 Dec 2020 12:34:39 -0600
Message-ID: <CABqSeARw2tcxEPiU4peuURZybVsFo5K+OkAK0ojADUEENMoKuA@mail.gmail.com>
Subject: Re: [PATCH v5 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Aleksa Sarai <cyphar@cyphar.com>, David Laight <David.Laight@aculab.com>,
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

On Thu, Dec 17, 2020 at 6:14 AM Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> Should there be a dependency on SECCOMP_ARCH_NATIVE?
> Should all architectures that implement seccomp have this?
>
> E.g. mips does select HAVE_ARCH_SECCOMP_FILTER, but doesn't
> have SECCOMP_ARCH_NATIVE?
>
> (noticed with preliminary out-of-tree seccomp implementation for m68k,
>  which doesn't have SECCOMP_ARCH_NATIVE

Hi Geert

You are correct. This specific patch in this series was not applied,
and this was addressed in a follow up patch series [1]. MIPS does not
define SECCOMP_ARCH_NATIVE because the bitmap expects syscall numbers
to start from 0, whereas MIPS does not (defines
CONFIG_HAVE_SPARSE_SYSCALL_NR). The follow up patch makes it so that
any arch with HAVE_SPARSE_SYSCALL_NR (currently just MIPS) cannot have
CONFIG_SECCOMP_CACHE_DEBUG on, by the depend on clause.

I see that you are doing an out of tree seccomp implementation for
m68k. Assuming unchanged arch/xtensa/include/asm/syscall.h, something
like this to arch/m68k/include/asm/seccomp.h should make it work:

#define SECCOMP_ARCH_NATIVE        AUDIT_ARCH_M68K
#define SECCOMP_ARCH_NATIVE_NR        NR_syscalls
#define SECCOMP_ARCH_NATIVE_NAME    "m68k"

If the file does not exist already, arch/xtensa/include/asm/seccomp.h
is a good example of how the file should look like, and remember to
remove `generic-y += seccomp.h` from arch/m68k/include/asm/Kbuild.

[1] https://lore.kernel.org/lkml/cover.1605101222.git.yifeifz2@illinois.edu/T/

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
