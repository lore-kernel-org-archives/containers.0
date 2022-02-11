Received: from out01.mta.xmission.com (out01.mta.xmission.com [166.70.13.231])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E985D7E
	for <containers@lists.linux.dev>; Fri, 11 Feb 2022 20:15:36 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52]:52364)
	by out01.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1nIc2M-002ugY-Bt; Fri, 11 Feb 2022 12:56:58 -0700
Received: from ip68-227-174-4.om.om.cox.net ([68.227.174.4]:51124 helo=email.froward.int.ebiederm.org.xmission.com)
	by in02.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1nIc2J-00A0GN-BV; Fri, 11 Feb 2022 12:56:57 -0700
From: "Eric W. Biederman" <ebiederm@xmission.com>
To: Alexey Gladkov <legion@kernel.org>
Cc: linux-kernel@vger.kernel.org,  Kees Cook <keescook@chromium.org>,  Shuah
 Khan <shuah@kernel.org>,  Christian Brauner <brauner@kernel.org>,  Solar
 Designer <solar@openwall.com>,  Ran Xiaokai <ran.xiaokai@zte.com.cn>,
  containers@lists.linux.dev,  Michal =?utf-8?Q?Koutn=C3=BD?=
 <mkoutny@suse.com>
References: <87o83e2mbu.fsf@email.froward.int.ebiederm.org>
	<20220211021324.4116773-6-ebiederm@xmission.com>
	<20220211113454.socmlrne5heux7q7@example.org>
	<87sfspz409.fsf@email.froward.int.ebiederm.org>
	<20220211184041.dlqjk2fgdnkmtpe3@example.org>
Date: Fri, 11 Feb 2022 13:56:29 -0600
In-Reply-To: <20220211184041.dlqjk2fgdnkmtpe3@example.org> (Alexey Gladkov's
	message of "Fri, 11 Feb 2022 19:40:41 +0100")
Message-ID: <87zgmxxjma.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1nIc2J-00A0GN-BV;;;mid=<87zgmxxjma.fsf@email.froward.int.ebiederm.org>;;;hst=in02.mta.xmission.com;;;ip=68.227.174.4;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX19E7a/eaKFtZzvaoEdxpINrDSEu8ypYCyc=
X-SA-Exim-Connect-IP: 68.227.174.4
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa07.xmission.com
X-Spam-Level: *****
X-Spam-Status: No, score=5.2 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,LotsOfNums_01,TR_XM_BayesUnsub,T_SCC_BODY_TEXT_LINE,
	T_TM2_M_HEADER_IN_MSG,T_TooManySym_01,XMNoVowels,XMSubLong,XM_B_Unsub
	autolearn=disabled version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.5000]
	*  1.5 XMNoVowels Alpha-numberic number with no vowels
	*  0.7 XMSubLong Long Subject
	*  1.2 LotsOfNums_01 BODY: Lots of long strings of numbers
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa07 1397; Body=1 Fuz1=1 Fuz2=1]
	*  0.5 XM_B_Unsub Unsubscribe in body of email but missing unsubscribe
	*       header
	* -0.0 T_SCC_BODY_TEXT_LINE No description available.
	*  0.0 T_TooManySym_01 4+ unique symbols in subject
	*  1.5 TR_XM_BayesUnsub High bayes score with no unsubscribe header
X-Spam-DCC: XMission; sa07 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: *****;Alexey Gladkov <legion@kernel.org>
X-Spam-Relay-Country: 
X-Spam-Timing: total 2407 ms - load_scoreonly_sql: 0.04 (0.0%),
	signal_user_changed: 11 (0.5%), b_tie_ro: 10 (0.4%), parse: 1.39
	(0.1%), extract_message_metadata: 15 (0.6%), get_uri_detail_list: 3.5
	(0.1%), tests_pri_-1000: 14 (0.6%), tests_pri_-950: 1.27 (0.1%),
	tests_pri_-900: 1.01 (0.0%), tests_pri_-90: 1912 (79.4%), check_bayes:
	1910 (79.4%), b_tokenize: 12 (0.5%), b_tok_get_all: 10 (0.4%),
	b_comp_prob: 3.2 (0.1%), b_tok_touch_all: 1881 (78.1%), b_finish: 1.03
	(0.0%), tests_pri_0: 438 (18.2%), check_dkim_signature: 0.59 (0.0%),
	check_dkim_adsp: 2.6 (0.1%), poll_dns_idle: 0.85 (0.0%), tests_pri_10:
	2.2 (0.1%), tests_pri_500: 7 (0.3%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [PATCH 6/8] ucounts: Handle inc_rlimit_ucounts wrapping in fork
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)

Alexey Gladkov <legion@kernel.org> writes:

