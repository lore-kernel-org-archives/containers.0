Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A700C2D0A3
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 20:04:55 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D16BA20870
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 20:04:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=google.com header.i=@google.com header.b="IenDEOwc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D16BA20870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 7EB3387271;
	Mon,  2 Nov 2020 20:04:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id o7WZBEQfhW4p; Mon,  2 Nov 2020 20:04:53 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 53395871B3;
	Mon,  2 Nov 2020 20:04:53 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 342FAC0889;
	Mon,  2 Nov 2020 20:04:53 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id CCCBCC0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:04:51 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id BAF6F87271
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:04:51 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id CNuN-R+Cff56
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:04:51 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-lf1-f43.google.com (mail-lf1-f43.google.com
 [209.85.167.43])
 by hemlock.osuosl.org (Postfix) with ESMTPS id BCF19871B3
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 20:04:50 +0000 (UTC)
Received: by mail-lf1-f43.google.com with SMTP id l28so19005640lfp.10
 for <containers@lists.linux-foundation.org>;
 Mon, 02 Nov 2020 12:04:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=SygJ0YMRNg3kRA+P+/o9DS9VAcEeWET+xfXo18MSK8w=;
 b=IenDEOwcE7acdWlt3upinLTTJLqi4UdRIK+PzIcZHwuf5PctnsoAcu0L8yOZf6HI57
 vlaLdkuBhc5qdDVb0YDoMMcI+rHBUzP1McRaXIovcqGA3X5wyw0sq1O9rJjQTyvAFkj4
 861P7yLhcvBsg8AEdFaV57Edi1EdHZvsLJOIhT0vSnbaUEmhGJo+AL4jNz0rqo8af+d7
 cYAj0ZM/aUC4Y3Lce948K0l4awqBXzXiDZrI1AgyGl4zivZne7XLXGpiLRjzEdn9aDzo
 98Kq0yEKIoz8niqnACP7ZZTeuT7fEmNkLrHA5ATKyJZvfX9PycBSL5wJNWljhEo8JtAX
 fcFA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=SygJ0YMRNg3kRA+P+/o9DS9VAcEeWET+xfXo18MSK8w=;
 b=Cu+pxNep2A/poD+uMHx1Aii0BKZaspRyuF5T8Wjnnmn8uFMD5UxWGcGeH7AoO//q16
 MK18lVMlpetzDuXAeSQS+BADbkZI8CcblBrJXLTrFSPhKZvLtTsGGLGcGhLVt5LUTYIA
 4N3EauV/+mJB2CZgO0lpo0cGO0jIixZKtBRTIf/cW0dN/8Y/kGpLp03aS3yatCYRkQml
 2zk7So3qlp0P01Lebw6p1QAaRCXDZISElWsJS19EzStryY8HPBOjqxxSiA5g2rH8wKLt
 6Y4697ovziMB3yUusIIn8Yw2OosNMJGhh7RoosoFj1z8tvpTvm9FyjXFMLxl90dmPuoO
 MNsg==
X-Gm-Message-State: AOAM531mK5JqMjA6TY1A2GsSPAs0RLoYa+YZsMP9g9RMaDhbasz7SpGd
 BDxPmWRgRRtVdVy4xbgwYdUPCPblhb6L7/whA7FUoQ==
X-Google-Smtp-Source: ABdhPJxFX44DEsMSrcm7kaqxDUVJ2f5DqziIyHEn1UgPjdye5o9apeArOqF6mOkc2usLmVXmtr2vu76cCQnMUTiCBGM=
X-Received: by 2002:a19:c357:: with SMTP id t84mr5844550lff.34.1604347488712; 
 Mon, 02 Nov 2020 12:04:48 -0800 (PST)
