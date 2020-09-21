Return-Path: <SRS0=X0Oq=C6=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03799C43466
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 15:28:13 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 752812085B
	for <containers@archiver.kernel.org>; Mon, 21 Sep 2020 15:28:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bk12Y9q2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 752812085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id E8C822001E;
	Mon, 21 Sep 2020 15:28:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id icdJKM0A+w77; Mon, 21 Sep 2020 15:28:10 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 8303A1FE65;
	Mon, 21 Sep 2020 15:28:10 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6573DC0889;
	Mon, 21 Sep 2020 15:28:10 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 3A64AC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 15:28:09 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 1F0F187291
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 15:28:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id XD4sHpz6NAMt
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 15:28:08 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pj1-f68.google.com (mail-pj1-f68.google.com
 [209.85.216.68])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 621A98726A
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 15:28:08 +0000 (UTC)
Received: by mail-pj1-f68.google.com with SMTP id jw11so7328905pjb.0
 for <containers@lists.linux-foundation.org>;
 Mon, 21 Sep 2020 08:28:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=kw9zFapd9SW+zuhwhTuJ3eJHqglSccYNB3MuySBWWOw=;
 b=bk12Y9q2B0Yk1G4hAcboUYdVUipOX+HSabhDsdDoCKeQHx4hzhs8ZeG8Ky6OzIRACn
 N9MQ2+LUmeXhucWq64AZK3D7AcmK45BP1ww0Si+5AFxsEouRn393+QfiTsvR2zh7N+Pu
 gbF59YFFdg3ceSCXB/QQu3aMi8CSeF5pT88rJE9eKevU+LcoIh1l1b5gxmjxTHIWGjGm
 gzeKWuKpgEr63E8eDJQKWbjNCSqlY+vkU60pSygLvNRgvioJPP+WY+85MfCmv0vZCu20
 /WfpqPvF1PuXAKceJGN30HmWyzb1yv7v1p/+3EKmHadog59uqEehLONBKasaC4lHF3gV
 iKgw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=kw9zFapd9SW+zuhwhTuJ3eJHqglSccYNB3MuySBWWOw=;
 b=SaPmfKIDeq+gQKYoNybpotAYIgNisnatuYJp1WngND3Q9guKMPp79j4HPd6WEtF14N
 A2orIGHtlOhLg7imhNjhWbEobNVd4ihcXeEP6ce17mYxm4TY8fzJJFb5Iwq9z0WpLCSz
 //EoRF3WKTWhYWN4DXaNrDJczuOjYmhRuPNUZe9r5AiWIsY3Wscd9G4AgkEyRu0iBmWc
 j6+WlWuGhzQq9d9FrMKo4Rmk+loHcGkkqngpa8XUxToNmQgOsgzyrQf/v4y346fYTAvW
 /t9sGeod6UvrgrOOclXmHkJAL1QVjNtxpM3w4LWfo2CfBs1NAkSeSomXN3RN7qnst85r
 aaKA==
X-Gm-Message-State: AOAM532zpUTONS797i0vpVIrMHF/dRGrnPkk+6601tpajBOdnXEqi62x
 kB9BEcV5a55/tQ7/EJVp8j3aFryw2Wzi2ZSoXrk=
X-Google-Smtp-Source: ABdhPJwZERAoWm+O+z1FTngCRBN7/Z4B8FPp1WhzJzSrBw1Ub2E2itWQa4qGm4rwDpcB1kATf93CuS2kaBKJoFs/9D0=
X-Received: by 2002:a17:90b:4b82:: with SMTP id
 lr2mr287928pjb.184.1600702087931; 
 Mon, 21 Sep 2020 08:28:07 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1600661418.git.yifeifz2@illinois.edu>
 <20200921135115.GC3794348@cisco>
In-Reply-To: <20200921135115.GC3794348@cisco>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Mon, 21 Sep 2020 10:27:56 -0500
Message-ID: <CABqSeASEw=Qr2CroKEpTyWMRXQkamKVUzXiEe2UsoQTCcv_99A@mail.gmail.com>
Subject: Re: [RFC PATCH seccomp 0/2] seccomp: Add bitmap cache of
 arg-independent filter results that allow syscalls
To: Tycho Andersen <tycho@tycho.pizza>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>, linux-kernel@vger.kernel.org,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>, Hubertus Franke <frankeh@us.ibm.com>,
 Andy Lutomirski <luto@amacapital.net>, Valentin Rothberg <vrothber@redhat.com>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>, Jack Chen <jianyan2@illinois.edu>,
 Josep Torrellas <torrella@illinois.edu>, bpf@vger.kernel.org,
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Mon, Sep 21, 2020 at 8:51 AM Tycho Andersen <tycho@tycho.pizza> wrote:
> One problem with a kernel config setting is that it's for all tasks.
> While docker and systemd may make decsisions based on syscall number,
> other applications may have more nuanced filters, and this cache would
> yield incorrect results.
>
> You could work around this by making this a filter flag instead;
> filter authors would generally know whether their filter results can
> be cached and probably be motivated to opt in if their users are
> complaining about slow syscall execution.
>
> Tycho

