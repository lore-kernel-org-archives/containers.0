Return-Path: <SRS0=82Ss=DT=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1E2BC43457
	for <containers@archiver.kernel.org>; Mon, 12 Oct 2020 05:01:09 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5ED602076D
	for <containers@archiver.kernel.org>; Mon, 12 Oct 2020 05:01:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5ED602076D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 0ACDD8697B;
	Mon, 12 Oct 2020 05:01:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Vq93iPc7+-4e; Mon, 12 Oct 2020 05:01:07 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 5EC59869A5;
	Mon, 12 Oct 2020 05:01:05 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 40EC4C0052;
	Mon, 12 Oct 2020 05:01:05 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 83B37C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 05:01:04 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 69B0B8739E
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 05:01:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id F3S+A6zEBOOk
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 05:01:03 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
 by hemlock.osuosl.org (Postfix) with ESMTPS id A327287359
 for <containers@lists.linux-foundation.org>;
 Mon, 12 Oct 2020 05:01:03 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out01.mta.xmission.com with esmtps (TLS1.2) tls
 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kRpx2-006tER-K0; Sun, 11 Oct 2020 23:00:48 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=x220.xmission.com) by in02.mta.xmission.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256) (Exim 4.87)
 (envelope-from <ebiederm@xmission.com>)
 id 1kRpx1-0005YR-GK; Sun, 11 Oct 2020 23:00:48 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Andy Lutomirski <luto@kernel.org>
References: <20200830143959.rhosiunyz5yqbr35@wittgenstein>
 <20201010042606.GA30062@mail.hallyn.com>
 <20201011205306.GC17441@localhost>
 <CALCETrUZcHNwspz315KFvSPxtK8MmLUPfiN=hCBgx+wqeJe4+g@mail.gmail.com>
Date: Mon, 12 Oct 2020 00:01:09 -0500
In-Reply-To: <CALCETrUZcHNwspz315KFvSPxtK8MmLUPfiN=hCBgx+wqeJe4+g@mail.gmail.com>
 (Andy Lutomirski's message of "Sun, 11 Oct 2020 17:38:41 -0700")
Message-ID: <87h7r0qbqi.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1kRpx1-0005YR-GK; ; ; mid=<87h7r0qbqi.fsf@x220.int.ebiederm.org>;
 ; ; hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ;
 frm=ebiederm@xmission.com; ; ; spf=neutral
X-XM-AID: U2FsdGVkX1+R2TJbmPUBT5o1leUsuv79cH+JtdTcZ2U=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: LPC 2020 Hackroom Session: summary and next steps for isolated
 user namespaces
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Cc: Alexander Mihalicyn <alexander@mihalicyn.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Joseph Christopher Sible <jcsible@cert.org>, Kees Cook <keescook@chromium.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Josh Triplett <josh@joshtriplett.org>, Geoffrey Thomas <geofft@ldpreload.com>,
 Vivek Goyal <vgoyal@redhat.com>,
 =?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?= <mic@digikod.net>,
 Wat Lim <watl@google.com>, Mrunal Patel <mpatel@redhat.com>,
 Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
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

Andy Lutomirski <luto@kernel.org> writes:

> On Sun, Oct 11, 2020 at 1:53 PM Josh Triplett <josh@joshtriplett.org> wrote:
>>
>> On Fri, Oct 09, 2020 at 11:26:06PM -0500, Serge E. Hallyn wrote:
>> > > 3. Find a way to allow setgroups() in a user namespace while keeping
>> > >    in mind the case of groups used for negative access control.
>> > >    This was suggested by Josh Triplett and Geoffrey Thomas. Their idea was to
>> > >    investigate adding a prctl() to allow setgroups() to be called in a user
>> > >    namespace at the cost of restricting paths to the most restrictive
>> > >    permission. So if something is 0707 it needs to be treated as if it's 0000
>> > >    even though the caller is not in its owning group which is used for negative
>> > >    access control (how these new semantics will interact with ACLs will also
>> > >    need to be looked into).
>> >
>> > I should probably think this through more, but for this problem, would it
>> > not suffice to add a new prevgroups grouplist to the struct cred, maybe
>> > struct group_info *locked_groups, and every time an unprivileged task creates
>> > a new user namespace, add all its current groups to this list?
>>
>> So, effectively, you would be allowed to drop permissions, but
>> locked_groups would still be checked for restrictions?
>>
>> That seems like it'd introduce a new level of complexity (a new facet of
>> permission) to manage. Not opposed, but it does seem more complex than
>> just opting out of using groups for negative permissions.
>
> Is there any context other than regular UNIX DAC in which groups can
> act as negative permissions or is this literally just an issue for
> files with a more restrictive group mode than other mode?

Just that.

The ideas kicked around in the conversation were some variant of having
a sysctl that says "This system never uses groups for negative
permissions".

It was also suggested that if the sysctl was set the the permission
checks would be altered such that even if someone tried to set a
negative permission, the more liberal permissions of other would be used
instead.

Given that creating /etc/subgid is effectively opting out of negative
permissions already have a sysctl that says that upfront feels like a
very clean solution.

Eric
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
