Return-Path: <SRS0=82Ss=DT=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8085EC433DF
	for <containers@archiver.kernel.org>; Mon, 12 Oct 2020 00:38:59 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0814D20756
	for <containers@archiver.kernel.org>; Mon, 12 Oct 2020 00:38:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Qu5kF8nf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0814D20756
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 6AA232052E;
	Mon, 12 Oct 2020 00:38:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 3pvhx1YKfqpe; Mon, 12 Oct 2020 00:38:57 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id C870120523;
	Mon, 12 Oct 2020 00:38:57 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id AD620C0052;
	Mon, 12 Oct 2020 00:38:57 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 73F33C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 00:38:56 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 3FCD82052E
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 00:38:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ZT2xz20o3cwy
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 00:38:55 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by silver.osuosl.org (Postfix) with ESMTPS id 38D5B20523
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 00:38:55 +0000 (UTC)
Received: from mail-wr1-f41.google.com (mail-wr1-f41.google.com
 [209.85.221.41])
 (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
 (No client certificate requested)
 by mail.kernel.org (Postfix) with ESMTPSA id 9C4F82074D
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 00:38:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
 s=default; t=1602463134;
 bh=3JjWOrrRe3Ri2Va88NyZZ9ysVmM7e7b9tXLpxqeeSRU=;
 h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
 b=Qu5kF8nfQfz6XNzmmbD5fUHAj71XqOtE8NDoiCzS9YXluuRnwMZ8ln+DCOneUwMXD
 rbaTlMa3Nz+1QFnrh7dA45ZYazQ+qHFbNVjSvdvXGFNeMx0WpaHlrxLZPSyb+VaZ/R
 Sv4bx+CbOMjhANhzgAVEHLGTZ5aXt4r1zj12N8B4=
Received: by mail-wr1-f41.google.com with SMTP id g12so17164451wrp.10
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 17:38:54 -0700 (PDT)
X-Gm-Message-State: AOAM533k3urfKv7aOR+IcNHrvNYJ/HlcBO0emgE/s9Y+qsY7UvOuo+6Y
 VBWPjbaUVE37jtmhgofJ0HqNVdphp4W9nnJs+6D0qg==
X-Google-Smtp-Source: ABdhPJwlhDPIvlJzvFEhRWYttOsupRWk8TH+QE3JDpT2utboUFP6eaB1GmUggiCCsaYrZMZU7yE5I0UdrAVs4OcjT1c=
X-Received: by 2002:a5d:6744:: with SMTP id l4mr27270264wrw.18.1602463133211; 
 Sun, 11 Oct 2020 17:38:53 -0700 (PDT)
MIME-Version: 1.0
References: <20200830143959.rhosiunyz5yqbr35@wittgenstein>
 <20201010042606.GA30062@mail.hallyn.com>
 <20201011205306.GC17441@localhost>
In-Reply-To: <20201011205306.GC17441@localhost>
From: Andy Lutomirski <luto@kernel.org>
Date: Sun, 11 Oct 2020 17:38:41 -0700
X-Gmail-Original-Message-ID: <CALCETrUZcHNwspz315KFvSPxtK8MmLUPfiN=hCBgx+wqeJe4+g@mail.gmail.com>
Message-ID: <CALCETrUZcHNwspz315KFvSPxtK8MmLUPfiN=hCBgx+wqeJe4+g@mail.gmail.com>
Subject: Re: LPC 2020 Hackroom Session: summary and next steps for isolated
 user namespaces
To: Josh Triplett <josh@joshtriplett.org>
Cc: Alexander Mihalicyn <alexander@mihalicyn.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Joseph Christopher Sible <jcsible@cert.org>, Kees Cook <keescook@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, Vivek Goyal <vgoyal@redhat.com>,
 Geoffrey Thomas <geofft@ldpreload.com>,
 "Eric W. Biederman" <ebiederm@xmission.com>,
 =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
 Wat Lim <watl@google.com>, Mrunal Patel <mpatel@redhat.com>,
 Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
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

On Sun, Oct 11, 2020 at 1:53 PM Josh Triplett <josh@joshtriplett.org> wrote:
>
> On Fri, Oct 09, 2020 at 11:26:06PM -0500, Serge E. Hallyn wrote:
> > > 3. Find a way to allow setgroups() in a user namespace while keeping
> > >    in mind the case of groups used for negative access control.
> > >    This was suggested by Josh Triplett and Geoffrey Thomas. Their idea was to
> > >    investigate adding a prctl() to allow setgroups() to be called in a user
> > >    namespace at the cost of restricting paths to the most restrictive
> > >    permission. So if something is 0707 it needs to be treated as if it's 0000
> > >    even though the caller is not in its owning group which is used for negative
> > >    access control (how these new semantics will interact with ACLs will also
> > >    need to be looked into).
> >
> > I should probably think this through more, but for this problem, would it
> > not suffice to add a new prevgroups grouplist to the struct cred, maybe
> > struct group_info *locked_groups, and every time an unprivileged task creates
> > a new user namespace, add all its current groups to this list?
>
> So, effectively, you would be allowed to drop permissions, but
> locked_groups would still be checked for restrictions?
>
> That seems like it'd introduce a new level of complexity (a new facet of
> permission) to manage. Not opposed, but it does seem more complex than
> just opting out of using groups for negative permissions.

Is there any context other than regular UNIX DAC in which groups can
act as negative permissions or is this literally just an issue for
files with a more restrictive group mode than other mode?
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
