Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 087A770
	for <containers@lists.linux.dev>; Thu,  8 Jul 2021 10:34:10 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 6FAA961459;
	Thu,  8 Jul 2021 10:34:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1625740450;
	bh=xssUPJ1B3hvub70Irlj6m0DKLO4diekgEQSWb/bldl4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=tD7QhsWGtipWaxOk/UuQhpM7fvBllCBBEUIVSIDdNV5jkBdXYRrAO5kjj8KEGmq1r
	 8bYeBTlJGTlaSh4a0/PS6dFgGx1jNICSVZWtnlT8fDKOxmt1fjfrjTVEV5GPEq/HGo
	 EjmpAP3PNYQ8dv+ccwwlzc1eR0vHSgnX5z1CnF+u65xIG76AqYlbW3dHe9WmHDct2L
	 Kq96MFn9sm/BrqnD3M70VKNQ+TsMgB6kDGnStvY+p43G2y9ao+sC4NDbGCmQg7Rl7w
	 t4u9Vi5HUoRNDdOmRSWV4TiHC02vNGnKXweXnODyoDDONiLNVs/l7+wevT+JStsJfM
	 up10AC7/Iwq5g==
From: Alexey Gladkov <legion@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>,
	Alexey Gladkov <legion@kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH v2] Fix UCOUNT_RLIMIT_SIGPENDING counter leak
Date: Thu,  8 Jul 2021 12:33:01 +0200
Message-Id: <20210708103301.2109330-1-legion@kernel.org>
X-Mailer: git-send-email 2.29.3
In-Reply-To: <CAHk-=wirhF8G1XniAfxzJXCYUnuAx23Q1WLi_n4+HGsUXv72KQ@mail.gmail.com>
References: <CAHk-=wirhF8G1XniAfxzJXCYUnuAx23Q1WLi_n4+HGsUXv72KQ@mail.gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

We must properly handle an errors when we increase the rlimit counter
and the ucounts reference counter. We have to this with RCU protection
to prevent possible use-after-free that could occur due to concurrent
put_cred_rcu().

The following reproducer triggers the problem:

$ cat testcase.sh
case "${STEP:-0}" in
0)
	ulimit -Si 1
	ulimit -Hi 1
	STEP=1 unshare -rU "$0"
	killall sleep
	;;
1)
	for i in 1 2 3 4 5; do unshare -rU sleep 5 & done
	;;
esac

