Return-Path: <SRS0=NWjS=FF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04A27C64E7A
	for <containers@archiver.kernel.org>; Tue,  1 Dec 2020 21:59:57 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 71BBE20870
	for <containers@archiver.kernel.org>; Tue,  1 Dec 2020 21:59:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="hNjrfGwq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71BBE20870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id EFDAC87FEA;
	Tue,  1 Dec 2020 21:59:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id salxc0HNET0t; Tue,  1 Dec 2020 21:59:54 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 516E587FB6;
	Tue,  1 Dec 2020 21:59:54 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 43FBAC163C;
	Tue,  1 Dec 2020 21:59:54 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id EA0FDC0052
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 21:59:52 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id D7EA8875C9
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 21:59:52 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id QI9qNjhDMzQR
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 21:59:51 +0000 (UTC)
X-Greylist: delayed 00:32:44 by SQLgrey-1.7.6
Received: from mail-pj1-f45.google.com (mail-pj1-f45.google.com
 [209.85.216.45])
 by hemlock.osuosl.org (Postfix) with ESMTPS id B2587875B8
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Dec 2020 21:59:51 +0000 (UTC)
Received: by mail-pj1-f45.google.com with SMTP id hk16so2203808pjb.4
 for <containers@lists.linux-foundation.org>;
 Tue, 01 Dec 2020 13:59:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:content-transfer-encoding:in-reply-to;
 bh=V+/ciNKNBVSxZCplHKMLdjwlLpX/qeh2rzRXvgYylIk=;
 b=hNjrfGwqBx3QzKDk1BMPJpys6yHH/Ow5wyuyQ/AnZdv6K4HhchhmrzvV26qLHqGZEk
 hcoZy6FKT+T+lGt6UxsSAFjKCCYVOtcbKna6Vf29AUHEHI5JN1scjAOQLovekc+D7FJv
 k06PHX3gBciak5OZ0UxfDdlYCz5SHcDuB4olk=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:content-transfer-encoding
 :in-reply-to;
 bh=V+/ciNKNBVSxZCplHKMLdjwlLpX/qeh2rzRXvgYylIk=;
 b=rqqCpIcznsbraZLPyhIstTDFxQ2sax3F0UOpVt/cURdWuyyTTCdzjOdwFa0yy5x5Ab
 8k2RSmuSWEgWIr2hvSQRaYTzWKP0APyYDM42f2hg+mpvi8woTsRkEptxJdfrlH6Wp9+h
 5SNoRPetmNowkA7SRvzZqf1A6CKZMgd8h9/lLFx4gTcnc5OjrJ39R9NC4ETbGSM1OKWc
 o2lGiiSwsq1Oh3xWy3e4/8zZex0eUOgLSFg4iUsZMxPO+sGQfvQ95iVaB+lRKvbe2z2S
 Hpmv0WExAZcyMkNMbvBdDcu0zJsynjuxxukxvZr/L3HWQX27UeBj9rAMZ4yZkGVSPBYU
 EuaQ==
X-Gm-Message-State: AOAM530xBzVIgPXwUQSHqPpfFMxCeZ51E+Zh4Y8fYXdMXxJrMaZFnPAR
 wfPJJpPmU9O/O4mZhIQPOzimX5XdKP4OfmWV
X-Google-Smtp-Source: ABdhPJw5yj53ZR3QLDDz51zvJ0bcJIWvdtfK6BBYzjYoKCTvtuzo5lWYGIzOYfal2816cj8aj14jUQ==
X-Received: by 2002:a17:902:ee03:b029:da:689f:337e with SMTP id
 z3-20020a170902ee03b02900da689f337emr4443914plb.52.1606858027455; 
 Tue, 01 Dec 2020 13:27:07 -0800 (PST)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id f17sm661590pfk.70.2020.12.01.13.27.06
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Tue, 01 Dec 2020 13:27:06 -0800 (PST)
Date: Tue, 1 Dec 2020 13:27:05 -0800
From: Kees Cook <keescook@chromium.org>
To: Tycho Andersen <tycho@tycho.pizza>
Subject: Re: SECCOMP_IOCTL_NOTIF_ADDFD race condition
Message-ID: <202012011322.26DCBC64F2@keescook>
References: <CADZs7q4sw71iNHmV8EOOXhUKJMORPzF7thraxZYddTZsxta-KQ@mail.gmail.com>
 <20201130232009.GC38675@cisco> <20201201124105.GB103125@cisco>
 <20201201130824.GA27822@ircssh-2.c.rugged-nimbus-611.internal>
 <20201201131334.GC103125@cisco>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201201131334.GC103125@cisco>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, jannh@google.com,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, Alban Crequy <alban@kinvolk.io>
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

On Tue, Dec 01, 2020 at 08:13:34AM -0500, Tycho Andersen wrote:
> On Tue, Dec 01, 2020 at 01:08:25PM +0000, Sargun Dhillon wrote:
> > On Tue, Dec 01, 2020 at 07:41:05AM -0500, Tycho Andersen wrote:
> > > On Mon, Nov 30, 2020 at 06:20:09PM -0500, Tycho Andersen wrote:
> > > > Idea 1 sounds best to me, but maybe that's because it's the way I
> > > > originally did the fd support that never landed :)
> > > > =

> > > > But here's an Idea 4: we add a way to remotely close an fd (I don't
> > > > see that the current infra can do this, but perhaps I didn't look h=
ard
> > > > enough), and then when you get ENOENT you have to close the fd. Of
> > > > course, this can't be via seccomp, so maybe it's even more racy.
> > > =

> > > Or better yet: what if the kernel closed everything it had added via
> > > ADDFD if it didn't get a valid response from the supervisor? Then
> > > everyone gets this bug fixed for free.
> > > =

> > > Tycho
> > > _______________________________________________
> > > Containers mailing list
> > > Containers@lists.linux-foundation.org
> > > https://lists.linuxfoundation.org/mailman/listinfo/containers
> > =

> > This doesn't solve=A0the problem universally because of the (Go) preemp=
tion =

> > problem. Unless we can guarantee that the supervisor can always handle =
the =

> > request in fewer than 10ms, or if it implements resumption behaviour. I=
 know =

> > that resumption behaviour is a requirement no matter what, but the easi=
er we can =

> > make it to implement resumption, the better chance we are giving users =
to get =

> > this right.
> =

> Doesn't automatic cleanup of fds make things easier? I'm not sure I
> understand the argument.

I doubt Al would ever allow the "cleanup" approach: his observation was
that the instant a file has been added to the fdtable, it's not possible
to "unwind" that ever, since it could be cloned away, etc, etc.

> I agree it doesn't fix the problem of uncooperative userspace.

IIUC, I see two issues:

- a slow monitor might cause a child to loop forever retrying the same
  interrupted syscall.

- a syscall-interrupted process may have had an fd added that it has no
  idea about.

The former problem seems like a userspace issue. :P But, to help, yeah, is
signal blocking best? Either explicit (at filter apply time) or implicit
(all user_notif-triggering syscalls get all signals blocks automatically)?

For the latter problem, I think we need to get back to Tycho's original
method: add fd and finish syscall in a single action. I can't see any
other way to get around the need for atomicity...

-- =

Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
