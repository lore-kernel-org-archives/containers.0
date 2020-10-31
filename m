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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 194A2C388F7
	for <containers@archiver.kernel.org>; Sat, 31 Oct 2020 16:28:01 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 76C5422259
	for <containers@archiver.kernel.org>; Sat, 31 Oct 2020 16:28:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JkJ314p1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76C5422259
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 1C275870BA;
	Sat, 31 Oct 2020 16:28:00 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fLTWgZNMAj1O; Sat, 31 Oct 2020 16:27:59 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 32D13870B9;
	Sat, 31 Oct 2020 16:27:59 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0CC26C0859;
	Sat, 31 Oct 2020 16:27:59 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 91CCAC0051
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 16:27:57 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 7E127204D7
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 16:27:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id vyFHys3enKxS
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 16:27:56 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com
 [209.85.221.48])
 by silver.osuosl.org (Postfix) with ESMTPS id 9B82A2039A
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 16:27:55 +0000 (UTC)
Received: by mail-wr1-f48.google.com with SMTP id k10so8391198wrw.13
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 09:27:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=cc:subject:to:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=ZS1Sb48m+qDvPTafZpQbeAaJf1HLzdFEdyw+BpUANJ8=;
 b=JkJ314p1U9zUzQfmkCX8cjxR66zvv0R9vMBDQHpgpVyHH40JEbY8CYcIRcPc9qB3wd
 mAg8A3XelZGAEcfzgb4v0hWJp5MVp43unParrrzUY/qC1TrMUbPcMjCdUNNZsEKn0GzD
 i8AXxwJGJ3zBV82bBhW6z37mnKnsMM4tHls67D7o3lUnPHHmJLiKAf2i5RgW4cer7/Pl
 VqmYQuSiO03QXfI9LZDlzUwuAKC0zI3gfBFZ7oD7dxDfGKcw1xZ9dSTxJ9r2+lj1tuMY
 0xviTHQEZjDyRZ74SmxlW6cEH+HcnYVTjEqySZi66pKs54PP22nNmpzPKIGhzxbDoFD0
 qEEQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:cc:subject:to:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=ZS1Sb48m+qDvPTafZpQbeAaJf1HLzdFEdyw+BpUANJ8=;
 b=smActOeSNfYhpcUHeVbriXF0wlAjNaqLXGKMTfO4xzSXJsA9829S9UwXM5JgfFXWdD
 2uqfzkGJ6LQxZ2TL1iVhEcSka5NoNnRiPuvrs4rpEQEoyT25V3qABwCh3g8hNFp9FGof
 UIOHwK3EUlr2RhYiv+GIcPDYRbFreqSoWXDk3y6Odx4XKGbhRZfURkdsOv7sm9NmEBA/
 oZc0YTi/Fzq3/pM4evBvQB1ecuvEgHQ2CPQUfs8LGvxz7vinbobgazkeVTfnUwkvEiu0
 YT2tZPSmU1qS91SAI/GiIfLX16AmdtjcYIfu/6NH4+9Ab5RKdcBN6G4FQ6nYfD7Iu03Z
 H7NQ==
X-Gm-Message-State: AOAM530fdOYWLEfDIRvMHPQw6p7S1gxRIW3GYDsU3WDPq00CUphKFuwM
 Dmo5UZPRfvUWopImmICZ8cE=
X-Google-Smtp-Source: ABdhPJxxOLA2vFQQ1H6m0go+bytX3hwj/pax9iShqodVQzyCjGunNUIP6HAFvzjSBM8odYz/A0RSPg==
X-Received: by 2002:a05:6000:1085:: with SMTP id
 y5mr10100171wrw.283.1604161673976; 
 Sat, 31 Oct 2020 09:27:53 -0700 (PDT)
Received: from ?IPv6:2001:a61:245a:d801:2e74:88ad:ef9:5218?
 ([2001:a61:245a:d801:2e74:88ad:ef9:5218])
 by smtp.gmail.com with ESMTPSA id t4sm8912354wmb.20.2020.10.31.09.27.51
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Sat, 31 Oct 2020 09:27:52 -0700 (PDT)
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
To: Sargun Dhillon <sargun@sargun.me>
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <20201029085312.GC29881@ircssh-2.c.rugged-nimbus-611.internal>
 <48e5937b-80f5-c48b-1c67-e8c9db263ca5@gmail.com>
 <20201030202720.GA4088@ircssh-2.c.rugged-nimbus-611.internal>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <606199d6-b48c-fee2-6e79-1e52bd7f429f@gmail.com>
Date: Sat, 31 Oct 2020 17:27:51 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.3.1
MIME-Version: 1.0
In-Reply-To: <20201030202720.GA4088@ircssh-2.c.rugged-nimbus-611.internal>
Content-Language: en-US
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
 Robert Sesek <rsesek@google.com>,
 Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, lkml <linux-kernel@vger.kernel.org>,
 Alexei Starovoitov <ast@kernel.org>, mtk.manpages@gmail.com,
 bpf <bpf@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>,
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

Hello Sargun,

Thanks for your reply.

On 10/30/20 9:27 PM, Sargun Dhillon wrote:
> On Thu, Oct 29, 2020 at 09:37:21PM +0100, Michael Kerrisk (man-pages)
> wrote:

[...]

