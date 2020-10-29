Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE6B6C4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 01:12:14 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 366C920725
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 01:12:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="vciGCxCg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 366C920725
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id B644686130;
	Thu, 29 Oct 2020 01:12:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8hFef-agLHNc; Thu, 29 Oct 2020 01:12:11 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 0080686499;
	Thu, 29 Oct 2020 01:12:11 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E33C1C0859;
	Thu, 29 Oct 2020 01:12:10 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4DD77C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 01:12:10 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 47C7487371
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 01:12:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id sSq1zfGXPyFh
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 01:12:09 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f50.google.com (mail-lf1-f50.google.com
 [209.85.167.50])
 by hemlock.osuosl.org (Postfix) with ESMTPS id AE4CD8736F
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 01:12:08 +0000 (UTC)
Received: by mail-lf1-f50.google.com with SMTP id i6so1238609lfd.1
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 18:12:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=2+uYu86LDWGsnC4W37LGE2qpMcN2MpffcV3JWIw2MFQ=;
 b=vciGCxCgV8AP2QARHScqr2zKoGS/+nJtrToSziCQ8d8h1NRdDiev7b4FY2OwCqgP1d
 pQbxRv3nm4M5jbQFhB27QEFUsCLY1i6eh1m09u0GR/aIZBCnQqfxLzxjTF3jSSNq63Ix
 7tc/61a9Eg7G4x1Q2ubkcaETyM84zF0DBSoX0Z35kXIp9RaUo5oEwdbRcGo1NCv5ThrS
 xv91Ll0nIZQR9E4a8eCFWpzRS93StI1OfrXVYHm3aQtiSQCjRfQnJM7yFQeATQ7e3KqK
 nI1O4QIZNutVL1kAoz9zNnzUTHY2AP0CtWCW2iHkQa6Wv2OlTNpHsTkIDscq6Ww8Qb6w
 b/Cw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=2+uYu86LDWGsnC4W37LGE2qpMcN2MpffcV3JWIw2MFQ=;
 b=LUIGTbPcS1Xby1fpcSO2zg9nyf2x+CA5VILQTlyVyzzw3kYURVW5J6KF2zlkHo0Xnd
 VbWb46dzny5/b83D8VjrWlr1fHW8usftgfDb5qCNIqqCiaq7CCbnXfISmV7sNIbYKhMy
 qbeHrT6NvWgZ4gg8mMOYMLDixHs/3WLPhlLPysfjl9YKs4FVxh31hdyWUc/x5AxjlJzX
 eRwV499aeUDcQMCT7Ul0dzSeH7uCt/5agfwkf2oj/avFVC00TN5f0hh9PcXVa8zWeG4x
 QLoYs3A6Si9mQVdHVgByR0UDn5Cnut+J1XNc8Acyyq5ZWRkOR633gg/a5yH9HSB4L4kj
 ZWfw==
X-Gm-Message-State: AOAM533IHa1RhjACfS07a2j0zAyuFb3p8qwuvhHFFBfc689sD/bW56L/
 IwxzGJBjRWHcvY8bBIb92fBwRdFN6FxX2FAZf9N4nA==
X-Google-Smtp-Source: ABdhPJzzc/J1JBJXAToRCeQHDdOVsoNE6U9yTJzDUPWdlDCEb1Uk4v5ySj0pBCeZjS4xxD+zSOrd96XH4omhzWIDEkE=
X-Received: by 2002:a19:83c1:: with SMTP id f184mr559337lfd.97.1603933926604; 
 Wed, 28 Oct 2020 18:12:06 -0700 (PDT)
MIME-Version: 1.0
References: <45f07f17-18b6-d187-0914-6f341fe90857@gmail.com>
 <20200930150330.GC284424@cisco>
 <8bcd956f-58d2-d2f0-ca7c-0a30f3fcd5b8@gmail.com>
 <20200930230327.GA1260245@cisco>
 <CAG48ez1VOUEHVQyo-2+uO7J+-jN5rh7=KmrMJiPaFjwCbKR1Sg@mail.gmail.com>
 <20200930232456.GB1260245@cisco>
 <CAG48ez2xn+_KznEztJ-eVTsTzkbf9CVgPqaAk7TpRNAqbdaRoA@mail.gmail.com>
 <202010251725.2BD96926E3@keescook>
 <CAG48ez2b-fnsp8YAR=H5uRMT4bBTid_hyU4m6KavHxDko1Efog@mail.gmail.com>
 <CAG48ez2OWhpH3HHUJSrAmokJ8=SVwKrmQMSw0gEbTJmKE4myCw@mail.gmail.com>
 <202010281553.A72E162A7@keescook>
In-Reply-To: <202010281553.A72E162A7@keescook>
Date: Thu, 29 Oct 2020 02:11:39 +0100
Message-ID: <CAG48ez0FS49ki=RfO_nrSnwH32g9oRS73OSUOhz6tVh+YwCNLg@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
To: Kees Cook <keescook@chromium.org>
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
From: Jann Horn via Containers <containers@lists.linux-foundation.org>
Reply-To: Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Wed, Oct 28, 2020 at 11:56 PM Kees Cook <keescook@chromium.org> wrote:
> On Mon, Oct 26, 2020 at 11:31:01AM +0100, Jann Horn wrote:
> > Or I guess we could also just set O_NONBLOCK on the fd by default?
> > Since the one existing user is eventloop-based...
>
> I thought about that initially, but it rubs me the wrong way: it
> violates least-surprise for me. File descriptors are expected to be
> default-blocking. It *is* a special fd, though, so maybe it could work.
> The only case I can think of it would break would be ioctl-loop case
> that is already buggy in that it didn't handle non-zero returns?

We don't have any actual users that use the API that way outside of
the kernel's selftest/sample code, right?
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
