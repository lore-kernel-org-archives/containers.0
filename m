Return-Path: <SRS0=KLId=EK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C33CC2D0A3
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 11:48:39 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B27782071A
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 11:48:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZdFcNNsE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B27782071A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 0F5B9874CF;
	Wed,  4 Nov 2020 11:48:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jxslBL8ajxk3; Wed,  4 Nov 2020 11:48:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 5ECF2874BC;
	Wed,  4 Nov 2020 11:48:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3BF2DC0889;
	Wed,  4 Nov 2020 11:48:37 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id CD728C0051
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 11:48:35 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id C48B986AED
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 11:48:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Vzttv8UtNrU4
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 11:48:35 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com
 [209.85.214.194])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 23F45869C4
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 11:48:35 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id g11so3670421pll.13
 for <containers@lists.linux-foundation.org>;
 Wed, 04 Nov 2020 03:48:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=7IzbM9m4aaHXdrXJm05MLSazuYENXBo0KE7aGRSwMEM=;
 b=ZdFcNNsEPd+MrYWXHoLvBaTyKHUZhwFwZu3J/PQqzp5Y/s91VRqgtwgRqnPdnsJFzV
 u8ndi/4ac74yeUDpbQr7HXPlEJnbasb7cO8o7gJ5QfnXfnqvT0IrHsEaICKEwxEa70A2
 YXFhqPLDhnbJkNUfiRkcSqJ8rcr7T7iBd7vGmo4WjMykCP58kLBQOzps+/fitCtmG7lx
 rqQXdb82DTVqzyozftIz+18xHfX9wm2lvzWUKmKLYyJ3imRpyuFKCfkdabT8dbUsAWYG
 nv0yauU0g8FHPsO317oAA4Yrr0jRGmrdqn85extqA7+6MeHG+mc31wlEfpFhQQxxW9Z6
 hBNQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=7IzbM9m4aaHXdrXJm05MLSazuYENXBo0KE7aGRSwMEM=;
 b=azt0N6y1WNl43Gejp4Km7K1BKA6djw1pTaW3h91zt1zsGKm0M0bzuoZhiffWOlHl+W
 mhhW8JCBv63AEYSyrwgfLz73dHok7XLaAfnsmIpTq7xDh0jGssFf39M7R8SjBwluyA4J
 tSy78YO5FuPLM945W5DgPT9r8VhNO/isJt6N5Z96i0+wMwnehFFtSXKSbuhuDqt4FsZc
 Qfm6L908t29Fu4a18cktpSApHT1anFR4dN/9Xr+yeU8LXhq05lg5CIT5cOk+aWOMqfsH
 DA8+E84TE/loIItC2gSB2vHR85R0EKzVJbVd/UqR3Zk6RsRve2PWI8gUIJeqotjqDgZt
 hqQw==
X-Gm-Message-State: AOAM532yazrIKP8NbiyVTxYcKyRUoTWZMK8PLSCpNBZj/tei52sggOZD
 Xt3bwt28UqAVNITE8+bvGuT/LMfBSH5AYqR8vWA=
X-Google-Smtp-Source: ABdhPJwhKGHgOtsgYmsX8K8geLNyRT+0OoRlLf1+UEBmK6aJHTGU8p2K0A8JMelevcl7yJOdhQWuD2QnmsGaSXA3des=
X-Received: by 2002:a17:902:d30c:b029:d6:8208:bb1 with SMTP id
 b12-20020a170902d30cb02900d682080bb1mr29348288plc.44.1604490514732; Wed, 04
 Nov 2020 03:48:34 -0800 (PST)
MIME-Version: 1.0
References: <cover.1604410035.git.yifeifz2@illinois.edu>
 <4ec2970fcc819eb4d5dac2bd35233ccdadfda845.1604410035.git.yifeifz2@illinois.edu>
 <87wnz1to9n.fsf@mpe.ellerman.id.au>
In-Reply-To: <87wnz1to9n.fsf@mpe.ellerman.id.au>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Wed, 4 Nov 2020 05:48:21 -0600
Message-ID: <CABqSeAQ+3sjLXH7GVt_tZrFT_e0nNMm8QgT+FBNQYSOc8viM=A@mail.gmail.com>
Subject: Re: [PATCH seccomp 3/8] powerpc: Enable seccomp architecture tracking
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-sh@vger.kernel.org, Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
 linux-riscv@lists.infradead.org, Andrea Arcangeli <aarcange@redhat.com>,
 linux-s390@vger.kernel.org, YiFei Zhu <yifeifz2@illinois.edu>,
 linux-csky@vger.kernel.org, Tianyin Xu <tyxu@illinois.edu>,
 linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, Valentin Rothberg <vrothber@redhat.com>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 linux-parisc@vger.kernel.org,
 Linux Containers <containers@lists.linux-foundation.org>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 David Laight <David.Laight@aculab.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, linuxppc-dev@lists.ozlabs.org
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

On Wed, Nov 4, 2020 at 4:22 AM Michael Ellerman <mpe@ellerman.id.au> wrote:
> > +#ifdef __LITTLE_ENDIAN__
>
> As Kees mentioned this should (must?!) match the configured endian.
>
> But I think it would still be better to use the CONFIG symbol, which is
> CONFIG_CPU_LITTLE_ENDIAN.

My attempt here is to be consistent with asm/syscall.h
syscall_get_arch [1]. Would it make sense to change that to
CONFIG_CPU_LITTLE_ENDIAN then?

[1] https://elixir.bootlin.com/linux/latest/source/arch/powerpc/include/asm/syscall.h#L116

> > +# define SECCOMP_ARCH_NATIVE         (AUDIT_ARCH_PPC64 | __SECCOMP_ARCH_LE)
>
> You use __SECCOMP_ARCH_LE there, but previously you only defined
> __SECCOMP_ARCH_LE_BIT.
>
> Is there some magic somewhere that defines __SECCOMP_ARCH_LE based on
> __SECCOMP_ARCH_LE_BIT ?

Oops, my bad here.

> > +# define SECCOMP_ARCH_NATIVE_NR              NR_syscalls
> > +# define SECCOMP_ARCH_NATIVE_NAME    "ppc64"
>
> What's the name used for?

This is used in the last patch in this series to report in procfs the
name of each architecture tracked by the bitmap cache.

> Usually we use "ppc64" for 64-bit big endian and "ppc64le" for 64-bit
> little endian.
>
> And usually we use "ppc" for 32-bit.

Ok.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
