Return-Path: <SRS0=u2Kp=IQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 530B1C433E0
	for <containers@archiver.kernel.org>; Thu, 18 Mar 2021 20:39:21 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C3CCE64F1D
	for <containers@archiver.kernel.org>; Thu, 18 Mar 2021 20:39:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3CCE64F1D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sargun.me
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 6ED428300C;
	Thu, 18 Mar 2021 20:39:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id apxhhaLyTuDY; Thu, 18 Mar 2021 20:39:19 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 2ED6482A29;
	Thu, 18 Mar 2021 20:39:19 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id F3228C000A;
	Thu, 18 Mar 2021 20:39:18 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [IPv6:2605:bc80:3010::136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id ABC64C0001
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 20:39:17 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 85F036FAE1
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 20:39:17 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp3.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=sargun.me
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 5WfWa_2GcHaW
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 20:39:16 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-il1-x12e.google.com (mail-il1-x12e.google.com
 [IPv6:2607:f8b0:4864:20::12e])
 by smtp3.osuosl.org (Postfix) with ESMTPS id 300B6606D6
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 20:39:16 +0000 (UTC)
Received: by mail-il1-x12e.google.com with SMTP id 19so6130960ilj.2
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 13:39:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sargun.me; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to:user-agent;
 bh=5lNoLTd2zddsI+YTLgZ1PSBgoPAyGtxjKp1mgdNA9Ac=;
 b=h0xO4lDszBFKrylkFdt8AHPsrSlYpZfuzkhA/3LjQ4/k+Z7Kf/nzp9OI4nCDT/Sz/L
 15gjMKjf+/LgKs9aMJ8tTvhP7h/rWNhgNcZ5u6Rd9TRJTJRe++HWGrAZMZCvJA4N1RIR
 xQ2NKK8WdyuSsQTSCRC14e8M/lHMiLEyo/ARg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to:user-agent;
 bh=5lNoLTd2zddsI+YTLgZ1PSBgoPAyGtxjKp1mgdNA9Ac=;
 b=QrdKDgu+OwPCmQjQpgV12qmTEcu3y0p8ektwqnbMy9UQD7U+0BgfgBPeiSBfQE6+Re
 zWouqpZ9ThYdbrkqtUtRSQLWBzoATsuKQryZQcTBDOphMLCFe9XoS2rXVGHHwov4z+rK
 0YFgi1Rv9wAUl2PXZtRGDFSoMZpTbgJcvkROLFoObUl93JXK/mr27n0DaiNu36LEo94F
 ryQCIzQ6i9ldzzZJiHaQm6flhYpS/6zgKPkWg3Q/kkTCzxxRIXuttVJLTzbKz581XQ/x
 DyH/3WguK/UMqTMD1aCVDqXakcNy6OlYUTT7vd/J4AWK1y3e2fLzLNiBwo9BBAbaoevE
 ohdg==
X-Gm-Message-State: AOAM530LxSDkzdf646uCtDyxwWZ0hq2Nf/unf+T4vLK6JZdb0M1kprOS
 mW4ltI5+lFouL43nrgEsmBI7nw==
X-Google-Smtp-Source: ABdhPJy5lnkk+2ghJpkKTkdeRTPLPUTDG7R38r8JESnmw8Nn9MbAKXKQAOC+wEQa8syCbnJLtX+mMw==
X-Received: by 2002:a92:b70c:: with SMTP id k12mr366489ili.60.1616099955031;
 Thu, 18 Mar 2021 13:39:15 -0700 (PDT)
Received: from ircssh-2.c.rugged-nimbus-611.internal
 (80.60.198.104.bc.googleusercontent.com. [104.198.60.80])
 by smtp.gmail.com with ESMTPSA id l14sm1578244ilc.33.2021.03.18.13.39.14
 (version=TLS1_2 cipher=ECDHE-ECDSA-CHACHA20-POLY1305 bits=256/256);
 Thu, 18 Mar 2021 13:39:14 -0700 (PDT)
Date: Thu, 18 Mar 2021 20:39:13 +0000
From: Sargun Dhillon <sargun@sargun.me>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: seccomp: Delay filter activation
Message-ID: <20210318203912.GA26982@ircssh-2.c.rugged-nimbus-611.internal>
References: <CAMp4zn9oEb6bJJLQWjSE1AFg6TqwkF3FOvFk2VSkKd+0Kj7TCg@mail.gmail.com>
 <20210301110907.2qoxmiy55gpkgwnq@wittgenstein>
 <20210301132156.in3z53t5xxy3ity5@wittgenstein>
 <202103011515.3A941F6@keescook>
 <20210318145454.d2xbetk2werv7j2u@wittgenstein>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210318145454.d2xbetk2werv7j2u@wittgenstein>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Kees Cook <keescook@chromium.org>,
 Keerti Lakshminarayan <keerti@netflix.com>,
 Linux Containers List <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Hariharan Ananthakrishnan <hari@netflix.com>,
 Kyle Anderson <kylea@netflix.com>, Andy Lutomirski <luto@amacapital.net>
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

On Thu, Mar 18, 2021 at 03:54:54PM +0100, Christian Brauner wrote:
> Sorry, I just found that mail.
> 
> On Mon, Mar 01, 2021 at 03:44:06PM -0800, Kees Cook wrote:
> > On Mon, Mar 01, 2021 at 02:21:56PM +0100, Christian Brauner wrote:
> > > On Mon, Mar 01, 2021 at 12:09:09PM +0100, Christian Brauner wrote:
> > > > On Sat, Feb 20, 2021 at 01:31:57AM -0800, Sargun Dhillon wrote:
> > > > > We've run into a problem where attaching a filter can be quite messy
> > > > > business because the filter itself intercepts sendmsg, and other
> > > > > syscalls related to exfiltrating the listener FD. I believe that this
> > > > > problem set has been brought up before, and although there are
> > > > > "simpler" methods of exfiltrating the listener, like clone3 or
> > > > > pidfd_getfd, but these are still less than ideal.
> > 
> > I'm trying to make sure I understand: the target process would like to
> > have a filter attached that blocks sendmsg, but that would mean it has
> > no way to send the listener FD to its manager?
> 
> With pidfd_getfd() that wouldn't be a problem, I think which is what I
> was trying to say. Unless the supervising task doen't have enough
> privilege over the supervised task which seems like an odd scenario but
> is technically possible, I guess.
> 
> > 
> > And you'd want to have listening working for sendmsg (otherwise you
> > could do it with two filters, I imagine)?
> > 
> > > > 	int fd_filter = seccomp(SECCOMP_SET_MODE_FILTER, SECCOMP_FILTER_DETACHED, &prog);
> > > > 
> > > > 	BARRIER_WAIT_SETUP_DONE;
> > > > 
> > > > 	int ret = seccomp(SECCOMP_ATTACH_FILTER, 0, INT_TO_PTR(fd_listener));
> > > 
> > > This obviously should've been sm like:
> > > 
> > > struct seccomp_filter_attach {
> > > 	union {
> > > 		__s32 pidfd;
> > > 		__s32 pid;
> > > 	};
> > > 	__u32 fd_filter;
> > > };
> > > 
> > > and then
> > > 
> > > int ret = seccomp(SECCOMP_ATTACH_FILTER, 0, seccomp_filter_attach);
> > 
> > Given the difficulty with TSYNC, I'm not excited about adding an
> > "apply this filter to another process" API. :)
> 
> Just to give a more complete reason for suggesting something like this
> without trying to argue that we must have this:
> 
> seccomp() has so far been an API that is caller-centric and by that I
> mean that the caller loaded it's seccomp profile and sandboxed itself. As
> such seccomp is an example of "caller-managed" security. This security
> model has obvious advantages and fits into the general fork()-like world
> of unix. But imho that self-management model breaks down as soon as a
> file descriptor that can be used to refer to the object in question
> enters into the picture. For seccomp this "breaking point" was the
> seccomp notifier fd.
> 
> Because with the introduction of that fd we have introduced the concept
> of supervisor and supervisee for seccomp which imho didn't really exist
> in the same way before. It's pretty obvious from the type of language
> that we now use both in userspace and in kernelspace when we talk about
> the seccomp notifier.
> 
> At the current point we're somewhere in the middle between caller-managed
> and supervised seccomp which brings up funny probelms and edge-cases.
> One of them most obvious examples is in fact the question how to get the
> seccomp notify fd out of the supervised task. This clearly points to the
> fact that we're missing one of the fundamentals of an fd-based
> supervision model: open(). This is why I was suggesting the
> SECCOMP_ATTACH_FILTER command. It's in a sense an open-call for the
> seccomp notify fd.
> 
> That all being said I know that it can be weird to implement this and if
> you prefer we go with another simpler model to work around such things
> than I fully understand.
> 
> Christian

