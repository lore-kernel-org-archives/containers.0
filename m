Return-Path: <SRS0=O+XM=JK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A55F6C433B4
	for <containers@archiver.kernel.org>; Tue, 13 Apr 2021 16:02:48 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 43CDB6113E
	for <containers@archiver.kernel.org>; Tue, 13 Apr 2021 16:02:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43CDB6113E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kinvolk.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp4.osuosl.org (Postfix) with ESMTP id 08D9440535;
	Tue, 13 Apr 2021 16:02:48 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
	by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id y0r-RqKu3O2o; Tue, 13 Apr 2021 16:02:46 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp4.osuosl.org (Postfix) with ESMTP id DE2D440519;
	Tue, 13 Apr 2021 16:02:45 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9D081C000B;
	Tue, 13 Apr 2021 16:02:45 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 6AC6BC000A
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 16:02:44 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 500FF4015D
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 16:02:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp2.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=kinvolk.io
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id WXO2pUKA8zWA
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 16:02:42 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-ed1-x52d.google.com (mail-ed1-x52d.google.com
 [IPv6:2a00:1450:4864:20::52d])
 by smtp2.osuosl.org (Postfix) with ESMTPS id 6A78340117
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 16:02:42 +0000 (UTC)
Received: by mail-ed1-x52d.google.com with SMTP id ba6so20029705edb.1
 for <containers@lists.linux-foundation.org>;
 Tue, 13 Apr 2021 09:02:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kinvolk.io; s=google;
 h=from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=MQXso/p7dQH9LxNX2FtlDtx7UZcy3CyevPkVQcW7NTY=;
 b=BCRSpiiRGXMfq3IM+ymGVZceX3iV7LKj1QO880OajNpEarYdi7UDRKRhkzpBmktmUY
 +rdSbi2FJ1GUxCxR2lfMFDNDTc3NqCgqovMfD8gP7TfWqc4rZYX+AD5sluVhFxWh2fy/
 x2jIzEdp1gLPwOlrSWi2WDVor3G6OMCnhsBow=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
 :content-transfer-encoding;
 bh=MQXso/p7dQH9LxNX2FtlDtx7UZcy3CyevPkVQcW7NTY=;
 b=pI4yIWp+kBJjL398gZK3IisdAuuddWNOllpFtgnYsqdxb+hZVdLBG7RUgz49/OUcQj
 ZwKcFBiAku4Q1kMZ8b7rnkHC+uKf92nQpm5gj1KOQmeANPszx4EAtb7jqVaN2+4QK9+q
 bdE4OmHbSWb7+ns3TNptS5CZ39BUavOWjDljBLUU6VBsqYNbq0JVCEM7AJGaFFeIFnYr
 2nEffmarjBprr8zY4GslprWOkSurwbV1jzf2POG1UaXOd1mR/W1uFhFK6NIoG79IRnZk
 N8gpI50wOI1DytxLqzbb/od6VeP7G9T4r12Ix49cCg4GQfKuF1cPj0bb0NrH3FkQlvHJ
 QIww==
X-Gm-Message-State: AOAM532OfTB5WxjwejMYoU/NC9J8dV6UTYPy4b0sefzSebg/3UuvuEB+
 sdYr9wLk7LTNxOJ+T2TN9QD8xA==
X-Google-Smtp-Source: ABdhPJwRoGjbckoXCLP7mhFP1t9lFmFkJ/iC5xwcq9r/6hH3ykhAY6B76oQyIkxLwjJiBAG5cfRkNA==
X-Received: by 2002:a05:6402:1284:: with SMTP id
 w4mr35216250edv.181.1618329760637; 
 Tue, 13 Apr 2021 09:02:40 -0700 (PDT)
Received: from localhost.localdomain
 ([2a02:8109:9880:57f0:ba7c:cdd5:fff7:623c])
 by smtp.gmail.com with ESMTPSA id gb4sm8162852ejc.122.2021.04.13.09.02.39
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Tue, 13 Apr 2021 09:02:40 -0700 (PDT)
From: Rodrigo Campos <rodrigo@kinvolk.io>
To: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>,
 Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
 containers@lists.linux-foundation.org
Subject: [PATCH 0/1] seccomp: Erroneous return on interrupted addfd ioctl()
Date: Tue, 13 Apr 2021 18:01:50 +0200
Message-Id: <20210413160151.3301-1-rodrigo@kinvolk.io>
X-Mailer: git-send-email 2.30.2
MIME-Version: 1.0
Cc: Alban Crequy <alban@kinvolk.io>
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

Hi!

With Alban and Mauricio (on Cc), we are adding seccomp userspace notify support
to runc and found a kernel bug while testing it. The issue is the following: if
the addfd ioctl() in the seccomp agent is interrupted (like with SIGURG) then
the target process is erroneously and prematurely unblocked and a 0 is returned
to the target process.

