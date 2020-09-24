Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2F13C2D0E2
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:29:09 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 275B8221EB
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 12:29:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="Ti6cmqL3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 275B8221EB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 86C482E113;
	Thu, 24 Sep 2020 12:29:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id f3QcPJp+AdLI; Thu, 24 Sep 2020 12:29:06 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 023E32E11D;
	Thu, 24 Sep 2020 12:29:05 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id DB48DC0890;
	Thu, 24 Sep 2020 12:29:05 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 14BCCC0859
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:29:04 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 0344685727
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:29:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id hEgSU46r-3o3
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:29:01 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-ej1-f68.google.com (mail-ej1-f68.google.com
 [209.85.218.68])
 by whitealder.osuosl.org (Postfix) with ESMTPS id A534786BF2
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 12:29:00 +0000 (UTC)
Received: by mail-ej1-f68.google.com with SMTP id gx22so4220898ejb.5
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 05:29:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=UcT+pZ/PTUp9wa/y0kDn97OtjvB6CdX4Q+3kJBuVUCc=;
 b=Ti6cmqL3Ww4/dmp4GkFf//pZM1Cyddfmt3F68rkT3FctP4csEwJV1NJkB1tib9WozY
 oNc6naTBxuclc80J+TWCWbGJd8Fuf4AnFoG86p+ut3WbzBD2lCKKaYvNSLkPp+nC7IjM
 Qoh75X6YKrgeZuI2F6HmflLcxhevKrt2jbmwkdoUuKN2fFfeUW12Csre4b3NreUUbUOV
 OxmzFfkvFy1NN4fo100JLfgqLlNL1LDX6jPfiBgqOlQYhv0rAGiWjFOcE1Z4bg1rQR9Z
 FSprGO32fR+tUWM8L24aC4BCxXNI5RVcCZCQJE1wV7IG+4RhTsKhd09adZuNylejwzhE
 HLhg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=UcT+pZ/PTUp9wa/y0kDn97OtjvB6CdX4Q+3kJBuVUCc=;
 b=MD7a7DJMVNisv/+YQBwwLM7ne8yMXFO0dHwjj7mnCrb4lLKhYNzYGRfh+kNw+ahAIk
 5kQbPQnW4vHU8M8SADn8n+li3Rbd6zC/sBycfI09sMk4NK1jRcvbHxe4CPGmMhlesxzM
 /LoNjpp6ypC7t5lEAAx9BYybXHVLxgo5NwQwBlaRcZ3fSaSOz7O1KyrHs103gT4kWs6V
 Cu4dKQezkGj3sKlNZmv6C0W7gd2ZJ/dgl5RLB4l/Neil0Qtycstm5aHeI4F43UPJHnBE
 f6S2TEHtCeWrsIW/ExstUfbYuE7eVRO/vo2XcPsed5mh8g2lnb1L0e7logheF1dy+j/F
 bRlQ==
X-Gm-Message-State: AOAM533ebFdu4J1cQk7r8T1610pusOwecY92VgReyd/kCpG8SV7xLN7Q
 Ng+aGnMjMHNDTdNluFGLb4gWhwbVHgeVtLPGMbKl8g==
X-Google-Smtp-Source: ABdhPJzVIElaKJCI4zdj8cYNSfBnh9BAhAhJsfLpPV5HoCvPWPZDo23uHBETkF6O0WXqmjXFTB7SOota/0VckQIv1BM=
X-Received: by 2002:a17:906:c447:: with SMTP id
 ck7mr767066ejb.358.1600950538813; 
 Thu, 24 Sep 2020 05:28:58 -0700 (PDT)
MIME-Version: 1.0
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-4-keescook@chromium.org>
 <CAG48ez0d80fOSTyn5QbH33WPz5UkzJJOo+V8of7YMR8pVQxumw@mail.gmail.com>
 <202009240018.A4D8274F@keescook>
In-Reply-To: <202009240018.A4D8274F@keescook>
Date: Thu, 24 Sep 2020 14:28:32 +0200
Message-ID: <CAG48ez1MWhrtkbWTNpc1v-WqWYiLM_JrCKvuE6DdH6vBY3MJzQ@mail.gmail.com>
Subject: Re: [PATCH 3/6] seccomp: Implement constant action bitmaps
To: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, YiFei Zhu <yifeifz2@illinois.edu>,
 Linux API <linux-api@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, Tianyin Xu <tyxu@illinois.edu>,
 kernel list <linux-kernel@vger.kernel.org>
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

