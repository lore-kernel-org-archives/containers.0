Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97227C4363D
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 17:53:14 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0510520BED
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 17:53:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="iqJprXev"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0510520BED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 7552586E6E;
	Mon, 21 Sep 2020 17:53:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Pea-U331+RiJ; Mon, 21 Sep 2020 17:53:12 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 6497082661;
	Mon, 21 Sep 2020 17:53:12 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 58B78C0889;
	Mon, 21 Sep 2020 17:53:12 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 5722AC0895
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 17:53:10 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 50BCC86E6E
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 17:53:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id KGlipAmWpC8E
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 17:53:08 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f65.google.com (mail-lf1-f65.google.com
 [209.85.167.65])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 0F73C82661
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 17:53:08 +0000 (UTC)
Received: by mail-lf1-f65.google.com with SMTP id y17so15021609lfa.8
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 10:53:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=xVoTB5ka9ij/JNpMUQJi3uemYQWRbk5sRyxB8af0Yk4=;
 b=iqJprXevp6YDSedAolM02uxv2cp/VvZkDrKCCaO+89H5aB2fW4FG0aF+s3sWCB3S16
 LrGTxEKt5vKKXLbFEmE8dYK0Ety4W7YGQlALf6fXgM7HaJQXNIXZL29uGpoqtKz+2naV
 MmSszpAeuePE2GFK55RuS22V2W88ZD458SxQlfYzxK7EJwN8ZVtHZ4CowY54hnAe5QJC
 xJEHk+lHx884k8Ri8/X2BtjIb0eoqy29IjFDXGTYAa/7HuPWpBgyIFIVB8nosZIcFvKB
 nkqQkVBTSGebVutfgBiREpafaBBHUM991eqqzZuZwheCK+pE4a+tcor/dw+HgnDQx2Vi
 gwNA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=xVoTB5ka9ij/JNpMUQJi3uemYQWRbk5sRyxB8af0Yk4=;
 b=Jbf1dbWyV59WwRhB17D4xTHFl0KCNN5pzIstoT5Zld6lGvQYZ2jvo0s8SZDvbYjUgD
 omw9/ZCtRG9yubS74ik1WX4Bv5caYyi/NPujWWD/5bsew+ezHfyvDSobuAna7sD9R4xZ
 sXfrlZAymJTZx3P8k2AJga5HGg8UXJM6cTMplJ/12F64/XkedONwmd81f85JeUXECkvA
 X7zi32ig1HDpF9ORQJUvfdki1iptFjqnNrCtf8W4WRuznPHEpJWSRc9EVnWSwpFxVw0Q
 k4T/zOy42h07PDMtskPsLhgsJZEnYJDTZBZ2fQ40R7WBK+ButgfH2zoF0PJ1/kNx89VT
 fUXg==
X-Gm-Message-State: AOAM530aRGf4k3OyAkrlFHLnTLMGj/qxFdhXYBEUj489rnzmvV2Pysbp
 4BhEktzYRXQIqUlSeNoRPU78cPJOrCn7Ty4PuX93XC2v72LAEQ==
X-Google-Smtp-Source: ABdhPJzUx+dGF1qmUJjldN5R/Kp/CHg8b3GsPokZFi763Z3EI3PzJUFPr6qBkBdrErj+QF7fFBLW4ARTCHeUiHBtnXc=
X-Received: by 2002:a17:906:9389:: with SMTP id
 l9mr581002ejx.537.1600710452090; 
 Mon, 21 Sep 2020 10:47:32 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <6af89348c08a4820039e614a090d35aa1583acff.1600661419.git.yifeifz2@illinois.edu>
In-Reply-To: <6af89348c08a4820039e614a090d35aa1583acff.1600661419.git.yifeifz2@illinois.edu>
Date: Mon, 21 Sep 2020 19:47:05 +0200
Message-ID: <CAG48ez0OqZavgm0BkGjCAJUr5UfRgbeCbmLOZFJ=Rj46COcN3Q@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 1/2] seccomp/cache: Add "emulator" to check if
 filter is arg-dependent
To: YiFei Zhu <zhuyifei1999@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, kernel list <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf <bpf@vger.kernel.org>,
 Tianyin Xu <tyxu@illinois.edu>
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

