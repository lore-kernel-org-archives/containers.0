Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C020CEA8
	for <containers@lists.linux.dev>; Fri,  2 Jun 2023 00:49:16 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51]:37446)
	by out03.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1q4sJh-00Evgz-Q9; Thu, 01 Jun 2023 18:06:53 -0600
Received: from ip68-110-29-46.om.om.cox.net ([68.110.29.46]:32956 helo=email.froward.int.ebiederm.org.xmission.com)
	by in01.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1q4sJg-003GZB-ML; Thu, 01 Jun 2023 18:06:53 -0600
From: "Eric W. Biederman" <ebiederm@xmission.com>
To: ~akihirosuda <akihirosuda@git.sr.ht>
Cc: linux-kernel@vger.kernel.org,  containers@lists.linux.dev,
  serge@hallyn.com,  brauner@kernel.org,  paul@paul-moore.com,
  ~akihirosuda <suda.kyoto@gmail.com>,  akihiro.suda.cz@hco.ntt.co.jp
References: <168547265011.24337.4306067683997517082-0@git.sr.ht>
Date: Thu, 01 Jun 2023 19:06:27 -0500
In-Reply-To: <168547265011.24337.4306067683997517082-0@git.sr.ht>
	(akihirosuda@git.sr.ht's message of "Tue, 30 May 2023 18:50:50 +0000")
Message-ID: <87v8g6bud8.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1q4sJg-003GZB-ML;;;mid=<87v8g6bud8.fsf@email.froward.int.ebiederm.org>;;;hst=in01.mta.xmission.com;;;ip=68.110.29.46;;;frm=ebiederm@xmission.com;;;spf=pass
X-XM-AID: U2FsdGVkX19jCAD3VXiN6cfDqTILsJT4KFsn1CUFU9Y=
X-SA-Exim-Connect-IP: 68.110.29.46
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa05.xmission.com
X-Spam-Level: 
X-Spam-Status: No, score=0.5 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_TM2_M_HEADER_IN_MSG,T_TooManySym_01,
	T_TooManySym_02,XMSubLong shortcircuit=no autolearn=disabled
	version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.5000]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa05 1397; Body=1 Fuz1=1 Fuz2=1]
	*  0.0 T_TooManySym_01 4+ unique symbols in subject
	*  0.0 T_TooManySym_02 5+ unique symbols in subject
X-Spam-DCC: XMission; sa05 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ;~akihirosuda <akihirosuda@git.sr.ht>
X-Spam-Relay-Country: 
X-Spam-Timing: total 511 ms - load_scoreonly_sql: 0.12 (0.0%),
	signal_user_changed: 12 (2.3%), b_tie_ro: 10 (1.9%), parse: 1.61
	(0.3%), extract_message_metadata: 31 (6.0%), get_uri_detail_list: 2.5
	(0.5%), tests_pri_-2000: 18 (3.4%), tests_pri_-1000: 3.3 (0.6%),
	tests_pri_-950: 1.65 (0.3%), tests_pri_-900: 1.30 (0.3%),
	tests_pri_-200: 1.07 (0.2%), tests_pri_-100: 8 (1.5%), tests_pri_-90:
	92 (18.0%), check_bayes: 81 (15.8%), b_tokenize: 7 (1.4%),
	b_tok_get_all: 7 (1.3%), b_comp_prob: 2.5 (0.5%), b_tok_touch_all: 60
	(11.8%), b_finish: 1.20 (0.2%), tests_pri_0: 225 (44.0%),
	check_dkim_signature: 0.70 (0.1%), check_dkim_adsp: 6 (1.3%),
	poll_dns_idle: 86 (16.9%), tests_pri_10: 4.0 (0.8%), tests_pri_500:
	108 (21.2%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [PATCH linux 0/3] [PATCH] userns: add sysctl
 "kernel.userns_group_range"
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)

~akihirosuda <akihirosuda@git.sr.ht> writes:

> This sysctl limits groups who can create a new userns without
> CAP_SYS_ADMIN in the current userns, so as to mitigate potential kernel
> vulnerabilities around userns.
>
> The sysctl value format is same as "net.ipv4.ping_group_range".
>
> To disable creating new unprivileged userns, set the sysctl value to "1
> 0" in the initial userns.
>
> To allow everyone to create new userns, set the sysctl value to "0
> 4294967294". This is the default value.
>
> This sysctl replaces "kernel.unprivileged_userns_clone" that is found in
> Ubuntu [1] and Debian GNU/Linux.
>
> Link: https://git.launchpad.net/~ubuntu-
> kernel/ubuntu/+source/linux/+git/jammy/commit?id=3422764 [1]
>
> Signed-off-by: Akihiro Suda <akihiro.suda.cz@hco.ntt.co.jp>

How does this functionally differ from what already exists
user.max_user_namespaces?

Given that setns exists I don't see limiting creation of user namespaces
by group being meaningful, if your goal is to reduce the attack surface
of the kernel to mitigate potential kernel vulnerabilities.

How does this functionality interact with the use of setgroups in a user
namespace?

What is the value of a group_range inside of a newly created user
namespace?  How does that work to maintain the policy you are trying to
implement?

Eric
