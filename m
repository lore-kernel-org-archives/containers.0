Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10C3BC43463
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 08:44:20 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 85C27207BC
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 08:44:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ek4wQqo0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85C27207BC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 43ABC20477;
	Mon, 21 Sep 2020 08:44:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id UvzmQYi-36Gh; Mon, 21 Sep 2020 08:44:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 744B4203FD;
	Mon, 21 Sep 2020 08:44:18 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 67B8EC0859;
	Mon, 21 Sep 2020 08:44:18 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 25787C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 08:44:17 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 1AB0785DC0
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 08:44:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id TrwM20Hk4YIG
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 08:44:16 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com
 [209.85.210.196])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 946D185815
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 08:44:16 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id w7so8670205pfi.4
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 01:44:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=I6HsE0eELlrQcO4TsI+wuslBDDzb2aL9SpkP/LH0CIY=;
 b=ek4wQqo0O3ZGYyvYSjADpuQBIyKJvqJn96byne7W9z8hxqA7ObjP8v2koIzhgAK06d
 jr/OFBqkNo6kjEtRVyrnJ9Uit+jePWzqU5NwGg7EX3TS8q6BvFlymmL35lJLcB4pnAsV
 TzfNFIay6DhV3PLywG7v+bMu9feD2UNR9O2aUXxR8Ycg8XeLrvs5xv7LQ2+7YIopSjL/
 xP41By3T8tO/cvDZErBwjLJuVNpSKrOTR06E7waMwMUDGMSJEHphAJEPf6nKl6Uqj+qe
 OCtNgQPcYvM6RA3b8+0rMwVCpiokVuzc3SkXhWcoV+zE5CxwbwG7emEGIwb0QDR9zcIX
 fqZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=I6HsE0eELlrQcO4TsI+wuslBDDzb2aL9SpkP/LH0CIY=;
 b=EYrnTK1/fHXu0/NUo7Ofp9qockad/liFqW1/vtNNGivfEPu0ri+VeZY34k7Jmpbg1v
 xe0638lR3NzzQe4j/+uiFfxNvCr/kQYe8uA3QYXXjr1tOvxMStO7kWzQUiu9qeOW0xW1
 CvXHGdZwmlTG72Yspxu8u8XIuhiRYI9nHEQp2eW/60zyZuMonCK75ztXcCj7OyZC8y1T
 cFhdFDG27XKPmYkGjYTnePz9s5snd8JnppCSB76cn5fxV0G9K5fYjyBA2NlO5cE4MrL0
 +IIBJPzMDu1jPQY3EJK64jM/IfpXF1sQ/oom/xF155HfxBxf2wftpOtxICsCXymo7GID
 JMTw==
X-Gm-Message-State: AOAM531+MQID6qjZjgWfPh2cZHBbqDdBLyW8aDHOf7KQiE0rRCKE4Czv
 rLANbTc0816P2YEH7PgOI3bWInhwTbvFvtxtPBw=
X-Google-Smtp-Source: ABdhPJyuD0wgIhq/Njnt6OzmDC+28Wcv88zDghEUZLrz87lUZKbyXKYes2bnZfRIKPdt9jZqlbuFftCYX6vas/RmQBI=
X-Received: by 2002:aa7:9491:0:b029:142:2501:396b with SMTP id
 z17-20020aa794910000b02901422501396bmr26157810pfk.48.1600677856250; Mon, 21
 Sep 2020 01:44:16 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <20200921083045.ojlswvusrfzohp2d@wittgenstein>
In-Reply-To: <20200921083045.ojlswvusrfzohp2d@wittgenstein>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Mon, 21 Sep 2020 03:44:05 -0500
Message-ID: <CABqSeARK=fzjBqO178pbzSXbazzDdxTmpA33pnvSy=rk9WYnJA@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 0/2] seccomp: Add bitmap cache of
 arg-independent filter results that allow syscalls
To: Christian Brauner <christian.brauner@ubuntu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, linux-kernel@vger.kernel.org,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf@vger.kernel.org,
 Tianyin Xu <tyxu@illinois.edu>
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

On Mon, Sep 21, 2020 at 3:30 AM Christian Brauner
<christian.brauner@ubuntu.com> wrote:
> This is missing some people so expanding the Cc a little. Make sure to
> run scripts/get_maintainers.pl next time, in case you forgot. (Adding
> Andy, Will, Jann, Aleksa at least.)
>
> Christian

ok noted. Thanks!

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
