Return-Path: <SRS0=lkaS=DB=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC735C4346E
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 07:11:09 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2CBFC206C9
	for <containers@archiver.kernel.org>; Thu, 24 Sep 2020 07:11:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="fHf6+8JT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CBFC206C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 71B3D2E0DB;
	Thu, 24 Sep 2020 07:11:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Vpt9BXdo-Hlh; Thu, 24 Sep 2020 07:11:05 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id C9E7B20493;
	Thu, 24 Sep 2020 07:11:05 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B533DC0889;
	Thu, 24 Sep 2020 07:11:05 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 3FE3CC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:11:04 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 3B9DC868C5
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:11:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id XrJQ84dIglMn
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:11:03 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pl1-f196.google.com (mail-pl1-f196.google.com
 [209.85.214.196])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 852048547D
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 07:11:03 +0000 (UTC)
Received: by mail-pl1-f196.google.com with SMTP id bb1so1204490plb.2
 for <containers@lists.linux-foundation.org>;
 Thu, 24 Sep 2020 00:11:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=mqsr49yCo2iSjf83d4dKwy3/hReLF+9ZnbvUsAtVECg=;
 b=fHf6+8JTZGz4OZkc5RmqWDmjG2fNb0kA8IZ9XG1XzWZ1L9jU/DFRoaUaQL3dguCzW1
 KXX48DwoGZNKKYWmcgQIrTNZc6mbItX/wyDrJs5ia9YGU+pRfubkzAvJYqXf+oFYv3h7
 Gdrct237K6JumwHGC7pwM7AuAmOiTK1HTe46A=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=mqsr49yCo2iSjf83d4dKwy3/hReLF+9ZnbvUsAtVECg=;
 b=AwiN875uYn8IipMgYvOZCG6csJFHIHlDriFs1wizlqN60n1+1KTnBScVVztro56fDw
 Gs8RrX0+8hzfPB6NuLxpFdXK/6zBWKxSVWjiPa9ywCbZhKIIcdjYRx9fPvMOvUqx/Tar
 gfC7ynyLeU6dz6GKHFpoAEZosEIG0+rRvn430MYs6AFZwYxP3zG5Oaupf1bNLYbU7uOE
 NZulae3sp0htvpl06AMcVC2TSDzrayAUzIQ3IWaaG1ujMzx2Jqvo6RADpN2snl1NEsE9
 7e37JYcKrqYb3V5yIpIxK6X5MoRScoO34pCQ3tpkThyhV9V2Cj2iU76hlwGbWlEKQAbE
 FQcw==
X-Gm-Message-State: AOAM533KHb27g7XUQN/3zP88VJ6Wec0s/iLRP1DRXajGl6iGhDm2GLDi
 qYNDIhlyR5cB55v63RIxdf6J5g==
X-Google-Smtp-Source: ABdhPJzv4SGxNbsgD8BkFEnfQt1qQLIfqoihgRZX9/LQECsfJCm5UcKJwzmliMUvjnnGLYmBo5PfBw==
X-Received: by 2002:a17:902:ff07:b029:d1:e5fa:aa1d with SMTP id
 f7-20020a170902ff07b02900d1e5faaa1dmr3259173plj.84.1600931463013; 
 Thu, 24 Sep 2020 00:11:03 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id gn24sm1360225pjb.8.2020.09.24.00.11.01
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Thu, 24 Sep 2020 00:11:02 -0700 (PDT)
Date: Thu, 24 Sep 2020 00:11:01 -0700
From: Kees Cook <keescook@chromium.org>
To: Jann Horn <jannh@google.com>
Subject: Re: [PATCH 1/6] seccomp: Introduce SECCOMP_PIN_ARCHITECTURE
Message-ID: <202009232353.FD011DAA0@keescook>
References: <20200923232923.3142503-1-keescook@chromium.org>
 <20200923232923.3142503-2-keescook@chromium.org>
 <CAG48ez17XK2Co+1LbUWTc4x_W7nza=TObNh2Kpz6P+ba3OKPsw@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez17XK2Co+1LbUWTc4x_W7nza=TObNh2Kpz6P+ba3OKPsw@mail.gmail.com>
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Thu, Sep 24, 2020 at 02:41:36AM +0200, Jann Horn wrote:
> On Thu, Sep 24, 2020 at 1:29 AM Kees Cook <keescook@chromium.org> wrote:
> > For systems that provide multiple syscall maps based on audit
> > architectures (e.g. AUDIT_ARCH_X86_64 and AUDIT_ARCH_I386 via
> > CONFIG_COMPAT) or via syscall masks (e.g. x86_x32), allow a fast way
> > to pin the process to a specific syscall table, instead of needing
> > to generate all filters with an architecture check as the first filter
> > action.
> >
> > This creates the internal representation that seccomp itself can use
> > (which is separate from the filters, which need to stay runtime
> > agnostic). Additionally paves the way for constant-action bitmaps.
> 
> I don't really see the point in providing this UAPI - the syscall
> number checking will probably have much more performance cost than the
> architecture number check, and it's not like this lets us avoid the
> check, we're just moving it over into C code.

