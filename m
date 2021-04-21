Return-Path: <SRS0=soTF=JS=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24A66C433ED
	for <containers@archiver.kernel.org>; Wed, 21 Apr 2021 17:27:26 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8937660FDB
	for <containers@archiver.kernel.org>; Wed, 21 Apr 2021 17:27:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8937660FDB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lists.linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id 2C3A0400CE;
	Wed, 21 Apr 2021 17:27:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mSN9JAx1TE3g; Wed, 21 Apr 2021 17:27:21 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp2.osuosl.org (Postfix) with ESMTP id 8D680405C0;
	Wed, 21 Apr 2021 17:27:21 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6DA3DC000F;
	Wed, 21 Apr 2021 17:27:21 +0000 (UTC)
Received: from smtp4.osuosl.org (smtp4.osuosl.org [IPv6:2605:bc80:3010::137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id DEBEBC000B
 for <containers@lists.linux-foundation.org>;
 Wed, 21 Apr 2021 17:27:20 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp4.osuosl.org (Postfix) with ESMTP id BF61040E59
 for <containers@lists.linux-foundation.org>;
 Wed, 21 Apr 2021 17:27:20 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp4.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=arista.com
Received: from smtp4.osuosl.org ([127.0.0.1])
 by localhost (smtp4.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id JjnVEfIU10fU
 for <containers@lists.linux-foundation.org>;
 Wed, 21 Apr 2021 17:27:19 +0000 (UTC)
X-Greylist: whitelisted by SQLgrey-1.8.0
Received: from mail-wr1-x435.google.com (mail-wr1-x435.google.com
 [IPv6:2a00:1450:4864:20::435])
 by smtp4.osuosl.org (Postfix) with ESMTPS id 3C39640262
 for <containers@lists.linux-foundation.org>;
 Wed, 21 Apr 2021 17:27:19 +0000 (UTC)
Received: by mail-wr1-x435.google.com with SMTP id r7so30158749wrm.1
 for <containers@lists.linux-foundation.org>;
 Wed, 21 Apr 2021 10:27:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com; s=google;
 h=from:to:cc:subject:date:message-id:in-reply-to:references
 :mime-version:content-transfer-encoding;
 bh=y5rB5hdeendPXtZ8kWukMNJqwT+C7isho8ILaV2Ei6o=;
 b=Fju+oMaW0JZE6NP+ZWRAXWvRXIbNMJ9AkdGWpnEpT9MFfQHRXAG+fvbY6kVNCuMvmv
 LojzxCPUkXSZnjVfw3UvD7H4ysLctuaUpYoHZ/9dwKF5gzsUpBpIPzwOVx7YB7ZzREFS
 lkcuBdEi6ByJEScWZxyesm7cbHU2sFimUGBSnsQTWP2JecS3Y2ig6fPqejI1iGujBQNq
 OFhCdy8aLJe/HGzUTxD2HQV0nZcpLpRH64kdNBmgML8Zphob/Xf6HbNgTUZ9kGUerWpb
 2SZZFRJuzVDmvASSSVdqdSbg//3smMc1lo3PZ7NQaF3noICRnSBSfeo4lk742ndCMj0o
 +e/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
 :references:mime-version:content-transfer-encoding;
 bh=y5rB5hdeendPXtZ8kWukMNJqwT+C7isho8ILaV2Ei6o=;
 b=eI6BGW1cvhuoLAfRib4+cPP6uuDivbO1NdHz9roAn3AXSlmzX77585LAz6Nx7avHOV
 uZ47uCFra7XlucagGj+RoFdmUbEurNAilBCiWDwz2MduRQv4OoIfTykydwpD1CKJitcj
 WAG7y7b+Hg4j7vTK4uFdDD4qoAfNhEYOJ+4SWQocy9yRyFgY1PGTcADHAqNxhX6G1qTj
 YuwsMkhkXi/Fekc5cbPsDcSy11wvn25/oh03BRVAPsXkTLvZzrJTOiXMZSfW1zZc9Yml
 7fMHoIJxtULNted/vRMeDItEMoxGVXzh6mLLpsDSOlJ5hN3jTK23r3lg65aealHt9cPP
 SQzw==
X-Gm-Message-State: AOAM531JPiTC45tTj33Eko4oygUgetN+rEjicVU7vRPS3JoWcfMQBZOU
 W5xy5cW/z66htjLQYCVLOrvEZA==
X-Google-Smtp-Source: ABdhPJzJkAvQ2xZ2smIGZxg2awxu3YJLjsW5vTvBTIz7iwmQHISbAOifURiuXOjt6TiYzZyHioknTA==
X-Received: by 2002:a5d:528a:: with SMTP id c10mr6127292wrv.333.1619026037338; 
 Wed, 21 Apr 2021 10:27:17 -0700 (PDT)
Received: from snaipe-arista.infra.corp.arista.io
 (188-141-36-148.dynamic.upc.ie. [188.141.36.148])
 by smtp.gmail.com with ESMTPSA id m15sm110805wrx.32.2021.04.21.10.27.16
 (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
 Wed, 21 Apr 2021 10:27:17 -0700 (PDT)
To: gscrivan@redhat.com
Subject: Re: LPC 2020 Hackroom Session: summary and next steps for isolated
 user namespaces
Date: Wed, 21 Apr 2021 19:27:14 +0200
Message-Id: <20210421172714.912119-1-snaipe@arista.com>
X-Mailer: git-send-email 2.31.1
In-Reply-To: <87ft6act3c.fsf@redhat.com>
References: <87ft6act3c.fsf@redhat.com>
MIME-Version: 1.0
Cc: alexander@mihalicyn.com, jcsible@cert.org, watl@google.com,
 keescook@chromium.org, containers@lists.linux-foundation.org,
 josh@joshtriplett.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org,
 cyphar@cyphar.com, Snaipe <snaipe@arista.com>, ebiederm@xmission.com,
 mic@digikod.net, christian.brauner@ubuntu.com, luto@amacapital.net,
 mpatel@redhat.com, ptikhomirov@virtuozzo.com, geofft@ldpreload.com
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
From: Snaipe via Containers <containers@lists.linux-foundation.org>
Reply-To: Snaipe <snaipe@arista.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

"Giuseppe Scrivano" <gscrivan@redhat.com> writes:
>>> >> instead of a prctl, I've added a new mode to /proc/PID/setgroups that
>>> >> allows setgroups in a userns locking the current gids.
>>> >> 
>>> >> What do you think about using /proc/PID/setgroups instead of a new
>>> >> prctl()?
>>> >
>>> > It's better than not having it, but two concerns -
>>> >
>>> > 1. some userspace, especially testsuites, could become confused by the fact
>>> > that they can't drop groups no matter how hard they try, since these will all
>>> > still show up as regular groups.
>>> 
>>> I forgot to send a link to a second patch :-) that completes the feature:
>>> https://github.com/giuseppe/linux/commit/1c5fe726346b216293a527719e64f34e6297f0c2
>>> 
>>> When the new mode is used, the gids that are not known in the userns do
>>> not show up in userspace.
>>
>> Ah, right - and of course those gids better not be mapped into the namespace :)
>>
>> But so, this is the patch you said you agreed was not worth the extra
>> complexity?
>
> yes, these two patches are what looked too complex at that time.  The
> problem still exists though, we could perhaps reconsider if the
> extra-complexity is acceptable to address it.

Hey Folks, sorry for necro-bumping, but I've found this discussion
while searching for this specific issue, and it seems like the most
recent relevant discussion on the matter. I'd like to chime in with
our personal experience.

We have a tool[1] that allows unprivileged use of namespaces
(when using a userns, which is the default).

The primary use-case of said tool is lightweight containerization,
but we're also using it for other mundane usages, like a better
substitute for fakeroot to build and package privileged software
(e.g. sudo or ping, which needs to be installed with special
capabilities) unprivileged, or to copy file trees that are owned by
the user or sub-ids.

For the first use-case, it's always safe to drop unmapped groups,
because the target rootfs is always owned by the user or its sub-ids.

For the other use-cases, this is more problematic, as you're all
well-aware of. Our position right now is that the tool will always
allow setgroups in user namespace, and that it's not safe to use on
systems that rely on negative access groups.

I think that something that's not mentioned is that if a user setgroups
to a fixed list of subgids, dropping all unmapped gids, they don't just
gain the ability to access these negative-access files, they also lose
legitimate access to files that their unmapped groups allow them to
access. This is fine for our first use-case, but a bit surprising for
the second one -- and since setgroups never lets us keep unmapped gids,
we have no way to keep these desired groups.

From a first glance, a sysctl that explicitly controls that would not
address the above problem, but keeping around the original group list
of the owner of the user ns would have the desired semantics.

Giuseppe's patch seems to address this use case, which would personally
make me very happy.

[1]: https://github.com/aristanetworks/bst

-- 
Snaipe
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
