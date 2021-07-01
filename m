Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B89B70
	for <containers@lists.linux.dev>; Thu,  1 Jul 2021 20:55:58 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52]:48706)
	by out03.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lz2wf-0051gb-7p; Thu, 01 Jul 2021 14:05:57 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]:48610 helo=email.xmission.com)
	by in02.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lz2we-00BEc1-3d; Thu, 01 Jul 2021 14:05:56 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Alexey Gladkov <legion@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,  Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,  Linux Containers <containers@lists.linux.dev>
References: <87fsx1vcr9.fsf@disp2133>
	<CAHk-=wj1z-NKxedgZvSS37iH=EKE47PkL=+BYccAUtsuB1sySQ@mail.gmail.com>
	<87czs4u0rm.fsf@disp2133>
	<CAHk-=wgs5+3MLjG_hsQcKdamOcTsJLsk47tV12FfD_0f2h47Rg@mail.gmail.com>
	<87mtr8sjvr.fsf@disp2133> <87a6n8simq.fsf@disp2133>
	<20210701164144.u2dod4g2obfj4kit@example.org>
Date: Thu, 01 Jul 2021 15:05:18 -0500
In-Reply-To: <20210701164144.u2dod4g2obfj4kit@example.org> (Alexey Gladkov's
	message of "Thu, 1 Jul 2021 18:41:44 +0200")
Message-ID: <87o8blol4x.fsf@disp2133>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1lz2we-00BEc1-3d;;;mid=<87o8blol4x.fsf@disp2133>;;;hst=in02.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX186RRMiCoq2i2iZsr93Lu2GAzZej0SbQoQ=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa06.xmission.com
X-Spam-Level: *
X-Spam-Status: No, score=2.0 required=8.0 tests=ALL_TRUSTED,BAYES_40,
	DCC_CHECK_NEGATIVE,T_TM2_M_HEADER_IN_MSG,XMSubLong,XMSubMetaSxObfu_03,
	XMSubMetaSx_00 autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	* -0.0 BAYES_40 BODY: Bayes spam probability is 20 to 40%
	*      [score: 0.2042]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa06 1397; Body=1 Fuz1=1 Fuz2=1]
	*  1.2 XMSubMetaSxObfu_03 Obfuscated Sexy Noun-People
	*  1.0 XMSubMetaSx_00 1+ Sexy Words
X-Spam-DCC: XMission; sa06 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: *;Alexey Gladkov <legion@kernel.org>
X-Spam-Relay-Country: 
X-Spam-Timing: total 485 ms - load_scoreonly_sql: 0.06 (0.0%),
	signal_user_changed: 8 (1.7%), b_tie_ro: 7 (1.5%), parse: 1.39 (0.3%),
	extract_message_metadata: 22 (4.5%), get_uri_detail_list: 2.7 (0.6%),
	tests_pri_-1000: 17 (3.5%), tests_pri_-950: 1.18 (0.2%),
	tests_pri_-900: 0.99 (0.2%), tests_pri_-90: 71 (14.7%), check_bayes:
	70 (14.4%), b_tokenize: 6 (1.3%), b_tok_get_all: 5 (1.1%),
	b_comp_prob: 2.0 (0.4%), b_tok_touch_all: 53 (10.8%), b_finish: 0.94
	(0.2%), tests_pri_0: 341 (70.2%), check_dkim_signature: 0.52 (0.1%),
	check_dkim_adsp: 8 (1.6%), poll_dns_idle: 0.73 (0.1%), tests_pri_10:
	2.6 (0.5%), tests_pri_500: 16 (3.2%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [GIT PULL] ucounts: Count rlimits in each user namespace
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)

Alexey Gladkov <legion@kernel.org> writes:

> On Tue, Jun 29, 2021 at 12:09:01PM -0500, Eric W. Biederman wrote:
>> ebiederm@xmission.com (Eric W. Biederman) writes:
>> 
>> > Linus Torvalds <torvalds@linux-foundation.org> writes:
>> >
>> >> On Tue, Jun 29, 2021 at 8:52 AM Eric W. Biederman <ebiederm@xmission.com> wrote:
>> >>>
>> >>> Linus Torvalds <torvalds@linux-foundation.org> writes:
>> >>>
>> >>> > Why the "sigpending < LONG_MAX" test in that
>> >>> >
>> >>> >         if (override_rlimit || (sigpending < LONG_MAX && sigpending <=
>> >>> > task_rlimit(t, RLIMIT_SIGPENDING))) {
>> >>> > thing?
>> >>>
>> >>> On second look that sigpending < LONG_MAX check is necessary.  When
>> >>> inc_rlimit_ucounts detects a problem it returns LONG_MAX.
>> >>
>> >> I saw that, but _without_ that test you'd be left with just that
>> >>
>> >>     sigpending <= task_rlimit(t, RLIMIT_SIGPENDING)
>> >>
>> >> and if task_rlimit() is LONG_MAX, then that means "no limits", so it is all ok.
>> >
>> > It means no limits locally.  The creator of your user namespace might
>> > have had a limit which you are also bound by.
>> >
>> > The other possibility is that inc_rlimits_ucounts caused a sigpending
>> > counter to overflow.  In which case we need to fail and run
>> > dec_rlimit_ucounts to keep the counter from staying overflowed.
>> >
>> > So I don't see a clever way to avoid the sigpending < LONG_MAX  test.
>> 
>> Hmm.  I take that back.  There is a simple clever way to satisfy all of
>> the tests.
>> 
>> - sigpending < LONG_MAX && sigpending <= task_rlimit(t, RLIMIT_SIGPENDING)
>> + sigpending < task_rlimit(t, RLIMIT_SIGPENDING)
>> 
>> That would just need a small comment to explain the subtleties.  
>
> Is it because user.sigpending was atomic_t before this patch ?

Apologies I was wrong.

The replacement of "<=" with "<" is correct for the case where
"task_rlimit(t, RLIMIT_SIGPENDING) == LONG_MAX".

Unfortunately off by one for all other values of
"task_rlimit(t, RLIMIT_SIGPENDING)".

It completely breaks things for the case where RLIMIT_SIGPENDING == 1,
where no signals are allowed to be queued.  Today allowing 1 queued
signal with a single task and a sender that does not send a second
signal until the first is consumed will work reliably.

That was just a brain fart on my part.

Eric

