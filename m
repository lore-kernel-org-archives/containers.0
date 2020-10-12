Return-Path: <SRS0=82Ss=DT=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 564C3C433DF
	for <containers@archiver.kernel.org>; Mon, 12 Oct 2020 06:46:47 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AF9CA206FB
	for <containers@archiver.kernel.org>; Mon, 12 Oct 2020 06:46:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="TeTWSCEs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF9CA206FB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 4146B87147;
	Mon, 12 Oct 2020 06:46:46 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id a49cI6ZS1i2a; Mon, 12 Oct 2020 06:46:45 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 2EE9C87136;
	Mon, 12 Oct 2020 06:46:45 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0FF36C0052;
	Mon, 12 Oct 2020 06:46:45 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 2AF5DC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 06:46:44 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 14B19204FC
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 06:46:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id HTQrCiqXmQrj
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 06:46:43 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com
 [209.85.208.66])
 by silver.osuosl.org (Postfix) with ESMTPS id 30605204E1
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 06:46:43 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id t21so15736594eds.6
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 23:46:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=0oV/+pj7Fnm5nZaRHqpOkjT78UAULW7d63AGoeM3lX8=;
 b=TeTWSCEsBYqyE/x1ZaeOkH0jWJEzqZ7ade7Tm1kFTgH31HzCcN0hNCHh62tJU51HXo
 oT1/7SjvVBjHHxKmo/6ioy411q0Lew2Z791SIXZMxKBXgleoTXwKqXOyNNnLsGMHo9d0
 +cTV7LNmhJPh1s7mUi2rqebsCXVI4yUVkSL/drzsPeODDm3sQVnnb5dbXYyhw3hhx/wm
 iS3jYetCXUTdyqg4zYSARhPFq28CXyB+zKkODklGDX6GJO4KkCIAFinOTcE+cmXsNi6Q
 4vs8+0YDkbjqMfOplYJWskfn3CRqo227oSBgHHSaMH6yj8m+JXb+qAeT40KP8PiAX0mW
 HpOw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=0oV/+pj7Fnm5nZaRHqpOkjT78UAULW7d63AGoeM3lX8=;
 b=Svmji3oqIv6GWUyRkcOPnhpQfKQteI45FqTA0sNTvvNJzp6whUxsarti0Z8n3pt0Lv
 IntCC8R8n11Mg3iHEYaZl9ZG/FhqybowB4WKolYeyFK08e1QXxmzBVUKKZYJsIegnxZ5
 7HapoREyYkI5ckzI9f543zHoFB0RriCv1W1T5MoDUC79fqEcAm8chlBm11DAMdMq0rrw
 mHQGWRpUJPXvG+a+lo0hMSldTCXI/hC+JWw7W6MspptJ+R9+fR5QEoKyuVeLE2KC7Idd
 iumqKwzxMddDiypMkJHE7vXSJbpdscRtKCAv76RhVZ/GG2K4Ur98tVuItjz0dV/2Tu2j
 /pUA==
X-Gm-Message-State: AOAM530Mm/PiAJvsKozpQesEa1OOjc71ZIhL+Nh+8fZJQjRCnaS0MvhA
 caChoCPVpB04EdZb6CSisROci4Q2lNKQLgGCrnbty3dlMDA=
X-Google-Smtp-Source: ABdhPJwAYFpyF8+D8cV7oXd3QE1aJOiN6i4bqWNX+WYEUPOZPTqnJ6SQkcBzssolp/os/9ZENLm83qg/oBxbASgSqn4=
X-Received: by 2002:aa7:d349:: with SMTP id m9mr12421814edr.51.1602485201449; 
 Sun, 11 Oct 2020 23:46:41 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1602431034.git.yifeifz2@illinois.edu>
 <71c7be2db5ee08905f41c3be5c1ad6e2601ce88f.1602431034.git.yifeifz2@illinois.edu>
In-Reply-To: <71c7be2db5ee08905f41c3be5c1ad6e2601ce88f.1602431034.git.yifeifz2@illinois.edu>
Date: Mon, 12 Oct 2020 08:46:15 +0200
Message-ID: <CAG48ez0waTA3+Bs9UWx4HSx3Pktq-6K-z67hmcTV0Fr-NYGdMw@mail.gmail.com>
Subject: Re: [PATCH v5 seccomp 2/5] seccomp/cache: Add "emulator" to check if
 filter is constant allow
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
> SECCOMP_CACHE will only operate on syscalls that do not access
> any syscall arguments or instruction pointer. To facilitate
> this we need a static analyser to know whether a filter will
> return allow regardless of syscall arguments for a given
> architecture number / syscall number pair. This is implemented
> here with a pseudo-emulator, and stored in a per-filter bitmap.
>
> In order to build this bitmap at filter attach time, each filter is
> emulated for every syscall (under each possible architecture), and
> checked for any accesses of struct seccomp_data that are not the "arch"
> nor "nr" (syscall) members. If only "arch" and "nr" are examined, and
> the program returns allow, then we can be sure that the filter must
> return allow independent from syscall arguments.
>
> Nearly all seccomp filters are built from these cBPF instructions:
>
> BPF_LD  | BPF_W    | BPF_ABS
> BPF_JMP | BPF_JEQ  | BPF_K
> BPF_JMP | BPF_JGE  | BPF_K
> BPF_JMP | BPF_JGT  | BPF_K
> BPF_JMP | BPF_JSET | BPF_K
> BPF_JMP | BPF_JA
> BPF_RET | BPF_K
> BPF_ALU | BPF_AND  | BPF_K
>
> Each of these instructions are emulated. Any weirdness or loading
> from a syscall argument will cause the emulator to bail.
>
> The emulation is also halted if it reaches a return. In that case,
> if it returns an SECCOMP_RET_ALLOW, the syscall is marked as good.
>
> Emulator structure and comments are from Kees [1] and Jann [2].
>
> Emulation is done at attach time. If a filter depends on more
> filters, and if the dependee does not guarantee to allow the
> syscall, then we skip the emulation of this syscall.
>
> [1] https://lore.kernel.org/lkml/20200923232923.3142503-5-keescook@chromium.org/
> [2] https://lore.kernel.org/lkml/CAG48ez1p=dR_2ikKq=xVxkoGg0fYpTBpkhJSv1w-6BG=76PAvw@mail.gmail.com/
>
> Suggested-by: Jann Horn <jannh@google.com>
> Co-developed-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>

Reviewed-by: Jann Horn <jannh@google.com>
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
