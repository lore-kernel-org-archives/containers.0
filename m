Return-Path: <SRS0=zK8s=D5=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CAB8C388F9
	for <containers@archiver.kernel.org>; Thu, 22 Oct 2020 20:52:36 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E73EB2080C
	for <containers@archiver.kernel.org>; Thu, 22 Oct 2020 20:52:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d6+CBZng"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E73EB2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 67B608787C;
	Thu, 22 Oct 2020 20:52:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id TZaGe5h42I3F; Thu, 22 Oct 2020 20:52:34 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id B560B8787A;
	Thu, 22 Oct 2020 20:52:34 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9F355C08A1;
	Thu, 22 Oct 2020 20:52:34 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 8476EC0052
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 20:52:33 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 680698787A
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 20:52:33 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id eFbp+NJg7BT0
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 20:52:32 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com
 [209.85.215.194])
 by hemlock.osuosl.org (Postfix) with ESMTPS id D15CE8784D
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 20:52:32 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id o3so1715992pgr.11
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Oct 2020 13:52:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=Ag5R8ANFXiIKHrZi3CpUKkJaLv+KTVPp7lGufqkGA/Q=;
 b=d6+CBZngB4ab2gx0rcr80/mUgsqGHrDfBj1/ysacUwotFwRiXDdiFVeXasFIZHuxHV
 1x42nCvwwG6yQagKIIf1tCqN7+6tPyMBG1vriokW70nyWmsc8sMnME4tilAanNACPt9O
 UzNtsCl8lGUuz9Im9a2MYKC37+MOa7tXY3edPXllbkN0hCEGFSQJnOVjVtVIAq/+HJLn
 puZeL7mEq755h14QQNrKiJO3EdeJ0uF64975sPV2JD6dBoaXPh5ct0LHO4hygeT08KGT
 jSXmP5u+fSJpVAIRfAuEVSd0XPlAxR+NDLBHr9Bh1K2r/SHLCD+LPnn7xcu4RCGkQK5K
 2CnQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=Ag5R8ANFXiIKHrZi3CpUKkJaLv+KTVPp7lGufqkGA/Q=;
 b=EfVM3k1iqIPK/KoEWO4BvHUJ4Mri0BbEFY2j1lpYYionCYpfC8yz/u+XxLqxjfGt3S
 Z+VqEBQrrYtTptfeMQMa6yfgiEqaWNQycdfS5lnnhAf8KtzL4zmzivRbn2Ghh07SgmSD
 cRoYuEsxGP6FR0YLKChU7S3rMq8hYGjfk1Wg0wS6/THbNMAw9esE7p499w0devfa6ipo
 50b9hg1WOsWTdG2hZyFDPBjRXzSIuYakxUbx8h4miKXOyeqnt6C/JXnjrpZr2fTmz8CB
 4ymPlfS4qvG3o72jXpm9h8bBVtwnYAYWXtWVuqC35stKWOL8NhrTtYGKBcvswBAM5UJ8
 jsSg==
X-Gm-Message-State: AOAM532Z1vkvhATpeHiFKIJkE83gQmxk4Y2mvF/mAfCJZvU2AghsoSqs
 mKBEqGmmfxQomHrirAETsDgNthFTvQ0QrLzFdyU=
X-Google-Smtp-Source: ABdhPJx+dBEdcJ+BztG+kLdnt+vX7FpE4LlJQH01ipc7IDV0pS9xsoGFMHkw/BUBCjO1GOwzT0IU3w3pZk202vhKcQg=
X-Received: by 2002:a17:90a:f184:: with SMTP id
 bv4mr3823913pjb.1.1603399952372; 
 Thu, 22 Oct 2020 13:52:32 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <c2077b8a86c6d82d611007d81ce81d32f718ec59.1602263422.git.yifeifz2@illinois.edu>
 <202010091613.B671C86@keescook>
 <CABqSeARZWBQrLkzd3ozF16ghkADQqcN4rUoJS2MKkd=73g4nVA@mail.gmail.com>
 <202010121556.1110776B83@keescook>
 <CABqSeAT2-vNVUrXSWiGp=cXCvz8LbOrTBo1GbSZP2Z+CKdegJA@mail.gmail.com>
In-Reply-To: <CABqSeAT2-vNVUrXSWiGp=cXCvz8LbOrTBo1GbSZP2Z+CKdegJA@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 22 Oct 2020 15:52:20 -0500
Message-ID: <CABqSeASc-3n_LXpYhb+PYkeAOsfSjih4qLMZ5t=q5yckv3w0nQ@mail.gmail.com>
Subject: Re: [PATCH v4 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
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

On Mon, Oct 12, 2020 at 7:31 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
>
> On Mon, Oct 12, 2020 at 5:57 PM Kees Cook <keescook@chromium.org> wrote:
> > I think it's fine to just have this "dangle" with a help text update of
> > "if seccomp action caching is supported by the architecture, provide the
> > /proc/$pid ..."
>
> I think it would be weird if someone sees this help text and wonder...
> "hmm does my architecture support seccomp action caching" and without
> a clear pointer to how seccomp action cache works, goes and compiles
> the kernel with this config option on for the purpose of knowing if
> their arch supports it... Or, is it a common practice in the kernel to
> leave dangling configs?

Bump, in case this question was missed. I don't really want to miss
the 5.10 merge window...

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
