Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEFDDC4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 04:26:40 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 017E120790
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 04:26:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="vCF7BqYv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 017E120790
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 67D1D86AC1;
	Thu, 29 Oct 2020 04:26:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KFOugl5Gtb8R; Thu, 29 Oct 2020 04:26:38 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 0FBFE86AB7;
	Thu, 29 Oct 2020 04:26:38 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 000F6C088B;
	Thu, 29 Oct 2020 04:26:37 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C3FA8C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 04:26:36 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 2223C2151E
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 04:26:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id vRepbh1qF7i4
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 04:26:35 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f51.google.com (mail-lf1-f51.google.com
 [209.85.167.51])
 by silver.osuosl.org (Postfix) with ESMTPS id 049BC20011
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 04:26:34 +0000 (UTC)
Received: by mail-lf1-f51.google.com with SMTP id b1so1570458lfp.11
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Oct 2020 21:26:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=5bZHSqby9xc03fv8b/uQtgTC0sysq05Jdo5tS6hC7Bk=;
 b=vCF7BqYvpPENaZQ1ij18cOuBn3mjiDl59S9e8pNu4I8MoMuZo8/ftg0Y9yOuESZN09
 VBw04wGTblOlqn6/d//nxST8d02fERV2k+Yqvoj5KIf/bU8IslsX99d6mIRXJv1H9eZ7
 dPdYqdkXenA5Mtf/Ci6Vn4NPk9RQpMYT+WOlqRhTU68ApcUfhfJDbQ4ydF1Vj8SKnJb5
 kYkD7iFe2dzDG5UlFj7yPh8AaapCSTfLe8HSbb08Qh60EKjEcTHQBTCNu6MPXVwS2U+e
 ddO/4+yG92LPOzOsogodfabgmFl0yPhga3RhQIlJ6Ulkl1MZebH5vSSbg1KnGyrTMNXW
 E67w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=5bZHSqby9xc03fv8b/uQtgTC0sysq05Jdo5tS6hC7Bk=;
 b=f7O92KbDZyJpGi6ZrXb48FqgcMT8oIMUPvLuj6nL/50xPjKhb1NO7qpxX6oG+Aa9WD
 mKhmhElrGCKLDcHl1B2Mca2wv8COLVevt+f69bU8Q9LVwRCcjeMmJUqG3DHW5iS1ylyu
 Mc7P7IhX3Yji/Ban2f0plbrmHqzzrx0xGMfCZ6D7ZIo6slgkTCQCUj/RcdX+UuW3S4bN
 b7owJ/7YO089tNPJYEfeIPZIKbhScZVWMrz3ULRAQcYvgWxmw3/kUVhGhnjLBJf1Qlrx
 rK9TLdpV+eKApMLjK8ijU38J7/vKxoVteF7cKGm7Fl9mw1q9Ux+5ODijDLX/xhOhS1gM
 nYQA==
X-Gm-Message-State: AOAM531CwlD2M8RsNqe//iZgiDhRACdyrDKJ0q1PvnPQaOze0ApdOis4
 YGTH8gW7hnT2QdrEEEjOLw83lMcoRACOAFZlP2W+iA==
X-Google-Smtp-Source: ABdhPJzKHFLrtcctmkuqmI3RamhnK2a1wmI/Y3U/6ijUcRKMrl5Xg1LaPRSJKCqbjtr8CcoK5kQQWSIr/nf0z+LrQ9A=
X-Received: by 2002:a19:c357:: with SMTP id t84mr773624lff.34.1603945592793;
 Wed, 28 Oct 2020 21:26:32 -0700 (PDT)
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
 <20201029021348.GB25673@cisco>
In-Reply-To: <20201029021348.GB25673@cisco>
Date: Thu, 29 Oct 2020 05:26:05 +0100
Message-ID: <CAG48ez2=8RBh_2D=WRKta4n3jvfTpD90j8DA-uOFAm86fKjSzw@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page
To: Tycho Andersen <tycho@tycho.pizza>
Cc: linux-man <linux-man@vger.kernel.org>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>,
 Giuseppe Scrivano <gscrivan@redhat.com>, Robert Sesek <rsesek@google.com>,
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

On Thu, Oct 29, 2020 at 3:13 AM Tycho Andersen <tycho@tycho.pizza> wrote:
> > > Consider the following scenario (with supervisor "S" and target "T"; S
> > > wants to wait for events on two file descriptors seccomp_fd and
> > > other_fd):
> > >
> > > S: starts poll() to wait for events on seccomp_fd and other_fd
> > > T: performs a syscall that's filtered with RET_USER_NOTIF
> > > S: poll() returns and signals readiness of seccomp_fd
> > > T: receives signal SIGUSR1
> > > T: syscall aborts, enters signal handler
> > > T: signal handler blocks on unfiltered syscall (e.g. write())
> > > S: starts SECCOMP_IOCTL_NOTIF_RECV
> > > S: blocks because no syscalls are pending
> > >
> > > Depending on what other_fd is, this could in a worst case even lead to
> > > a deadlock (if e.g. the signal handler wants to write to stdout, but
> > > the stdout fd is hooked up to other_fd in the supervisor, but the
> > > supervisor can't consume the data written because it's stuck in
> > > seccomp handling).
> > >
> > > So we have to ensure that when existing code (like that crun code you
> > > linked to) triggers this case, SECCOMP_IOCTL_NOTIF_RECV returns
> > > immediately instead of blocking.
> >
> > Or I guess we could also just set O_NONBLOCK on the fd by default?
> > Since the one existing user is eventloop-based...
>
> I feel like it's ok to return an error from the RECV ioctl() if
> there's never going to be any more events on the fd; was there
> something fundamentally wrong with your patch here:
> https://lore.kernel.org/bpf/CAG48ez2xn+_KznEztJ-eVTsTzkbf9CVgPqaAk7TpRNAqbdaRoA@mail.gmail.com/
> ?

No, I have a new version of that about 80% done and hope to send it
out soonish. (There's some stuff around tests that I still need to
cobble together).
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
