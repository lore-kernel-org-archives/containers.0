Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAD53C4727E
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 07:07:15 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0586F22211
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 07:07:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gt9l35Cg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0586F22211
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 9323986BBD;
	Fri, 25 Sep 2020 07:07:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qfRjjg8Ja7g7; Fri, 25 Sep 2020 07:07:13 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id EC0AE86BB9;
	Fri, 25 Sep 2020 07:07:13 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id CE25FC0890;
	Fri, 25 Sep 2020 07:07:13 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 89B7AC0859
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 07:07:12 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 772A38756F
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 07:07:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id vweA9wRQSlsp
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 07:07:12 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f66.google.com (mail-pj1-f66.google.com
 [209.85.216.66])
 by hemlock.osuosl.org (Postfix) with ESMTPS id F02828756D
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 07:07:11 +0000 (UTC)
Received: by mail-pj1-f66.google.com with SMTP id mn7so1279893pjb.5
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 00:07:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=oXHAzrDSGjCjB2rkCK3StmtVizqd8imW6WJ6CCyJZeQ=;
 b=gt9l35Cg3svYq9N0uBGPNxc+e9Lj33iOExb3HpMPwqd2IPv6C27pIvDXvzxWOzcHBW
 Yh6glD+IXSLk5VfF1jBzqvUUkan5XiVd6XlMp+D3SVOURcaVZ3nn2+1MK3naJ7SRwHJT
 VQ+9/V2/FG6I3s/4f6i3P5/lZ05PsRTL9Avex18L+gg4JE3fmaJDBPu0MGlCNYxRDVEt
 QIEcXSjUOn52P6voDi2cMT4cgBLkxfo/Jh1fns0C9xKWvlYlMBlOg6y/rZGEd5SbFpAI
 KDzO3BcKFpdoY8pgwzuEdmuNrO5qQPcTyFezyookmPHET2xLWBBgUm/ISJ2ttmeyDB9c
 FnPQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=oXHAzrDSGjCjB2rkCK3StmtVizqd8imW6WJ6CCyJZeQ=;
 b=sEaGWXK0hjwMlt7DTaDLJWL09U8CcSGXxeZN9HJ/S4no31kgD68wbB8kwDnVhxGbfL
 kbsYKR57O6t9ZFkpjnJce71iEExGQhPb17BMXnRTfEKH7tpTmFoOD3MLMYolwk7ztDb9
 FRFsYJlyvqpUtxqQcFWk/E/aaREzrHQwmLqV6fXGJ3R2kkwz0jQI2z7rKZOU7ShI0PN4
 uQ0k2/CGF+C3W02Zsu3KKzvBNDwcO9rI4Nmtjs39MmxMbiz5FaubKhEqVXqmlSTEw4tS
 4VW2zE1tk7C3oxygssOQSAonh6fhDGsEt15/gNs830KDcTXgdxmbmdRq4j4Ovt/6zn30
 MGMA==
X-Gm-Message-State: AOAM530zMB9qABmiwOiBabysF4kWbBn421xEH3tX+LtOvMk5wS4iBJHO
 Xu2B2ZwvFZu2iKKtb6Vzk+TLWHY0VVfpIQq+oYo=
X-Google-Smtp-Source: ABdhPJzlGUGW2iKkTkrAVqTUKcvO9npurfnjC2yNvq753E1M0AVW5b7tjO01qNJKAYI3kQSCeflzbuJKPBvB5TUeDog=
X-Received: by 2002:a17:90a:6e45:: with SMTP id
 s5mr1374059pjm.12.1601017631436; 
 Fri, 25 Sep 2020 00:07:11 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <43039bb6-9d9f-b347-fa92-ea34ccc21d3d@rasmusvillemoes.dk>
 <CABqSeAQKksqM1SdsQMoR52AJ5CY0VE2tk8-TJaMuOrkCprQ0MQ@mail.gmail.com>
 <27b4ef86-fee5-fc35-993b-3352ce504c73@rasmusvillemoes.dk>
In-Reply-To: <27b4ef86-fee5-fc35-993b-3352ce504c73@rasmusvillemoes.dk>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Fri, 25 Sep 2020 02:07:00 -0500
Message-ID: <CABqSeATHtvA7qm7j_kxBsbxRCd5B=MHtxGdsYsXEJ-TRRYKTgA@mail.gmail.com>
Subject: Re: [PATCH v1 0/6] seccomp: Implement constant action bitmaps
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf <bpf@vger.kernel.org>,
 Tianyin Xu <tyxu@illinois.edu>, kernel list <linux-kernel@vger.kernel.org>
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

On Fri, Sep 25, 2020 at 12:56 AM Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
> Yes, the man page would read something like
>
>        SECCOMP_SET_MODE_FILTER_BITMAP
>               The system calls allowed are defined by a pointer to a
> Berkeley Packet Filter (BPF) passed  via  args.
>               This argument is a pointer to a struct sock_fprog_bitmap;
>
> with that struct containing whatever information/extra pointers needed
> for passing the bitmap(s) in addition to the bpf prog.
>
> And SECCOMP_SET_MODE_FILTER would internally just be updated to work
> as-if all-zero allow-bitmaps were passed along. The internal kernel
> bitmap would just be the and of the bitmaps in the filter stack.
>
> Sure, it's UAPI, so would certainly need more careful thought on details
> of just how the arg struct looks like etc. etc., but I was wondering why
> it hadn't been discussed at all.

If SECCOMP_SET_MODE_FILTER is attached before / after
SECCOMP_SET_MODE_FILTER_BITMAP, does it mean all bitmap gets void?

Would it make sense to have SECCOMP_SET_MODE_FILTER run through the
emulator to see if we can construct a bitmap anyways for "legacy
no-bitmap" support?

Another thing to consider is that in both patch series we only
construct one final bitmap that, if the bit is set, seccomp will not
call into the BPF filter. If the bit is not set, then all filters are
called in sequence, even if some of them "must allow the syscall".
With SECCOMP_SET_MODE_FILTER_BITMAP, the filter BPF code will no
longer have the "if it's this syscall" for any syscalls that are given
in the bitmaps, and calling into these filters will be a false
negative. So we would need extra logic to make "does this filter have
a bitmap? if so check bitmap first". Probably won't be too
complicated, but idk if it is actually worth the complexity. wdyt?

> Regardless, I'd like to see some numbers, certainly for the "how much
> faster does a getpid() or read() or any of the other syscalls that
> nobody disallows" get, but also "what's the cost of doing that emulation
> at seccomp(2) time".

The former has been given in my RFC patch [1]. In an extreme case of
no side channel mitigations, in the same amount of time, unixbench
syscall mixed runs 33295685 syscalls without seccomp, 20661056
syscalls with docker profile, 25719937 syscalls with bitmapped docker
profile. Though, I think Jack was running on Ubuntu and it did not
have a libseccomp shipped with the distro that's new enough to do the
binary decision tree generation [2].

I'll try to profile the latter later on my qemu-kvm, with a recent
libsecomp with binary tree and docker's profile, probably both direct
filter attaches and filter attaches with fork(). I'm guessing if I
have fork() the cost of fork() will overshadow seccomp() though.

[1] https://lore.kernel.org/containers/cover.1600661418.git.yifeifz2@illinois.edu/
[2] https://github.com/seccomp/libseccomp/pull/152

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
