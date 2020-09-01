Return-Path: <SRS0=dGYh=CK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5575C433E6
	for <containers@archiver.kernel.org>; Tue,  1 Sep 2020 14:53:49 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7CF2D206FA
	for <containers@archiver.kernel.org>; Tue,  1 Sep 2020 14:53:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CF2D206FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 50A63870BA;
	Tue,  1 Sep 2020 14:53:49 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VTtgsV1wxKIR; Tue,  1 Sep 2020 14:53:48 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id AB40C87089;
	Tue,  1 Sep 2020 14:53:48 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9827FC0052;
	Tue,  1 Sep 2020 14:53:48 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 54865C0051
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Sep 2020 14:53:47 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 3B98A20424
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Sep 2020 14:53:47 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 8hSImMjUSbhC
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Sep 2020 14:53:45 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out02.mta.xmission.com (out02.mta.xmission.com [166.70.13.232])
 by silver.osuosl.org (Postfix) with ESMTPS id D69AA20417
 for <containers@lists.linux-foundation.org>;
 Tue,  1 Sep 2020 14:53:45 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out02.mta.xmission.com with esmtps (TLS1.2) tls
 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kD7fE-00D94g-F2; Tue, 01 Sep 2020 08:53:36 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=x220.xmission.com) by in02.mta.xmission.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256) (Exim 4.87)
 (envelope-from <ebiederm@xmission.com>)
 id 1kD7fD-0003RC-Lv; Tue, 01 Sep 2020 08:53:36 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: "Serge E. Hallyn" <serge@hallyn.com>
References: <87zh6eiyv7.fsf@x220.int.ebiederm.org>
 <20200901060631.GA5193@mail.hallyn.com>
Date: Tue, 01 Sep 2020 09:53:31 -0500
In-Reply-To: <20200901060631.GA5193@mail.hallyn.com> (Serge E. Hallyn's
 message of "Tue, 1 Sep 2020 01:06:31 -0500")
Message-ID: <871rjleefo.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1kD7fD-0003RC-Lv; ; ; mid=<871rjleefo.fsf@x220.int.ebiederm.org>;
 ; ; hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ;
 frm=ebiederm@xmission.com; ; ; spf=neutral
X-XM-AID: U2FsdGVkX18oxE2STrWK3FNRPWGx1lLEWK/LwZLI6zg=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: Use cases for multiple uid mapping?
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
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

"Serge E. Hallyn" <serge@hallyn.com> writes:

> On Fri, Aug 28, 2020 at 10:17:16AM -0500, Eric W. Biederman wrote:
>> 
>> We had a discussion in the hackroom at LPC talking about use cases for
>> a shiftfs style setup where there are different mappings of uids to
>> disk.
>> 
>> In the discussion we had a couple of ideas of kernel developments
>> we should look at that address some of these.
>> 
>> - Fix rlimits in user namespaces (This potentially allows multiple
>>   containers to run with the same userids simplifying the mapping
>>   problem).
>> 
>> - Look at extending kuid_t to 64bits and using the highbits to
>>   implement uids that are private to user namespaces and don't
>>   map out.
>>   
>> - Look at ways for allowing setgroups unprivileged.
>> 
>> 
>> Together this has the potential that the existing uid & gid mappings
>> will be able to function the same as the proposed fusid mappings. Fingers crossed.
>> 
>> 
>> I had some problems with audio and a lot of people were talking
>> quickly.  So I did not manage to capture everyone's use cases.   And I
>> definitely was not able to see how everyone's use cases interacted with
>> the changes we are looking at.
>> 
>> I know for certain I missed Serge's usecase (apologies).
>> 
>> Can people follow up to this and report their use cases?
>
> Sorry - I'll do so later this week.

Thank you.

I know we have the OCI use case of overlayfs and sharing storage
between containers.

I know we have the lxc case of not wanting to be strangled by ulimits.
So not using the same uid between containers even when it is logically
the same users.

I know the brainstorming was going a lot of different directions and I
piped up and said that we should probably focus on handling the stranger
cases with fuse mounts, and the other capabilities we have now.

It really will be valuable to understand the other cases so we don't
code ourselves into a corner that only works for the most vocal of the
developers.

Eric
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
