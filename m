Return-Path: <SRS0=jAU3=JX=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEB92C433B4
	for <containers@archiver.kernel.org>; Mon, 26 Apr 2021 19:02:37 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 419D06115C
	for <containers@archiver.kernel.org>; Mon, 26 Apr 2021 19:02:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 419D06115C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id C8B8C83366;
	Mon, 26 Apr 2021 19:02:36 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oYOrhIrScgmq; Mon, 26 Apr 2021 19:02:36 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id BE58B8390F;
	Mon, 26 Apr 2021 19:02:35 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9A9BAC000F;
	Mon, 26 Apr 2021 19:02:35 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [IPv6:2605:bc80:3010::137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 77DFEC000B
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 19:02:34 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id 57D304048E
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 19:02:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp4.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=tycho.pizza header.b="6uRE5o4e";
 dkim=pass (2048-bit key) header.d=messagingengine.com
 header.b="Oi6UozXj"
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 089Bw6clasdG
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 19:02:33 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com
 [66.111.4.230])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 8C73C403DE
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 19:02:33 +0000 (UTC)
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
 by mailnew.nyi.internal (Postfix) with ESMTP id 6DD395803EE;
 Mon, 26 Apr 2021 15:02:32 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
 by compute2.internal (MEProxy); Mon, 26 Apr 2021 15:02:32 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm3; bh=jlblDGKKV68vfiveJhVJ8dGvoNh
 vhfHu+cqRN1LYftE=; b=6uRE5o4evdjcVrMLLg4VChLZMlox1EIpQvg512h2ttT
 0cqWGEvLxtWSle4WMHIY8HfsaN2BNM2yhGvTIukOVieT1x/yuHWJ0HIblahhREX1
 lkYcwJX96BeASy2Y2Nvq7HdFQfPOflXr9aTGjE2O5unI12sFk3rnmhdYedZyC6Fy
 f3gjfvvyh9cLGtq/oXnopjVQFWeZwY3fHE52WNglSTMrNS+AhvgGk8oHw62h2xO2
 w84apisB9ajInCMevTFAp+8Y8F6nb2aV0V860VVhlG0QRDBsXyzPyghKOjP50Mjc
 SOo9tbzDoO638yXZdTH4f58foIME3MXh+UvkbNLD5TA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=jlblDG
 KKV68vfiveJhVJ8dGvoNhvhfHu+cqRN1LYftE=; b=Oi6UozXjCLyKLEBgVVwTln
 Q1JMo0Whhdo4r2iofXS5dE1si64zw18X60KHi8vWK5PQDfOteziedsVPUn/A7xXd
 +SRHYy2sAS9FoiMEhSqGjPj26MBsAAi8urRc+nkMSvm1Z5e1Oe2kTZ8bbZ6er4bw
 OYSSvbXPqr49fTqPxTuVCQ+D3ZgeBnTenFZwm4zwY+fbcTbiZi3TNlTmbC2V8U/Y
 pGjMzNTHLqCf8moceRABm5m804MqElA8jqIKjaON+AvD9d2O1jHptaozyaQaSYdX
 a6aPxNPC0O7y11uNT+u513SMvKv7TbAO630ry6WiF6+avnH6ZRlUkbnuOjpEF7Kw
 ==
X-ME-Sender: <xms:Rw6HYF2L0tpn99bjt9FuLyKQxCIQFIZwdSczZNsaAIL_zku247ts7A>
 <xme:Rw6HYLymEf5utr8QOvYpRZxTaxBm6P1qAeArMz9lmHktKlpGQ9ohscati0kjecOw8
 GMjxixxbX9iasZXfkM>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduledrvddukedgudefgecutefuodetggdotefrod
 ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
 necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
 enucfjughrpeffhffvuffkfhggtggujgesthdtredttddtvdenucfhrhhomhepvfihtghh
 ohcutehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrf
 grthhtvghrnhepgeekfeejgeektdejgfefudelkeeuteejgefhhfeugffffeelheegieef
 vdfgtefhnecukfhppedujeefrdefkedruddujedrkeehnecuvehluhhsthgvrhfuihiivg
 eptdenucfrrghrrghmpehmrghilhhfrhhomhepthihtghhohesthihtghhohdrphhiiiii
 rg
