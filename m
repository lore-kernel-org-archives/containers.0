Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81F5DC2D0E2
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 14:17:04 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CB77322208
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 14:17:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SJimvUVK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB77322208
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 113BF86ABB;
	Thu, 24 Sep 2020 14:17:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 31NKKx8Y8Iq5; Thu, 24 Sep 2020 14:17:02 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 074DE868FB;
	Thu, 24 Sep 2020 14:17:02 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E1AF5C0859;
	Thu, 24 Sep 2020 14:17:01 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 68AE1C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:17:01 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 5E6E18700E
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:17:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id CFuT2tGWPYeP
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:17:00 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f196.google.com (mail-pl1-f196.google.com
 [209.85.214.196])
 by hemlock.osuosl.org (Postfix) with ESMTPS id E609E86FED
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 14:17:00 +0000 (UTC)
Received: by mail-pl1-f196.google.com with SMTP id f1so1722011plo.13
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:17:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=EATK8UYhF6QjpQ7ze5Yh7cYtMGpiiPgRYaZZWNM3PGw=;
 b=SJimvUVKP3YEpu5dbZp6nclj4PoP4GI+5FVjQ8crLl6qV9jI/jhWrK0lfimZtmOx6+
 mL4TiT24Ma+WYUyPm+d9i/NzLQTlpIIkM91dkJRza3wdWcUvcX5mO2ztLegu+Faz13bd
 aiYvSWKry4Go4mqNuA5xJHEhFAaeXzsmB0kYAg5AATlP8PnkJGbZCsxUOcfc4AYJt66h
 O7ToiK+nkRI+ZdMGXj7ytt9vV2U+R6zRBE/aCMP6VGIVfFUpwaCm65KWSw2OLULeAsLM
 2kBAw7c0HTRDuFAeQTVSMTpwMKMuvLnTsAN+qr4gGxfCU2iIa4w6Befzl0JtV/W8B7ks
 geOw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=EATK8UYhF6QjpQ7ze5Yh7cYtMGpiiPgRYaZZWNM3PGw=;
 b=TyGnw3uUdCuJqpWuW3T6gmfLGwmm4zTCNzxvgXqRqSIfdvXN76J7YrTN02BszJHy+2
 DO3lTaAAaA+6LJuV/qfWO0vuKlcrGGDJrX40vPzrwo3XB380iIxXEkhcNSVMrjcqj5gG
 DuuYMBExgtDeStjwVljx5FqAlMg65IcpGtpdqeEA5UxaZapkVg7REbtl3xk5UFY7r8u+
 CJxdfsnJp/agVsnc94KKWOkqPGPvgB+AA7WuyP3kuoTwrSiOLh9F1A4q8Kpt1rIPhsPo
 nixC5Wo0ygUZucBMDPlRjFkStSEc14oENJGJYZK2pyCSpBTuVISsEvVFj6C9jbbS8IaP
 YeeQ==
X-Gm-Message-State: AOAM533PZgV5a5zonbwEGpUo04q/52FRdvAiskKvnGgzeVvXdJiepn5g
 T0VYdknq4Rs2Ab3wz1BebZfgEwsghyUBaVY20bI=
X-Google-Smtp-Source: ABdhPJze9G2qwEgOsJcOLC/ZCpO1uGYoNBkKLhCAFaz0fKNffXetdfSN0Vxop7ofH0HuYNasmu+o57YdIiwKDNMuHvs=
X-Received: by 2002:a17:90b:3252:: with SMTP id
 jy18mr4034944pjb.1.1600957020491; 
 Thu, 24 Sep 2020 07:17:00 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <20bbc8ed4b9f2c83d0f67f37955eb2d789268525.1600951211.git.yifeifz2@illinois.edu>
 <7042ba3307b34ce3b95e5fede823514e@AcuMS.aculab.com>
In-Reply-To: <7042ba3307b34ce3b95e5fede823514e@AcuMS.aculab.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 24 Sep 2020 09:16:48 -0500
Message-ID: <CABqSeASWf_CArdOzASLeRBPZQ-S_vtinhZLteYng4iAof4py+w@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 2/6] asm/syscall.h: Add syscall_arches[] array
To: David Laight <David.Laight@aculab.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 "containers@lists.linux-foundation.org"
 <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 "bpf@vger.kernel.org" <bpf@vger.kernel.org>, Tianyin Xu <tyxu@illinois.edu>
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

On Thu, Sep 24, 2020 at 8:47 AM David Laight <David.Laight@aculab.com> wrote:
> I doubt the compiler will do what you want.
> Looking at it, in most cases there are one or two entries.
> I think only MIPS has three.

It does ;) GCC 10.2.0:

$ objdump -d kernel/seccomp.o | less
[...]
0000000000001520 <__seccomp_filter>:
[...]
    1587:       41 8b 54 24 04          mov    0x4(%r12),%edx
    158c:       b9 08 01 00 00          mov    $0x108,%ecx
    1591:       81 fa 3e 00 00 c0       cmp    $0xc000003e,%edx
    1597:       75 2e                   jne    15c7 <__seccomp_filter+0xa7>
[...]
    15c7:       81 fa 03 00 00 40       cmp    $0x40000003,%edx
    15cd:       b9 40 01 00 00          mov    $0x140,%ecx
    15d2:       74 c5                   je     1599 <__seccomp_filter+0x79>
    15d4:       0f 0b                   ud2
[...]
0000000000001cb0 <seccomp_cache_prepare>:
[...]
    1cc4:       41 b9 3e 00 00 c0       mov    $0xc000003e,%r9d
[...]
    1dba:       41 b9 03 00 00 40       mov    $0x40000003,%r9d
[...]
0000000000002e30 <proc_pid_seccomp_cache>:
[...]
    2e72:       ba 3e 00 00 c0          mov    $0xc000003e,%edx
[...]
    2eb5:       ba 03 00 00 40          mov    $0x40000003,%edx

Granted, I have CC_OPTIMIZE_FOR_PERFORMANCE rather than
CC_OPTIMIZE_FOR_SIZE, but this patch itself is trying to sacrifice
some of the memory for speed.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
