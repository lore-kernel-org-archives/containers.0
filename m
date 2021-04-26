Return-Path: <SRS0=jAU3=JX=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A77D9C433ED
	for <containers@archiver.kernel.org>; Mon, 26 Apr 2021 19:01:03 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 022EC601FC
	for <containers@archiver.kernel.org>; Mon, 26 Apr 2021 19:01:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 022EC601FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.pizza
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 9377B40233;
	Mon, 26 Apr 2021 19:01:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id L26TAgWQyus2; Mon, 26 Apr 2021 19:01:00 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp2.osuosl.org (Postfix) with ESMTP id 7D5B740160;
	Mon, 26 Apr 2021 19:01:00 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 567ECC000F;
	Mon, 26 Apr 2021 19:01:00 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 289A7C000B
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 19:00:59 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id 23B0A83260
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 19:00:59 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp1.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=tycho.pizza header.b="7VLdJfUU";
 dkim=pass (2048-bit key) header.d=messagingengine.com
 header.b="ZNQLyKaB"
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Nd04ZAvwrjNc
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 19:00:57 +0000 (UTC)
X-Greylist: delayed 00:09:13 by SQLgrey-1.8.0
Received: from new4-smtp.messagingengine.com (new4-smtp.messagingengine.com
 [66.111.4.230])
 by smtp1.osuosl.org (Postfix) with ESMTPS id C4267831A7
 for <containers@lists.linux-foundation.org>;
 Mon, 26 Apr 2021 19:00:57 +0000 (UTC)
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
 by mailnew.nyi.internal (Postfix) with ESMTP id 073CC580B58;
 Mon, 26 Apr 2021 14:51:41 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
 by compute3.internal (MEProxy); Mon, 26 Apr 2021 14:51:41 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tycho.pizza; h=
 date:from:to:cc:subject:message-id:references:mime-version
 :content-type:in-reply-to; s=fm3; bh=sImtnFIf2IiGLj1moI9Axaabj+1
 /JIUf9WTF63IiVmI=; b=7VLdJfUUGvVQcSqhypULyrzoviMfJLOD8sJ0oV6jKOM
 DreychR1086TvYsxPf2fXhedJhJq3kAJw7r8vXf+WFXLs+pcHkhPhrTsMm5lkbmU
 rZr0NV+13i75V/xFaIILYYtRtQMiv5/vvffYp/32eeYdtgZN/XSv7KhOLzeZvsfn
 lTyG/DmbZzRyIngMbDayAp/55lb8RZRJoB8uMlFgorzf0QgFxcnKDSU4VpuBXSH8
 SDQsGEs1ASoz4xoHUBvdRBQGTXcrz77Qpcsr0IMnkpxJE3T7qgxWaHzGCy1URcOt
 S7wW9aLc0H7IcYXXq25zWXgbuoDgiffDmwaIaSjvdxA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
 messagingengine.com; h=cc:content-type:date:from:in-reply-to
 :message-id:mime-version:references:subject:to:x-me-proxy
 :x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=sImtnF
 If2IiGLj1moI9Axaabj+1/JIUf9WTF63IiVmI=; b=ZNQLyKaB+hPmesLsB5Gb5X
 FaCa0ONSitPlEOSsHfBfsE9a/4IMCfWVlsy+EIKz90taXHrtOL5Q/Ocdu18c/uWg
 duW1Ej1/K1O0/enz6zMe8baBG+3Bnl960exXDSrfe59KhZw1k85sjjjlkF8m7lz9
 hgVQbBqImTu6t50sjMbFQMhUyCatd6wNDWUBOfuO3vGV+6wPadjyHDV6+JSywEZ2
 bTMXErDJvMRxnVuVj211o2+xx9wndpcSzYggG5VbERxA+PQeJKUCtNoWCUvLIMi9
 YxmvXN7XDpKYUE6bxvcPf+BM9PW7DASJ7+lpwoTgIOZRQZgwFg44G4kd28fEayng
 ==