>>> I think I commented in another thread somewhere that the
>>> supervisor is not notified if the syscall is preempted. Therefore
>>> if it is performing a preemptible, long-running syscall, you need
>>> to poll SECCOMP_IOCTL_NOTIF_ID_VALID in the background, otherwise
>>> you can end up in a bad situation -- like leaking resources, or
>>> holding on to file descriptors after the program under
>>> supervision has intended to release them.
>> 
>> It's been a long day, and I'm not sure I reallu understand this. 
>> Could you outline the scnario in more detail?
>> 
> S: Sets up filter + interception for accept T: socket(AF_INET,
> SOCK_STREAM, 0) = 7 T: bind(7, {127.0.0.1, 4444}, ..) T: listen(7,
> 10) T: pidfd_getfd(T, 7) = 7 # For the sake of discussion.

Presumably, the preceding line should have been:

S: pidfd_getfd(T, 7) = 7 # For the sake of discussion.
(s/T:/S:/)

right?

> T: accept(7, ...) S: Intercepts accept S: Does accept in background 
> T: Receives signal, and accept(...) responds in EINTR T: close(7) S:
> Still running accept(7, ....), holding port 4444, so if now T
> retries to bind to port 4444, things fail.

Okay -- I understand. Presumably the solution here is not to 
block in accept(), but rather to use poll() to monitor both the
notification FD and the listening socket FD?

>>> A very specific example is if you're performing an accept on
>>> behalf of the program generating the notification, and the
>>> program intends to reuse the port. You can get into all sorts of
>>> awkward situations there.
>> 
>> [...]
>> 
> See above

[...]

>>> In addition, if it is a socket, it inherits the cgroup v1 classid
>>> and netprioidx of the receiving process.
>>> 
>>> The argument of this is as follows:
>>> 
>>> struct seccomp_notif_addfd { __u64 id; __u32 flags; __u32 srcfd; 
>>> __u32 newfd; __u32 newfd_flags; };
>>> 
>>> id This is the cookie value that was obtained using 
>>> SECCOMP_IOCTL_NOTIF_RECV.
>>> 
>>> flags A bitmask that includes zero or more of the 
>>> SECCOMP_ADDFD_FLAG_* bits set
>>> 
>>> SECCOMP_ADDFD_FLAG_SETFD - Use dup2 (or dup3?) like semantics
>>> when copying the file descriptor.
>>> 
>>> srcfd The file descriptor number to copy in the supervisor
>>> process.
>>> 
>>> newfd If the SECCOMP_ADDFD_FLAG_SETFD flag is specified this will
>>> be the file descriptor that is used in the dup2 semantics. If
>>> this file descriptor exists in the receiving process, it is
>>> closed and replaced by this file descriptor in an atomic fashion.
>>> If the copy process fails due to a MAC failure, or if srcfd is
>>> invalid, the newfd will not be closed in the receiving process.
>> 
>> Great description!
>> 
>>> If SECCOMP_ADDFD_FLAG_SETFD it not set, then this value must be
>>> 0.
>>> 
>>> newfd_flags The file descriptor flags to set on the file
>>> descriptor after it has been received by the process. The only
>>> flag that can currently be specified is O_CLOEXEC.
>>> 
>>> On success, this operation returns the file descriptor number in
>>> the receiving process. On failure, -1 is returned.
>>> 
>>> It can fail with the following error codes:
>>> 
>>> EINPROGRESS The cookie number specified hasn't been received by
>>> the listener
>> 
>> I don't understand this. Can you say more about the scenario?
>> 
> 
> This should not really happen. But if you do a ADDFD(...), on a
> notification *before* you've received it, you will get this error. So
> for example, 
> --> epoll(....) -> returns 
> --> RECV(...) cookie id is 777
> --> epoll(...) -> returns
> <-- ioctl(ADDFD, id = 778) # Notice how we haven't done a receive yet
> where we've received a notification for 778.

Got it. Looking also at the source code, I came up with the 
following:

              EINPROGRESS
                     The user-space notification specified in the id
                     field exists but has not yet been fetched (by a
                     SECCOMP_IOCTL_NOTIF_RECV) or has already been
                     responded to (by a SECCOMP_IOCTL_NOTIF_SEND).

Does that seem okay?

>>> ENOENT The cookie number is not valid. This can happen if a
>>> response has already been sent, or if the syscall was
>>> interrupted
>>> 
>>> EBADF If the file descriptor specified in srcfd is invalid, or if
>>> the fd is out of range of the destination program.
>> 
>> The piece "or if the fd is out of range of the destination program"
>> is not clear to me. Can you say some more please.
>> 
> 
> IIRC the maximum fd range is specific in proc by some sysctl named 
> nr_open. It's also evaluated against RLIMITs, and nr_max.
> 
> If nr-open (maximum fds open per process, iiirc) is 1000, even if 10
> FDs are open, it wont work if newfd is 1001.

Actually, the relevant limit seems to be just the RLIMIT_NOFILE
resource limit at least in my reading of fs/file.c::replace_fd().
So I made the text

              EBADF  Allocating the file descriptor in the target would
                     cause the target's RLIMIT_NOFILE limit to be
                     exceeded (see getrlimit(2)).

 
>>> EINVAL If flags or new_flags were unrecognized, or if newfd is
>>> non-zero, and SECCOMP_ADDFD_FLAG_SETFD has not been set.
>>> 
>>> EMFILE Too many files are open by the destination process.

I'm not sure that the error can really occur. That's the error
that in most other places occurs when RLIMIT_NOFILE is exceeded.
But I may have missed something. More precisely, when do you think
EMFILE can occur?

[...]

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