It's desirable for libseccomp and is a request from systemd (which is,
at this point, the largest seccomp user I know of), as they have no way
to force an arch without doing it in filters, which doesn't help much
with reducing filter runtime.

> 
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> > ---
> >  include/linux/seccomp.h                       |  9 +++
> >  include/uapi/linux/seccomp.h                  |  1 +
> >  kernel/seccomp.c                              | 79 ++++++++++++++++++-
> >  tools/testing/selftests/seccomp/seccomp_bpf.c | 33 ++++++++
> >  4 files changed, 120 insertions(+), 2 deletions(-)
> >
> > diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
> > index 02aef2844c38..0be20bc81ea9 100644
> > --- a/include/linux/seccomp.h
> > +++ b/include/linux/seccomp.h
> > @@ -20,12 +20,18 @@
> >  #include <linux/atomic.h>
> >  #include <asm/seccomp.h>
> >
> > +#define SECCOMP_ARCH_IS_NATIVE         1
> > +#define SECCOMP_ARCH_IS_COMPAT         2
> 
> FYI, mips has three different possible "arch" values (per kernel build
> config; the __AUDIT_ARCH_LE flag can also be set, but that's fixed
> based on the config):
> 
>  - AUDIT_ARCH_MIPS
>  - AUDIT_ARCH_MIPS | __AUDIT_ARCH_64BIT
>  - AUDIT_ARCH_MIPS | __AUDIT_ARCH_64BIT | __AUDIT_ARCH_CONVENTION_MIPS64_N32
> 
> But I guess we can deal with that once someone wants to actually add
> support for this on mips.

Yup!

> 
> > +#define SECCOMP_ARCH_IS_MULTIPLEX      3
> 
> Why should X32 be handled specially? If the seccomp filter allows

Because it's a masked lookup into a separate table; the syscalls don't
map to x86_64's table; so for seccomp to correctly figure out which
bitmap to use, it has to do this decoding.

> specific syscalls (as it should), we don't have to care about X32.
> Only in weird cases where the seccomp filter wants to deny specific
> syscalls (a horrible idea), X32 is a concern, and in such cases, the
> userspace code can generate a single conditional jump to deal with it.

I feel like I must not understand what you mean. The x32-aware seccomp
filters are using syscall tests with 0x40000000 included in the values.
So seccomp's bitmap cannot handle this because it must know how many
syscalls to include in a linearly-allocated bitmap.

> And when seccomp is used properly to allow specific syscalls, the
> kernel will just waste time uselessly checking this X32 stuff.

It not measurable in my tests -- seccomp_data::nr is rather hot in the
cache. ;) That said, if it's unwanted, then CONFIG_X86_X32=n is the way
to go.

> [...]
> > diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> [...]
> > +static long seccomp_pin_architecture(void)
> > +{
> > +#ifdef SECCOMP_ARCH
> > +       struct task_struct *task = current;
> > +
> > +       u8 arch = seccomp_get_arch(syscall_get_arch(task),
> > +                                  syscall_get_nr(task, task_pt_regs(task)));
> > +
> > +       /* How did you even get here? */
> 
> Via a racing TSYNC, that's how.

Yes; thanks. This will need to take &current->sighand->siglock.

> 
> > +       if (task->seccomp.arch && task->seccomp.arch != arch)
> > +               return -EBUSY;
> > +
> > +       task->seccomp.arch = arch;
> > +#endif
> > +       return 0;
> > +}
> 
> Why does this return 0 if SECCOMP_ARCH is not defined? That suggests
> to userspace that we have successfully pinned the ABI, even though
> we're actually unable to do so.

Yup; thanks for the catch. This is a logical leftover from the RFC. This
should be, I think:

+       task->seccomp.arch = arch;
+       return 0;
+#else
+	return -EINVAL;
+#endif


-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
