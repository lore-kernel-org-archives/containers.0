Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 420393FC3
	for <containers@lists.linux.dev>; Mon, 23 Aug 2021 16:17:15 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id F0724613D2;
	Mon, 23 Aug 2021 16:17:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1629735434;
	bh=gh23DwG5/x4c4F1O5I7aJHgigmYmMs61WqC4Xp5rDqw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Rz/u91l07tl7ws78s8KJN6vglg01dhY2Om1r3cF/WBXW6W+0fYhv2ZY9fYpiEm7ca
	 AyjjdWua8NicjsQ41RbddswSXOQRR+tOz9W0xrMJtpbYB7Tc5VUkOOBYruCbK3LGyl
	 +7G4jMWDXT5KVXBcsYwjKOP1rVxLKTy+2zT270TfL7kl71V7Vsgppk0+Amaf2q7zIs
	 I0PNfYx0NSTAKP0idzOiXfglccTLFK2f+MQiIH4DzfgoYGYvqVgmXfoCN+gOzYq36m
	 dl2kuF2wR3FxQSXGK58kv/VWPsWvQWOVZWIENU1CzYYMxO8QeAYw+7QDw9cB5ksNZm
	 n+pGdBbUW+Q/g==
From: Alexey Gladkov <legion@kernel.org>
To: LKML <linux-kernel@vger.kernel.org>,
	"Eric W . Biederman" <ebiederm@xmission.com>
Cc: Linux Containers <containers@lists.linux.dev>,
	syzbot+01985d7909f9468f013c@syzkaller.appspotmail.com
Subject: [PATCH v1] ucounts: Increase ucounts reference counter before the security hook
Date: Mon, 23 Aug 2021 18:16:33 +0200
Message-Id: <97433b1742c3331f02ad92de5a4f07d673c90613.1629735352.git.legion@kernel.org>
X-Mailer: git-send-email 2.32.0
In-Reply-To: <000000000000b1f4d305c9ef72ad@google.com>
References: <000000000000b1f4d305c9ef72ad@google.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

We need to increment the ucounts reference counter befor security_prepare_creds()
because this function may fail and abort_creds() will try to decrement
this reference.

[   96.465056][ T8641] FAULT_INJECTION: forcing a failure.
[   96.465056][ T8641] name fail_page_alloc, interval 1, probability 0, space 0, times 0
[   96.478453][ T8641] CPU: 1 PID: 8641 Comm: syz-executor668 Not tainted 5.14.0-rc6-syzkaller #0
[   96.487215][ T8641] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[   96.497254][ T8641] Call Trace:
[   96.500517][ T8641]  dump_stack_lvl+0x1d3/0x29f
[   96.505758][ T8641]  ? show_regs_print_info+0x12/0x12
[   96.510944][ T8641]  ? log_buf_vmcoreinfo_setup+0x498/0x498
[   96.516652][ T8641]  should_fail+0x384/0x4b0
[   96.521141][ T8641]  prepare_alloc_pages+0x1d1/0x5a0
[   96.526236][ T8641]  __alloc_pages+0x14d/0x5f0
[   96.530808][ T8641]  ? __rmqueue_pcplist+0x2030/0x2030
[   96.536073][ T8641]  ? lockdep_hardirqs_on_prepare+0x3e2/0x750
[   96.542056][ T8641]  ? alloc_pages+0x3f3/0x500
[   96.546635][ T8641]  allocate_slab+0xf1/0x540
[   96.551120][ T8641]  ___slab_alloc+0x1cf/0x350
[   96.555689][ T8641]  ? kzalloc+0x1d/0x30
[   96.559740][ T8641]  __kmalloc+0x2e7/0x390
[   96.563980][ T8641]  ? kzalloc+0x1d/0x30
[   96.568029][ T8641]  kzalloc+0x1d/0x30
[   96.571903][ T8641]  security_prepare_creds+0x46/0x220
[   96.577174][ T8641]  prepare_creds+0x411/0x640
[   96.581747][ T8641]  __sys_setfsuid+0xe2/0x3a0
[   96.586333][ T8641]  do_syscall_64+0x3d/0xb0
[   96.590739][ T8641]  entry_SYSCALL_64_after_hwframe+0x44/0xae
[   96.596611][ T8641] RIP: 0033:0x445a69
[   96.600483][ T8641] Code: 28 00 00 00 75 05 48 83 c4 28 c3 e8 11 15 00 00 90 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 c7 c1 b8 ff ff ff f7 d8 64 89 01 48
[   96.620152][ T8641] RSP: 002b:00007f1054173318 EFLAGS: 00000246 ORIG_RAX: 000000000000007a
[   96.628543][ T8641] RAX: ffffffffffffffda RBX: 00000000004ca4c8 RCX: 0000000000445a69
[   96.636600][ T8641] RDX: 0000000000000010 RSI: 00007f10541732f0 RDI: 0000000000000000
[   96.644550][ T8641] RBP: 00000000004ca4c0 R08: 0000000000000001 R09: 0000000000000000
[   96.652500][ T8641] R10: 0000000000000000 R11: 0000000000000246 R12: 00000000004ca4cc
[   96.660631][ T8641] R13: 00007fffffe0b62f R14: 00007f1054173400 R15: 0000000000022000

Fixes: 905ae01c4ae2 ("Add a reference to ucounts for each cred")
Reported-by: syzbot+01985d7909f9468f013c@syzkaller.appspotmail.com
Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 kernel/cred.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/kernel/cred.c b/kernel/cred.c
index e6fd2b3fc31f..f784e08c2fbd 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -286,13 +286,13 @@ struct cred *prepare_creds(void)
 	new->security = NULL;
 #endif
 
-	if (security_prepare_creds(new, old, GFP_KERNEL_ACCOUNT) < 0)
-		goto error;
-
 	new->ucounts = get_ucounts(new->ucounts);
 	if (!new->ucounts)
 		goto error;
 
+	if (security_prepare_creds(new, old, GFP_KERNEL_ACCOUNT) < 0)
+		goto error;
+
 	validate_creds(new);
 	return new;
 
@@ -753,13 +753,13 @@ struct cred *prepare_kernel_cred(struct task_struct *daemon)
 #ifdef CONFIG_SECURITY
 	new->security = NULL;
 #endif
-	if (security_prepare_creds(new, old, GFP_KERNEL_ACCOUNT) < 0)
-		goto error;
-
 	new->ucounts = get_ucounts(new->ucounts);
 	if (!new->ucounts)
 		goto error;
 
+	if (security_prepare_creds(new, old, GFP_KERNEL_ACCOUNT) < 0)
+		goto error;
+
 	put_cred(old);
 	validate_creds(new);
 	return new;
-- 
2.32.0

