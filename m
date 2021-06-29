Received: from out02.mta.xmission.com (out02.mta.xmission.com [166.70.13.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B169670
	for <containers@lists.linux.dev>; Tue, 29 Jun 2021 16:42:09 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51])
	by out02.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lyGoK-007Oh9-AZ; Tue, 29 Jun 2021 10:42:08 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]:60056 helo=email.xmission.com)
	by in01.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lyGoI-002Txf-FL; Tue, 29 Jun 2021 10:42:07 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alexey Gladkov <legion@kernel.org>,  Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,  Linux Containers <containers@lists.linux.dev>
References: <87fsx1vcr9.fsf@disp2133>
	<CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
	<87czs4u0rm.fsf@disp2133>
	<CAHk-=wgs5+3MLjG_hsQcKdamOcTsJLsk47tV12FfD_0f2h47Rg@mail.gmail.com>
Date: Tue, 29 Jun 2021 11:42:00 -0500
In-Reply-To: <CAHk-=wgs5+3MLjG_hsQcKdamOcTsJLsk47tV12FfD_0f2h47Rg@mail.gmail.com>
	(Linus Torvalds's message of "Tue, 29 Jun 2021 09:34:17 -0700")
Message-ID: <87mtr8sjvr.fsf@disp2133>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1lyGoI-002Txf-FL;;;mid=<87mtr8sjvr.fsf@disp2133>;;;hst=in01.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX1+RhPiZBQsPCPrf7dkJU9N3BdG6qpff208=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa06.xmission.com
X-Spam-Level: **
X-Spam-Status: No, score=2.8 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_TM2_M_HEADER_IN_MSG,XMSubLong,XMSubMetaSxObfu_03,
	XMSubMetaSx_00 autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4573]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa06 1397; Body=1 Fuz1=1 Fuz2=1]
	*  1.2 XMSubMetaSxObfu_03 Obfuscated Sexy Noun-People
	*  1.0 XMSubMetaSx_00 1+ Sexy Words
X-Spam-DCC: XMission; sa06 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: **;Linus Torvalds <torvalds@linux-foundation.org>
X-Spam-Relay-Country: 
X-Spam-Timing: total 1304 ms - load_scoreonly_sql: 0.13 (0.0%),
	signal_user_changed: 13 (1.0%), b_tie_ro: 11 (0.8%), parse: 1.10
	(0.1%), extract_message_metadata: 17 (1.3%), get_uri_detail_list: 1.28
	(0.1%), tests_pri_-1000: 25 (1.9%), tests_pri_-950: 1.38 (0.1%),
	tests_pri_-900: 1.12 (0.1%), tests_pri_-90: 67 (5.2%), check_bayes: 66
	(5.0%), b_tokenize: 5 (0.4%), b_tok_get_all: 5 (0.4%), b_comp_prob:
	1.79 (0.1%), b_tok_touch_all: 49 (3.8%), b_finish: 0.99 (0.1%),
	tests_pri_0: 1165 (89.4%), check_dkim_signature: 0.60 (0.0%),
	check_dkim_adsp: 2.8 (0.2%), poll_dns_idle: 0.95 (0.1%), tests_pri_10:
	2.2 (0.2%), tests_pri_500: 7 (0.5%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [GIT PULL] ucounts: Count rlimits in each user namespace
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Tue, Jun 29, 2021 at 8:52 AM Eric W. Biederman <ebiederm@xmission.com> wrote:
>>
>> Linus Torvalds <torvalds@linux-foundation.org> writes:
>>
>> > Why the "sigpending < LONG_MAX" test in that
>> >
>> >         if (override_rlimit || (sigpending < LONG_MAX && sigpending <=
>> > task_rlimit(t, RLIMIT_SIGPENDING))) {
>> > thing?
>>
>> On second look that sigpending < LONG_MAX check is necessary.  When
>> inc_rlimit_ucounts detects a problem it returns LONG_MAX.
>
> I saw that, but _without_ that test you'd be left with just that
>
>     sigpending <= task_rlimit(t, RLIMIT_SIGPENDING)
>
> and if task_rlimit() is LONG_MAX, then that means "no limits", so it is all ok.

It means no limits locally.  The creator of your user namespace might
have had a limit which you are also bound by.

The other possibility is that inc_rlimits_ucounts caused a sigpending
counter to overflow.  In which case we need to fail and run
dec_rlimit_ucounts to keep the counter from staying overflowed.

So I don't see a clever way to avoid the sigpending < LONG_MAX  test.

Eric
