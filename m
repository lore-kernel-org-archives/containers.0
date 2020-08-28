Return-Path: <SRS0=8SPi=CG=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A698FC433E2
	for <containers@archiver.kernel.org>; Fri, 28 Aug 2020 20:33:54 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6D9DB2074A
	for <containers@archiver.kernel.org>; Fri, 28 Aug 2020 20:33:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=sargun.me header.i=@sargun.me header.b="xTxWwhEV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D9DB2074A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 360BC87F8B;
	Fri, 28 Aug 2020 20:33:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0Isy2T4wjavt; Fri, 28 Aug 2020 20:33:53 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 4967485FED;
	Fri, 28 Aug 2020 20:33:53 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 2E5B7C07FF;
	Fri, 28 Aug 2020 20:33:53 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4E8A0C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 20:33:52 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 36C1D85FED
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 20:33:52 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id KWgTAIxHhYLd
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 20:33:50 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ed1-f49.google.com (mail-ed1-f49.google.com
 [209.85.208.49])
 by whitealder.osuosl.org (Postfix) with ESMTPS id D7CB2874F7
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 20:33:49 +0000 (UTC)
Received: by mail-ed1-f49.google.com with SMTP id ay8so238025edb.8
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 13:33:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=DnLPewM/6z2Ca3eSBTJ09aPCoC3sIGnyctxFbXRMDVc=;
 b=xTxWwhEVyw428sCG3emMHL4+r803f5gZ8B9/ZOfnyxNZyr88E++NPbk6RKdwwjWEu0
 0uzhJqnu5W0e4L05oaEN5TicKF7F8xt9gbNRJGOKSn6L0xe4TZRX2T6G4hV/QpE0JGbo
 PL/TB8O294IOThK4Xn8n1t5bYywWge1c/9uFg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=DnLPewM/6z2Ca3eSBTJ09aPCoC3sIGnyctxFbXRMDVc=;
 b=d1ctlK6IFE5WCNDJE3muCRi6wbSF2zSiIDu9/M4FnyUgAxn/ZYXYeEnRy43EJkSleh
 2pFX4ObkpdG5YVe+vEni1l1CGqY/hG5jMqbWZMAKvwEd4w9yVCyZWIp2u/csrOw7sc0S
 uIytb11Az5GptEicgGEUFwHti5TaND9uIC26qox/r+lBOvOAvMFyqubgPH6KHfi+yDdS
 3ZpDVYEOVe9Blgitz6FUnTSO+FYCXvGjZ79JhKM2cfNlsEwWqfYy6+CXOtpZCuX34j6O
 DE6B4470RoPW4WxBElkuIem6sbjCzEbcl9JZnkeBD7nQdZhQiHSNwRwmo0qFhmOQIAnz
 PNyA==
X-Gm-Message-State: AOAM53071ybuLII7vjarUpraiaGuaWDfrw8892s/V0dlFjjcz8ZM34NA
 O8gU1tFqjoDxNt1yyfylDBq8yQOe2MoVw8UBPrZQBQ==
X-Google-Smtp-Source: ABdhPJx/4t9J2rkv9DdBoSWQ42Pn8H13Sx0erJv/PaR8G8TO/G9uKUPA66YvkGx2+hrO+vB8IJbki5+d1hsh3jt/jew=
X-Received: by 2002:aa7:d517:: with SMTP id y23mr567107edq.210.1598646827947; 
 Fri, 28 Aug 2020 13:33:47 -0700 (PDT)
MIME-Version: 1.0
References: <87imd2incs.fsf@x220.int.ebiederm.org>
In-Reply-To: <87imd2incs.fsf@x220.int.ebiederm.org>
From: Sargun Dhillon <sargun@sargun.me>
Date: Fri, 28 Aug 2020 13:33:12 -0700
Message-ID: <CAMp4zn9M783PTkq0q5BV5n2x=4P4ed4F6F9b7p7ex97=_3J0GA@mail.gmail.com>
Subject: Re: Per user rlimits
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Containers <containers@lists.linux-foundation.org>
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

On Fri, Aug 28, 2020 at 12:29 PM Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
>
> Just to scope how much work it would be to fix rlimits
> so they are not a problem for user namespaces I took a quick
> survey.
>
> The rlimits can be found in
> include/uapi/asm-generic/resource.h
>
> There are a total of 16 rlimits.
> There are only 4 rlimits that are enforced at anything other
> than process granularity.
>
> RLIMIT_NPROC
> RLIMIT_MEMLOCK
> RLIMIT_SIGPENDING
> RLIMIT_MSGQUEUE
>
> So it should not be difficult to fix those rlimits.
What are your proposed semantics for what the "fix" would look like? Or
are you saying that once we take on Christian's proposal of 64-bit kuid
they would be trivial to fix? I think the reason we didn't move forward with
fixing it is the only real thing we could agree upon is an rlimit namespace,
and then you get into a question of why do these even exist, and should
they just be cgroup(v2) controllers, and should calling setrlimit just
be a wrapper around a cgroup(v2) controller that has a map of
uid -> limit?

>
> I think the implementation of RLIMIT_MEMLOCK is highly suspect, and
> might be worth reexamining, as RLMIT_MEMLOCK it interpreted differently
> in different contexts.  For the limit there is mm->locked_vm,
> user->lock_vm, and user->locked_shm.
>
> Eric
>
>
>
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
