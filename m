Return-Path: <SRS0=qqQl=EG=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.8 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B893CC388F7
	for <containers@archiver.kernel.org>; Sat, 31 Oct 2020 08:52:02 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1E2F120756
	for <containers@archiver.kernel.org>; Sat, 31 Oct 2020 08:52:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tQB+6tZP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E2F120756
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 7F1572A0D9;
	Sat, 31 Oct 2020 08:52:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id cjzWvXtJ5U8B; Sat, 31 Oct 2020 08:52:00 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 0082627515;
	Sat, 31 Oct 2020 08:52:00 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D374EC0859;
	Sat, 31 Oct 2020 08:51:59 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id DEC31C0051
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 08:51:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id C2B3F873A1
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 08:51:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id XOzKpg+OmgtK
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 08:51:58 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wr1-f66.google.com (mail-wr1-f66.google.com
 [209.85.221.66])
 by whitealder.osuosl.org (Postfix) with ESMTPS id C2EE5870FE
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 08:51:57 +0000 (UTC)
Received: by mail-wr1-f66.google.com with SMTP id y12so8888794wrp.6
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 01:51:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=cc:subject:to:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=+69KEmce40v1epkbBxC+EGokBd+WLifMbLXb2C4t/lA=;
 b=tQB+6tZP3FxHXK7vRjRjl/DIqF0zdN8CH995uIGjnRYMeb7zfG3AnSikMcEhoErZ7L
 aeZ26T5pUjYsPq/DvXOWuE4qkkvHAROor6YF7IH8C6ibRohhhXEeOJfqgrO2+rFK1Twx
 y2uzRz7LyHoBOmO0eg1H+WhIW+DHKLEA3QP6eSYvxBPSQvLm+UAsFrOz5plzIA38Cs0z
 /NOmTMk8SsuKG6JRVKssbaZy9i+TTP/1j3sn8fQ7CTcGwfemBuIrXF0hfxdJDs/8EWSp
 pd3YD52nz5BO+nxcIFQ5TZ1Lu153VJI0TbvtpZFPXPg4YG8Dqfg6Dc1xeWccNOM/nzE8
 g0gw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:cc:subject:to:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=+69KEmce40v1epkbBxC+EGokBd+WLifMbLXb2C4t/lA=;
 b=LYd7LIhdMKgpaSs8CmB0BS1aTMJ1G89NgIyni/0Ykjm/6x7QnwWvWBRU0rHfo9BcT5
 +vkG05gQAD5gnudp57qSUXT415DORC9H3tp8fFLWDb1179zxZ5l/qsEGPZqMgF/seCir
 rc54ZdkxeQoacw5EXBp/vfwECmoJ8YdIVwzHG31iEHw1kh1pa2F3U+BqZ1DqRxRk+f+U
 ZPD4DkfinXG4elK38FseC0UkL/YgruHMFAivI6DIkcL0nUhszVH67cSbZlffSWX72GRm
 iZM5vXqbmOm4/qkxDkBMSlJfQUsVseLFQjV2MkyIKUDB/n9PexXrkpVmw6S4GxDbiZWb
 dBZg==
X-Gm-Message-State: AOAM530XdsXQrR3ko96BBeiYhF1FJ6B55cfktkiqI9WpTvGfCLzlN84q
 hYvXybTJbh32k/dedGlclQ0=
X-Google-Smtp-Source: ABdhPJxD1Wl7Aoo5KK/QUcpzK+vCCHNuYnBktAz8VMEEa+l0I3PpBYpYhQz5VAv2fBzlLxAc8NGsCA==
X-Received: by 2002:adf:fd82:: with SMTP id d2mr8149160wrr.304.1604134316071; 
 Sat, 31 Oct 2020 01:51:56 -0700 (PDT)
Received: from ?IPv6:2001:a61:245a:d801:2e74:88ad:ef9:5218?
 ([2001:a61:245a:d801:2e74:88ad:ef9:5218])
 by smtp.gmail.com with ESMTPSA id v6sm7438264wmj.6.2020.10.31.01.51.54
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Sat, 31 Oct 2020 01:51:55 -0700 (PDT)
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
To: Jann Horn <jannh@google.com>
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
 <93cfdc79-4c48-bceb-3620-4c63e9f4822e@gmail.com>
 <CAG48ez3nH2Oiz9wMSpvUxxX_TRYTT98d3Nj1vnCuJOj9CCXH8Q@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <b43b50a2-fa5c-419d-ad24-3fd40bc26dba@gmail.com>