X-ME-Sender: <xms:vAuHYB4Zxsdj7A-2mRFexalUWN5RaP_0fWTMFs8wv6E8RWWPk_H2-Q>
 <xme:vAuHYO0mB57IUojXRiXPdGdiC2Isjepv8aC49f-Fa3-YUB4dLbTHj4QAM9n0hqgZ5
 CRd5Rl7PRK5tURKLFs>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduledrvddukedgudefvdcutefuodetggdotefrod
 ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
 necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
 enucfjughrpeffhffvuffkfhggtggujgesthdtredttddtvdenucfhrhhomhepvfihtghh
 ohcutehnuggvrhhsvghnuceothihtghhohesthihtghhohdrphhiiiiirgeqnecuggftrf
 grthhtvghrnhepgeekfeejgeektdejgfefudelkeeuteejgefhhfeugffffeelheegieef
 vdfgtefhnecukfhppedujeefrdefkedruddujedrkeehnecuvehluhhsthgvrhfuihiivg
 eptdenucfrrghrrghmpehmrghilhhfrhhomhepthihtghhohesthihtghhohdrphhiiiii
 rg
X-ME-Proxy: <xmx:vAuHYFV2pb_T0tBrJxJDtTqZoKWT7pyknta59rMWrEUsMt7Lt3n_9A>
 <xmx:vAuHYB6tys_XGS2yycR19zEZGqRy35u2fGzfts0FjhMA_pFAjYMsRw>
 <xmx:vAuHYEKzezsxS_peONK4BaophQq9qDBw38Kzx4borrHiYudRdW6mkg>
 <xmx:vAuHYITankRz_KyZaTPVA-yJkwqn_BOd4ZYRe2eIFdQsgVbL6PLENg>
Received: from cisco (unknown [173.38.117.85])
 by mail.messagingengine.com (Postfix) with ESMTPA id 43CDC1080066;
 Mon, 26 Apr 2021 14:51:39 -0400 (EDT)
Date: Mon, 26 Apr 2021 12:51:38 -0600
From: Tycho Andersen <tycho@tycho.pizza>
To: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH RESEND 3/5] selftests/seccomp: Add test for wait killable
 notifier
Message-ID: <20210426185138.GA1605795@cisco>
References: <20210426180610.2363-1-sargun@sargun.me>
 <20210426180610.2363-4-sargun@sargun.me>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210426180610.2363-4-sargun@sargun.me>
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

On Mon, Apr 26, 2021 at 11:06:08AM -0700, Sargun Dhillon wrote:
> +TEST(user_notification_signal_wait_killable)
> +{
> +	pid_t pid;
> +	long ret;
> +	int status, listener, sk_pair[2];
> +	struct seccomp_notif req = {
> +		.flags = SECCOMP_USER_NOTIF_FLAG_WAIT_KILLABLE,
> +	};
> +	struct seccomp_notif_resp resp = {};
> +	char c;
> +
> +	ret = prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);
> +	ASSERT_EQ(0, ret) {
> +		TH_LOG("Kernel does not support PR_SET_NO_NEW_PRIVS!");
> +	}
> +
> +	ASSERT_EQ(socketpair(PF_LOCAL, SOCK_SEQPACKET, 0, sk_pair), 0);
> +	ASSERT_EQ(fcntl(sk_pair[0], F_SETFL, O_NONBLOCK), 0);
> +
> +	listener = user_notif_syscall(__NR_gettid,
> +				      SECCOMP_FILTER_FLAG_NEW_LISTENER);
> +	ASSERT_GE(listener, 0);
> +
> +	pid = fork();
> +	ASSERT_GE(pid, 0);
> +
> +	if (pid == 0) {
> +		close(sk_pair[0]);
> +		handled = sk_pair[1];
> +		if (signal(SIGUSR1, signal_handler) == SIG_ERR) {

I think here you want a write(handled, "x", 1), right?

Tycho
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
