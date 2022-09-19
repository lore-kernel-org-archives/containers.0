Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFAB16127
	for <containers@lists.linux.dev>; Mon, 19 Sep 2022 15:29:10 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51]:51716)
	by out01.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1oaIhp-005WyF-Ma; Mon, 19 Sep 2022 09:29:09 -0600
Received: from ip68-110-29-46.om.om.cox.net ([68.110.29.46]:41908 helo=email.froward.int.ebiederm.org.xmission.com)
	by in01.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1oaIho-001xqf-J0; Mon, 19 Sep 2022 09:29:09 -0600
From: "Eric W. Biederman" <ebiederm@xmission.com>
To: Alexey Gladkov <legion@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>,  Linux Containers
 <containers@lists.linux.dev>,  linux-doc@vger.kernel.org,  Andrew Morton
 <akpm@linux-foundation.org>,  Christian Brauner <brauner@kernel.org>,
  Kees Cook <keescook@chromium.org>,  Manfred Spraul
 <manfred@colorfullife.com>,  Jonathan Corbet <corbet@lwn.net>
References: <87wnc1i2wo.fsf@email.froward.int.ebiederm.org>
	<cover.1660664258.git.legion@kernel.org>
	<9b566b9b7313300d60b7dfd785ab041bed757ae0.1660664258.git.legion@kernel.org>
Date: Mon, 19 Sep 2022 10:29:02 -0500
In-Reply-To: <9b566b9b7313300d60b7dfd785ab041bed757ae0.1660664258.git.legion@kernel.org>
	(Alexey Gladkov's message of "Tue, 16 Aug 2022 17:42:45 +0200")
Message-ID: <87bkrb2xj5.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1oaIho-001xqf-J0;;;mid=<87bkrb2xj5.fsf@email.froward.int.ebiederm.org>;;;hst=in01.mta.xmission.com;;;ip=68.110.29.46;;;frm=ebiederm@xmission.com;;;spf=softfail
X-XM-AID: U2FsdGVkX1+4L+9MyEPXt7wTGczqMWy7gxvNtcsX4Dk=
X-SA-Exim-Connect-IP: 68.110.29.46
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa05.xmission.com
X-Spam-Level: ***
X-Spam-Status: No, score=3.0 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_SCC_BODY_TEXT_LINE,T_TM2_M_HEADER_IN_MSG,
	XMSubLong,XM_SPF_SoftFail autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4994]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa05 1397; Body=1 Fuz1=1 Fuz2=1]
	*  2.5 XM_SPF_SoftFail SPF-SoftFail
	* -0.0 T_SCC_BODY_TEXT_LINE No description available.
X-Spam-DCC: XMission; sa05 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ***;Alexey Gladkov <legion@kernel.org>
X-Spam-Relay-Country: 
X-Spam-Timing: total 605 ms - load_scoreonly_sql: 0.05 (0.0%),
	signal_user_changed: 13 (2.1%), b_tie_ro: 11 (1.8%), parse: 1.44
	(0.2%), extract_message_metadata: 18 (3.0%), get_uri_detail_list: 3.0
	(0.5%), tests_pri_-1000: 20 (3.3%), tests_pri_-950: 1.75 (0.3%),
	tests_pri_-900: 1.31 (0.2%), tests_pri_-90: 136 (22.5%), check_bayes:
	134 (22.1%), b_tokenize: 10 (1.7%), b_tok_get_all: 9 (1.5%),
	b_comp_prob: 2.9 (0.5%), b_tok_touch_all: 108 (17.9%), b_finish: 1.16
	(0.2%), tests_pri_0: 400 (66.1%), check_dkim_signature: 0.73 (0.1%),
	check_dkim_adsp: 3.7 (0.6%), poll_dns_idle: 1.26 (0.2%), tests_pri_10:
	2.1 (0.4%), tests_pri_500: 7 (1.1%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [PATCH v1 3/3] docs: Add information about ipc sysctls limitations
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)

Alexey Gladkov <legion@kernel.org> writes:

> After 25b21cb2f6d6 ("[PATCH] IPC namespace core") and 4e9823111bdc
> ("[PATCH] IPC namespace - shm") the shared memory page count stopped
> being global and started counting per ipc namespace. The documentation
> and shmget(2) still says that shmall is a global option.
>
> shmget(2):
>
> SHMALL System-wide limit on the total amount of shared memory, measured
> in units of the system page size. On Linux, this limit can be read and
> modified via /proc/sys/kernel/shmall.
>
> I think the changes made in 2006 should be documented.

Agreed. Documenting these limits only apply to their ipc namespace is
overdue.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

> Signed-off-by: Alexey Gladkov <legion@kernel.org>
> ---
>  Documentation/admin-guide/sysctl/kernel.rst | 14 +++++++++++---
>  1 file changed, 11 insertions(+), 3 deletions(-)
>
> diff --git a/Documentation/admin-guide/sysctl/kernel.rst b/Documentation/admin-guide/sysctl/kernel.rst
> index ddccd1077462..9ad344b5e7a1 100644
> --- a/Documentation/admin-guide/sysctl/kernel.rst
> +++ b/Documentation/admin-guide/sysctl/kernel.rst
> @@ -541,6 +541,9 @@ default (``MSGMNB``).
>  ``msgmni`` is the maximum number of IPC queues. 32000 by default
>  (``MSGMNI``).
>  
> +All of these parameters are set per ipc namespace. The maximum number of bytes
> +in POSIX message queues is limited by ``RLIMIT_MSGQUEUE``. This limit is
> +respected hierarchically in the each user namespace.
>  
>  msg_next_id, sem_next_id, and shm_next_id (System V IPC)
>  ========================================================
> @@ -1169,15 +1172,20 @@ are doing anyway :)
>  shmall
>  ======
>  
> -This parameter sets the total amount of shared memory pages that
> -can be used system wide. Hence, ``shmall`` should always be at least
> -``ceil(shmmax/PAGE_SIZE)``.
> +This parameter sets the total amount of shared memory pages that can be used
> +inside ipc namespace. The shared memory pages counting occurs for each ipc
> +namespace separately and is not inherited. Hence, ``shmall`` should always be at
> +least ``ceil(shmmax/PAGE_SIZE)``.
>  
>  If you are not sure what the default ``PAGE_SIZE`` is on your Linux
>  system, you can run the following command::
>  
>  	# getconf PAGE_SIZE
>  
> +To reduce or disable the ability to allocate shared memory, you must create a
> +new ipc namespace, set this parameter to the required value and prohibit the
> +creation of a new ipc namespace in the current user namespace or cgroups can
> +be used.
>  
>  shmmax
>  ======
