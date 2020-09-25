Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BE08C4346E
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 03:28:45 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F1F262176B
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 03:28:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OiYYJ/us"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1F262176B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id C7A03869EC;
	Fri, 25 Sep 2020 03:28:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5qjS0FVOs-cq; Fri, 25 Sep 2020 03:28:43 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id DCA7B867FD;
	Fri, 25 Sep 2020 03:28:43 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id C0BECC0859;
	Fri, 25 Sep 2020 03:28:43 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0003DC0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:28:42 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id ED92386923
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:28:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id wbFxG0GF9hdT
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:28:42 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com
 [209.85.215.193])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 774BC867FD
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:28:42 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id l71so1368904pge.4
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:28:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=JKwaSEBh/aNFcHLbsrqXTKnHnGZtGuyc7kM8iGIPRLM=;
 b=OiYYJ/us006aCQf8GreRu+v+umHyKuyJ53tWXgVLYKCgpjHSbVOGfP9NeOMrPERPkN
 fmlosi7oYA0P9EtBqPMUJqOWUsBwE+ibW/ooPeQ70jKnWG4370Zrtv40OVzlDx0ZEf4r
 AnlTwk3rBGD2VttqfanX6R93rzUfDik7jwy84XIJcJg1TZrTaYfhfWBqM7TfyXykz2DB
 QI8Erwr5nqcOMAAj0di4ks6hTFBMfpD2NyTht2eaWuRHfTBdjkof5/3aHKUztSzFS0N5
 ZRYp0xekaQ7wZSDR9P6FISnEXN0RNXNFo24NqCRlyvr1bYMWDZX9QvG9s+xEjqGobfLo
 RAEw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=JKwaSEBh/aNFcHLbsrqXTKnHnGZtGuyc7kM8iGIPRLM=;
 b=rIGAVIBg4QQsJlFdmP8oY+eUMlADSEwLFpZ3QsSCaOwHnWZ7NunRRSHD4Cw6PJ9bZf
 WZnOSVYCA7qgK9shj3yKdZ2F9yBv7gyIHeAa/Z4ZKuHAKoUfh6yfrq7o6Neujo3RnH0N
 FeJzxtl89ufnrA5gcn5A6waEDwPFKvzQaevso70TMFfTlZ+tcDqjDrGmXJ+VWq+A+A+N
 hm9vVDujhQD+uDE+7SQ015Vc5wuwMTWbMjqj1DKlDXvbngb/llCd3MIh2RxxYfT8a2el
 GL3jPYdbK8K7jLyl9aVBoV3OLSxXPCtIaszsV0ZM99WQBWdy+zistpUqSvgNUcOJbCjx
 Wrpg==
X-Gm-Message-State: AOAM533IuX8IbsskoMu81N7KsNkkKIsTxRSLqm8YnWDQB6M3xM2iJ3k0
 TQ8SnB34BeANCTCoWSQlA91Sl1x1sfT64FmTEJE=
X-Google-Smtp-Source: ABdhPJzyyAhHtoK2wZHqoUFbZHJWRTfpD857YUtUND4/x9KBeMbRkdMSgFIGeLqMu6/zEKEJVS4vbV6+V7CgGFtQdUk=
X-Received: by 2002:a63:511d:: with SMTP id f29mr1846448pgb.11.1601004522041; 
 Thu, 24 Sep 2020 20:28:42 -0700 (PDT)
MIME-Version: 1.0
References: <b792335294ee5598d0fb42702a49becbce2f925f.1600661419.git.yifeifz2@illinois.edu>
 <202009241658.A062D6AE@keescook>
 <CABqSeAQ=joheH+0LUZ201U-XwFFsHN3Ouo5FGoscUwn+itkL2w@mail.gmail.com>
 <202009242000.DE12689BD8@keescook>
In-Reply-To: <202009242000.DE12689BD8@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 24 Sep 2020 22:28:31 -0500
Message-ID: <CABqSeATWoFXM6uBHywVrJCo1JvCwHZ6gyegiJp_y4nr97BY-3Q@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 2/6] asm/syscall.h: Add syscall_arches[] array
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

On Thu, Sep 24, 2020 at 10:09 PM Kees Cook <keescook@chromium.org> wrote:
> Right, sorry, I may not have been clear. When building my RFC I noticed
> that I couldn't use NR_syscall very "early" in the header file include
> stack on arm64, which complicated things. So I guess what I mean is
> something like "it's probably better to do all these seccomp-specific
> macros/etc in asm/include/seccomp.h rather than in syscall.h because I
> know at least one architecture that might cause trouble."

Ah. Makes sense.

> Ironicailly, that's the only place I actually know for sure where people
> using x32 because it shows measurable (10%) speed-up for builders:
> https://lore.kernel.org/lkml/CAOesGMgu1i3p7XMZuCEtj63T-ST_jh+BfaHy-K6LhgqNriKHAA@mail.gmail.com

Wow. 10% is significant. Makes you wonder why x32 hasn't conquered the world.

> So, yes, as you and Jann both point out, it wouldn't be terrible to just
> ignore x32, it seems a shame to penalize it. That said, if the masking
> step from my v1 is actually noticable on a native workload, then yeah,
> probably x32 should be ignored. My instinct (not measured) is that it's
> faster than walking a small array.[citation needed]

My instinct: should be pretty similar, with the loop unrolled.

You convince me that penalizing supporting x32 would be a pity :( The
10% is so nice I want it.

> It's easier to do a per-arch revert (i.e. all the -stable tree
> machinery, etc) with a single SHA instead of having to write a partial
> revert, etc.

I see. Thanks for clarifying.

How about this? Rather than specifically designing names for bitmasks
(native, compat, multiplex), just have SECCOMP_ARCH_{1,2,3}? Each arch
number would provide the size of the bitmap and a static inline
function to check the given seccomp_data belongs to the arch and if
so, the order of the bit in the bitmap. There is no need for the
shifts and madness in seccomp.c; it's arch-dependent code in their own
seccomp.h. We let the preprocessor and compiler to make things
optimized.

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