X-ME-Proxy: <xmx:Rw6HYBhsGSkcyTKlD5Fv9pUCL1TA1wodniFJHxX8dzKpiwv8iC9FBw>
 <xmx:Rw6HYOrZXsTfNoDXtlCSrbMbRkbbn_yJ63wa7n0udYb6_cp7fPF1LA>
 <xmx:Rw6HYIjXx5oaxjlV__TBUoBHOgY529rU_i4XsRaxo0DAla0MzVjJIw>
 <xmx:SA6HYDTQFnwT4NtSmpVb1ymkO8g2HmocMa9op_ID5_qt0rN0PXEhXA>
Received: from cisco (unknown [173.38.117.85])
 by mail.messagingengine.com (Postfix) with ESMTPA id D31661080066;
 Mon, 26 Apr 2021 15:02:30 -0400 (EDT)
Date: Mon, 26 Apr 2021 13:02:29 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH RESEND 2/5] seccomp: Add wait_killable semantic to
 seccomp user notifier
Message-ID: <20210426190229.GB1605795@cisco>
References: <20210426180610.2363-1-sargun@sargun.me>
 <20210426180610.2363-3-sargun@sargun.me>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210426180610.2363-3-sargun@sargun.me>
Cc: Giuseppe Scrivano <gscrivan@redhat.com>, Will Drewry <wad@chromium.org>,
 Kees Cook <keescook@chromium.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>,
 Alban Crequy <alban@kinvolk.io>,
 Christian Brauner <christian.brauner@ubuntu.com>
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

On Mon, Apr 26, 2021 at 11:06:07AM -0700, Sargun Dhillon wrote:
> @@ -1103,11 +1111,31 @@ static int seccomp_do_user_notification(int this_syscall,
>  	 * This is where we wait for a reply from userspace.
>  	 */
>  	do {
> +		interruptible = notification_interruptible(&n);
> +
>  		mutex_unlock(&match->notify_lock);
> -		err = wait_for_completion_interruptible(&n.ready);
> +		if (interruptible)
> +			err = wait_for_completion_interruptible(&n.ready);
> +		else
> +			err = wait_for_completion_killable(&n.ready);
>  		mutex_lock(&match->notify_lock);
> -		if (err != 0)
> +
> +		if (err != 0) {
> +			/*
> +			 * There is a race condition here where if the
> +			 * notification was received with the
> +			 * SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE flag, but a
> +			 * non-fatal signal was received before we could
> +			 * transition we could erroneously end our wait early.
> +			 *
> +			 * The next wait for completion will ensure the signal
> +			 * was not fatal.
> +			 */
> +			if (interruptible && !notification_interruptible(&n))
> +				continue;

I'm trying to understand how one would hit this race,

> @@ -1457,6 +1487,12 @@ static long seccomp_notify_recv(struct seccomp_filter *filter,
>  	unotif.pid = task_pid_vnr(knotif->task);
>  	unotif.data = *(knotif->data);
>  
> +	if (unotif.flags & SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE) {
> +		knotif->wait_killable = true;
> +		complete(&knotif->ready);
> +	}
> +
> +
>  	knotif->state = SECCOMP_NOTIFY_SENT;
>  	wake_up_poll(&filter->wqh, EPOLLOUT | EPOLLWRNORM);
>  	ret = 0;

Seems like the idea is that if someone does a ioctl(RECV, ...) twice
they'll hit it? But doesn't the test for NOTIFY_INIT and return
-ENOENT above this hunk prevent that?

Thanks,

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
