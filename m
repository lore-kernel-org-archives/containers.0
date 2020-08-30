Return-Path: <SRS0=zxUI=CI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D33B8C433E2
	for <containers@archiver.kernel.org>; Sun, 30 Aug 2020 05:48:21 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 85F612071B
	for <containers@archiver.kernel.org>; Sun, 30 Aug 2020 05:48:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="IueRA7pi";
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="NCgNyQ6e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85F612071B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 2DCDB203EA;
	Sun, 30 Aug 2020 05:48:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id txZqNp2pA1bW; Sun, 30 Aug 2020 05:48:19 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id D43EF203AD;
	Sun, 30 Aug 2020 05:48:19 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B6FF8C088B;
	Sun, 30 Aug 2020 05:48:19 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 5D27EC0052
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 05:48:18 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 4DA20860A3
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 05:48:18 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 9uUiZZBGl-E4
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 05:48:16 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com
 [66.63.167.143])
 by whitealder.osuosl.org (Postfix) with ESMTPS id BE29F85D5F
 for <containers@lists.linux-foundation.org>;
 Sun, 30 Aug 2020 05:48:16 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by bedivere.hansenpartnership.com (Postfix) with ESMTP id 9089C8EE119;
 Sat, 29 Aug 2020 22:48:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
 s=20151216; t=1598766495;
 bh=nFj9FMiPs+Aeqn5M7NaLpcMMm1ne5Kahp/vBOPpRhjs=;
 h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
 b=IueRA7piUkkuwlXO9tb77AlPxlfg4I6/Ko8sKXlJ0hpa2FcDN40NGDlbXxcD07waW
 /UbJ9J8WIqgzeJqXbnCoiiMs8nhqtMlw8HWqeJS7SVVRkGM/bFqTIWMm1DJPvITSWF
 9b1GSkY2HJjg1h8BiPSZpJgXvR7OW1Z/g79ocW6M=
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
 by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new,
 port 10024)
 with ESMTP id JCnJolpvS0lz; Sat, 29 Aug 2020 22:48:14 -0700 (PDT)
Received: from [153.66.254.174] (c-73-35-198-56.hsd1.wa.comcast.net
 [73.35.198.56])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id A33908EE10C;
 Sat, 29 Aug 2020 22:48:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
 s=20151216; t=1598766493;
 bh=nFj9FMiPs+Aeqn5M7NaLpcMMm1ne5Kahp/vBOPpRhjs=;
 h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
 b=NCgNyQ6eonqLah3sGrvvcTydWRVhJJcytSBfChLtQ/GuPCB0X/qR+q9j54xkxhLcy
 yBu0T4oMscoU7BPlGI/GFZeOWSV7afZ0yylWYV3SFfaTLdG3j0fVmd2LiEF8PNYf0Y
 4IZYpZcFsIzehyD9iQ/2p8Tn4ki85NQBpJhBSsso=
Message-ID: <1598766491.5540.2.camel@HansenPartnership.com>
Subject: Re: Use cases for multiple uid mapping?
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers
 <containers@lists.linux-foundation.org>
Date: Sat, 29 Aug 2020 22:48:11 -0700
In-Reply-To: <87zh6eiyv7.fsf@x220.int.ebiederm.org>
References: <87zh6eiyv7.fsf@x220.int.ebiederm.org>
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Cc: Christian Brauner <christian.brauner@ubuntu.com>
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

On Fri, 2020-08-28 at 10:17 -0500, Eric W. Biederman wrote:
[...]
> Can people follow up to this and report their use cases?
> 
> There are some real challenges and I would like to see if we
> can solve them, while avoiding scary problems like changing
> uids on write.

The main problem shiftfs has that fsuid doesn't is write at privileged
id, so mainly safely writing to kuid 0.

shiftfs tried to solve this by exposing the shifted mount point safely,
but maybe there's another way to do it.

James

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