So, beyond clone3 to get pidfds being kind of awkward, how do you see this
pattern actually working? How does the filter installer let the supervisor
know that it's ready for extraction? pause() + signaling the parent?

In the case that you're not fork-execing, how do you communicate to the 
notifier? My coworkers have been working on this code, where they need to 
connect to a daemon that does the supervision, and it's gnarly[1]. They're 
looking at adding sendmsg to the filter list, and that complicates things.

I think that pidfd_getfd works well if the child has some way to signal to the 
parent that it's ready and that the filter has been installed, but when your 
filter intercepts connect, and sendmsg, and the supervisor is not your parent 
(and your parent is some compiled, COTS software), it becomes complicated to 
handle this.

I believe that the OCI spec[2] is going to run into this class of problem unless 
we introduce an out of band signaling mechanism. I think a valid way to handle 
this is do a send() of the fd number (literal), and wait for the other side to 
pidfd_getfd the seccomp filter, and wait for the socket to be closed to continue,
but I think we should maybe create an example (I volunteer) showing how to do this.



[1]: 
https://github.com/Netflix/titus-executor/blob/393d71fa3b4ab836c6036c6a242a7f4fd2d0307e/tini/src/seccomp_fd_notify.c#L139-L201 
[2]: 
https://github.com/opencontainers/runtime-spec/commit/a8c4a9ee0f6b5a0b994c5c23c68725394e2b0d9d
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
