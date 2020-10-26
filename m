Return-Path: <SRS0=D+Sq=EB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.8 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D5DFC4363A
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 09:48:00 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DA7D920704
	for <containers@archiver.kernel.org>; Mon, 26 Oct 2020 09:47:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WoCW0nte"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA7D920704
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 4D4498672C;
	Mon, 26 Oct 2020 09:47:59 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zAjSelI3MKsu; Mon, 26 Oct 2020 09:47:58 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id AE206863D9;
	Mon, 26 Oct 2020 09:47:58 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8C929C088B;
	Mon, 26 Oct 2020 09:47:58 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id BF5C0C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 09:47:57 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id B3A6886135
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 09:47:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id zfoN_4wAzFmK
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 09:47:57 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wr1-f65.google.com (mail-wr1-f65.google.com
 [209.85.221.65])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id D35DB860DE
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 09:47:56 +0000 (UTC)
Received: by mail-wr1-f65.google.com with SMTP id n6so11597968wrm.13
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 02:47:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=cc:subject:to:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=RofcZGS865XP0CJeBO4BVg251gRgyllrJGC9dSHvpIE=;
 b=WoCW0nte1VKuBFW+DHpEF0q3TEBLAhrJniB+2cR1R+Jym+5miy+0H/59Ej7Vjqtxwb
 ELgbqDxczlFqvvYWd8ff9ZpMax8dxulwgEb1e77IFnFxNY4JpCAP6xqtkqhVlzlzVG8o
 vlrc5Az5GD92t07MyuT+H7QSj4ZXWteaG4DwFkAtauPZK+AyssIbtz4ZvGDcIRqegBvN
 TevURipvJPTUC1XVL8+GKYXn3/R2fDOqaIgZWAlrLCih/6rV4s6SDrSUzbJNrappu6dV
 ACB2Y9Ep9LODGceWQF8Ecux1Iku3oC05D9cAcJFirykh7rDoIKayOA+EZ5tP75GFUb5x
 zvdQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:cc:subject:to:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=RofcZGS865XP0CJeBO4BVg251gRgyllrJGC9dSHvpIE=;
 b=hr+LRdtnebvTfSUvA1gUWWbjrLSZBOcS0YDq/Sb3jkwgv1rPr8fsqtYKtm3fvKr3re
 TFOI5JD273WzlqusgcROLBq8fx6SuK3Yo5prbTXHgtLvZqgoHO2jiVCIO6418MJHO5am
 qoxk21X9cpwUn2xksrh++bjuk+5h+Yjzd/Qjj8VonF9j2MOaB6UUtI/Md9smpp0Hb86C
 vhrp8Cq9FILQ7DYu8xC8R56hInPDAj0jeZuGB0hU9WtqaL31Bt57Q+NpN6Ysvlik4uIp
 I4sjn0tRkFgV3vC4SLtacBtxVcxHFPD70VCYxMpYJgTh+AFMDKIWU/ME1m85DFWJd6WS
 s8YA==
X-Gm-Message-State: AOAM5312G/zdQ9D0/G67GfvvpvhSMpRKFoUSIhdYm60CjS7Cl87SVp4P
 APBWem9Pf+v+3mPWJqK6GhI=
X-Google-Smtp-Source: ABdhPJyFM3wn+IiQLQzz50kHLaqHXhKfK4cG0OvqF6sLtSsTrVOcYiUso1oxM/L+lHez4anrJ8+EQw==
X-Received: by 2002:adf:e4ca:: with SMTP id v10mr17870768wrm.53.1603705675151; 
 Mon, 26 Oct 2020 02:47:55 -0700 (PDT)
Received: from ?IPv6:2001:a61:245a:d801:2e74:88ad:ef9:5218?
 ([2001:a61:245a:d801:2e74:88ad:ef9:5218])
 by smtp.gmail.com with ESMTPSA id u15sm22285531wrm.77.2020.10.26.02.47.53
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Mon, 26 Oct 2020 02:47:54 -0700 (PDT)
Subject: Re: For review: seccomp_user_notif(2) manual page
To: Jann Horn <jannh@google.com>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <CAG48ez3aqLs_-xgU0bThOLqRiiDWGObxcg-X9iFe6D5RDnLVJg@mail.gmail.com>
 <5647b94a-4693-dad0-6e0d-ed178b495d65@gmail.com>
 <CAG48ez1PtJPQLrQ54P+uuuxbt6mri9wcP=1m1wgVuMWOSDMazg@mail.gmail.com>
 <0f41f776-9379-9ee6-df4b-e7538f69313e@gmail.com>
 <CAG48ez1e-xKoJ_1v0DGMZ62WQCG7o7AUw+89DYEVbDpHWrdweA@mail.gmail.com>
 <887d5a29-edaa-2761-1512-370c1f5c3a6f@gmail.com>
 <CAG48ez2TcWb6SQ86XRJDdN-Ab_gO9-sXgpFnJODMXH60mCkBJQ@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <a1921621-6656-c440-2117-2e5f1d31dafd@gmail.com>
Date: Mon, 26 Oct 2020 10:47:53 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.11.0
MIME-Version: 1.0
In-Reply-To: <CAG48ez2TcWb6SQ86XRJDdN-Ab_gO9-sXgpFnJODMXH60mCkBJQ@mail.gmail.com>
Content-Language: en-US
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Robert Sesek <rsesek@google.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 mtk.manpages@gmail.com, bpf <bpf@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Christian Brauner <christian@brauner.io>
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

Hi Jann,

On 10/26/20 10:32 AM, Jann Horn wrote:
> On Sat, Oct 24, 2020 at 2:53 PM Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>> On 10/17/20 2:25 AM, Jann Horn wrote:
>>> On Fri, Oct 16, 2020 at 8:29 PM Michael Kerrisk (man-pages)
>>> <mtk.manpages@gmail.com> wrote:
> [...]
>>>> I'm not sure if I should write anything about this small UAPI
>>>> breakage in BUGS, or not. Your thoughts?
>>>
>>> Thinking about it a bit more: Any code that relies on pause() or
>>> epoll_wait() not restarting is buggy anyway, right? Because a signal
>>> could also arrive directly before entering the syscall, while
>>> userspace code is still executing? So one could argue that we're just
>>> enlarging a preexisting race. (Unless the signal handler checks the
>>> interrupted register state to figure out whether we already entered
>>> syscall handling?)
>>
>> Yes, that all makes sense.
>>
>>> If userspace relies on non-restarting behavior, it should be using
>>> something like epoll_pwait(). And that stuff only unblocks signals
>>> after we've already past the seccomp checks on entry.
>>
>> Thanks for elaborating that detail, since as soon as you talked
>> about "enlarging a preexisting race" above, I immediately wondered
>> sigsuspend(), pselect(), etc.
>>
>> (Mind you, I still wonder about the effect on system calls that
>> are normally nonrestartable because they have timeouts. My
>> understanding is that the kernel doesn't restart those system
>> calls because it's impossible for the kernel to restart the call
>> with the right timeout value. I wonder what happens when those
>> system calls are restarted in the scenario we're discussing.)
> 
> Ah, that's an interesting edge case...

I'm going to drop a FIXME into the page source so that
there's a reminder of this issue in the next draft of 
the page, which I'm about to send out.

[...]

Thanks for checking the other pieces, Jann.

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
