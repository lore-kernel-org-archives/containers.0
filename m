Return-Path: <SRS0=WbUC=DI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6D57C4727C
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 07:49:26 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 17F2520838
	for <containers@archiver.kernel.org>; Thu,  1 Oct 2020 07:49:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iPFug+KD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17F2520838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 8F3F5844CC;
	Thu,  1 Oct 2020 07:49:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id RamVGq40ZVfM; Thu,  1 Oct 2020 07:49:25 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 4967886C69;
	Thu,  1 Oct 2020 07:49:24 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3FF96C0889;
	Thu,  1 Oct 2020 07:49:24 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4A4B5C0051
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 07:49:23 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 32856869F8
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 07:49:23 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ZrihyMR0KpIk
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 07:49:22 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wr1-f43.google.com (mail-wr1-f43.google.com
 [209.85.221.43])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 4E554869EA
 for <containers@lists.linux-foundation.org>;
 Thu,  1 Oct 2020 07:49:22 +0000 (UTC)
Received: by mail-wr1-f43.google.com with SMTP id w5so4466638wrp.8
 for <containers@lists.linux-foundation.org>;
 Thu, 01 Oct 2020 00:49:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=cc:subject:to:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=+NcXdkZLuqZEhsrjLZ9EomnWbR0CtRb+cHGEY+PT1Ow=;
 b=iPFug+KDfRfSjnv8hr1xM23l+L9MwjkEkMoNtiau31vGWusKlYxGwKmr8yZ1elD1rt
 E1wi3701TuTqy/vljRGWKqWgztLAX00MBnVXCGq69fg+bCptBy7U+3Ep56DG9xW7ZYh7
 6Jqvw8r/E88ACAm6V/9nwKIeBN8CjqBTojTqP9rHYiXsVSTd5WpnxNYZJpH1ZdQkd1XS
 yEBFgcMs8RNLrc9qh/ojt7zWiSsqfrqQlqIqW8d6ooLedRHqwAkClZu7n85/q5hvhDzW
 iR1uu9MKfWxf56o5xh6sFzwjBxFqzGCTuEwD1jB0FTyeNH0ab6ygPdmGkQMsKtXVJMnG
 Je8g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:cc:subject:to:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=+NcXdkZLuqZEhsrjLZ9EomnWbR0CtRb+cHGEY+PT1Ow=;
 b=kZoudA5lewAikqe7T873TQn34MhRlXjidOx8dJwWGbIrdBd9jbqqIxSVbhWI+qbGpx
 9Fp+cDJLyR90j82lwOU2FqfcxI5aIRYzw+r/sPdE8WlYqYLfhSVEFvzkr86GWIftp5v3
 tr8lg2S20K4kmH7hEcaAHd1G5dJmdvBovE2dRR6JltZ/dARnCvIudxG8cWFv7bbcwirq
 UaYzVPb0KAJMeK/8jJdL1vIeayArMgbSqxU9kAzo0fLqK6qBTK4PF5wFmnEhk9aVQsHy
 RpCL9ghFC9ODYgEnOoBllV4bbUMgJlmEJzX6BybqTkW00Pd/qGyw/MQMdGi43Yrl1YfM
 1iSw==
X-Gm-Message-State: AOAM533Lsfo/1+FcJTqd+seWS46mj74cY3bL42OG95f4S8OwimznmakL
 Yp41oOUR9R5BDdFSgw+BWP4=
X-Google-Smtp-Source: ABdhPJxihcQDVW1G0d43dfFRvyTn9xsOufQiCocx9h1OGoc1GRDSIrP+1BQ44PkXDiveoDcyuO7mlw==
X-Received: by 2002:adf:fe42:: with SMTP id m2mr7149297wrs.367.1601538560582; 
 Thu, 01 Oct 2020 00:49:20 -0700 (PDT)
Received: from ?IPv6:2001:a61:2479:6801:d8fe:4132:9f23:7e8f?
 ([2001:a61:2479:6801:d8fe:4132:9f23:7e8f])
 by smtp.gmail.com with ESMTPSA id u2sm8313285wre.7.2020.10.01.00.49.19
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Thu, 01 Oct 2020 00:49:19 -0700 (PDT)
Subject: Re: For review: seccomp_user_notif(2) manual page
To: Jann Horn <jannh@google.com>, Tycho Andersen <tycho@tycho.pizza>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
 <CAG48ez1VOUEHVQyo-2+uO7J+-jN5rh7=KmrMJiPaFjwCbKR1Sg@mail.gmail.com>
 <20200930232456.GB1260245@cisco>
 <CAG48ez2xn+_KznEztJ-eVTsTzkbf9CVgPqaAk7TpRNAqbdaRoA@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <f70836c2-927d-6de5-3022-4ffac2cba924@gmail.com>
Date: Thu, 1 Oct 2020 09:49:18 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.10.0
MIME-Version: 1.0
In-Reply-To: <CAG48ez2xn+_KznEztJ-eVTsTzkbf9CVgPqaAk7TpRNAqbdaRoA@mail.gmail.com>
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

On 10/1/20 3:52 AM, Jann Horn wrote:

[...]

> I guess this is a nice point in favor of Michael's usual complaint
> that if there are no man pages for a feature by the time the feature
> lands upstream, there's a higher chance that the UAPI will suck
> forever...

Thanks for saving me the trouble of saying that (again).

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
