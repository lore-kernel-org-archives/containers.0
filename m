Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AFC5C4727C
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 12:06:48 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8250520759
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 12:06:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="E/mNGlIL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8250520759
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 08F8786A4E;
	Thu,  1 Oct 2020 12:06:47 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VfqxAkrTb1pr; Thu,  1 Oct 2020 12:06:45 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id C89B0869FE;
	Thu,  1 Oct 2020 12:06:45 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B9ECDC0889;
	Thu,  1 Oct 2020 12:06:45 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 26BA4C0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 12:06:45 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 0EF4B86BA8
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 12:06:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 94WBLIhsAmYk
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 12:06:44 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f68.google.com (mail-pj1-f68.google.com
 [209.85.216.68])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 53A4586BA6
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 12:06:44 +0000 (UTC)
Received: by mail-pj1-f68.google.com with SMTP id p21so1561469pju.0
 for <containers@lists.linux-foundation.org>;
 Thu, 01 Oct 2020 05:06:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=sV74BIakUvCRx9xcShItHkPBiKSDkVPNapmNdKhM3Fw=;
 b=E/mNGlILRl6AHiL3qGtevUrxp3GXKf9RRaYnjJ56vO+Bw7X/VenWRMl/YHLAQLyXp2
 5tu9fs7q81Pfl9SncMeOSscxQc2DVUSotpGa3RhCZ/APh/Z1aqlZrJaHDitCIK4GO2xr
 VFaPnKjF7s0DG+BR8TRCEuXyfhI76FEq8wzJmCtZkn0Md70rhlLWsK/u1DokcOm/oq96
 sEzmpGaxL5WWn6nMkpgholDXMNy2Gg28eyWrAgnMBHgl0qJne3jpLWDW/QnjxJYGWo/z
 BH3gFJfEntDFHgkwPt50iHZRIwXG/rH0drVrWD2R4ua3ish3KYeERc+D1c+eSoYdvOfc
 yWXw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=sV74BIakUvCRx9xcShItHkPBiKSDkVPNapmNdKhM3Fw=;
 b=rddesUwOQbR3V2GbOV7dqYLFXLwHPggB2I4WKY4QEGWFPM/OnRtcca03NPX/x3jBAU
 V2oWJsp3TcvBNq4EYivHgmHk/ZXz4AOIO3pxZSGcMGaWgXbhvgJFnFv53EUlYRkII3uW
 L2L5GJW6px3dHmnDxZIorqfKshP1Vk8reswqg/DbLSgq3UkviXmXyf1lMHHQixY2ZQlV
 ked7rFY5el3/NZgWa4NAIxvr39N1tS3lKlZL1yayNs8/dLXgvnayLllTX9vZQl6ya81k
 6Gao4jFtjpItq8vrcy3n4d11IX6MY56ZZRf9/suFIwoWmqBgkuBN+RB812FWUYa9BXuW
 Cz3g==
X-Gm-Message-State: AOAM5330obXDAT/Zw02Xqd1idpqACxSz2pGtD779lEJfcFeyNIlF0Smp
 mkFp1X8c1P369WS2Hy6rAS+4gyF5nhx3Pscu2tk=
X-Google-Smtp-Source: ABdhPJxFIrcPL34IzL0lczgzrednTeL9WUedF7XaOVI+sCHu376fT8D6xN93NHnFrJalk3Lnw2G5vzRnU6419m15U8w=
X-Received: by 2002:a17:90a:d495:: with SMTP id
 s21mr6547846pju.1.1601554003886; 
 Thu, 01 Oct 2020 05:06:43 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <d3d1c05ea0be2b192f480ec52ad64bffbb22dc9d.1601478774.git.yifeifz2@illinois.edu>
 <CAG48ez0whaSTobwnoJHW+Eyqg5a8H4JCO-KHrgsuNiEg0qbD3w@mail.gmail.com>
In-Reply-To: <CAG48ez0whaSTobwnoJHW+Eyqg5a8H4JCO-KHrgsuNiEg0qbD3w@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 1 Oct 2020 07:06:32 -0500
Message-ID: <CABqSeATEMTB_hRt9D9teW6GcDvz4VLfMQyvX=nvgR4Uu4+AgoA@mail.gmail.com>
Subject: Re: [PATCH v3 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
To: Jann Horn <jannh@google.com>
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Wed, Sep 30, 2020 at 5:01 PM Jann Horn <jannh@google.com> wrote:
> Hmm, this won't work, because the task could be exiting, and seccomp
> filters are detached in release_task() (using
> seccomp_filter_release()). And at the moment, seccomp_filter_release()
> just locklessly NULLs out the tsk->seccomp.filter pointer and drops
> the reference.
>
> The locking here is kind of gross, but basically I think you can
> change this code to use lock_task_sighand() / unlock_task_sighand()
> (see the other examples in fs/proc/base.c), and bail out if
> lock_task_sighand() returns NULL. And in seccomp_filter_release(), add
> something like this:
>
> /* We are effectively holding the siglock by not having any sighand. */
> WARN_ON(tsk->sighand != NULL);

Ah thanks. I was thinking about how tasks exit and get freed and that
sort of stuff, and how this would race against them. The last time I
worked with procfs there was some magic going on that I could not
figure out, so I was thinking if some magic will stop the task_struct
from being released, considering it's an argument here.

I just looked at release_task and related functions; looks like it
will, at the end, decrease the reference count of the task_struct.
Does procfs increase the refcount while calling the procfs functions?
Hence, in procfs functions one can rely on the task_struct still being
a task_struct, but any direct effects of release_task may happen while
the procfs functions are running?

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
