Return-Path: <SRS0=KOwt=DF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AC69C2D0A8
	for <containers@archiver.kernel.org>; Mon, 28 Sep 2020 20:16:18 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E1DA7207E8
	for <containers@archiver.kernel.org>; Mon, 28 Sep 2020 20:16:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NZZZsyHQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1DA7207E8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 711FA86462;
	Mon, 28 Sep 2020 20:16:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id vqbIFm2x36sn; Mon, 28 Sep 2020 20:16:17 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 06B118642E;
	Mon, 28 Sep 2020 20:16:17 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D8CC6C0889;
	Mon, 28 Sep 2020 20:16:16 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id AAE28C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 28 Sep 2020 20:16:15 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 9426A858BA
 for <containers@lists.linux-foundation.org>;
 Mon, 28 Sep 2020 20:16:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id nQgu1fGPTxPu
 for <containers@lists.linux-foundation.org>;
 Mon, 28 Sep 2020 20:16:14 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com
 [209.85.215.193])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 8452F858B3
 for <containers@lists.linux-foundation.org>;
 Mon, 28 Sep 2020 20:16:14 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id e18so1872700pgd.4
 for <containers@lists.linux-foundation.org>;
 Mon, 28 Sep 2020 13:16:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=n5fs9N7O7kX4WZI+JaZ5Zk9F/Ve3sjOEq/KE/y3eZEA=;
 b=NZZZsyHQde4tfNecmEB/UwHVyhxXIFIl6/O1nny0WP+j9dJhH+pBYRPhP8MSl140QK
 InD9RjbRzHGBObk/JneSjeXMH4JucKSx5DzB6OkVmm8Eh5WPSjtBdcsguuEF+L1tOBHS
 0teuOg7LPUKGVf57kIlbHTpiFvwupixku8VU27OI5vaz5j1nxcPKWmaLg7rMWTJrswgI
 C9T0DsyuqYa5HIzqBoRia9AbvGc0R5CX+a2uZ/KLHwrWKmVetxKxydeVw/vuljEdRP4D
 hE89hploklteLSgB9Ht4BjNaRzMziS1T7Le8UKp1ypjmAGEq1T721TB89vB+LHMCBIGf
 sQUw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=n5fs9N7O7kX4WZI+JaZ5Zk9F/Ve3sjOEq/KE/y3eZEA=;
 b=N3spEvzKrejvMZGABvXVQ6pmafOoqwNBHMPI82WaD6PCUZF1fpdmYCPcnotQU2bmN+
 AMzohmQmVvyZdRxrKXGgSjr1dRXgtgQRZIaeug/Pns+k0YBR9jC4GfAM7fF87fMTbGrc
 t+GLK7sIU+lAkXXMx7edlTkH/8GPhtt5chtc8CSyOGbKCYnII+XnYA1fVIjEqSrLMGCA
 fS7TM88BB803DGZzQxcOuZVsKrNN5DZeAc8qVFjYxXZPL8OUnAw8kNlssPw4CmOyjrM6
 ImJqoM50yyg0v+CjKSU9m8m6wXOG8dEB46FQm1l7ue3RogFB29ct8FSxdd2p0wULR/vL
 Bmdw==
X-Gm-Message-State: AOAM532EivR1a9pewP9o3sVCq9vZnuavoWGdycA3x7K7s9O0bE5BM9Ck
 HnS8LZK3jqMaY16CC4+sIrLAhaTeEKAUE5h3xkw=
X-Google-Smtp-Source: ABdhPJwD//xv3MXMApixX8ayuv2V0hLURpgssTUGig7LrHLy6w9oveNK0ZVrUSLMjUtZsjaxR0mfr9O6qxu7It2uvY8=
X-Received: by 2002:a17:902:778e:b029:d2:8046:efe2 with SMTP id
 o14-20020a170902778eb02900d28046efe2mr1026132pll.44.1601324174119; Mon, 28
 Sep 2020 13:16:14 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <43039bb6-9d9f-b347-fa92-ea34ccc21d3d@rasmusvillemoes.dk>
 <CABqSeAQKksqM1SdsQMoR52AJ5CY0VE2tk8-TJaMuOrkCprQ0MQ@mail.gmail.com>
 <27b4ef86-fee5-fc35-993b-3352ce504c73@rasmusvillemoes.dk>
 <CABqSeATHtvA7qm7j_kxBsbxRCd5B=MHtxGdsYsXEJ-TRRYKTgA@mail.gmail.com>
 <CABqSeASMObs7HtwfM=ua9Tbx1mfHZaxCMWD6AP6-6hR4-Xcn=Q@mail.gmail.com>
 <202009281259.D7D18AE95@keescook>
In-Reply-To: <202009281259.D7D18AE95@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Mon, 28 Sep 2020 15:16:02 -0500
Message-ID: <CABqSeAT4Qaq6BrYYc2S974b8ejKB4j4R+y3tMk_P7wTPxYNgGg@mail.gmail.com>
Subject: Re: [PATCH v1 0/6] seccomp: Implement constant action bitmaps
To: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Will Drewry <wad@chromium.org>,
 Jann Horn <jannh@google.com>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Rasmus Villemoes <linux@rasmusvillemoes.dk>,
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

On Mon, Sep 28, 2020 at 3:04 PM Kees Cook <keescook@chromium.org> wrote:
> Regardless, let's take things one step at a time. First, let's do
> the simplest version of the feature, and then let's look at further
> optimizations.
>
> Can you send a v3 and we can continue from there?

ok, will do later tonight / tomorrow.

YiFeiZhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
