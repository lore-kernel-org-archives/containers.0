Return-Path: <SRS0=hje2=JZ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DB9AC433B4
	for <containers@archiver.kernel.org>; Wed, 28 Apr 2021 14:56:48 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 96A0661151
	for <containers@archiver.kernel.org>; Wed, 28 Apr 2021 14:56:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96A0661151
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id D8BC3400C1;
	Wed, 28 Apr 2021 14:56:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6jvYd5D-3kRY; Wed, 28 Apr 2021 14:56:43 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp2.osuosl.org (Postfix) with ESMTP id DC1CD400D6;
	Wed, 28 Apr 2021 14:56:42 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id BCAC6C0022;
	Wed, 28 Apr 2021 14:56:42 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [IPv6:2605:bc80:3010::133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D99EBC0001
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 14:56:40 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id BC1AC400C1
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 14:56:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id P1Nlt1AOrrMi
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 14:56:39 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by smtp2.osuosl.org (Postfix) with ESMTPS id DF88040598
 for <containers@lists.linux-foundation.org>;
 Wed, 28 Apr 2021 14:56:39 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 9D139601FE;
 Wed, 28 Apr 2021 14:56:37 +0000 (UTC)
Date: Wed, 28 Apr 2021 16:56:34 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: containers@lists.linux.dev, containers@lists.linux-foundation.org,
 Konstantin Ryabitsev <konstantin@linuxfoundation.org>
Subject: Re: Containers Development List Migration
Message-ID: <20210428145634.uameekhs5ulikxnn@wittgenstein>
References: <20210416110030.2jwljvcpcuq2xao5@wittgenstein>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210416110030.2jwljvcpcuq2xao5@wittgenstein>
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

On Fri, Apr 16, 2021 at 01:00:36PM +0200, Christian Brauner wrote:
> Hello everyone,
> 
> The good people running kernel.org have put a lot of effort into better
> tooling for the kernel community. This covers handling patches for
> maintainers and developers via the new b4 tool, archiving all our
> mailing lists in the new public-inbox format, better spam filtering,
> non-delayed delivery of patches. Part of these efforts is to ultimately
> run all our kernel development mailing lists under the kernel.org
> umbrella 
> People interested in details can re-read the threads on [1] and
> subscribe to the workflows mailing list at [2] or peruse the articles
> published about this initiative on LWN.
> 
> In the coming time mailing lists will slowly start migrating to the new
> lists.linux.dev domain run by the kernel community under the kernel.org
> umbrella. Some details about the new lists can be found in the great
> blogpost at [6].
> The migration has already happened for a few lists (ksummit-discuss,
> linux-staging, tools) others are in the process of doing so right now
> and it will ultimately take on all the duties that vger (and others)
> once fulfilled including lkml itself.
> 
> Last year I already asked Konstantin to start archiving the containers
> development list through lore.kernel.org at [3] and sent out a
> corresponding announcement to this list [4].
> 
> We will now initiate the move of the mailing list to
> 
>         containers@lists.linux.dev
> 
> Given the low-volume of this list the move is scheduled to happen on
> 
>         01 May 2021
> 
> Note, there is no need for you to do anything now.
> 
> The migration is coordinated with Konstantin Ryabitsev who leads this
> effort (I'm sure most of you know him from his excellent blogposts on
> tooling at [5].). Disruptions will be kept to a minimum.
> 
> # Steps on May 1:
> 
>   - We will switch the archives for lore.kernel.org/containers to be
>     from the new list.
>   - All existing subscribers of the old list will be subscribed to the
>     new list.
>   - Archiving will be enabled for the new list.
>   - The list will show up at lists.linux.dev with details about
>     subscription, unsubscription etc.
>   - An autoresponder will be setup on the old list notifying anyone
>     still posting there that the list has moved. The old list will
>     likely stick around for a few months.
> 
> Konstantin will announce when the move has finished on May 1 with a mail
> to the new list. Until May 1 I will send a few reminders about the
> upcoming move with people Cced (as done in this mail) that have sent
> patches in the last couple of weeks.

Please note that this change is just a few days away. Starting on:

        01 May 2021

patchsets should be sent to:

        containers@lists.linux.dev

Subscribers without any active patchsets don't need to do anything
(apart from maybe updating any potential mail filters :)). Please
re-read the mail for information about how the switch will happen.

> 
> Thanks!
> Christian
> 
> [1]: https://lore.kernel.org/workflows/
> [2]: workflows@vger.kernel.org
> [3]: https://lore.kernel.org/containers/
> [4]: https://lists.linuxfoundation.org/pipermail/containers/2020-August/042030.html
> [5]: https://people.kernel.org/monsieuricon/
> [6]: https://people.kernel.org/monsieuricon/subspace-mailing-list-server
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
