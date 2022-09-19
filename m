Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA6577C
	for <containers@lists.linux.dev>; Mon, 19 Sep 2022 16:16:10 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51]:57352)
	by out03.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1oaIgi-009wR6-LX; Mon, 19 Sep 2022 09:28:00 -0600
Received: from ip68-110-29-46.om.om.cox.net ([68.110.29.46]:51232 helo=email.froward.int.ebiederm.org.xmission.com)
	by in01.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1oaIgh-001xfh-Ow; Mon, 19 Sep 2022 09:28:00 -0600
From: "Eric W. Biederman" <ebiederm@xmission.com>
To: Alexey Gladkov <legion@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>,  Linux Containers
 <containers@lists.linux.dev>,  Andrew Morton <akpm@linux-foundation.org>,
  Christian Brauner <brauner@kernel.org>,  Kees Cook
 <keescook@chromium.org>,  Manfred Spraul <manfred@colorfullife.com>
References: <87wnc1i2wo.fsf@email.froward.int.ebiederm.org>
	<cover.1660664258.git.legion@kernel.org>
	<0e095acd72553868925b116d778357eb019796a2.1660664258.git.legion@kernel.org>
Date: Mon, 19 Sep 2022 10:27:53 -0500
In-Reply-To: <0e095acd72553868925b116d778357eb019796a2.1660664258.git.legion@kernel.org>
	(Alexey Gladkov's message of "Tue, 16 Aug 2022 17:42:44 +0200")
Message-ID: <87h7132xl2.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1oaIgh-001xfh-Ow;;;mid=<87h7132xl2.fsf@email.froward.int.ebiederm.org>;;;hst=in01.mta.xmission.com;;;ip=68.110.29.46;;;frm=ebiederm@xmission.com;;;spf=softfail
X-XM-AID: U2FsdGVkX1+6kbp/GAjBNzN409XC+yQuuXQX0PMBISc=
X-SA-Exim-Connect-IP: 68.110.29.46
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa07.xmission.com
X-Spam-Level: ***
X-Spam-Status: No, score=3.0 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,T_SCC_BODY_TEXT_LINE,T_TM2_M_HEADER_IN_MSG,
	XMSubLong,XM_SPF_SoftFail autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.5000]
	*  0.7 XMSubLong Long Subject
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa07 1397; Body=1 Fuz1=1 Fuz2=1]
	*  2.5 XM_SPF_SoftFail SPF-SoftFail
	* -0.0 T_SCC_BODY_TEXT_LINE No description available.
X-Spam-DCC: XMission; sa07 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ***;Alexey Gladkov <legion@kernel.org>
X-Spam-Relay-Country: 
X-Spam-Timing: total 347 ms - load_scoreonly_sql: 0.03 (0.0%),
	signal_user_changed: 11 (3.1%), b_tie_ro: 9 (2.7%), parse: 0.86 (0.2%),
	 extract_message_metadata: 3.3 (0.9%), get_uri_detail_list: 1.47
	(0.4%), tests_pri_-1000: 3.5 (1.0%), tests_pri_-950: 1.25 (0.4%),
	tests_pri_-900: 0.98 (0.3%), tests_pri_-90: 57 (16.4%), check_bayes:
	56 (16.1%), b_tokenize: 7 (2.1%), b_tok_get_all: 6 (1.6%),
	b_comp_prob: 1.94 (0.6%), b_tok_touch_all: 38 (10.9%), b_finish: 0.82
	(0.2%), tests_pri_0: 250 (72.2%), check_dkim_signature: 0.55 (0.2%),
	check_dkim_adsp: 2.6 (0.8%), poll_dns_idle: 0.68 (0.2%), tests_pri_10:
	2.3 (0.7%), tests_pri_500: 8 (2.4%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [PATCH v1 2/3] sysctl: Allow to change limits for posix
 messages queues
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)

Alexey Gladkov <legion@kernel.org> writes:

> All parameters of posix messages queues (queues_max/msg_max/msgsize_max)
> end up being limited by RLIMIT_MSGQUEUE. The code in mqueue_get_inode is
> where that limiting happens.
>
> The RLIMIT_MSGQUEUE is bound to the user namespace and is counted
> hierarchically.
>
> We can allow root in the user namespace to modify the posix messages
> queues parameters.

This looks good from 10,000 feet.  But the same nits with setting
mode in mq_permissions as in ipc_set_permissions in your other patch.

Eric

> Signed-off-by: Alexey Gladkov <legion@kernel.org>
> ---
>  ipc/mq_sysctl.c | 36 ++++++++++++++++++++++++++++++++++++
>  1 file changed, 36 insertions(+)
>
> diff --git a/ipc/mq_sysctl.c b/ipc/mq_sysctl.c
> index fbf6a8b93a26..39dcf086b7c2 100644
> --- a/ipc/mq_sysctl.c
> +++ b/ipc/mq_sysctl.c
> @@ -12,6 +12,7 @@
>  #include <linux/stat.h>
>  #include <linux/capability.h>
>  #include <linux/slab.h>
> +#include <linux/cred.h>
>  
>  static int msg_max_limit_min = MIN_MSGMAX;
>  static int msg_max_limit_max = HARD_MSGMAX;
> @@ -76,8 +77,43 @@ static int set_is_seen(struct ctl_table_set *set)
>  	return &current->nsproxy->ipc_ns->mq_set == set;
>  }
>  
> +static int mq_permissions(struct ctl_table_header *head, struct ctl_table *table)
> +{
> +	struct ipc_namespace *ns =
> +		container_of(head->set, struct ipc_namespace, mq_set);
> +
> +	if (ns->user_ns != &init_user_ns) {
> +		kuid_t ns_root_uid = make_kuid(ns->user_ns, 0);
> +		kgid_t ns_root_gid = make_kgid(ns->user_ns, 0);
> +
> +		if (uid_valid(ns_root_uid) && uid_eq(current_euid(), ns_root_uid))
> +			return  table->mode >> 6;
> +
> +		if (gid_valid(ns_root_gid) && in_egroup_p(ns_root_gid))
> +			return table->mode >> 3;
> +	}
> +
> +	return table->mode;
> +}
> +
> +static void mq_set_ownership(struct ctl_table_header *head,
> +			     struct ctl_table *table,
> +			     kuid_t *uid, kgid_t *gid)
> +{
> +	struct ipc_namespace *ns =
> +		container_of(head->set, struct ipc_namespace, mq_set);
> +
> +	kuid_t ns_root_uid = make_kuid(ns->user_ns, 0);
> +	kgid_t ns_root_gid = make_kgid(ns->user_ns, 0);
> +
> +	*uid = uid_valid(ns_root_uid) ? ns_root_uid : GLOBAL_ROOT_UID;
> +	*gid = gid_valid(ns_root_gid) ? ns_root_gid : GLOBAL_ROOT_GID;
> +}
> +
>  static struct ctl_table_root set_root = {
>  	.lookup = set_lookup,
> +	.permissions = mq_permissions,
> +	.set_ownership = mq_set_ownership,
>  };
>  
>  bool setup_mq_sysctls(struct ipc_namespace *ns)
