Return-Path: <SRS0=U9nl=DH=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D310C4363D
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 21:33:51 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E36C020739
	for <containers@archiver.kernel.org>; Wed, 30 Sep 2020 21:33:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="jEZZuulT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E36C020739
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 51B59203A7;
	Wed, 30 Sep 2020 21:33:50 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8aqwlnK-g83n; Wed, 30 Sep 2020 21:33:48 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id C4AE5203AA;
	Wed, 30 Sep 2020 21:33:48 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id AAC38C0889;
	Wed, 30 Sep 2020 21:33:48 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 634DCC0051
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 21:33:47 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 040AB203AA
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 21:33:47 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id V1PGftyir1Ue
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 21:33:44 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f67.google.com (mail-ej1-f67.google.com
 [209.85.218.67])
 by silver.osuosl.org (Postfix) with ESMTPS id B30971FD42
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 21:33:43 +0000 (UTC)
Received: by mail-ej1-f67.google.com with SMTP id dd13so4979887ejb.5
 for <containers@lists.linux-foundation.org>;
 Wed, 30 Sep 2020 14:33:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=auUqGvs0gHMXAey6wH7F9Apr7r/9WxxEyJFZn6Y4ccM=;
 b=jEZZuulTAkEP8ra+dIdb67z4FyGG96oF+vkHW7GlTvPFyN0nVCVZIn9qGMllZOit52
 xj0H2s8ta9HYmC2xhPb1zHhF4HfH+UhZxwQYGniF7NYVP6OGvTjHST+AO2oYeFOeDzel
 K80B8lQVwG4BEz/c3n+OhRltgv2kxMciDlkUAu7SwpTzBlHY9YZEb+zGocLMIulaTJ3J
 E7rnlY8Jfjcr2wvOlQGr2UqSv2R9Lw2k+Fdc+cXBVe0Ad8TjzEjIzvxQ50rU3fUPEfwn
 gx6czlTmSA/lyvlJ3ErszHDOy3n8+mW25p41M/y9O9bguu9kmnvyQfZQsfnrXknVZngO
 XeRg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=auUqGvs0gHMXAey6wH7F9Apr7r/9WxxEyJFZn6Y4ccM=;
 b=psTe+fx1Mnz/A5IqORJ052QdJOMA0suMaAmRQYmLr123gAFUlITFTDvZ9bbAWdoVDK
 HeJ65OZ4j24rP0M0ZcMTywBRevEeq7pS32ZmH2FAVmL4Fil05DF+U2u7nQ4UxXEIbLZm
 ecDF0iXREbvcXDZA0VG6WKaXgd1pAfyCpregqCzvH75NouzG2qyEJaSi5NLr78yZc5La
 GTyMYRTv40h8lpZjnwlp+JvWq1iLEpUYbeTGZ5qevbwNrCMjYeHmZWUq25xIXiFUvfA2
 VIK+8ZRtNMMnrIItGTjnyKqhrzylehbmAoma7zrR9FTosi1rU3ojaCABbmO8aRkBNtuV
 sPNQ==
X-Gm-Message-State: AOAM533/GS3AtPXajvTk2dvoYT8v6vp7oLVVcRxLaMBgxqFBssjrpzj9
 wx+mL26Me7XpK1mQdVQaEf0KhMcTENnb3aUOAjgP2g==
X-Google-Smtp-Source: ABdhPJyMPW38MT/cpIj3rWIUCaLGD/HFhM0te7s40TzgBb3ydM7D9Qbrn6/eFy/iZ1fva2zDw42UX+OK4+/N0TeEOLw=
X-Received: by 2002:a17:907:94cf:: with SMTP id
 dn15mr5042513ejc.114.1601501622005; 
 Wed, 30 Sep 2020 14:33:42 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1601478774.git.yifeifz2@illinois.edu>
 <484392624b475cc25d90a787525ede70df9f7d51.1601478774.git.yifeifz2@illinois.edu>
 <202009301418.20BA0CE33@keescook>
In-Reply-To: <202009301418.20BA0CE33@keescook>
Date: Wed, 30 Sep 2020 23:33:15 +0200
Message-ID: <CAG48ez3039B+w_D7SJBaGGXw9sd1_SzWO+qUnhMs6tcweGa-+w@mail.gmail.com>
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

On Wed, Sep 30, 2020 at 11:21 PM Kees Cook <keescook@chromium.org> wrote:
> On Wed, Sep 30, 2020 at 10:19:12AM -0500, YiFei Zhu wrote:
> > From: Kees Cook <keescook@chromium.org>
> >
> > Provide seccomp internals with the details to calculate which syscall
> > table the running kernel is expecting to deal with. This allows for
> > efficient architecture pinning and paves the way for constant-action
> > bitmaps.
> >
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> > [YiFei: Removed x32, added macro for nr_syscalls]
> > Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
[...]
> But otherwise, yes, looks good to me. For this patch, I think the S-o-b chain is probably more
> accurately captured as:
>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Co-developed-by: YiFei Zhu <yifeifz2@illinois.edu>
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>

(Technically, https://www.kernel.org/doc/html/latest/process/submitting-patches.html#when-to-use-acked-by-cc-and-co-developed-by
says that "every Co-developed-by: must be immediately followed by a
Signed-off-by: of the associated co-author" (and has an example of how
that should look).)
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
