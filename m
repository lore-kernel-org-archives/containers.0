Return-Path: <SRS0=nHAz=EY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D393C5519F
	for <containers@archiver.kernel.org>; Wed, 18 Nov 2020 10:02:38 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 342F720738
	for <containers@archiver.kernel.org>; Wed, 18 Nov 2020 10:02:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 342F720738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 7849E8523B;
	Wed, 18 Nov 2020 10:02:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hULQKWhWLgad; Wed, 18 Nov 2020 10:02:33 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id B4C1D820B3;
	Wed, 18 Nov 2020 10:02:33 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9C424C0891;
	Wed, 18 Nov 2020 10:02:33 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 98692C07FF
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:02:31 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 7EE58864F3
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:02:31 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id EKhS6qEU55b8
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:02:30 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by whitealder.osuosl.org (Postfix) with ESMTP id 7FDBC8602E
 for <containers@lists.linux-foundation.org>;
 Wed, 18 Nov 2020 10:02:30 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kfKID-00037N-TN; Wed, 18 Nov 2020 10:02:26 +0000
Date: Wed, 18 Nov 2020 11:02:25 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Giuseppe Scrivano <gscrivan@redhat.com>
Subject: Re: [PATCH v2 0/2] fs, close_range: add flag CLOSE_RANGE_CLOEXEC
Message-ID: <20201118100225.5sdsourja7ec5fyn@wittgenstein>
References: <20201019102654.16642-1-gscrivan@redhat.com>
 <20201029153859.numo2fc42vgf3ppk@wittgenstein>
 <87mu05vv0m.fsf@redhat.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <87mu05vv0m.fsf@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org,
 linux@rasmusvillemoes.dk, linux-kernel@vger.kernel.org,
 viro@zeniv.linux.org.uk
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

On Thu, Oct 29, 2020 at 05:47:53PM +0100, Giuseppe Scrivano wrote:
> Hi Christian,
> 
> Christian Brauner <christian.brauner@ubuntu.com> writes:
> 
> > On Mon, Oct 19, 2020 at 12:26:52PM +0200, Giuseppe Scrivano wrote:
> >> When the new flag is used, close_range will set the close-on-exec bit
> >> for the file descriptors instead of close()-ing them.
> >> 
> >> It is useful for e.g. container runtimes that want to minimize the
> >> number of syscalls used after a seccomp profile is installed but want
> >> to keep some fds open until the container process is executed.
> >> 
> >> v1->v2:
> >> * move close_range(..., CLOSE_RANGE_CLOEXEC) implementation to a separate function.
> >> * use bitmap_set() to set the close-on-exec bits in the bitmap.
> >> * add test with rlimit(RLIMIT_NOFILE) in place.
> >> * use "cur_max" that is already used by close_range(..., 0).
> >
> > I'm picking this up for some testing, thanks
> > Christian
> 
> thanks!  I've addressed the comments you had for v2 and pushed them
> here[1] but I've not sent yet v3 as I was waiting for a feedback from Al
> whether using bitmap_set() is fine.

Send it please.
Christian
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
