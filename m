Return-Path: <SRS0=50w+=DC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84ABBC4346E
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 03:04:35 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D76762084C
	for <containers@archiver.kernel.org>; Fri, 25 Sep 2020 03:04:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EkPvPefR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D76762084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 8277086A2D;
	Fri, 25 Sep 2020 03:04:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yj7abDiAoOaM; Fri, 25 Sep 2020 03:04:33 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id AD4A48547D;
	Fri, 25 Sep 2020 03:04:33 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 901CCC0889;
	Fri, 25 Sep 2020 03:04:33 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A3FABC0051
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:04:32 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 895B687547
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:04:32 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id xgyhSeCWYNH0
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:04:31 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com
 [209.85.215.194])
 by hemlock.osuosl.org (Postfix) with ESMTPS id DCD18874B2
 for <containers@lists.linux-foundation.org>;
 Fri, 25 Sep 2020 03:04:31 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id y14so1302286pgf.12
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 20:04:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=TaLV707zQzZoN9QVLmaV1M3bCDM0wWxg5z+B0UkLQGg=;
 b=EkPvPefRxz0sWEd3UPVC8kxM159CSTntHac6+Inlv5wOG9OZKkrjEyYag0K/as/E90
 7/A8BO8/EMphA9rdWDdLvSqLMScFNaqeHSCoOjoxxk96OPWS/dsZJvpUpfhzF0hm9Wbu
 bxeJAeIytZ+L0UjGyHr5XwO9aWCNz6Uc7werwqPxqZb2h174LSOVhEN3r2JO9qsDWEjT
 51QW0j/7qWIcXrGktJhy0zW4hDUMQIh9S72MKexreLM7bqYYQyOA7OD7O6bnM8H4worb
 IxkMkB3DJeDa5gzfcRV5a6Q95pSRYUx1p0jD0qdyrfUtqdUf2LmfclyKPeFfWSU0QWss
 WYvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=TaLV707zQzZoN9QVLmaV1M3bCDM0wWxg5z+B0UkLQGg=;
 b=l2FA6mUhoeXC23dyfvUPAxHlWNORDmeo6EgMJItDapjlX9trCNhKPOYCKlrHFmH5W5
 EmdpUBwmbp7gdhsI8plww7uM3BvkPSX4ExG5Pnp5dUnKI4U1/0RooKzEieN5RzptbFPu
 1135O5riVf1wGD97VR163Vn3pVuBStyagr1OQ7oXE+70uxTNlmPMS0yBCz3E9tX8dPSA
 7pNOYQDAS0znYdjSz1EjRck/jF//ssULP7ByzIOpn9gneXNztTHXav01z9vo4XvMQBfp
 nPDVxT9wn+yXmGB8A2egeyvODjOUpunozeAdzcFDYraah6P1IgpryAb25xWfnt+5pDW5
 mOiQ==
X-Gm-Message-State: AOAM533+iGNitnwd2FCaFSn12zkAOOw6e+jad6bxluBtoaMENyJSwiVJ
 5VUPmCewgufWOOK7Vrx+A3VgouJdQGC8xJcL8Eo=
X-Google-Smtp-Source: ABdhPJzjiyeuGOlQoK/hG6jcimUOzcy7CQEv7zxwO869et/v35NnPEJvv3NMxcXCfGmNr9BcSNz8lzE/nTu7SbOgZ3k=
X-Received: by 2002:aa7:9491:0:b029:142:2501:396b with SMTP id
 z17-20020aa794910000b02901422501396bmr2144153pfk.48.1601003071283; Thu, 24
 Sep 2020 20:04:31 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600951211.git.yifeifz2@illinois.edu>
 <c14518ba563d4c6bb75b9fac63b69cd4c82f9dcc.1600951211.git.yifeifz2@illinois.edu>
 <202009241601.FFC0CF68@keescook>
In-Reply-To: <202009241601.FFC0CF68@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Thu, 24 Sep 2020 22:04:20 -0500
Message-ID: <CABqSeARb7GNU9+sVgGzgqqOmpQNpxq1JsMrZJvS2EC05AyfAVw@mail.gmail.com>
Subject: Re: [PATCH v2 seccomp 3/6] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
To: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 Jack Chen <jianyan2@illinois.edu>, Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
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

[resending this, forgot to hit reply all...]

On Thu, Sep 24, 2020 at 6:25 PM Kees Cook <keescook@chromium.org> wrote:
> I'm not interested in seccomp having a config option for this. It should
> entire exist or not, and that depends on the per-architecture support.
> You mentioned in another thread that you wanted it to let people play
> with this support in some way. Can you elaborate on this? My perspective
> is that of distro and vendor kernels: there is _one_ config and end
> users can't really do anything about it without rolling their own
> kernels.

That's one. The other is to allow future optional extensions, like
syscall-argument-capable accelerators.

