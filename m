Return-Path: <SRS0=hmK5=JT=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5123DC433B4
	for <containers@archiver.kernel.org>; Thu, 22 Apr 2021 09:18:16 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C0D4C61459
	for <containers@archiver.kernel.org>; Thu, 22 Apr 2021 09:18:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0D4C61459
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id 4DC8783DFD;
	Thu, 22 Apr 2021 09:18:15 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 8GacyJMnVoy9; Thu, 22 Apr 2021 09:18:14 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp1.osuosl.org (Postfix) with ESMTP id 22ECF83D7E;
	Thu, 22 Apr 2021 09:18:14 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 08958C000E;
	Thu, 22 Apr 2021 09:18:14 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 3C214C000B
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Apr 2021 09:18:13 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 2603740145
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Apr 2021 09:18:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp2.osuosl.org (amavisd-new);
 dkim=pass (1024-bit key) header.d=redhat.com
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id hJibwS3UuAZi
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Apr 2021 09:18:12 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by smtp2.osuosl.org (Postfix) with ESMTPS id 2C8F440112
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Apr 2021 09:18:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1619083091;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=g1baHM7nEka/Zfb1PwxTxoIZrmYwNdCkYeX0BTAU5Ho=;
 b=UR79NFdDTdJiOT+7hZUv4016evwQQekZIUsnXHLRnojkq6FoegNmN0sZrUTR6OC1xhk8dD
 VXKL0/akt2tiWoLQlc2XjgOz2M8HY+9D1CWSjmMGiik0sjAiVHxcRAx/8f4aH69y7eQHzC
 9tDUuR4g9o3yYAvTF0pPrYBJI5xdY08=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-261-owvUNEI3Moi9N-EP2QcMeQ-1; Thu, 22 Apr 2021 05:18:07 -0400
X-MC-Unique: owvUNEI3Moi9N-EP2QcMeQ-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com
 [10.5.11.13])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 97FAD343A7;
 Thu, 22 Apr 2021 09:18:04 +0000 (UTC)
Received: from localhost (ovpn-113-147.ams2.redhat.com [10.36.113.147])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id C151A60938;
 Thu, 22 Apr 2021 09:18:02 +0000 (UTC)
From: Giuseppe Scrivano <gscrivan@redhat.com>
To: Snaipe <snaipe@arista.com>
Subject: Re: LPC 2020 Hackroom Session: summary and next steps for isolated
 user namespaces
References: <87ft6act3c.fsf@redhat.com>
 <20210421172714.912119-1-snaipe@arista.com>
Date: Thu, 22 Apr 2021 11:18:01 +0200
In-Reply-To: <20210421172714.912119-1-snaipe@arista.com> (snaipe@arista.com's
 message of "Wed, 21 Apr 2021 19:27:14 +0200")
Message-ID: <87h7jyvfsm.fsf@redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.2 (gnu/linux)
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
Cc: alexander@mihalicyn.com, jcsible@cert.org, watl@google.com,
 keescook@chromium.org, containers@lists.linux-foundation.org,
 josh@joshtriplett.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org,
 cyphar@cyphar.com, ebiederm@xmission.com, mic@digikod.net,
 christian.brauner@ubuntu.com, luto@amacapital.net, mpatel@redhat.com,
 ptikhomirov@virtuozzo.com, geofft@ldpreload.com
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

Snaipe <snaipe@arista.com> writes:

> "Giuseppe Scrivano" <gscrivan@redhat.com> writes:
>>>> >> instead of a prctl, I've added a new mode to /proc/PID/setgroups that
>>>> >> allows setgroups in a userns locking the current gids.
>>>> >> 
>>>> >> What do you think about using /proc/PID/setgroups instead of a new
>>>> >> prctl()?
>>>> >
>>>> > It's better than not having it, but two concerns -
>>>> >
>>>> > 1. some userspace, especially testsuites, could become confused by the fact
>>>> > that they can't drop groups no matter how hard they try, since these will all
>>>> > still show up as regular groups.
>>>> 
>>>> I forgot to send a link to a second patch :-) that completes the feature:
>>>> https://github.com/giuseppe/linux/commit/1c5fe726346b216293a527719e64f34e6297f0c2
>>>> 
>>>> When the new mode is used, the gids that are not known in the userns do
>>>> not show up in userspace.
>>>
>>> Ah, right - and of course those gids better not be mapped into the namespace :)
>>>
>>> But so, this is the patch you said you agreed was not worth the extra
>>> complexity?
>>
>> yes, these two patches are what looked too complex at that time.  The
>> problem still exists though, we could perhaps reconsider if the
>> extra-complexity is acceptable to address it.
>
> Hey Folks, sorry for necro-bumping, but I've found this discussion
> while searching for this specific issue, and it seems like the most
> recent relevant discussion on the matter. I'd like to chime in with
> our personal experience.
>
> We have a tool[1] that allows unprivileged use of namespaces
> (when using a userns, which is the default).
>
> The primary use-case of said tool is lightweight containerization,
> but we're also using it for other mundane usages, like a better
> substitute for fakeroot to build and package privileged software
> (e.g. sudo or ping, which needs to be installed with special
> capabilities) unprivileged, or to copy file trees that are owned by
> the user or sub-ids.
>
> For the first use-case, it's always safe to drop unmapped groups,
> because the target rootfs is always owned by the user or its sub-ids.
>
> For the other use-cases, this is more problematic, as you're all
> well-aware of. Our position right now is that the tool will always
> allow setgroups in user namespace, and that it's not safe to use on
> systems that rely on negative access groups.
>
> I think that something that's not mentioned is that if a user setgroups
> to a fixed list of subgids, dropping all unmapped gids, they don't just
> gain the ability to access these negative-access files, they also lose
> legitimate access to files that their unmapped groups allow them to
> access. This is fine for our first use-case, but a bit surprising for
> the second one -- and since setgroups never lets us keep unmapped gids,
> we have no way to keep these desired groups.
>
> From a first glance, a sysctl that explicitly controls that would not
> address the above problem, but keeping around the original group list
> of the owner of the user ns would have the desired semantics.
>
> Giuseppe's patch seems to address this use case, which would personally
> make me very happy.
>
> [1]: https://github.com/aristanetworks/bst

thanks for the feedback.  We are still facing the issue with rootless
Podman, and these patches (listed here so you won't need to dig into archives):

https://github.com/giuseppe/linux/commit/7e0701b389c497472d11fab8570c153a414050af
https://github.com/giuseppe/linux/commit/1c5fe726346b216293a527719e64f34e6297f0c2

would solve the issue for us as well and we can use setgroups within a
user namespace in a safe way.

Any comments on this approach?  Could we move forward with it?

Regards,
Giuseppe

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
