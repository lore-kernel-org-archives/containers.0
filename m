Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0596C4363D
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 06:25:10 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AA8D921D7F
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 06:25:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=rasmusvillemoes.dk header.i=@rasmusvillemoes.dk header.b="ShdjI09H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA8D921D7F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rasmusvillemoes.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 2391F86BAD;
	Fri, 25 Sep 2020 06:25:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8I90Dlyct8fv; Fri, 25 Sep 2020 06:25:08 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 0D33C8698D;
	Fri, 25 Sep 2020 06:25:08 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E8845C0889;
	Fri, 25 Sep 2020 06:25:07 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 825ABC0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 06:25:06 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 763FF20489
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 06:25:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id t9sozRqyudMg
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 06:25:04 +0000 (UTC)
X-Greylist: delayed 16:44:06 by SQLgrey-1.7.6
Received: from mail-lf1-f68.google.com (mail-lf1-f68.google.com
 [209.85.167.68])
 by silver.osuosl.org (Postfix) with ESMTPS id 3525920445
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 06:25:03 +0000 (UTC)
Received: by mail-lf1-f68.google.com with SMTP id z17so1485277lfi.12
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 23:25:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=rasmusvillemoes.dk; s=google;
 h=subject:to:cc:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=PHvJCnf/e3w+kWddJhhNAUVQMYCOoytl80Q0gn/kXVM=;
 b=ShdjI09HEYlSizD4uVM0B2rxoJnN8U2bQb09Wy+Bt5b05y7VaybgV6048Ct9oMNFC0
 5ZuNRFl1xvZT54kcWZm6nV7++CSa/aNWkwsaYltPyAOfaCPz1p9rS80d1afmgWjIiLfk
 QByKHsiiFOXOgqaUReS6BxYLxrysJg3zJgNro=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:subject:to:cc:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=PHvJCnf/e3w+kWddJhhNAUVQMYCOoytl80Q0gn/kXVM=;
 b=cZ7YuMJBKU/dvN+v4HbnVrSuyFs/4dMCs+8VJiCWfLFLHov8O7PaUbnt9QqxLBKQJs
 l2v1AZW+TakXJ+sp/42KIhy8uw3/krjnrf/04uKsXRnFG0Xm4FQ1kVM+vOajnil1lxji
 7/WaCFpWGyBFa0Gnkp0MKpsR2bytpgi5I2/7na5+rPA9+0BWWispvaC6PotiNgVIkBSY
 +zmHYdyfU46CTvReK1MdeDToNvBK15hAfC1YvZfribeJecXrErXhaco6OWI+EQpB8/DX
 kQHJDFzqTaGfiHvGvykbQ5RbUObbTY1yFXULo5jWz4XfTM8UOWjauuWHa4EsxYKekckt
 zVtA==
X-Gm-Message-State: AOAM530lilvUToDqYqP5A1pkLyi/wLSQVGIfyGBtdg8c9o3wQw6sBqRP
 VJZjChE34OFuEbr2eGYx3VexU2Ne+bOFWxP1P7A=
X-Google-Smtp-Source: ABdhPJzIM58jxMOmE2zPrllWl3bqZQksl9iktnNDkyFfkSPoqVYRt7Y7NFlYBnC9G6KhTmZPTNAT/w==
X-Received: by 2002:a17:906:841a:: with SMTP id
 n26mr1099782ejx.213.1601013408160; 
 Thu, 24 Sep 2020 22:56:48 -0700 (PDT)
Received: from [192.168.1.149] (5.186.115.188.cgn.fibianet.dk. [5.186.115.188])
 by smtp.gmail.com with ESMTPSA id s30sm1055003edc.8.2020.09.24.22.56.46
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Thu, 24 Sep 2020 22:56:47 -0700 (PDT)
Subject: Re: [PATCH v1 0/6] seccomp: Implement constant action bitmaps
To: YiFei Zhu <zhuyifei1999@gmail.com>,
 Rasmus Villemoes <linux@rasmusvillemoes.dk>
References: <20200923232923.3142503-1-keescook@chromium.org>
 <43039bb6-9d9f-b347-fa92-ea34ccc21d3d@rasmusvillemoes.dk>
 <CABqSeAQKksqM1SdsQMoR52AJ5CY0VE2tk8-TJaMuOrkCprQ0MQ@mail.gmail.com>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <27b4ef86-fee5-fc35-993b-3352ce504c73@rasmusvillemoes.dk>
Date: Fri, 25 Sep 2020 07:56:46 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.10.0
MIME-Version: 1.0
In-Reply-To: <CABqSeAQKksqM1SdsQMoR52AJ5CY0VE2tk8-TJaMuOrkCprQ0MQ@mail.gmail.com>
Content-Language: en-US
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

On 24/09/2020 15.58, YiFei Zhu wrote:
> On Thu, Sep 24, 2020 at 8:46 AM Rasmus Villemoes
> <linux@rasmusvillemoes.dk> wrote:
>> But one thing I'm wondering about and I haven't seen addressed anywhere:
>> Why build the bitmap on the kernel side (with all the complexity of
>> having to emulate the filter for all syscalls)? Why can't userspace just
>> hand the kernel "here's a new filter: the syscalls in this bitmap are
>> always allowed noquestionsasked, for the rest, run this bpf". Sure, that
>> might require a new syscall or extending seccomp(2) somewhat, but isn't
>> that a _lot_ simpler? It would probably also mean that the bpf we do get
>> handed is a lot smaller. Userspace might need to pass a couple of
>> bitmaps, one for each relevant arch, but you get the overall idea.
> 
> Perhaps. The thing is, the current API expects any filter attaches to
> be "additive". If a new filter gets attached that says "disallow read"
> then no matter whatever has been attached already, "read" shall not be
> allowed at the next syscall, bypassing all previous allowlist bitmaps
> (so you need to emulate the bpf anyways here?). We should also not
> have a API that could let anyone escape the secomp jail. Say "prctl"
> is permitted but "read" is not permitted, one must not be allowed to
> attach a bitmap so that "read" now appears in the allowlist. The only
> way this could potentially work is to attach a BPF filter and a bitmap
> at the same time in the same syscall, which might mean API redesign?

Yes, the man page would read something like

       SECCOMP_SET_MODE_FILTER_BITMAP
              The system calls allowed are defined by a pointer to a
Berkeley Packet Filter (BPF) passed  via  args.
              This argument is a pointer to a struct sock_fprog_bitmap;

with that struct containing whatever information/extra pointers needed
for passing the bitmap(s) in addition to the bpf prog.

And SECCOMP_SET_MODE_FILTER would internally just be updated to work
as-if all-zero allow-bitmaps were passed along. The internal kernel
bitmap would just be the and of the bitmaps in the filter stack.

Sure, it's UAPI, so would certainly need more careful thought on details
of just how the arg struct looks like etc. etc., but I was wondering why
it hadn't been discussed at all.

>> I'm also a bit worried about the performance of doing that emulation;
>> that's constant extra overhead for, say, launching a docker container.
> 
> IMO, launching a docker container is so expensive this should be negligible.

Regardless, I'd like to see some numbers, certainly for the "how much
faster does a getpid() or read() or any of the other syscalls that
nobody disallows" get, but also "what's the cost of doing that emulation
at seccomp(2) time".

Rasmus
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
