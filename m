Return-Path: <SRS0=ql3H=ED=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4F0CC4363A
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 22:53:10 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3DB4220732
	for <containers@archiver.kernel.org>; Wed, 28 Oct 2020 22:53:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="bBaojgDC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DB4220732
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 8B3F787362;
	Wed, 28 Oct 2020 22:53:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id uhco5iB87wIh; Wed, 28 Oct 2020 22:53:09 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id F012E87289;
	Wed, 28 Oct 2020 22:53:08 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D5BD2C088B;
	Wed, 28 Oct 2020 22:53:08 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 9EB17C0051
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 22:53:07 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 850D2860B2
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 22:53:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id SPQWnjXpGAuo
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 22:53:07 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pg1-f175.google.com (mail-pg1-f175.google.com
 [209.85.215.175])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 0E2168600D
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 22:53:07 +0000 (UTC)
Received: by mail-pg1-f175.google.com with SMTP id h6so740845pgk.4
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 15:53:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=0Xy/2zadYFsZw40LFEtdOiEBtCWDHEhIZKqPxiXGDgo=;
 b=bBaojgDCytTeCZe09Aniv5ZCo9/1FqsTT/3OVeHNHiQoo0VRsUJwEEF+dAKR8keSyL
 yRWbSBM9isY011JSCr6qCTcRwh2CYocjn/3k5iQI8Ss/5A/CGKTOriZdbyXDN2ys6BHT
 tIbkFOOYefNeoQ0CJz/hUYR7ERPfwa7Bx6B6I=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=0Xy/2zadYFsZw40LFEtdOiEBtCWDHEhIZKqPxiXGDgo=;
 b=lyNHwfMKnBQyy3DbOgdaHlmHdcMVZH9PrBImdlCreFEjm+bBbSYH/yeKFoqsUYZK9W
 OVIoGupnklzT9ja2jYLt2fytYhJnmcTarl7LKTcLJDfvCaRIVlgarqhS87oek55P1F+t
 NySBzdaChyaX+MwmoPZ25EH95dSiTmTZ0WTesXIKG9E3qF2ffAuT5VTZwRj+akReioFH
 bv7qptNJF19qXIY6UuEcPlLA24C9kUG2r3MPFL3hbVZFc98N6hUuBqaBtohjflWlM02U
 eOoO3E8GBVZVqLqtU+J8C1aPtm43M4DeAR/z4p66n7jCJlNt7eQlvI5zpFmVs9hlSmiY
 BaWA==
X-Gm-Message-State: AOAM532Bb3Ff24/Un1hWYwo5rL+3akiPXu3Hb3RmXMwtER7xLe4y9Ciw
 4hbgmkZp06vIS86EwCE8TS2jqQ==
X-Google-Smtp-Source: ABdhPJzNUPngBSBllGfVxFqpThpHmKtVDwZBWHpI1tUv5u0YsP97zuSXYttLoLqCl2FU2MQmSaZy8A==
X-Received: by 2002:a17:90b:90d:: with SMTP id
 bo13mr1086316pjb.111.1603925586677; 
 Wed, 28 Oct 2020 15:53:06 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id l7sm465074pja.11.2020.10.28.15.53.05
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 28 Oct 2020 15:53:05 -0700 (PDT)
Date: Wed, 28 Oct 2020 15:53:04 -0700
From: Kees Cook <keescook@chromium.org>
To: Jann Horn <jannh@google.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
Message-ID: <202010281548.CCA92731F@keescook>
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
 <CAG48ez1VOUEHVQyo-2+uO7J+-jN5rh7=KmrMJiPaFjwCbKR1Sg@mail.gmail.com>
 <20200930232456.GB1260245@cisco>
 <CAG48ez2xn+_KznEztJ-eVTsTzkbf9CVgPqaAk7TpRNAqbdaRoA@mail.gmail.com>
 <202010251725.2BD96926E3@keescook>
 <CAG48ez2b-fnsp8YAR=H5uRMT4bBTid_hyU4m6KavHxDko1Efog@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAG48ez2b-fnsp8YAR=H5uRMT4bBTid_hyU4m6KavHxDko1Efog@mail.gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Robert Sesek <rsesek@google.com>,
 Daniel Borkmann <daniel@iogearbox.net>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 lkml <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>,
 "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>,
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

On Mon, Oct 26, 2020 at 10:51:02AM +0100, Jann Horn wrote:
> The problem is the scenario where a process is interrupted while it's
> waiting for the supervisor to reply.
> 
> Consider the following scenario (with supervisor "S" and target "T"; S
> wants to wait for events on two file descriptors seccomp_fd and
> other_fd):
> 
> S: starts poll() to wait for events on seccomp_fd and other_fd
> T: performs a syscall that's filtered with RET_USER_NOTIF
> S: poll() returns and signals readiness of seccomp_fd
> T: receives signal SIGUSR1
> T: syscall aborts, enters signal handler
> T: signal handler blocks on unfiltered syscall (e.g. write())
> S: starts SECCOMP_IOCTL_NOTIF_RECV
> S: blocks because no syscalls are pending

Oooh, yes, ew. Thanks for the illustration.

Thinking about this from userspace's least-surprise view, I would expect
the "recv" to stay "queued", in the sense we'd see this:

S: starts poll() to wait for events on seccomp_fd and other_fd
T: performs a syscall that's filtered with RET_USER_NOTIF
S: poll() returns and signals readiness of seccomp_fd
T: receives signal SIGUSR1
T: syscall aborts, enters signal handler
T: signal handler blocks on unfiltered syscall (e.g. write())
S: starts SECCOMP_IOCTL_NOTIF_RECV
S: gets (stale) seccomp_notif from seccomp_fd
S: sends seccomp_notif_resp, receives ENOENT (or some better errno?)

This is not at all how things are designed internally right now, but
that behavior would work, yes?

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
