Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A102C2D0E2
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 13:59:08 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1687820888
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 13:59:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iJNOg80z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1687820888
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 7975986B96;
	Thu, 24 Sep 2020 13:59:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0x7JZ1qiTEf3; Thu, 24 Sep 2020 13:59:06 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id D2C5386B01;
	Thu, 24 Sep 2020 13:59:06 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B88CCC0889;
	Thu, 24 Sep 2020 13:59:06 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 5734CC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 13:59:05 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 52B1F8621D
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 13:59:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id B7HFi98fPPkd
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 13:59:04 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com
 [209.85.214.194])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id CF3F58665F
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 13:59:04 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id m15so1714430pls.8
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 06:59:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=2VqKeVQ1TTob+l57hN7CdbLV7X6Dn8oLhoInjEYhe84=;
 b=iJNOg80zt0Ah6l1cspo0ZJjdpKbJBzcvljzpu8+RCIbOrUi40Z1r3x2wlxIWpPzyK+
 eLb7EzZ3TJE+vkIwK2o9x7A+85aoWnqvzUIvkM9O+WkPQwDljpljo07XtixsC/idbiW6
 I5M/0BUAhIm+I37qSCiHIGqWqxsSIrJlkYRe9nvlaEabgDuxyKZeUYBWj1bNi6S9L6iP
 v6NgR7zVnmBQ5+hA1BQ9E+BznV19j8PON6LZah+TVe5iAr7w14Fa3n/BBV7TE960fC+D
 dBaJUb53KMUS/SQi/beDRYuLTahpqbK9FjRD9R5OvwgGQyFM+I59lTUFzO0RrZTU9sIm
 8b1A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=2VqKeVQ1TTob+l57hN7CdbLV7X6Dn8oLhoInjEYhe84=;
 b=JSmgZVh3cbYdYlyoqvIaLsI8EYoozMP6WtY1XqSgxJILdmRIhs5zV/D/kPIAV003GQ
 Z6hZv0FU13Vmn3GgshHBBgkWa/lBBEAmi/P/FFq8/oXb7jjai9TEuBhhxOCvGmABNWg6
 d48ZfiPU/MgL21gLtrzYTQflle/yj6sdJGxPKgXgv8oih5LhyC8JCPAnZgoeIeT5UtR7
 iKtO/3WZACDYK1sNKvCbcFGnaykUhtY1dtpwCuub5zapUNnAYoyrNvB0yY5YxWEMSNO9
 AnZsRjw4sbBVNDLFSMZVbcQsF3dsFKaGzeumWt4s0g6APa2DdSggsvJTIS2sgTSQf31u
 2+VQ==
X-Gm-Message-State: AOAM533n4pVF96r8ee4gOcB+BJuupOmfv10fDj/ov+z1V8l5AiyOTYS3
 rODHBoOJlVhR0zcnEDlqndDw69N9Oid3NtXlY7o=
X-Google-Smtp-Source: ABdhPJyvl17/a3pu9tlrQgIEKe6i/q2CoeM5t9WnXhUUjEFht9tfPbDh6SnabQyrDZfNtd1ZmQpcooqGFz/nEPw+tIA=
X-Received: by 2002:a17:90b:4b82:: with SMTP id
 lr2mr4074041pjb.184.1600955944381; 
 Thu, 24 Sep 2020 06:59:04 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <43039bb6-9d9f-b347-fa92-ea34ccc21d3d@rasmusvillemoes.dk>
In-Reply-To: <43039bb6-9d9f-b347-fa92-ea34ccc21d3d@rasmusvillemoes.dk>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 24 Sep 2020 08:58:53 -0500
Message-ID: <CABqSeAQKksqM1SdsQMoR52AJ5CY0VE2tk8-TJaMuOrkCprQ0MQ@mail.gmail.com>
Subject: Re: [PATCH v1 0/6] seccomp: Implement constant action bitmaps
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
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

On Thu, Sep 24, 2020 at 8:46 AM Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
> But one thing I'm wondering about and I haven't seen addressed anywhere:
> Why build the bitmap on the kernel side (with all the complexity of
> having to emulate the filter for all syscalls)? Why can't userspace just
> hand the kernel "here's a new filter: the syscalls in this bitmap are
> always allowed noquestionsasked, for the rest, run this bpf". Sure, that
> might require a new syscall or extending seccomp(2) somewhat, but isn't
> that a _lot_ simpler? It would probably also mean that the bpf we do get
> handed is a lot smaller. Userspace might need to pass a couple of
> bitmaps, one for each relevant arch, but you get the overall idea.

Perhaps. The thing is, the current API expects any filter attaches to
be "additive". If a new filter gets attached that says "disallow read"
then no matter whatever has been attached already, "read" shall not be
allowed at the next syscall, bypassing all previous allowlist bitmaps
(so you need to emulate the bpf anyways here?). We should also not
have a API that could let anyone escape the secomp jail. Say "prctl"
is permitted but "read" is not permitted, one must not be allowed to
attach a bitmap so that "read" now appears in the allowlist. The only
way this could potentially work is to attach a BPF filter and a bitmap
at the same time in the same syscall, which might mean API redesign?

> I'm also a bit worried about the performance of doing that emulation;
> that's constant extra overhead for, say, launching a docker container.

IMO, launching a docker container is so expensive this should be negligible.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
