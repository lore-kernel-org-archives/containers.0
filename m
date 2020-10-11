Return-Path: <SRS0=u+zM=DS=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BABBC433DF
	for <containers@archiver.kernel.org>; Sun, 11 Oct 2020 20:53:29 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9BD1220678
	for <containers@archiver.kernel.org>; Sun, 11 Oct 2020 20:53:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BD1220678
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joshtriplett.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 3F26285641;
	Sun, 11 Oct 2020 20:53:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zTBprmmSrGBS; Sun, 11 Oct 2020 20:53:26 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 678D98583F;
	Sun, 11 Oct 2020 20:53:26 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3ED77C0052;
	Sun, 11 Oct 2020 20:53:26 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D79FFC0051
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 20:53:24 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id C231A8756A
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 20:53:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id NzLOEihq82qD
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 20:53:23 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net
 [217.70.183.198])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 2885087568
 for <containers@lists.linux-foundation.org>;
 Sun, 11 Oct 2020 20:53:22 +0000 (UTC)
X-Originating-IP: 67.5.25.97
Received: from localhost (unknown [67.5.25.97])
 (Authenticated sender: josh@joshtriplett.org)
 by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 499F2C0004;
 Sun, 11 Oct 2020 20:53:08 +0000 (UTC)
Date: Sun, 11 Oct 2020 13:53:06 -0700
From: Josh Triplett <josh@joshtriplett.org>
To: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: LPC 2020 Hackroom Session: summary and next steps for isolated
 user namespaces
Message-ID: <20201011205306.GC17441@localhost>
References: <20200830143959.rhosiunyz5yqbr35@wittgenstein>
 <20201010042606.GA30062@mail.hallyn.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20201010042606.GA30062@mail.hallyn.com>
Cc: Alexander Mihalicyn <alexander@mihalicyn.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Joseph Christopher Sible <jcsible@cert.org>, Kees Cook <keescook@chromium.org>,
 containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
 Vivek Goyal <vgoyal@redhat.com>, Andy Lutomirski <luto@amacapital.net>,
 "Eric W. Biederman" <ebiederm@xmission.com>,
 =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
 Wat Lim <watl@google.com>, Mrunal Patel <mpatel@redhat.com>,
 Pavel Tikhomirov <ptikhomirov@virtuozzo.com>,
 Geoffrey Thomas <geofft@ldpreload.com>
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

On Fri, Oct 09, 2020 at 11:26:06PM -0500, Serge E. Hallyn wrote:
> > 3. Find a way to allow setgroups() in a user namespace while keeping
> >    in mind the case of groups used for negative access control.
> >    This was suggested by Josh Triplett and Geoffrey Thomas. Their idea was to
> >    investigate adding a prctl() to allow setgroups() to be called in a user
> >    namespace at the cost of restricting paths to the most restrictive
> >    permission. So if something is 0707 it needs to be treated as if it's 0000
> >    even though the caller is not in its owning group which is used for negative
> >    access control (how these new semantics will interact with ACLs will also
> >    need to be looked into).
> 
> I should probably think this through more, but for this problem, would it
> not suffice to add a new prevgroups grouplist to the struct cred, maybe
> struct group_info *locked_groups, and every time an unprivileged task creates
> a new user namespace, add all its current groups to this list?

So, effectively, you would be allowed to drop permissions, but
locked_groups would still be checked for restrictions?

That seems like it'd introduce a new level of complexity (a new facet of
permission) to manage. Not opposed, but it does seem more complex than
just opting out of using groups for negative permissions.
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
