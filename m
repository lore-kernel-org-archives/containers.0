Return-Path: <SRS0=dGYh=CK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19A3DC433E7
	for <containers@archiver.kernel.org>; Tue,  1 Sep 2020 06:07:45 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C35E2208DB
	for <containers@archiver.kernel.org>; Tue,  1 Sep 2020 06:07:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C35E2208DB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hallyn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 8C30D86EA6;
	Tue,  1 Sep 2020 06:07:44 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KwRiTozlADmx; Tue,  1 Sep 2020 06:07:41 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id ADE4586EAA;
	Tue,  1 Sep 2020 06:07:41 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 8B1DBC088B;
	Tue,  1 Sep 2020 06:07:41 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id BA495C0052
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Sep 2020 06:07:39 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id A15E2203BB
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Sep 2020 06:07:39 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id iVB1Apewa5PL
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Sep 2020 06:07:33 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
 by silver.osuosl.org (Postfix) with ESMTPS id 99D8520345
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Sep 2020 06:06:33 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
 id C2E9A82A; Tue,  1 Sep 2020 01:06:31 -0500 (CDT)
Date: Tue, 1 Sep 2020 01:06:31 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: Use cases for multiple uid mapping?
Message-ID: <20200901060631.GA5193@mail.hallyn.com>
References: <87zh6eiyv7.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <87zh6eiyv7.fsf@x220.int.ebiederm.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Linux Containers <containers@lists.linux-foundation.org>,
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

On Fri, Aug 28, 2020 at 10:17:16AM -0500, Eric W. Biederman wrote:
> 
> We had a discussion in the hackroom at LPC talking about use cases for
> a shiftfs style setup where there are different mappings of uids to
> disk.
> 
> In the discussion we had a couple of ideas of kernel developments
> we should look at that address some of these.
> 
> - Fix rlimits in user namespaces (This potentially allows multiple
>   containers to run with the same userids simplifying the mapping
>   problem).
> 
> - Look at extending kuid_t to 64bits and using the highbits to
>   implement uids that are private to user namespaces and don't
>   map out.
>   
> - Look at ways for allowing setgroups unprivileged.
> 
> 
> Together this has the potential that the existing uid & gid mappings
> will be able to function the same as the proposed fusid mappings. Fingers crossed.
> 
> 
> I had some problems with audio and a lot of people were talking
> quickly.  So I did not manage to capture everyone's use cases.   And I
> definitely was not able to see how everyone's use cases interacted with
> the changes we are looking at.
> 
> I know for certain I missed Serge's usecase (apologies).
> 
> Can people follow up to this and report their use cases?

Sorry - I'll do so later this week.

> There are some real challenges and I would like to see if we
> can solve them, while avoiding scary problems like changing
> uids on write.
> 
> Eric
> 
> 
> 
> 
> 
> 
> 
>   
> 
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
