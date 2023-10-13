Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E2B9511C91
	for <containers@lists.linux.dev>; Fri, 13 Oct 2023 13:04:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=xmission.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=xmission.com
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from in02.mta.xmission.com ([166.70.13.52]:51400)
	by out03.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1qrHpe-004kKO-NP; Fri, 13 Oct 2023 07:03:58 -0600
Received: from ip68-227-168-167.om.om.cox.net ([68.227.168.167]:60040 helo=email.froward.int.ebiederm.org.xmission.com)
	by in02.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1qrHpd-00GEuo-Bj; Fri, 13 Oct 2023 07:03:58 -0600
From: "Eric W. Biederman" <ebiederm@xmission.com>
To: yunhui cui <cuiyunhui@bytedance.com>
Cc: akpm@linux-foundation.org,  keescook@chromium.org,  brauner@kernel.org,
  jeffxu@google.com,  frederic@kernel.org,  mcgrof@kernel.org,
  cyphar@cyphar.com,  rongtao@cestc.cn,  linux-kernel@vger.kernel.org,
  Linux Containers <containers@lists.linux.dev>
References: <20231011065446.53034-1-cuiyunhui@bytedance.com>
	<87sf6gcyb3.fsf@email.froward.int.ebiederm.org>
	<CAEEQ3wm8oE1dXo7AuU3gY90oF_G21OqNZwnkqhhd1-_j4wWbYQ@mail.gmail.com>
Date: Fri, 13 Oct 2023 08:03:27 -0500
In-Reply-To: <CAEEQ3wm8oE1dXo7AuU3gY90oF_G21OqNZwnkqhhd1-_j4wWbYQ@mail.gmail.com>
	(yunhui cui's message of "Fri, 13 Oct 2023 10:44:45 +0800")
Message-ID: <87r0lyad40.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-XM-SPF: eid=1qrHpd-00GEuo-Bj;;;mid=<87r0lyad40.fsf@email.froward.int.ebiederm.org>;;;hst=in02.mta.xmission.com;;;ip=68.227.168.167;;;frm=ebiederm@xmission.com;;;spf=pass
X-XM-AID: U2FsdGVkX18XjmovimnXJhc/c58GwdkiGPUaBlB1duc=
X-SA-Exim-Connect-IP: 68.227.168.167
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa06.xmission.com
X-Spam-Level: 
X-Spam-Status: No, score=0.5 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_TM2_M_HEADER_IN_MSG,XMSubLong,XM_B_Unicode
	shortcircuit=no autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4888]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	*  0.0 XM_B_Unicode BODY: Testing for specific types of unicode
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa06 1397; Body=1 Fuz1=1 Fuz2=1]
X-Spam-DCC: XMission; sa06 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ;yunhui cui <cuiyunhui@bytedance.com>
X-Spam-Relay-Country: 
X-Spam-Timing: total 800 ms - load_scoreonly_sql: 0.09 (0.0%),
	signal_user_changed: 20 (2.5%), b_tie_ro: 19 (2.3%), parse: 1.64
	(0.2%), extract_message_metadata: 44 (5.5%), get_uri_detail_list: 2.7
	(0.3%), tests_pri_-2000: 62 (7.7%), tests_pri_-1000: 8 (1.0%),
	tests_pri_-950: 1.94 (0.2%), tests_pri_-900: 1.62 (0.2%),
	tests_pri_-200: 1.31 (0.2%), tests_pri_-100: 6 (0.8%), tests_pri_-90:
	224 (28.0%), check_bayes: 201 (25.2%), b_tokenize: 11 (1.4%),
	b_tok_get_all: 20 (2.5%), b_comp_prob: 4.2 (0.5%), b_tok_touch_all:
	160 (20.0%), b_finish: 1.91 (0.2%), tests_pri_0: 408 (51.0%),
	check_dkim_signature: 0.91 (0.1%), check_dkim_adsp: 4.7 (0.6%),
	poll_dns_idle: 0.42 (0.1%), tests_pri_10: 2.5 (0.3%), tests_pri_500:
	13 (1.7%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [External] Re: [PATCH] pid_ns: support pidns switching between
 sibling
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)

yunhui cui <cuiyunhui@bytedance.com> writes:

> Hi Eric,
>
> On Thu, Oct 12, 2023 at 11:31=E2=80=AFAM Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> The check you are deleting is what verifies the pid namespaces you are
>> attempting to change pid_ns_for_children to is a member of the tasks
>> current pid namespace (aka task_active_pid_ns).
>>
>>
>> There is a perfectly good comment describing why what you are attempting
>> to do is unsupportable.
>>
>>         /*
>>          * Only allow entering the current active pid namespace
>>          * or a child of the current active pid namespace.
>>          *
>>          * This is required for fork to return a usable pid value and
>>          * this maintains the property that processes and their
>>          * children can not escape their current pid namespace.
>>          */
>>
>>
>> If you pick a pid namespace that does not meet the restrictions you are
>> removing the pid of the new child can not be mapped into the pid
>> namespace of the parent that called setns.
>>
>> AKA the following code can not work.
>>
>> pid =3D fork();
>> if (!pid) {
>>         /* child */
>>         do_something();
>>         _exit(0);
>> }
>> waitpid(pid);
>
> Sorry, I don't understand what you mean here.

What I mean is that if your simple patch was adopted,
then the classic way of controlling a fork would fail.

	pid =3D fork()
        ^--------------- Would return 0 for both parent and child
        ^--------------- Look at pid_nr_ns to understand.
        if (!pid() {
		/* child */
		do_something();
		_exit(0);
	}
	waitpid(pid);

For your use case there are more serious problems as well.  The entire
process hierarchy built would be incorrect.   Which means children
signaling parents when they exit would be incorrect, and that parents
would not be able to wait on their children.

I do understand the desire to want to cow the memory space of all of the
processes.  That can potentially save a lot of resources.

In other checkpoint/restart scenarios people have been using userfaultfd
to get a similar benefit.

I suggest you look at the CRIU project.

Eric


