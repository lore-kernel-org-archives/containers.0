Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.8 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4297C4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 14:19:56 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3682E20780
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 14:19:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rpkj0Jc7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3682E20780
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id A2EC88640E;
	Thu, 29 Oct 2020 14:19:55 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id XJgLkDjzARL3; Thu, 29 Oct 2020 14:19:54 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id B06888665B;
	Thu, 29 Oct 2020 14:19:54 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9647DC0859;
	Thu, 29 Oct 2020 14:19:54 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 447F1C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 14:19:53 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 2B825875A5
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 14:19:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id UXju1j3f4Y9c
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 14:19:52 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wr1-f66.google.com (mail-wr1-f66.google.com
 [209.85.221.66])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 0AB69870B0
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 14:19:52 +0000 (UTC)
Received: by mail-wr1-f66.google.com with SMTP id k10so1633593wrw.13
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 07:19:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=cc:subject:to:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=IG7tsLJmeRfHh6RhAZa+dQgZB0okc8aPFoAcBoJ4Rrg=;
 b=rpkj0Jc75yJkzo7xNX6lc0EksZSpF9MeOYniMB45rwEzzLCMwxAQPpDmyY7IhCFbxE
 Zw922+i3sidiSvYnZ8HossRSuxUVSDRMWCCpXsVQHe2OoXQqi4iG3leW8u12iTErdfpO
 4CLcho2aHQTCi9v2z0Pck4m+ZPvbVWvi84YCi4LecEkcnhssZ5HgYhAi35V+MAFaOFVs
 T6hYs4h7BEfZojdm6yKECBuWaieovAhiHKT81+AkM3TyazL4WbZgZz6Y/jlprCTo9giw
 0ZpRCBnS4s6h9Fbxwpr3G4JtQ7C/tlAAHd5PW6x61ySnXZuOsrG01jTjbZf8hhVcFAD1
 G/SA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:cc:subject:to:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=IG7tsLJmeRfHh6RhAZa+dQgZB0okc8aPFoAcBoJ4Rrg=;
 b=EnIBrQQaLNMhz2gPAMvvDP8BLOKquwyJPWz5VRY2sfI539gWl1embrgeNy6yOuOQCd
 +AkecXKYb3T4FNtzJZPZINmDPrwJUDCG5zLJRzzBqdLhRQ69mOl7sGpuOKMWj60mfiLT
 Iqai1vfoWLDSIHkEC6Upw6rfkIH3tmr/nZRBt1U0uAU4HjcgZjSCBGLMDyBmzlokZgYc
 urtBSva6YgOQyQkTA6hlMM5EAkAn15k/6gVuNLRZl2YJP2R7RQF/CJg/cohpbMmb8jW7
 Boo6RtdblLnIbnELvwPXpqEX5abi7LrN7X//A3vDCyCFulMoRNV3fp40wsCEIBtnO9ON
 S2Qw==
X-Gm-Message-State: AOAM533s4NtO8jqTQd5zc9hFMkmetAZk28VacdWIqYSZbyX/5xowwnYz
 pJQ+LUrxvU6DeyomsK/mXiQ=
X-Google-Smtp-Source: ABdhPJySnfrnD0+l5dneed6fFIU3+/0xpO41ctDgfWTaEnqrPyFvDhe+3nU9GLoPc83nDDVqmBg11w==
X-Received: by 2002:a5d:490c:: with SMTP id x12mr5816557wrq.193.1603981190393; 
 Thu, 29 Oct 2020 07:19:50 -0700 (PDT)
Received: from ?IPv6:2001:a61:245a:d801:2e74:88ad:ef9:5218?
 ([2001:a61:245a:d801:2e74:88ad:ef9:5218])
 by smtp.gmail.com with ESMTPSA id x21sm6413570wmi.3.2020.10.29.07.19.48
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Thu, 29 Oct 2020 07:19:49 -0700 (PDT)
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
To: Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <0de41eb1-e1fd-85da-61b7-fac4e3006726@gmail.com>
Date: Thu, 29 Oct 2020 15:19:45 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.3.1
MIME-Version: 1.0
In-Reply-To: <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
Content-Language: en-US
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Robert Sesek <rsesek@google.com>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
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

Hello Jann,

