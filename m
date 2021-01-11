Return-Path: <SRS0=6a6i=GO=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A523AC433E0
	for <containers@archiver.kernel.org>; Mon, 11 Jan 2021 20:18:31 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1DAF1222B3
	for <containers@archiver.kernel.org>; Mon, 11 Jan 2021 20:18:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DAF1222B3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=xmission.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id BA07485B80;
	Mon, 11 Jan 2021 20:18:30 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id bCbdeBAZjJ0S; Mon, 11 Jan 2021 20:18:28 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 0499185143;
	Mon, 11 Jan 2021 20:18:27 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id DE7A8C088B;
	Mon, 11 Jan 2021 20:18:27 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id CDBA3C013A
 for <containers@lists.linux-foundation.org>;
 Mon, 11 Jan 2021 20:18:25 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 8BB0D204A9
 for <containers@lists.linux-foundation.org>;
 Mon, 11 Jan 2021 20:18:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 30hh-cOdjsAB
 for <containers@lists.linux-foundation.org>;
 Mon, 11 Jan 2021 20:18:24 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
 by silver.osuosl.org (Postfix) with ESMTPS id 3755620030
 for <containers@lists.linux-foundation.org>;
 Mon, 11 Jan 2021 20:18:24 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
 by out01.mta.xmission.com with esmtps (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kz3du-0092Lm-23; Mon, 11 Jan 2021 13:18:22 -0700
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]
 helo=x220.xmission.com)
 by in02.mta.xmission.com with esmtpsa (TLS1.3) tls
 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 (Exim 4.93)
 (envelope-from <ebiederm@xmission.com>)
 id 1kz3ds-00GF4a-SO; Mon, 11 Jan 2021 13:18:21 -0700
From: ebiederm@xmission.com (Eric W. Biederman)
To: Linus Torvalds <torvalds@linux-foundation.org>
References: <cover.1610299857.git.gladkov.alexey@gmail.com>
 <CAHk-=wgXZmRu762bjSeK80+T_LTo+UP9y5rP-uvym1vquSxmBw@mail.gmail.com>
Date: Mon, 11 Jan 2021 14:17:19 -0600
In-Reply-To: <CAHk-=wgXZmRu762bjSeK80+T_LTo+UP9y5rP-uvym1vquSxmBw@mail.gmail.com>
 (Linus Torvalds's message of "Sun, 10 Jan 2021 10:46:05 -0800")
Message-ID: <87a6tfp6sw.fsf@x220.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
X-XM-SPF: eid=1kz3ds-00GF4a-SO; ; ; mid=<87a6tfp6sw.fsf@x220.int.ebiederm.org>;
 ; ; hst=in02.mta.xmission.com; ; ; ip=68.227.160.95; ; ;
 frm=ebiederm@xmission.com; ; ; spf=neutral
X-XM-AID: U2FsdGVkX1/Yf/U+HHFa2llriv5GGUzjHmbH00nuzd4=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: Re: [RFC PATCH v2 0/8] Count rlimits in each user namespace
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)
Cc: Kees Cook <keescook@chromium.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, Alexey Gladkov <legion@kernel.org>,
 Christian Brauner <christian@brauner.io>
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

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Sun, Jan 10, 2021 at 9:34 AM Alexey Gladkov <gladkov.alexey@gmail.com> wrote:
>>
>> To address the problem, we bind rlimit counters to each user namespace. The
>> result is a tree of rlimit counters with the biggest value at the root (aka
>> init_user_ns). The rlimit counter increment/decrement occurs in the current and
>> all parent user namespaces.
>
> I'm not seeing why this is necessary.
>
> Maybe it's the right approach, but none of the patches (or this cover
> letter email) really explain it to me.
>
> I understand why you might want the _limits_ themselves would form a
> tree like this - with the "master limit" limiting the limits in the
> user namespaces under it.
>
> But I don't understand why the _counts_ should do that. The 'struct
> user_struct' should be shared across even user namespaces for the same
> user.
>
> IOW, the very example of the problem you quote seems to argue against this:
>
>> For example, there are two containers (A and B) created by one user. The
>> container A sets RLIMIT_NPROC=1 and starts one process. Everything is fine, but
>> when container B tries to do the same it will fail because the number of
>> processes is counted globally for each user and user has one process already.
>
> Note how the problem was _not_ that the _count_ was global. That part
> was fine and all good.

The problem is fundamentally that the per process RLIMIT_NPROC was
compared against the user_struct->processes.

I have only heard the problem described but I believe it is either the
RLIMIT_NPROC test in fork or at the beginning of do_execveat_common that
is failing.

From fs/exec.c line 1866:
> 	/*
> 	 * We move the actual failure in case of RLIMIT_NPROC excess from
> 	 * set*uid() to execve() because too many poorly written programs
> 	 * don't check setuid() return code.  Here we additionally recheck
> 	 * whether NPROC limit is still exceeded.
> 	 */
> 	if ((current->flags & PF_NPROC_EXCEEDED) &&
> 	    atomic_read(&current_user()->processes) > rlimit(RLIMIT_NPROC)) {
> 		retval = -EAGAIN;
> 		goto out_ret;
> 	}

From fs/fork.c line 1966:
> 	retval = -EAGAIN;
> 	if (atomic_read(&p->real_cred->user->processes) >=
> 			task_rlimit(p, RLIMIT_NPROC)) {
> 		if (p->real_cred->user != INIT_USER &&
> 		    !capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN))
> 			goto bad_fork_free;
> 	}
> 	current->flags &= ~PF_NPROC_EXCEEDED;

In both the cases the RLIMIT_NPROC value comes from
task->signal->rlim[RLIMIT_NPROC] and the count of processes
comes from task->cred->user->processes.

> No, the problem was that the _limit_ in container A also ended up
> affecting container B.

The description I have is that both containers run the same service
that set it's RLIMIT_NPROC to 1 in both containers.

> So to me, that says that it would make sense to continue to use the
> resource counts in 'struct user_struct' (because if user A has a hard
> limit of X, then creating a new namespace shouldn't expand that
> limit), but then have the ability to make per-container changes to the
> resource limits (as long as they are within the bounds of the parent
> user namespace resource limit).

I agree that needs to work as well.

> Maybe there is some reason for this ucounts approach, but if so, I
> feel it was not explained at all.

Let me see if I can starte the example a litle more clearly.

Suppose there is a service never_fork that sets RLIMIT_NPROC runs as
never_fork_user and sets RLIMIT_NPROC to 1 in it's systemd service file.

Further suppose there is a user bob who has two containers he wants to
run: container1 and container2.  Both containers start the never_fork
service.

Bob first starts container1 and inside it the never_fork service starts.
Bob starts container2 and the never_fork service fails to start.

Does that make it clear that it is the count of the processes that would
exceed 1 if both instances of the never_fork service starts that would
be the problem?

Eric
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
