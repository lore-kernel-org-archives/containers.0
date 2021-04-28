Return-Path: <SRS0=hje2=JZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88541C433ED
	for <containers@archiver.kernel.org>; Wed, 28 Apr 2021 11:11:32 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E217461168
	for <containers@archiver.kernel.org>; Wed, 28 Apr 2021 11:11:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E217461168
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kinvolk.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 77E2640EAE;
	Wed, 28 Apr 2021 11:11:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id qwldgfllDkyD; Wed, 28 Apr 2021 11:11:30 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp4.osuosl.org (Postfix) with ESMTP id 3DC6C40EAF;
	Wed, 28 Apr 2021 11:11:30 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0AF1EC001C;
	Wed, 28 Apr 2021 11:11:30 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 5BAD0C0001
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 11:11:28 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 55C6F40EAF
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 11:11:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id rFYWCxpcv2dN
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 11:11:27 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-lf1-x135.google.com (mail-lf1-x135.google.com
 [IPv6:2a00:1450:4864:20::135])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 2E50840EAE
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 11:11:27 +0000 (UTC)
Received: by mail-lf1-x135.google.com with SMTP id x19so68153352lfa.2
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 04:11:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kinvolk.io; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=uyfujupd+nn5QDO9renTFnifqj77qdb+Pu4FnljETRM=;
 b=gtHUnUjcLgmxwsgWIIOf8S/iDfnzWUGSnw/WqI9y2//8sFp6qgXEM166UhuVsXcx/R
 qGlFx9kB/9NKu/QNkYaAe2i6SpgZAoxyFQM2GLXntmB5DijUeMqcwhHV07sFAvuHQHIP
 OFvq2LbO/SqGzD2czTrq8ZGIJxCIEHXVnD3Us=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=uyfujupd+nn5QDO9renTFnifqj77qdb+Pu4FnljETRM=;
 b=KPNjkmTy9OyDTMYtazQQQdbUgeRnaJkg7kZkw7X59t+Ckah62Ns5nTUroMPgp5HzNk
 WL+xOVqnqL7L7AE6t44TEtqh0mQNVnTpKlr0AsmsVUejD7Y61dd2L8CfmtCKxVW8vMsG
 Wadj46aYv3mopenQ73Gn/aloAsBYvn5MKBDV16+ln74pHFqiAbmvYp0ms1KI/b9+Uj77
 d40xm+RRMzbcAmM/3nn0cM7RuzqNExss+r/py/aevSv2/A3CUtjf97jbEqz2aFDQoHTa
 akANhihlalB5TOA+0AEMB+BfgNGy2CJP551xg4G7kBNvk9velt46EJaGsx4j0M4Kzoxk
 BGfQ==
X-Gm-Message-State: AOAM531K8M2+e2h18tAne+/AGWC2j2UowyCgitCRQSGNnGdIO0K2IUq4
 Sbg0C4jz24fSKKWTwIH5lPJnD+6xizL5DtIEUk8ndw==
X-Google-Smtp-Source: ABdhPJyRqU7x9LfIz6OKejPVBvLcSRnhU++Q8NTEmQA868KtvCUuU4zOr7es0Wue0SowhX2xTymnzaz6O0rKw4WYcfw=
X-Received: by 2002:ac2:5335:: with SMTP id f21mr20269909lfh.288.1619608284816; 
 Wed, 28 Apr 2021 04:11:24 -0700 (PDT)
MIME-Version: 1.0
References: <20210426180610.2363-1-sargun@sargun.me>
 <20210426180610.2363-3-sargun@sargun.me>
 <20210426190229.GB1605795@cisco>
 <20210426221527.GA30835@ircssh-2.c.rugged-nimbus-611.internal>
 <20210427134853.GA1746081@cisco>
 <CALCETrVrfBtQPh=YeDEK4P9+QHQvNxHbn8ZT3fdQNznpSeS5oQ@mail.gmail.com>
 <20210427170753.GA1786245@cisco>
 <20210427221028.GA16602@ircssh-2.c.rugged-nimbus-611.internal>
 <CALCETrX9JnHE9BOhRxCc1bCvEBfbOY8bb2rxeKTsDNxfMruntQ@mail.gmail.com>
 <20210428002215.GB1786245@cisco>
In-Reply-To: <20210428002215.GB1786245@cisco>
From: Rodrigo Campos <rodrigo@kinvolk.io>
Date: Wed, 28 Apr 2021 13:10:49 +0200
Message-ID: <CACaBj2ZchRGzHpGn5TD2FE=yKWZotVRNZ7M78TmvGfM9BoHF4g@mail.gmail.com>
Subject: Re: [PATCH RESEND 2/5] seccomp: Add wait_killable semantic to seccomp
 user notifier
To: Tycho Andersen <tycho@tycho.pizza>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, Alban Crequy <alban@kinvolk.io>,
 Andy Lutomirski <luto@kernel.org>,
 Christian Brauner <christian.brauner@ubuntu.com>
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

On Wed, Apr 28, 2021 at 2:22 AM Tycho Andersen <tycho@tycho.pizza> wrote:
>
> On Tue, Apr 27, 2021 at 04:19:54PM -0700, Andy Lutomirski wrote:
> > User notifiers should allow correct emulation.  Right now, it doesn't,
> > but there is no reason it can't.
>
> Thanks for the explanation.
>
> Consider fsmount, which has a,
>
>         ret = mutex_lock_interruptible(&fc->uapi_mutex);
>         if (ret < 0)
>                 goto err_fsfd;
>
> If a regular task is interrupted during that wait, it return -EINTR
> or whatever back to userspace.
>
> Suppose that we intercept fsmount. The supervisor decides the mount is
> OK, does the fsmount, injects the mount fd into the container, and
> then the tracee receives a signal. At this point, the mount fd is
> visible inside the container. The supervisor gets a notification about
> the signal and revokes the mount fd, but there was some time where it
> was exposed in the container, whereas with the interrupt in the native
> syscall there was never any exposure.

IIUC, this is solved by my patch, patch 4 of the series. The
supervisor should do the addfd with the flag added in that patch
(SECCOMP_ADDFD_FLAG_SEND) for an atomic "addfd + send".

That means when using the atomic "addfd+send" what happens is: either
we add the fd _and_ the added fd value is returned to the syscall or
the fd is not added at all and the container sees the syscall as
interrupted. Therefore, the fd is only visible to the container when
it should.


Best,
Rodrigo
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
