Received: from out02.mta.xmission.com (out02.mta.xmission.com [166.70.13.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFA483FC2
	for <containers@lists.linux.dev>; Mon, 23 Aug 2021 21:51:54 +0000 (UTC)
Received: from in02.mta.xmission.com ([166.70.13.52]:45198)
	by out02.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1mIHXZ-007U4Y-7W; Mon, 23 Aug 2021 15:31:33 -0600
Received: from ip68-227-160-95.om.om.cox.net ([68.227.160.95]:37324 helo=email.xmission.com)
	by in02.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1mIHXY-003d48-4S; Mon, 23 Aug 2021 15:31:32 -0600
From: ebiederm@xmission.com (Eric W. Biederman)
To: Alexey Gladkov <legion@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>,  Linux Containers <containers@lists.linux.dev>,  syzbot+01985d7909f9468f013c@syzkaller.appspotmail.com
References: <000000000000b1f4d305c9ef72ad@google.com>
	<97433b1742c3331f02ad92de5a4f07d673c90613.1629735352.git.legion@kernel.org>
Date: Mon, 23 Aug 2021 16:31:25 -0500
In-Reply-To: <97433b1742c3331f02ad92de5a4f07d673c90613.1629735352.git.legion@kernel.org>
	(Alexey Gladkov's message of "Mon, 23 Aug 2021 18:16:33 +0200")
Message-ID: <87tujfrgpe.fsf@disp2133>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1mIHXY-003d48-4S;;;mid=<87tujfrgpe.fsf@disp2133>;;;hst=in02.mta.xmission.com;;;ip=68.227.160.95;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX19pp4qrKf/JfCjQ/zA7PnEgzjip6wxQ7b8=
X-SA-Exim-Connect-IP: 68.227.160.95
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa02.xmission.com
X-Spam-Level: ***
X-Spam-Status: No, score=3.1 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,FVGT_m_MULTI_ODD,LotsOfNums_01,
	T_TM2_M_HEADER_IN_MSG,XMSubLong,XM_Sft_Co_L33T autolearn=disabled
	version=3.4.2
X-Spam-Virus: No
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4996]
	*  0.7 XMSubLong Long Subject
	*  1.2 LotsOfNums_01 BODY: Lots of long strings of numbers
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa02 1397; Body=1 Fuz1=1 Fuz2=1]
	*  1.0 XM_Sft_Co_L33T No description available.
	*  0.4 FVGT_m_MULTI_ODD Contains multiple odd letter combinations
X-Spam-DCC: XMission; sa02 1397; Body=1 Fuz1=1 Fuz2=1 
X-Spam-Combo: ***;Alexey Gladkov <legion@kernel.org>
X-Spam-Relay-Country: 
X-Spam-Timing: total 525 ms - load_scoreonly_sql: 0.03 (0.0%),
	signal_user_changed: 3.9 (0.7%), b_tie_ro: 2.7 (0.5%), parse: 0.71
	(0.1%), extract_message_metadata: 9 (1.7%), get_uri_detail_list: 1.88
	(0.4%), tests_pri_-1000: 9 (1.7%), tests_pri_-950: 0.96 (0.2%),
	tests_pri_-900: 0.80 (0.2%), tests_pri_-90: 156 (29.8%), check_bayes:
	154 (29.3%), b_tokenize: 8 (1.4%), b_tok_get_all: 9 (1.7%),
	b_comp_prob: 1.76 (0.3%), b_tok_touch_all: 133 (25.3%), b_finish: 0.63
	(0.1%), tests_pri_0: 333 (63.6%), check_dkim_signature: 0.41 (0.1%),
	check_dkim_adsp: 3.1 (0.6%), poll_dns_idle: 1.81 (0.3%), tests_pri_10:
	1.82 (0.3%), tests_pri_500: 6 (1.2%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [PATCH v1] ucounts: Increase ucounts reference counter before the security hook
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in02.mta.xmission.com)

Alexey Gladkov <legion@kernel.org> writes:

> We need to increment the ucounts reference counter befor security_prepare_creds()
> because this function may fail and abort_creds() will try to decrement
> this reference.
>
> [   96.465056][ T8641] FAULT_INJECTION: forcing a failure.
> [   96.465056][ T8641] name fail_page_alloc, interval 1, probability 0, space 0, times 0
> [   96.478453][ T8641] CPU: 1 PID: 8641 Comm: syz-executor668 Not tainted 5.14.0-rc6-syzkaller #0
> [   96.487215][ T8641] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
> [   96.497254][ T8641] Call Trace:
> [   96.500517][ T8641]  dump_stack_lvl+0x1d3/0x29f
> [   96.505758][ T8641]  ? show_regs_print_info+0x12/0x12
> [   96.510944][ T8641]  ? log_buf_vmcoreinfo_setup+0x498/0x498
> [   96.516652][ T8641]  should_fail+0x384/0x4b0
> [   96.521141][ T8641]  prepare_alloc_pages+0x1d1/0x5a0
> [   96.526236][ T8641]  __alloc_pages+0x14d/0x5f0
> [   96.530808][ T8641]  ? __rmqueue_pcplist+0x2030/0x2030
> [   96.536073][ T8641]  ? lockdep_hardirqs_on_prepare+0x3e2/0x750
> [   96.542056][ T8641]  ? alloc_pages+0x3f3/0x500
> [   96.546635][ T8641]  allocate_slab+0xf1/0x540
> [   96.551120][ T8641]  ___slab_alloc+0x1cf/0x350
> [   96.555689][ T8641]  ? kzalloc+0x1d/0x30
> [   96.559740][ T8641]  __kmalloc+0x2e7/0x390
> [   96.563980][ T8641]  ? kzalloc+0x1d/0x30
> [   96.568029][ T8641]  kzalloc+0x1d/0x30
> [   96.571903][ T8641]  security_prepare_creds+0x46/0x220
> [   96.577174][ T8641]  prepare_creds+0x411/0x640
> [   96.581747][ T8641]  __sys_setfsuid+0xe2/0x3a0
> [   96.586333][ T8641]  do_syscall_64+0x3d/0xb0
> [   96.590739][ T8641]  entry_SYSCALL_64_after_hwframe+0x44/0xae
> [   96.596611][ T8641] RIP: 0033:0x445a69
> [   96.600483][ T8641] Code: 28 00 00 00 75 05 48 83 c4 28 c3 e8 11 15 00 00 90 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 c7 c1 b8 ff ff ff f7 d8 64 89 01 48
> [   96.620152][ T8641] RSP: 002b:00007f1054173318 EFLAGS: 00000246 ORIG_RAX: 000000000000007a
> [   96.628543][ T8641] RAX: ffffffffffffffda RBX: 00000000004ca4c8 RCX: 0000000000445a69
> [   96.636600][ T8641] RDX: 0000000000000010 RSI: 00007f10541732f0 RDI: 0000000000000000
> [   96.644550][ T8641] RBP: 00000000004ca4c0 R08: 0000000000000001 R09: 0000000000000000
> [   96.652500][ T8641] R10: 0000000000000000 R11: 0000000000000246 R12: 00000000004ca4cc
> [   96.660631][ T8641] R13: 00007fffffe0b62f R14: 00007f1054173400 R15: 0000000000022000
>
> Fixes: 905ae01c4ae2 ("Add a reference to ucounts for each cred")
> Reported-by: syzbot+01985d7909f9468f013c@syzkaller.appspotmail.com
> Signed-off-by: Alexey Gladkov <legion@kernel.org>

Applied.

It is obvious how a failure of security_prepare_creds calling
abort_creds could result a decrement without an increment.

So it looks like the fault injection did it's job.

Eric


> ---
>  kernel/cred.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
>
> diff --git a/kernel/cred.c b/kernel/cred.c
> index e6fd2b3fc31f..f784e08c2fbd 100644
> --- a/kernel/cred.c
> +++ b/kernel/cred.c
> @@ -286,13 +286,13 @@ struct cred *prepare_creds(void)
>  	new->security = NULL;
>  #endif
>  
> -	if (security_prepare_creds(new, old, GFP_KERNEL_ACCOUNT) < 0)
> -		goto error;
> -
>  	new->ucounts = get_ucounts(new->ucounts);
>  	if (!new->ucounts)
>  		goto error;
>  
> +	if (security_prepare_creds(new, old, GFP_KERNEL_ACCOUNT) < 0)
> +		goto error;
> +
>  	validate_creds(new);
>  	return new;
>  
> @@ -753,13 +753,13 @@ struct cred *prepare_kernel_cred(struct task_struct *daemon)
>  #ifdef CONFIG_SECURITY
>  	new->security = NULL;
>  #endif
> -	if (security_prepare_creds(new, old, GFP_KERNEL_ACCOUNT) < 0)
> -		goto error;
> -
>  	new->ucounts = get_ucounts(new->ucounts);
>  	if (!new->ucounts)
>  		goto error;
>  
> +	if (security_prepare_creds(new, old, GFP_KERNEL_ACCOUNT) < 0)
> +		goto error;
> +
>  	put_cred(old);
>  	validate_creds(new);
>  	return new;
