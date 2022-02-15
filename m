Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EF327C
	for <containers@lists.linux.dev>; Tue, 15 Feb 2022 19:30:49 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52]:54488)
	by out01.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1nK3X8-00D9nP-CF; Tue, 15 Feb 2022 12:30:42 -0700
Received: from ip68-227-174-4.om.om.cox.net ([68.227.174.4]:41044 helo=email.froward.int.ebiederm.org.xmission.com)
	by in02.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1nK3X5-0070hH-KN; Tue, 15 Feb 2022 12:30:41 -0700
From: "Eric W. Biederman" <ebiederm@xmission.com>
To: bugzilla-daemon@kernel.org
Cc: Alexey Gladkov <legion@kernel.org>,
 Linux Containers <containers@lists.linux.dev> 
References: <bug-215596-7251@https.bugzilla.kernel.org/>
Date: Tue, 15 Feb 2022 13:30:33 -0600
In-Reply-To: <bug-215596-7251@https.bugzilla.kernel.org/>
	(bugzilla-daemon@kernel.org's message of "Sat, 12 Feb 2022 15:01:32
	+0000")
Message-ID: <8735kkq65i.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1nK3X5-0070hH-KN;;;mid=<8735kkq65i.fsf@email.froward.int.ebiederm.org>;;;hst=in02.mta.xmission.com;;;ip=68.227.174.4;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX1+hoJe3lL3qO5Pjlre9AwfQGoKY2SMtmyA=
X-SA-Exim-Connect-IP: 68.227.174.4
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa06.xmission.com
X-Spam-Level: 
X-Spam-Status: No, score=0.5 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_SCC_BODY_TEXT_LINE,T_TM2_M_HEADER_IN_MSG,
	XMSubLong autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4913]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa06 1397; Body=1 Fuz1=1 Fuz2=1]
	* -0.0 T_SCC_BODY_TEXT_LINE No description available.
X-Spam-DCC: XMission; sa06 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ;bugzilla-daemon@kernel.org
X-Spam-Relay-Country: 
X-Spam-Timing: total 2175 ms - load_scoreonly_sql: 0.06 (0.0%),
	signal_user_changed: 10 (0.4%), b_tie_ro: 8 (0.4%), parse: 1.01 (0.0%),
	 extract_message_metadata: 26 (1.2%), get_uri_detail_list: 3.0 (0.1%),
	tests_pri_-1000: 22 (1.0%), tests_pri_-950: 1.37 (0.1%),
	tests_pri_-900: 1.08 (0.0%), tests_pri_-90: 222 (10.2%), check_bayes:
	206 (9.5%), b_tokenize: 9 (0.4%), b_tok_get_all: 41 (1.9%),
	b_comp_prob: 2.8 (0.1%), b_tok_touch_all: 149 (6.8%), b_finish: 1.08
	(0.0%), tests_pri_0: 1421 (65.4%), check_dkim_signature: 0.96 (0.0%),
	check_dkim_adsp: 3.7 (0.2%), poll_dns_idle: 448 (20.6%), tests_pri_10:
	2.1 (0.1%), tests_pri_500: 465 (21.4%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [Bug 215596] New: Commit 59ec715 breaks systemd LimitNPROC with
 PrivateUsers
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)

bugzilla-daemon@kernel.org writes:

> https://bugzilla.kernel.org/show_bug.cgi?id=215596
>
>             Bug ID: 215596
>            Summary: Commit 59ec715 breaks systemd LimitNPROC with
>                     PrivateUsers
>            Product: Other
>            Version: 2.5
>           Hardware: All
>                 OS: Linux
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: other_other@kernel-bugs.osdl.org
>           Reporter: etienne@edechamps.fr
>                 CC: ebiederm@xmission.com, mkoutny@suse.com,
>                     solar@openwall.com
>         Regression: Yes
>
> Commit 59ec715 "ucounts: Fix rlimit max values check", first included in Linux
> 5.15.12, breaks systemd "LimitNPROC" (RLIMIT_NPROC) when combined with
> "PrivateUsers" (user namespacing).
>
> This can be reproduced with a trivial systemd service file:
>
> [Service]
> User=nobody
> PrivateUsers=yes
> LimitNPROC=4
> Type=oneshot
> ExecStart=/bin/true
>
> Which, on 59ec715, fails with:
>
> Failed to execute /bin/true: Resource temporarily unavailable
> Failed at step EXEC spawning /bin/true: Resource temporarily unavailable
> Main process exited, code=exited, status=203/EXEC
>
> (Even though user `nobody` has no running processes besides this one)
>
> A strace on PID 1 reveals the following sequence of calls (excerpt):
>
> clone(child_stack=NULL, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD,
> child_tidptr=0x40e60150) = 129
> [pid   129] prlimit64(0, RLIMIT_NPROC, {rlim_cur=4, rlim_max=4}, NULL) = 0
> [pid   129] unshare(CLONE_NEWUSER)      = 0
> [pid   129] setresuid(65534, 65534, 65534) = 0
> [pid   129] execve("/bin/true", ["/bin/true"], 0x552ad950a0 /* 7 vars */) = -1
> EAGAIN (Resource temporarily unavailable)

Do you happen to know which user the code was running as when prlimit64
was called?  Really it only matters before the unshare(CLONE_NEWUSER).

> On the parent commit of 59ec715 the service starts successfully.
>
> This is still reproducible on current master (83e3966).
>
> Relevant patch discussion:
> https://lore.kernel.org/lkml/87lf0g9xq7.fsf@email.froward.int.ebiederm.org/T/#m0a39edf27bc5aabca58b2c2a3d81704818d2c6fe
>
> This more recent thread also seems highly relevant:
> https://lore.kernel.org/lkml/20220207121800.5079-1-mkoutny@suse.com/

What this looks like is the user that called unshare had more that 4
processes running.

If that user is root is root there is an easy argument for fixing this.
Looking at the behavior from your trace and reading the code I don't
think the code was running as user root.

If the user that called unshare was not root, the question becomes
what are you trying to achieve.

You say it breaks LimitNPROC with PrivateUsers but I don't see how
this could have worked reliably in the past even without the change.

What limit were you expecting to be enforced?

Right now this looks like:
  Set RLIMIT_NPROC to 4.
  Have more than 4 processes.
  The kernel enforces the limit.

There is a lot of weird and goofy history with RLIMIT_NPROC so I am open
to learning something that would let this be a sensible case.  Right now
I unfortunately am not seeing it.

Eric



