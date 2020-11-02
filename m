Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42BBBC00A89
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 17:10:41 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A96F92071A
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 17:10:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="HjoXjBTh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A96F92071A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 547668738A;
	Mon,  2 Nov 2020 17:10:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id o96rouvCJtEX; Mon,  2 Nov 2020 17:10:38 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 505AB872F6;
	Mon,  2 Nov 2020 17:10:38 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4122CC0889;
	Mon,  2 Nov 2020 17:10:38 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id CEE5CC0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:10:36 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id A8669204A8
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:10:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 8t-GI4zoGTPF
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:10:35 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f65.google.com (mail-lf1-f65.google.com
 [209.85.167.65])
 by silver.osuosl.org (Postfix) with ESMTPS id 7B179203DB
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:10:35 +0000 (UTC)
Received: by mail-lf1-f65.google.com with SMTP id h6so18392546lfj.3
 for <containers@lists.linux-foundation.org>;
 Mon, 02 Nov 2020 09:10:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=iUhgKcjbc2s2EhhIkvemuRNHWDak5R9RJ9CGVBXgZ48=;
 b=HjoXjBTh/qMKF+PBX2unf6tg/4usdIKMSKAIxixFWbuZHeBxEiGMSat4Zh8HZSatkD
 yh34u2mi6GUPgEYC6XkEPYo9Jg3f2gJXkUFr9G4Vvun79vVX68OERc5TLzSyunRKdFDX
 dXic1qzf0FZGzvOWnm+oao39D40nWO8SbcQW9xGmSduixw6yzJAAWRiiCCgacbUftFDg
 CO3ynoaxLyFgWKeEvUBTvyhNfWfeINFsEGF0BpEt24j21pUMQmdXQoisKd5Nrev316TT
 QVVxu63+MfITJp0rNMsvdZHkgJ6zrk7DolMLGWJcPuz9HNC5O73afCtEwXRLxA/Cvp9z
 P+HQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=iUhgKcjbc2s2EhhIkvemuRNHWDak5R9RJ9CGVBXgZ48=;
 b=mIxaSYHq3JNgsXFRBr47zpms5GZR7zIwwp7CLnyRb6BSA4bhVpo3RBoZXuVf6ucL2J
 XHUlSbnmleO7cpJ4pgbZcLNMs7Mo/bdDJ2UaNcmmzAKavMlHQBpYzyUy685+0pAKz3S5
 2FdsrxyoO31BDjnQWF8aRkbOgv/ytlmD4zOf90G4MVBvgYvGJGZSF2I2RyYr/rh6JZJo
 uMWAwXIksTMnRwUPX4pRa2rTucS/zmVkH1nqKSFm5NFPghtKqeOs6+Riekwy6IcNbxgo
 P54PJ+EEKcNDScnpqOeSa+9oVVcKOO+qYriK//TDFjHO/vqEzZ/GGgk+4kZIErNQXtAe
 5I8g==
X-Gm-Message-State: AOAM533DsCx7GUyIQxUdQYzq1ZLCPfEFiah7sx/SwYcodZUTR921g0pA
 kKGCrVDcAnE9zt5FrldYiseMydN7ixGMiiy/sm140A==
X-Google-Smtp-Source: ABdhPJxkJnEbvYM5/968FpfLPAantffeO/sBABvh2n53Wp/IAlVp7pFGbWZ1wReq9yCdHL8ATpXRmVFjRmjODYdsmhc=
X-Received: by 2002:a19:c357:: with SMTP id t84mr5636062lff.34.1604337033294; 
 Mon, 02 Nov 2020 09:10:33 -0800 (PST)
MIME-Version: 1.0
References: <cover.1604335819.git.gladkov.alexey@gmail.com>
 <2718f7b13189dfd159414efb68e3533552593140.1604335819.git.gladkov.alexey@gmail.com>
In-Reply-To: <2718f7b13189dfd159414efb68e3533552593140.1604335819.git.gladkov.alexey@gmail.com>
Date: Mon, 2 Nov 2020 18:10:06 +0100
Message-ID: <CAG48ez0zGoB4Pr_+nLKaycCgEUtUrAvLJ89JG1ZbcbjKChMcng@mail.gmail.com>
Subject: Re: [RFC PATCH v1 4/4] Allow to change the user namespace in which
 user rlimits are counted
To: Alexey Gladkov <gladkov.alexey@gmail.com>
Cc: Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Alexey Gladkov <legion@kernel.org>, Christian Brauner <christian@brauner.io>
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

On Mon, Nov 2, 2020 at 5:52 PM Alexey Gladkov <gladkov.alexey@gmail.com> wrote:
> Add a new prctl to change the user namespace in which the process
> counter is located. A pointer to the user namespace is in cred struct
> to be inherited by all child processes.
[...]
> +       case PR_SET_RLIMIT_USER_NAMESPACE:
> +               if (!capable(CAP_SYS_RESOURCE))
> +                       return -EPERM;
> +
> +               switch (arg2) {
> +               case PR_RLIMIT_BIND_GLOBAL_USERNS:
> +                       error = set_rlimit_ns(&init_user_ns);
> +                       break;
> +               case PR_RLIMIT_BIND_CURRENT_USERNS:
> +                       error = set_rlimit_ns(current_user_ns());
> +                       break;
> +               default:
> +                       error = -EINVAL;
> +               }
> +               break;

I don't see how this can work. capable() requires that
current_user_ns()==&init_user_ns, so you can't use this API to bind
rlimits to any other user namespace.

Fundamentally, if it requires CAP_SYS_RESOURCE, this probably can't be
done as an API that a process uses to change its own rlimit scope. In
that case I would implement this as part of clone3() instead of
prctl(). (Then init_user_ns can set it if the caller has
CAP_SYS_RESOURCE. If you want to have support for doing the same thing
with nested namespaces, you'd also need a flag that the first-level
clone3() can set on the namespace to say "further rlimit splitting
should be allowed".)

Or alternatively, we could say that CAP_SYS_RESOURCE doesn't matter,
and instead you're allowed to move the rlimit scope if your current
hard rlimit is INFINITY. That might make more sense? Maybe?
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
