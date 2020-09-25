Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DBD4C4346E
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 03:11:32 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A8821206C1
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 03:11:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eOBo1Dk5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8821206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 2C99686A60;
	Fri, 25 Sep 2020 03:11:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8M9AocXtCr8P; Fri, 25 Sep 2020 03:11:30 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 9F77B8690F;
	Fri, 25 Sep 2020 03:11:30 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 95A13C0859;
	Fri, 25 Sep 2020 03:11:30 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E0F13C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:11:29 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id C75F286A60
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:11:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id yikRa3LA9EBn
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:11:29 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com
 [209.85.210.196])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 45CF88690F
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:11:29 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id w7so1818347pfi.4
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:11:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=4ySqE1hRmF9Ut683kpqXH3+Ug8FaOyeb/lR8F0Fj7WM=;
 b=eOBo1Dk5p71aOus/dqAJ5VrtH0vlEUxqA/HX/NYAH316KAy2KiDxLZ+RHBbSiGGOLC
 fK0M41WRXhGjY9h1joZWds6hPj2ODt92H9A8vGV6qTyOXSrttaLuU3Ca0rT+hQXa2Hc8
 RnEVYQ20u5JFb6w/sofhSYAz7Y19aoL1sD4YMVwoe9yWPr31Csn0MzMhDauTqPYuuWow
 ZFIOuwU5e+R5uY49sI3IFKYCR+vUEDrF7oVauM/7vMjbn99qllOZWnoJfn0sPR+blKv+
 hvOId1dlpBj+QvDV9av1m4Ktj1oGIee23S8yDcbQEEc7uhKSOV5LcWqviLoQ0bsA7pOh
 YC4A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=4ySqE1hRmF9Ut683kpqXH3+Ug8FaOyeb/lR8F0Fj7WM=;
 b=PWe6iedB7OFubQVnxcr8mxIxnzpCgsMAgFlFIbfbI4vPZHAOtX9Fsde7EiTjOxgj0x
 U5v97Yzo9y7SkplM5O+dv+7gqCtepDMjwTyVhHOf20NGX+vP3bPGnPjJTAQfQcrkQUId
 /RIA/EhcF0V+iJUCS2esUm+n4caP4fzfMZH9JekZkcvJfs3Yssp1t4fQaXY41O06jhFp
 ZcCMbIKXpH0cxTTPBaXjHvDdKXljR/EH2AMEQT6uCOzEqLE8g0kTlpnVJoWj9vIKP2sI
 lRgDy5x5u81LHc0wXmsuhFCLTCSEmUHaWNof07NopOL/lp/q2Pg6Fa14DomL3hygdqmc
 pFqg==
X-Gm-Message-State: AOAM532Y1TIy2+4Fkahx/cBKvhNdprl+5snntdW/UK4AE5qSWtZJBNGM
 DQRQuxbZO9FB1FxOP6VpHBwyVnSLva/Ppm1OppI=
X-Google-Smtp-Source: ABdhPJzW6eDnzhk2FnjrkoXEDFOI42OK+sDY3QodTZzLs9uOSntOF7enBAOqFgHMxIhE8UdI3EgqLjF9FLBZICuokXM=
X-Received: by 2002:aa7:8d4c:0:b029:150:f692:4129 with SMTP id
 s12-20020aa78d4c0000b0290150f6924129mr2179043pfe.11.1601003488655; Thu, 24
 Sep 2020 20:11:28 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <b11ebe533838af7829a5e7381a7914bca27cb621.1600951211.git.yifeifz2@illinois.edu>
 <202009241647.2239747F0@keescook>
In-Reply-To: <202009241647.2239747F0@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 24 Sep 2020 22:11:17 -0500
Message-ID: <CABqSeASrwXwSHHAsVwjG6vCLbfXpkp+42HWW27MUK2zgMnAu8w@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 6/6] seccomp/cache: Report cache data through
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

On Thu, Sep 24, 2020 at 6:56 PM Kees Cook <keescook@chromium.org> wrote:
> > This file is guarded by CONFIG_PROC_SECCOMP_CACHE with a default
> The question of permissions is my central concern here: who should see
> this? Some contained processes have been intentionally blocked from
> self-introspection so even the "standard" high bar of "ptrace attach
> allowed?" can't always be sufficient.
>
> My compromise about filter visibility in the past was saying that
> CAP_SYS_ADMIN was required (see seccomp_get_filter()). I'm nervous to
> weaken this. (There is some work that hasn't been sent upstream yet that
> is looking to expose the filter _contents_ via /proc that has been
> nervous too.)
>
> Now full contents vs "allow"/"filter" are certainly different things,
> but I don't feel like I've got enough evidence to show that this
> introspection would help debugging enough to justify the partially
> imagined safety of not exposing it to potential attackers.

Agreed. I'm inclined to make it CONFIG_DEBUG_SECCOMP_CACHE and guarded
by a CAP just to make it "debug only".

> I suspect it _is_ the right thing to do (just look at my own RFC's
> "debug" patch), but I'd like this to be well justified in the commit
> log.
>
> And yes, while it does hide behind a CONFIG, I'd still want it justified,
> especially since distros have a tendency to just turn everything on
> anyway. ;)

Is there something to stop a config from being enabled in an
allyesconfig? I remember seeing something like that. Else if someone
is manually selecting we can add a help text with a big banner...

> But behavior-wise, yeah, I like it; I'm fine with human-readable and
> full AUDIT_ARCH values. (Though, as devil's advocate again, to repeat
> Jann's own words back: do we want to add this only to have a new UAPI to
> support going forward?)

Is this something we want to keep stable?

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
