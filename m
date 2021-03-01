Return-Path: <SRS0=ByLK=H7=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EA0CC433E0
	for <containers@archiver.kernel.org>; Mon,  1 Mar 2021 23:44:13 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2B395601FE
	for <containers@archiver.kernel.org>; Mon,  1 Mar 2021 23:44:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B395601FE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id DBE054300A;
	Mon,  1 Mar 2021 23:44:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id G4ch1Z3t6K_y; Mon,  1 Mar 2021 23:44:12 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp2.osuosl.org (Postfix) with ESMTP id C0650414FE;
	Mon,  1 Mar 2021 23:44:11 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A9F56C000B;
	Mon,  1 Mar 2021 23:44:11 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 93FAAC0001
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 23:44:10 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id 8209D838F7
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 23:44:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp1.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=chromium.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id fhEzILE855GL
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 23:44:09 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from mail-pl1-f179.google.com (mail-pl1-f179.google.com
 [209.85.214.179])
 by smtp1.osuosl.org (Postfix) with ESMTPS id ABB0B82A7F
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 23:44:09 +0000 (UTC)
Received: by mail-pl1-f179.google.com with SMTP id a24so10899642plm.11
 for <containers@lists.linux-foundation.org>;
 Mon, 01 Mar 2021 15:44:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=chromium.org; s=google;
 h=date:from:to:cc:subject:message-id:references:mime-version
 :content-disposition:in-reply-to;
 bh=RTezlDdWlyXLpCOLyoejuYIgRgLCTwDD8YVq+tQaJc8=;
 b=SMEGRkEBp354fEyh/GFvOWpGE747zYZKCkATBRaZTQsjtvIRubMSxLsRxc8oXqidQT
 DmmTlRBrgI2Gk4Foj+nUqGf2/taCScG356x6bZ7gG8Z24ALqmCoiGAhrtMWpI/oPbhCw
 AFAq59StlLTfhFw9M3ah/zARN6Bn6NjhEXnoI=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:date:from:to:cc:subject:message-id:references
 :mime-version:content-disposition:in-reply-to;
 bh=RTezlDdWlyXLpCOLyoejuYIgRgLCTwDD8YVq+tQaJc8=;
 b=QTVYfgfB3vcZWdYSeW7keNWnH/qm86kMf+yqFK6fJzSeb2vx3E5/Eky63uHOH7MNIh
 wBixTR9HDR6XZvy++8W4kfmHcQxmDh+VMB8ZLZZUvvhiRI+ALFH5fMRYR3OHRivn6CoB
 qgUDLAMGhwIodsRP1j1bNOBCLgegb+fJ+GiZpRsTIl79DVTxrsQOakHWAsMrPOBydQ7w
 4sUdiDVADzZKlvzGt6EK1lu2GA9jn4Klu74CJrxPXR1lQJDkYynJiZkQooQ9dZyHRMhw
 DAUJo8LTj4ob+KKegmoUpFEe34+6BSf64LsZizpQK8Yg354TD5MuvOFJABS+ug6gXLhB
 HL2g==
X-Gm-Message-State: AOAM531VgC8oun3CFsYq/ZB67wclta5uJ3rJKL45e9A2P+V3EYlTaJaK
 rH/juiwXAcU0c2k+jto2tqXowQ==
X-Google-Smtp-Source: ABdhPJyttvCmDvNSHruHFb4bfNVgROsrUVbaW5dCNRyWImvCjjaydTLjSrMwbUXOBijWRs1VeOnCAg==
X-Received: by 2002:a17:90a:ce0c:: with SMTP id
 f12mr1333241pju.11.1614642249086; 
 Mon, 01 Mar 2021 15:44:09 -0800 (PST)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
 by smtp.gmail.com with ESMTPSA id y4sm4412027pgq.32.2021.03.01.15.44.08
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Mon, 01 Mar 2021 15:44:08 -0800 (PST)
Date: Mon, 1 Mar 2021 15:44:06 -0800
From: Kees Cook <keescook@chromium.org>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: seccomp: Delay filter activation
Message-ID: <202103011515.3A941F6@keescook>
References: <CAMp4zn9oEb6bJJLQWjSE1AFg6TqwkF3FOvFk2VSkKd+0Kj7TCg@mail.gmail.com>
 <20210301110907.2qoxmiy55gpkgwnq@wittgenstein>
 <20210301132156.in3z53t5xxy3ity5@wittgenstein>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210301132156.in3z53t5xxy3ity5@wittgenstein>
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

On Mon, Mar 01, 2021 at 02:21:56PM +0100, Christian Brauner wrote:
> On Mon, Mar 01, 2021 at 12:09:09PM +0100, Christian Brauner wrote:
> > On Sat, Feb 20, 2021 at 01:31:57AM -0800, Sargun Dhillon wrote:
> > > We've run into a problem where attaching a filter can be quite messy
> > > business because the filter itself intercepts sendmsg, and other
> > > syscalls related to exfiltrating the listener FD. I believe that this
> > > problem set has been brought up before, and although there are
> > > "simpler" methods of exfiltrating the listener, like clone3 or
> > > pidfd_getfd, but these are still less than ideal.

I'm trying to make sure I understand: the target process would like to
have a filter attached that blocks sendmsg, but that would mean it has
no way to send the listener FD to its manager?

And you'd want to have listening working for sendmsg (otherwise you
could do it with two filters, I imagine)?

> > 	int fd_filter = seccomp(SECCOMP_SET_MODE_FILTER, SECCOMP_FILTER_DETACHED, &prog);
> > 
> > 	BARRIER_WAIT_SETUP_DONE;
> > 
> > 	int ret = seccomp(SECCOMP_ATTACH_FILTER, 0, INT_TO_PTR(fd_listener));
> 
> This obviously should've been sm like:
> 
> struct seccomp_filter_attach {
> 	union {
> 		__s32 pidfd;
> 		__s32 pid;
> 	};
> 	__u32 fd_filter;
> };
> 
> and then
> 
> int ret = seccomp(SECCOMP_ATTACH_FILTER, 0, seccomp_filter_attach);

Given the difficulty with TSYNC, I'm not excited about adding an
"apply this filter to another process" API. :)

The prior thread was here:
https://lore.kernel.org/lkml/20201029075841.GB29881@ircssh-2.c.rugged-nimbus-611.internal/

But I haven't had time to follow up. Both Andy and Sargun discuss filter
"replacement", but I'm not a fan of that, since I'd really like to keep
the "additive-only" property of seccomp.

So, I'm still back to wanting an answer to my questions at the end of
https://lore.kernel.org/lkml/202010281503.3D1FCFE0@keescook/

Namely, how to best indicate the point of execution where "delayed"
filters become applied?

If we require supporting the "2b" (launched oblivious target) case
(which I think we must), we need to signal it externally, or via an
automatic trip point.

Since synchronizing with an oblivious target is rather nasty (e.g.
involving ptrace or at least ptrace access checking), I'd rather create
a predefined trip point. Having it be "execve" limits the utility of
this feature for cooperating targets, though, so I think "apply on exec"
isn't great.

struct seccomp_filter_attach_trigger {
	u64 nr;
	unsigned char *filter;
};

seccomp(SECCOMP_ATTACH_FILTER_TRIGGER, 0, seccomp_filter_attach_trigger);

after "nr" is evaluated (but before it runs), seccomp installs the
filter.

And by "installs", I'm not sure if it needs to keep it in a queue, with
separate ref coutning, or if it should be in the main filter stack, but
have an "alive" toggle, or what.

-- 
Kees Cook
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
