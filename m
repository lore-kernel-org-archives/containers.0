Received: from out03.mta.xmission.com (out03.mta.xmission.com [166.70.13.233])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2FF493C2F
	for <containers@lists.linux.dev>; Wed, 22 Jun 2022 23:26:14 +0000 (UTC)
Received: from in01.mta.xmission.com ([166.70.13.51]:60862)
	by out03.mta.xmission.com with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1o49GR-00BAi3-O6; Wed, 22 Jun 2022 16:55:59 -0600
Received: from ip68-227-174-4.om.om.cox.net ([68.227.174.4]:57402 helo=email.froward.int.ebiederm.org.xmission.com)
	by in01.mta.xmission.com with esmtpsa  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <ebiederm@xmission.com>)
	id 1o49GP-002YCq-FP; Wed, 22 Jun 2022 16:55:59 -0600
From: "Eric W. Biederman" <ebiederm@xmission.com>
To: Alexey Gladkov <legion@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>,  Linux Containers
 <containers@lists.linux.dev>,  Dmitry Vyukov <dvyukov@google.com>,
  Catalin Marinas <catalin.marinas@arm.com>,
  syzkaller-bugs@googlegroups.com,
  syzbot+b4b0d1b35442afbf6fd2@syzkaller.appspotmail.com
References: <8735fyhyvy.fsf@email.froward.int.ebiederm.org>
	<20220622200729.2639663-1-legion@kernel.org>
Date: Wed, 22 Jun 2022 17:55:22 -0500
In-Reply-To: <20220622200729.2639663-1-legion@kernel.org> (Alexey Gladkov's
	message of "Wed, 22 Jun 2022 22:07:29 +0200")
Message-ID: <87y1xob95x.fsf@email.froward.int.ebiederm.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1o49GP-002YCq-FP;;;mid=<87y1xob95x.fsf@email.froward.int.ebiederm.org>;;;hst=in01.mta.xmission.com;;;ip=68.227.174.4;;;frm=ebiederm@xmission.com;;;spf=softfail
X-XM-AID: U2FsdGVkX1/26elwTItBzsE3kqrhYEqvZh6qW4CuuxM=
X-SA-Exim-Connect-IP: 68.227.174.4
X-SA-Exim-Mail-From: ebiederm@xmission.com
X-Spam-Checker-Version: SpamAssassin 3.4.2 (2018-09-13) on sa07.xmission.com
X-Spam-Level: ****
X-Spam-Status: No, score=4.2 required=8.0 tests=ALL_TRUSTED,BAYES_50,
	DCC_CHECK_NEGATIVE,LotsOfNums_01,T_SCC_BODY_TEXT_LINE,
	T_TM2_M_HEADER_IN_MSG,XMSubLong,XM_SPF_SoftFail autolearn=disabled
	version=3.4.2
X-Spam-Report: 
	* -1.0 ALL_TRUSTED Passed through trusted hosts only via SMTP
	*  0.8 BAYES_50 BODY: Bayes spam probability is 40 to 60%
	*      [score: 0.4035]
	*  0.7 XMSubLong Long Subject
	*  1.2 LotsOfNums_01 BODY: Lots of long strings of numbers
	*  0.0 T_TM2_M_HEADER_IN_MSG BODY: No description available.
	* -0.0 DCC_CHECK_NEGATIVE Not listed in DCC
	*      [sa07 1397; Body=1 Fuz1=1]
	*  2.5 XM_SPF_SoftFail SPF-SoftFail
	* -0.0 T_SCC_BODY_TEXT_LINE No description available.
X-Spam-DCC: XMission; sa07 1397; Body=1 Fuz1=1 
X-Spam-Combo: ****;Alexey Gladkov <legion@kernel.org>
X-Spam-Relay-Country: 
X-Spam-Timing: total 1733 ms - load_scoreonly_sql: 0.12 (0.0%),
	signal_user_changed: 13 (0.7%), b_tie_ro: 11 (0.6%), parse: 1.67
	(0.1%), extract_message_metadata: 17 (1.0%), get_uri_detail_list: 5
	(0.3%), tests_pri_-1000: 17 (1.0%), tests_pri_-950: 1.35 (0.1%),
	tests_pri_-900: 1.07 (0.1%), tests_pri_-90: 143 (8.3%), check_bayes:
	141 (8.1%), b_tokenize: 18 (1.0%), b_tok_get_all: 9 (0.5%),
	b_comp_prob: 2.8 (0.2%), b_tok_touch_all: 108 (6.2%), b_finish: 0.96
	(0.1%), tests_pri_0: 1521 (87.8%), check_dkim_signature: 0.76 (0.0%),
	check_dkim_adsp: 2.7 (0.2%), poll_dns_idle: 0.86 (0.0%), tests_pri_10:
	2.3 (0.1%), tests_pri_500: 11 (0.6%), rewrite_mail: 0.00 (0.0%)
Subject: Re: [PATCH] ipc: Free mq_sysctls if ipc namespace creation failed
X-SA-Exim-Version: 4.2.1 (built Sat, 08 Feb 2020 21:53:50 +0000)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)

