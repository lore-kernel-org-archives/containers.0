Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6722F185E
	for <containers@lists.linux.dev>; Sun,  5 Jun 2022 22:42:03 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52]:37948)
	by out03.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1nxyT6-00C2pP-7e; Sun, 05 Jun 2022 16:11:32 -0600
Received: from ip68-227-174-4.om.om.cox.net ([68.227.174.4]:41754 helo=email.froward.int.ebiederm.org.xmission.com)
	by in02.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1nxyT5-004SZw-BA; Sun, 05 Jun 2022 16:11:31 -0600
From: "Eric W. Biederman" <ebiederm@xmission.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,  Alexey
 Gladkov <legion@kernel.org>,  Linux Containers
 <containers@lists.linux.dev>
References: <875ylh8xxx.fsf@email.froward.int.ebiederm.org>
	<CAHk-=wh0ZYiQuCJmohyYpk99mch=Nb+_m4DWxBX03DQWnsvCZA@mail.gmail.com>
Date: Sun, 05 Jun 2022 17:11:07 -0500
In-Reply-To: <CAHk-=wh0ZYiQuCJmohyYpk99mch=Nb+_m4DWxBX03DQWnsvCZA@mail.gmail.com>
	(Linus Torvalds's message of "Fri, 3 Jun 2022 15:59:33 -0700")
Message-ID: <87tu8y69s4.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1nxyT5-004SZw-BA;;;mid=<87tu8y69s4.fsf@email.froward.int.ebiederm.org>;;;hst=in02.mta.xmission.com;;;ip=68.227.174.4;;;frm=ebiederm@xmission.com;;;spf=softfail
X-XM-AID: U2FsdGVkX1/IcMM5ic1t771lZP5L72ecB8LyxksRPPU=
X-SA-Exim-Connect-IP: 68.227.174.4
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa07.xmission.com
X-Spam-Level: *****
X-Spam-Status: No, score=5.2 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_SCC_BODY_TEXT_LINE,T_TM2_M_HEADER_IN_MSG,
	XMSubLong,XMSubMetaSxObfu_03,XMSubMetaSx_00,XM_SPF_SoftFail
	autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4824]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa07 1397; Body=1 Fuz1=1 Fuz2=1]
	*  1.0 XMSubMetaSx_00 1+ Sexy Words
	*  2.5 XM_SPF_SoftFail SPF-SoftFail
	*  1.2 XMSubMetaSxObfu_03 Obfuscated Sexy Noun-People
	* -0.0 T_SCC_BODY_TEXT_LINE No description available.
X-Spam-DCC: XMission; sa07 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: *****;Linus Torvalds <torvalds@linux-foundation.org>
X-Spam-Relay-Country: 
X-Spam-Timing: total 270 ms - load_scoreonly_sql: 0.09 (0.0%),
	signal_user_changed: 11 (4.1%), b_tie_ro: 9 (3.4%), parse: 1.18 (0.4%),
	 extract_message_metadata: 17 (6.3%), get_uri_detail_list: 1.37 (0.5%),
	 tests_pri_-1000: 16 (5.8%), tests_pri_-950: 1.37 (0.5%),
	tests_pri_-900: 1.04 (0.4%), tests_pri_-90: 48 (17.7%), check_bayes:
	46 (17.2%), b_tokenize: 4.9 (1.8%), b_tok_get_all: 5 (2.0%),
	b_comp_prob: 1.91 (0.7%), b_tok_touch_all: 31 (11.4%), b_finish: 0.90
	(0.3%), tests_pri_0: 146 (53.9%), check_dkim_signature: 0.56 (0.2%),
	check_dkim_adsp: 3.2 (1.2%), poll_dns_idle: 0.89 (0.3%), tests_pri_10:
	2.9 (1.1%), tests_pri_500: 23 (8.5%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [GIT PULL] ipc: per namespace ipc sysctl changes for v5.19
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Fri, Jun 3, 2022 at 10:21 AM Eric W. Biederman <ebiederm@xmission.com> wrote:
>>
>> These changes were sent for v5.18[1] but were dropped because some
>> additional cleanups were requested.  Linus has given his nod[2] to the
>> cleanups so I hope enough cleanups are present this time.
>
> Well, I'll be happier still when the next set of cleanups hits:
>
>    https://lore.kernel.org/all/CAHk-=wjJ2CP0ugbOnwAd-=Cw0i-q_xC1PbJ-_1jrvR-aisiAAA@mail.gmail.com/
>
> but yeah, that further cleanup series clearly wasn't quite ready yet.

Yes.  It came in during the merge window.  I have been keeping a weather
eye on it but I really haven't had a chance to look yet.

Eric
