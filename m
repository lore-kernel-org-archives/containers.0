Return-Path: <SRS0=Ilr0=DR=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDCDAC433DF
	for <containers@archiver.kernel.org>; Sat, 10 Oct 2020 04:26:14 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1C78021D41
	for <containers@archiver.kernel.org>; Sat, 10 Oct 2020 04:26:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C78021D41
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hallyn.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 98A1887850;
	Sat, 10 Oct 2020 04:26:13 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1D2vthgIsXRL; Sat, 10 Oct 2020 04:26:12 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id DA78D8784C;
	Sat, 10 Oct 2020 04:26:12 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A64C7C016F;
	Sat, 10 Oct 2020 04:26:12 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id BAF56C0051
 for <containers@lists.linux-foundation.org>;
 Sat, 10 Oct 2020 04:26:10 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 9A538203EB
 for <containers@lists.linux-foundation.org>;
 Sat, 10 Oct 2020 04:26:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 4KBBhf-bYpjt
 for <containers@lists.linux-foundation.org>;
 Sat, 10 Oct 2020 04:26:09 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
 by silver.osuosl.org (Postfix) with ESMTPS id CD78F203E9
 for <containers@lists.linux-foundation.org>;
 Sat, 10 Oct 2020 04:26:08 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
 id 9A31682C; Fri,  9 Oct 2020 23:26:06 -0500 (CDT)
Date: Fri, 9 Oct 2020 23:26:06 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: LPC 2020 Hackroom Session: summary and next steps for isolated
 user namespaces
Message-ID: <20201010042606.GA30062@mail.hallyn.com>
References: <20200830143959.rhosiunyz5yqbr35@wittgenstein>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20200830143959.rhosiunyz5yqbr35@wittgenstein>
User-Agent: Mutt/1.9.4 (2018-02-28)
Cc: Alexander Mihalicyn <alexander@mihalicyn.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Joseph Christopher Sible <jcsible@cert.org>, Kees Cook <keescook@chromium.org>,
 linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org,
 Josh Triplett <josh@joshtriplett.org>, Vivek Goyal <vgoyal@redhat.com>,
 Andy Lutomirski <luto@amacapital.net>,
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

> 3. Find a way to allow setgroups() in a user namespace while keeping
>    in mind the case of groups used for negative access control.
>    This was suggested by Josh Triplett and Geoffrey Thomas. Their idea was to
>    investigate adding a prctl() to allow setgroups() to be called in a user
>    namespace at the cost of restricting paths to the most restrictive
>    permission. So if something is 0707 it needs to be treated as if it's 0000
>    even though the caller is not in its owning group which is used for negative
>    access control (how these new semantics will interact with ACLs will also
>    need to be looked into).

I should probably think this through more, but for this problem, would it
not suffice to add a new prevgroups grouplist to the struct cred, maybe
struct group_info *locked_groups, and every time an unprivileged task creates
a new user namespace, add all its current groups to this list?
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
