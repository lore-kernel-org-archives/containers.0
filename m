Return-Path: <SRS0=NWjS=FF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02B97C64E7B
	for <containers@archiver.kernel.org>; Tue,  1 Dec 2020 13:08:34 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 184BA2076C
	for <containers@archiver.kernel.org>; Tue,  1 Dec 2020 13:08:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=sargun.me header.i=@sargun.me header.b="gTV19U7L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 184BA2076C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 89BE586C7A;
	Tue,  1 Dec 2020 13:08:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 2M9cz27vnuJ6; Tue,  1 Dec 2020 13:08:31 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 8756986C71;
	Tue,  1 Dec 2020 13:08:31 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6B44AC1833;
	Tue,  1 Dec 2020 13:08:31 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 38081C0859
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 13:08:30 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 0072E2DE2A
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 13:08:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id MGD0dKsXa-Na
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 13:08:28 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail-io1-f42.google.com (mail-io1-f42.google.com
 [209.85.166.42])
 by silver.osuosl.org (Postfix) with ESMTPS id 41FD220022
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 13:08:28 +0000 (UTC)
Received: by mail-io1-f42.google.com with SMTP id o8so1525153ioh.0
 for <containers@lists.linux-foundation.org>;
 Tue, 01 Dec 2020 05:08:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:content-transfer-encoding:in-reply-to
 :user-agent; bh=ZGcFuRI/bJF+HhBMzLDe2qGtoT/j0joOqdDzilS2qpo=;
 b=gTV19U7L/PRLjHjLVMBT9mj1qEMnpXhJ4DrO/+phoB5vlcweQ4DDm5pyPwcF/OJKeD
 p1IFSmdvJmxj7FFSzHjtbqBJTkDHtdP2dna0fFX6/moLUXI0ng4cU7iAIkXFEav/LiQL
 g791l9yDscEX979Y+yY4E+S1SLs3YXrE861Bk=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:content-transfer-encoding
 :in-reply-to:user-agent;
 bh=ZGcFuRI/bJF+HhBMzLDe2qGtoT/j0joOqdDzilS2qpo=;
 b=uREW5qCnwfOFaVSR+LJF01x4RuI7QC8jUJx9XVh0GLwOwJmD/iXV/XnZ7mlOPMpZ/a
 QeGdnZ6YINq3hxXuJfr1nuziLtZsE09s2k4P1AVxSJIttXluBszGOLXuYYfV0oNIvK9/
 8eRSximjKDY28R8ytulYNtpxNAoWAlTsmiuJ0RQOyARLe2SwAKoMICOMwEblJrv0xyPR
 XqUK4RVjtejEHmpUkXniAqLlwONZHDc1znncMoK+4VJPtjEaA3/cZ6wA7yLL2kxtlZXS
 upGblykbtQ64GBaQFDuSiRUwruqgSoLDF+5XwTI9LVZxZBZs4IiwPfhVE1FInLk2j+gT
 do/w==
X-Gm-Message-State: AOAM5326YIE/uvDpqgvxMdd34RBw0XmU9yXAi93iaMdmaKvFf1jVgl43
 LLfU5VMnE/VUXAsB0AVYSyl6eQ==
X-Google-Smtp-Source: ABdhPJxwlwKDoOdC8evZD54rtRTBt2PosvC3O4D1AZaVXoFjuWZXLX6+JWQ51f7bO1ilExJucdfw1A==
X-Received: by 2002:a02:3e86:: with SMTP id s128mr2383118jas.131.1606828107257; 
 Tue, 01 Dec 2020 05:08:27 -0800 (PST)
Received: from ircssh-2.c.rugged-nimbus-611.internal
 (80.60.198.104.bc.googleusercontent.com. [104.198.60.80])
 by smtp.gmail.com with ESMTPSA id u18sm765171iob.53.2020.12.01.05.08.26
 (version=TLS1_2 cipher=ECDHE-ECDSA-CHACHA20-POLY1305 bits=256/256);
 Tue, 01 Dec 2020 05:08:26 -0800 (PST)
Date: Tue, 1 Dec 2020 13:08:25 +0000
From: Sargun Dhillon <sargun@sargun.me>
To: Tycho Andersen <tycho@tycho.pizza>
Subject: Re: SECCOMP_IOCTL_NOTIF_ADDFD race condition
Message-ID: <20201201130824.GA27822@ircssh-2.c.rugged-nimbus-611.internal>
References: <CADZs7q4sw71iNHmV8EOOXhUKJMORPzF7thraxZYddTZsxta-KQ@mail.gmail.com>
 <20201130232009.GC38675@cisco> <20201201124105.GB103125@cisco>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201201124105.GB103125@cisco>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Giuseppe Scrivano <gscrivan@redhat.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Alban Crequy <alban@kinvolk.io>, Kees Cook <keescook@chromium.org>,
 LKML <linux-kernel@vger.kernel.org>
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
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Tue, Dec 01, 2020 at 07:41:05AM -0500, Tycho Andersen wrote:
> On Mon, Nov 30, 2020 at 06:20:09PM -0500, Tycho Andersen wrote:
> > Idea 1 sounds best to me, but maybe that's because it's the way I
> > originally did the fd support that never landed :)
> > =

> > But here's an Idea 4: we add a way to remotely close an fd (I don't
> > see that the current infra can do this, but perhaps I didn't look hard
> > enough), and then when you get ENOENT you have to close the fd. Of
> > course, this can't be via seccomp, so maybe it's even more racy.
> =

> Or better yet: what if the kernel closed everything it had added via
> ADDFD if it didn't get a valid response from the supervisor? Then
> everyone gets this bug fixed for free.
> =

> Tycho
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers

This doesn't solve=A0the problem universally because of the (Go) preemption =

problem. Unless we can guarantee that the supervisor can always handle the =

request in fewer than 10ms, or if it implements resumption behaviour. I kno=
w =

that resumption behaviour is a requirement no matter what, but the easier w=
e can =

make it to implement resumption, the better chance we are giving users to g=
et =

this right.

I think that the easiest solution is to add to the SECCOMP_IOCTL_NOTIF_RECV
ioctl. Either we have a flag like "block all blockable signals" or pass a
sigset_t directly of which signals to allow (and return an einval if they
try to block non-blockable signals).


_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