On Mon, Sep 21, 2020 at 7:35 AM YiFei Zhu <zhuyifei1999@gmail.com> wrote:
> SECCOMP_CACHE_NR_ONLY will only operate on syscalls that do not
> access any syscall arguments or instruction pointer. To facilitate
> this we need a static analyser to know whether a filter will
> access. This is implemented here with a pseudo-emulator, and
> stored in a per-filter bitmap. Each seccomp cBPF instruction,
> aside from ALU (which should rarely be used in seccomp), gets a
> naive best-effort emulation for each syscall number.
>
> The emulator works by following all possible (without SAT solving)
> paths the filter can take. Every cBPF register / memory position
> records whether that is a constant, and of so, the value of the
> constant. Loading from struct seccomp_data is considered constant
> if it is a syscall number, else it is an unknown. For each
> conditional jump, if the both arguments can be resolved to a
> constant, the jump is followed after computing the result of the
> condition; else both directions are followed, by pushing one of
> the next states to a linked list of next states to process. We
> keep a finite number of pending states to process.

Is this actually necessary, or can we just bail out on any branch that
we can't statically resolve?

struct seccomp_data only contains the syscall number (constant for a
given filter evaluation), the architecture number (also constant), the
instruction pointer (basically never used in seccomp filters), and the
syscall arguments. Any normal seccomp filter first branches on the
architecture, then branches on the syscall number, and then branches
on arguments if necessary.

This optimization could only be improved by the "follow both branches"
logic if a seccomp program branches on either the instruction pointer
or an argument *before* looking at the syscall number, and later comes
to the same conclusion on *both* sides of the check. It would have to
be something like:

if (instruction_pointer == 0xasdf1234) {
  if (nr == mmap) return ACCEPT;
  [...]
  return KILL;
} else {
  if (nr == mmap) return ACCEPT;
  [...]
  return KILL;
}

I've never seen anyone do something like this. And the proposed patch
would still bail out on such a filter because of the load from the
instruction_pointer field; I don't think it would even be possible to
reach a branch with an unknown condition with this patch. So I think
we should probably get rid of this extra logic for keeping track of
multiple execution states for now. That would make the code a lot
simpler.


Also: If it turns out that the time spent in seccomp_cache_prepare()
is measurable for large filters, a possible improvement would be to
keep track of the last syscall number for which the result would be
the same as for the current one, such that instead of evaluating the
filter for one instruction at a time, it would effectively be
evaluated for a range at a time. That should be pretty straightforward
to implement, I think.

> The emulation is halted if it reaches a return, or if it reaches a
> read from struct seccomp_data that reads an offset that is neither
> syscall number or architecture number. In the latter case, we mark
> the syscall number as not okay for seccomp to cache. If a filter
> depends on more filters, then if its dependee cannot process the
> syscall then the depender is also marked not to process the syscall.
>
> We also do a single pass on the entire filter instructions before
> performing emulation. If none of the filter instructions load from
> the troublesome offsets, then the filter is considered "trivial",
> and all syscalls are marked okay for seccomp to cache.
>
> Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
> ---
>  arch/x86/Kconfig |  27 ++++
>  kernel/seccomp.c | 323 ++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 349 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
[...]
> +choice
> +       prompt "Seccomp filter cache"
> +       default SECCOMP_CACHE_NONE

I think this should be on by default.

> +       depends on SECCOMP
> +       depends on SECCOMP_FILTER

SECCOMP_FILTER already depends on SECCOMP, so the "depends on SECCOMP"
line is unnecessary.

> +       help
> +         Seccomp filters can potentially incur large overhead for each
> +         system call. This can alleviate some of the overhead.
> +
> +         If in doubt, select 'none'.

This should not be in arch/x86. Other architectures, such as arm64,
should also be able to use this without extra work.

> +config SECCOMP_CACHE_NONE
> +       bool "None"
> +       help
> +         No caching is done. Seccomp filters will be called each time
> +         a system call occurs in a seccomp-guarded task.
> +
> +config SECCOMP_CACHE_NR_ONLY
> +       bool "Syscall number only"
> +       help
> +         This is enables a bitmap to cache the results of seccomp
> +         filters, if the filter allows the syscall and is independent
> +         of the syscall arguments.

Maybe reword this as something like: "For each syscall number, if the
seccomp filter has a fixed result, store that result in a bitmap to
speed up system calls."

