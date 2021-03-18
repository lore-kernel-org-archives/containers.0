Return-Path: <SRS0=u2Kp=IQ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5296EC433E0
	for <containers@archiver.kernel.org>; Thu, 18 Mar 2021 14:55:06 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8DAEF64F10
	for <containers@archiver.kernel.org>; Thu, 18 Mar 2021 14:55:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DAEF64F10
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 4E2D982F37;
	Thu, 18 Mar 2021 14:55:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id E9oz3DHI6Nae; Thu, 18 Mar 2021 14:55:04 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 47D3283ECE;
	Thu, 18 Mar 2021 14:55:04 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 2469EC000A;
	Thu, 18 Mar 2021 14:55:04 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E1341C0001
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 14:55:02 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id B81B14EE18
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 14:55:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id LJwYXfLflAiV
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 14:55:01 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 9E16D4ED51
 for <containers@lists.linux-foundation.org>;
 Thu, 18 Mar 2021 14:55:01 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1lMu35-0000LC-Rm; Thu, 18 Mar 2021 14:54:55 +0000
Date: Thu, 18 Mar 2021 15:54:54 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Kees Cook <keescook@chromium.org>
Subject: Re: seccomp: Delay filter activation
Message-ID: <20210318145454.d2xbetk2werv7j2u@wittgenstein>
References: <CAMp4zn9oEb6bJJLQWjSE1AFg6TqwkF3FOvFk2VSkKd+0Kj7TCg@mail.gmail.com>
 <20210301110907.2qoxmiy55gpkgwnq@wittgenstein>
 <20210301132156.in3z53t5xxy3ity5@wittgenstein>
 <202103011515.3A941F6@keescook>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <202103011515.3A941F6@keescook>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>,
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

Sorry, I just found that mail.

On Mon, Mar 01, 2021 at 03:44:06PM -0800, Kees Cook wrote:
> On Mon, Mar 01, 2021 at 02:21:56PM +0100, Christian Brauner wrote:
> > On Mon, Mar 01, 2021 at 12:09:09PM +0100, Christian Brauner wrote:
> > > On Sat, Feb 20, 2021 at 01:31:57AM -0800, Sargun Dhillon wrote:
> > > > We've run into a problem where attaching a filter can be quite messy
> > > > business because the filter itself intercepts sendmsg, and other
> > > > syscalls related to exfiltrating the listener FD. I believe that this
> > > > problem set has been brought up before, and although there are
> > > > "simpler" methods of exfiltrating the listener, like clone3 or
> > > > pidfd_getfd, but these are still less than ideal.
> 
> I'm trying to make sure I understand: the target process would like to
> have a filter attached that blocks sendmsg, but that would mean it has
> no way to send the listener FD to its manager?

With pidfd_getfd() that wouldn't be a problem, I think which is what I
was trying to say. Unless the supervising task doen't have enough
privilege over the supervised task which seems like an odd scenario but
is technically possible, I guess.

> 
> And you'd want to have listening working for sendmsg (otherwise you
> could do it with two filters, I imagine)?
> 
> > > 	int fd_filter = seccomp(SECCOMP_SET_MODE_FILTER, SECCOMP_FILTER_DETACHED, &prog);
> > > 
> > > 	BARRIER_WAIT_SETUP_DONE;
> > > 
> > > 	int ret = seccomp(SECCOMP_ATTACH_FILTER, 0, INT_TO_PTR(fd_listener));
> > 
> > This obviously should've been sm like:
> > 
> > struct seccomp_filter_attach {
> > 	union {
> > 		__s32 pidfd;
> > 		__s32 pid;
> > 	};
> > 	__u32 fd_filter;
> > };
> > 
> > and then
> > 
> > int ret = seccomp(SECCOMP_ATTACH_FILTER, 0, seccomp_filter_attach);
> 
> Given the difficulty with TSYNC, I'm not excited about adding an
> "apply this filter to another process" API. :)

Just to give a more complete reason for suggesting something like this
without trying to argue that we must have this:

seccomp() has so far been an API that is caller-centric and by that I
mean that the caller loaded it's seccomp profile and sandboxed itself. As
such seccomp is an example of "caller-managed" security. This security
model has obvious advantages and fits into the general fork()-like world
of unix. But imho that self-management model breaks down as soon as a
file descriptor that can be used to refer to the object in question
enters into the picture. For seccomp this "breaking point" was the
seccomp notifier fd.

Because with the introduction of that fd we have introduced the concept
of supervisor and supervisee for seccomp which imho didn't really exist
in the same way before. It's pretty obvious from the type of language
that we now use both in userspace and in kernelspace when we talk about
the seccomp notifier.

At the current point we're somewhere in the middle between caller-managed
and supervised seccomp which brings up funny probelms and edge-cases.
One of them most obvious examples is in fact the question how to get the
seccomp notify fd out of the supervised task. This clearly points to the
fact that we're missing one of the fundamentals of an fd-based
supervision model: open(). This is why I was suggesting the
SECCOMP_ATTACH_FILTER command. It's in a sense an open-call for the
seccomp notify fd.

That all being said I know that it can be weird to implement this and if
you prefer we go with another simpler model to work around such things
than I fully understand.

Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
