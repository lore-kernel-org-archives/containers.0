Received: from out02.mta.xmission.com (out02.mta.xmission.com [166.70.13.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE06917F
	for <containers@lists.linux.dev>; Tue, 29 Jun 2021 15:52:06 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
	by out02.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lyG1t-007HkF-AW; Tue, 29 Jun 2021 09:52:05 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]:59472 helo=email.xmission.com)
	by in02.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lyG1s-001hct-9Q; Tue, 29 Jun 2021 09:52:04 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alexey Gladkov <legion@kernel.org>,  Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,  Linux Containers <containers@lists.linux.dev>
References: <87fsx1vcr9.fsf@disp2133>
	<CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
Date: Tue, 29 Jun 2021 10:51:57 -0500
In-Reply-To: <CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
	(Linus Torvalds's message of "Mon, 28 Jun 2021 20:47:12 -0700")
Message-ID: <87czs4u0rm.fsf@disp2133>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1lyG1s-001hct-9Q;;;mid=<87czs4u0rm.fsf@disp2133>;;;hst=in02.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX1/CH09AIniFLWzy282KwTH+6uGeoCx45RM=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa02.xmission.com
X-Spam-Level: *
X-Spam-Status: No, score=2.0 required=8.0 tests=ALL_TRUSTED,BAYES_40,
	DCC_CHECK_NEGATIVE,T_TM2_M_HEADER_IN_MSG,XMSubLong,XMSubMetaSxObfu_03,
	XMSubMetaSx_00 autolearn=disabled version=3.4.2
X-Spam-Virus: No
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	* -0.0 BAYES_40 BODY: Bayes spam probability is 20 to 40%
	*      [score: 0.3735]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa02 1397; Body=1 Fuz1=1 Fuz2=1]
	*  1.2 XMSubMetaSxObfu_03 Obfuscated Sexy Noun-People
	*  1.0 XMSubMetaSx_00 1+ Sexy Words
X-Spam-DCC: XMission; sa02 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: *;Linus Torvalds <torvalds@linux-foundation.org>
X-Spam-Relay-Country: 
X-Spam-Timing: total 282 ms - load_scoreonly_sql: 0.03 (0.0%),
	signal_user_changed: 3.7 (1.3%), b_tie_ro: 2.6 (0.9%), parse: 0.62
	(0.2%), extract_message_metadata: 8 (2.7%), get_uri_detail_list: 0.43
	(0.2%), tests_pri_-1000: 3.9 (1.4%), tests_pri_-950: 0.98 (0.3%),
	tests_pri_-900: 0.81 (0.3%), tests_pri_-90: 135 (47.8%), check_bayes:
	127 (45.0%), b_tokenize: 3.2 (1.1%), b_tok_get_all: 3.4 (1.2%),
	b_comp_prob: 0.95 (0.3%), b_tok_touch_all: 117 (41.5%), b_finish: 0.62
	(0.2%), tests_pri_0: 118 (41.6%), check_dkim_signature: 0.35 (0.1%),
	check_dkim_adsp: 2.2 (0.8%), poll_dns_idle: 0.48 (0.2%), tests_pri_10:
	2.3 (0.8%), tests_pri_500: 7 (2.6%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [GIT PULL] ucounts: Count rlimits in each user namespace
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)

Linus Torvalds <torvalds@linux-foundation.org> writes:

> Why the "sigpending < LONG_MAX" test in that
>
>         if (override_rlimit || (sigpending < LONG_MAX && sigpending <=
> task_rlimit(t, RLIMIT_SIGPENDING))) {
> thing?

On second look that sigpending < LONG_MAX check is necessary.  When
inc_rlimit_ucounts detects a problem it returns LONG_MAX.

So the check for LONG_MAX is the condensed check to see if there is a
problem in any other levels of the ucount hierarchy.

Eric