On Thu, Sep 24, 2020 at 9:37 AM Kees Cook <keescook@chromium.org> wrote:
> On Thu, Sep 24, 2020 at 02:25:03AM +0200, Jann Horn wrote:
> > On Thu, Sep 24, 2020 at 1:29 AM Kees Cook <keescook@chromium.org> wrote:
[...]
> > (However, a "which syscalls have a fixed result" bitmap might make
> > sense if we want to export the list of permitted syscalls as a text
> > file in procfs, as I mentioned over at
> > <https://lore.kernel.org/lkml/CAG48ez3Ofqp4crXGksLmZY6=fGrF_tWyUCg7PBkAetvbbOPeOA@mail.gmail.com/>.)
>
> I haven't found a data structure I'm happy with for this. It seemed like
> NR_syscalls * sizeof(u32) was rather a lot (i.e. to store the BPF_RET
> value). However, let me discuss that more in the "why in in thread?"
> below...
[...]
> > > +#endif
> > > +};
> > > +
> > >  struct seccomp_filter;
> > >  /**
> > >   * struct seccomp - the state of a seccomp'ed process
> > > @@ -45,6 +56,13 @@ struct seccomp {
> > >  #endif
> > >         atomic_t filter_count;
> > >         struct seccomp_filter *filter;
> > > +       struct seccomp_bitmaps native;
> > > +#ifdef CONFIG_COMPAT
> > > +       struct seccomp_bitmaps compat;
> > > +#endif
> > > +#ifdef SECCOMP_MULTIPLEXED_SYSCALL_TABLE_ARCH
> > > +       struct seccomp_bitmaps multiplex;
> > > +#endif
> >
> > Why do we have one bitmap per thread (in struct seccomp) instead of
> > putting the bitmap for a given filter and all its ancestors into the
> > seccomp_filter?
>
> I explicitly didn't want to add code that was run per-filter; I wanted
> O(1), not O(n) even if the n work was a small constant. There is
> obviously a memory/perf tradeoff here. I wonder if the middle ground
> would be to put a bitmap and "constant action" results in the filter....
> oh duh. The "top" filter is already going to be composed with its
> ancestors. That's all that needs to be checked.

Yeah - when adding a new filter, you can evaluate each syscall for the
newly added filter. For both the "accept" bitmap and the "constant
action" bitmap, you can AND the bitmap of the existing filter into the
new filter's bitmap.

Although actually, I think my "constant action" bitmap proposal was a
stupid idea... when someone asks for an analysis of the filter via
procfs (which shouldn't be a common action, so speed doesn't really
matter there), we can just dynamically evaluate the entire filter tree
using our filter-evaluation helper. Let's drop the "constant action"
bitmap idea.

> Then the tri-state can be:
>
> bitmap accept[NR_syscalls]: accept or check "known" bitmap
> bitmap filter[NR_syscalls]: run filter or return known action
> u32 known_action[NR_syscalls];

Actually, maybe we should just have an "accept" list, nothing else, to
keep it straightforward and with minimal memory usage...

> (times syscall numbering "architecture" counts)
>
> Though perhaps it would be just as fast as:
>
> bitmap run_filter[NR_syscalls]: run filter or return known_action
> u32 known_action[NR_syscalls];
>
> where accept isn't treated special...

Using a bitset for accepted syscalls instead of a big array would
probably have far less cache impact on the syscall entry path. If we
just have an "accept" bitmask, we can store information about 512
syscalls per cache line - that's almost the entire syscall table. In
contrast, a known_action list can only store information about 16
syscalls in a cache line, and we'd additionally still have to query
the "filter" bitmap.

I think our goal here should be that if a syscall is always allowed,
seccomp should execute the smallest amount of instructions we can get
away with, and touch the smallest amount of memory possible (and
preferably that memory should be shared between threads). The bitmap
fastpath should probably also avoid populate_seccomp_data().
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
