Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABBB9C4346E
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 03:27:04 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 29C0520872
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 03:27:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="cQNWEhua"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29C0520872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id B851886C88;
	Fri, 25 Sep 2020 03:27:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id sCcEoRD7aFTn; Fri, 25 Sep 2020 03:27:02 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 8B9AE86B2D;
	Fri, 25 Sep 2020 03:27:02 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 677FEC0859;
	Fri, 25 Sep 2020 03:27:02 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 9169DC0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:27:01 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 8CDAE87556
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:27:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 5v2Dm3hR9FOO
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:27:00 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f65.google.com (mail-pj1-f65.google.com
 [209.85.216.65])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 9D6D38754C
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:27:00 +0000 (UTC)
Received: by mail-pj1-f65.google.com with SMTP id fa1so1154531pjb.0
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:27:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=DeK1msedXGauky3LlZFdr+n8u+1Ihl4Ki0G/c0dEbRY=;
 b=cQNWEhuaNcfuMfCkkICKyKMwE1l6FY6pAgtxRmC7RXPnlCJ0saei23PhAdo67xody0
 RVpo2EJG4WpdQ5R8+mD+eB/MgkgQZPZufWt9hd4uz6jxYGpgabSCzyVqUGlBLvU+VxBt
 ZSrIa4uahkkdPSl2dtlVqAtgg+jd1CNPrWcwQ=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=DeK1msedXGauky3LlZFdr+n8u+1Ihl4Ki0G/c0dEbRY=;
 b=owT884n99UaaWdPUJ5X6Hit6aZdL3QAxEPa0a04kgXs4jFJvSA2FE1MnuTHO6ibGTM
 JTzEa1dQmmcOgxq2+z6aBAHbSw0l462OgS23dBLg1kiZgjqUgUMP7UP7C6Bf5PPxRZP4
 gptYIpNjfycmSJQavSrRhThujBZSaDgC0pJirNrSReFXYkuLQSoWmiLdcMK1NkI3/0rT
 EF9HV2J1GxreYKWJ6Ot4xUdxbjUgUpoStPmnqaBdz6HRMfaGHMJ2B1l94kCBdraG3+tM
 qDJempe+SFOjQUYsa2s8acCqp5V7HHTdn/qrTriAJbmeo7RYmoteNsZngS1LP6q89vmO
 8qsQ==
X-Gm-Message-State: AOAM531vFEvLkd59OLucRnkFaqRZDZKVg6qr4j1sjDKNVOwKkw5DLCYd
 XNA5h5s7ABbJMYlIetzQmtA2Bw==
X-Google-Smtp-Source: ABdhPJymYYYGWizHsr6HmLpbJR37C6I0dl0R7R4eB+yVnjR5cxc6gFLsOvtjiudHcJH8+ojao39tog==
X-Received: by 2002:a17:90b:4a0c:: with SMTP id
 kk12mr655501pjb.223.1601004420158; 
 Thu, 24 Sep 2020 20:27:00 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id b10sm637973pgm.64.2020.09.24.20.26.59
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 20:26:59 -0700 (PDT)
Date: Thu, 24 Sep 2020 20:26:58 -0700
From: Kees Cook <keescook@chromium.org>
To: YiFei Zhu <zhuyifei1999@gmail.com>
Subject: Re: [PATCH v2 seccomp 6/6] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
Message-ID: <202009242021.B0FB41084@keescook>
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <b11ebe533838af7829a5e7381a7914bca27cb621.1600951211.git.yifeifz2@illinois.edu>
 <202009241647.2239747F0@keescook>
 <CABqSeASrwXwSHHAsVwjG6vCLbfXpkp+42HWW27MUK2zgMnAu8w@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CABqSeASrwXwSHHAsVwjG6vCLbfXpkp+42HWW27MUK2zgMnAu8w@mail.gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
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

On Thu, Sep 24, 2020 at 10:11:17PM -0500, YiFei Zhu wrote:
> On Thu, Sep 24, 2020 at 6:56 PM Kees Cook <keescook@chromium.org> wrote:
> > > This file is guarded by CONFIG_PROC_SECCOMP_CACHE with a default
> > The question of permissions is my central concern here: who should see
> > this? Some contained processes have been intentionally blocked from
> > self-introspection so even the "standard" high bar of "ptrace attach
> > allowed?" can't always be sufficient.
> >
> > My compromise about filter visibility in the past was saying that
> > CAP_SYS_ADMIN was required (see seccomp_get_filter()). I'm nervous to
> > weaken this. (There is some work that hasn't been sent upstream yet that
> > is looking to expose the filter _contents_ via /proc that has been
> > nervous too.)
> >
> > Now full contents vs "allow"/"filter" are certainly different things,
> > but I don't feel like I've got enough evidence to show that this
> > introspection would help debugging enough to justify the partially
> > imagined safety of not exposing it to potential attackers.
> 
> Agreed. I'm inclined to make it CONFIG_DEBUG_SECCOMP_CACHE and guarded
> by a CAP just to make it "debug only".

Yeah; I just can't quite see what the best direction is here. I will
ponder this more. As I mentioned, it does seem handy. :)

> Is there something to stop a config from being enabled in an
> allyesconfig? I remember seeing something like that. Else if someone
> is manually selecting we can add a help text with a big banner...

Yeah, allyesconfig and allmodconfig both effectively set
CONFIG_COMPILE_TEST. Anyway, likely a caps test will end up being the
way to do it.

> 
> > But behavior-wise, yeah, I like it; I'm fine with human-readable and
> > full AUDIT_ARCH values. (Though, as devil's advocate again, to repeat
> > Jann's own words back: do we want to add this only to have a new UAPI to
> > support going forward?)
> 
> Is this something we want to keep stable?

The Prime Directive of "never break userspace" is really "never break
userspace in a way that someone notices". So if nothing ever parses that
file, then we don't have to keep it stable, but if something does, and
we change it, we have to fix it.

So, a capability test means very few things will touch it, and if we
decide it's not a big deal, we can relax permissions in the future.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