> This requires around 60 bytes per
> +         filter and 70 bytes per task.
> +
> +endchoice
> +
>  source "kernel/Kconfig.hz"
>
>  config KEXEC
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index 3ee59ce0a323..d8c30901face 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -143,6 +143,27 @@ struct notification {
>         struct list_head notifications;
>  };
>
> +#ifdef CONFIG_SECCOMP_CACHE_NR_ONLY
> +/**
> + * struct seccomp_cache_filter_data - container for cache's per-filter data
> + *
> + * @syscall_ok: A bitmap where each bit represent whether seccomp is allowed to

nit: represents

> + *             cache the results of this syscall.
> + */
> +struct seccomp_cache_filter_data {
> +       DECLARE_BITMAP(syscall_ok, NR_syscalls);
> +};
> +
> +#define SECCOMP_EMU_MAX_PENDING_STATES 64
> +#else
> +struct seccomp_cache_filter_data { };
> +
> +static inline int seccomp_cache_prepare(struct seccomp_filter *sfilter)
> +{
> +       return 0;
> +}
> +#endif /* CONFIG_SECCOMP_CACHE_NR_ONLY */
[...]
> +/**
> + * seccomp_emu_step - step one instruction in the emulator
> + * @env: The emulator environment
> + * @state: The emulator state
> + *
> + * Returns 1 to halt emulation, 0 to continue, or -errno if error occurred.
> + */
> +static int seccomp_emu_step(struct seccomp_emu_env *env,
> +                           struct seccomp_emu_state *state)
> +{
> +       struct sock_filter *ftest = &env->filter[state->pc++];
> +       struct seccomp_emu_state *new_state;
> +       u16 code = ftest->code;
> +       u32 k = ftest->k;
> +       u32 operand;
> +       bool compare;
> +       int reg_idx;
> +
> +       switch (BPF_CLASS(code)) {
> +       case BPF_LD:
> +       case BPF_LDX:
> +               reg_idx = BPF_CLASS(code) == BPF_LDX;
> +
> +               switch (BPF_MODE(code)) {
> +               case BPF_IMM:
> +                       state->reg_known[reg_idx] = true;
> +                       state->reg_const[reg_idx] = k;
> +                       break;
> +               case BPF_ABS:
> +                       if (k == offsetof(struct seccomp_data, nr)) {
> +                               state->reg_known[reg_idx] = true;
> +                               state->reg_const[reg_idx] = env->nr;
> +                       } else {
> +                               state->reg_known[reg_idx] = false;

This is completely broken. This emulation logic *needs* to run with
the proper architecture identifier. (And for platforms like x86-64
that have compatibility support for a second ABI, the emulation should
probably also be done for that ABI, and there should be separate
bitmasks for that ABI.)

With the current logic, you will (almost) never actually have
permitted syscalls in the bitmask, because filters fundamentally have
to return different results for different ABIs - the syscall numbers
mean completely different things under different ABIs.

> +                               if (k != offsetof(struct seccomp_data, arch)) {
> +                                       env->syscall_ok = false;
> +                                       return 1;
> +                               }
> +                       }

This would read nicer as:

if (k == offsetof(struct seccomp_data, nr)) {

} else if (k == offsetof(struct seccomp_data, arch)) {

} else {
  env->syscall_ok = false;
  return 1;
}

> +
> +                       break;
> +               case BPF_MEM:
> +                       state->reg_known[reg_idx] = state->reg_known[2 + k];
> +                       state->reg_const[reg_idx] = state->reg_const[2 + k];
> +                       break;
> +               default:
> +                       state->reg_known[reg_idx] = false;
> +               }
> +
> +               return 0;
> +       case BPF_ST:
> +       case BPF_STX:
> +               reg_idx = BPF_CLASS(code) == BPF_STX;
> +
> +               state->reg_known[2 + k] = state->reg_known[reg_idx];
> +               state->reg_const[2 + k] = state->reg_const[reg_idx];

I think we should probably just bail out if we see anything that's
BPF_ST/BPF_STX. I've never seen seccomp filters that actually use that
part of cBPF.

But in case we do need this, maybe instead of using "2 +" for all
these things, the cBPF memory slots should be in a separate array.

> +               return 0;
> +       case BPF_ALU:
> +               state->reg_known[0] = false;
> +               return 0;
> +       case BPF_JMP:
> +               if (BPF_OP(code) == BPF_JA) {
> +                       state->pc += k;
> +                       return 0;
> +               }
> +
> +               if (ftest->jt == ftest->jf) {
> +                       state->pc += ftest->jt;
> +                       return 0;
> +               }

Why is this check here? Is anyone actually creating filters with such
obviously nonsensical branches? I know that there are highly ludicrous
filters out there, but I don't think I've ever seen this specific kind
of useless code.

> +               if (!state->reg_known[0])
> +                       goto both_cases;
[...]
> +both_cases:
> +               if (env->next_state_len >= SECCOMP_EMU_MAX_PENDING_STATES)
> +                       return -E2BIG;

Even if we cap the maximum number of pending states, this could still
run for an almost unbounded amount of time, I think. Which is bad. If
this code was actually necessary, we'd probably want to track
separately the total number of branches we've seen and so on.

But as I said, I think this code should just be removed instead.

[...]
> +       }
> +}
[...]
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
