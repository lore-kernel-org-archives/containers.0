Return-Path: <SRS0=cdS5=JC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_RED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B94EC433ED
	for <containers@archiver.kernel.org>; Mon,  5 Apr 2021 17:03:19 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3EFCF6139E
	for <containers@archiver.kernel.org>; Mon,  5 Apr 2021 17:03:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EFCF6139E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id E925460AEB;
	Mon,  5 Apr 2021 17:03:18 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KBfKWlJPvzoc; Mon,  5 Apr 2021 17:03:18 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp3.osuosl.org (Postfix) with ESMTP id B60D7606E8;
	Mon,  5 Apr 2021 17:03:17 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 96D71C000C;
	Mon,  5 Apr 2021 17:03:17 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 34075C000A
 for <containers@lists.linux-foundation.org>;
 Mon,  5 Apr 2021 17:03:16 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 1FFE7403A2
 for <containers@lists.linux-foundation.org>;
 Mon,  5 Apr 2021 17:03:16 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id gs2xQshwN0tc
 for <containers@lists.linux-foundation.org>;
 Mon,  5 Apr 2021 17:03:15 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
 by smtp2.osuosl.org (Postfix) with ESMTPS id 3DE4240264
 for <containers@lists.linux-foundation.org>;
 Mon,  5 Apr 2021 17:03:11 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51])
 by out01.mta.xmission.com with esmtps (TLS1.2) tls
 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1lTSd3-00HQE2-Tq; Mon, 05 Apr 2021 11:03:10 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=fess.xmission.com) by in01.mta.xmission.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256) (Exim 4.87)
 (envelope-from <ebiederm@xmission.com>)
 id 1lTSd2-0000VS-UE; Mon, 05 Apr 2021 11:03:09 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Alexey Gladkov <gladkov.alexey@gmail.com>
References: <cover.1616533074.git.gladkov.alexey@gmail.com>
Date: Mon, 05 Apr 2021 12:03:05 -0500
In-Reply-To: <cover.1616533074.git.gladkov.alexey@gmail.com> (Alexey Gladkov's
 message of "Tue, 23 Mar 2021 21:59:09 +0100")
Message-ID: <m17dlgll4m.fsf@fess.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1lTSd2-0000VS-UE; ; ; mid=<m17dlgll4m.fsf@fess.ebiederm.org>; ; ;
 hst=in01.mta.xmission.com; ; ; ip=68.227.160.95; ; ; frm=ebiederm@xmission.com;
 ; ; spf=neutral
X-XM-AID: U2FsdGVkX18auhi4AyUcfdr4Byj9mZr34hCEOOzN8aw=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [PATCH v9 0/8] Count rlimits in each user namespace
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Alexey Gladkov <legion@kernel.org>
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

Alexey Gladkov <gladkov.alexey@gmail.com> writes:

> Preface
> -------
> These patches are for binding the rlimit counters to a user in user namespace.
> This patch set can be applied on top of:
>
> git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git v5.12-rc4
>
> Problem
> -------
> The RLIMIT_NPROC, RLIMIT_MEMLOCK, RLIMIT_SIGPENDING, RLIMIT_MSGQUEUE rlimits
> implementation places the counters in user_struct [1]. These limits are global
> between processes and persists for the lifetime of the process, even if
> processes are in different user namespaces.
>
> To illustrate the impact of rlimits, let's say there is a program that does not
> fork. Some service-A wants to run this program as user X in multiple containers.
> Since the program never fork the service wants to set RLIMIT_NPROC=1.
>
> service-A
>  \- program (uid=1000, container1, rlimit_nproc=1)
>  \- program (uid=1000, container2, rlimit_nproc=1)
>
> The service-A sets RLIMIT_NPROC=1 and runs the program in container1. When the
> service-A tries to run a program with RLIMIT_NPROC=1 in container2 it fails
> since user X already has one running process.
>
> The problem is not that the limit from container1 affects container2. The
> problem is that limit is verified against the global counter that reflects
> the number of processes in all containers.
>
> This problem can be worked around by using different users for each container
> but in this case we face a different problem of uid mapping when transferring
> files from one container to another.
>
> Eric W. Biederman mentioned this issue [2][3].
>
> Introduced changes
> ------------------
> To address the problem, we bind rlimit counters to user namespace. Each counter
> reflects the number of processes in a given uid in a given user namespace. The
> result is a tree of rlimit counters with the biggest value at the root (aka
> init_user_ns). The limit is considered exceeded if it's exceeded up in the tree.
>
> [1]: https://lore.kernel.org/containers/87imd2incs.fsf@x220.int.ebiederm.org/
> [2]: https://lists.linuxfoundation.org/pipermail/containers/2020-August/042096.html
> [3]: https://lists.linuxfoundation.org/pipermail/containers/2020-October/042524.html
>
> Changelog
> ---------
> v9:
> * Used a negative value to check that the ucounts->count is close to overflow.
> * Rebased onto v5.12-rc4.
>
> v8:
> * Used atomic_t for ucounts reference counting. Also added counter overflow
>   check (thanks to Linus Torvalds for the idea).
> * Fixed other issues found by lkp-tests project in the patch that Reimplements
>   RLIMIT_MEMLOCK on top of ucounts.
>
> v7:
> * Fixed issues found by lkp-tests project in the patch that Reimplements
>   RLIMIT_MEMLOCK on top of ucounts.
>
> v6:
> * Fixed issues found by lkp-tests project.
> * Rebased onto v5.11.
>
> v5:
> * Split the first commit into two commits: change ucounts.count type to atomic_long_t
>   and add ucounts to cred. These commits were merged by mistake during the rebase.
> * The __get_ucounts() renamed to alloc_ucounts().
> * The cred.ucounts update has been moved from commit_creds() as it did not allow
>   to handle errors.
> * Added error handling of set_cred_ucounts().
>
> v4:
> * Reverted the type change of ucounts.count to refcount_t.
> * Fixed typo in the kernel/cred.c
>
> v3:
> * Added get_ucounts() function to increase the reference count. The existing
>   get_counts() function renamed to __get_ucounts().
> * The type of ucounts.count changed from atomic_t to refcount_t.
> * Dropped 'const' from set_cred_ucounts() arguments.
> * Fixed a bug with freeing the cred structure after calling cred_alloc_blank().
> * Commit messages have been updated.
> * Added selftest.
>
> v2:
> * RLIMIT_MEMLOCK, RLIMIT_SIGPENDING and RLIMIT_MSGQUEUE are migrated to ucounts.
> * Added ucounts for pair uid and user namespace into cred.
> * Added the ability to increase ucount by more than 1.
>
> v1:
> * After discussion with Eric W. Biederman, I increased the size of ucounts to
>   atomic_long_t.
> * Added ucount_max to avoid the fork bomb.
>
> --
>
> Alexey Gladkov (8):
>   Increase size of ucounts to atomic_long_t
>   Add a reference to ucounts for each cred
>   Use atomic_t for ucounts reference counting
>   Reimplement RLIMIT_NPROC on top of ucounts
>   Reimplement RLIMIT_MSGQUEUE on top of ucounts
>   Reimplement RLIMIT_SIGPENDING on top of ucounts
>   Reimplement RLIMIT_MEMLOCK on top of ucounts
>   kselftests: Add test to check for rlimit changes in different user namespaces
>

Overall this looks good, and it is a very good sign that the automatic
testing bots have not found anything.  I found a few little nits.
But thing are looking very good.

Eric

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
