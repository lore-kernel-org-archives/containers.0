Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.8 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,NICE_REPLY_A,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B36BCC00A89
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 19:45:24 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DB05A20731
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 19:45:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Xcu4Fuh7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB05A20731
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 4D59A86E9F;
	Mon,  2 Nov 2020 19:45:23 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id InVH8oq_zw9s; Mon,  2 Nov 2020 19:45:22 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 20B4A86E14;
	Mon,  2 Nov 2020 19:45:22 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 04947C0889;
	Mon,  2 Nov 2020 19:45:22 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 72EDAC0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 19:45:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 6111C87318
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 19:45:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id FjEmTOml5oY8
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 19:45:19 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-wr1-f65.google.com (mail-wr1-f65.google.com
 [209.85.221.65])
 by hemlock.osuosl.org (Postfix) with ESMTPS id C7419872FC
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 19:45:18 +0000 (UTC)
Received: by mail-wr1-f65.google.com with SMTP id w1so16014759wrm.4
 for <containers@lists.linux-foundation.org>;
 Mon, 02 Nov 2020 11:45:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=cc:subject:to:references:from:message-id:date:user-agent
 :mime-version:in-reply-to:content-language:content-transfer-encoding;
 bh=laqvXkYmnuGd0xSBrvapYqlT+lDWdfEk/TVZWHBUFak=;
 b=Xcu4Fuh7ucz0IyN2Q9r9gVmHTHMRgAt6J3EL40r2hOn8GHpIYVL4F9QyxLZjQjaHKD
 Q23alGe3vdzXDX/NYsmYEGuz0HSN0mD5zpT6OG2cZmZB/2A8rlOp/u5dnPC8jb0L/Zlb
 jQpmd4aLHJM5p1sDQ6+hoS4A8xICctQtmdgp3wMstwZA7wqQvL3nJgQG//zv5ctFG/1U
 75/w69lxjXWSyHtPfNNmL5zudSct3ItMfx6+b01qJhKjAKBWl5o4oqgQQAdl8dDCMltf
 5jHGvTX1xOK8prO/vWr0PsbKEhppDUxNe4DCHwv97Zsyy3tDVIy5yycC1Ep5TCbdOPu2
 mytw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:cc:subject:to:references:from:message-id:date
 :user-agent:mime-version:in-reply-to:content-language
 :content-transfer-encoding;
 bh=laqvXkYmnuGd0xSBrvapYqlT+lDWdfEk/TVZWHBUFak=;
 b=QCWNOwe8n3V0jVt7lDx0/0tWtq2i2/9zAdlkLwpUFklyVlzI6jMcj7uzf+ORaBlcId
 IMAEb8zT/ga/f3uL90iWEQkmSNG3osSNJZ/1xW4KXxC0nOQ8ifYy05MIlXVtq2ULgBuC
 5DTV5otlXEYQdlJSeft1W/tVCwyjSdmLRvP7qb8+B77YjE6HoNwh8bj/zr5D+8e2NKSn
 eqX6gT/DjjSBMmaqO6nGyH6VdFV1M0K97u5SHPymd7iq4fmkD28Ut68a8c9VI+NtcD2n
 Mhs2ilPmeRM8mxqh1rKYfQbLday6/C7pO2xjPOYRFK0Nk2CHBfnp3IEYLhH+NyW0etbg
 oo7Q==
X-Gm-Message-State: AOAM533sROsXt55qQo4fCno85/HY/UJO0JLWFU7FobG0dhUP3Yn6PHMI
 9B4yk/ZL6UHS28la0ek2JpY=
X-Google-Smtp-Source: ABdhPJz8m94F40PYPDleJPuNVjP3xxDbSlJfSVCYuiHmiaTZX/Dk9in69mChxicVhbXQrTId1ocsGg==
X-Received: by 2002:a5d:4f07:: with SMTP id c7mr23106131wru.296.1604346317099; 
 Mon, 02 Nov 2020 11:45:17 -0800 (PST)
