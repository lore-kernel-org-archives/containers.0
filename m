Return-Path: <SRS0=KLId=EK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45486C2D0A3
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 11:41:09 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AAF25223AB
	for <containers@archiver.kernel.org>; Wed,  4 Nov 2020 11:41:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TA/upDzk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAF25223AB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 0EE008691C;
	Wed,  4 Nov 2020 11:41:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qFtWQuZQIRHO; Wed,  4 Nov 2020 11:41:06 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 69D9286960;
	Wed,  4 Nov 2020 11:41:06 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 56D77C0889;
	Wed,  4 Nov 2020 11:41:06 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id CB5F0C0051
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 11:41:04 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id B7CDF2047C
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 11:41:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id e77gIHifThe9
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 11:41:03 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com
 [209.85.210.193])
 by silver.osuosl.org (Postfix) with ESMTPS id C71752039D
 for <containers@lists.linux-foundation.org>;
 Wed,  4 Nov 2020 11:41:03 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id j18so17092235pfa.0
 for <containers@lists.linux-foundation.org>;
 Wed, 04 Nov 2020 03:41:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=LrTKUro/EAfrSfquqr6fzY3elZ7+MZodt7l7Rb7VaMA=;
 b=TA/upDzkSlqE8bbPerc9M1oYcPB/SCguB/fv6tsU0qNJEICokPJOWWbzUO1heqjx1X
 3MJkKQbgC+mF0e9Skbu2tODntCXpim0YAGDgj8FN7sDDIYQ3LWENybyqXCZl/be+XIV7
 WkLl+XHEOUOo5pQruyx0qVAlxfInjmoyHlqVQGeveukro3khLO1jYepKUOZHrwFZ9ajK
 qadPobf/QXXP57jlIZ1IuZ5JjtLZc2rA7A6Suqtp3Kq9x2PAu07ziUDnyQuTlnoexYBH
 aFgJjI+kgZNHMfPu8OpcuPuLOyBtB9ucJUa6Vc1pIoNedcqDe7XyKvzwxbAnHqPdVC/8
 3d2A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=LrTKUro/EAfrSfquqr6fzY3elZ7+MZodt7l7Rb7VaMA=;
 b=TW/5OpMaT2x0/ivbaEW7Lwk6g282agJsvbaVeaNQSKnINQRFAIfC92i/OIw57BPrhf
 QwhT56xAZvGqCr7oJKh/YkJgFHzZfAgMtMDio7XdWVYSF9YXJM5T5a8tPBZKJSVO0J+M
 cPvKh8ZiDiK8xjjcit9BL9zaVlDoqbgH3ORsrujHVS6zPg4kwD5e+vTszyUZUaQJ6sfC
 VMv+vAzEwEgI2DPo15df5p0zMiK5Gf4+GgxcHqXA4kOdvQr/ipU1coyqxsShBbGAUAgr
 nPFqRPuhOOTX9+4QC97m6rpH3IP3UI5pVEVxB5YiPykTVMqBySNl7j300o6ELn6ojnSo
 fa5A==
X-Gm-Message-State: AOAM532JTbS3gZtqnDbCAjFiOeP6eLUh+lp258uX0S6bdO6bAUj3jPiR
 xeVKoASi9IAepE7tZa/+7mVDge3nkHAWMk+wgh0=
X-Google-Smtp-Source: ABdhPJxXrmLrL+mP1OQCNUcSRgpIRR5lxJCHjx9kumQZ9Rb2jjUaKiD5ojjTiFRpWH3+G31Xb1/FBX1ZKkxWCv735h0=
X-Received: by 2002:a63:f445:: with SMTP id p5mr20807325pgk.293.1604490063419; 
 Wed, 04 Nov 2020 03:41:03 -0800 (PST)
MIME-Version: 1.0
References: <202010091613.B671C86@keescook>
 <CABqSeARZWBQrLkzd3ozF16ghkADQqcN4rUoJS2MKkd=73g4nVA@mail.gmail.com>
 <202010121556.1110776B83@keescook>
 <CABqSeAT2-vNVUrXSWiGp=cXCvz8LbOrTBo1GbSZP2Z+CKdegJA@mail.gmail.com>
 <CABqSeASc-3n_LXpYhb+PYkeAOsfSjih4qLMZ5t=q5yckv3w0nQ@mail.gmail.com>
 <202010221520.44C5A7833E@keescook>
 <CABqSeAT4L65_uS=45uxPZALKaDSDocMviMginLOV2N0h-e1AzA@mail.gmail.com>
 <202010231945.90FA4A4AA@keescook>
 <CABqSeAQ4cCwiPuXEeaGdErMmLDCGxJ-RgweAbUqdrdm+XJXxeg@mail.gmail.com>
 <CABqSeATiV0sQvqpvCuqkOXNbjetY=1=6ry_SciMVmo63W9A88A@mail.gmail.com>
 <202011031612.6AA505157@keescook>
In-Reply-To: <202011031612.6AA505157@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Wed, 4 Nov 2020 05:40:51 -0600
Message-ID: <CABqSeASFkTFn8ix8-5D0vdZ_FR9bR1PpU3j5eQPYOMshK6FuNA@mail.gmail.com>
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

On Tue, Nov 3, 2020 at 6:29 PM Kees Cook <keescook@chromium.org> wrote:
> Yeah, this is very interesting. That there is anything measurably _slower_
> with the cache is surprising. Though with only 4 runs, I wonder if it's
> still noisy? What happens at 10 runs -- more importantly what is the
> standard deviation?

I could do that. it just takes such a long time. Each run takes about
20 minutes so with 10 runs per environment, 3 environments (native + 2
docker) per boot, and 4 boots (2 bootparam * 2 compile config), it's
27 hours of compilation. I should probably script it at that point.

> I assume this is from Indirect Branch Prediction Barrier (IBPB) and
> Single Threaded Indirect Branch Prediction (STIBP) (which get enabled
> for threads under seccomp by default).
>
> Try booting with "spectre_v2_user=prctl"

Hmm, to make sure, boot with just "spectre_v2_user=prctl" on the
command line and test the performance of that?

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