This happens on all kernels that support addfd (>= v5.9). The problem is the
following, things should happen in this specific order to hit the bug.

The agent is written in go, so the runtime sends SIGURG quite often. If we are
interrupted when the addfd ioctl is in this wait[1]:
        ret = wait_for_completion_interruptible(&kaddfd.completion);

Then the "complete(&knotif->ready);" was just run. So, we proceed to take the
lock and delete the addfd element from the list[2]. The kaddfd.list is empty
now.

After that, the other side (the target process) will be woken up (because we
issued the "complete(&knotif->ready)") and take the lock, but the "if" to add
the fd will be false as the element is already deleted (the list is empty)[3].

Then, we don't execute the "goto wait" and we proceed to return to the other
side values set in n, that is 0 initialized. So, the other side sees 0 as a
response (error is 0 and val is 0).

The target process, then, sees a response even when we didn't answer the
notification, we just tried to add an fd.

I attach the strace output when hitting the bug. The target is issuing openat in
a loop, for "/dev/null-%d" with %d being the iteration we are at. The strace
shows that openat returned 0 for the iteration 27246.

The agent in go checks the notification is valid (SECCOMP_IOCTL_NOTIF_ID_VALID)
and then runs the addfd ioctl, that is interrupted by the go runtime. Then, it
is resumed and returns ENOENT. This makes sense, as the notification was already
responded (incorrectly) by the interrupted addfd ioctl, so when we run it again
now the notification doesn't exist.

There are two ways that come to mind to solve this problem. One is the patch in
the next email (tested, fixes the issue). The other one is the first patch in
the joint patchset that we sent with Sargun some days ago ("seccomp: Refactor
notification handler to prepare for new semantics")[4]. That patch alone also
fixes the issue.

Both patches are quite simple, although the one attached here doesn't change
semantics and the other ("seccomp: Refactor notification handler to prepare for
new semantics") does.

The patch that we apply should be cc stable too. This patch is based on
for-linus/seccomp, affect 5.9+ kernels and applies cleany to 5.10.y, 5.11.y and
current 5.12 (probably to others too, this part hasn't changed recently).

Rodrigo Campos (1):
  seccomp: Always "goto wait" if the list is empty

 kernel/seccomp.c | 20 +++++++++++++++-----
 1 file changed, 15 insertions(+), 5 deletions(-)


[1]: https://github.com/torvalds/linux/blob/89698becf06d341a700913c3d89ce2a914af69a2/kernel/seccomp.c#L1615
[2]: https://github.com/torvalds/linux/blob/89698becf06d341a700913c3d89ce2a914af69a2/kernel/seccomp.c#L1628-L1639 
[3]: https://github.com/torvalds/linux/blob/89698becf06d341a700913c3d89ce2a914af69a2/kernel/seccomp.c#L1113 
[4]: https://lore.kernel.org/lkml/20210318051733.2544-2-sargun@sargun.me/ 

Strace on the target:
...
[pid  3211] openat(-1, "/dev/null-27246", O_RDONLY) = 0

Strace on the agent (golang):
...
[pid  3214] pread64(10, "/dev/null-27246\0001\371\1Ag\177\0\0\0\0\0\0\1\0\0\0"..., 4096, 140724461935344) = 4096
[pid  3214] close(10)                   = 0
[pid  3214] ioctl(4, SECCOMP_IOCTL_NOTIF_ID_VALID, 0x7f7a1a7fbdc8) = 0
[pid  3214] write(2, "\33[37mDEBU\33[0m[0091] doing replac"..., 66 <unfinished ...>
[pid  3141] <... nanosleep resumed>NULL) = 0
[pid  3214] <... write resumed>)        = 66
[pid  3141] getpid( <unfinished ...>
[pid  3214] write(1, "using notify_fd: 4, srcfd: 8\n", 29 <unfinished ...>
[pid  3141] <... getpid resumed>)       = 3140
[pid  3214] <... write resumed>)        = 29
[pid  3141] tgkill(3140, 3214, SIGURG <unfinished ...>
[pid  3214] ioctl(4, SECCOMP_IOCTL_NOTIF_ADDFD <unfinished ...>
[pid  3141] <... tgkill resumed>)       = 0
[pid  3214] <... ioctl resumed>, 0x7f7a1a7fbde0) = ? ERESTARTSYS (To be restarted if SA_RESTART is set)
[pid  3141] nanosleep({tv_sec=0, tv_nsec=20000},  <unfinished ...>
[pid  3214] --- SIGURG {si_signo=SIGURG, si_code=SI_TKILL, si_pid=3140, si_uid=0} ---
[pid  3214] rt_sigreturn({mask=[]})     = 16
[pid  3214] ioctl(4, SECCOMP_IOCTL_NOTIF_ADDFD, 0x7f7a1a7fbde0) = -1 ENOENT (No such file or directory)

-- 
2.30.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
