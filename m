Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0695C43464
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 07:13:24 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4D46C207DE
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 07:13:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Sb2PzeL8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D46C207DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 0D23485F80;
	Mon, 21 Sep 2020 07:13:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 2bSzdc1fIDJs; Mon, 21 Sep 2020 07:13:22 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 288AB85F11;
	Mon, 21 Sep 2020 07:13:17 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0BCCAC0889;
	Mon, 21 Sep 2020 07:13:17 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 56EA3C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 07:13:15 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 33E6E204DB
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 07:13:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id d+H7UD3hqGhk
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 07:13:14 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com
 [209.85.210.193])
 by silver.osuosl.org (Postfix) with ESMTPS id 4A7422035C
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 07:13:14 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id k13so7973692pfg.1
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 00:13:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=27FBm1XqiNw7AjsJuiyEsOatJq+RBJdAk0cH4QyVgm4=;
 b=Sb2PzeL87fShFqdgFltwcSK4VfBnfK8vQiMjV5iIucOhWiIpQYMUAg9Y0N1RO7g46N
 pkAZLXgSET2jjbMXvQXcxC0HFfjpM3zS7SVeZC30SO6LyxTCVyV/81qZgeHO5Gdj4tHb
 TPQTWl162Km/QVcvLA9CK+W6Mw2mAVtJlyI0tfl0z3LwHdnOInQ7cYUDrfkZXoPUp5xy
 gf+RszN2jobN8X1VobBfGU3rdQE/W2A7+HA0v6nZ8GMMrq93VLOnSh3ws8pKkh0hfs4B
 krept19O3AXLiAAaWLstp/1rIZY6rRp70LH++KgsMgtT06rwr3tcxbNdMTfxpueHkO8w
 LX+g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=27FBm1XqiNw7AjsJuiyEsOatJq+RBJdAk0cH4QyVgm4=;
 b=T5h5TZXv0onoZ0QSXCY0Jh5I5BV1bJMnR9fie1tAlEEeqh3YKxDwF0nKg+I0YHFQF+
 K0LC0EToNeCWBjXTNOl9UtIEWk9tTYO7UHoHv3xPVfOTRvqeR10oSPNdewCwFnvIEHFZ
 E5UKsdz5DtXIxCwiCLqB7lq/eim4nnX7R/oNSXreHeZqZRQ+w9+9v92FlU1KUyMA8uB2
 dvDBf8Ys1XgdkIEfIbEbxRK32hktV5jaH+EefBpRtwYNl+X7xkd9qTUuJgLC37LOO9Ct
 +OxEXVqg60RlBEfN4ypfalWeQK8L8LAlO72KuTuD0Qc8IxrGy291US7OXNPNZUCdo+iN
 x5Kg==
X-Gm-Message-State: AOAM533wRWHBKHylJbubA7mSj22iUfX9lo1T+bsMNj5wMywtbwZar23N
 7llfujEfgSlaiTrxiPYayjAC/QKC8werPWDwgeg=
X-Google-Smtp-Source: ABdhPJx+/N9pIhfN+k7kx+mh3otgIu5Pv+X+oYls7sygR7Ne62+c6bLhwKJ5q+1k4h65hQ4roLjKDjpP6874nUbVtWM=
X-Received: by 2002:a17:902:ed4b:b029:d1:cbfc:6382 with SMTP id
 y11-20020a170902ed4bb02900d1cbfc6382mr31898674plb.24.1600672393773; Mon, 21
 Sep 2020 00:13:13 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <CAMp4zn8FPAdDubD=LGmydQvv2PJCeRB-TAeaU92ab4fJAjLnfQ@mail.gmail.com>
In-Reply-To: <CAMp4zn8FPAdDubD=LGmydQvv2PJCeRB-TAeaU92ab4fJAjLnfQ@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Mon, 21 Sep 2020 02:13:02 -0500
Message-ID: <CABqSeASeEX0huy5gudQgFA+gZzEizKXEwUT9xnbdOPTcP6-5vQ@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 0/2] seccomp: Add bitmap cache of
 arg-independent filter results that allow syscalls
To: Sargun Dhillon <sargun@sargun.me>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Kees Cook <keescook@chromium.org>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf@vger.kernel.org,
 Tianyin Xu <tyxu@illinois.edu>
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

On Mon, Sep 21, 2020 at 12:49 AM Sargun Dhillon <sargun@sargun.me> wrote:
>
> On Sun, Sep 20, 2020 at 10:35 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> >
> Long-term, do you believe static analysis will be viable? I think that it is
> the "ideal" solution here, but I agree in that it is more complex.
>
> Is there a way to "prime" filters, by giving them a syscall #, and if it has
> a terminal condition without inspecting args, it turns into a bitmask entry
> viable?

I think in theory one could follow the execution of the filter, and if
the filter is determined to return a pass for a given syscall number
under all circumstances, we record that syscall. We can then replace
the bitmap_zero call in seccomp_cache_check with a call to bitmap_copy
from the pre-primed bitmap. However, I don't know how much benefit
this would provide.

One ugly part of the current situation is that the kernel has
absolutely no idea what arch numbers returned by syscall_get_arch may
be possible for the machine it is running on. For example, for an
x86_64 machine with IA32 emulation, the arch number can be either
AUDIT_ARCH_I386 or AUDIT_ARCH_X86_64. The seccomp filter will
typically have parts handling both cases. As a result, an uncertainty
for one syscall on one arch will affect the syscall under the same
number for the other arch. If a syscall number is not guaranteed to be
allowed under both arches, it won't be primed. Given that usually a
seccomp filter is a list of allowed syscalls, my guess is that there
won't be many syscalls numbers that will fall under this case; though,
I have not tested this.

We could add an array of possible arch numbers so that the emulator
can refine its tracing. This is probably the best in effort, though,
seccomp_cache_prepare now has to iterate through all combinations of
syscall numbers and arch numbers. Given that seccomp_cache_prepare
should be relatively cold it's probably not too much of a trouble.
Alternatively, we could employ constraint tracking, but that sounds
overly complex for what we are trying to do.

The other question would be, would pre-priming the cache be worth the
effort? The assumption is that the vast majority of cacheable syscalls
will be permitted. For them, only the first time a particular syscall
is invoked would experience the overhead of calling the filter, which
means that this part of the initial run we are going to optimize out
by pre-priming is going to be relatively cold. wdyt?

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
