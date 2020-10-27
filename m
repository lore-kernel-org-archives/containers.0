Return-Path: <SRS0=DMKn=EC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.8 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BC04C4363A
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 06:14:15 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8A8AD20874
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 06:14:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WHPoAqPE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A8AD20874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 19121866BA;
	Tue, 27 Oct 2020 06:14:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id JFKQliwHY59t; Tue, 27 Oct 2020 06:14:10 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 5958A865C1;
	Tue, 27 Oct 2020 06:14:10 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4D01AC088B;
	Tue, 27 Oct 2020 06:14:10 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 310D4C0051
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 06:14:09 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 1763086110
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 06:14:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id KfjgIhuOPxiy
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 06:14:07 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com
 [209.85.128.41])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 82D7A865C1
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 06:14:07 +0000 (UTC)
Received: by mail-wm1-f41.google.com with SMTP id k18so210313wmj.5
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Oct 2020 23:14:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=cc:subject:to:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=jfo31Pg0Y7mNoQfq9W2rm3LaBQTFU19PRMYhqK7FonA=;
 b=WHPoAqPE0Dd/RhKzTIxJwQH+MFeHpNXlvqU0h7kdlg1bE8i0aPbIeAZsk3hw1vgRip
 TQuBp4mC1gN35ZWzblEla1HJM8N6X7WKrWXST8kLDJqgH6QmT0N62BWUQc27l21rQZRq
 jVOKJjyoJdGIgtp4tJvmXDvChbS2xUqO8q3o+hpykn6hchir4SpuhRCH/uzoLfoqWsaG
 pd5iNEVN4FyK7ck56tlLqUQfijGNK6kBRDydA0jMzNA6pB0xG+y3qej+9mA6DVxDuJHR
 XaTtm5fjg8vmn1XStmo1KumJU/wBhVJ+ZDsH9Orr26Q+gTnUN4rpg5i67wjxI/966aDn
 lfoA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:cc:subject:to:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=jfo31Pg0Y7mNoQfq9W2rm3LaBQTFU19PRMYhqK7FonA=;
 b=N7AnYQ5DozfzZU8yDyewWlfNxTmg0aH4FXVuq08bbkspcPPi7Cc7lG1gtskY/LK+8X
 EBJW9UK3fYPHYz2f9ET/xJiK7amClnovd02A3Sc7iLeETDAGuypbOilrkmcNWi5UWuPK
 KsxZV7cp/ScQ7SGoUUV+UvCgTcRuFquHQLW/cRqqMs0KCmU14g51ZAmJ/qlNTnWaP+Xn
 2r6HsJo3DrpWfzVlRRulE8yTNhWR+ahvWZDvEDO9Ch3RXtz7KBuhr0xNHzr7wNr/3AZS
 2Gz4Qb9sWlBsiXVxkvUc3NkY2/9Qg75XnemjaONB9gTK1LsA5bQuiLFWQpU+dRAo9pcf
 K67w==
X-Gm-Message-State: AOAM5339X0R47zUjfPUtHzoZnWzmD3spc3WvZxK7p2xbMKsD+tyv7gho
 QlYChn3v2HLP3MmaI85+99o=
X-Google-Smtp-Source: ABdhPJyeBBAzzf4v0qJDy0pr93s4VjEbFAKQ9XmS93oq+JSHL537pXNmrsKz2g4mKxXCEYsD92OKYw==
X-Received: by 2002:a1c:b486:: with SMTP id d128mr813191wmf.164.1603779245705; 
 Mon, 26 Oct 2020 23:14:05 -0700 (PDT)
Received: from ?IPv6:2001:a61:245a:d801:2e74:88ad:ef9:5218?
 ([2001:a61:245a:d801:2e74:88ad:ef9:5218])
 by smtp.gmail.com with ESMTPSA id v189sm622729wmg.14.2020.10.26.23.14.03
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Mon, 26 Oct 2020 23:14:04 -0700 (PDT)
Subject: Re: For review: seccomp_user_notif(2) manual page
To: Jann Horn <jannh@google.com>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
 <CAG48ez1VOUEHVQyo-2+uO7J+-jN5rh7=KmrMJiPaFjwCbKR1Sg@mail.gmail.com>
 <20200930232456.GB1260245@cisco>
 <CAG48ez2xn+_KznEztJ-eVTsTzkbf9CVgPqaAk7TpRNAqbdaRoA@mail.gmail.com>
 <CAG48ez3kpEDO1x_HfvOM2R9M78Ach9O_4+Pjs-vLLfqvZL+13A@mail.gmail.com>
 <656a37b5-75e3-0ded-6ba8-3bb57b537b24@gmail.com>
 <CAG48ez2Uy8=Tz9k1hcr0suLPHjbJi1qUviSGzDQ-XWEGsdNU+A@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <e2643168-b5d5-4d8c-947a-7895bcabc268@gmail.com>
Date: Tue, 27 Oct 2020 07:14:03 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.11.0
MIME-Version: 1.0
In-Reply-To: <CAG48ez2Uy8=Tz9k1hcr0suLPHjbJi1qUviSGzDQ-XWEGsdNU+A@mail.gmail.com>
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

On 10/26/20 4:54 PM, Jann Horn wrote:
> On Sun, Oct 25, 2020 at 5:32 PM Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
[...]
>> I tried applying the patch below to vanilla 5.9.0.
>> (There's one typo: s/ENOTCON/ENOTCONN).
>>
>> It seems not to work though; when I send a signal to my test
>> target process that is sleeping waiting for the notification
>> response, the process enters the uninterruptible D state.
>> Any thoughts?
> 
> Ah, yeah, I think I was completely misusing the wait API. I'll go change that.
> 
> (Btw, in general, for reports about hangs like that, it can be helpful
> to have the contents of /proc/$pid/stack. And for cases where CPUs are
> spinning, the relevant part from the output of the "L" sysrq, or
> something like that.)

Thanks for the tipcs!

> Also, I guess we can probably break this part of UAPI after all, since
> the only user of this interface seems to currently be completely
> broken in this case anyway? So I think we want the other
> implementation without the ->canceled_reqs logic after all.

Okay.

> I'm a bit on the fence now on whether non-blocking mode should use
> ENOTCONN or not... I guess if we returned ENOENT even when there are
> no more listeners, you'd have to disambiguate through the poll()
> revents, which would be kinda ugly?

I must confess, I'm not quite clear on which two cases you 
are trying to distinguish. Can you elaborate?

> I'll try to turn this into a proper patch submission...

Thank you!!

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
