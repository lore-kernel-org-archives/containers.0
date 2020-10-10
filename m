Return-Path: <SRS0=Ilr0=DR=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C805C433E7
	for <containers@archiver.kernel.org>; Sat, 10 Oct 2020 13:26:33 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C108B22273
	for <containers@archiver.kernel.org>; Sat, 10 Oct 2020 13:26:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nRqb4ZE0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C108B22273
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 7FE3E8752B;
	Sat, 10 Oct 2020 13:26:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yskZTEoSZGwO; Sat, 10 Oct 2020 13:26:32 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 21E2D8747C;
	Sat, 10 Oct 2020 13:26:32 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 09ED6C016F;
	Sat, 10 Oct 2020 13:26:32 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 867E1C0051
 for <containers@lists.linux-foundation.org>;
 Sat, 10 Oct 2020 13:26:30 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 6C286203E2
 for <containers@lists.linux-foundation.org>;
 Sat, 10 Oct 2020 13:26:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id vIOn47aW6dlO
 for <containers@lists.linux-foundation.org>;
 Sat, 10 Oct 2020 13:26:28 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com
 [209.85.215.193])
 by silver.osuosl.org (Postfix) with ESMTPS id 67AA320115
 for <containers@lists.linux-foundation.org>;
 Sat, 10 Oct 2020 13:26:28 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id g29so9726652pgl.2
 for <containers@lists.linux-foundation.org>;
 Sat, 10 Oct 2020 06:26:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=bVFCs8xXG3UZzqj41Vd+QbKEjQvzFTw086//8JQkmAk=;
 b=nRqb4ZE058ecg0wB9M928Xcs3pdAmmYenHmHIKwtKIeDBkj22u265jtqAy+oGUqTuP
 3Kbtl4e9BhdhDhLaIKfzGQmiDJ8fyWCLLoVOHFAs7/Pq7T+C36pd8cHKZlwBFA3qG4sj
 i6qhyFyFCo6wA+30BWi4e3TqjdPphXZ5bEb+GGtWhrP+9adNgfvwcF8q5v0Bs/5qU2Fj
 F6lZwCXDnXRBt18iSeRVgmmLm8WKb4d3WaJq60FL2G6W9xhs49E0qR8Pv3V9NGNnFjnK
 CRfPAGtZ0lJ/fQ9SXWWGbPSaoIDJRq9tVGbgJ8OFLdz4GCUrvQQELdFrYIWPdhJg3T6r
 isyw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=bVFCs8xXG3UZzqj41Vd+QbKEjQvzFTw086//8JQkmAk=;
 b=uZk17tzPPha8o7gFXV+OltRgnbp1TmplflP2+7y8vZHTQ4KMy1/SNC+zMgwYTolGZ8
 LoJ+iFLHsStgc6Ev+hWoC4vAEVXKelaYg61uSD3t7y25e75P9s25u0lPOe+30Jizxb5g
 9nLSBfKIIb37h3/2O6OGqCwjiPNf6aQGRq30hoR3nJEjtHOVTfrPpscmb9SwZNtzPVOv
 9gf9XLvWFsHspf5wNviTbJkzDE4m2g/wnE3mfXsWfWZPRHpfgRonyTJHPx3SqhA61yyg
 F4IAbHIiDhFr8qpJoTVklEt7peVyxdirCU6KpYoF9gw81ylN4aGtKNAUYkQgGLjXAu7V
 VObw==
X-Gm-Message-State: AOAM530KF98AOoAZ12ScWcbplOk+Oa5B5RfDJVO+rLpcRyPad6GGkp1N
 m9PI+dhNh0CIrFOYhN9+megN0C54y//WvqtigWs=
X-Google-Smtp-Source: ABdhPJxJZH4rfHRGX8OWQzzQRKi6l0cfQ8gJdZhGHNFZtth6oqmXK/1KFPFUYgnj0yT0dLv9Ky3MZHKlrHUdMvDhlFM=
X-Received: by 2002:a62:750a:0:b029:152:4d07:aec6 with SMTP id
 q10-20020a62750a0000b02901524d07aec6mr16211235pfc.48.1602336387840; Sat, 10
 Oct 2020 06:26:27 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <c2077b8a86c6d82d611007d81ce81d32f718ec59.1602263422.git.yifeifz2@illinois.edu>
 <202010091613.B671C86@keescook>
In-Reply-To: <202010091613.B671C86@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Sat, 10 Oct 2020 08:26:16 -0500
Message-ID: <CABqSeARZWBQrLkzd3ozF16ghkADQqcN4rUoJS2MKkd=73g4nVA@mail.gmail.com>
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

On Fri, Oct 9, 2020 at 6:14 PM Kees Cook <keescook@chromium.org> wrote:
> HAVE_ARCH_SECCOMP_CACHE isn't used any more. I think this was left over
> from before.

Oh, I was meant to add this to the dependencies of
SECCOMP_CACHE_DEBUG. Is this something that would make sense?

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