On 10/29/20 2:42 AM, Jann Horn wrote:
> On Mon, Oct 26, 2020 at 10:55 AM Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>>        static bool
>>        getTargetPathname(struct seccomp_notif *req, int notifyFd,
>>                          char *path, size_t len)
>>        {
>>            char procMemPath[PATH_MAX];
>>
>>            snprintf(procMemPath, sizeof(procMemPath), "/proc/%d/mem", req->pid);
>>
>>            int procMemFd = open(procMemPath, O_RDONLY);
>>            if (procMemFd == -1)
>>                errExit("\tS: open");
>>
>>            /* Check that the process whose info we are accessing is still alive.
>>               If the SECCOMP_IOCTL_NOTIF_ID_VALID operation (performed
>>               in checkNotificationIdIsValid()) succeeds, we know that the
>>               /proc/PID/mem file descriptor that we opened corresponds to the
>>               process for which we received a notification. If that process
>>               subsequently terminates, then read() on that file descriptor
>>               will return 0 (EOF). */
>>
>>            checkNotificationIdIsValid(notifyFd, req->id);
>>
>>            /* Read bytes at the location containing the pathname argument
>>               (i.e., the first argument) of the mkdir(2) call */
>>
>>            ssize_t nread = pread(procMemFd, path, len, req->data.args[0]);
>>            if (nread == -1)
>>                errExit("pread");
> 
> As discussed at
> <https://lore.kernel.org/r/CAG48ez0m4Y24ZBZCh+Tf4ORMm9_q4n7VOzpGjwGF7_Fe8EQH=Q@mail.gmail.com>,
> we need to re-check checkNotificationIdIsValid() after reading remote
> memory but before using the read value in any way. Otherwise, the
> syscall could in the meantime get interrupted by a signal handler, the
> signal handler could return, and then the function that performed the
> syscall could free() allocations or return (thereby freeing buffers on
> the stack).
> 
> In essence, this pread() is (unavoidably) a potential use-after-free
> read; and to make that not have any security impact, we need to check
> whether UAF read occurred before using the read value. This should
> probably be called out elsewhere in the manpage, too...

Thanks very much for pointing me at this!

So, I want to conform that the fix to the code is as simple as
adding a check following the pread() call, something like:

[[
     ssize_t nread = pread(procMemFd, path, len, req->data.args[argNum]);
     if (nread == -1)
        errExit("Supervisor: pread");
 
     if (nread == 0) {
        fprintf(stderr, "\tS: pread() of /proc/PID/mem "
                "returned 0 (EOF)\n");
        exit(EXIT_FAILURE);
     }
 
     if (close(procMemFd) == -1)
        errExit("Supervisor: close-/proc/PID/mem");
 
+    /* Once again check that the notification ID is still valid. The
+       case we are particularly concerned about here is that just
+       before we fetched the pathname, the target's blocked system
+       call was interrupted by a signal handler, and after the handler
+       returned, the target carried on execution (past the interrupted
+       system call). In that case, we have no guarantees about what we
+       are reading, since the target's memory may have been arbitrarily
+       changed by subsequent operations. */
+
+    if (!notificationIdIsValid(notifyFd, req->id, "post-open"))
+        return false;
+
     /* We have no guarantees about what was in the memory of the target
        process. We therefore treat the buffer returned by pread() as
        untrusted input. The buffer should be terminated by a null byte;
        if not, then we will trigger an error for the target process. */
 
     if (strnlen(path, nread) < nread)
         return true;
]]

> Now, of course, **reading** is the easy case. The difficult case is if
> we have to **write** to the remote process... because then we can't
> play games like that. If we write data to a freed pointer, we're
> screwed, that's it. (And for somewhat unrelated bonus fun, consider
> that /proc/$pid/mem is originally intended for process debugging,
> including installing breakpoints, and will therefore happily write
> over "readonly" private mappings, such as typical mappings of
> executable code.)
> 
> So, uuuuh... I guess if anyone wants to actually write memory back to
> the target process, we'd better come up with some dedicated API for
> that, using an ioctl on the seccomp fd that magically freezes the
> target process inside the syscall while writing to its memory, or
> something like that? And until then, the manpage should have a big fat
> warning that writing to the target's memory is simply not possible
> (safely).
> 
>>            if (nread == 0) {
>>                fprintf(stderr, "\tS: pread() of /proc/PID/mem "
>>                        "returned 0 (EOF)\n");
>>                exit(EXIT_FAILURE);
>>            }
> .

I'll think over some changes to the text of the manual page.

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
