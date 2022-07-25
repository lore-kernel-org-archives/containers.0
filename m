Received: from out02.mta.xmission.com (out02.mta.xmission.com [166.70.13.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE414366
	for <containers@lists.linux.dev>; Mon, 25 Jul 2022 16:40:38 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51]:38100)
	by out02.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1oG0l6-003w3H-H7; Mon, 25 Jul 2022 10:16:40 -0600
Received: from ip68-227-174-4.om.om.cox.net ([68.227.174.4]:58050 helo=email.froward.int.ebiederm.org.xmission.com)
	by in01.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1oG0l5-006JxI-Hs; Mon, 25 Jul 2022 10:16:40 -0600
From: "Eric W. Biederman" <ebiederm@xmission.com>
To: Alexey Gladkov <legion@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>,  Linux Containers
 <containers@lists.linux.dev>,  Andrew Morton <akpm@linux-foundation.org>,
  Christian Brauner <brauner@kernel.org>,  Kees Cook
 <keescook@chromium.org>,  Manfred Spraul <manfred@colorfullife.com>
References: <54e6b6b1b430537748a7136e854923498443f78a.1657642613.git.legion@kernel.org>
Date: Mon, 25 Jul 2022 11:16:07 -0500
In-Reply-To: <54e6b6b1b430537748a7136e854923498443f78a.1657642613.git.legion@kernel.org>
	(Alexey Gladkov's message of "Tue, 12 Jul 2022 18:17:38 +0200")
Message-ID: <87wnc1i2wo.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1oG0l5-006JxI-Hs;;;mid=<87wnc1i2wo.fsf@email.froward.int.ebiederm.org>;;;hst=in01.mta.xmission.com;;;ip=68.227.174.4;;;frm=ebiederm@xmission.com;;;spf=softfail
X-XM-AID: U2FsdGVkX1+7xsvv3hql2OPojijov5d5m6fwK6evo0A=
X-SA-Exim-Connect-IP: 68.227.174.4
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa07.xmission.com
X-Spam-Level: ***
X-Spam-Status: No, score=3.0 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_TM2_M_HEADER_IN_MSG,XMSubLong,XM_SPF_SoftFail
	autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4965]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa07 1397; Body=1 Fuz1=1 Fuz2=1]
	*  2.5 XM_SPF_SoftFail SPF-SoftFail
X-Spam-DCC: XMission; sa07 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ***;Alexey Gladkov <legion@kernel.org>
X-Spam-Relay-Country: 
X-Spam-Timing: total 465 ms - load_scoreonly_sql: 0.08 (0.0%),
	signal_user_changed: 11 (2.5%), b_tie_ro: 10 (2.1%), parse: 1.54
	(0.3%), extract_message_metadata: 5 (1.2%), get_uri_detail_list: 2.3
	(0.5%), tests_pri_-1000: 5 (1.2%), tests_pri_-950: 1.90 (0.4%),
	tests_pri_-900: 1.55 (0.3%), tests_pri_-90: 116 (25.0%), check_bayes:
	114 (24.6%), b_tokenize: 8 (1.8%), b_tok_get_all: 8 (1.7%),
	b_comp_prob: 2.2 (0.5%), b_tok_touch_all: 92 (19.8%), b_finish: 1.03
	(0.2%), tests_pri_0: 295 (63.3%), check_dkim_signature: 0.64 (0.1%),
	check_dkim_adsp: 2.9 (0.6%), poll_dns_idle: 1.23 (0.3%), tests_pri_10:
	2.3 (0.5%), tests_pri_500: 12 (2.5%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [PATCH v1] sysctl: Allow change system v ipc sysctls inside ipc
 namespace
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)

Alexey Gladkov <legion@kernel.org> writes:

> Rootless containers are not allowed to modify kernel IPC parameters such
> as kernel.msgmnb.
>
> It seems to me that we can allow customization of these parameters if
> the user has CAP_SYS_RESOURCE in that ipc namespace.
>
> CAP_SYS_RESOURCE is already needed in order to overcome mqueue limits
> (msg_max and msgsize_max).


For changing the permissions on who can modify the SysV limits, I don't
think this change is safe.  I don't see anything that will prevent abuse
if anyone can modify these limits.  Replacing the ordinary unix DAC
permission check with ns_capable will allow anyone to modify the limits.


That said there is RLIMIT_MSGQUEUE that limits the posix messages queues
so those should be safe to allow anyone to modify their limits.

The code in mqueue_get_inode is where that limiting happens.

For the posix message queues all that should be needed is to change the
owner of the sysctl files from the global root to the user namespace
root.  There are also two capable calls in ipc/mqueue.c that can
probably be changed to ns_capable calls.


The only posix message queue limit that I don't immediately see
something that will prevent abuse of is /proc/sys/fs/mqueue/queus_max.
That probably still runs into RLIMIT_MSGQUEUE somewhere but it was
not immediately obvious at first glance.

Eric






>
> Signed-off-by: Alexey Gladkov <legion@kernel.org>
> ---
>  ipc/ipc_sysctl.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/ipc/ipc_sysctl.c b/ipc/ipc_sysctl.c
> index ef313ecfb53a..e79452867720 100644
> --- a/ipc/ipc_sysctl.c
> +++ b/ipc/ipc_sysctl.c
> @@ -193,16 +193,19 @@ static int set_is_seen(struct ctl_table_set *set)
>  static int ipc_permissions(struct ctl_table_header *head, struct ctl_table *table)
>  {
>  	int mode = table->mode;
> -
> -#ifdef CONFIG_CHECKPOINT_RESTORE
>  	struct ipc_namespace *ns = current->nsproxy->ipc_ns;
>  
> +#ifdef CONFIG_CHECKPOINT_RESTORE
>  	if (((table->data == &ns->ids[IPC_SEM_IDS].next_id) ||
>  	     (table->data == &ns->ids[IPC_MSG_IDS].next_id) ||
>  	     (table->data == &ns->ids[IPC_SHM_IDS].next_id)) &&
>  	    checkpoint_restore_ns_capable(ns->user_ns))
>  		mode = 0666;
> +	else
>  #endif
> +	if (ns_capable(ns->user_ns, CAP_SYS_RESOURCE))
> +		mode = 0666;
> +
>  	return mode;
>  }
