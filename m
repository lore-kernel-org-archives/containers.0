Return-Path: <SRS0=ZZR0=HZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D87FC433DB
	for <containers@archiver.kernel.org>; Tue, 23 Feb 2021 01:53:30 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E9D2064E5C
	for <containers@archiver.kernel.org>; Tue, 23 Feb 2021 01:53:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E9D2064E5C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id BA0FC87066;
	Tue, 23 Feb 2021 01:53:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KDDaCjSlU3YY; Tue, 23 Feb 2021 01:53:29 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 59BB881AF0;
	Tue, 23 Feb 2021 01:53:29 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3C36AC000A;
	Tue, 23 Feb 2021 01:53:29 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 5D154C0001
 for <containers@lists.linux-foundation.org>;
 Tue, 23 Feb 2021 01:53:28 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 48D4E60602
 for <containers@lists.linux-foundation.org>;
 Tue, 23 Feb 2021 01:53:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 7D_9SJFgzyL0
 for <containers@lists.linux-foundation.org>;
 Tue, 23 Feb 2021 01:53:27 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by smtp3.osuosl.org (Postfix) with ESMTPS id 63C3E605D2
 for <containers@lists.linux-foundation.org>;
 Tue, 23 Feb 2021 01:53:27 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPS id D5DC964E12;
 Tue, 23 Feb 2021 01:53:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
 s=k20201202; t=1614045206;
 bh=P3F/xfDHxag11qUSAjCG+isJYETCAxburWf45MLxJa8=;
 h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
 b=Mvrql0pU9M5CWTXgE5vJdekMchlRIvs1k7uS5oLguFoOfCDYuSh5lCfTdsGyy41uw
 dgrFjcJEgKj+0ihge4zgGP2fwLiVbKdmRHPhF0Aro8C7VwPhjuq8WV3gfTjtz2Fpxk
 UvkjiKJmD1IAOZFF8MWYpJkOpJzetXP78fNldMlmxV91dpDHAwoug6ynWAfsyvvuUv
 sAAKifz/0+wSAmsWFM9SMVpcfx84AeMreTP+qnlroBeCN/CQs+q5yWm4wrDOtikQ2u
 oFMcHWCsoO3METLSyqk638IGGgD/byVfEHdGiDy+hv7ulcSDLpGxgGH5qKKlI1nC0k
 lRN4lqZtKhonQ==
Subject: Re: [GIT PULL] user namespace updates for v5.12-rc1
From: pr-tracker-bot@kernel.org
In-Reply-To: <m1o8gkrl41.fsf@fess.ebiederm.org>
References: <m1o8gkrl41.fsf@fess.ebiederm.org>
X-PR-Tracked-List-Id: Linux Containers <containers.lists.linuxfoundation.org>
X-PR-Tracked-Message-Id: <m1o8gkrl41.fsf@fess.ebiederm.org>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git
 userns-for-v5.12
X-PR-Tracked-Commit-Id: 95ebabde382c371572297915b104e55403674e73
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 7b0b78df9cca7344960decf3a16805e8378a43b7
Message-Id: <161404520682.2827.11513983365562569973.pr-tracker-bot@kernel.org>
Date: Tue, 23 Feb 2021 01:53:26 +0000
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Containers <containers@lists.linux-foundation.org>,
 Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org,
 "Andrew G. Morgan" <morgan@kernel.org>
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
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

The pull request you sent on Tue, 16 Feb 2021 11:14:06 -0600:

> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git userns-for-v5.12

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/7b0b78df9cca7344960decf3a16805e8378a43b7

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