MIME-Version: 1.0
References: <63598b4f-6ce3-5a11-4552-cdfe308f68e4@gmail.com>
 <20201029085312.GC29881@ircssh-2.c.rugged-nimbus-611.internal>
 <48e5937b-80f5-c48b-1c67-e8c9db263ca5@gmail.com>
 <20201030202720.GA4088@ircssh-2.c.rugged-nimbus-611.internal>
 <606199d6-b48c-fee2-6e79-1e52bd7f429f@gmail.com>
 <CAMp4zn9AaQ46EyG6QFrF33efpUHnK_TyMYkTicr=iwY5hcKrBg@mail.gmail.com>
 <964c2191-db78-ff4d-5664-1d80dc382df4@gmail.com>
 <CAMp4zn9Eaq7UQqL4Gk7Cs2O3dj1Gfp8L_YDpWxhvru_kVEBVfw@mail.gmail.com>
In-Reply-To: <CAMp4zn9Eaq7UQqL4Gk7Cs2O3dj1Gfp8L_YDpWxhvru_kVEBVfw@mail.gmail.com>
Date: Mon, 2 Nov 2020 21:04:22 +0100
Message-ID: <CAG48ez2vPUCiZX-swrE2oWx8j-6QCzCRiFGnCPFoGMN+oBFGQw@mail.gmail.com>
Subject: Re: For review: seccomp_user_notif(2) manual page [v2]
To: Sargun Dhillon <sargun@sargun.me>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Song Liu <songliubraving@fb.com>,
 Will Drewry <wad@chromium.org>, Kees Cook <keescook@chromium.org>,
 Daniel Borkmann <daniel@iogearbox.net>, linux-man <linux-man@vger.kernel.org>,
 Robert Sesek <rsesek@google.com>,
 Containers <containers@lists.linux-foundation.org>,
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

On Mon, Nov 2, 2020 at 8:50 PM Sargun Dhillon <sargun@sargun.me> wrote:
> On Mon, Nov 2, 2020 at 11:45 AM Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
> >    Caveats regarding blocking system calls
> >        Suppose that the target performs a blocking system call (e.g.,
> >        accept(2)) that the supervisor should handle.  The supervisor
> >        might then in turn execute the same blocking system call.
> >
> >        In this scenario, it is important to note that if the target's
> >        system call is now interrupted by a signal, the supervisor is not
> >        informed of this.  If the supervisor does not take suitable steps
> >        to actively discover that the target's system call has been
> >        canceled, various difficulties can occur.  Taking the example of
> >        accept(2), the supervisor might remain blocked in its accept(2)
> >        holding a port number that the target (which, after the
> >        interruption by the signal handler, perhaps closed  its listening
> >        socket) might expect to be able to reuse in a bind(2) call.
> >
> >        Therefore, when the supervisor wishes to emulate a blocking system
> >        call, it must do so in such a way that it gets informed if the
> >        target's system call is interrupted by a signal handler.  For
> >        example, if the supervisor itself executes the same blocking
> >        system call, then it could employ a separate thread that uses the
> >        SECCOMP_IOCTL_NOTIF_ID_VALID operation to check if the target is
> >        still blocked in its system call.  Alternatively, in the accept(2)
> >        example, the supervisor might use poll(2) to monitor both the
> >        notification file descriptor (so as as to discover when the
> >        target's accept(2) call has been interrupted) and the listening
> >        file descriptor (so as to know when a connection is available).
> >
> >        If the target's system call is interrupted, the supervisor must
> >        take care to release resources (e.g., file descriptors) that it
> >        acquired on behalf of the target.
> >
> > Does that seem okay?
> >
> This is far clearer than my explanation. The one thing is that *just*
> poll is not good enough, you would poll, with some timeout, and when
> that timeout is hit, check if all the current notifications are valid,
> as poll isn't woken up when an in progress notification goes off
> AFAIK.

Arguably that's so terrible that it qualifies for being in the BUGS
section of the manpage.

If you want this to be fixed properly, I recommend that someone
implements my proposal from
<https://lore.kernel.org/lkml/CAG48ez1O2H5HDikPO-_o-toXTheU8GnZot9woGDsNRNJqSWesA@mail.gmail.com/>,
unless you can come up with something better.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
