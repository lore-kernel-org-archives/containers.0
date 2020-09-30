Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2832C4363D
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:15:58 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 75998206C1
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 23:15:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="pw30qPK5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75998206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 095002284F;
	Wed, 30 Sep 2020 23:15:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id V+ZK5PQ4cofP; Wed, 30 Sep 2020 23:15:56 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 7D878203F7;
	Wed, 30 Sep 2020 23:15:56 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 70E9BC0889;
	Wed, 30 Sep 2020 23:15:56 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B822DC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:15:55 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 9C436868B5
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:15:55 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id aU1nu5n-zFOb
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:15:55 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f65.google.com (mail-ej1-f65.google.com
 [209.85.218.65])
 by whitealder.osuosl.org (Postfix) with ESMTPS id BF0E4868B2
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 23:15:54 +0000 (UTC)
Received: by mail-ej1-f65.google.com with SMTP id a3so4468662ejy.11
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 16:15:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=7NtR8Af5mbsnJurMxCwsT1Qowr1kj5d6Fb9bCF6cp9U=;
 b=pw30qPK5acsamYkNqSxjNDViySQWHBINt4pgak0I6oN9BDI2yBlrAFZ7PYx4lB9T7Z
 HSrQSc1m3X5dyYBHGoAmUL/eyRBqa4xUzqWaH7PPDscJ1Ae2Zj08246uHc//sWeYewck
 53vyf72uWa6WOVK8gjf/qYZCkdVIPELn9Fli/FR8OcSgczqjUafRdcOgWuLdh2XYL6bq
 9yo/Wp/DaQt/aD69hGgaaI814TkUEQgm3uAVeUNGSM2dH5tXzayx9rjzSQhya0noqQzX
 nlRgaN7NdT0G8csaLaoJ6G5fx7nFre50Qp1dtsv6Mz5h6A9s/9Z2tcPJRzbi7ACupfCp
 9b6g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=7NtR8Af5mbsnJurMxCwsT1Qowr1kj5d6Fb9bCF6cp9U=;
 b=VJXVq8Yi8mp5k9ZTdLw5edHYLByiaXCtBKLQwOeNzRzCSFgX6Yed+XuIFx3n1vaIqP
 qlJpWT/jrWU807FYWTfzeJMiYrCNkwIDN6i0yqHUcTfDDdi8EFXOgrwrrilRL9YfW99f
 06AG1lxqCpIoD/oo2Q9EWZiQ2NmFCPlpIg6JDFH1wzt5ilp1voH/g3zY4LGUjzn4ED6U
 8M4D2nJpUCRriamUbRJ1YL6sMsrA1xWXnR9bDkMYUqGiVUpBY4UEf9eVDs+uZMsw2/aC
 agybyhGqkbK6eh3Y65VwjwS9BP2lr3uohaGBbLqjBKTtJ4iz2DNrDq3N9Sp6D9hVApMm
 Xflg==
X-Gm-Message-State: AOAM533r8LscVb/ZRJ7pyvC3OnOxHoq15x0AM0WtL568VuGB5h3mvUYm
 SAQecHRaZ8gKmYivylwmHouQltE8VMDOFkp8oA816Q==
X-Google-Smtp-Source: ABdhPJy9ik0VDeL+cu6VtcVQ/+hDXc248kSGiAvJX6+w/4UrgfNPOUORWDEnAsA6QMlkA5tDhYvPNM8Qid/ySYOAIHQ=
X-Received: by 2002:a17:906:980f:: with SMTP id
 lm15mr5403777ejb.184.1601507753153; 
 Wed, 30 Sep 2020 16:15:53 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <484392624b475cc25d90a787525ede70df9f7d51.1601478774.git.yifeifz2@illinois.edu>
 <202009301418.20BA0CE33@keescook>
 <CAG48ez3039B+w_D7SJBaGGXw9sd1_SzWO+qUnhMs6tcweGa-+w@mail.gmail.com>
 <202009301549.17D3DE5@keescook>
In-Reply-To: <202009301549.17D3DE5@keescook>
Date: Thu, 1 Oct 2020 01:15:26 +0200
Message-ID: <CAG48ez1cj5Ff7CiU5jZetfe0KppPSOUzE-TFKMEZ0JmofL7abw@mail.gmail.com>
Subject: Re: [PATCH v3 seccomp 1/5] x86: Enable seccomp architecture tracking
To: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, YiFei Zhu <yifeifz2@illinois.edu>,
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Thu, Oct 1, 2020 at 12:53 AM Kees Cook <keescook@chromium.org> wrote:
>
> On Wed, Sep 30, 2020 at 11:33:15PM +0200, Jann Horn wrote:
> > On Wed, Sep 30, 2020 at 11:21 PM Kees Cook <keescook@chromium.org> wrote:
> > > On Wed, Sep 30, 2020 at 10:19:12AM -0500, YiFei Zhu wrote:
> > > > From: Kees Cook <keescook@chromium.org>
> > > >
> > > > Provide seccomp internals with the details to calculate which syscall
> > > > table the running kernel is expecting to deal with. This allows for
> > > > efficient architecture pinning and paves the way for constant-action
> > > > bitmaps.
> > > >
> > > > Signed-off-by: Kees Cook <keescook@chromium.org>
> > > > [YiFei: Removed x32, added macro for nr_syscalls]
> > > > Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> > [...]
> > > But otherwise, yes, looks good to me. For this patch, I think the S-o-b chain is probably more
> > > accurately captured as:
> > >
> > > Signed-off-by: Kees Cook <keescook@chromium.org>
> > > Co-developed-by: YiFei Zhu <yifeifz2@illinois.edu>
> > > Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> >
> > (Technically, https://www.kernel.org/doc/html/latest/process/submitting-patches.html#when-to-use-acked-by-cc-and-co-developed-by
> > says that "every Co-developed-by: must be immediately followed by a
> > Signed-off-by: of the associated co-author" (and has an example of how
> > that should look).)
>
> Right, but it is not needed for the commit author (here, the From:),
> the second example given in the docs shows this:

Aah, right. Nevermind, sorry for the noise.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
