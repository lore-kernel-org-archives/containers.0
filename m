Return-Path: <SRS0=hje2=JZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42049C433ED
	for <containers@archiver.kernel.org>; Wed, 28 Apr 2021 13:20:46 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B286D61423
	for <containers@archiver.kernel.org>; Wed, 28 Apr 2021 13:20:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B286D61423
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kinvolk.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id 609BD605D9;
	Wed, 28 Apr 2021 13:20:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hC44MSgjM3Pn; Wed, 28 Apr 2021 13:20:44 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp3.osuosl.org (Postfix) with ESMTP id 4E9B5605F2;
	Wed, 28 Apr 2021 13:20:44 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 36565C001C;
	Wed, 28 Apr 2021 13:20:44 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 40878C0001
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 13:20:43 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 22CBC400D6
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 13:20:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp2.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=kinvolk.io
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id GoraKBu83Y1b
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 13:20:41 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-lj1-x22c.google.com (mail-lj1-x22c.google.com
 [IPv6:2a00:1450:4864:20::22c])
 by smtp2.osuosl.org (Postfix) with ESMTPS id BBB22404CE
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 13:20:41 +0000 (UTC)
Received: by mail-lj1-x22c.google.com with SMTP id a5so35200891ljk.0
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 06:20:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kinvolk.io; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=uIGj9FC9IzQAq2GBbgZ3dpBuRxuZ1w8kk9zAVN1t/ks=;
 b=Atxh07MDqbbW6/8ErsAvnGFkCNHvXe2vYe9WACJaEyB7bJkjnALZzk1jNN5xtWCwrG
 izIca9U7kp1F/dB6FgQJwUeWw7/HVJ0fhgnwgHlW7VnhUz8cjI9OCl1ep8aGKyoYnpMp
 qwRrem0ZKmJaX7mt0eVuN+e18X4/U3KpboD1U=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=uIGj9FC9IzQAq2GBbgZ3dpBuRxuZ1w8kk9zAVN1t/ks=;
 b=m3l89dvP42caY/2zFk8/ZCl8xsdGUIMNzM8RhDLBlZmebhGw3huCe3s5pk9UJo5RW+
 Ir8by+kIY9wlKSz4vPzs3/MI0r5FeWevLN//3dF9UvYAbdcs25a65JJDRrT0i4VmRYRJ
 kiZ1PqFzO/J4YZ3C/yySI5OYsAb4HJS/wp0HZWCQaYc9U9Adw7LiwB3zfIAUT0bgEIOj
 ePCm10Z0Z/phd22BTtjCgF9zxpPafr8eIrxcQhbBijKsFdth8+8b2ynikHYoCDVnWrt5
 pFUID0Q57VzgGwgkpY1y0c92ZJizq/ShA/GQh9r9mSsrphomuC71KTLy3Ka/V80PpQYx
 ry8Q==
X-Gm-Message-State: AOAM532JxkT2TfPYxRtE36bMs7kI0fkFsxfXgPnVrkNFu1yfDyDNRt+g
 jXRa6i5EW2qhfE4ltoiHmTjse9qfXW5ptoWb7oodVg==
X-Google-Smtp-Source: ABdhPJx9KA3ejbYEli1zAg5bEg5ZXtE1NsqbHnBRe3FeKasU220+f/H5v10Cq1RRRSRPsxwCH7ZeWuiXmKw0XIS1zCs=
X-Received: by 2002:a2e:9b50:: with SMTP id o16mr21000868ljj.8.1619616039596; 
 Wed, 28 Apr 2021 06:20:39 -0700 (PDT)
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
 <CACaBj2ZchRGzHpGn5TD2FE=yKWZotVRNZ7M78TmvGfM9BoHF4g@mail.gmail.com>
In-Reply-To: <CACaBj2ZchRGzHpGn5TD2FE=yKWZotVRNZ7M78TmvGfM9BoHF4g@mail.gmail.com>
From: Rodrigo Campos <rodrigo@kinvolk.io>
Date: Wed, 28 Apr 2021 15:20:02 +0200
Message-ID: <CACaBj2aSnzQnbZG0sMM2Vae_yWGzxKWrGUz9xJVL_7akF8DvNA@mail.gmail.com>
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

On Wed, Apr 28, 2021 at 1:10 PM Rodrigo Campos <rodrigo@kinvolk.io> wrote:
>
> On Wed, Apr 28, 2021 at 2:22 AM Tycho Andersen <tycho@tycho.pizza> wrote:
> >
> > On Tue, Apr 27, 2021 at 04:19:54PM -0700, Andy Lutomirski wrote:
> > > User notifiers should allow correct emulation.  Right now, it doesn't,
> > > but there is no reason it can't.
> >
> > Thanks for the explanation.
> >
> > Consider fsmount, which has a,
> >
> >         ret = mutex_lock_interruptible(&fc->uapi_mutex);
> >         if (ret < 0)
> >                 goto err_fsfd;
> >
> > If a regular task is interrupted during that wait, it return -EINTR
> > or whatever back to userspace.
> >
> > Suppose that we intercept fsmount. The supervisor decides the mount is
> > OK, does the fsmount, injects the mount fd into the container, and
> > then the tracee receives a signal. At this point, the mount fd is
> > visible inside the container. The supervisor gets a notification about
> > the signal and revokes the mount fd, but there was some time where it
> > was exposed in the container, whereas with the interrupt in the native
> > syscall there was never any exposure.
>
> IIUC, this is solved by my patch, patch 4 of the series. The
> supervisor should do the addfd with the flag added in that patch
> (SECCOMP_ADDFD_FLAG_SEND) for an atomic "addfd + send".

Well, under Andy's proposal handling that is even simpler. If the
signal is delivered after we added the fd (note that the container
syscall does not return when the signal arrives, as it happens today,
it just signals the notifier and continues to wait), we can just
ignore the signal and return that (if that is the appropriate thing
for that syscall, but I guess after adding an fd there isn't any other
reasonable thing to do).



Best,
Rodrigo
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
