Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF926C4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 16:48:07 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0DF1A20838
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 16:48:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="D0TFV20S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DF1A20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 777A086B5A;
	Thu, 29 Oct 2020 16:48:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jUEJe7aoBZ6H; Thu, 29 Oct 2020 16:48:04 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 1053386B80;
	Thu, 29 Oct 2020 16:48:04 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id F0322C0859;
	Thu, 29 Oct 2020 16:48:03 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 63327C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:48:03 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 5EF0686B5A
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:48:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 3F85430vnPr2
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:48:02 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [63.128.21.124])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id ADBB286AE0
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 16:48:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1603990081;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=TwZQ2oN6WxzK0UUncdaVDf1saKXhHV2p2lzyo7kKTGg=;
 b=D0TFV20SMf+eCOlXjdnnASI0eVTPpeHSXbq/mFjN82ui1HVC3YVsuW8IGzCZqUa+iy/hAp
 2mXu5q8Ti0QgyHweL40kQU3aiifNBeiMlMLWlE2RLeKi90W88YwjEiTcZHuarUVS5WJnSP
 UyjXxZK4RsrgB3wJ2Rk7XIBGlhdVAb4=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-594-ARyo9KBvOw-DHqiZaF1ENw-1; Thu, 29 Oct 2020 12:47:57 -0400
X-MC-Unique: ARyo9KBvOw-DHqiZaF1ENw-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com
 [10.5.11.13])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 451A6807321;
 Thu, 29 Oct 2020 16:47:56 +0000 (UTC)
Received: from localhost (ovpn-113-77.ams2.redhat.com [10.36.113.77])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id B96B56EF68;
 Thu, 29 Oct 2020 16:47:55 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v2 0/2] fs, close_range: add flag CLOSE_RANGE_CLOEXEC
References: <20201019102654.16642-1-gscrivan@redhat.com>
 <20201029153859.numo2fc42vgf3ppk@wittgenstein>
Date: Thu, 29 Oct 2020 17:47:53 +0100
In-Reply-To: <20201029153859.numo2fc42vgf3ppk@wittgenstein> (Christian
 Brauner's message of "Thu, 29 Oct 2020 16:38:59 +0100")
Message-ID: <87mu05vv0m.fsf@redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
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

Hi Christian,

Christian Brauner <christian.brauner@ubuntu.com> writes:

> On Mon, Oct 19, 2020 at 12:26:52PM +0200, Giuseppe Scrivano wrote:
>> When the new flag is used, close_range will set the close-on-exec bit
>> for the file descriptors instead of close()-ing them.
>> 
>> It is useful for e.g. container runtimes that want to minimize the
>> number of syscalls used after a seccomp profile is installed but want
>> to keep some fds open until the container process is executed.
>> 
>> v1->v2:
>> * move close_range(..., CLOSE_RANGE_CLOEXEC) implementation to a separate function.
>> * use bitmap_set() to set the close-on-exec bits in the bitmap.
>> * add test with rlimit(RLIMIT_NOFILE) in place.
>> * use "cur_max" that is already used by close_range(..., 0).
>
> I'm picking this up for some testing, thanks
> Christian

thanks!  I've addressed the comments you had for v2 and pushed them
here[1] but I've not sent yet v3 as I was waiting for a feedback from Al
whether using bitmap_set() is fine.

Regards,
Giuseppe

[1] https://github.com/giuseppe/linux/tree/close-range-cloexec

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