Yielding incorrect results should not be possible. The purpose of the
"emulator" (for the lack of a better term) is to determine whether the
filter reads any syscall arguments. A read from a syscall argument
must go through the BPF_LD | BPF_ABS instruction, where the 32 bit
multiuse field "k" is an offset to struct seccomp_data.

struct seccomp_data contains four components [1]: syscall number,
architecture number, instruction pointer at the time of syscall, and
syscall arguments. The syscall number is enumerated by the emulator.
The arch number is treated by the cache as 'if arch number is
different from cached arch number, flush cache' (this is in
seccomp_cache_check). The last two (ip and args) are treated exactly
the same way in this patch: if the filter loads the arguments at all,
the syscall is marked non-cacheable for any architecture number.

The struct seccomp_data is the only external thing the filter may
access. It is also cBPF so it cannot contain maps to store special
states between runs. Therefore a seccomp filter is pure function. If
we know given some inputs (the syscall number and arch number) the
function will not evaluate any other inputs before returning, then we
can safely cache with just the inputs in concern.

As for the overhead, on my x86_64 with gcc 10.2.0, seccomp_cache_check
compiles into:

    if (unlikely(syscall_nr < 0 || syscall_nr >= NR_syscalls))
        return false;
0xffffffff8120fdb3 <+99>:    movsxd rdx,DWORD PTR [r12]
0xffffffff8120fdb7 <+103>:    cmp    edx,0x1b7
0xffffffff8120fdbd <+109>:    ja     0xffffffff8120fdf9 <__seccomp_filter+169>
    if (unlikely(thread_data->last_filter != sfilter ||
             thread_data->last_arch != sd->arch)) {
0xffffffff8120fdbf <+111>:    mov    rdi,QWORD PTR [rbp-0xb8]
0xffffffff8120fdc6 <+118>:    lea    rsi,[rax+0x6f0]
0xffffffff8120fdcd <+125>:    cmp    rdi,QWORD PTR [rax+0x728]
0xffffffff8120fdd4 <+132>:    jne    0xffffffff812101f0 <__seccomp_filter+1184>
0xffffffff8120fdda <+138>:    mov    ebx,DWORD PTR [r12+0x4]
0xffffffff8120fddf <+143>:    cmp    DWORD PTR [rax+0x730],ebx
0xffffffff8120fde5 <+149>:    jne    0xffffffff812101f0 <__seccomp_filter+1184>
    return test_bit(syscall_nr, thread_data->syscall_ok);
0xffffffff8120fdeb <+155>:    bt     QWORD PTR [rax+0x6f0],rdx
0xffffffff8120fdf3 <+163>:    jb     0xffffffff8120ffb7 <__seccomp_filter+615>
[... unlikely path of cache flush omitted]

and seccomp_cache_insert compiles into:

    if (unlikely(syscall_nr < 0 || syscall_nr >= NR_syscalls))
        return;
0xffffffff8121021b <+1227>:    movsxd rax,DWORD PTR [r12]
0xffffffff8121021f <+1231>:    cmp    eax,0x1b7
0xffffffff81210224 <+1236>:    ja     0xffffffff8120ffb7 <__seccomp_filter+615>
    if (!test_bit(syscall_nr, sfilter->cache.syscall_ok))
        return;
0xffffffff8121022a <+1242>:    mov    rbx,QWORD PTR [rbp-0xb8]
0xffffffff81210231 <+1249>:    mov    rdx,QWORD PTR gs:0x17000
0xffffffff8121023a <+1258>:    bt     QWORD PTR [rbx+0x108],rax
0xffffffff81210242 <+1266>:    jae    0xffffffff8120ffb7 <__seccomp_filter+615>
    set_bit(syscall_nr, thread_data->syscall_ok);
0xffffffff81210248 <+1272>:    lock bts QWORD PTR [rdx+0x6f0],rax
0xffffffff81210251 <+1281>:    jmp    0xffffffff8120ffb7 <__seccomp_filter+615>

In the circumstance of a non-cacheable syscall happening over and
over, the code path would go through the syscall_nr bound check, then
the filter flush check, then the test_bit, then another syscall_nr
bound check and one more test_bit in seccomp_cache_insert. Considering
that they are either stack variables, elements of current task_struct,
and elements of the filter struct, I imagine they would well be in the
CPU data cache and not incur much overhead. The CPU is also free to
branch predict and reorder memory accesses (there are no hardware
memory barriers here) to further increase the efficiency, whereas a
normal filter execution would be impaired by things like retpoline.

If one were to add an additional flag for
does-userspace-want-us-to-cache, it would still be a member of the
filter struct. What would be loaded into the CPU data cache originally
would still be loaded. Correct me if I'm wrong, but I don't think that
check will reduce any significant overhead of the seccomp cache
itself.

That said, I have not profiled the exact number of milliseconds this
patch would incur to uncacheable syscalls, I can report back with
numbers if you would like to see.

Does that answer your concern?

YiFei Zhu

[1] https://elixir.bootlin.com/linux/latest/source/include/uapi/linux/seccomp.h#L60
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
