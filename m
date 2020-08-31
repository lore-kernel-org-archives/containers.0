Return-Path: <SRS0=Gfcc=CJ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08FEEC433E6
	for <containers@archiver.kernel.org>; Mon, 31 Aug 2020 13:35:15 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B9A8420936
	for <containers@archiver.kernel.org>; Mon, 31 Aug 2020 13:35:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9A8420936
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 96D24866BD;
	Mon, 31 Aug 2020 13:35:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id tdhq2-WwLIus; Mon, 31 Aug 2020 13:35:12 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 5DDBB8669A;
	Mon, 31 Aug 2020 13:35:12 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 4460BC0052;
	Mon, 31 Aug 2020 13:35:12 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B28EAC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 31 Aug 2020 13:35:11 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id AF00585D6E
 for <containers@lists.linux-foundation.org>;
 Mon, 31 Aug 2020 13:35:11 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 7B66SowYRPJQ
 for <containers@lists.linux-foundation.org>;
 Mon, 31 Aug 2020 13:35:11 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out02.mta.xmission.com (out02.mta.xmission.com [166.70.13.232])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 0CD5885D54
 for <containers@lists.linux-foundation.org>;
 Mon, 31 Aug 2020 13:35:11 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out02.mta.xmission.com with esmtps (TLS1.2) tls
 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kCjxk-00AulK-Tp; Mon, 31 Aug 2020 07:35:08 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=x220.xmission.com) by in02.mta.xmission.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256) (Exim 4.87)
 (envelope-from <ebiederm@xmission.com>)
 id 1kCjxj-00006m-Pz; Mon, 31 Aug 2020 07:35:08 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Aleksa Sarai <cyphar@cyphar.com>
References: <87imd2incs.fsf@x220.int.ebiederm.org>
 <CAMp4zn9M783PTkq0q5BV5n2x=4P4ed4F6F9b7p7ex97=_3J0GA@mail.gmail.com>
 <20200831080941.ikc7ltacf6n3q6fm@yavin.dot.cyphar.com>
 <20200831081207.b6kajp5jhcyelwnt@yavin.dot.cyphar.com>
Date: Mon, 31 Aug 2020 08:35:05 -0500
In-Reply-To: <20200831081207.b6kajp5jhcyelwnt@yavin.dot.cyphar.com> (Aleksa
 Sarai's message of "Mon, 31 Aug 2020 18:12:07 +1000")
Message-ID: <87k0xfey5y.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1kCjxj-00006m-Pz; ; ; mid=<87k0xfey5y.fsf@x220.int.ebiederm.org>;
 ; ; hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ;
 frm=ebiederm@xmission.com; ; ; spf=neutral
X-XM-AID: U2FsdGVkX19oRgnd+2fzLmav97NZb2vkyNSf9E6dk4Y=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: Per user rlimits
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Cc: Linux Containers <containers@lists.linux-foundation.org>
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

Aleksa Sarai <cyphar@cyphar.com> writes:

> On 2020-08-31, Aleksa Sarai <asarai@suse.de> wrote:
>> On 2020-08-28, Sargun Dhillon <sargun@sargun.me> wrote:
>> > On Fri, Aug 28, 2020 at 12:29 PM Eric W. Biederman
>> > <ebiederm@xmission.com> wrote:
>> > > Just to scope how much work it would be to fix rlimits
>> > > so they are not a problem for user namespaces I took a quick
>> > > survey.
>> > >
>> > > The rlimits can be found in
>> > > include/uapi/asm-generic/resource.h
>> > >
>> > > There are a total of 16 rlimits.
>> > > There are only 4 rlimits that are enforced at anything other
>> > > than process granularity.
>> > >
>> > > RLIMIT_NPROC
>> > > RLIMIT_MEMLOCK
>> > > RLIMIT_SIGPENDING
>> > > RLIMIT_MSGQUEUE
>> > >
>> > > So it should not be difficult to fix those rlimits.
>> > 
>> > What are your proposed semantics for what the "fix" would look like? Or
>> > are you saying that once we take on Christian's proposal of 64-bit kuid
>> > they would be trivial to fix? I think the reason we didn't move forward with
>> > fixing it is the only real thing we could agree upon is an rlimit namespace,
>> 
>> From memory, we did briefly discuss how this would work in the call. I
>> believe the basic idea was that the host rlimit would act as a maximum
>> setting but there would be an optional lower limit that a user namespace
>> could set and would be accounted separately. That way containers
>> wouldn't interfere with each others' rlimit settings. I imagine this
>> would be nested with user namespaces and presumable means that rlimit
>> would now be attached to userns directly.
>> 
>> (But I might be misremembering the details of the proposal. I do
>> remember Eric mentioning that the "maximum namespaces" sysctl semantics
>> were a useful model to look at.)
>> 
>> > and then you get into a question of why do these even exist, and should
>> > they just be cgroup(v2) controllers, and should calling setrlimit just
>> > be a wrapper around a cgroup(v2) controller that has a map of
>> > uid -> limit?
>> 
>> To mirror what I said when this came up in the actual discussion, the
>> reason why we don't have cgroups for all of these things is that some of
>> those limits aren't "real resources" and arguably should all be managed
>> through kmemcg policies.
>> 
>> Right after getting the pids cgroup controller merged, I did mention
>> adding controllers for the other rlimits and Tejun said that they didn't
>> make sense to add ([1] is one of the responses I found through a quick
>> search). The only reason the pids controller was merged is that you
>> could still fork-bomb a system even with modest kmemcg limits.
>> 
>> [1]: https://lore.kernel.org/lkml/20150227114940.GB3964@htj.duckdns.org/
>
> [2] is a more explicit NACK from Tejun in that thread.
>
> [2]: https://lore.kernel.org/lkml/20150227170640.GK3964@htj.duckdns.org/

Right now in /proc/sys/user we have a number of other recursive limits.
So that is the infrastructure I am proposing that we reuse.

Assuming doing so does not cause real world performance issue.


Fundamentally we need to change rlimits if are going to have multiple uids
without root privileges as having multiple uids allows you to escape
rlimits.


I am very confused about what cgroups have become after they were
proposed.  Some of what cgroups are is good, some of what cgroups are is
very awkward.  What cgroups are not is a nice file system based API
on top of OpenVZ beancounters, that plays well with containers.


So for where it makes sense for rlimits and the like I am happy to
include these kinds of limits into user namespaces.  Mostly I am
expecting we aim this functionality at the case where one application
goes crazy that craziness is detected by hitting the limit.  By doing
that we can now things are bad without bringing down the entire system.


It is not the nuanced control that cgroups can provide when setup
properly but it is enough to keep things working, and it is effectively
what rlimits provide today.

Eric
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
