Return-Path: <SRS0=bTwc=D2=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A56CC43457
	for <containers@archiver.kernel.org>; Mon, 19 Oct 2020 12:12:58 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EE75A22268
	for <containers@archiver.kernel.org>; Mon, 19 Oct 2020 12:12:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="VRMpkG6W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE75A22268
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 3DDBD20428;
	Mon, 19 Oct 2020 12:12:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id WWAaZNjVx1ls; Mon, 19 Oct 2020 12:12:55 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 678F920018;
	Mon, 19 Oct 2020 12:12:55 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 50785C088B;
	Mon, 19 Oct 2020 12:12:55 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C8081C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 12:12:53 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id B5B1620113
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 12:12:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id hsr-CV2VVFLk
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 12:12:52 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by silver.osuosl.org (Postfix) with ESMTPS id 808B320018
 for <containers@lists.linux-foundation.org>;
 Mon, 19 Oct 2020 12:12:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1603109571;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=vLFn62FSJJ9Vs5FkGimI2TzAFRqYEEiOjqjYC0gWRHk=;
 b=VRMpkG6WTJ+cPgQTcScO0dhTH/4gzbZe9IU3/LsfaWU5qiTd++zeN1z/XBnIWpbb3sEt+7
 9CIYYCayeuoH7/PN11JCDYL58l2aj9hIpfTYr4ossUFzacvF5mniq3kwEahWf/2IYD3jSy
 KGq0YkKELneoUIRDf00qPmpHPc4qImY=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-97-eZzeNCW1Nie9g96COdjc6g-1; Mon, 19 Oct 2020 08:12:47 -0400
X-MC-Unique: eZzeNCW1Nie9g96COdjc6g-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com
 [10.5.11.12])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id DEAA364147;
 Mon, 19 Oct 2020 12:12:43 +0000 (UTC)
Received: from localhost (ovpn-115-87.ams2.redhat.com [10.36.115.87])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id EC25B60FC2;
 Mon, 19 Oct 2020 12:12:41 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: LPC 2020 Hackroom Session: summary and next steps for isolated
 user namespaces
References: <20200830143959.rhosiunyz5yqbr35@wittgenstein>
 <20201010042606.GA30062@mail.hallyn.com>
 <20201011205306.GC17441@localhost> <87tuuzv0hl.fsf@redhat.com>
 <20201013124650.GA19668@mail.hallyn.com> <87o8l6qhnz.fsf@redhat.com>
 <20201015143207.GB25286@mail.hallyn.com>
Date: Mon, 19 Oct 2020 14:12:39 +0200
In-Reply-To: <20201015143207.GB25286@mail.hallyn.com> (Serge E. Hallyn's
 message of "Thu, 15 Oct 2020 09:32:07 -0500")
Message-ID: <87ft6act3c.fsf@redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
Cc: Alexander Mihalicyn <alexander@mihalicyn.com>,
 Joseph Christopher Sible <jcsible@cert.org>, Kees Cook <keescook@chromium.org>,
 linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org,
 Josh Triplett <josh@joshtriplett.org>, Vivek Goyal <vgoyal@redhat.com>,
 Andy Lutomirski <luto@amacapital.net>,
 "Eric W. Biederman" <ebiederm@xmission.com>,
 =?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?= <mic@digikod.net>,
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

"Serge E. Hallyn" <serge@hallyn.com> writes:

> On Tue, Oct 13, 2020 at 05:17:36PM +0200, Giuseppe Scrivano wrote:
>> "Serge E. Hallyn" <serge@hallyn.com> writes:
>> 
>> > On Mon, Oct 12, 2020 at 07:05:10PM +0200, Giuseppe Scrivano wrote:
>> >> Josh Triplett <josh@joshtriplett.org> writes:
>> >> 
>> >> > On Fri, Oct 09, 2020 at 11:26:06PM -0500, Serge E. Hallyn wrote:
>> >> >> > 3. Find a way to allow setgroups() in a user namespace while keeping
>> >> >> >    in mind the case of groups used for negative access control.
>> >> >> >    This was suggested by Josh Triplett and Geoffrey Thomas. Their idea was to
>> >> >> >    investigate adding a prctl() to allow setgroups() to be called in a user
>> >> >> >    namespace at the cost of restricting paths to the most restrictive
>> >> >> >    permission. So if something is 0707 it needs to be treated as if it's 0000
>> >> >> >    even though the caller is not in its owning group which is used for negative
>> >> >> >    access control (how these new semantics will interact with ACLs will also
>> >> >> >    need to be looked into).
>> >> >> 
>> >> >> I should probably think this through more, but for this problem, would it
>> >> >> not suffice to add a new prevgroups grouplist to the struct cred, maybe
>> >> >> struct group_info *locked_groups, and every time an unprivileged task creates
>> >> >> a new user namespace, add all its current groups to this list?
>> >> >
>> >> > So, effectively, you would be allowed to drop permissions, but
>> >> > locked_groups would still be checked for restrictions?
>> >> >
>> >> > That seems like it'd introduce a new level of complexity (a new facet of
>> >> > permission) to manage. Not opposed, but it does seem more complex than
>> >> > just opting out of using groups for negative permissions.
>> >> 
>> >> I have played with something similar in the past.  At that time I've
>> >> discussed it only privately with Eric and we agreed it wasn't worth the
>> >> extra complexity:
>> >> 
>> >> https://github.com/giuseppe/linux/commit/7e0701b389c497472d11fab8570c153a414050af
>> >
>> > Hi, you linked the setgroups patch, but do you also have a link to the
>> > attempt which you deemed was not worth it?
>> 
>> it was just part of a private discussion; but was 4 years ago so we can
>> probably revisit and accept the additional complexity since setgroups()
>> is still an issue with user namespaces.
>> 
>> 
>> >> instead of a prctl, I've added a new mode to /proc/PID/setgroups that
>> >> allows setgroups in a userns locking the current gids.
>> >> 
>> >> What do you think about using /proc/PID/setgroups instead of a new
>> >> prctl()?
>> >
>> > It's better than not having it, but two concerns -
>> >
>> > 1. some userspace, especially testsuites, could become confused by the fact
>> > that they can't drop groups no matter how hard they try, since these will all
>> > still show up as regular groups.
>> 
>> I forgot to send a link to a second patch :-) that completes the feature:
>> https://github.com/giuseppe/linux/commit/1c5fe726346b216293a527719e64f34e6297f0c2
>> 
>> When the new mode is used, the gids that are not known in the userns do
>> not show up in userspace.
>
> Ah, right - and of course those gids better not be mapped into the namespace :)
>
> But so, this is the patch you said you agreed was not worth the extra
> complexity?

yes, these two patches are what looked too complex at that time.  The
problem still exists though, we could perhaps reconsider if the
extra-complexity is acceptable to address it.

Regards,
Giuseppe

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
