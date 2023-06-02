Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C25E4184
	for <containers@lists.linux.dev>; Fri,  2 Jun 2023 00:14:17 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51]:38966)
	by out03.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1q4sQp-00Ew6R-PT; Thu, 01 Jun 2023 18:14:15 -0600
Received: from ip68-110-29-46.om.om.cox.net ([68.110.29.46]:54766 helo=email.froward.int.ebiederm.org.xmission.com)
	by in01.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1q4sQo-003HU4-La; Thu, 01 Jun 2023 18:14:15 -0600
From: "Eric W. Biederman" <ebiederm@xmission.com>
To: Paul Moore <paul@paul-moore.com>
Cc: "~akihirosuda" <suda.kyoto@gmail.com>,  linux-kernel@vger.kernel.org,
  containers@lists.linux.dev,  serge@hallyn.com,  brauner@kernel.org,
  akihiro.suda.cz@hco.ntt.co.jp
References: <168547265011.24337.4306067683997517082-0@git.sr.ht>
	<CAHC9VhQhBBPyZE24LM6KvYrET2huW-W_YYsyPndpNkn70Mu3Ug@mail.gmail.com>
Date: Thu, 01 Jun 2023 19:14:08 -0500
In-Reply-To: <CAHC9VhQhBBPyZE24LM6KvYrET2huW-W_YYsyPndpNkn70Mu3Ug@mail.gmail.com>
	(Paul Moore's message of "Tue, 30 May 2023 17:58:48 -0400")
Message-ID: <87fs7abu0f.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-XM-SPF: eid=1q4sQo-003HU4-La;;;mid=<87fs7abu0f.fsf@email.froward.int.ebiederm.org>;;;hst=in01.mta.xmission.com;;;ip=68.110.29.46;;;frm=ebiederm@xmission.com;;;spf=pass
X-XM-AID: U2FsdGVkX19DIiVSRQ5BpipU+RbDjDyU5NgJlxnB9UQ=
X-SA-Exim-Connect-IP: 68.110.29.46
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa07.xmission.com
X-Spam-Level: 
X-Spam-Status: No, score=0.5 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_SCC_BODY_TEXT_LINE,T_TM2_M_HEADER_IN_MSG,
	T_TooManySym_01,T_TooManySym_02,XMSubLong,XM_B_Unicode shortcircuit=no
	autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4984]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	*  0.0 XM_B_Unicode BODY: Testing for specific types of unicode
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa07 1397; Body=1 Fuz1=1 Fuz2=1]
	* -0.0 T_SCC_BODY_TEXT_LINE No description available.
	*  0.0 T_TooManySym_02 5+ unique symbols in subject
	*  0.0 T_TooManySym_01 4+ unique symbols in subject
X-Spam-DCC: XMission; sa07 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ;Paul Moore <paul@paul-moore.com>
X-Spam-Relay-Country: 
X-Spam-Timing: total 541 ms - load_scoreonly_sql: 0.05 (0.0%),
	signal_user_changed: 11 (2.1%), b_tie_ro: 10 (1.8%), parse: 0.96
	(0.2%), extract_message_metadata: 20 (3.7%), get_uri_detail_list: 1.60
	(0.3%), tests_pri_-2000: 19 (3.4%), tests_pri_-1000: 2.5 (0.5%),
	tests_pri_-950: 1.29 (0.2%), tests_pri_-900: 1.08 (0.2%),
	tests_pri_-200: 0.90 (0.2%), tests_pri_-100: 6 (1.1%), tests_pri_-90:
	68 (12.6%), check_bayes: 67 (12.3%), b_tokenize: 6 (1.2%),
	b_tok_get_all: 8 (1.5%), b_comp_prob: 2.4 (0.4%), b_tok_touch_all: 47
	(8.7%), b_finish: 0.93 (0.2%), tests_pri_0: 227 (42.0%),
	check_dkim_signature: 0.58 (0.1%), check_dkim_adsp: 2.5 (0.5%),
	poll_dns_idle: 164 (30.4%), tests_pri_10: 2.1 (0.4%), tests_pri_500:
	178 (32.9%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [PATCH linux 0/3] [PATCH] userns: add sysctl
 "kernel.userns_group_range"
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)

Paul Moore <paul@paul-moore.com> writes:

> On Tue, May 30, 2023 at 2:50=E2=80=AFPM ~akihirosuda <akihirosuda@git.sr.=
ht> wrote:
>>
>> This sysctl limits groups who can create a new userns without
>> CAP_SYS_ADMIN in the current userns, so as to mitigate potential kernel
>> vulnerabilities around userns.
>>
>> The sysctl value format is same as "net.ipv4.ping_group_range".
>>
>> To disable creating new unprivileged userns, set the sysctl value to "1
>> 0" in the initial userns.
>>
>> To allow everyone to create new userns, set the sysctl value to "0
>> 4294967294". This is the default value.
>>
>> This sysctl replaces "kernel.unprivileged_userns_clone" that is found in
>> Ubuntu [1] and Debian GNU/Linux.
>>
>> Link: https://git.launchpad.net/~ubuntu-
>> kernel/ubuntu/+source/linux/+git/jammy/commit?id=3D3422764 [1]
>
> Given the challenges around adding access controls to userns
> operations, have you considered using the LSM support that was added
> upstream last year?  The relevant LSM hook can be found in commit
> 7cd4c5c2101c ("security, lsm: Introduce security_create_user_ns()"),


Paul how have you handled the real world regression I reported against
chromium?

Paul are you aware that the LSM hook can not be used to achieve the
objective of this patchset?

> and although only SELinux currently provides an access control
> implementation, there is no reason you couldn't add support for your
> favorite LSM, or even just a simple BPF LSM to enforce the group
> controls as you've described them here.

Is there a publicly available SELinux policy that uses that LSM hook?

Eric