[   84.670919] ==================================================================
[   84.673326] BUG: KASAN: use-after-free in put_ucounts+0x17/0xa0
[   84.674983] Write of size 4 at addr ffff8880045f031c by task swapper/2/0
[   84.676702]
[   84.677119] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 5.13.0+ #19
[   84.678920] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 1.14.0-alt4 04/01/2014
[   84.683128] Call Trace:
[   84.683950]  <IRQ>
[   84.684635]  dump_stack+0x8a/0xb5
[   84.685751]  print_address_description.constprop.0+0x18/0x130
[   84.687633]  ? put_ucounts+0x17/0xa0
[   84.688831]  ? put_ucounts+0x17/0xa0
[   84.690050]  kasan_report.cold+0x7f/0x111
[   84.691413]  ? put_ucounts+0x17/0xa0
[   84.692618]  kasan_check_range+0xf9/0x1e0
[   84.694039]  put_ucounts+0x17/0xa0
[   84.695237]  put_cred_rcu+0xd5/0x190
[   84.696998]  rcu_core+0x3bf/0xcb0
[   84.699692]  ? note_gp_changes+0x90/0x90
[   84.700938]  ? recalibrate_cpu_khz+0x10/0x10
[   84.702575]  ? lapic_timer_set_periodic+0x30/0x30
[   84.704152]  ? clockevents_program_event+0xd3/0x130
[   84.705754]  ? hrtimer_interrupt+0x418/0x440
[   84.707198]  __do_softirq+0xe3/0x341
[   84.708412]  irq_exit_rcu+0xbe/0xe0
[   84.709572]  sysvec_apic_timer_interrupt+0x6a/0x90
[   84.711235]  </IRQ>
[   84.711972]  asm_sysvec_apic_timer_interrupt+0x12/0x20
[   84.713661] RIP: 0010:default_idle+0xb/0x10
[   84.715070] Code: ff f0 80 63 02 df 5b 41 5c c3 0f ae f0 0f ae 3b 0f ae f0 eb 90 66 2e 0f 1f 84 00 00 00 00 00 eb 07 0f 00 2d 37 7d 5a 5
[   84.721579] RSP: 0018:ffffc900000dfe80 EFLAGS: 00000202
[   84.723330] RAX: ffffffffad279280 RBX: ffff8880013f3e00 RCX: ffffffffad269c56
[   84.725724] RDX: 000000000001a8c6 RSI: 0000000000000004 RDI: ffff8880361322a0
[   84.728085] RBP: 0000000000000002 R08: 0000000000000001 R09: ffff8880361322a3
[   84.730485] R10: ffffed1006c26454 R11: 0000000000000001 R12: 0000000000000002
[   84.732814] R13: 0000000000000000 R14: 0000000000000000 R15: 1ffff9200001bfd6
[   84.736325]  ? mwait_idle+0xc0/0xc0
[   84.737488]  ? rcu_eqs_enter.constprop.0+0x86/0xa0
[   84.739085]  default_idle_call+0x53/0x130
[   84.740410]  do_idle+0x311/0x3c0
[   84.741512]  ? _raw_spin_lock_irqsave+0x7b/0xd0
[   84.743060]  ? arch_cpu_idle_exit+0x30/0x30
[   84.744442]  ? swake_up_locked+0x6d/0x80
[   84.745673]  cpu_startup_entry+0x14/0x20
[   84.746657]  secondary_startup_64_no_verify+0xc2/0xcb
[   84.747746]
[   84.748073] Allocated by task 127:
[   84.748742]  kasan_save_stack+0x1b/0x40
[   84.750483]  __kasan_kmalloc+0x7c/0x90
[   84.751359]  alloc_ucounts+0x169/0x2b0
[   84.752270]  set_cred_ucounts+0xbb/0x170
[   84.753266]  ksys_unshare+0x24c/0x4e0
[   84.754194]  __x64_sys_unshare+0x16/0x20
[   84.755332]  do_syscall_64+0x37/0x70
[   84.756503]  entry_SYSCALL_64_after_hwframe+0x44/0xae
[   84.758106]
[   84.758625] Freed by task 0:
[   84.759589]  kasan_save_stack+0x1b/0x40
[   84.760841]  kasan_set_track+0x1c/0x30
[   84.762082]  kasan_set_free_info+0x20/0x30
[   84.763421]  __kasan_slab_free+0xeb/0x120
[   84.764736]  kfree+0xaa/0x460
[   84.765722]  put_cred_rcu+0xd5/0x190
[   84.766925]  rcu_core+0x3bf/0xcb0
[   84.768074]  __do_softirq+0xe3/0x341
[   84.769262]
[   84.769765] The buggy address belongs to the object at ffff8880045f0300
[   84.769765]  which belongs to the cache kmalloc-192 of size 192
[   84.773675] The buggy address is located 28 bytes inside of
[   84.773675]  192-byte region [ffff8880045f0300, ffff8880045f03c0)
[   84.778876] The buggy address belongs to the page:
[   84.780338] page:000000008de0a388 refcount:1 mapcount:0 mapping:0000000000000000 index:0xffff8880045f0000 pfn:0x45f0
[   84.782844] flags: 0x100000000000200(slab|node=0|zone=1)
[   84.784640] raw: 0100000000000200 ffffea00000f4640 0000000a0000000a ffff888001042a00
[   84.787229] raw: ffff8880045f0000 000000008010000d 00000001ffffffff 0000000000000000
[   84.789685] page dumped because: kasan: bad access detected
[   84.791511]
[   84.792037] Memory state around the buggy address:
[   84.793590]  ffff8880045f0200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[   84.795920]  ffff8880045f0280: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
[   84.798252] >ffff8880045f0300: fa fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[   84.800636]                             ^
[   84.801953]  ffff8880045f0380: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
[   84.804261]  ffff8880045f0400: fa fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[   84.806622] ==================================================================
[   84.808909] Disabling lock debugging due to kernel taint

Fixes: d64696905554 ("Reimplement RLIMIT_SIGPENDING on top of ucounts")
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 kernel/signal.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index de0920353d30..e1e4d6d07f08 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -426,18 +426,30 @@ __sigqueue_alloc(int sig, struct task_struct *t, gfp_t gfp_flags,
 	rcu_read_lock();
 	ucounts = task_ucounts(t);
 	sigpending = inc_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1);
-	if (sigpending == 1)
-		ucounts = get_ucounts(ucounts);
+	switch (sigpending) {
+	case 1:
+		if (likely(get_ucounts(ucounts)))
+			break;
+		fallthrough;
+	case LONG_MAX:
+		/*
+		 * we need to decrease the ucount in the userns tree on any
+		 * failure to avoid counts leaking.
+		 */
+		dec_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1);
+		rcu_read_unlock();
+		return NULL;
+	}
 	rcu_read_unlock();
 
-	if (override_rlimit || (sigpending < LONG_MAX && sigpending <= task_rlimit(t, RLIMIT_SIGPENDING))) {
+	if (override_rlimit || likely(sigpending <= task_rlimit(t, RLIMIT_SIGPENDING))) {
 		q = kmem_cache_alloc(sigqueue_cachep, gfp_flags);
 	} else {
 		print_dropped_signal(sig);
 	}
 
 	if (unlikely(q == NULL)) {
-		if (ucounts && dec_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1))
+		if (dec_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1))
 			put_ucounts(ucounts);
 	} else {
 		INIT_LIST_HEAD(&q->list);
-- 
2.29.3

