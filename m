Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68D5B70
	for <containers@lists.linux.dev>; Fri, 21 May 2021 18:11:47 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52])
	by out01.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lk8BX-000zLU-Nh; Fri, 21 May 2021 10:39:39 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95] helo=fess.xmission.com)
	by in02.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1lk8BW-00Ahr4-PK; Fri, 21 May 2021 10:39:39 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Sargun Dhillon <sargun@sargun.me>
Cc: Linux Containers <containers@lists.linux.dev>,  LKML
 <linux-kernel@vger.kernel.org>,  Kees Cook <keescook@chromium.org>,
  Christian Brauner <christian.brauner@ubuntu.com>,  Andy Lutomirski
 <luto@kernel.org>,  Tycho Andersen <tycho@tycho.pizza>,  Giuseppe Scrivano
 <gscrivan@redhat.com>,  Rodrigo Campos <rodrigo@kinvolk.io>,  Mauricio
 =?utf-8?Q?V=C3=A1squez?= Bernal <mauricio@kinvolk.io>
References: <CAMp4zn93WRF5u=et=detunN7exhQNoFctr-7Qb8-a9=As8vaQw@mail.gmail.com>
Date: Fri, 21 May 2021 11:39:27 -0500
In-Reply-To: <CAMp4zn93WRF5u=et=detunN7exhQNoFctr-7Qb8-a9=As8vaQw@mail.gmail.com>
	(Sargun Dhillon's message of "Fri, 21 May 2021 09:23:52 -0700")
Message-ID: <m1eee0xcqo.fsf@fess.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1lk8BW-00Ahr4-PK;;;mid=<m1eee0xcqo.fsf@fess.ebiederm.org>;;;hst=in02.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX1/Qtp8BV6nWzxx0wp6SUitiWRpy1wcXxlk=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa06.xmission.com
X-Spam-Level: 
X-Spam-Status: No, score=-0.2 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_TM2_M_HEADER_IN_MSG autolearn=disabled
	version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4336]
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa06 1397; Body=1 Fuz1=1 Fuz2=1]
X-Spam-DCC: XMission; sa06 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ;Sargun Dhillon <sargun@sargun.me>
X-Spam-Relay-Country: 
X-Spam-Timing: total 389 ms - load_scoreonly_sql: 0.33 (0.1%),
	signal_user_changed: 12 (3.1%), b_tie_ro: 10 (2.6%), parse: 0.99
	(0.3%), extract_message_metadata: 12 (3.1%), get_uri_detail_list: 1.29
	(0.3%), tests_pri_-1000: 12 (3.2%), tests_pri_-950: 1.31 (0.3%),
	tests_pri_-900: 1.08 (0.3%), tests_pri_-90: 67 (17.3%), check_bayes:
	66 (16.9%), b_tokenize: 6 (1.6%), b_tok_get_all: 7 (1.9%),
	b_comp_prob: 2.2 (0.6%), b_tok_touch_all: 47 (12.1%), b_finish: 0.76
	(0.2%), tests_pri_0: 270 (69.4%), check_dkim_signature: 0.82 (0.2%),
	check_dkim_adsp: 2.2 (0.6%), poll_dns_idle: 0.56 (0.1%), tests_pri_10:
	2.2 (0.6%), tests_pri_500: 6 (1.7%), rewrite_mail: 0.00 (0.0%)
Subject: Re: Preemption Signal Management
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)

Sargun Dhillon <sargun@sargun.me> writes:

> Andy pointed out that we need a mechanism to determine whether or
> notifications are preempted. He suggested we use EPOLLPRI to indicate
> whether or not notifications are preempted. My outstanding question is
> whether or not we need to be able to get insight of what caused the
> preemption, and to which notification.

Can I have some context please?  Perhaps links to the previous
conversations?

The subject sounds like you are talking about those things that are
delivered as the result of kill(2) but the rest does not.  What are
notification ids?

Is this a seccomp design choice?

> In the past, Christian has suggested just background polling
> notification IDs for validity, which is a fine mechanism to determine
> that preemption has occurred. We could raise EPOLLPRI whenever a
> notification has changed into the preempted state, but that would
> require an O(n) operations across all outstanding notifications to
> determine which one was preempted, and in addition, it doesn't give a
> lot of information as to why the preemption occurred (fatal signal,
> preemption?).
>
> In order to try to break this into small parts, I suggest:
> 1. We make it so EPOLLPRI is raised (always) on preempted notifications
> 2. We allow the user to set a flag to "track" notifications. If they
> specify this flag, they can then run a "stronger" ioctl -- let's say
> SECCOMP_IOCTL_NOTIF_STATUS, which, if the flag was specified upon
> receiving the notification will return the current state of the
> notification and if a signal preempted it, it will always do that.
>
> ---
> Alternatively (and this is my preference), we add another filter flag,
> like SECCOMP_FILTER_FLAG_NOTIF_PREEMPT, which changes the behaviour
> to:
> 1. Raise EPOLLPRI on preempted notifications
> 2. All preemption notifications must be cleared via
> SECCOMP_IOCTL_NOTIF_RECV_STATUS.
>
> Opinions?