Alexey Gladkov <legion@kernel.org> writes:

> The problem that Dmitry Vyukov pointed out is that if setup_ipc_sysctls fails,
> mq_sysctls must be freed before return.

Can we get a tested-by from syzbot?

It would be nice to confirm that this bug is the one syzbot was seeing.

Thank you,
Eric



> executing program
> BUG: memory leak
> unreferenced object 0xffff888112fc9200 (size 512):
>   comm "syz-executor237", pid 3648, jiffies 4294970469 (age 12.270s)
>   hex dump (first 32 bytes):
>     ef d3 60 85 ff ff ff ff 0c 9b d2 12 81 88 ff ff  ..`.............
>     04 00 00 00 a4 01 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff814b6eb3>] kmemdup+0x23/0x50 mm/util.c:129
>     [<ffffffff82219a9b>] kmemdup include/linux/fortify-string.h:456 [inline]
>     [<ffffffff82219a9b>] setup_mq_sysctls+0x4b/0x1c0 ipc/mq_sysctl.c:89
>     [<ffffffff822197f2>] create_ipc_ns ipc/namespace.c:63 [inline]
>     [<ffffffff822197f2>] copy_ipcs+0x292/0x390 ipc/namespace.c:91
>     [<ffffffff8127de7c>] create_new_namespaces+0xdc/0x4f0 kernel/nsproxy.c:90
>     [<ffffffff8127e89b>] unshare_nsproxy_namespaces+0x9b/0x120 kernel/nsproxy.c:226
>     [<ffffffff8123f92e>] ksys_unshare+0x2fe/0x600 kernel/fork.c:3165
>     [<ffffffff8123fc42>] __do_sys_unshare kernel/fork.c:3236 [inline]
>     [<ffffffff8123fc42>] __se_sys_unshare kernel/fork.c:3234 [inline]
>     [<ffffffff8123fc42>] __x64_sys_unshare+0x12/0x20 kernel/fork.c:3234
>     [<ffffffff845aab45>] do_syscall_x64 arch/x86/entry/common.c:50 [inline]
>     [<ffffffff845aab45>] do_syscall_64+0x35/0xb0 arch/x86/entry/common.c:80
>     [<ffffffff8460006a>] entry_SYSCALL_64_after_hwframe+0x46/0xb0
>
> BUG: memory leak
> unreferenced object 0xffff888112fd5f00 (size 256):
>   comm "syz-executor237", pid 3648, jiffies 4294970469 (age 12.270s)
>   hex dump (first 32 bytes):
>     00 92 fc 12 81 88 ff ff 00 00 00 00 01 00 00 00  ................
>     01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff816fea1b>] kmalloc include/linux/slab.h:605 [inline]
>     [<ffffffff816fea1b>] kzalloc include/linux/slab.h:733 [inline]
>     [<ffffffff816fea1b>] __register_sysctl_table+0x7b/0x7f0 fs/proc/proc_sysctl.c:1344
>     [<ffffffff82219b7a>] setup_mq_sysctls+0x12a/0x1c0 ipc/mq_sysctl.c:112
>     [<ffffffff822197f2>] create_ipc_ns ipc/namespace.c:63 [inline]
>     [<ffffffff822197f2>] copy_ipcs+0x292/0x390 ipc/namespace.c:91
>     [<ffffffff8127de7c>] create_new_namespaces+0xdc/0x4f0 kernel/nsproxy.c:90
>     [<ffffffff8127e89b>] unshare_nsproxy_namespaces+0x9b/0x120 kernel/nsproxy.c:226
>     [<ffffffff8123f92e>] ksys_unshare+0x2fe/0x600 kernel/fork.c:3165
>     [<ffffffff8123fc42>] __do_sys_unshare kernel/fork.c:3236 [inline]
>     [<ffffffff8123fc42>] __se_sys_unshare kernel/fork.c:3234 [inline]
>     [<ffffffff8123fc42>] __x64_sys_unshare+0x12/0x20 kernel/fork.c:3234
>     [<ffffffff845aab45>] do_syscall_x64 arch/x86/entry/common.c:50 [inline]
>     [<ffffffff845aab45>] do_syscall_64+0x35/0xb0 arch/x86/entry/common.c:80
>     [<ffffffff8460006a>] entry_SYSCALL_64_after_hwframe+0x46/0xb0
>
> BUG: memory leak
> unreferenced object 0xffff888112fbba00 (size 256):
>   comm "syz-executor237", pid 3648, jiffies 4294970469 (age 12.270s)
>   hex dump (first 32 bytes):
>     78 ba fb 12 81 88 ff ff 00 00 00 00 01 00 00 00  x...............
>     01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff816fef49>] kmalloc include/linux/slab.h:605 [inline]
>     [<ffffffff816fef49>] kzalloc include/linux/slab.h:733 [inline]
>     [<ffffffff816fef49>] new_dir fs/proc/proc_sysctl.c:978 [inline]
>     [<ffffffff816fef49>] get_subdir fs/proc/proc_sysctl.c:1022 [inline]
>     [<ffffffff816fef49>] __register_sysctl_table+0x5a9/0x7f0 fs/proc/proc_sysctl.c:1373
>     [<ffffffff82219b7a>] setup_mq_sysctls+0x12a/0x1c0 ipc/mq_sysctl.c:112
>     [<ffffffff822197f2>] create_ipc_ns ipc/namespace.c:63 [inline]
>     [<ffffffff822197f2>] copy_ipcs+0x292/0x390 ipc/namespace.c:91
>     [<ffffffff8127de7c>] create_new_namespaces+0xdc/0x4f0 kernel/nsproxy.c:90
>     [<ffffffff8127e89b>] unshare_nsproxy_namespaces+0x9b/0x120 kernel/nsproxy.c:226
>     [<ffffffff8123f92e>] ksys_unshare+0x2fe/0x600 kernel/fork.c:3165
>     [<ffffffff8123fc42>] __do_sys_unshare kernel/fork.c:3236 [inline]
>     [<ffffffff8123fc42>] __se_sys_unshare kernel/fork.c:3234 [inline]
>     [<ffffffff8123fc42>] __x64_sys_unshare+0x12/0x20 kernel/fork.c:3234
>     [<ffffffff845aab45>] do_syscall_x64 arch/x86/entry/common.c:50 [inline]
>     [<ffffffff845aab45>] do_syscall_64+0x35/0xb0 arch/x86/entry/common.c:80
>     [<ffffffff8460006a>] entry_SYSCALL_64_after_hwframe+0x46/0xb0
>
> BUG: memory leak
> unreferenced object 0xffff888112fbb900 (size 256):
>   comm "syz-executor237", pid 3648, jiffies 4294970469 (age 12.270s)
>   hex dump (first 32 bytes):
>     78 b9 fb 12 81 88 ff ff 00 00 00 00 01 00 00 00  x...............
>     01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<ffffffff816fef49>] kmalloc include/linux/slab.h:605 [inline]
>     [<ffffffff816fef49>] kzalloc include/linux/slab.h:733 [inline]
>     [<ffffffff816fef49>] new_dir fs/proc/proc_sysctl.c:978 [inline]
>     [<ffffffff816fef49>] get_subdir fs/proc/proc_sysctl.c:1022 [inline]
>     [<ffffffff816fef49>] __register_sysctl_table+0x5a9/0x7f0 fs/proc/proc_sysctl.c:1373
>     [<ffffffff82219b7a>] setup_mq_sysctls+0x12a/0x1c0 ipc/mq_sysctl.c:112
>     [<ffffffff822197f2>] create_ipc_ns ipc/namespace.c:63 [inline]
>     [<ffffffff822197f2>] copy_ipcs+0x292/0x390 ipc/namespace.c:91
>     [<ffffffff8127de7c>] create_new_namespaces+0xdc/0x4f0 kernel/nsproxy.c:90
>     [<ffffffff8127e89b>] unshare_nsproxy_namespaces+0x9b/0x120 kernel/nsproxy.c:226
>     [<ffffffff8123f92e>] ksys_unshare+0x2fe/0x600 kernel/fork.c:3165
>     [<ffffffff8123fc42>] __do_sys_unshare kernel/fork.c:3236 [inline]
>     [<ffffffff8123fc42>] __se_sys_unshare kernel/fork.c:3234 [inline]
>     [<ffffffff8123fc42>] __x64_sys_unshare+0x12/0x20 kernel/fork.c:3234
>     [<ffffffff845aab45>] do_syscall_x64 arch/x86/entry/common.c:50 [inline]
>     [<ffffffff845aab45>] do_syscall_64+0x35/0xb0 arch/x86/entry/common.c:80
>     [<ffffffff8460006a>] entry_SYSCALL_64_after_hwframe+0x46/0xb0
>
> Reported-by: syzbot+b4b0d1b35442afbf6fd2@syzkaller.appspotmail.com
> Signed-off-by: Alexey Gladkov <legion@kernel.org>
> ---
>  ipc/namespace.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/ipc/namespace.c b/ipc/namespace.c
> index 754f3237194a..e1fcaedba4fa 100644
> --- a/ipc/namespace.c
> +++ b/ipc/namespace.c
> @@ -64,7 +64,7 @@ static struct ipc_namespace *create_ipc_ns(struct user_namespace *user_ns,
>  		goto fail_put;
>  
>  	if (!setup_ipc_sysctls(ns))
> -		goto fail_put;
> +		goto fail_mq;
>  
>  	sem_init_ns(ns);
>  	msg_init_ns(ns);
> @@ -72,6 +72,9 @@ static struct ipc_namespace *create_ipc_ns(struct user_namespace *user_ns,
>  
>  	return ns;
>  
> +fail_mq:
> +	retire_mq_sysctls(ns);
> +
>  fail_put:
>  	put_user_ns(ns->user_ns);
>  	ns_free_inum(&ns->ns);