Date: Sat, 31 Oct 2020 09:51:51 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.3.1
MIME-Version: 1.0
In-Reply-To: <CAG48ez3nH2Oiz9wMSpvUxxX_TRYTT98d3Nj1vnCuJOj9CCXH8Q@mail.gmail.com>
Content-Language: en-US
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
 Robert Sesek <rsesek@google.com>,
 Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 mtk.manpages@gmail.com, bpf <bpf@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>,
 Christian Brauner <christian@brauner.io>
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

On 10/30/20 8:20 PM, Jann Horn wrote:
> On Thu, Oct 29, 2020 at 8:14 PM Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>> On 10/29/20 2:42 AM, Jann Horn wrote:
>>> As discussed at
>>> <https://lore.kernel.org/r/CAG48ez0m4Y24ZBZCh+Tf4ORMm9_q4n7VOzpGjwGF7_Fe8EQH=Q@mail.gmail.com>,
>>> we need to re-check checkNotificationIdIsValid() after reading remote
>>> memory but before using the read value in any way. Otherwise, the
>>> syscall could in the meantime get interrupted by a signal handler, the
>>> signal handler could return, and then the function that performed the
>>> syscall could free() allocations or return (thereby freeing buffers on
>>> the stack).
>>>
>>> In essence, this pread() is (unavoidably) a potential use-after-free
>>> read; and to make that not have any security impact, we need to check
>>> whether UAF read occurred before using the read value. This should
>>> probably be called out elsewhere in the manpage, too...
>>>
>>> Now, of course, **reading** is the easy case. The difficult case is if
>>> we have to **write** to the remote process... because then we can't
>>> play games like that. If we write data to a freed pointer, we're
>>> screwed, that's it. (And for somewhat unrelated bonus fun, consider
>>> that /proc/$pid/mem is originally intended for process debugging,
>>> including installing breakpoints, and will therefore happily write
>>> over "readonly" private mappings, such as typical mappings of
>>> executable code.)
>>>
>>> So, uuuuh... I guess if anyone wants to actually write memory back to
>>> the target process, we'd better come up with some dedicated API for
>>> that, using an ioctl on the seccomp fd that magically freezes the
>>> target process inside the syscall while writing to its memory, or
>>> something like that? And until then, the manpage should have a big fat
>>> warning that writing to the target's memory is simply not possible
>>> (safely).
>>
>> Thank you for your very clear explanation! It turned out to be
>> trivially easy to demonstrate this issue with a slightly modified
>> version of my program.
>>
>> As well as the change to the code example that I already mentioned
>> my reply of a few hours ago, I've added the following text to the
>> page:
>>
>>    Caveats regarding the use of /proc/[tid]/mem
>>        The discussion above noted the need to use the
>>        SECCOMP_IOCTL_NOTIF_ID_VALID ioctl(2) when opening the
>>        /proc/[tid]/mem file of the target to avoid the possibility of
>>        accessing the memory of the wrong process in the event that the
>>        target terminates and its ID is recycled by another (unrelated)
>>        thread.  However, the use of this ioctl(2) operation is also
>>        necessary in other situations, as explained in the following
>>        pargraphs.
> 
> (nit: paragraphs)

I spotted that one also already. But thanks for reading carefully!

>>        Consider the following scenario, where the supervisor tries to
>>        read the pathname argument of a target's blocked mount(2) system
>>        call:
> [...]
>> Seem okay?
> 
> Yeah, sounds good.
> 
>> By the way, is there any analogous kind of issue concerning
>> pidfd_getfd()? I'm thinking not, but I wonder if I've missed
>> something.
> 
> When it is used by a seccomp supervisor, you mean? I think basically
> the same thing applies - when resource identifiers (such as memory
> addresses or file descriptors) are passed to a syscall, it generally
> has to be assumed that those identifiers may become invalid and be
> reused as soon as the syscall has returned.

I probably needed to be more explicit. Would the following (i.e., a
single cookie check) not be sufficient to handle the above scenario.
Here, the target is making a syscall a system call that employs the
file descriptor 'tfd':

T: makes syscall that triggers notification
S: Get notification
S: pidfd = pidfd_open(T, 0);
S: sfd = pifd_getfd(pidfd, tfd, 0)
S: check that the cookie is still valid
S: do operation with sfd [*]

By contrast, I can see that we might want to do multiple cookie
checks in the /proc/PID/mem case, since the supervisor might do
multiple reads.

Or, do you mean: there really needs to be another cookie check after
the point [*], since, if the the target's syscall was interrupted
and 'tfd' was closed/resused, then the supervisor would be operating
with a file descriptor that refers to an open file description
(a "struct file") that is no longer meaningful in the target?
(Thinking about it, I think this probably is what you mean, but 
I want to confirm.)

Thanks,

Michael
-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
