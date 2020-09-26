Return-Path: <SRS0=QcxQ=DD=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 416FFC4727D
	for <containers@archiver.kernel.org>; Sat, 26 Sep 2020 01:23:46 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9E3442075A
	for <containers@archiver.kernel.org>; Sat, 26 Sep 2020 01:23:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Imh+a54p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E3442075A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 3AC992036D;
	Sat, 26 Sep 2020 01:23:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id FlD+wWJ0AJWB; Sat, 26 Sep 2020 01:23:44 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id A966020130;
	Sat, 26 Sep 2020 01:23:44 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8DBC5C0859;
	Sat, 26 Sep 2020 01:23:44 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 14F3EC0051
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 01:23:44 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id EE23F2036D
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 01:23:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id XBH2drnnDr+t
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 01:23:42 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f67.google.com (mail-pj1-f67.google.com
 [209.85.216.67])
 by silver.osuosl.org (Postfix) with ESMTPS id C6CD320130
 for <containers@lists.linux-foundation.org>;
 Sat, 26 Sep 2020 01:23:42 +0000 (UTC)
Received: by mail-pj1-f67.google.com with SMTP id q4so351778pjh.5
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 18:23:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=gjsiX96TOZRrX+VWB5R73a/e4ejGDQtJ92tP2rTnjOs=;
 b=Imh+a54pvSI9sfrjTL6vFP9BP8aCNTez3j81G7yDGDS59MGe4mxIsT5JeEXn51ynmf
 wGIDMu7h37nNhagccGZt84pZgsS7AIKEs40qYkX+MHQvkVfOZnoakZdz9M8u4vdlGb5P
 8yQBq6S01sczjE5nT0niD5iVgLXYHTUBp939DUYIPIZ879aB1GcXRZUeBdlAUbyC7Cwv
 Ruy2U3hxVwfr9jds0Vmo66h6zEqsxKqrQaYwuXyW6bIR73SwpKlLTyTsnpk6LVgFZAn+
 Idqwu5WQx3/qfn2BlC4gVXLpxxMbuXM3P/UHb4FqM95OyYoD0Mhuvp9ibx5dstPe7H1G
 +hUg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=gjsiX96TOZRrX+VWB5R73a/e4ejGDQtJ92tP2rTnjOs=;
 b=SjGeZwwbs/GXNd4J+qc2OrQbzs0/0DUEooJjMFSjSrN7sXyqAqeBrVlTMm1GWvvHrj
 LWJwITt7ZaCQpht+R66rJOZanRhZlFaMgHyCuSKvuPl1dOuDkSbJmMajodrX/gTb/dXG
 jYyTtueYusybIu1veFtLPpRq4h9FMtLHGR0VjJb5MOc29droib9cosoG8zIv3BphD9Jl
 jk5qEA1dhnlaes0FaziPjBLQz9VXOSe2Lb2FcFLajwDZccQgLNhG9ifqINSAI9cQHz/p
 /9eSMQUHQfqYPPLkGfaPHgmpqp4JBrccAp6So7OT2gHm/RVgFcpjFC728ontbv23p2JL
 dbGw==
X-Gm-Message-State: AOAM533jJpujUMpNY/xIgkejzjKni+UNy6tl8PyEJGI8+B9f8WJGStfR
 gv5IjtwWrP6gHq0IWdD/FQqVt+w7LcXleqiGWs8=
X-Google-Smtp-Source: ABdhPJzOKTBS/qfK2ZK7IckkNEZ2COxbBRpCd5qZvLpE47fez0OjnTD6tKlcc+G9j0e6gphevIVvtwX2kJMYareLyfQ=
X-Received: by 2002:a17:902:778e:b029:d2:8046:efe2 with SMTP id
 o14-20020a170902778eb02900d28046efe2mr172074pll.44.1601083422286; Fri, 25 Sep
 2020 18:23:42 -0700 (PDT)
MIME-Version: 1.0
References: <202009251223.8E46C831E2@keescook>
 <2FA23A2E-16B0-4E08-96D5-6D6FE45BBCF6@amacapital.net>
 <202009251332.24CE0C58@keescook>
 <CALCETrU_UpcLhXSG84SA6QkAYe8xXn4AXPKeud-=Adp57u54Mg@mail.gmail.com>
In-Reply-To: <CALCETrU_UpcLhXSG84SA6QkAYe8xXn4AXPKeud-=Adp57u54Mg@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Fri, 25 Sep 2020 20:23:30 -0500
Message-ID: <CABqSeASR0bQ7Y302SkZ639NM=roSVRmd3ROGm0YDEFCTxxd63w@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 3/6] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Hubertus Franke <frankeh@us.ibm.com>, Jack Chen <jianyan2@illinois.edu>,
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

On Fri, Sep 25, 2020 at 4:07 PM Andy Lutomirski <luto@amacapital.net> wrote:
> We'd need at least three states per syscall: unknown, always-allow,
> and need-to-run-filter.
>
> The downsides are less determinism and a bit of an uglier
> implementation.  The upside is that we don't need to loop over all
> syscalls at load -- instead the time that each operation takes is
> independent of the total number of syscalls on the system.  And we can
> entirely avoid, say, evaluating the x32 case until the task tries an
> x32 syscall.

I was really afraid of multiple tasks writing to the bitmaps at once,
hence I used bitmap-per-task. Now I think about it, if this stays
lockless, the worst thing that can happen is that a write undo a bit
set by another task. In this case, if the "known" bit is cleared then
the worst would be the emulation is run many times. But if the "always
allow" is cleared but not "known" bit then we have an issue: the
syscall will always be executed in BPF.

Is it worth holding a spinlock here?

Though I'll try to get the benchmark numbers for the emulator later tonight.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