Distro / vendor kernels will keep defaults anyways, no?

> So, as Jann pointed out, using NR_syscalls only accidentally works --
> they're actually different sizes and there isn't strictly any reason to
> expect one to be smaller than another. So, we need to either choose the
> max() in asm/linux/seccomp.h or be more efficient with space usage and
> use explicitly named bitmaps (how my v1 does things).

Right.

> This isn't used in this patch; likely leftover/in need of moving?

Correct. Will remove.

> I moved this up in the structure to see if I could benefit from cache
> line sharing. In either case, we must verify (with "pahole") that we do
> not induce massive padding in the struct.
>
> But yes, attaching this to the filter is the right way to go.

Right. I don't think it would cause massive padding with all I know
about padding learnt from [1].

I'm used to use gdb to look at structure layout, and this is what I see:
(gdb) ptype /o struct seccomp_filter
/* offset    |  size */  type = struct seccomp_filter {
/*    0      |     4 */    refcount_t refs;
/*    4      |     4 */    refcount_t users;
/*    8      |     1 */    bool log;
/* XXX  7-byte hole  */
/*   16      |     8 */    struct seccomp_filter *prev;
[...]
/*  264      |   112 */    struct seccomp_cache_filter_data {
/*  264      |   112 */        unsigned long syscall_ok[2][7];

                               /* total size (bytes):  112 */
                           } cache;

                           /* total size (bytes):  376 */
                         }

The bitmaps are long-aligned; so is the prev-pointer. If we want we
can put the cache struct right before prev and that should not
introduce any new holes. It's the refcounts and the bool that's not
cooperative.

> nit: "ok" is too vague. We mean either "constant action" or "allow" (or
> "filter" in the negative case).

Right.

> Why is this split out? (i.e. why is it not just a self-contained loop
> the way Jann wrote it?)

Because my brain thinks like a finite state machine and this function
is a state transition. ;) Though yeah I agree a loop is probably more
readable.

> I appreciate the -errno intent, but it actually risks making these
> changes break existing userspace filters: if something is unhandled in
> the emulator in a way we don't find during design and testing, the
> filter load will actually _fail_ instead of just falling back to "run
> filter". Failures should be reported (WARN_ON_ONCE()), but my v1
> intentionally lets this continue.

Right.

> This version appears to have removed all the comments; I liked Jann's
> comments and I had rearranged things a bit to make it more readable
> (IMO) for people that do not immediate understand BPF. :)

Right.

> > +/**
> > + * seccomp_cache_prepare - emulate the filter to find cachable syscalls
> > + * @sfilter: The seccomp filter
> > + *
> > + * Returns 0 if successful or -errno if error occurred.
> > + */
> > +int seccomp_cache_prepare(struct seccomp_filter *sfilter)
> > +{
> > +     struct sock_fprog_kern *fprog = sfilter->prog->orig_prog;
> > +     struct sock_filter *filter = fprog->filter;
> > +     int arch, nr, res = 0;
> > +
> > +     for (arch = 0; arch < ARRAY_SIZE(syscall_arches); arch++) {
> > +             for (nr = 0; nr < NR_syscalls; nr++) {
> > +                     struct seccomp_emu_env env = {0};

Btw, do you know what is the initial state of the A register at the
start of BPF execution? In my RFC I assumed it's unknown but then in
v1 after the "reg_known" removal the register is assumed to be 0. Idk
if it is correct to assume so.

> I don't really like the complexity here, passing around syscall_ok, etc.
> I feel like seccomp_emu_step() should be self-contained to say "allow or
> filter" directly.

Ok.

> I also prefer an inversion to the logic: if we start bitmaps as "default
> allow", we only ever increase the filtering cases: we can never
> accidentally ADD an allow to the bitmap. (This was an intentional design
> in the RFC and v1 to do as much as possible to fail safe.)

Wait why? If it's default allow, what if you hit an error? You can
accidentally not remove an allow from the bitmap, and that is much
more of an issue than accidentally not add an allow. I don't
understand your reasoning of "accidentally ADD an allow", an action
will only occur when everything is right, but an action might not
occur if some random shenanigans happen. Hence, the non-action /
default side should be the fail-safe side, rather than the action
side.

> Why do the prepare here instead of during attach? (And note that it
> should not be written to fail.)

Right.

> And, as per being as defensive as I can imagine, this should be a
> one-way mask: we can only remove bits from syscall_ok, never add them.
> sfilter must be constructed so that it can only ever have fewer or the
> same bits set as prev.

Right.

> In the RFC I did this inherit earlier (in the emulation stage) to
> benefit from the RET_KILL results, but that's not very useful any more.
> However, I think it's still code-locality better to keep the bit
> manipulation logic as close together as possible for readability.

Right.

[1] http://www.catb.org/esr/structure-packing/#_structure_alignment_and_padding

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
