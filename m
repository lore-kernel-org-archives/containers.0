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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4652DC388F7
	for <containers@archiver.kernel.org>; Sat, 31 Oct 2020 08:32:03 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A63502074F
	for <containers@archiver.kernel.org>; Sat, 31 Oct 2020 08:32:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nkyMxNml"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A63502074F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 13F212D059;
	Sat, 31 Oct 2020 08:32:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NG0m9Ms6Wre0; Sat, 31 Oct 2020 08:31:57 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id B27D820020;
	Sat, 31 Oct 2020 08:31:56 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 95DA9C0859;
	Sat, 31 Oct 2020 08:31:56 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 74E5AC0051
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 08:31:54 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 579028730C
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 08:31:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id kON5wDP9orBA
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 08:31:53 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wm1-f66.google.com (mail-wm1-f66.google.com
 [209.85.128.66])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 2ED1C8726A
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 08:31:53 +0000 (UTC)
Received: by mail-wm1-f66.google.com with SMTP id d3so4851145wma.4
 for <containers@lists.linux-foundation.org>;
 Sat, 31 Oct 2020 01:31:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=cc:subject:to:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=gwESmo+bSPSmTJDiKLpcaTLVBvMkudbYKi/iPkEZuo8=;
 b=nkyMxNmlnja8d0utNiobAlC4APn36Pl708MmnUPDMdFITVDcTP0XnCiIKIoA9yzYaU
 wXdw6yDDz4ty8XvOekZa1GvefK8dZWlMygC4GqGlxg/oQgsGuTak+dYWNQcAYNgx/Ba9
 EoMNa6AjxR7UucvurifKIpJABa8QxBHbigOF5Iw+9ENXAFbDHLBGMavfXDh5ckqy+zzo
 vdrYs91S5MTyLvzq9EJ1c8CkntthSXWkhqqojnBJiPYU0B7OkNsK3SiVzFaN0mf3BTP8
 Nti50Bb9ju841uiOilMhCEhjU05s6oDIDuhx1uDOk9Abq0HyhiS6LqkWPm7DnBasEEFm
 0PdQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:cc:subject:to:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=gwESmo+bSPSmTJDiKLpcaTLVBvMkudbYKi/iPkEZuo8=;
 b=fMxdu9hpKTrCM8L2X8cYynfz2PkmkXbFNyrTflV+1c0TpFv76uhQ5vkAJhnuYdHiS1
 anLGOAOa8uxYwRYguoqb8035i5PVzVTndbV91+6NufxnbTb2Hf4eJH73emLpzlw92HaE
 b4wh/CmbPPytLDIQuYRuc1CssYgmRaI9Tjyj002ulyjjzkcuqCftwXdcUr0i3f1FbaiW
 AJT1kLgNHUcYPOZfYUuAb9RKnaxqvJ4cFDsoOnzLZm83gmNAXxm6Eu+5IDle9Rnx4wRP
 k/EzyR2CNlMArKnwrI7uJ4qJYzLGUb8mevS55tPX4p2eJHW11kR1EWKiNd83p8hpVNXd
 UFJA==
X-Gm-Message-State: AOAM533PImsMjz/9tzXqpko58LBsBtuyEMIFFBkL2pvw+P2kKUZuRbk5
 8nXZbK0iHLz4ReBPSPYHvOg=
X-Google-Smtp-Source: ABdhPJzI04cLpRhHAbCXpntnIa72kZwXW3SoQdziwX2vZGAsDt8H5Ev+5h0mLvDdEjRUbGa4wcdOtw==
X-Received: by 2002:a1c:8087:: with SMTP id b129mr7036629wmd.10.1604133111490; 
 Sat, 31 Oct 2020 01:31:51 -0700 (PDT)
Received: from ?IPv6:2001:a61:245a:d801:2e74:88ad:ef9:5218?
 ([2001:a61:245a:d801:2e74:88ad:ef9:5218])
 by smtp.gmail.com with ESMTPSA id t12sm14001675wrm.25.2020.10.31.01.31.49
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Sat, 31 Oct 2020 01:31:50 -0700 (PDT)
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
To: Jann Horn <jannh@google.com>
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <CAG48ez0fBE6AJfWh0in=WKkgt98y=KjAen=SQPyTYtvsUbF1yA@mail.gmail.com>
 <0de41eb1-e1fd-85da-61b7-fac4e3006726@gmail.com>
 <CAG48ez3qKg-ReY4R=S_thQ6tOzv2ZHV=xW5qBxpqs0iSjH_oFQ@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <9f9b8b86-6e49-17ef-e414-82e489b0b99a@gmail.com>
Date: Sat, 31 Oct 2020 09:31:48 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.3.1
MIME-Version: 1.0
In-Reply-To: <CAG48ez3qKg-ReY4R=S_thQ6tOzv2ZHV=xW5qBxpqs0iSjH_oFQ@mail.gmail.com>
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

