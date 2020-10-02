Return-Path: <SRS0=Hw3E=DJ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0A23C4363D
	for <containers@archiver.kernel.org>; Fri,  2 Oct 2020 11:08:27 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1D139206B8
	for <containers@archiver.kernel.org>; Fri,  2 Oct 2020 11:08:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ScLOAE5w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D139206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id E680386469;
	Fri,  2 Oct 2020 11:08:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ULqqvCxjfwDd; Fri,  2 Oct 2020 11:08:24 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 29DBB86403;
	Fri,  2 Oct 2020 11:08:24 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 1F502C016F;
	Fri,  2 Oct 2020 11:08:24 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 78408C0051
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Oct 2020 11:08:23 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 655A78723B
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Oct 2020 11:08:23 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id icTqH5xt2PJF
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Oct 2020 11:08:20 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f65.google.com (mail-pj1-f65.google.com
 [209.85.216.65])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 6FC7F87186
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Oct 2020 11:08:20 +0000 (UTC)
Received: by mail-pj1-f65.google.com with SMTP id l18so607223pjz.1
 for <containers@lists.linux-foundation.org>;
 Fri, 02 Oct 2020 04:08:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=TN/noH5vH9CkLLRAplsfECRDqMRnriPBEN1mLBkYoFM=;
 b=ScLOAE5wHKEY7mteqyA6ZIBlmVDJetG7nJWSSSPBAU2hYneqKoMVmzDM7Y6C2FOJFC
 bVXwCvizsRXxVjJ3o9QeFLOXgQb9xBRbNhIBTOIlHjM11ZTits1nOl71bepZgW2l7/nB
 onGNyYsHyu1koUAYJaJgdyFzE/w8mBeCBRfqqQxzSZr47RXQ1PZEE2O6OklclfaUOyuv
 lsowFxvMomqeCCYpQL1LMgZDZsKWbetDQOG6qaGXSkIEFYuGVvy6B/9VU7tzkh9aO0yY
 BWFwV4yKavUOGH0R24IS5/Lovne7FPCWleQLZ3iQ7IivB3S4p4ZMFRkida2di5K2/HCl
 PB1g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=TN/noH5vH9CkLLRAplsfECRDqMRnriPBEN1mLBkYoFM=;
 b=HwnfHUd7t85z5TYTO+eN4yS3gc6ApmRXnJH1bxcii+R/kjd7soh7TJuIp7A2ERTIsE
 lWISF4veaPeTHd4vSYcIFm6m+lWeWbGwgkUxXISjcR3qKQQXpLC7ABlHKEpLdck3Y9nm
 bvk5ifoJzB0Rz53V34HXHnihdM0j37dvYyqe2R1fYIccC9thVjUjCVNA1aAOiuTMnxwF
 XUlbs+Zvs8/uKEgMUlrV0GLjXF6p8eihUhEsItUOJ24RMgYQdyDGwpWJGQKAbIkKr3EE
 1sdRhsieI5msA+SMbiNyV2nSN4bjrNZs1IGpMxkqirqa7Bcfa1hheSjCSxuSFeJoDag0
 go1w==
X-Gm-Message-State: AOAM533UKt8hm215MoLcz3ZR/742oLpjZSN7I7WFkWP7SeGX8+z63vn/
 c3H2uIz7CuCPKjz67qu/3lfkRzLM6oUmQ7ilyVE=
X-Google-Smtp-Source: ABdhPJwp9DY3a5VFCCxDN4ubn5YX34qjNqjm6nq5KsA56YZfWWkqfLoWTESqEVHF6+xId3COLUqvBoz7OzmOiK8Orvg=
X-Received: by 2002:a17:90a:f184:: with SMTP id
 bv4mr2131882pjb.1.1601636900031; 
 Fri, 02 Oct 2020 04:08:20 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <b16456e8dbc378c41b73c00c56854a3c30580833.1601478774.git.yifeifz2@illinois.edu>
 <202009301432.C862BBC4B@keescook>
 <CABqSeATqYuEAb=i1nxufbVQUWRw6FDbb9x0DYJz87U0RbQj14A@mail.gmail.com>
 <202010011314.503D67209@keescook>
In-Reply-To: <202010011314.503D67209@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Fri, 2 Oct 2020 06:08:08 -0500
Message-ID: <CABqSeASuuJcY_tAA5hskRaZ-3y8cA-zCpVJvOue8Uv+3jM9NDw@mail.gmail.com>
Subject: Re: [PATCH v3 seccomp 2/5] seccomp/cache: Add "emulator" to check if
 filter is constant allow
To: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
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

On Thu, Oct 1, 2020 at 4:05 PM Kees Cook <keescook@chromium.org> wrote:
> Right, but we depend on that test always doing the correct thing (and
> continuing to do so into the future). I'm looking at this from the
> perspective of future changes, maintenance, etc. I want the actions to
> match the design principles as closely as possible so that future
> evolutions of the code have lower risk to bugs causing security
> failures. Right now, the code is simple. I want to design this so that
> when it is complex, it will still fail toward safety in the face of
> bugs.
>
> I'd prefer this way because for the loop, the tests, and the results only
> make the bitmap more restrictive. The worst thing a bug in here can do is
> leave the bitmap unchanged (which is certainly bad), but it can't _undo_
> an earlier restriction.
>
> The proposed loop's leading test_bit() becomes only an optimization,
> rather than being required for policy enforcement.
>
> In other words, I prefer:
>
>         inherit all prior prior bitmap restrictions
>         for all syscalls
>                 if this filter not restricted
>                         continue
>                 set bitmap restricted
>
>         within this loop (where the bulk of future logic may get added),
>         the worse-case future bug-induced failure mode for the syscall
>         bitmap is "skip *this* filter".
>
>
> Instead of:
>
>         set bitmap all restricted
>         for all syscalls
>                 if previous bitmap not restricted and
>                    filter not restricted
>                         set bitmap unrestricted
>
>         within this loop the worst-case future bug-induced failure mode
>         for the syscall bitmap is "skip *all* filters".
>
>
>
>
> Or, to reword again, this:
>
>         retain restrictions from previous caching decisions
>         for all syscalls
>                 [evaluate this filter, maybe continue]
>                 set restricted
>
> instead of:
>
>         set new cache to all restricted
>         for all syscalls
>                 [evaluate prior cache and this filter, maybe continue]
>                 set unrestricted
>
> I expect the future code changes for caching to be in the "evaluate"
> step, so I'd like the code designed to make things MORE restrictive not
> less from the start, and remove any prior cache state tests from the
> loop.
>
> At the end of the day I believe changing the design like this now lays
> the groundwork to the caching mechanism being more robust against having
> future bugs introduce security flaws.
>

I see. Makes sense. Thanks. Will do that in the v4

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
