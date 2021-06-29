Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F1C9917F
	for <containers@lists.linux.dev>; Tue, 29 Jun 2021 15:29:00 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
	by out01.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lyFIN-008dtP-NA; Tue, 29 Jun 2021 09:05:03 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]:58984 helo=email.xmission.com)
	by in02.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lyFIM-001WCn-AL; Tue, 29 Jun 2021 09:05:03 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alexey Gladkov <legion@kernel.org>,  Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,  Linux Containers <containers@lists.linux.dev>
References: <87fsx1vcr9.fsf@disp2133>
	<CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
Date: Tue, 29 Jun 2021 10:04:19 -0500
In-Reply-To: <CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
	(Linus Torvalds's message of "Mon, 28 Jun 2021 20:47:12 -0700")
Message-ID: <87r1gku2z0.fsf@disp2133>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1lyFIM-001WCn-AL;;;mid=<87r1gku2z0.fsf@disp2133>;;;hst=in02.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX192t3ZGKJh38+xv4Fmewi8hlGXzg4wt6Nc=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa07.xmission.com
X-Spam-Level: **
X-Spam-Status: No, score=2.8 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_TM2_M_HEADER_IN_MSG,XMSubLong,XMSubMetaSxObfu_03,
	XMSubMetaSx_00 autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4997]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa07 1397; Body=1 Fuz1=1 Fuz2=1]
	*  1.0 XMSubMetaSx_00 1+ Sexy Words
	*  1.2 XMSubMetaSxObfu_03 Obfuscated Sexy Noun-People
X-Spam-DCC: XMission; sa07 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: **;Linus Torvalds <torvalds@linux-foundation.org>
X-Spam-Relay-Country: 
X-Spam-Timing: total 689 ms - load_scoreonly_sql: 0.05 (0.0%),
	signal_user_changed: 12 (1.8%), b_tie_ro: 11 (1.6%), parse: 1.24
	(0.2%), extract_message_metadata: 20 (2.9%), get_uri_detail_list: 2.2
	(0.3%), tests_pri_-1000: 15 (2.1%), tests_pri_-950: 1.15 (0.2%),
	tests_pri_-900: 1.04 (0.2%), tests_pri_-90: 307 (44.6%), check_bayes:
	296 (43.0%), b_tokenize: 6 (0.8%), b_tok_get_all: 102 (14.8%),
	b_comp_prob: 3.4 (0.5%), b_tok_touch_all: 182 (26.4%), b_finish: 0.92
	(0.1%), tests_pri_0: 315 (45.8%), check_dkim_signature: 0.50 (0.1%),
	check_dkim_adsp: 2.7 (0.4%), poll_dns_idle: 0.55 (0.1%), tests_pri_10:
	3.3 (0.5%), tests_pri_500: 9 (1.3%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [GIT PULL] ucounts: Count rlimits in each user namespace
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Mon, Jun 28, 2021 at 3:35 PM Eric W. Biederman <ebiederm@xmission.com> wrote:
>>
>> This is the work mainly by Alexey Gladkov to limit rlimits to the
>> rlimits of the user that created a user namespace, and to allow users to
>> have stricter limits on the resources created within a user namespace.
>
> I guess all the performance issues got sorted, since I haven't seen
> any reports from the test robots.

Yes.  The structure was made to not change anything unnecessarily
(such as the ordering in sigqueue_alloc) and the performances
differences went away.

With the code in linux-next the entire cycle I think that is a reliable
result.  There are probably some things we could do to further optimize
things but we did not need them to avoid regressions.

> I do end up with two questions, mainly because of looking at the
> result of the conflict resolution.
>
> In particular, in __sigqueue_alloc(), two oddities..
>
> Why the "sigpending < LONG_MAX" test in that
>
>         if (override_rlimit || (sigpending < LONG_MAX && sigpending <=
> task_rlimit(t, RLIMIT_SIGPENDING))) {
>
> thing?

> And why test for "ucounts" being non-NULL in
>
>                 if (ucounts && dec_rlimit_ucounts(ucounts,
> UCOUNT_RLIMIT_SIGPENDING, 1))
>                         put_ucounts(ucounts);
>
> when afaik both of those should be happy with a NULL 'ucounts' pointer
> (if it was NULL, we certainly already used it for the reverse
> operations for get_ucounts() and inc_rlimit_ucounts()..)
>
> Hmm?

Yes.  I suspect that those tests are left over from a previous version
of the change.  Alex do you remember why those tests are there?

> And somebody should verify that I didn't screw anything up in my merge
> resolution. It all looked very straightforward, but mistakes happen..

Just reading through the resolution looks correct.

Eric
