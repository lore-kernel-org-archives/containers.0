Return-Path: <SRS0=BJMF=DW=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EDB4C433DF
	for <containers@archiver.kernel.org>; Thu, 15 Oct 2020 14:32:16 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7F9A522256
	for <containers@archiver.kernel.org>; Thu, 15 Oct 2020 14:32:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F9A522256
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hallyn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id E494A87E34;
	Thu, 15 Oct 2020 14:32:14 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1ommVkazGlzH; Thu, 15 Oct 2020 14:32:12 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B713A87E2D;
	Thu, 15 Oct 2020 14:32:12 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A8E1BC07FF;
	Thu, 15 Oct 2020 14:32:12 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 0CFA3C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 15 Oct 2020 14:32:11 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id F3A148867D
 for <containers@lists.linux-foundation.org>;
 Thu, 15 Oct 2020 14:32:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 3Ti1FynJq2oM
 for <containers@lists.linux-foundation.org>;
 Thu, 15 Oct 2020 14:32:09 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 6B70A8861D
 for <containers@lists.linux-foundation.org>;
 Thu, 15 Oct 2020 14:32:09 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
 id 9C59A1105; Thu, 15 Oct 2020 09:32:07 -0500 (CDT)
Date: Thu, 15 Oct 2020 09:32:07 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Giuseppe Scrivano <gscrivan@redhat.com>
Subject: Re: LPC 2020 Hackroom Session: summary and next steps for isolated
 user namespaces
Message-ID: <20201015143207.GB25286@mail.hallyn.com>
References: <20200830143959.rhosiunyz5yqbr35@wittgenstein>
 <20201010042606.GA30062@mail.hallyn.com>
 <20201011205306.GC17441@localhost> <87tuuzv0hl.fsf@redhat.com>
 <20201013124650.GA19668@mail.hallyn.com>
 <87o8l6qhnz.fsf@redhat.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <87o8l6qhnz.fsf@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Alexander Mihalicyn <alexander@mihalicyn.com>,
 Joseph Christopher Sible <jcsible@cert.org>, Kees Cook <keescook@chromium.org>,
 linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org,
 Josh Triplett <josh@joshtriplett.org>, Vivek Goyal <vgoyal@redhat.com>,
 Geoffrey Thomas <geofft@ldpreload.com>, Andy Lutomirski <luto@amacapital.net>,
 "Eric W. Biederman" <ebiederm@xmission.com>,
 =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
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

On Tue, Oct 13, 2020 at 05:17:36PM +0200, Giuseppe Scrivano wrote:
> "Serge E. Hallyn" <serge@hallyn.com> writes:
> 
> > On Mon, Oct 12, 2020 at 07:05:10PM +0200, Giuseppe Scrivano wrote:
> >> Josh Triplett <josh@joshtriplett.org> writes:
> >> 
> >> > On Fri, Oct 09, 2020 at 11:26:06PM -0500, Serge E. Hallyn wrote:
> >> >> > 3. Find a way to allow setgroups() in a user namespace while keeping
> >> >> >    in mind the case of groups used for negative access control.
> >> >> >    This was suggested by Josh Triplett and Geoffrey Thomas. Their idea was to
> >> >> >    investigate adding a prctl() to allow setgroups() to be called in a user
> >> >> >    namespace at the cost of restricting paths to the most restrictive
> >> >> >    permission. So if something is 0707 it needs to be treated as if it's 0000
> >> >> >    even though the caller is not in its owning group which is used for negative
> >> >> >    access control (how these new semantics will interact with ACLs will also
> >> >> >    need to be looked into).
> >> >> 
> >> >> I should probably think this through more, but for this problem, would it
> >> >> not suffice to add a new prevgroups grouplist to the struct cred, maybe
> >> >> struct group_info *locked_groups, and every time an unprivileged task creates
> >> >> a new user namespace, add all its current groups to this list?
> >> >
> >> > So, effectively, you would be allowed to drop permissions, but
> >> > locked_groups would still be checked for restrictions?
> >> >
> >> > That seems like it'd introduce a new level of complexity (a new facet of
> >> > permission) to manage. Not opposed, but it does seem more complex than
> >> > just opting out of using groups for negative permissions.
> >> 
> >> I have played with something similar in the past.  At that time I've
> >> discussed it only privately with Eric and we agreed it wasn't worth the
> >> extra complexity:
> >> 
> >> https://github.com/giuseppe/linux/commit/7e0701b389c497472d11fab8570c153a414050af
> >
> > Hi, you linked the setgroups patch, but do you also have a link to the
> > attempt which you deemed was not worth it?
> 
> it was just part of a private discussion; but was 4 years ago so we can
> probably revisit and accept the additional complexity since setgroups()
> is still an issue with user namespaces.
> 
> 
> >> instead of a prctl, I've added a new mode to /proc/PID/setgroups that
> >> allows setgroups in a userns locking the current gids.
> >> 
> >> What do you think about using /proc/PID/setgroups instead of a new
> >> prctl()?
> >
> > It's better than not having it, but two concerns -
> >
> > 1. some userspace, especially testsuites, could become confused by the fact
> > that they can't drop groups no matter how hard they try, since these will all
> > still show up as regular groups.
> 
> I forgot to send a link to a second patch :-) that completes the feature:
> https://github.com/giuseppe/linux/commit/1c5fe726346b216293a527719e64f34e6297f0c2
> 
> When the new mode is used, the gids that are not known in the userns do
> not show up in userspace.

Ah, right - and of course those gids better not be mapped into the namespace :)

But so, this is the patch you said you agreed was not worth the extra
complexity?

> > 2. whereas in my lockgroups proposal, lock_groups would only be taken into account
> > for permission denial, this proposal would count for permission grants too.  This
> > means that if I have a group which is permitted to read /foo/topsecret, and I
> > start a program in a new user namespace expecting it to drop that permission,
> > I can't have that, right?  The new program, will always have that permission?
> 
> right.  The new mode I was working on cannot be used to drop granted permissions.
> 
> Giuseppe
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
