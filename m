Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E9C5C4363D
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 16:39:35 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C9D6E206BE
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 16:39:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NUk6qpse"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9D6E206BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 7CA6E8762B;
	Fri, 25 Sep 2020 16:39:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Zo9GT2e0DnwJ; Fri, 25 Sep 2020 16:39:34 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 0418B87625;
	Fri, 25 Sep 2020 16:39:33 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D15BCC0890;
	Fri, 25 Sep 2020 16:39:33 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A0773C0859
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 16:39:31 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 884C320491
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 16:39:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id GP7Z-TYZRJGb
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 16:39:31 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com
 [209.85.210.196])
 by silver.osuosl.org (Postfix) with ESMTPS id E93BD2037B
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 16:39:30 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id z19so3699117pfn.8
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 09:39:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=We4c1ICLefb45lgkpgey0ZztAECSO/V5IQ3/lYTx0I4=;
 b=NUk6qpse0T5FTgje3rJBQ8NoqKcjBaGi1nGfHxq1QhIPF5SjYlPh3mnQLDGvqCx2q6
 NYgDBzzQqFIPF9c1TJsVpHRF5f4xMNo8b/R00Gy4WNe1xslqvIP+6pLdnLRGAuDU/dF5
 oSVnv/qbSGjBwz2WcdALRvAectNhf/UmU9IwAHkZGSkqmxt34tNT2wRURDE0Dz0SMIL+
 JSHwAradhStfE+oo2ycMnVy+YfyQsqK1B/QqSVA177v7AmiI5cAMeveKTSr3FWxLaXsG
 LSz5zsiSLQX52ziSoCbm1T/Gcv6BFthqkbh6Z3OWA+tTrIMDh5P/eXZErwLuuWSxUvfI
 bH2w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=We4c1ICLefb45lgkpgey0ZztAECSO/V5IQ3/lYTx0I4=;
 b=gO5a/DhGBNo7i1j7MmQkxZoJVjHExCNSdQNbihnTpDVkINO19/aXx6qC9ocggEebQe
 z/HvG9UIOo+Tl3zrJ4sl70C95sOgFIgDcianYkIF4xaAEgDuupQf+p7J/hhRjn38eils
 TSo/WojymrGKNpHETpHDXAjCVqnjTSsJAsVAyJxtw5RDN8g7YrSGLY9ryYUpGRqUBvPk
 42RUkovJ/Wu2D+UjaVqUaq92sQgUkc/nJ16oYp8uYd+flVltwbtL8Wfk7drvne1N2pyb
 PPMxBzeo9v/zSliLBX/sq68941osBFe+XmE6LIZ+LebuLsNcOIFAlsd38zEyIiMhsua0
 1H5g==
X-Gm-Message-State: AOAM531xmq+7pwrj7uKB3CC/tLE3OrmI3fawpX0Nln/ANvLsUw1m9/0D
 e8hTnzneo/EENnAW74Si2d04srkXvCKclCkcv78=
X-Google-Smtp-Source: ABdhPJw59LuaxUUp30+zgQCKzKm6ocn/Skfo2I74OYhGOoc6OavtsdxUPBqj79tXlm1rgIZZur3Rwdl8twbiU7usz6Q=
X-Received: by 2002:aa7:8d4c:0:b029:150:f692:4129 with SMTP id
 s12-20020aa78d4c0000b0290150f6924129mr114530pfe.11.1601051970465; Fri, 25 Sep
 2020 09:39:30 -0700 (PDT)
MIME-Version: 1.0
References: <b792335294ee5598d0fb42702a49becbce2f925f.1600661419.git.yifeifz2@illinois.edu>
 <202009241658.A062D6AE@keescook>
 <CABqSeAQ=joheH+0LUZ201U-XwFFsHN3Ouo5FGoscUwn+itkL2w@mail.gmail.com>
 <202009242000.DE12689BD8@keescook>
 <CABqSeATWoFXM6uBHywVrJCo1JvCwHZ6gyegiJp_y4nr97BY-3Q@mail.gmail.com>
In-Reply-To: <CABqSeATWoFXM6uBHywVrJCo1JvCwHZ6gyegiJp_y4nr97BY-3Q@mail.gmail.com>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Fri, 25 Sep 2020 11:39:18 -0500
Message-ID: <CABqSeARSufFuFf85VFyTXNkfcWOPE5d9H2C-OuYza4WDdk70fw@mail.gmail.com>
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

On Thu, Sep 24, 2020 at 10:28 PM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> Ah. Makes sense.
>
> > Ironicailly, that's the only place I actually know for sure where people
> > using x32 because it shows measurable (10%) speed-up for builders:
> > https://lore.kernel.org/lkml/CAOesGMgu1i3p7XMZuCEtj63T-ST_jh+BfaHy-K6LhgqNriKHAA@mail.gmail.com
>
> Wow. 10% is significant. Makes you wonder why x32 hasn't conquered the world.
>
> > So, yes, as you and Jann both point out, it wouldn't be terrible to just
> > ignore x32, it seems a shame to penalize it. That said, if the masking
> > step from my v1 is actually noticable on a native workload, then yeah,
> > probably x32 should be ignored. My instinct (not measured) is that it's
> > faster than walking a small array.[citation needed]
>
> You convince me that penalizing supporting x32 would be a pity :( The
> 10% is so nice I want it.

I'm rethinking this -- the majority of our users will not use x32. I
don't think it's that useful for the majority to run all the
simulations and have the memory footprint if only a small minority
will use it.

I also just checked Debian, and it has boot-time disabling of the x32
arch downstream [1]:
CONFIG_X86_X32=y
CONFIG_X86_X32_DISABLED=y

Which means we will still generate all the code for x32 in seccomp
even though people probably won't be using it...

I also talked to some of my peers and they had a point regarding how
x32 limiting address space to 4GiB is very harsh on many modern
language runtimes, so even though it provides a 10% speed boost, its
adoption is hard -- one has to compile all the C libraries in x32 in
addition to x86_64, since one would have programs needing > 4GiB
address space needing x86_64 version of the libraries.

[1] https://wiki.debian.org/X32Port

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