> On Fri, Feb 11, 2022 at 11:50:46AM -0600, Eric W. Biederman wrote:
>> Alexey Gladkov <legion@kernel.org> writes:
>> 
>> > On Thu, Feb 10, 2022 at 08:13:22PM -0600, Eric W. Biederman wrote:
>> >> Move inc_rlimit_ucounts from copy_creds into copy_process immediately
>> >> after copy_creds where it can be called exactly once.  Test for and
>> >> handle it when inc_rlimit_ucounts returns LONG_MAX indicating the
>> >> count has wrapped.
>> >> 
>> >> This is good hygenine and fixes a theoretical bug.  In practice
>> >> PID_MAX_LIMIT is at most 2^22 so there is not a chance the number of
>> >> processes would ever wrap even on an architecture with a 32bit long.
>> >> 
>> >> Fixes: 21d1c5e386bc ("Reimplement RLIMIT_NPROC on top of ucounts")
>> >> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> >> ---
>> >>  kernel/cred.c | 2 --
>> >>  kernel/fork.c | 2 ++
>> >>  2 files changed, 2 insertions(+), 2 deletions(-)
>> >> 
>> >> diff --git a/kernel/cred.c b/kernel/cred.c
>> >> index 229cff081167..96d5fd6ff26f 100644
>> >> --- a/kernel/cred.c
>> >> +++ b/kernel/cred.c
>> >> @@ -358,7 +358,6 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
>> >>  		kdebug("share_creds(%p{%d,%d})",
>> >>  		       p->cred, atomic_read(&p->cred->usage),
>> >>  		       read_cred_subscribers(p->cred));
>> >> -		inc_rlimit_ucounts(task_ucounts(p), UCOUNT_RLIMIT_NPROC, 1);
>> >>  		return 0;
>> >>  	}
>> >>  
>> >> @@ -395,7 +394,6 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
>> >>  #endif
>> >>  
>> >>  	p->cred = p->real_cred = get_cred(new);
>> >> -	inc_rlimit_ucounts(task_ucounts(p), UCOUNT_RLIMIT_NPROC, 1);
>> >>  	alter_cred_subscribers(new, 2);
>> >>  	validate_creds(new);
>> >>  	return 0;
>> >> diff --git a/kernel/fork.c b/kernel/fork.c
>> >> index 6f62d37f3650..69333078259c 100644
>> >> --- a/kernel/fork.c
>> >> +++ b/kernel/fork.c
>> >> @@ -2026,6 +2026,8 @@ static __latent_entropy struct task_struct *copy_process(
>> >>  		goto bad_fork_free;
>> >>  
>> >>  	retval = -EAGAIN;
>> >> +	if (inc_rlimit_ucounts(task_ucounts(p), UCOUNT_RLIMIT_NPROC, 1) == LONG_MAX)
>> >> +		goto bad_fork_cleanup_count;
>> >>  	if (is_ucounts_overlimit(task_ucounts(p), UCOUNT_RLIMIT_NPROC, rlimit(RLIMIT_NPROC))) {
>> >>  		if ((task_ucounts(p) != &init_ucounts) &&
>> >>  		    !capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN))
>> >
>> > It might make sense to do something like:
>> >
>> > 	if (inc_rlimit_ucounts_overlimit(task_ucounts(p), UCOUNT_RLIMIT_NPROC, 1, rlimit(RLIMIT_NPROC)) == LONG_MAX) {
>> > 		if ((task_ucounts(p) != &init_ucounts) &&
>> > 		    !capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN))
>> >
>> > and the new function:
>> >
>> > long inc_rlimit_ucounts_overlimit(struct ucounts *ucounts, enum ucount_type type, long v, unsigned long rlimit)
>> > {
>> > 	struct ucounts *iter;
>> > 	long ret = 0;
>> > 	long max = rlimit;
>> > 	if (rlimit > LONG_MAX)
>> > 		max = LONG_MAX;
>> > 	for (iter = ucounts; iter; iter = iter->ns->ucounts) {
>> > 		long new = atomic_long_add_return(v, &iter->ucount[type]);
>> > 		if (new < 0 || new > max)
>> > 			ret = LONG_MAX;
>> > 		else if (iter == ucounts)
>> > 			ret = new;
>> > 		max = READ_ONCE(iter->ns->ucount_max[type]);
>> > 	}
>> > 	return ret;
>> > }
>> >
>> > This will avoid double checking the same userns tree.
>> >
>> > Or even modify inc_rlimit_ucounts. This function is used elsewhere like
>> > this:
>> >
>> >
>> > msgqueue = inc_rlimit_ucounts(info->ucounts, UCOUNT_RLIMIT_MSGQUEUE, mq_bytes);
>> > if (msgqueue == LONG_MAX || msgqueue > rlimit(RLIMIT_MSGQUEUE)) {
>> >
>> >
>> > memlock = inc_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_MEMLOCK, locked);
>> > if (!allowed && (memlock == LONG_MAX || memlock > lock_limit) && !capable(CAP_IPC_LOCK)) {
>> >
>> >
>> > In all cases, we have max value for comparison.
>> 
>> Good point.   The downside is that it means we can't use the same code
>> in exec.  The upside is that the code is more idiomatic.
>
> My suggestion was before I saw the 8/8 patch :)
>
> We can make something like:
>
> static inline bool is_nproc_overlimit(struct task_struct *task)
> {
> 	return (task_ucounts(task) != &init_ucounts) &&
> 		!has_capability(task, CAP_SYS_RESOURCE) &&
> 		!has_capability(task, CAP_SYS_ADMIN);
> }
>
> In copy_process:
>
> if (inc_rlimit_ucounts_overlimit(task_ucounts(p), UCOUNT_RLIMIT_NPROC, 1, rlimit(RLIMIT_NPROC)) == LONG_MAX) {
> 	if (is_nproc_overlimit(p))
> 		goto bad_fork_cleanup_count;
> }
>
> In do_execveat_common:
>
> if ((current->flags & PF_NPROC_CHECK) &&
>     is_ucounts_overlimit(current_ucounts(), UCOUNT_RLIMIT_NPROC, rlimit(RLIMIT_NPROC)) &&
>     is_nproc_overlimit(current)) {
> 	retval = -EAGAIN;
> 	goto out_ret;
> }


The more I think about it the more I suspect 8/8 is the wrong way to go.

The report is that adding the capability calls in kernel/sys.c which I
moved into execve broke apache.  As the change was about removing
inconsistencies I expect I should just start with the revert and keep
the difference between the two code paths.

My gut feel is that both the capable and the magic exception of a user
are wrong.  If I am wrong people can report a bug and the code can get
fixed.

But definitely a bug fix branch is the wrong place to be expanding what
is allowed without it clearly being a bug.

Eric