Received: from ?IPv6:2001:a61:245a:d801:2e74:88ad:ef9:5218?
 ([2001:a61:245a:d801:2e74:88ad:ef9:5218])
 by smtp.gmail.com with ESMTPSA id l11sm21642720wro.89.2020.11.02.11.45.15
 (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
 Mon, 02 Nov 2020 11:45:15 -0800 (PST)
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
To: Sargun Dhillon <sargun@sargun.me>
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <20201029085312.GC29881@ircssh-2.c.rugged-nimbus-611.internal>
 <48e5937b-80f5-c48b-1c67-e8c9db263ca5@gmail.com>
 <20201030202720.GA4088@ircssh-2.c.rugged-nimbus-611.internal>
 <606199d6-b48c-fee2-6e79-1e52bd7f429f@gmail.com>
 <CAMp4zn9AaQ46EyG6QFrF33efpUHnK_TyMYkTicr=iwY5hcKrBg@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <964c2191-db78-ff4d-5664-1d80dc382df4@gmail.com>
Date: Mon, 2 Nov 2020 20:45:14 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.3.1
MIME-Version: 1.0
In-Reply-To: <CAMp4zn9AaQ46EyG6QFrF33efpUHnK_TyMYkTicr=iwY5hcKrBg@mail.gmail.com>
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

Thanks for your reply!

On 11/2/20 9:07 AM, Sargun Dhillon wrote:
> On Sat, Oct 31, 2020 at 9:27 AM Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>>
>> Hello Sargun,
>>
>> Thanks for your reply.
>>
>> On 10/30/20 9:27 PM, Sargun Dhillon wrote:
>>> On Thu, Oct 29, 2020 at 09:37:21PM +0100, Michael Kerrisk (man-pages)
>>> wrote:
>>
>> [...]
>>
>>>>> I think I commented in another thread somewhere that the
>>>>> supervisor is not notified if the syscall is preempted. Therefore
>>>>> if it is performing a preemptible, long-running syscall, you need
>>>>> to poll SECCOMP_IOCTL_NOTIF_ID_VALID in the background, otherwise
>>>>> you can end up in a bad situation -- like leaking resources, or
>>>>> holding on to file descriptors after the program under
>>>>> supervision has intended to release them.
>>>>
>>>> It's been a long day, and I'm not sure I reallu understand this.
>>>> Could you outline the scnario in more detail?
>>>>
>>> S: Sets up filter + interception for accept T: socket(AF_INET,
>>> SOCK_STREAM, 0) = 7 T: bind(7, {127.0.0.1, 4444}, ..) T: listen(7,
>>> 10) T: pidfd_getfd(T, 7) = 7 # For the sake of discussion.
>>
>> Presumably, the preceding line should have been:
>>
>> S: pidfd_getfd(T, 7) = 7 # For the sake of discussion.
>> (s/T:/S:/)
>>
>> right?
> 
> Right.
>>
>>
>>> T: accept(7, ...) S: Intercepts accept S: Does accept in background
>>> T: Receives signal, and accept(...) responds in EINTR T: close(7) S:
>>> Still running accept(7, ....), holding port 4444, so if now T
>>> retries to bind to port 4444, things fail.
>>
>> Okay -- I understand. Presumably the solution here is not to
>> block in accept(), but rather to use poll() to monitor both the
>> notification FD and the listening socket FD?
>>
> You need to have some kind of mechanism to periodically check
> if the notification is still alive, and preempt the accept. It doesn't
> matter how exactly you "background" the accept (threads, or
> O_NONBLOCK + epoll).
> 
> The thing is you need to make sure that when the process
> cancels a syscall, you need to release the resources you
> may have acquired on its behalf or bad things can happen.
> 

Got it. I added the following text:

   Caveats regarding blocking system calls
       Suppose that the target performs a blocking system call (e.g.,
       accept(2)) that the supervisor should handle.  The supervisor
       might then in turn execute the same blocking system call.

       In this scenario, it is important to note that if the target's
       system call is now interrupted by a signal, the supervisor is not
       informed of this.  If the supervisor does not take suitable steps
       to actively discover that the target's system call has been
       canceled, various difficulties can occur.  Taking the example of
       accept(2), the supervisor might remain blocked in its accept(2)
       holding a port number that the target (which, after the
       interruption by the signal handler, perhaps closed  its listening
       socket) might expect to be able to reuse in a bind(2) call.

       Therefore, when the supervisor wishes to emulate a blocking system
       call, it must do so in such a way that it gets informed if the
       target's system call is interrupted by a signal handler.  For
       example, if the supervisor itself executes the same blocking
       system call, then it could employ a separate thread that uses the
       SECCOMP_IOCTL_NOTIF_ID_VALID operation to check if the target is
       still blocked in its system call.  Alternatively, in the accept(2)
       example, the supervisor might use poll(2) to monitor both the
       notification file descriptor (so as as to discover when the
       target's accept(2) call has been interrupted) and the listening
       file descriptor (so as to know when a connection is available).

       If the target's system call is interrupted, the supervisor must
       take care to release resources (e.g., file descriptors) that it
       acquired on behalf of the target.

Does that seem okay?

>>>>> ENOENT The cookie number is not valid. This can happen if a
>>>>> response has already been sent, or if the syscall was
>>>>> interrupted
>>>>>
>>>>> EBADF If the file descriptor specified in srcfd is invalid, or if
>>>>> the fd is out of range of the destination program.
>>>>
>>>> The piece "or if the fd is out of range of the destination program"
>>>> is not clear to me. Can you say some more please.
>>>>
>>>
>>> IIRC the maximum fd range is specific in proc by some sysctl named
>>> nr_open. It's also evaluated against RLIMITs, and nr_max.
>>>
>>> If nr-open (maximum fds open per process, iiirc) is 1000, even if 10
>>> FDs are open, it wont work if newfd is 1001.
>>
>> Actually, the relevant limit seems to be just the RLIMIT_NOFILE
>> resource limit at least in my reading of fs/file.c::replace_fd().
>> So I made the text
>>
>>               EBADF  Allocating the file descriptor in the target would
>>                      cause the target's RLIMIT_NOFILE limit to be
>>                      exceeded (see getrlimit(2)).
>>
>>
> 
> If you're above RLIMIT_NOFILE, you get EBADF.
> 
> When we do __receive_fd with a specific fd (newfd specified):
> https://elixir.bootlin.com/linux/latest/source/fs/file.c#L1086
> 
> it calls replace_fd, which calls expand_files. expand_files
> can fail with EMFILE.
> 
>>>>> EINVAL If flags or new_flags were unrecognized, or if newfd is
>>>>> non-zero, and SECCOMP_ADDFD_FLAG_SETFD has not been set.
>>>>>
>>>>> EMFILE Too many files are open by the destination process.
>>
>> I'm not sure that the error can really occur. That's the error
>> that in most other places occurs when RLIMIT_NOFILE is exceeded.
>> But I may have missed something. More precisely, when do you think
>> EMFILE can occur?
>>
> It can happen if the user specifies a newfd which is too large.

Got it. Thanks! I made the error text:

        EMFILE The file descriptor number specified in newfd  exceeds  the
              limit specified in /proc/sys/fs/nr_open.

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