On 10/30/20 8:14 PM, Jann Horn wrote:
> On Thu, Oct 29, 2020 at 3:19 PM Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>> On 10/29/20 2:42 AM, Jann Horn wrote:
>>> On Mon, Oct 26, 2020 at 10:55 AM Michael Kerrisk (man-pages)
>>> <mtk.manpages@gmail.com> wrote:
>>>>        static bool
>>>>        getTargetPathname(struct seccomp_notif *req, int notifyFd,
>>>>                          char *path, size_t len)
>>>>        {
>>>>            char procMemPath[PATH_MAX];
>>>>
>>>>            snprintf(procMemPath, sizeof(procMemPath), "/proc/%d/mem", req->pid);
>>>>
>>>>            int procMemFd = open(procMemPath, O_RDONLY);
>>>>            if (procMemFd == -1)
>>>>                errExit("\tS: open");
>>>>
>>>>            /* Check that the process whose info we are accessing is still alive.
>>>>               If the SECCOMP_IOCTL_NOTIF_ID_VALID operation (performed
>>>>               in checkNotificationIdIsValid()) succeeds, we know that the
>>>>               /proc/PID/mem file descriptor that we opened corresponds to the
>>>>               process for which we received a notification. If that process
>>>>               subsequently terminates, then read() on that file descriptor
>>>>               will return 0 (EOF). */
>>>>
>>>>            checkNotificationIdIsValid(notifyFd, req->id);
>>>>
>>>>            /* Read bytes at the location containing the pathname argument
>>>>               (i.e., the first argument) of the mkdir(2) call */
>>>>
>>>>            ssize_t nread = pread(procMemFd, path, len, req->data.args[0]);
>>>>            if (nread == -1)
>>>>                errExit("pread");
>>>
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
>>
>> Thanks very much for pointing me at this!
>>
>> So, I want to conform that the fix to the code is as simple as
>> adding a check following the pread() call, something like:
>>
>> [[
>>      ssize_t nread = pread(procMemFd, path, len, req->data.args[argNum]);
>>      if (nread == -1)
>>         errExit("Supervisor: pread");
>>
>>      if (nread == 0) {
>>         fprintf(stderr, "\tS: pread() of /proc/PID/mem "
>>                 "returned 0 (EOF)\n");
>>         exit(EXIT_FAILURE);
>>      }
>>
>>      if (close(procMemFd) == -1)
>>         errExit("Supervisor: close-/proc/PID/mem");
>>
>> +    /* Once again check that the notification ID is still valid. The
>> +       case we are particularly concerned about here is that just
>> +       before we fetched the pathname, the target's blocked system
>> +       call was interrupted by a signal handler, and after the handler
>> +       returned, the target carried on execution (past the interrupted
>> +       system call). In that case, we have no guarantees about what we
>> +       are reading, since the target's memory may have been arbitrarily
>> +       changed by subsequent operations. */
>> +
>> +    if (!notificationIdIsValid(notifyFd, req->id, "post-open"))
>> +        return false;
>> +
>>      /* We have no guarantees about what was in the memory of the target
>>         process. We therefore treat the buffer returned by pread() as
>>         untrusted input. The buffer should be terminated by a null byte;
>>         if not, then we will trigger an error for the target process. */
>>
>>      if (strnlen(path, nread) < nread)
>>          return true;
>> ]]
> 
> Yeah, that should do the job. 

Thanks.

> With the caveat that a cancelled syscall
> could've also led to the memory being munmap()ed, so the nread==0 case
> could also happen legitimately - so you might want to move this check
> up above the nread==0 (mm went away) and nread==-1 (mm still exists,
> but read from address failed, errno EIO) checks if the error message
> shouldn't appear spuriously.

In any case, I've been refactoring (simplifying) that code a little.
I haven't so far rearranged the order of the checks, but I already
log message for the nread==0 case. (Instead, there will eventually
be an error when the response is sent.)

I also haven't exactly tested the scenario you describe in the
seccomp unotify scenario, but I think the above is not correct. Here 
are two scenarios I did test, simply with mmap() and /proc/PID/mem
(no seccomp involved): 

Scenario 1:
A creates a mapping at address X
B opens /proc/A/mem and and lseeks on resulting FD to offset X
A terminates
B reads from FD ==> read() returns 0 (EOF)

Scenario 2:
A creates a mapping at address X
B opens /proc/A/mem and and lseeks on resulting FD to offset X
A unmaps mapping at address X
B reads from FD ==> read() returns -1 / EIO.

That last scenario seems to contradict what you say, since I
think you meant that in this case read() should return 0 in
that case. Have I misunderstood you?

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
