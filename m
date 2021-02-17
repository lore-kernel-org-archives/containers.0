Return-Path: <SRS0=SPWt=HT=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.2 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EF20C433E0
	for <containers@archiver.kernel.org>; Wed, 17 Feb 2021 15:52:41 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7048F64DA1
	for <containers@archiver.kernel.org>; Wed, 17 Feb 2021 15:52:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7048F64DA1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 102CE84542;
	Wed, 17 Feb 2021 15:52:40 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LYOEioKK7xLe; Wed, 17 Feb 2021 15:52:21 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 08D23844CC;
	Wed, 17 Feb 2021 15:52:20 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id D72C2C0174;
	Wed, 17 Feb 2021 15:52:20 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id CF0D1C013A
 for <containers@lists.linux-foundation.org>;
 Wed, 17 Feb 2021 15:52:19 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id A579786566
 for <containers@lists.linux-foundation.org>;
 Wed, 17 Feb 2021 15:52:19 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id iHbjCU7BRx11
 for <containers@lists.linux-foundation.org>;
 Wed, 17 Feb 2021 15:52:00 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mga14.intel.com (mga14.intel.com [192.55.52.115])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 01A6D85044
 for <containers@lists.linux-foundation.org>;
 Wed, 17 Feb 2021 15:51:59 +0000 (UTC)
IronPort-SDR: pwxnFWRbYXO+g6M+JfqRwbG1ykLptbLNPshvlYuv/okmOdBypfvEjBKLrKM8RlqNFkCVYtlw4U
 pBcAHYu0AgQw==
X-IronPort-AV: E=McAfee;i="6000,8403,9897"; a="182445290"
X-IronPort-AV: E=Sophos;i="5.81,184,1610438400"; 
 d="xz'?scan'208";a="182445290"
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
 by fmsmga103.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384;
 17 Feb 2021 07:51:58 -0800
IronPort-SDR: yq6s//vxFJPNSa15HInPaRPpzYdyF/UVIXZpVkBOdo2i6UxA+DVAAyi0y3tUor7A6OmeQIwNWa
 a4pagOaVQiZg==
X-IronPort-AV: E=Sophos;i="5.81,184,1610438400"; 
 d="xz'?scan'208";a="592845996"
Received: from xsang-optiplex-9020.sh.intel.com (HELO xsang-OptiPlex-9020)
 ([10.239.159.140])
 by fmsmga005-auth.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384;
 17 Feb 2021 07:51:49 -0800
Date: Thu, 18 Feb 2021 00:07:26 +0800
From: kernel test robot <oliver.sang@intel.com>
To: Alexey Gladkov <gladkov.alexey@gmail.com>
Subject: f009495a8d: BUG:KASAN:use-after-free_in_user_shm_unlock
Message-ID: <20210217160726.GD4503@xsang-OptiPlex-9020>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="pQhZXvAqiZgbeUkD"
Content-Disposition: inline
In-Reply-To: <04cdc5d6da93511c0493612581b319b2255ea3d6.1613392826.git.gladkov.alexey@gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
Cc: Jens Axboe <axboe@kernel.dk>, 0day robot <lkp@intel.com>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, lkp@lists.01.org,
 kernel test robot <oliver.sang@intel.com>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Andrew Morton <akpm@linux-foundation.org>, Alexey Gladkov <legion@kernel.org>,
 io-uring@vger.kernel.org, Kees Cook <keescook@chromium.org>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>


--pQhZXvAqiZgbeUkD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Greeting,

FYI, we noticed the following commit (built with gcc-9):

commit: f009495a8def89a71b9e0b9025a39379d6f9097d ("Reimplement RLIMIT_MEMLOCK on top of ucounts")
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git Alexey-Gladkov/Count-rlimits-in-each-user-namespace/20210215-204524


in testcase: trinity
version: trinity-x86_64-4d2343bd-1_20210105
with following parameters:

	runtime: 300s

test-description: Trinity is a linux system call fuzz tester.
test-url: http://codemonkey.org.uk/projects/trinity/


on test machine: qemu-system-x86_64 -enable-kvm -cpu SandyBridge -smp 2 -m 8G

caused below changes (please refer to attached dmesg/kmsg for entire log/backtrace):


+---------------------------------------------+------------+------------+
|                                             | ebc4144c8c | f009495a8d |
+---------------------------------------------+------------+------------+
| boot_successes                              | 12         | 3          |
| boot_failures                               | 0          | 9          |
| BUG:KASAN:use-after-free_in_user_shm_unlock | 0          | 9          |
+---------------------------------------------+------------+------------+


If you fix the issue, kindly add following tag
Reported-by: kernel test robot <oliver.sang@intel.com>


[  379.451460] BUG: KASAN: use-after-free in user_shm_unlock (kbuild/src/consumer/mm/mlock.c:839) 
[  379.452995] Read of size 8 at addr ffff888117ff7e90 by task trinity-c2/3961
[  379.454626]
[  379.455018] CPU: 0 PID: 3961 Comm: trinity-c2 Tainted: G            E     5.11.0-rc7-00017-gf009495a8def #1
[  379.457212] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.12.0-1 04/01/2014
[  379.459153] Call Trace:
[  379.459777] print_address_description+0x18/0x26f 
[  379.461168] ? user_shm_unlock (kbuild/src/consumer/mm/mlock.c:839) 
[  379.462171] kasan_report (kbuild/src/consumer/mm/kasan/report.c:397 kbuild/src/consumer/mm/kasan/report.c:413) 
[  379.463132] ? user_shm_unlock (kbuild/src/consumer/mm/mlock.c:839) 
[  379.464053] user_shm_unlock (kbuild/src/consumer/mm/mlock.c:839) 
[  379.464986] shmem_lock (kbuild/src/consumer/mm/shmem.c:2247) 
[  379.465741] shmctl_do_lock (kbuild/src/consumer/ipc/shm.c:1124) 
[  379.466611] ksys_shmctl+0x19b/0x1e2 
[  379.467620] ? __x32_compat_sys_shmctl (kbuild/src/consumer/ipc/shm.c:1141) 
[  379.468612] ? lock_acquire (kbuild/src/consumer/kernel/locking/lockdep.c:437 kbuild/src/consumer/kernel/locking/lockdep.c:5444) 
[  379.469427] ? find_held_lock (kbuild/src/consumer/kernel/locking/lockdep.c:4956) 
[  379.470301] ? __context_tracking_exit (kbuild/src/consumer/kernel/context_tracking.c:161) 
[  379.471508] ? lock_downgrade (kbuild/src/consumer/kernel/locking/lockdep.c:5450) 
[  379.472561] ? kvm_clock_read (kbuild/src/consumer/arch/x86/include/asm/preempt.h:84 kbuild/src/consumer/arch/x86/kernel/kvmclock.c:90) 
[  379.473521] ? account_steal_time (kbuild/src/consumer/kernel/sched/cputime.c:212) 
[  379.474581] ? account_other_time (kbuild/src/consumer/kernel/sched/cputime.c:245 kbuild/src/consumer/kernel/sched/cputime.c:262) 
[  379.475544] ? mark_held_locks (kbuild/src/consumer/kernel/locking/lockdep.c:4000 (discriminator 1)) 
[  379.476491] ? lockdep_hardirqs_on_prepare (kbuild/src/consumer/kernel/locking/lockdep.c:437 kbuild/src/consumer/kernel/locking/lockdep.c:4099) 
[  379.477743] do_syscall_64 (kbuild/src/consumer/arch/x86/entry/common.c:46) 
[  379.478611] entry_SYSCALL_64_after_hwframe (kbuild/src/consumer/arch/x86/entry/entry_64.S:127) 
[  379.479768] RIP: 0033:0x7f79708ebf59
[ 379.480640] Code: 00 c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 07 6f 0c 00 f7 d8 64 89 01 48
All code
========
   0:	00 c3                	add    %al,%bl
   2:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
   9:	00 00 00 
   c:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  11:	48 89 f8             	mov    %rdi,%rax
  14:	48 89 f7             	mov    %rsi,%rdi
  17:	48 89 d6             	mov    %rdx,%rsi
  1a:	48 89 ca             	mov    %rcx,%rdx
  1d:	4d 89 c2             	mov    %r8,%r10
  20:	4d 89 c8             	mov    %r9,%r8
  23:	4c 8b 4c 24 08       	mov    0x8(%rsp),%r9
  28:	0f 05                	syscall 
  2a:*	48 3d 01 f0 ff ff    	cmp    $0xfffffffffffff001,%rax		<-- trapping instruction
  30:	73 01                	jae    0x33
  32:	c3                   	retq   
  33:	48 8b 0d 07 6f 0c 00 	mov    0xc6f07(%rip),%rcx        # 0xc6f41
  3a:	f7 d8                	neg    %eax
  3c:	64 89 01             	mov    %eax,%fs:(%rcx)
  3f:	48                   	rex.W

Code starting with the faulting instruction
===========================================
   0:	48 3d 01 f0 ff ff    	cmp    $0xfffffffffffff001,%rax
   6:	73 01                	jae    0x9
   8:	c3                   	retq   
   9:	48 8b 0d 07 6f 0c 00 	mov    0xc6f07(%rip),%rcx        # 0xc6f17
  10:	f7 d8                	neg    %eax
  12:	64 89 01             	mov    %eax,%fs:(%rcx)
  15:	48                   	rex.W
[  379.484875] RSP: 002b:00007ffd0b8ac428 EFLAGS: 00000246 ORIG_RAX: 000000000000001f
[  379.486602] RAX: ffffffffffffffda RBX: 000000000000001f RCX: 00007f79708ebf59
[  379.488077] RDX: 0000000000000004 RSI: 000000000000000c RDI: 0000000000000000
[  379.489493] RBP: 000000000000001f R08: 0000a7fc6cf3f14d R09: 0000000008000000
[  379.491020] R10: ffffffffffffff71 R11: 0000000000000246 R12: 0000000000000002
[  379.492661] R13: 00007f796f2bb058 R14: 00007f79707d46c0 R15: 00007f796f2bb000
[  379.494454]
[  379.494871] Allocated by task 0:
[  379.495620] (stack is not available)
[  379.496488]
[  379.496893] Freed by task 10:
[  379.497655] kasan_save_stack (kbuild/src/consumer/mm/kasan/common.c:38) 
[  379.498658] kasan_set_track (kbuild/src/consumer/mm/kasan/common.c:46) 
[  379.499609] kasan_set_free_info (kbuild/src/consumer/mm/kasan/generic.c:358) 
[  379.500681] ____kasan_slab_free (kbuild/src/consumer/mm/kasan/common.c:364) 
[  379.501725] slab_free_freelist_hook (kbuild/src/consumer/mm/slub.c:1580) 
[  379.502861] kmem_cache_free (kbuild/src/consumer/mm/slub.c:3143 kbuild/src/consumer/mm/slub.c:3159) 
[  379.503731] rcu_process_callbacks (kbuild/src/consumer/include/linux/rcupdate.h:264 kbuild/src/consumer/kernel/rcu/tiny.c:99 kbuild/src/consumer/kernel/rcu/tiny.c:130) 
[  379.504755] __do_softirq (kbuild/src/consumer/include/linux/instrumented.h:71 kbuild/src/consumer/include/asm-generic/atomic-instrumented.h:27 kbuild/src/consumer/include/linux/jump_label.h:254 kbuild/src/consumer/include/linux/jump_label.h:264 kbuild/src/consumer/include/trace/events/irq.h:142 kbuild/src/consumer/kernel/softirq.c:344) 
[  379.505618]
[  379.505979] The buggy address belongs to the object at ffff888117ff7e00
[  379.505979]  which belongs to the cache cred_jar of size 176
[  379.508744] The buggy address is located 144 bytes inside of
[  379.508744]  176-byte region [ffff888117ff7e00, ffff888117ff7eb0)
[  379.511290] The buggy address belongs to the page:
[  379.512399] page:0000000097ece402 refcount:1 mapcount:0 mapping:0000000000000000 index:0x0 pfn:0x117ff7
[  379.514652] flags: 0x8000000000000200(slab)
[  379.515652] raw: 8000000000000200 dead000000000100 dead000000000122 ffff888100372a00
[  379.517377] raw: 0000000000000000 0000000000100010 00000001ffffffff 0000000000000000
[  379.519257] page dumped because: kasan: bad access detected
[  379.520478]
[  379.520835] Memory state around the buggy address:
[  379.521953]  ffff888117ff7d80: fb fb fb fb fb fb fc fc fc fc fc fc fc fc fc fc
[  379.523570]  ffff888117ff7e00: fa fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[  379.525357] >ffff888117ff7e80: fb fb fb fb fb fb fc fc fc fc fc fc fc fc fc fc
[  379.527029]                          ^
[  379.527887]  ffff888117ff7f00: fa fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
[  379.529581]  ffff888117ff7f80: fb fb fb fb fb fb fc fc fc fc fc fc fc fc fc fc
[  379.531334] ==================================================================
[  379.533107] Disabling lock debugging due to kernel taint
[  379.755941] [main] kernel became tainted! (8224/8192) Last seed was 782038633
[  379.756009]
[  379.773617] trinity: Detected kernel tainting. Last seed was 782038633
[  379.773690]
[  379.789324] [main] exit_reason=7, but 3 children still running.
[  379.789394]
[  381.812865] [main] Bailing main loop because kernel became tainted..
[  381.812932]
[  382.091273] [main] Ran 93208 syscalls. Successes: 23634  Failures: 67538
[  382.091348]
[  405.279282] /lkp/lkp/src/tests/trinity: 45: kill: No such process
[  405.279354]
[  405.298590]
[  405.298646]
[  405.656613] /usr/bin/wget -q --timeout=1800 --tries=1 --local-encoding=UTF-8 http://internal-lkp-server:80/~lkp/cgi-bin/lkp-jobfile-append-var?job_file=/lkp/jobs/scheduled/vm-snb-124/trinity-300s-debian-10.4-x86_64-20200603.cgz-f009495a8def89a71b9e0b9025a39379d6f9097d-20210217-33540-1tuu5rt-2.yaml&job_state=post_run -O /dev/null
[  405.656700]
[  407.339684] kill 377 vmstat --timestamp -n 10
[  407.339744]
[  407.453173] kill 375 dmesg --follow --decode
[  407.453237]
[  407.547712] wait for background processes: 379 meminfo
[  407.547783]
[  415.539948] sysrq: Emergency Sync
[  415.540999] Emergency Sync complete
[  415.544090] sysrq: Resetting

Kboot worker: lkp-worker31
Elapsed time: 420

kvm=(
qemu-system-x86_64
-enable-kvm
-cpu SandyBridge
-kernel $kernel
-initrd initrd-vm-snb-124.cgz
-m 8192
-smp 2
-device e1000,netdev=net0
-netdev user,id=net0,hostfwd=tcp::32032-:22
-boot order=nc
-no-reboot
-watchdog i6300esb
-watchdog-action debug
-rtc base=localtime
-serial stdio
-display none
-monitor null
)

append=(
ip=::::vm-snb-124::dhcp
root=/dev/ram0


To reproduce:

        # build kernel
	cd linux
	cp config-5.11.0-rc7-00017-gf009495a8def .config
	make HOSTCC=gcc-9 CC=gcc-9 ARCH=x86_64 olddefconfig prepare modules_prepare bzImage

        git clone https://github.com/intel/lkp-tests.git
        cd lkp-tests
        bin/lkp qemu -k <bzImage> job-script # job-script is attached in this email



Thanks,
Oliver Sang


--pQhZXvAqiZgbeUkD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-5.11.0-rc7-00017-gf009495a8def"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 5.11.0-rc7 Kernel Configuration
#
CONFIG_CC_VERSION_TEXT="gcc-9 (Debian 9.3.0-15) 9.3.0"
CONFIG_CC_IS_GCC=y
CONFIG_GCC_VERSION=90300
CONFIG_LD_VERSION=235000000
CONFIG_CLANG_VERSION=0
CONFIG_LLD_VERSION=0
CONFIG_CC_CAN_LINK=y
CONFIG_CC_CAN_LINK_STATIC=y
CONFIG_CC_HAS_ASM_GOTO=y
CONFIG_CC_HAS_ASM_INLINE=y
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_TABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_BUILD_SALT=""
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_HAVE_KERNEL_ZSTD=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
CONFIG_KERNEL_XZ=y
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
# CONFIG_KERNEL_ZSTD is not set
CONFIG_DEFAULT_INIT=""
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_WATCH_QUEUE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_HARDIRQS_SW_RESEND=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
CONFIG_IRQ_MSI_IOMMU=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
# CONFIG_GENERIC_IRQ_DEBUGFS is not set
# end of IRQ subsystem

CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_INIT=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_HAVE_POSIX_CPU_TIMERS_TASK_WORK=y
CONFIG_POSIX_CPU_TIMERS_TASK_WORK=y

#
# Timers subsystem
#
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
CONFIG_CONTEXT_TRACKING=y
CONFIG_CONTEXT_TRACKING_FORCE=y
# CONFIG_NO_HZ is not set
# CONFIG_HIGH_RES_TIMERS is not set
# end of Timers subsystem

CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
# CONFIG_TICK_CPU_ACCOUNTING is not set
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_IRQ_TIME_ACCOUNTING=y
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set
CONFIG_PSI=y
# CONFIG_PSI_DEFAULT_DISABLED is not set
# end of CPU/Task time and stats accounting

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TINY_SRCU=y
CONFIG_TASKS_RCU_GENERIC=y
CONFIG_TASKS_RCU=y
CONFIG_TASKS_RUDE_RCU=y
CONFIG_TASKS_TRACE_RCU=y
CONFIG_TASKS_TRACE_RCU_READ_MB=y
# end of RCU Subsystem

CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
# CONFIG_IKHEADERS is not set
CONFIG_LOG_BUF_SHIFT=20
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y

#
# Scheduler features
#
# end of Scheduler features

CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_CC_HAS_INT128=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
# CONFIG_MEMCG is not set
CONFIG_BLK_CGROUP=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_CGROUP_PIDS=y
CONFIG_CGROUP_RDMA=y
CONFIG_CGROUP_FREEZER=y
# CONFIG_CGROUP_HUGETLB is not set
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
# CONFIG_CGROUP_BPF is not set
CONFIG_CGROUP_DEBUG=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_TIME_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
# CONFIG_PID_NS is not set
CONFIG_NET_NS=y
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
# CONFIG_RD_LZO is not set
CONFIG_RD_LZ4=y
# CONFIG_RD_ZSTD is not set
CONFIG_BOOT_CONFIG=y
# CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE is not set
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_LD_ORPHAN_WARN=y
CONFIG_SYSCTL=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
CONFIG_FHANDLE=y
CONFIG_POSIX_TIMERS=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_IO_URING=y
CONFIG_ADVISE_SYSCALLS=y
CONFIG_HAVE_ARCH_USERFAULTFD_WP=y
CONFIG_MEMBARRIER=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_BPF_SYSCALL=y
CONFIG_ARCH_WANT_DEFAULT_BPF_JIT=y
# CONFIG_BPF_PRELOAD is not set
CONFIG_USERFAULTFD=y
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
CONFIG_RSEQ=y
# CONFIG_DEBUG_RSEQ is not set
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
# end of Kernel Performance Events And Counters

CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_SLAB_MERGE_DEFAULT=y
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SLAB_FREELIST_HARDENED is not set
# CONFIG_SHUFFLE_PAGE_ALLOCATOR is not set
CONFIG_SYSTEM_DATA_VERIFICATION=y
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
# end of General setup

CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_FILTER_PGPROT=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DYNAMIC_PHYSICAL_MASK=y
CONFIG_PGTABLE_LEVELS=5
CONFIG_CC_HAS_SANE_STACKPROTECTOR=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
# CONFIG_X86_X2APIC is not set
# CONFIG_X86_MPPARSE is not set
# CONFIG_GOLDFISH is not set
# CONFIG_RETPOLINE is not set
CONFIG_X86_CPU_RESCTRL=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_AMD_PLATFORM_DEVICE=y
CONFIG_IOSF_MBI=m
# CONFIG_IOSF_MBI_DEBUG is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_X86_HV_CALLBACK_VECTOR=y
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
CONFIG_ARCH_CPUIDLE_HALTPOLL=y
# CONFIG_PVH is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_JAILHOUSE_GUEST is not set
# CONFIG_ACRN_GUEST is not set
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_IA32_FEAT_CTL=y
CONFIG_X86_VMX_FEATURE_NAMES=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_HYGON=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_ZHAOXIN=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
CONFIG_NR_CPUS_RANGE_BEGIN=1
CONFIG_NR_CPUS_RANGE_END=1
CONFIG_NR_CPUS_DEFAULT=1
CONFIG_NR_CPUS=1
CONFIG_UP_LATE_INIT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCELOG_LEGACY=y
# CONFIG_X86_MCE_INTEL is not set
# CONFIG_X86_MCE_AMD is not set
CONFIG_X86_MCE_INJECT=y

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=m
CONFIG_PERF_EVENTS_INTEL_RAPL=m
# CONFIG_PERF_EVENTS_INTEL_CSTATE is not set
# CONFIG_PERF_EVENTS_AMD_POWER is not set
# end of Performance monitoring

CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
# CONFIG_X86_IOPL_IOPERM is not set
# CONFIG_I8K is not set
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
CONFIG_X86_5LEVEL=y
CONFIG_X86_DIRECT_GBPAGES=y
CONFIG_X86_CPA_STATISTICS=y
CONFIG_AMD_MEM_ENCRYPT=y
# CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
# CONFIG_X86_PMEM_LEGACY is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_X86_UMIP=y
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
# CONFIG_X86_INTEL_TSX_MODE_OFF is not set
# CONFIG_X86_INTEL_TSX_MODE_ON is not set
CONFIG_X86_INTEL_TSX_MODE_AUTO=y
# CONFIG_X86_SGX is not set
CONFIG_EFI=y
# CONFIG_EFI_STUB is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
# CONFIG_KEXEC is not set
# CONFIG_KEXEC_FILE is not set
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_DYNAMIC_MEMORY_LAYOUT=y
CONFIG_RANDOMIZE_MEMORY=y
CONFIG_RANDOMIZE_MEMORY_PHYSICAL_PADDING=0x0
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_XONLY is not set
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_LIVEPATCH=y
# end of Processor type and features

CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
# CONFIG_PM_ADVANCED_DEBUG is not set
CONFIG_PM_TEST_SUSPEND=y
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_PM_TRACE_RTC is not set
CONFIG_PM_CLK=y
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ARCH_SUPPORTS_ACPI=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
CONFIG_ACPI_DEBUGGER=y
CONFIG_ACPI_DEBUGGER_USER=m
# CONFIG_ACPI_SPCR_TABLE is not set
CONFIG_ACPI_LPIT=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_REV_OVERRIDE_POSSIBLE is not set
CONFIG_ACPI_EC_DEBUGFS=y
# CONFIG_ACPI_AC is not set
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=m
# CONFIG_ACPI_TINY_POWER_BUTTON is not set
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_TAD=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=m
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_TABLE_UPGRADE is not set
CONFIG_ACPI_DEBUG=y
# CONFIG_ACPI_PCI_SLOT is not set
# CONFIG_ACPI_CONTAINER is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
# CONFIG_ACPI_SBS is not set
CONFIG_ACPI_HED=y
CONFIG_ACPI_CUSTOM_METHOD=m
CONFIG_ACPI_BGRT=y
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
# CONFIG_ACPI_NFIT is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
# CONFIG_ACPI_DPTF is not set
# CONFIG_ACPI_CONFIGFS is not set
# CONFIG_PMIC_OPREGION is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=m
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# CPU frequency scaling drivers
#
# CONFIG_CPUFREQ_DT is not set
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
CONFIG_X86_ACPI_CPUFREQ=y
# CONFIG_X86_ACPI_CPUFREQ_CPB is not set
CONFIG_X86_POWERNOW_K8=m
CONFIG_X86_AMD_FREQ_SENSITIVITY=m
CONFIG_X86_SPEEDSTEP_CENTRINO=y
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# end of CPU Frequency scaling

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_CPU_IDLE_GOV_TEO is not set
# CONFIG_CPU_IDLE_GOV_HALTPOLL is not set
CONFIG_HALTPOLL_CPUIDLE=y
# end of CPU Idle

# CONFIG_INTEL_IDLE is not set
# end of Power management and ACPI options

#
# Bus options (PCI etc.)
#
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_ISA_BUS is not set
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_X86_SYSFB is not set
# end of Bus options (PCI etc.)

#
# Binary Emulations
#
# CONFIG_IA32_EMULATION is not set
CONFIG_X86_X32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
# end of Binary Emulations

#
# Firmware Drivers
#
# CONFIG_EDD is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=m
CONFIG_FW_CFG_SYSFS=y
CONFIG_FW_CFG_SYSFS_CMDLINE=y
CONFIG_GOOGLE_FIRMWARE=y
CONFIG_GOOGLE_SMI=m
CONFIG_GOOGLE_COREBOOT_TABLE=y
CONFIG_GOOGLE_MEMCONSOLE=m
CONFIG_GOOGLE_MEMCONSOLE_X86_LEGACY=m
# CONFIG_GOOGLE_MEMCONSOLE_COREBOOT is not set
CONFIG_GOOGLE_VPD=y

#
# EFI (Extensible Firmware Interface) Support
#
CONFIG_EFI_VARS=m
CONFIG_EFI_ESRT=y
# CONFIG_EFI_FAKE_MEMMAP is not set
CONFIG_EFI_RUNTIME_WRAPPERS=y
CONFIG_EFI_BOOTLOADER_CONTROL=m
CONFIG_EFI_CAPSULE_LOADER=y
# CONFIG_EFI_TEST is not set
# CONFIG_EFI_RCI2_TABLE is not set
CONFIG_EFI_DISABLE_PCI_DMA=y
# end of EFI (Extensible Firmware Interface) Support

CONFIG_EFI_EARLYCON=y
# CONFIG_EFI_CUSTOM_SSDT_OVERLAYS is not set

#
# Tegra firmware driver
#
# end of Tegra firmware driver
# end of Firmware Drivers

CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
CONFIG_AS_AVX512=y
CONFIG_AS_SHA1_NI=y
CONFIG_AS_SHA256_NI=y
CONFIG_AS_TPAUSE=y

#
# General architecture-dependent options
#
CONFIG_GENERIC_ENTRY=y
CONFIG_OPROFILE=m
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_STATIC_CALL_SELFTEST=y
CONFIG_OPTPROBES=y
CONFIG_KPROBES_ON_FTRACE=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_FUNCTION_ERROR_INJECTION=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_ARCH_HAS_SET_DIRECT_MAP=y
CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_ASM_MODVERSIONS=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_RSEQ=y
CONFIG_HAVE_FUNCTION_ARG_ACCESS_API=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_HAVE_ARCH_JUMP_LABEL_RELATIVE=y
CONFIG_MMU_GATHER_TABLE_FREE=y
CONFIG_MMU_GATHER_RCU_TABLE_FREE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
# CONFIG_SECCOMP is not set
CONFIG_HAVE_ARCH_STACKLEAK=y
CONFIG_HAVE_STACKPROTECTOR=y
# CONFIG_STACKPROTECTOR is not set
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_CONTEXT_TRACKING_OFFSTACK=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_MOVE_PUD=y
CONFIG_HAVE_MOVE_PMD=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES=y
CONFIG_HAVE_STACK_VALIDATION=y
CONFIG_HAVE_RELIABLE_STACKTRACE=y
CONFIG_ISA_BUS_API=y
CONFIG_COMPAT_32BIT_TIME=y
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_VMAP_STACK=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_STRICT_MODULE_RWX=y
CONFIG_HAVE_ARCH_PREL32_RELOCATIONS=y
CONFIG_ARCH_USE_MEMREMAP_PROT=y
CONFIG_LOCK_EVENT_COUNTS=y
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
CONFIG_HAVE_STATIC_CALL=y
CONFIG_HAVE_STATIC_CALL_INLINE=y
CONFIG_ARCH_WANT_LD_ORPHAN_WARN=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_GCOV_PROFILE_ALL is not set
# end of GCOV-based kernel profiling

CONFIG_HAVE_GCC_PLUGINS=y
# end of General architecture-dependent options

CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULE_SIG_FORMAT=y
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
# CONFIG_MODULE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_MODULE_SIG=y
# CONFIG_MODULE_SIG_FORCE is not set
CONFIG_MODULE_SIG_ALL=y
# CONFIG_MODULE_SIG_SHA1 is not set
# CONFIG_MODULE_SIG_SHA224 is not set
# CONFIG_MODULE_SIG_SHA256 is not set
CONFIG_MODULE_SIG_SHA384=y
# CONFIG_MODULE_SIG_SHA512 is not set
CONFIG_MODULE_SIG_HASH="sha384"
# CONFIG_MODULE_COMPRESS is not set
# CONFIG_MODULE_ALLOW_MISSING_NAMESPACE_IMPORTS is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_CGROUP_RWSTAT=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_DEV_INTEGRITY_T10=y
CONFIG_BLK_DEV_ZONED=y
CONFIG_BLK_DEV_THROTTLING=y
# CONFIG_BLK_DEV_THROTTLING_LOW is not set
CONFIG_BLK_CMDLINE_PARSER=y
CONFIG_BLK_WBT=y
CONFIG_BLK_CGROUP_IOLATENCY=y
# CONFIG_BLK_CGROUP_IOCOST is not set
# CONFIG_BLK_WBT_MQ is not set
# CONFIG_BLK_DEBUG_FS is not set
CONFIG_BLK_SED_OPAL=y
CONFIG_BLK_INLINE_ENCRYPTION=y
CONFIG_BLK_INLINE_ENCRYPTION_FALLBACK=y

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_AIX_PARTITION is not set
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
# CONFIG_MSDOS_PARTITION is not set
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=y
CONFIG_SYSV68_PARTITION=y
CONFIG_CMDLINE_PARTITION=y
# end of Partition Types

CONFIG_BLOCK_COMPAT=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y
CONFIG_BLK_PM=y

#
# IO Schedulers
#
CONFIG_MQ_IOSCHED_DEADLINE=y
# CONFIG_MQ_IOSCHED_KYBER is not set
CONFIG_IOSCHED_BFQ=m
# CONFIG_BFQ_GROUP_IOSCHED is not set
# end of IO Schedulers

CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE=y
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
CONFIG_ARCH_HAS_SYSCALL_WRAPPER=y
CONFIG_FREEZER=y

#
# Executable file formats
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
# end of Executable file formats

#
# Memory Management options
#
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_FAST_GUP=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
# CONFIG_COMPACTION is not set
# CONFIG_PAGE_REPORTING is not set
CONFIG_MIGRATION=y
CONFIG_CONTIG_ALLOC=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=m
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_NEED_PER_CPU_KM=y
CONFIG_CLEANCACHE=y
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
CONFIG_CMA_DEBUGFS=y
CONFIG_CMA_AREAS=7
# CONFIG_MEM_SOFT_DIRTY is not set
CONFIG_ZPOOL=y
# CONFIG_ZBUD is not set
# CONFIG_Z3FOLD is not set
# CONFIG_ZSMALLOC is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_IDLE_PAGE_TRACKING=y
CONFIG_ARCH_HAS_PTE_DEVMAP=y
CONFIG_VMAP_PFN=y
CONFIG_FRAME_VECTOR=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
CONFIG_PERCPU_STATS=y
CONFIG_GUP_TEST=y
CONFIG_ARCH_HAS_PTE_SPECIAL=y
CONFIG_MAPPING_DIRTY_HELPERS=y
CONFIG_KMAP_LOCAL=y
# end of Memory Management options

CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
CONFIG_UNIX_SCM=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_TLS is not set
# CONFIG_XFRM_USER is not set
# CONFIG_NET_KEY is not set
# CONFIG_XDP_SOCKETS is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
# CONFIG_SYN_COOKIES is not set
# CONFIG_NET_IPVTI is not set
# CONFIG_NET_FOU is not set
# CONFIG_NET_FOU_IP_TUNNELS is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
# CONFIG_IPV6_SEG6_HMAC is not set
# CONFIG_IPV6_RPL_LWTUNNEL is not set
# CONFIG_NETLABEL is not set
# CONFIG_MPTCP is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_BPFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_6LOWPAN is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=m
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_NET_NSH is not set
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
# CONFIG_NET_L3_MASTER_DEV is not set
# CONFIG_QRTR is not set
# CONFIG_NET_NCSI is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_NET_DROP_MONITOR is not set
# end of Network testing
# end of Networking options

# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_RFKILL is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
# CONFIG_LWTUNNEL is not set
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
CONFIG_FAILOVER=m
CONFIG_ETHTOOL_NETLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#
CONFIG_HAVE_EISA=y
# CONFIG_EISA is not set
CONFIG_HAVE_PCI=y
CONFIG_PCI=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEFAULT is not set
CONFIG_PCIEASPM_POWERSAVE=y
# CONFIG_PCIEASPM_POWER_SUPERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
# CONFIG_PCIE_PTM is not set
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
CONFIG_PCI_PF_STUB=y
CONFIG_PCI_ATS=y
CONFIG_PCI_ECAM=y
CONFIG_PCI_LOCKLESS_CONFIG=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
# CONFIG_PCIE_BUS_TUNE_OFF is not set
CONFIG_PCIE_BUS_DEFAULT=y
# CONFIG_PCIE_BUS_SAFE is not set
# CONFIG_PCIE_BUS_PERFORMANCE is not set
# CONFIG_PCIE_BUS_PEER2PEER is not set
# CONFIG_HOTPLUG_PCI is not set

#
# PCI controller drivers
#
# CONFIG_PCI_FTPCI100 is not set
CONFIG_PCI_HOST_COMMON=y
CONFIG_PCI_HOST_GENERIC=y
# CONFIG_PCIE_XILINX is not set
CONFIG_VMD=m

#
# DesignWare PCI Core Support
#
CONFIG_PCIE_DW=y
CONFIG_PCIE_DW_HOST=y
CONFIG_PCIE_DW_PLAT=y
CONFIG_PCIE_DW_PLAT_HOST=y
# CONFIG_PCIE_DW_PLAT_EP is not set
# CONFIG_PCIE_INTEL_GW is not set
CONFIG_PCI_MESON=y
# end of DesignWare PCI Core Support

#
# Mobiveil PCIe Core Support
#
# end of Mobiveil PCIe Core Support

#
# Cadence PCIe controllers support
#
CONFIG_PCIE_CADENCE=y
CONFIG_PCIE_CADENCE_HOST=y
CONFIG_PCIE_CADENCE_PLAT=y
CONFIG_PCIE_CADENCE_PLAT_HOST=y
# CONFIG_PCIE_CADENCE_PLAT_EP is not set
# CONFIG_PCI_J721E_HOST is not set
# CONFIG_PCI_J721E_EP is not set
# end of Cadence PCIe controllers support
# end of PCI controller drivers

#
# PCI Endpoint
#
CONFIG_PCI_ENDPOINT=y
# CONFIG_PCI_ENDPOINT_CONFIGFS is not set
CONFIG_PCI_EPF_TEST=y
# end of PCI Endpoint

#
# PCI switch controller drivers
#
CONFIG_PCI_SW_SWITCHTEC=m
# end of PCI switch controller drivers

CONFIG_PCCARD=m
CONFIG_PCMCIA=m
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=m
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
# CONFIG_PD6729 is not set
CONFIG_I82092=m
CONFIG_PCCARD_NONSTATIC=y
# CONFIG_RAPIDIO is not set

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set

#
# Firmware loader
#
CONFIG_FW_LOADER=y
CONFIG_FW_LOADER_PAGED_BUF=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
CONFIG_FW_LOADER_COMPRESS=y
CONFIG_FW_CACHE=y
# end of Firmware loader

CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
# CONFIG_TEST_ASYNC_DRIVER_PROBE is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SLIMBUS=m
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_FENCE_TRACE is not set
# end of Generic Driver Options

#
# Bus devices
#
CONFIG_SIMPLE_PM_BUS=m
# CONFIG_MHI_BUS is not set
# end of Bus devices

# CONFIG_CONNECTOR is not set
# CONFIG_GNSS is not set
CONFIG_MTD=y
# CONFIG_MTD_TESTS is not set

#
# Partition parsers
#
# CONFIG_MTD_AR7_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=m
CONFIG_MTD_OF_PARTS=m
CONFIG_MTD_REDBOOT_PARTS=m
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
# end of Partition parsers

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=m
# CONFIG_MTD_BLOCK_RO is not set
# CONFIG_FTL is not set
CONFIG_NFTL=y
# CONFIG_NFTL_RW is not set
CONFIG_INFTL=m
# CONFIG_RFD_FTL is not set
CONFIG_SSFDC=m
# CONFIG_SM_FTL is not set
CONFIG_MTD_OOPS=m
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=m
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
CONFIG_MTD_CFI_BE_BYTE_SWAP=y
# CONFIG_MTD_CFI_LE_BYTE_SWAP is not set
CONFIG_MTD_CFI_GEOMETRY=y
CONFIG_MTD_MAP_BANK_WIDTH_1=y
# CONFIG_MTD_MAP_BANK_WIDTH_2 is not set
CONFIG_MTD_MAP_BANK_WIDTH_4=y
CONFIG_MTD_MAP_BANK_WIDTH_8=y
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
CONFIG_MTD_MAP_BANK_WIDTH_32=y
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
CONFIG_MTD_CFI_I4=y
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_OTP=y
# CONFIG_MTD_CFI_INTELEXT is not set
CONFIG_MTD_CFI_AMDSTD=y
# CONFIG_MTD_CFI_STAA is not set
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=m
# CONFIG_MTD_ABSENT is not set
# end of RAM/ROM/Flash chip drivers

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
# CONFIG_MTD_PHYSMAP is not set
CONFIG_MTD_AMD76XROM=m
CONFIG_MTD_ICHXROM=m
CONFIG_MTD_ESB2ROM=m
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=m
# CONFIG_MTD_PCI is not set
CONFIG_MTD_PCMCIA=m
# CONFIG_MTD_PCMCIA_ANONYMOUS is not set
CONFIG_MTD_INTEL_VR_NOR=y
CONFIG_MTD_PLATRAM=y
# end of Mapping drivers for chip access

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_SLRAM is not set
CONFIG_MTD_PHRAM=y
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTD_BLOCK2MTD=m

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=m
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
# end of Self-contained MTD device drivers

#
# NAND
#
CONFIG_MTD_NAND_CORE=y
CONFIG_MTD_ONENAND=m
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
# CONFIG_MTD_ONENAND_GENERIC is not set
CONFIG_MTD_ONENAND_OTP=y
# CONFIG_MTD_ONENAND_2X_PROGRAM is not set
CONFIG_MTD_RAW_NAND=y

#
# Raw/parallel NAND flash controllers
#
CONFIG_MTD_NAND_DENALI=m
CONFIG_MTD_NAND_DENALI_PCI=m
# CONFIG_MTD_NAND_DENALI_DT is not set
CONFIG_MTD_NAND_CAFE=y
CONFIG_MTD_NAND_MXIC=y
# CONFIG_MTD_NAND_GPIO is not set
CONFIG_MTD_NAND_PLATFORM=y
CONFIG_MTD_NAND_CADENCE=y
# CONFIG_MTD_NAND_ARASAN is not set
CONFIG_MTD_NAND_INTEL_LGM=y

#
# Misc
#
CONFIG_MTD_SM_COMMON=y
# CONFIG_MTD_NAND_NANDSIM is not set
CONFIG_MTD_NAND_RICOH=y
CONFIG_MTD_NAND_DISKONCHIP=y
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED=y
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_HIGH is not set
CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE=y

#
# ECC engine support
#
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SW_HAMMING is not set
# CONFIG_MTD_NAND_ECC_SW_BCH is not set
# end of ECC engine support
# end of NAND

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
# end of LPDDR & LPDDR2 PCM memory drivers

# CONFIG_MTD_UBI is not set
# CONFIG_MTD_HYPERBUS is not set
CONFIG_DTC=y
CONFIG_OF=y
# CONFIG_OF_UNITTEST is not set
CONFIG_OF_FLATTREE=y
CONFIG_OF_EARLY_FLATTREE=y
CONFIG_OF_KOBJ=y
CONFIG_OF_DYNAMIC=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
CONFIG_OF_RESERVED_MEM=y
CONFIG_OF_RESOLVE=y
CONFIG_OF_OVERLAY=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_LOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SKD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# NVME Support
#
CONFIG_NVME_CORE=m
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_NVME_MULTIPATH is not set
# CONFIG_NVME_HWMON is not set
CONFIG_NVME_FABRICS=m
# CONFIG_NVME_FC is not set
CONFIG_NVME_TARGET=y
CONFIG_NVME_TARGET_LOOP=m
CONFIG_NVME_TARGET_FC=m
# CONFIG_NVME_TARGET_TCP is not set
# end of NVME Support

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=m
CONFIG_AD525X_DPOT_I2C=m
CONFIG_DUMMY_IRQ=y
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=m
CONFIG_TIFM_CORE=m
# CONFIG_TIFM_7XX1 is not set
# CONFIG_ICS932S401 is not set
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=m
CONFIG_ISL29003=m
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
CONFIG_SENSORS_BH1770=y
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
CONFIG_SRAM=y
CONFIG_PCI_ENDPOINT_TEST=m
CONFIG_XILINX_SDFEC=m
CONFIG_MISC_RTSX=m
CONFIG_PVPANIC=y
CONFIG_HISI_HIKEY_USB=m
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=m
# CONFIG_EEPROM_LEGACY is not set
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_IDT_89HPESX=m
CONFIG_EEPROM_EE1004=y
# end of EEPROM support

# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# end of Texas Instruments shared transport line discipline

CONFIG_SENSORS_LIS3_I2C=y
# CONFIG_ALTERA_STAPL is not set
CONFIG_INTEL_MEI=m
CONFIG_INTEL_MEI_ME=m
CONFIG_INTEL_MEI_TXE=m
CONFIG_INTEL_MEI_HDCP=m
# CONFIG_VMWARE_VMCI is not set
# CONFIG_GENWQE is not set
CONFIG_ECHO=m
# CONFIG_MISC_ALCOR_PCI is not set
CONFIG_MISC_RTSX_PCI=m
# CONFIG_MISC_RTSX_USB is not set
CONFIG_HABANA_AI=m
CONFIG_UACCE=m
# end of Misc devices

CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=y
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_ENCLOSURE=m
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_ATA is not set
# CONFIG_SCSI_SAS_HOST_SMP is not set
CONFIG_SCSI_SRP_ATTRS=m
# end of SCSI Transports

CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
CONFIG_ISCSI_BOOT_SYSFS=m
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_BE2ISCSI is not set
CONFIG_BLK_DEV_3W_XXXX_RAID=m
# CONFIG_SCSI_HPSA is not set
CONFIG_SCSI_3W_9XXX=m
# CONFIG_SCSI_3W_SAS is not set
CONFIG_SCSI_ACARD=y
CONFIG_SCSI_AACRAID=y
CONFIG_SCSI_AIC7XXX=m
CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
CONFIG_AIC7XXX_RESET_DELAY_MS=5000
# CONFIG_AIC7XXX_BUILD_FIRMWARE is not set
CONFIG_AIC7XXX_DEBUG_ENABLE=y
CONFIG_AIC7XXX_DEBUG_MASK=0
CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC79XX=m
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=5000
# CONFIG_AIC79XX_BUILD_FIRMWARE is not set
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC94XX=m
CONFIG_AIC94XX_DEBUG=y
CONFIG_SCSI_MVSAS=y
CONFIG_SCSI_MVSAS_DEBUG=y
CONFIG_SCSI_MVSAS_TASKLET=y
CONFIG_SCSI_MVUMI=m
CONFIG_SCSI_DPT_I2O=m
CONFIG_SCSI_ADVANSYS=m
CONFIG_SCSI_ARCMSR=y
CONFIG_SCSI_ESAS2R=m
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
CONFIG_MEGARAID_SAS=y
CONFIG_SCSI_MPT3SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_SMARTPQI=y
# CONFIG_SCSI_UFSHCD is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_SCSI_MYRB is not set
# CONFIG_SCSI_MYRS is not set
CONFIG_VMWARE_PVSCSI=m
CONFIG_SCSI_SNIC=y
CONFIG_SCSI_SNIC_DEBUG_FS=y
CONFIG_SCSI_DMX3191D=m
# CONFIG_SCSI_FDOMAIN_PCI is not set
CONFIG_SCSI_GDTH=m
CONFIG_SCSI_ISCI=m
CONFIG_SCSI_IPS=y
CONFIG_SCSI_INITIO=y
CONFIG_SCSI_INIA100=y
CONFIG_SCSI_STEX=m
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
CONFIG_SCSI_SYM53C8XX_MMIO=y
CONFIG_SCSI_IPR=y
CONFIG_SCSI_IPR_TRACE=y
CONFIG_SCSI_IPR_DUMP=y
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_ISCSI is not set
CONFIG_SCSI_DC395x=m
# CONFIG_SCSI_AM53C974 is not set
# CONFIG_SCSI_WD719X is not set
CONFIG_SCSI_DEBUG=m
# CONFIG_SCSI_PMCRAID is not set
CONFIG_SCSI_PM8001=y
CONFIG_SCSI_VIRTIO=m
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
# CONFIG_SCSI_DH is not set
# end of SCSI device support

CONFIG_ATA=y
CONFIG_SATA_HOST=y
CONFIG_PATA_TIMINGS=y
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_FORCE=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
# CONFIG_SATA_AHCI is not set
CONFIG_SATA_AHCI_PLATFORM=m
# CONFIG_AHCI_CEVA is not set
# CONFIG_AHCI_QORIQ is not set
CONFIG_SATA_INIC162X=y
CONFIG_SATA_ACARD_AHCI=m
CONFIG_SATA_SIL24=m
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=m
CONFIG_SATA_QSTOR=y
CONFIG_SATA_SX4=y
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=y
CONFIG_SATA_DWC=m
# CONFIG_SATA_DWC_OLD_DMA is not set
CONFIG_SATA_DWC_DEBUG=y
CONFIG_SATA_DWC_VDEBUG=y
CONFIG_SATA_MV=y
CONFIG_SATA_NV=m
# CONFIG_SATA_PROMISE is not set
CONFIG_SATA_SIL=y
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_SVW is not set
CONFIG_SATA_ULI=m
CONFIG_SATA_VIA=y
# CONFIG_SATA_VITESSE is not set

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=y
CONFIG_PATA_AMD=m
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
CONFIG_PATA_ATP867X=m
# CONFIG_PATA_CMD64X is not set
CONFIG_PATA_CYPRESS=m
# CONFIG_PATA_EFAR is not set
CONFIG_PATA_HPT366=m
# CONFIG_PATA_HPT37X is not set
CONFIG_PATA_HPT3X2N=m
# CONFIG_PATA_HPT3X3 is not set
CONFIG_PATA_IT8213=m
CONFIG_PATA_IT821X=m
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_MARVELL is not set
CONFIG_PATA_NETCELL=m
# CONFIG_PATA_NINJA32 is not set
CONFIG_PATA_NS87415=y
CONFIG_PATA_OLDPIIX=y
CONFIG_PATA_OPTIDMA=y
CONFIG_PATA_PDC2027X=m
CONFIG_PATA_PDC_OLD=y
# CONFIG_PATA_RADISYS is not set
CONFIG_PATA_RDC=m
# CONFIG_PATA_SCH is not set
CONFIG_PATA_SERVERWORKS=m
CONFIG_PATA_SIL680=m
CONFIG_PATA_SIS=m
CONFIG_PATA_TOSHIBA=y
CONFIG_PATA_TRIFLEX=m
CONFIG_PATA_VIA=y
CONFIG_PATA_WINBOND=y

#
# PIO-only SFF controllers
#
CONFIG_PATA_CMD640_PCI=y
CONFIG_PATA_MPIIX=y
CONFIG_PATA_NS87410=m
CONFIG_PATA_OPTI=m
CONFIG_PATA_PCMCIA=m
# CONFIG_PATA_PLATFORM is not set
CONFIG_PATA_RZ1000=m

#
# Generic fallback / legacy drivers
#
CONFIG_PATA_ACPI=m
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
# CONFIG_MD_AUTODETECT is not set
CONFIG_MD_LINEAR=m
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
CONFIG_MD_MULTIPATH=y
# CONFIG_MD_FAULTY is not set
CONFIG_BCACHE=y
# CONFIG_BCACHE_DEBUG is not set
# CONFIG_BCACHE_CLOSURES_DEBUG is not set
# CONFIG_BCACHE_ASYNC_REGISTRATION is not set
CONFIG_BLK_DEV_DM_BUILTIN=y
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_DEBUG is not set
CONFIG_DM_BUFIO=y
# CONFIG_DM_DEBUG_BLOCK_MANAGER_LOCKING is not set
CONFIG_DM_BIO_PRISON=y
CONFIG_DM_PERSISTENT_DATA=y
CONFIG_DM_UNSTRIPED=m
# CONFIG_DM_CRYPT is not set
CONFIG_DM_SNAPSHOT=m
CONFIG_DM_THIN_PROVISIONING=y
CONFIG_DM_CACHE=y
# CONFIG_DM_CACHE_SMQ is not set
CONFIG_DM_WRITECACHE=y
CONFIG_DM_EBS=m
CONFIG_DM_ERA=m
# CONFIG_DM_CLONE is not set
CONFIG_DM_MIRROR=m
# CONFIG_DM_LOG_USERSPACE is not set
CONFIG_DM_RAID=m
CONFIG_DM_ZERO=y
# CONFIG_DM_MULTIPATH is not set
CONFIG_DM_DELAY=m
CONFIG_DM_DUST=m
# CONFIG_DM_INIT is not set
CONFIG_DM_UEVENT=y
# CONFIG_DM_FLAKEY is not set
# CONFIG_DM_VERITY is not set
# CONFIG_DM_SWITCH is not set
# CONFIG_DM_LOG_WRITES is not set
CONFIG_DM_INTEGRITY=y
CONFIG_DM_ZONED=m
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=m
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=m
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
CONFIG_FIREWIRE_NOSY=y
# end of IEEE 1394 (FireWire) support

CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_WIREGUARD is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_FC is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_IPVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_GENEVE is not set
# CONFIG_BAREUDP is not set
# CONFIG_GTP is not set
# CONFIG_MACSEC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NTB_NETDEV is not set
# CONFIG_TUN is not set
# CONFIG_TUN_VNET_CROSS_LE is not set
# CONFIG_VETH is not set
CONFIG_VIRTIO_NET=m
# CONFIG_NLMON is not set
# CONFIG_ARCNET is not set

#
# Distributed Switch Architecture drivers
#
# end of Distributed Switch Architecture drivers

CONFIG_ETHERNET=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_PCMCIA_3C574 is not set
# CONFIG_PCMCIA_3C589 is not set
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
# CONFIG_ENA_ETHERNET is not set
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
# CONFIG_PCMCIA_NMCLAN is not set
# CONFIG_AMD_XGBE is not set
CONFIG_NET_VENDOR_AQUANTIA=y
# CONFIG_AQTION is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
CONFIG_NET_VENDOR_AURORA=y
# CONFIG_AURORA_NB8800 is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
# CONFIG_BCMGENET is not set
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
# CONFIG_SYSTEMPORT is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
CONFIG_NET_VENDOR_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
# CONFIG_LIQUIDIO is not set
# CONFIG_LIQUIDIO_VF is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
CONFIG_NET_VENDOR_CORTINA=y
# CONFIG_GEMINI_ETHERNET is not set
# CONFIG_CX_ECAT is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EZCHIP=y
# CONFIG_EZCHIP_NPS_MANAGEMENT_ENET is not set
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
CONFIG_NET_VENDOR_GOOGLE=y
# CONFIG_GVE is not set
CONFIG_NET_VENDOR_HUAWEI=y
# CONFIG_HINIC is not set
CONFIG_NET_VENDOR_I825XX=y
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
# CONFIG_E1000E is not set
# CONFIG_IGB is not set
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
# CONFIG_IXGBE is not set
# CONFIG_IXGBEVF is not set
# CONFIG_I40E is not set
# CONFIG_I40EVF is not set
# CONFIG_ICE is not set
# CONFIG_FM10K is not set
# CONFIG_IGC is not set
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_LAN743X is not set
CONFIG_NET_VENDOR_MICROSEMI=y
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_NETERION=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_NETRONOME=y
# CONFIG_NFP is not set
CONFIG_NET_VENDOR_NI=y
# CONFIG_NI_XGE_MANAGEMENT_ENET is not set
CONFIG_NET_VENDOR_8390=y
# CONFIG_PCMCIA_AXNET is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_PCMCIA_PCNET is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_ETHOC is not set
CONFIG_NET_VENDOR_PACKET_ENGINES=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_PENSANDO=y
# CONFIG_IONIC is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCOM_EMAC is not set
# CONFIG_RMNET is not set
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SOLARFLARE=y
# CONFIG_SFC is not set
# CONFIG_SFC_FALCON is not set
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_SOCIONEXT=y
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TI_CPSW_PHY_SEL is not set
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XILINX=y
# CONFIG_XILINX_AXI_EMAC is not set
# CONFIG_XILINX_LL_TEMAC is not set
CONFIG_NET_VENDOR_XIRCOM=y
# CONFIG_PCMCIA_XIRC2PS is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_PHYLIB is not set
# CONFIG_MDIO_DEVICE is not set

#
# PCS device drivers
#
# end of PCS device drivers

# CONFIG_PLIP is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
CONFIG_USB_NET_DRIVERS=y
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_RTL8152 is not set
# CONFIG_USB_LAN78XX is not set
# CONFIG_USB_USBNET is not set
# CONFIG_USB_IPHETH is not set
CONFIG_WLAN=y
CONFIG_WLAN_VENDOR_ADMTEK=y
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K_PCI is not set
CONFIG_WLAN_VENDOR_ATMEL=y
CONFIG_WLAN_VENDOR_BROADCOM=y
CONFIG_WLAN_VENDOR_CISCO=y
CONFIG_WLAN_VENDOR_INTEL=y
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_PRISM54 is not set
CONFIG_WLAN_VENDOR_MARVELL=y
CONFIG_WLAN_VENDOR_MEDIATEK=y
CONFIG_WLAN_VENDOR_MICROCHIP=y
CONFIG_WLAN_VENDOR_RALINK=y
CONFIG_WLAN_VENDOR_REALTEK=y
CONFIG_WLAN_VENDOR_RSI=y
CONFIG_WLAN_VENDOR_ST=y
CONFIG_WLAN_VENDOR_TI=y
CONFIG_WLAN_VENDOR_ZYDAS=y
CONFIG_WLAN_VENDOR_QUANTENNA=y
# CONFIG_PCMCIA_RAYCS is not set
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
# CONFIG_USB4_NET is not set
# CONFIG_NETDEVSIM is not set
CONFIG_NET_FAILOVER=m
# CONFIG_ISDN is not set
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=m
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_SPARSEKMAP=y
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=m
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=m
CONFIG_INPUT_EVDEV=m
CONFIG_INPUT_EVBUG=m

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1050 is not set
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_DLINK_DIR685 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_STMPE is not set
# CONFIG_KEYBOARD_IQS62X is not set
# CONFIG_KEYBOARD_OMAP4 is not set
# CONFIG_KEYBOARD_TC3589X is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_CAP11XX is not set
# CONFIG_KEYBOARD_BCM is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
# CONFIG_TOUCHSCREEN_AD7879 is not set
# CONFIG_TOUCHSCREEN_AR1021_I2C is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
CONFIG_TOUCHSCREEN_AUO_PIXCIR=m
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_BU21029 is not set
CONFIG_TOUCHSCREEN_CHIPONE_ICN8318=y
CONFIG_TOUCHSCREEN_CHIPONE_ICN8505=m
CONFIG_TOUCHSCREEN_CY8CTMA140=y
CONFIG_TOUCHSCREEN_CY8CTMG110=y
CONFIG_TOUCHSCREEN_CYTTSP_CORE=y
# CONFIG_TOUCHSCREEN_CYTTSP_I2C is not set
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP4_I2C=y
CONFIG_TOUCHSCREEN_DA9034=y
CONFIG_TOUCHSCREEN_DA9052=m
CONFIG_TOUCHSCREEN_DYNAPRO=m
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
# CONFIG_TOUCHSCREEN_EETI is not set
# CONFIG_TOUCHSCREEN_EGALAX is not set
CONFIG_TOUCHSCREEN_EGALAX_SERIAL=m
# CONFIG_TOUCHSCREEN_EXC3000 is not set
CONFIG_TOUCHSCREEN_FUJITSU=m
CONFIG_TOUCHSCREEN_GOODIX=m
CONFIG_TOUCHSCREEN_HIDEEP=m
CONFIG_TOUCHSCREEN_ILI210X=m
# CONFIG_TOUCHSCREEN_S6SY761 is not set
# CONFIG_TOUCHSCREEN_GUNZE is not set
CONFIG_TOUCHSCREEN_EKTF2127=m
CONFIG_TOUCHSCREEN_ELAN=y
CONFIG_TOUCHSCREEN_ELO=y
CONFIG_TOUCHSCREEN_WACOM_W8001=y
CONFIG_TOUCHSCREEN_WACOM_I2C=m
# CONFIG_TOUCHSCREEN_MAX11801 is not set
CONFIG_TOUCHSCREEN_MCS5000=y
CONFIG_TOUCHSCREEN_MMS114=m
CONFIG_TOUCHSCREEN_MELFAS_MIP4=m
CONFIG_TOUCHSCREEN_MTOUCH=y
CONFIG_TOUCHSCREEN_IMX6UL_TSC=m
CONFIG_TOUCHSCREEN_INEXIO=y
# CONFIG_TOUCHSCREEN_MK712 is not set
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
CONFIG_TOUCHSCREEN_TOUCHRIGHT=m
CONFIG_TOUCHSCREEN_TOUCHWIN=y
# CONFIG_TOUCHSCREEN_PIXCIR is not set
CONFIG_TOUCHSCREEN_WDT87XX_I2C=m
# CONFIG_TOUCHSCREEN_WM831X is not set
CONFIG_TOUCHSCREEN_WM97XX=y
# CONFIG_TOUCHSCREEN_WM9705 is not set
# CONFIG_TOUCHSCREEN_WM9712 is not set
CONFIG_TOUCHSCREEN_WM9713=y
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_MC13783=m
CONFIG_TOUCHSCREEN_TOUCHIT213=y
CONFIG_TOUCHSCREEN_TSC_SERIO=y
# CONFIG_TOUCHSCREEN_TSC2004 is not set
CONFIG_TOUCHSCREEN_TSC2007=m
CONFIG_TOUCHSCREEN_RM_TS=m
CONFIG_TOUCHSCREEN_SILEAD=m
CONFIG_TOUCHSCREEN_SIS_I2C=m
CONFIG_TOUCHSCREEN_ST1232=y
CONFIG_TOUCHSCREEN_STMFTS=y
CONFIG_TOUCHSCREEN_STMPE=m
CONFIG_TOUCHSCREEN_SX8654=m
# CONFIG_TOUCHSCREEN_TPS6507X is not set
CONFIG_TOUCHSCREEN_ZET6223=y
CONFIG_TOUCHSCREEN_ZFORCE=m
# CONFIG_TOUCHSCREEN_ROHM_BU21023 is not set
CONFIG_TOUCHSCREEN_IQS5XX=m
CONFIG_TOUCHSCREEN_ZINITIX=y
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_88PM80X_ONKEY is not set
# CONFIG_INPUT_AD714X is not set
CONFIG_INPUT_ATMEL_CAPTOUCH=y
CONFIG_INPUT_BMA150=y
CONFIG_INPUT_E3X0_BUTTON=y
CONFIG_INPUT_PCSPKR=y
CONFIG_INPUT_MAX77650_ONKEY=m
CONFIG_INPUT_MAX77693_HAPTIC=y
# CONFIG_INPUT_MAX8925_ONKEY is not set
# CONFIG_INPUT_MAX8997_HAPTIC is not set
CONFIG_INPUT_MC13783_PWRBUTTON=m
CONFIG_INPUT_MMA8450=m
CONFIG_INPUT_APANEL=y
CONFIG_INPUT_GPIO_BEEPER=y
CONFIG_INPUT_GPIO_DECODER=m
CONFIG_INPUT_GPIO_VIBRA=m
CONFIG_INPUT_ATLAS_BTNS=m
CONFIG_INPUT_ATI_REMOTE2=y
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_KXTJ9 is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
CONFIG_INPUT_CM109=m
CONFIG_INPUT_REGULATOR_HAPTIC=m
CONFIG_INPUT_TPS65218_PWRBUTTON=m
CONFIG_INPUT_AXP20X_PEK=m
# CONFIG_INPUT_UINPUT is not set
CONFIG_INPUT_PCF50633_PMU=m
CONFIG_INPUT_PCF8574=y
CONFIG_INPUT_PWM_BEEPER=m
# CONFIG_INPUT_PWM_VIBRA is not set
# CONFIG_INPUT_RK805_PWRKEY is not set
CONFIG_INPUT_GPIO_ROTARY_ENCODER=y
# CONFIG_INPUT_DA7280_HAPTICS is not set
# CONFIG_INPUT_DA9052_ONKEY is not set
CONFIG_INPUT_DA9063_ONKEY=m
CONFIG_INPUT_WM831X_ON=y
CONFIG_INPUT_ADXL34X=m
CONFIG_INPUT_ADXL34X_I2C=m
# CONFIG_INPUT_IMS_PCU is not set
CONFIG_INPUT_IQS269A=y
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_IDEAPAD_SLIDEBAR=m
CONFIG_INPUT_DRV260X_HAPTICS=y
# CONFIG_INPUT_DRV2665_HAPTICS is not set
CONFIG_INPUT_DRV2667_HAPTICS=m
# CONFIG_INPUT_STPMIC1_ONKEY is not set
CONFIG_RMI4_CORE=y
# CONFIG_RMI4_I2C is not set
# CONFIG_RMI4_SMB is not set
CONFIG_RMI4_F03=y
CONFIG_RMI4_F03_SERIO=y
CONFIG_RMI4_2D_SENSOR=y
CONFIG_RMI4_F11=y
CONFIG_RMI4_F12=y
CONFIG_RMI4_F30=y
CONFIG_RMI4_F34=y
CONFIG_RMI4_F3A=y
# CONFIG_RMI4_F55 is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=m
CONFIG_SERIO_PCIPS2=m
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_SERIO_APBPS2=y
CONFIG_SERIO_GPIO_PS2=m
# CONFIG_USERIO is not set
# CONFIG_GAMEPORT is not set
# end of Hardware I/O ports
# end of Input device support

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_LDISC_AUTOLOAD=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_16550A_VARIANTS is not set
CONFIG_SERIAL_8250_FINTEK=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
# CONFIG_SERIAL_8250_PCI is not set
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_MEN_MCB=m
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
CONFIG_SERIAL_8250_ASPEED_VUART=m
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_RT288X is not set
# CONFIG_SERIAL_8250_LPSS is not set
CONFIG_SERIAL_8250_MID=y
CONFIG_SERIAL_OF_PLATFORM=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_UARTLITE=y
CONFIG_SERIAL_UARTLITE_CONSOLE=y
CONFIG_SERIAL_UARTLITE_NR_UARTS=1
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SIFIVE=m
CONFIG_SERIAL_LANTIQ=y
# CONFIG_SERIAL_LANTIQ_CONSOLE is not set
CONFIG_SERIAL_SCCNXP=y
# CONFIG_SERIAL_SCCNXP_CONSOLE is not set
CONFIG_SERIAL_SC16IS7XX_CORE=m
CONFIG_SERIAL_SC16IS7XX=m
CONFIG_SERIAL_SC16IS7XX_I2C=y
CONFIG_SERIAL_BCM63XX=m
CONFIG_SERIAL_ALTERA_JTAGUART=m
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_ALTERA_UART_CONSOLE is not set
CONFIG_SERIAL_XILINX_PS_UART=m
CONFIG_SERIAL_ARC=m
CONFIG_SERIAL_ARC_NR_PORTS=1
CONFIG_SERIAL_RP2=y
CONFIG_SERIAL_RP2_NR_UARTS=32
# CONFIG_SERIAL_FSL_LPUART is not set
CONFIG_SERIAL_FSL_LINFLEXUART=y
CONFIG_SERIAL_FSL_LINFLEXUART_CONSOLE=y
CONFIG_SERIAL_CONEXANT_DIGICOLOR=m
# CONFIG_SERIAL_MEN_Z135 is not set
# CONFIG_SERIAL_SPRD is not set
# end of Serial drivers

CONFIG_SERIAL_MCTRL_GPIO=y
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
CONFIG_CYCLADES=m
CONFIG_CYZ_INTR=y
CONFIG_MOXA_INTELLIO=m
# CONFIG_MOXA_SMARTIO is not set
CONFIG_SYNCLINK_GT=y
CONFIG_ISI=y
# CONFIG_N_HDLC is not set
# CONFIG_N_GSM is not set
CONFIG_NOZOMI=y
CONFIG_NULL_TTY=m
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
CONFIG_HVC_DRIVER=y
# CONFIG_SERIAL_DEV_BUS is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
# CONFIG_PPDEV is not set
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
# CONFIG_IPMB_DEVICE_INTERFACE is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
CONFIG_HW_RANDOM_INTEL=m
# CONFIG_HW_RANDOM_AMD is not set
# CONFIG_HW_RANDOM_BA431 is not set
CONFIG_HW_RANDOM_VIA=m
CONFIG_HW_RANDOM_VIRTIO=m
# CONFIG_HW_RANDOM_CCTRNG is not set
CONFIG_HW_RANDOM_XIPHERA=m
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
CONFIG_CARDMAN_4000=m
CONFIG_CARDMAN_4040=m
CONFIG_SCR24X=m
# CONFIG_IPWIRELESS is not set
# end of PCMCIA character devices

CONFIG_MWAVE=y
CONFIG_DEVMEM=y
CONFIG_DEVKMEM=y
CONFIG_NVRAM=m
CONFIG_RAW_DRIVER=m
CONFIG_MAX_RAW_DEVS=256
CONFIG_DEVPORT=y
CONFIG_HPET=y
# CONFIG_HPET_MMAP is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=y
# CONFIG_HW_RANDOM_TPM is not set
# CONFIG_TCG_TIS is not set
# CONFIG_TCG_TIS_I2C_ATMEL is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=m
# CONFIG_TCG_NSC is not set
CONFIG_TCG_ATMEL=y
CONFIG_TCG_INFINEON=m
# CONFIG_TCG_CRB is not set
CONFIG_TCG_VTPM_PROXY=y
CONFIG_TCG_TIS_ST33ZP24=m
CONFIG_TCG_TIS_ST33ZP24_I2C=m
CONFIG_TELCLOCK=y
# CONFIG_XILLYBUS is not set
# end of Character devices

# CONFIG_RANDOM_TRUST_CPU is not set
# CONFIG_RANDOM_TRUST_BOOTLOADER is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_ARB_GPIO_CHALLENGE=y
# CONFIG_I2C_MUX_GPIO is not set
# CONFIG_I2C_MUX_GPMUX is not set
CONFIG_I2C_MUX_LTC4306=y
CONFIG_I2C_MUX_PCA9541=m
CONFIG_I2C_MUX_PCA954x=y
# CONFIG_I2C_MUX_PINCTRL is not set
CONFIG_I2C_MUX_REG=y
# CONFIG_I2C_DEMUX_PINCTRL is not set
CONFIG_I2C_MUX_MLXCPLD=y
# end of Multiplexer I2C Chip support

CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
CONFIG_I2C_ALI1563=m
CONFIG_I2C_ALI15X3=y
CONFIG_I2C_AMD756=y
# CONFIG_I2C_AMD756_S4882 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_AMD_MP2 is not set
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=m
CONFIG_I2C_NFORCE2=y
CONFIG_I2C_NFORCE2_S4985=m
CONFIG_I2C_NVIDIA_GPU=y
CONFIG_I2C_SIS5595=y
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=m
# CONFIG_I2C_VIA is not set
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
# CONFIG_I2C_DESIGNWARE_PLATFORM is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_EMEV2=y
CONFIG_I2C_GPIO=m
# CONFIG_I2C_GPIO_FAULT_INJECTOR is not set
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=m
# CONFIG_I2C_RK3X is not set
CONFIG_I2C_SIMTEC=m
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_DLN2=m
CONFIG_I2C_PARPORT=m
CONFIG_I2C_ROBOTFUZZ_OSIF=m
CONFIG_I2C_TAOS_EVM=y
CONFIG_I2C_TINY_USB=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_MLXCPLD=m
CONFIG_I2C_FSI=m
# end of I2C Hardware Bus support

CONFIG_I2C_STUB=m
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
CONFIG_I2C_SLAVE_TESTUNIT=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# end of I2C support

CONFIG_I3C=y
CONFIG_CDNS_I3C_MASTER=m
# CONFIG_DW_I3C_MASTER is not set
CONFIG_MIPI_I3C_HCI=m
# CONFIG_SPI is not set
CONFIG_SPMI=y
CONFIG_HSI=m
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_PARPORT=y
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# end of PTP clock support

CONFIG_PINCTRL=y
CONFIG_GENERIC_PINCTRL_GROUPS=y
CONFIG_PINMUX=y
CONFIG_GENERIC_PINMUX_FUNCTIONS=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
CONFIG_DEBUG_PINCTRL=y
CONFIG_PINCTRL_AS3722=m
CONFIG_PINCTRL_AXP209=m
CONFIG_PINCTRL_AMD=y
CONFIG_PINCTRL_MCP23S08_I2C=y
CONFIG_PINCTRL_MCP23S08=y
CONFIG_PINCTRL_SINGLE=m
CONFIG_PINCTRL_SX150X=y
CONFIG_PINCTRL_STMFX=y
# CONFIG_PINCTRL_RK805 is not set
CONFIG_PINCTRL_OCELOT=y
# CONFIG_PINCTRL_MICROCHIP_SGPIO is not set
# CONFIG_PINCTRL_BAYTRAIL is not set
CONFIG_PINCTRL_CHERRYVIEW=m
# CONFIG_PINCTRL_LYNXPOINT is not set
CONFIG_PINCTRL_INTEL=y
CONFIG_PINCTRL_ALDERLAKE=y
CONFIG_PINCTRL_BROXTON=m
CONFIG_PINCTRL_CANNONLAKE=m
CONFIG_PINCTRL_CEDARFORK=y
CONFIG_PINCTRL_DENVERTON=y
CONFIG_PINCTRL_ELKHARTLAKE=y
CONFIG_PINCTRL_EMMITSBURG=m
CONFIG_PINCTRL_GEMINILAKE=m
# CONFIG_PINCTRL_ICELAKE is not set
# CONFIG_PINCTRL_JASPERLAKE is not set
# CONFIG_PINCTRL_LAKEFIELD is not set
# CONFIG_PINCTRL_LEWISBURG is not set
CONFIG_PINCTRL_SUNRISEPOINT=y
CONFIG_PINCTRL_TIGERLAKE=m

#
# Renesas pinctrl drivers
#
# end of Renesas pinctrl drivers

CONFIG_PINCTRL_MADERA=m
CONFIG_PINCTRL_CS47L35=y
CONFIG_PINCTRL_CS47L85=y
CONFIG_PINCTRL_CS47L90=y
CONFIG_PINCTRL_CS47L92=y
CONFIG_PINCTRL_EQUILIBRIUM=y
CONFIG_GPIOLIB=y
CONFIG_GPIOLIB_FASTPATH_LIMIT=512
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_CDEV=y
CONFIG_GPIO_CDEV_V1=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_74XX_MMIO=y
CONFIG_GPIO_ALTERA=m
CONFIG_GPIO_AMDPT=m
CONFIG_GPIO_CADENCE=y
CONFIG_GPIO_DWAPB=y
# CONFIG_GPIO_FTGPIO010 is not set
# CONFIG_GPIO_GENERIC_PLATFORM is not set
CONFIG_GPIO_GRGPIO=m
CONFIG_GPIO_HLWD=m
CONFIG_GPIO_ICH=m
CONFIG_GPIO_LOGICVC=m
# CONFIG_GPIO_MB86S7X is not set
CONFIG_GPIO_MENZ127=m
CONFIG_GPIO_SAMA5D2_PIOBU=m
CONFIG_GPIO_SIFIVE=y
# CONFIG_GPIO_SIOX is not set
CONFIG_GPIO_SYSCON=y
# CONFIG_GPIO_VX855 is not set
CONFIG_GPIO_WCD934X=m
CONFIG_GPIO_XILINX=m
CONFIG_GPIO_AMD_FCH=y
# end of Memory mapped GPIO drivers

#
# Port-mapped I/O GPIO drivers
#
# CONFIG_GPIO_F7188X is not set
# CONFIG_GPIO_IT87 is not set
# CONFIG_GPIO_SCH is not set
CONFIG_GPIO_SCH311X=y
CONFIG_GPIO_WINBOND=y
# CONFIG_GPIO_WS16C48 is not set
# end of Port-mapped I/O GPIO drivers

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=m
CONFIG_GPIO_ADNP=y
CONFIG_GPIO_GW_PLD=y
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
# CONFIG_GPIO_MAX732X_IRQ is not set
CONFIG_GPIO_PCA953X=m
CONFIG_GPIO_PCA953X_IRQ=y
# CONFIG_GPIO_PCA9570 is not set
CONFIG_GPIO_PCF857X=y
# CONFIG_GPIO_TPIC2810 is not set
# end of I2C GPIO expanders

#
# MFD GPIO expanders
#
CONFIG_GPIO_ARIZONA=m
CONFIG_GPIO_BD71828=y
CONFIG_GPIO_BD9571MWV=y
# CONFIG_GPIO_DA9052 is not set
# CONFIG_GPIO_DLN2 is not set
CONFIG_GPIO_JANZ_TTL=m
# CONFIG_GPIO_LP873X is not set
# CONFIG_GPIO_MADERA is not set
# CONFIG_GPIO_MAX77650 is not set
# CONFIG_GPIO_RC5T583 is not set
CONFIG_GPIO_STMPE=y
CONFIG_GPIO_TC3589X=y
CONFIG_GPIO_TPS65218=m
CONFIG_GPIO_TPS6586X=y
CONFIG_GPIO_TPS65910=y
CONFIG_GPIO_TPS65912=m
CONFIG_GPIO_TQMX86=y
CONFIG_GPIO_WHISKEY_COVE=m
# CONFIG_GPIO_WM831X is not set
# CONFIG_GPIO_WM8994 is not set
# end of MFD GPIO expanders

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
CONFIG_GPIO_BT8XX=m
CONFIG_GPIO_ML_IOH=m
# CONFIG_GPIO_PCI_IDIO_16 is not set
CONFIG_GPIO_PCIE_IDIO_24=y
CONFIG_GPIO_RDC321X=m
# CONFIG_GPIO_SODAVILLE is not set
# end of PCI GPIO expanders

#
# USB GPIO expanders
#
# end of USB GPIO expanders

#
# Virtual GPIO drivers
#
CONFIG_GPIO_AGGREGATOR=m
CONFIG_GPIO_MOCKUP=m
# end of Virtual GPIO drivers

CONFIG_W1=m

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=m
# CONFIG_W1_MASTER_DS2490 is not set
CONFIG_W1_MASTER_DS2482=m
CONFIG_W1_MASTER_DS1WM=m
CONFIG_W1_MASTER_GPIO=m
# CONFIG_W1_MASTER_SGI is not set
# end of 1-wire Bus Masters

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=m
CONFIG_W1_SLAVE_SMEM=m
CONFIG_W1_SLAVE_DS2405=m
# CONFIG_W1_SLAVE_DS2408 is not set
CONFIG_W1_SLAVE_DS2413=m
CONFIG_W1_SLAVE_DS2406=m
CONFIG_W1_SLAVE_DS2423=m
CONFIG_W1_SLAVE_DS2805=m
CONFIG_W1_SLAVE_DS2430=m
# CONFIG_W1_SLAVE_DS2431 is not set
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2438=m
CONFIG_W1_SLAVE_DS250X=m
CONFIG_W1_SLAVE_DS2780=m
CONFIG_W1_SLAVE_DS2781=m
CONFIG_W1_SLAVE_DS28E04=m
CONFIG_W1_SLAVE_DS28E17=m
# end of 1-wire Slaves

# CONFIG_POWER_RESET is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_POWER_SUPPLY_HWMON=y
CONFIG_PDA_POWER=m
CONFIG_MAX8925_POWER=y
CONFIG_WM831X_BACKUP=y
# CONFIG_WM831X_POWER is not set
CONFIG_TEST_POWER=m
CONFIG_CHARGER_ADP5061=y
# CONFIG_BATTERY_ACT8945A is not set
# CONFIG_BATTERY_CW2015 is not set
CONFIG_BATTERY_DS2760=m
CONFIG_BATTERY_DS2780=m
CONFIG_BATTERY_DS2781=m
CONFIG_BATTERY_DS2782=m
CONFIG_BATTERY_WM97XX=y
CONFIG_BATTERY_SBS=y
# CONFIG_CHARGER_SBS is not set
# CONFIG_MANAGER_SBS is not set
CONFIG_BATTERY_BQ27XXX=m
CONFIG_BATTERY_BQ27XXX_I2C=m
CONFIG_BATTERY_BQ27XXX_HDQ=m
# CONFIG_BATTERY_BQ27XXX_DT_UPDATES_NVM is not set
CONFIG_BATTERY_DA9030=y
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_BATTERY_MAX1721X is not set
# CONFIG_CHARGER_PCF50633 is not set
# CONFIG_CHARGER_ISP1704 is not set
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_GPIO=m
CONFIG_CHARGER_MANAGER=y
CONFIG_CHARGER_LT3651=m
# CONFIG_CHARGER_DETECTOR_MAX14656 is not set
# CONFIG_CHARGER_MAX77650 is not set
# CONFIG_CHARGER_MAX77693 is not set
CONFIG_CHARGER_BQ2415X=y
# CONFIG_CHARGER_BQ24190 is not set
CONFIG_CHARGER_BQ24257=m
# CONFIG_CHARGER_BQ24735 is not set
CONFIG_CHARGER_BQ2515X=y
CONFIG_CHARGER_BQ25890=m
# CONFIG_CHARGER_BQ25980 is not set
CONFIG_CHARGER_SMB347=m
CONFIG_BATTERY_GAUGE_LTC2941=m
CONFIG_BATTERY_RT5033=m
CONFIG_CHARGER_RT9455=m
# CONFIG_CHARGER_UCS1002 is not set
# CONFIG_CHARGER_BD99954 is not set
CONFIG_RN5T618_POWER=m
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
CONFIG_SENSORS_AD7414=m
CONFIG_SENSORS_AD7418=m
CONFIG_SENSORS_ADM1021=m
CONFIG_SENSORS_ADM1025=y
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=y
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM1177=m
# CONFIG_SENSORS_ADM9240 is not set
CONFIG_SENSORS_ADT7X10=m
CONFIG_SENSORS_ADT7410=m
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=y
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_AS370=y
CONFIG_SENSORS_ASC7621=m
CONFIG_SENSORS_AXI_FAN_CONTROL=y
CONFIG_SENSORS_K8TEMP=m
CONFIG_SENSORS_K10TEMP=y
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_AMD_ENERGY is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ASPEED=m
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_CORSAIR_CPRO=y
# CONFIG_SENSORS_CORSAIR_PSU is not set
CONFIG_SENSORS_DRIVETEMP=y
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=m
# CONFIG_SENSORS_DELL_SMM is not set
CONFIG_SENSORS_DA9052_ADC=m
CONFIG_SENSORS_I5K_AMB=m
# CONFIG_SENSORS_F71805F is not set
CONFIG_SENSORS_F71882FG=m
CONFIG_SENSORS_F75375S=m
CONFIG_SENSORS_MC13783_ADC=m
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=m
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=m
# CONFIG_SENSORS_GPIO_FAN is not set
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_I5500=m
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_POWR1220 is not set
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
# CONFIG_SENSORS_LTC2947_I2C is not set
CONFIG_SENSORS_LTC2990=m
# CONFIG_SENSORS_LTC2992 is not set
CONFIG_SENSORS_LTC4151=y
# CONFIG_SENSORS_LTC4215 is not set
# CONFIG_SENSORS_LTC4222 is not set
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=m
CONFIG_SENSORS_LTC4261=y
# CONFIG_SENSORS_MAX127 is not set
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
# CONFIG_SENSORS_MAX1668 is not set
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX31730=y
CONFIG_SENSORS_MAX6621=m
CONFIG_SENSORS_MAX6639=m
CONFIG_SENSORS_MAX6642=m
CONFIG_SENSORS_MAX6650=m
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MAX31790=y
CONFIG_SENSORS_MCP3021=m
CONFIG_SENSORS_TC654=m
CONFIG_SENSORS_MENF21BMC_HWMON=y
# CONFIG_SENSORS_MR75203 is not set
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM73=m
CONFIG_SENSORS_LM75=m
# CONFIG_SENSORS_LM77 is not set
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=y
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=m
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=m
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_NTC_THERMISTOR=y
# CONFIG_SENSORS_NCT6683 is not set
# CONFIG_SENSORS_NCT6775 is not set
# CONFIG_SENSORS_NCT7802 is not set
CONFIG_SENSORS_NPCM7XX=m
# CONFIG_SENSORS_PCF8591 is not set
CONFIG_PMBUS=m
# CONFIG_SENSORS_PMBUS is not set
CONFIG_SENSORS_ADM1266=m
CONFIG_SENSORS_ADM1275=m
CONFIG_SENSORS_BEL_PFE=m
# CONFIG_SENSORS_IBM_CFFPS is not set
CONFIG_SENSORS_INSPUR_IPSPS=m
# CONFIG_SENSORS_IR35221 is not set
CONFIG_SENSORS_IR38064=m
CONFIG_SENSORS_IRPS5401=m
CONFIG_SENSORS_ISL68137=m
# CONFIG_SENSORS_LM25066 is not set
CONFIG_SENSORS_LTC2978=m
CONFIG_SENSORS_LTC2978_REGULATOR=y
CONFIG_SENSORS_LTC3815=m
# CONFIG_SENSORS_MAX16064 is not set
CONFIG_SENSORS_MAX16601=m
CONFIG_SENSORS_MAX20730=m
CONFIG_SENSORS_MAX20751=m
CONFIG_SENSORS_MAX31785=m
CONFIG_SENSORS_MAX34440=m
# CONFIG_SENSORS_MAX8688 is not set
CONFIG_SENSORS_MP2975=m
CONFIG_SENSORS_PM6764TR=m
# CONFIG_SENSORS_PXE1610 is not set
CONFIG_SENSORS_Q54SJ108A2=m
# CONFIG_SENSORS_TPS40422 is not set
CONFIG_SENSORS_TPS53679=m
# CONFIG_SENSORS_UCD9000 is not set
# CONFIG_SENSORS_UCD9200 is not set
# CONFIG_SENSORS_XDPE122 is not set
CONFIG_SENSORS_ZL6100=m
# CONFIG_SENSORS_PWM_FAN is not set
CONFIG_SENSORS_SBTSI=m
CONFIG_SENSORS_SHT15=m
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SHT3x is not set
CONFIG_SENSORS_SHTC1=m
CONFIG_SENSORS_SIS5595=m
# CONFIG_SENSORS_DME1737 is not set
CONFIG_SENSORS_EMC1403=y
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=m
# CONFIG_SENSORS_STTS751 is not set
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_ADC128D818=m
CONFIG_SENSORS_ADS7828=m
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
CONFIG_SENSORS_INA2XX=m
# CONFIG_SENSORS_INA3221 is not set
CONFIG_SENSORS_TC74=y
CONFIG_SENSORS_THMC50=m
CONFIG_SENSORS_TMP102=y
# CONFIG_SENSORS_TMP103 is not set
CONFIG_SENSORS_TMP108=m
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=m
CONFIG_SENSORS_TMP513=y
CONFIG_SENSORS_VIA_CPUTEMP=m
CONFIG_SENSORS_VIA686A=y
# CONFIG_SENSORS_VT1211 is not set
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83773G=y
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
CONFIG_SENSORS_W83793=m
CONFIG_SENSORS_W83795=m
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=m
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
CONFIG_SENSORS_W83627EHF=m
CONFIG_SENSORS_WM831X=m

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=y
# CONFIG_THERMAL_NETLINK is not set
# CONFIG_THERMAL_STATISTICS is not set
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
# CONFIG_THERMAL_HWMON is not set
CONFIG_THERMAL_OF=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_BANG_BANG=y
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_CPU_THERMAL=y
CONFIG_CPU_FREQ_THERMAL=y
CONFIG_CPU_IDLE_THERMAL=y
# CONFIG_DEVFREQ_THERMAL is not set
CONFIG_THERMAL_EMULATION=y
CONFIG_THERMAL_MMIO=m

#
# Intel thermal drivers
#
CONFIG_INTEL_POWERCLAMP=m
CONFIG_INTEL_SOC_DTS_IOSF_CORE=m
CONFIG_INTEL_SOC_DTS_THERMAL=m

#
# ACPI INT340X thermal drivers
#
CONFIG_INT340X_THERMAL=m
CONFIG_ACPI_THERMAL_REL=m
# CONFIG_INT3406_THERMAL is not set
CONFIG_PROC_THERMAL_MMIO_RAPL=m
# end of ACPI INT340X thermal drivers

CONFIG_INTEL_BXT_PMIC_THERMAL=m
# CONFIG_INTEL_PCH_THERMAL is not set
# end of Intel thermal drivers

# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
# CONFIG_SSB_PCIHOST is not set
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_SFLASH=y
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
# CONFIG_BCMA_DRIVER_GPIO is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_ACT8945A=y
CONFIG_MFD_AS3711=y
CONFIG_MFD_AS3722=m
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_ATMEL_FLEXCOM=m
CONFIG_MFD_ATMEL_HLCDC=m
# CONFIG_MFD_BCM590XX is not set
CONFIG_MFD_BD9571MWV=y
CONFIG_MFD_AXP20X=m
CONFIG_MFD_AXP20X_I2C=m
CONFIG_MFD_MADERA=m
# CONFIG_MFD_MADERA_I2C is not set
# CONFIG_MFD_CS47L15 is not set
CONFIG_MFD_CS47L35=y
CONFIG_MFD_CS47L85=y
CONFIG_MFD_CS47L90=y
CONFIG_MFD_CS47L92=y
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9062 is not set
CONFIG_MFD_DA9063=m
# CONFIG_MFD_DA9150 is not set
CONFIG_MFD_DLN2=m
# CONFIG_MFD_GATEWORKS_GSC is not set
CONFIG_MFD_MC13XXX=m
CONFIG_MFD_MC13XXX_I2C=m
CONFIG_MFD_MP2629=y
CONFIG_MFD_HI6421_PMIC=y
CONFIG_HTC_PASIC3=m
CONFIG_HTC_I2CPLD=y
CONFIG_MFD_INTEL_QUARK_I2C_GPIO=m
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_INTEL_SOC_PMIC_BXTWC=m
# CONFIG_INTEL_SOC_PMIC_CHTDC_TI is not set
# CONFIG_INTEL_SOC_PMIC_MRFLD is not set
CONFIG_MFD_INTEL_LPSS=m
CONFIG_MFD_INTEL_LPSS_ACPI=m
CONFIG_MFD_INTEL_LPSS_PCI=m
# CONFIG_MFD_INTEL_MSIC is not set
CONFIG_MFD_INTEL_PMC_BXT=m
CONFIG_MFD_INTEL_PMT=y
CONFIG_MFD_IQS62X=y
CONFIG_MFD_JANZ_CMODIO=y
# CONFIG_MFD_KEMPLD is not set
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=m
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77620 is not set
CONFIG_MFD_MAX77650=m
CONFIG_MFD_MAX77686=m
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX77843=y
# CONFIG_MFD_MAX8907 is not set
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
CONFIG_MFD_MAX8998=y
# CONFIG_MFD_MT6360 is not set
# CONFIG_MFD_MT6397 is not set
CONFIG_MFD_MENF21BMC=y
# CONFIG_MFD_VIPERBOARD is not set
# CONFIG_MFD_RETU is not set
CONFIG_MFD_PCF50633=m
CONFIG_PCF50633_ADC=m
CONFIG_PCF50633_GPIO=m
# CONFIG_UCB1400_CORE is not set
CONFIG_MFD_RDC321X=m
CONFIG_MFD_RT5033=y
CONFIG_MFD_RC5T583=y
CONFIG_MFD_RK808=y
CONFIG_MFD_RN5T618=y
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
CONFIG_MFD_SKY81452=y
CONFIG_ABX500_CORE=y
CONFIG_AB3100_CORE=y
CONFIG_AB3100_OTP=y
CONFIG_MFD_STMPE=y

#
# STMicroelectronics STMPE Interface Drivers
#
# CONFIG_STMPE_I2C is not set
# end of STMicroelectronics STMPE Interface Drivers

CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP3943 is not set
CONFIG_MFD_LP8788=y
CONFIG_MFD_TI_LMU=m
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=m
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=m
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
CONFIG_MFD_TI_LP873X=y
# CONFIG_MFD_TI_LP87565 is not set
CONFIG_MFD_TPS65218=m
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=m
CONFIG_MFD_TPS65912_I2C=m
CONFIG_MFD_TPS80031=y
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_MFD_LM3533=m
CONFIG_MFD_TC3589X=y
CONFIG_MFD_TQMX86=y
CONFIG_MFD_VX855=y
# CONFIG_MFD_LOCHNAGAR is not set
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
CONFIG_MFD_CS47L24=y
CONFIG_MFD_WM5102=y
CONFIG_MFD_WM5110=y
# CONFIG_MFD_WM8997 is not set
CONFIG_MFD_WM8998=y
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
# CONFIG_MFD_ROHM_BD718XX is not set
# CONFIG_MFD_ROHM_BD70528 is not set
CONFIG_MFD_ROHM_BD71828=y
CONFIG_MFD_STPMIC1=y
CONFIG_MFD_STMFX=y
CONFIG_MFD_WCD934X=m
# end of Multifunction device drivers

CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=m
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_88PG86X=m
CONFIG_REGULATOR_88PM800=y
CONFIG_REGULATOR_ACT8865=m
# CONFIG_REGULATOR_ACT8945A is not set
CONFIG_REGULATOR_AD5398=m
CONFIG_REGULATOR_AB3100=y
CONFIG_REGULATOR_AS3711=y
CONFIG_REGULATOR_AS3722=m
# CONFIG_REGULATOR_AXP20X is not set
# CONFIG_REGULATOR_BD71828 is not set
# CONFIG_REGULATOR_BD9571MWV is not set
# CONFIG_REGULATOR_DA903X is not set
# CONFIG_REGULATOR_DA9052 is not set
CONFIG_REGULATOR_DA9063=m
# CONFIG_REGULATOR_DA9121 is not set
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=m
# CONFIG_REGULATOR_FAN53880 is not set
CONFIG_REGULATOR_GPIO=m
CONFIG_REGULATOR_HI6421=m
CONFIG_REGULATOR_HI6421V530=y
CONFIG_REGULATOR_ISL9305=m
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LM363X=m
CONFIG_REGULATOR_LP3971=m
CONFIG_REGULATOR_LP3972=m
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_LP873X=m
CONFIG_REGULATOR_LP8755=m
CONFIG_REGULATOR_LP8788=y
CONFIG_REGULATOR_LTC3589=m
CONFIG_REGULATOR_LTC3676=m
# CONFIG_REGULATOR_MAX1586 is not set
CONFIG_REGULATOR_MAX77650=m
CONFIG_REGULATOR_MAX8649=m
CONFIG_REGULATOR_MAX8660=m
# CONFIG_REGULATOR_MAX8925 is not set
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8973=m
# CONFIG_REGULATOR_MAX8997 is not set
# CONFIG_REGULATOR_MAX8998 is not set
CONFIG_REGULATOR_MAX77686=m
CONFIG_REGULATOR_MAX77693=y
CONFIG_REGULATOR_MAX77802=m
CONFIG_REGULATOR_MAX77826=m
CONFIG_REGULATOR_MC13XXX_CORE=m
CONFIG_REGULATOR_MC13783=m
# CONFIG_REGULATOR_MC13892 is not set
CONFIG_REGULATOR_MCP16502=m
CONFIG_REGULATOR_MP5416=m
CONFIG_REGULATOR_MP8859=m
CONFIG_REGULATOR_MP886X=m
CONFIG_REGULATOR_MPQ7920=y
# CONFIG_REGULATOR_MT6311 is not set
CONFIG_REGULATOR_PCA9450=m
# CONFIG_REGULATOR_PCF50633 is not set
# CONFIG_REGULATOR_PF8X00 is not set
# CONFIG_REGULATOR_PFUZE100 is not set
CONFIG_REGULATOR_PV88060=y
CONFIG_REGULATOR_PV88080=y
# CONFIG_REGULATOR_PV88090 is not set
CONFIG_REGULATOR_PWM=m
# CONFIG_REGULATOR_QCOM_SPMI is not set
CONFIG_REGULATOR_QCOM_USB_VBUS=m
CONFIG_REGULATOR_RASPBERRYPI_TOUCHSCREEN_ATTINY=y
CONFIG_REGULATOR_RC5T583=y
CONFIG_REGULATOR_RK808=y
# CONFIG_REGULATOR_RN5T618 is not set
# CONFIG_REGULATOR_RT4801 is not set
CONFIG_REGULATOR_RT5033=m
# CONFIG_REGULATOR_RTMV20 is not set
CONFIG_REGULATOR_S2MPA01=m
# CONFIG_REGULATOR_S2MPS11 is not set
# CONFIG_REGULATOR_S5M8767 is not set
CONFIG_REGULATOR_SKY81452=m
CONFIG_REGULATOR_SLG51000=y
CONFIG_REGULATOR_STPMIC1=m
CONFIG_REGULATOR_SY8106A=y
CONFIG_REGULATOR_SY8824X=m
# CONFIG_REGULATOR_SY8827N is not set
# CONFIG_REGULATOR_TPS51632 is not set
CONFIG_REGULATOR_TPS6105X=m
# CONFIG_REGULATOR_TPS62360 is not set
# CONFIG_REGULATOR_TPS65023 is not set
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS65132 is not set
CONFIG_REGULATOR_TPS65218=m
# CONFIG_REGULATOR_TPS6586X is not set
CONFIG_REGULATOR_TPS65910=y
CONFIG_REGULATOR_TPS65912=m
CONFIG_REGULATOR_TPS80031=m
CONFIG_REGULATOR_VCTRL=y
CONFIG_REGULATOR_WM831X=m
CONFIG_REGULATOR_WM8400=y
CONFIG_REGULATOR_WM8994=y
CONFIG_REGULATOR_QCOM_LABIBB=m
# CONFIG_RC_CORE is not set
CONFIG_CEC_CORE=y
CONFIG_CEC_NOTIFIER=y
CONFIG_MEDIA_CEC_SUPPORT=y
# CONFIG_CEC_CH7322 is not set
CONFIG_CEC_SECO=m
CONFIG_USB_PULSE8_CEC=m
# CONFIG_USB_RAINSHADOW_CEC is not set
CONFIG_MEDIA_SUPPORT=y
# CONFIG_MEDIA_SUPPORT_FILTER is not set
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y

#
# Media device types
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
CONFIG_MEDIA_SDR_SUPPORT=y
CONFIG_MEDIA_PLATFORM_SUPPORT=y
CONFIG_MEDIA_TEST_SUPPORT=y
# end of Media device types

#
# Media core support
#
# CONFIG_VIDEO_DEV is not set
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_DVB_CORE=y
# end of Media core support

#
# Digital TV options
#
CONFIG_DVB_NET=y
CONFIG_DVB_MAX_ADAPTERS=16
CONFIG_DVB_DYNAMIC_MINORS=y
CONFIG_DVB_DEMUX_SECTION_LOSS_LOG=y
CONFIG_DVB_ULE_DEBUG=y
# end of Digital TV options

#
# Media drivers
#
# CONFIG_MEDIA_USB_SUPPORT is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
CONFIG_DVB_PLATFORM_DRIVERS=y
CONFIG_SDR_PLATFORM_DRIVERS=y
# CONFIG_DVB_TEST_DRIVERS is not set
# end of Media drivers

#
# Media ancillary drivers
#
CONFIG_MEDIA_ATTACH=y
CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA18250=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
# CONFIG_MEDIA_TUNER_MT2060 is not set
CONFIG_MEDIA_TUNER_MT2063=y
CONFIG_MEDIA_TUNER_MT2266=m
CONFIG_MEDIA_TUNER_MT2131=y
# CONFIG_MEDIA_TUNER_QT1010 is not set
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MXL5005S=y
# CONFIG_MEDIA_TUNER_MXL5007T is not set
CONFIG_MEDIA_TUNER_MC44S803=y
CONFIG_MEDIA_TUNER_MAX2165=y
# CONFIG_MEDIA_TUNER_TDA18218 is not set
# CONFIG_MEDIA_TUNER_FC0011 is not set
# CONFIG_MEDIA_TUNER_FC0012 is not set
CONFIG_MEDIA_TUNER_FC0013=m
CONFIG_MEDIA_TUNER_TDA18212=y
# CONFIG_MEDIA_TUNER_M88RS6000T is not set
CONFIG_MEDIA_TUNER_TUA9001=m
CONFIG_MEDIA_TUNER_SI2157=m
# CONFIG_MEDIA_TUNER_IT913X is not set
CONFIG_MEDIA_TUNER_R820T=m
CONFIG_MEDIA_TUNER_MXL301RF=y
# CONFIG_MEDIA_TUNER_QM1D1C0042 is not set
CONFIG_MEDIA_TUNER_QM1D1B0004=y
# end of Customize TV tuners

#
# Customise DVB Frontends
#

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=y
CONFIG_DVB_STB6100=m
CONFIG_DVB_STV090x=m
CONFIG_DVB_STV0910=m
CONFIG_DVB_STV6110x=m
CONFIG_DVB_STV6111=m
CONFIG_DVB_MXL5XX=m
CONFIG_DVB_M88DS3103=y

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=y
CONFIG_DVB_TDA18271C2DD=m
CONFIG_DVB_SI2165=m
# CONFIG_DVB_MN88472 is not set
CONFIG_DVB_MN88473=m

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=y
# CONFIG_DVB_CX24123 is not set
# CONFIG_DVB_MT312 is not set
CONFIG_DVB_ZL10036=y
# CONFIG_DVB_ZL10039 is not set
CONFIG_DVB_S5H1420=m
CONFIG_DVB_STV0288=m
# CONFIG_DVB_STB6000 is not set
# CONFIG_DVB_STV0299 is not set
CONFIG_DVB_STV6110=m
CONFIG_DVB_STV0900=m
CONFIG_DVB_TDA8083=y
# CONFIG_DVB_TDA10086 is not set
CONFIG_DVB_TDA8261=m
CONFIG_DVB_VES1X93=m
CONFIG_DVB_TUNER_ITD1000=m
CONFIG_DVB_TUNER_CX24113=y
# CONFIG_DVB_TDA826X is not set
CONFIG_DVB_TUA6100=m
# CONFIG_DVB_CX24116 is not set
CONFIG_DVB_CX24117=y
# CONFIG_DVB_CX24120 is not set
CONFIG_DVB_SI21XX=m
# CONFIG_DVB_TS2020 is not set
# CONFIG_DVB_DS3000 is not set
# CONFIG_DVB_MB86A16 is not set
CONFIG_DVB_TDA10071=m

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=y
CONFIG_DVB_SP887X=m
CONFIG_DVB_CX22700=m
CONFIG_DVB_CX22702=m
CONFIG_DVB_S5H1432=m
# CONFIG_DVB_DRXD is not set
# CONFIG_DVB_L64781 is not set
# CONFIG_DVB_TDA1004X is not set
CONFIG_DVB_NXT6000=m
CONFIG_DVB_MT352=y
# CONFIG_DVB_ZL10353 is not set
CONFIG_DVB_DIB3000MB=y
CONFIG_DVB_DIB3000MC=y
# CONFIG_DVB_DIB7000M is not set
CONFIG_DVB_DIB7000P=m
CONFIG_DVB_DIB9000=m
# CONFIG_DVB_TDA10048 is not set
CONFIG_DVB_AF9013=m
# CONFIG_DVB_EC100 is not set
CONFIG_DVB_STV0367=m
CONFIG_DVB_CXD2820R=y
CONFIG_DVB_CXD2841ER=y
CONFIG_DVB_RTL2830=y
CONFIG_DVB_RTL2832=m
# CONFIG_DVB_SI2168 is not set
# CONFIG_DVB_ZD1301_DEMOD is not set

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=y
# CONFIG_DVB_TDA10021 is not set
# CONFIG_DVB_TDA10023 is not set
CONFIG_DVB_STV0297=m

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=m
# CONFIG_DVB_OR51211 is not set
CONFIG_DVB_OR51132=y
# CONFIG_DVB_BCM3510 is not set
CONFIG_DVB_LGDT330X=y
CONFIG_DVB_LGDT3305=m
CONFIG_DVB_LGDT3306A=m
CONFIG_DVB_LG2160=m
CONFIG_DVB_S5H1409=y
CONFIG_DVB_AU8522=m
CONFIG_DVB_AU8522_DTV=m
# CONFIG_DVB_S5H1411 is not set

#
# ISDB-T (terrestrial) frontends
#
# CONFIG_DVB_S921 is not set
# CONFIG_DVB_DIB8000 is not set
# CONFIG_DVB_MB86A20S is not set

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=y
CONFIG_DVB_MN88443X=y

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y
# CONFIG_DVB_TUNER_DIB0070 is not set
CONFIG_DVB_TUNER_DIB0090=y

#
# SEC control devices for DVB-S
#
# CONFIG_DVB_DRX39XYJ is not set
CONFIG_DVB_LNBH25=y
CONFIG_DVB_LNBH29=m
CONFIG_DVB_LNBP21=m
CONFIG_DVB_LNBP22=y
CONFIG_DVB_ISL6405=m
CONFIG_DVB_ISL6421=y
CONFIG_DVB_ISL6423=m
# CONFIG_DVB_A8293 is not set
CONFIG_DVB_LGS8GL5=m
CONFIG_DVB_LGS8GXX=m
CONFIG_DVB_ATBM8830=y
CONFIG_DVB_TDA665x=y
CONFIG_DVB_IX2505V=y
CONFIG_DVB_M88RS2000=m
# CONFIG_DVB_AF9033 is not set
CONFIG_DVB_HORUS3A=y
# CONFIG_DVB_ASCOT2E is not set
CONFIG_DVB_HELENE=m

#
# Common Interface (EN50221) controller drivers
#
CONFIG_DVB_CXD2099=y
CONFIG_DVB_SP2=m
# end of Customise DVB Frontends

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set
# end of Media ancillary drivers

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_INTEL_GTT=m
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_MIPI_DSI=y
# CONFIG_DRM_DP_AUX_CHARDEV is not set
# CONFIG_DRM_DEBUG_MM is not set
# CONFIG_DRM_DEBUG_SELFTEST is not set
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
# CONFIG_DRM_DEBUG_DP_MST_TOPOLOGY_REFS is not set
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_FBDEV_OVERALLOC=100
# CONFIG_DRM_FBDEV_LEAK_PHYS_SMEM is not set
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_DP_CEC=y
CONFIG_DRM_TTM=y
CONFIG_DRM_VRAM_HELPER=y
CONFIG_DRM_TTM_HELPER=y
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y
CONFIG_DRM_GEM_SHMEM_HELPER=y
CONFIG_DRM_VM=y
CONFIG_DRM_SCHED=m

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=m
# CONFIG_DRM_I2C_SIL164 is not set
CONFIG_DRM_I2C_NXP_TDA998X=y
CONFIG_DRM_I2C_NXP_TDA9950=y
# end of I2C encoder or helper chips

#
# ARM devices
#
# CONFIG_DRM_KOMEDA is not set
# end of ARM devices

# CONFIG_DRM_RADEON is not set
CONFIG_DRM_AMDGPU=m
CONFIG_DRM_AMDGPU_SI=y
CONFIG_DRM_AMDGPU_CIK=y
# CONFIG_DRM_AMDGPU_USERPTR is not set
# CONFIG_DRM_AMDGPU_GART_DEBUGFS is not set

#
# ACP (Audio CoProcessor) Configuration
#
# CONFIG_DRM_AMD_ACP is not set
# end of ACP (Audio CoProcessor) Configuration

#
# Display Engine Configuration
#
# CONFIG_DRM_AMD_DC is not set
CONFIG_DRM_AMD_DC_SI=y
# end of Display Engine Configuration

# CONFIG_HSA_AMD is not set
CONFIG_DRM_NOUVEAU=y
CONFIG_NOUVEAU_LEGACY_CTX_SUPPORT=y
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
# CONFIG_NOUVEAU_DEBUG_MMU is not set
# CONFIG_NOUVEAU_DEBUG_PUSH is not set
CONFIG_DRM_NOUVEAU_BACKLIGHT=y
CONFIG_DRM_I915=m
CONFIG_DRM_I915_FORCE_PROBE=""
CONFIG_DRM_I915_CAPTURE_ERROR=y
CONFIG_DRM_I915_COMPRESS_ERROR=y
# CONFIG_DRM_I915_USERPTR is not set
# CONFIG_DRM_I915_GVT is not set

#
# drm/i915 Debugging
#
CONFIG_DRM_I915_WERROR=y
# CONFIG_DRM_I915_DEBUG is not set
# CONFIG_DRM_I915_DEBUG_MMIO is not set
# CONFIG_DRM_I915_DEBUG_GEM is not set
# CONFIG_DRM_I915_SW_FENCE_DEBUG_OBJECTS is not set
# CONFIG_DRM_I915_SW_FENCE_CHECK_DAG is not set
# CONFIG_DRM_I915_DEBUG_GUC is not set
# CONFIG_DRM_I915_SELFTEST is not set
# CONFIG_DRM_I915_LOW_LEVEL_TRACEPOINTS is not set
# CONFIG_DRM_I915_DEBUG_VBLANK_EVADE is not set
# CONFIG_DRM_I915_DEBUG_RUNTIME_PM is not set
# end of drm/i915 Debugging

#
# drm/i915 Profile Guided Optimisation
#
CONFIG_DRM_I915_FENCE_TIMEOUT=10000
CONFIG_DRM_I915_USERFAULT_AUTOSUSPEND=250
CONFIG_DRM_I915_HEARTBEAT_INTERVAL=2500
CONFIG_DRM_I915_PREEMPT_TIMEOUT=640
CONFIG_DRM_I915_MAX_REQUEST_BUSYWAIT=8000
CONFIG_DRM_I915_STOP_TIMEOUT=100
CONFIG_DRM_I915_TIMESLICE_DURATION=1
# end of drm/i915 Profile Guided Optimisation

CONFIG_DRM_VGEM=m
CONFIG_DRM_VKMS=y
CONFIG_DRM_VMWGFX=y
# CONFIG_DRM_VMWGFX_FBCON is not set
# CONFIG_DRM_GMA500 is not set
CONFIG_DRM_UDL=m
CONFIG_DRM_AST=m
CONFIG_DRM_MGAG200=m
CONFIG_DRM_RCAR_DW_HDMI=m
CONFIG_DRM_RCAR_LVDS=y
CONFIG_DRM_QXL=y
CONFIG_DRM_BOCHS=y
CONFIG_DRM_PANEL=y

#
# Display Panels
#
# CONFIG_DRM_PANEL_ARM_VERSATILE is not set
CONFIG_DRM_PANEL_ASUS_Z00T_TM5P5_NT35596=m
CONFIG_DRM_PANEL_BOE_HIMAX8279D=y
CONFIG_DRM_PANEL_BOE_TV101WUM_NL6=y
# CONFIG_DRM_PANEL_LVDS is not set
CONFIG_DRM_PANEL_SIMPLE=y
# CONFIG_DRM_PANEL_ELIDA_KD35T133 is not set
CONFIG_DRM_PANEL_FEIXIN_K101_IM2BA02=m
CONFIG_DRM_PANEL_FEIYANG_FY07024DI26A30D=y
# CONFIG_DRM_PANEL_ILITEK_ILI9881C is not set
# CONFIG_DRM_PANEL_INNOLUX_P079ZCA is not set
CONFIG_DRM_PANEL_JDI_LT070ME05000=y
CONFIG_DRM_PANEL_KINGDISPLAY_KD097D04=y
CONFIG_DRM_PANEL_LEADTEK_LTK050H3146W=y
# CONFIG_DRM_PANEL_LEADTEK_LTK500HD1829 is not set
CONFIG_DRM_PANEL_NOVATEK_NT35510=m
CONFIG_DRM_PANEL_NOVATEK_NT36672A=y
CONFIG_DRM_PANEL_MANTIX_MLAF057WE51=m
# CONFIG_DRM_PANEL_OLIMEX_LCD_OLINUXINO is not set
CONFIG_DRM_PANEL_ORISETECH_OTM8009A=m
CONFIG_DRM_PANEL_OSD_OSD101T2587_53TS=m
CONFIG_DRM_PANEL_PANASONIC_VVX10F034N00=y
# CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN is not set
# CONFIG_DRM_PANEL_RAYDIUM_RM67191 is not set
CONFIG_DRM_PANEL_RAYDIUM_RM68200=y
CONFIG_DRM_PANEL_RONBO_RB070D30=y
CONFIG_DRM_PANEL_SAMSUNG_S6D16D0=m
CONFIG_DRM_PANEL_SAMSUNG_S6E3HA2=m
CONFIG_DRM_PANEL_SAMSUNG_S6E63J0X03=y
CONFIG_DRM_PANEL_SAMSUNG_S6E63M0=y
CONFIG_DRM_PANEL_SAMSUNG_S6E63M0_DSI=m
CONFIG_DRM_PANEL_SAMSUNG_S6E88A0_AMS452EF01=m
# CONFIG_DRM_PANEL_SAMSUNG_S6E8AA0 is not set
CONFIG_DRM_PANEL_SAMSUNG_SOFEF00=m
CONFIG_DRM_PANEL_SEIKO_43WVF1G=y
CONFIG_DRM_PANEL_SHARP_LQ101R1SX01=m
# CONFIG_DRM_PANEL_SHARP_LS037V7DW01 is not set
# CONFIG_DRM_PANEL_SHARP_LS043T1LE01 is not set
CONFIG_DRM_PANEL_SITRONIX_ST7701=m
CONFIG_DRM_PANEL_SITRONIX_ST7703=y
CONFIG_DRM_PANEL_SONY_ACX424AKP=y
CONFIG_DRM_PANEL_TDO_TL070WSH30=m
# CONFIG_DRM_PANEL_TRULY_NT35597_WQXGA is not set
# CONFIG_DRM_PANEL_VISIONOX_RM69299 is not set
CONFIG_DRM_PANEL_XINPENG_XPP055C272=y
# end of Display Panels

CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
CONFIG_DRM_CDNS_DSI=y
# CONFIG_DRM_CHRONTEL_CH7033 is not set
CONFIG_DRM_DISPLAY_CONNECTOR=m
# CONFIG_DRM_LONTIUM_LT9611 is not set
# CONFIG_DRM_LONTIUM_LT9611UXC is not set
# CONFIG_DRM_LVDS_CODEC is not set
CONFIG_DRM_MEGACHIPS_STDPXXXX_GE_B850V3_FW=y
CONFIG_DRM_NWL_MIPI_DSI=m
CONFIG_DRM_NXP_PTN3460=y
CONFIG_DRM_PARADE_PS8622=m
CONFIG_DRM_PARADE_PS8640=y
# CONFIG_DRM_SIL_SII8620 is not set
CONFIG_DRM_SII902X=m
# CONFIG_DRM_SII9234 is not set
CONFIG_DRM_SIMPLE_BRIDGE=m
CONFIG_DRM_THINE_THC63LVD1024=y
CONFIG_DRM_TOSHIBA_TC358762=y
# CONFIG_DRM_TOSHIBA_TC358764 is not set
# CONFIG_DRM_TOSHIBA_TC358767 is not set
CONFIG_DRM_TOSHIBA_TC358768=m
CONFIG_DRM_TOSHIBA_TC358775=y
CONFIG_DRM_TI_TFP410=y
CONFIG_DRM_TI_SN65DSI86=m
CONFIG_DRM_TI_TPD12S015=m
CONFIG_DRM_ANALOGIX_ANX6345=y
# CONFIG_DRM_ANALOGIX_ANX78XX is not set
CONFIG_DRM_ANALOGIX_DP=y
# CONFIG_DRM_ANALOGIX_ANX7625 is not set
CONFIG_DRM_I2C_ADV7511=m
CONFIG_DRM_I2C_ADV7511_CEC=y
CONFIG_DRM_CDNS_MHDP8546=m
CONFIG_DRM_DW_HDMI=m
CONFIG_DRM_DW_HDMI_AHB_AUDIO=m
# CONFIG_DRM_DW_HDMI_CEC is not set
# end of Display Interface Bridges

# CONFIG_DRM_ETNAVIV is not set
# CONFIG_DRM_ARCPGU is not set
CONFIG_DRM_MXS=y
CONFIG_DRM_MXSFB=y
CONFIG_DRM_CIRRUS_QEMU=y
CONFIG_DRM_GM12U320=y
CONFIG_DRM_VBOXVIDEO=m
CONFIG_DRM_LEGACY=y
CONFIG_DRM_TDFX=m
CONFIG_DRM_R128=m
CONFIG_DRM_MGA=y
CONFIG_DRM_VIA=m
CONFIG_DRM_SAVAGE=m
CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y

#
# Frame buffer Devices
#
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_DDC=m
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=m
CONFIG_FB_BACKLIGHT=m
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
CONFIG_FB_PM2=m
CONFIG_FB_PM2_FIFO_DISCONNECT=y
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=m
# CONFIG_FB_ASILIANT is not set
CONFIG_FB_IMSTT=y
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_VESA is not set
CONFIG_FB_EFI=y
CONFIG_FB_N411=m
CONFIG_FB_HGA=m
CONFIG_FB_OPENCORES=m
CONFIG_FB_S1D13XXX=m
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
CONFIG_FB_I740=m
CONFIG_FB_LE80578=m
# CONFIG_FB_CARILLO_RANCH is not set
CONFIG_FB_MATROX=m
# CONFIG_FB_MATROX_MILLENIUM is not set
CONFIG_FB_MATROX_MYSTIQUE=y
# CONFIG_FB_MATROX_G is not set
# CONFIG_FB_MATROX_I2C is not set
CONFIG_FB_RADEON=m
CONFIG_FB_RADEON_I2C=y
CONFIG_FB_RADEON_BACKLIGHT=y
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=m
CONFIG_FB_ATY128_BACKLIGHT=y
CONFIG_FB_ATY=y
# CONFIG_FB_ATY_CT is not set
# CONFIG_FB_ATY_GX is not set
# CONFIG_FB_ATY_BACKLIGHT is not set
# CONFIG_FB_S3 is not set
CONFIG_FB_SAVAGE=m
CONFIG_FB_SAVAGE_I2C=y
# CONFIG_FB_SAVAGE_ACCEL is not set
CONFIG_FB_SIS=m
CONFIG_FB_SIS_300=y
# CONFIG_FB_SIS_315 is not set
CONFIG_FB_VIA=m
# CONFIG_FB_VIA_DIRECT_PROCFS is not set
# CONFIG_FB_VIA_X_COMPATIBILITY is not set
# CONFIG_FB_NEOMAGIC is not set
CONFIG_FB_KYRO=y
# CONFIG_FB_3DFX is not set
CONFIG_FB_VOODOO1=m
# CONFIG_FB_VT8623 is not set
CONFIG_FB_TRIDENT=m
# CONFIG_FB_ARK is not set
CONFIG_FB_PM3=y
CONFIG_FB_CARMINE=y
CONFIG_FB_CARMINE_DRAM_EVAL=y
# CONFIG_CARMINE_DRAM_CUSTOM is not set
CONFIG_FB_SM501=m
CONFIG_FB_SMSCUFX=y
CONFIG_FB_UDL=m
# CONFIG_FB_IBM_GXT4500 is not set
CONFIG_FB_VIRTUAL=y
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_SIMPLE is not set
CONFIG_FB_SSD1307=m
CONFIG_FB_SM712=m
# end of Frame buffer Devices

#
# Backlight & LCD device support
#
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_PLATFORM=m
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_KTD253=m
# CONFIG_BACKLIGHT_LM3533 is not set
CONFIG_BACKLIGHT_CARILLO_RANCH=m
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_DA903X=y
CONFIG_BACKLIGHT_DA9052=m
# CONFIG_BACKLIGHT_MAX8925 is not set
CONFIG_BACKLIGHT_APPLE=m
CONFIG_BACKLIGHT_QCOM_WLED=m
CONFIG_BACKLIGHT_SAHARA=y
# CONFIG_BACKLIGHT_WM831X is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=y
# CONFIG_BACKLIGHT_PCF50633 is not set
CONFIG_BACKLIGHT_LM3630A=y
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_LP855X=m
CONFIG_BACKLIGHT_LP8788=m
CONFIG_BACKLIGHT_SKY81452=y
CONFIG_BACKLIGHT_AS3711=m
CONFIG_BACKLIGHT_GPIO=y
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
# CONFIG_BACKLIGHT_ARCXCNN is not set
CONFIG_BACKLIGHT_LED=m
# end of Backlight & LCD device support

CONFIG_VGASTATE=m
CONFIG_VIDEOMODE_HELPERS=y
CONFIG_HDMI=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
# CONFIG_LOGO_LINUX_CLUT224 is not set
# end of Graphics support

CONFIG_SOUND=y
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_PCM_ELD=y
CONFIG_SND_PCM_IEC958=y
CONFIG_SND_HWDEP=y
CONFIG_SND_SEQ_DEVICE=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
# CONFIG_SND_OSSEMUL is not set
CONFIG_SND_PCM_TIMER=y
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
CONFIG_SND_VERBOSE_PRINTK=y
CONFIG_SND_DEBUG=y
# CONFIG_SND_DEBUG_VERBOSE is not set
CONFIG_SND_PCM_XRUN_DEBUG=y
CONFIG_SND_CTL_VALIDATION=y
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
CONFIG_SND_SEQ_MIDI_EVENT=y
CONFIG_SND_SEQ_MIDI=y
CONFIG_SND_SEQ_MIDI_EMUL=m
CONFIG_SND_SEQ_VIRMIDI=m
CONFIG_SND_MPU401_UART=y
CONFIG_SND_OPL3_LIB=m
CONFIG_SND_OPL3_LIB_SEQ=m
CONFIG_SND_AC97_CODEC=y
# CONFIG_SND_DRIVERS is not set
CONFIG_SND_SB_COMMON=m
CONFIG_SND_PCI=y
# CONFIG_SND_AD1889 is not set
CONFIG_SND_ALS300=m
CONFIG_SND_ALS4000=m
# CONFIG_SND_ALI5451 is not set
CONFIG_SND_ASIHPI=y
# CONFIG_SND_ATIIXP is not set
CONFIG_SND_ATIIXP_MODEM=m
CONFIG_SND_AU8810=m
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
CONFIG_SND_AW2=m
# CONFIG_SND_AZT3328 is not set
CONFIG_SND_BT87X=m
# CONFIG_SND_BT87X_OVERCLOCK is not set
# CONFIG_SND_CA0106 is not set
CONFIG_SND_CMIPCI=m
CONFIG_SND_OXYGEN_LIB=m
CONFIG_SND_OXYGEN=m
CONFIG_SND_CS4281=m
# CONFIG_SND_CS46XX is not set
CONFIG_SND_CTXFI=m
# CONFIG_SND_DARLA20 is not set
CONFIG_SND_GINA20=m
CONFIG_SND_LAYLA20=y
CONFIG_SND_DARLA24=m
CONFIG_SND_GINA24=m
CONFIG_SND_LAYLA24=y
CONFIG_SND_MONA=y
CONFIG_SND_MIA=y
CONFIG_SND_ECHO3G=m
CONFIG_SND_INDIGO=m
CONFIG_SND_INDIGOIO=y
CONFIG_SND_INDIGODJ=m
# CONFIG_SND_INDIGOIOX is not set
CONFIG_SND_INDIGODJX=y
CONFIG_SND_EMU10K1=m
CONFIG_SND_EMU10K1_SEQ=m
CONFIG_SND_EMU10K1X=m
CONFIG_SND_ENS1370=m
CONFIG_SND_ENS1371=m
# CONFIG_SND_ES1938 is not set
CONFIG_SND_ES1968=m
# CONFIG_SND_ES1968_INPUT is not set
CONFIG_SND_FM801=m
CONFIG_SND_HDSP=m
CONFIG_SND_HDSPM=y
CONFIG_SND_ICE1712=m
CONFIG_SND_ICE1724=m
CONFIG_SND_INTEL8X0=m
CONFIG_SND_INTEL8X0M=y
CONFIG_SND_KORG1212=m
CONFIG_SND_LOLA=y
CONFIG_SND_LX6464ES=m
CONFIG_SND_MAESTRO3=m
# CONFIG_SND_MAESTRO3_INPUT is not set
CONFIG_SND_MIXART=m
CONFIG_SND_NM256=y
CONFIG_SND_PCXHR=m
CONFIG_SND_RIPTIDE=m
CONFIG_SND_RME32=m
CONFIG_SND_RME96=y
CONFIG_SND_RME9652=y
# CONFIG_SND_SONICVIBES is not set
CONFIG_SND_TRIDENT=y
CONFIG_SND_VIA82XX=y
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
CONFIG_SND_YMFPCI=m

#
# HD-Audio
#
CONFIG_SND_HDA=y
CONFIG_SND_HDA_GENERIC_LEDS=y
CONFIG_SND_HDA_INTEL=y
# CONFIG_SND_HDA_HWDEP is not set
CONFIG_SND_HDA_RECONFIG=y
# CONFIG_SND_HDA_INPUT_BEEP is not set
CONFIG_SND_HDA_PATCH_LOADER=y
# CONFIG_SND_HDA_CODEC_REALTEK is not set
CONFIG_SND_HDA_CODEC_ANALOG=y
CONFIG_SND_HDA_CODEC_SIGMATEL=m

#
# Set to Y if you want auto-loading the codec driver
#
# CONFIG_SND_HDA_CODEC_VIA is not set
CONFIG_SND_HDA_CODEC_HDMI=y
CONFIG_SND_HDA_CODEC_CIRRUS=y
# CONFIG_SND_HDA_CODEC_CONEXANT is not set
CONFIG_SND_HDA_CODEC_CA0110=y
CONFIG_SND_HDA_CODEC_CA0132=y
# CONFIG_SND_HDA_CODEC_CA0132_DSP is not set
CONFIG_SND_HDA_CODEC_CMEDIA=m

#
# Set to Y if you want auto-loading the codec driver
#
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDA_INTEL_HDMI_SILENT_STREAM=y
# end of HD-Audio

CONFIG_SND_HDA_CORE=y
CONFIG_SND_HDA_COMPONENT=y
CONFIG_SND_HDA_I915=y
CONFIG_SND_HDA_PREALLOC_SIZE=2048
CONFIG_SND_INTEL_NHLT=y
CONFIG_SND_INTEL_DSP_CONFIG=y
# CONFIG_SND_USB is not set
CONFIG_SND_PCMCIA=y
# CONFIG_SND_VXPOCKET is not set
CONFIG_SND_PDAUDIOCF=m
# CONFIG_SND_SOC is not set
CONFIG_SND_X86=y
CONFIG_HDMI_LPE_AUDIO=m
CONFIG_SND_SYNTH_EMUX=m
CONFIG_AC97_BUS=y

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
CONFIG_UHID=m
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACCUTOUCH is not set
CONFIG_HID_ACRUX=y
CONFIG_HID_ACRUX_FF=y
CONFIG_HID_APPLE=y
# CONFIG_HID_APPLEIR is not set
# CONFIG_HID_ASUS is not set
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=m
CONFIG_HID_BETOP_FF=m
CONFIG_HID_BIGBEN_FF=m
CONFIG_HID_CHERRY=m
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_CORSAIR is not set
CONFIG_HID_COUGAR=m
CONFIG_HID_MACALLY=y
# CONFIG_HID_PRODIKEYS is not set
CONFIG_HID_CMEDIA=y
CONFIG_HID_CREATIVE_SB0540=m
# CONFIG_HID_CYPRESS is not set
CONFIG_HID_DRAGONRISE=m
# CONFIG_DRAGONRISE_FF is not set
CONFIG_HID_EMS_FF=m
CONFIG_HID_ELAN=m
CONFIG_HID_ELECOM=y
CONFIG_HID_ELO=m
CONFIG_HID_EZKEY=y
CONFIG_HID_GEMBIRD=m
CONFIG_HID_GFRM=m
# CONFIG_HID_GLORIOUS is not set
CONFIG_HID_HOLTEK=m
# CONFIG_HOLTEK_FF is not set
CONFIG_HID_VIVALDI=m
CONFIG_HID_GT683R=m
CONFIG_HID_KEYTOUCH=m
CONFIG_HID_KYE=y
CONFIG_HID_UCLOGIC=m
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_VIEWSONIC is not set
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
CONFIG_HID_ITE=m
# CONFIG_HID_JABRA is not set
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=m
CONFIG_HID_LCPOWER=y
CONFIG_HID_LED=y
CONFIG_HID_LENOVO=m
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MALTRON is not set
CONFIG_HID_MAYFLASH=y
# CONFIG_HID_REDRAGON is not set
CONFIG_HID_MICROSOFT=m
CONFIG_HID_MONTEREY=m
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_NTI is not set
CONFIG_HID_NTRIG=m
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
CONFIG_HID_PENMOUNT=m
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=m
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
# CONFIG_HID_PLANTRONICS is not set
CONFIG_HID_PRIMAX=m
CONFIG_HID_RETRODE=m
# CONFIG_HID_ROCCAT is not set
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SONY=m
CONFIG_SONY_FF=y
CONFIG_HID_SPEEDLINK=m
CONFIG_HID_STEAM=m
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_RMI=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
# CONFIG_HID_SMARTJOYPLUS is not set
CONFIG_HID_TIVO=m
CONFIG_HID_TOPSEED=m
CONFIG_HID_THINGM=y
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_UDRAW_PS3 is not set
CONFIG_HID_U2FZERO=m
# CONFIG_HID_WACOM is not set
CONFIG_HID_WIIMOTE=m
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
# CONFIG_HID_ZYDACRON is not set
CONFIG_HID_SENSOR_HUB=m
# CONFIG_HID_SENSOR_CUSTOM_SENSOR is not set
CONFIG_HID_ALPS=m
# CONFIG_HID_MCP2221 is not set
# end of Special HID drivers

#
# USB HID support
#
CONFIG_USB_HID=m
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# USB HID Boot Protocol drivers
#
# CONFIG_USB_KBD is not set
# CONFIG_USB_MOUSE is not set
# end of USB HID Boot Protocol drivers
# end of USB HID support

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
# end of I2C HID support

#
# Intel ISH HID support
#
CONFIG_INTEL_ISH_HID=y
CONFIG_INTEL_ISH_FIRMWARE_DOWNLOADER=m
# end of Intel ISH HID support

#
# AMD SFH HID Support
#
CONFIG_AMD_SFH_HID=y
# end of AMD SFH HID Support
# end of HID support

CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
# CONFIG_USB_LED_TRIG is not set
CONFIG_USB_ULPI_BUS=m
CONFIG_USB_CONN_GPIO=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_PCI=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
CONFIG_USB_FEW_INIT_RETRIES=y
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_OTG=y
CONFIG_USB_OTG_PRODUCTLIST=y
# CONFIG_USB_OTG_DISABLE_EXTERNAL_HUB is not set
CONFIG_USB_OTG_FSM=y
# CONFIG_USB_LEDS_TRIGGER_USBPORT is not set
CONFIG_USB_AUTOSUSPEND_DELAY=2
CONFIG_USB_MON=m

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=m
# CONFIG_USB_XHCI_DBGCAP is not set
CONFIG_USB_XHCI_PCI=m
CONFIG_USB_XHCI_PCI_RENESAS=m
CONFIG_USB_XHCI_PLATFORM=m
CONFIG_USB_EHCI_HCD=m
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=m
# CONFIG_USB_EHCI_FSL is not set
CONFIG_USB_EHCI_HCD_PLATFORM=m
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_FOTG210_HCD=y
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=m
CONFIG_USB_OHCI_HCD_SSB=y
CONFIG_USB_OHCI_HCD_PLATFORM=y
CONFIG_USB_UHCI_HCD=y
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
CONFIG_USB_SL811_HCD_ISO=y
CONFIG_USB_SL811_CS=m
CONFIG_USB_R8A66597_HCD=y
CONFIG_USB_HCD_BCMA=m
CONFIG_USB_HCD_SSB=y
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=m
CONFIG_USB_WDM=y
CONFIG_USB_TMC=m

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=m
CONFIG_USB_STORAGE_DEBUG=y
# CONFIG_USB_STORAGE_REALTEK is not set
# CONFIG_USB_STORAGE_DATAFAB is not set
CONFIG_USB_STORAGE_FREECOM=m
CONFIG_USB_STORAGE_ISD200=m
CONFIG_USB_STORAGE_USBAT=m
CONFIG_USB_STORAGE_SDDR09=m
CONFIG_USB_STORAGE_SDDR55=m
CONFIG_USB_STORAGE_JUMPSHOT=m
# CONFIG_USB_STORAGE_ALAUDA is not set
# CONFIG_USB_STORAGE_ONETOUCH is not set
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
CONFIG_USB_STORAGE_ENE_UB6250=m
CONFIG_USB_UAS=m

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
CONFIG_USB_MICROTEK=y
# CONFIG_USBIP_CORE is not set
CONFIG_USB_CDNS3=y
# CONFIG_USB_CDNS3_HOST is not set
CONFIG_USB_CDNS3_PCI_WRAP=m
CONFIG_USB_MUSB_HDRC=m
CONFIG_USB_MUSB_HOST=y

#
# Platform Glue Layer
#

#
# MUSB DMA mode
#
# CONFIG_MUSB_PIO_ONLY is not set
# CONFIG_USB_DWC3 is not set
# CONFIG_USB_DWC2 is not set
# CONFIG_USB_CHIPIDEA is not set
# CONFIG_USB_ISP1760 is not set

#
# USB port drivers
#
CONFIG_USB_USS720=m
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=m
CONFIG_USB_ADUTUX=y
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_LEGOTOWER is not set
CONFIG_USB_LCD=y
# CONFIG_USB_CYPRESS_CY7C63 is not set
CONFIG_USB_CYTHERM=m
# CONFIG_USB_IDMOUSE is not set
CONFIG_USB_FTDI_ELAN=y
# CONFIG_USB_APPLEDISPLAY is not set
CONFIG_APPLE_MFI_FASTCHARGE=m
CONFIG_USB_SISUSBVGA=m
# CONFIG_USB_LD is not set
CONFIG_USB_TRANCEVIBRATOR=m
CONFIG_USB_IOWARRIOR=m
# CONFIG_USB_TEST is not set
CONFIG_USB_EHSET_TEST_FIXTURE=y
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=m
# CONFIG_USB_EZUSB_FX2 is not set
# CONFIG_USB_HUB_USB251XB is not set
CONFIG_USB_HSIC_USB3503=m
# CONFIG_USB_HSIC_USB4604 is not set
CONFIG_USB_LINK_LAYER_TEST=y
CONFIG_USB_CHAOSKEY=y

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=m
CONFIG_USB_GPIO_VBUS=m
# CONFIG_USB_ISP1301 is not set
# end of USB Physical Layer drivers

# CONFIG_USB_GADGET is not set
# CONFIG_TYPEC is not set
CONFIG_USB_ROLE_SWITCH=y
# CONFIG_USB_ROLES_INTEL_XHCI is not set
# CONFIG_MMC is not set
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=m
CONFIG_MS_BLOCK=m

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=m
# CONFIG_MEMSTICK_JMICRON_38X is not set
CONFIG_MEMSTICK_R592=m
CONFIG_MEMSTICK_REALTEK_PCI=m
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set
# CONFIG_LEDS_CLASS_MULTICOLOR is not set
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
CONFIG_LEDS_AN30259A=y
CONFIG_LEDS_APU=m
CONFIG_LEDS_AW2013=m
CONFIG_LEDS_BCM6328=m
CONFIG_LEDS_BCM6358=y
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3532=y
CONFIG_LEDS_LM3533=m
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_LM3692X is not set
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=m
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP3952=y
# CONFIG_LEDS_LP50XX is not set
# CONFIG_LEDS_LP55XX_COMMON is not set
CONFIG_LEDS_LP8788=y
CONFIG_LEDS_LP8860=y
CONFIG_LEDS_CLEVO_MAIL=m
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA955X_GPIO is not set
CONFIG_LEDS_PCA963X=m
# CONFIG_LEDS_WM831X_STATUS is not set
# CONFIG_LEDS_DA903X is not set
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_PWM=y
# CONFIG_LEDS_REGULATOR is not set
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_INTEL_SS4200=y
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_MC13783 is not set
# CONFIG_LEDS_TCA6507 is not set
CONFIG_LEDS_TLC591XX=m
CONFIG_LEDS_MAX77650=m
# CONFIG_LEDS_MAX8997 is not set
# CONFIG_LEDS_LM355x is not set
CONFIG_LEDS_MENF21BMC=y
CONFIG_LEDS_IS31FL319X=y
# CONFIG_LEDS_IS31FL32XX is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
CONFIG_LEDS_SYSCON=y
CONFIG_LEDS_MLXCPLD=y
CONFIG_LEDS_MLXREG=m
CONFIG_LEDS_USER=m
# CONFIG_LEDS_NIC78BX is not set
CONFIG_LEDS_TI_LMU_COMMON=m
# CONFIG_LEDS_LM3697 is not set
CONFIG_LEDS_LM36274=m
CONFIG_LEDS_TPS6105X=m

#
# Flash and Torch LED drivers
#

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=m
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_DISK=y
CONFIG_LEDS_TRIGGER_MTD=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
CONFIG_LEDS_TRIGGER_ACTIVITY=y
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_LEDS_TRIGGER_CAMERA=m
# CONFIG_LEDS_TRIGGER_PANIC is not set
# CONFIG_LEDS_TRIGGER_NETDEV is not set
CONFIG_LEDS_TRIGGER_PATTERN=y
CONFIG_LEDS_TRIGGER_AUDIO=y
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
# CONFIG_RTC_SYSTOHC is not set
# CONFIG_RTC_DEBUG is not set
# CONFIG_RTC_NVMEM is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
# CONFIG_RTC_INTF_PROC is not set
# CONFIG_RTC_INTF_DEV is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM80X=m
CONFIG_RTC_DRV_ABB5ZES3=y
CONFIG_RTC_DRV_ABEOZ9=m
CONFIG_RTC_DRV_ABX80X=y
CONFIG_RTC_DRV_AS3722=m
CONFIG_RTC_DRV_DS1307=m
# CONFIG_RTC_DRV_DS1307_CENTURY is not set
CONFIG_RTC_DRV_DS1374=y
# CONFIG_RTC_DRV_DS1672 is not set
CONFIG_RTC_DRV_HYM8563=m
CONFIG_RTC_DRV_LP8788=m
CONFIG_RTC_DRV_MAX6900=m
# CONFIG_RTC_DRV_MAX8925 is not set
CONFIG_RTC_DRV_MAX8998=y
# CONFIG_RTC_DRV_MAX8997 is not set
CONFIG_RTC_DRV_MAX77686=m
# CONFIG_RTC_DRV_RK808 is not set
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
CONFIG_RTC_DRV_ISL12022=y
# CONFIG_RTC_DRV_ISL12026 is not set
# CONFIG_RTC_DRV_X1205 is not set
CONFIG_RTC_DRV_PCF8523=m
CONFIG_RTC_DRV_PCF85063=y
CONFIG_RTC_DRV_PCF85363=y
CONFIG_RTC_DRV_PCF8563=m
CONFIG_RTC_DRV_PCF8583=m
CONFIG_RTC_DRV_M41T80=y
# CONFIG_RTC_DRV_M41T80_WDT is not set
# CONFIG_RTC_DRV_BQ32K is not set
CONFIG_RTC_DRV_TPS6586X=m
CONFIG_RTC_DRV_TPS65910=m
# CONFIG_RTC_DRV_TPS80031 is not set
# CONFIG_RTC_DRV_RC5T583 is not set
# CONFIG_RTC_DRV_RC5T619 is not set
# CONFIG_RTC_DRV_S35390A is not set
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8010=y
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=m
CONFIG_RTC_DRV_EM3027=m
CONFIG_RTC_DRV_RV3028=y
CONFIG_RTC_DRV_RV3032=m
CONFIG_RTC_DRV_RV8803=m
CONFIG_RTC_DRV_S5M=y
# CONFIG_RTC_DRV_SD3078 is not set

#
# SPI RTC drivers
#
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=m
CONFIG_RTC_DRV_DS3232_HWMON=y
# CONFIG_RTC_DRV_PCF2127 is not set
CONFIG_RTC_DRV_RV3029C2=y
# CONFIG_RTC_DRV_RV3029_HWMON is not set
CONFIG_RTC_DRV_RX6110=y

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
# CONFIG_RTC_DRV_DS1511 is not set
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1685_FAMILY=m
# CONFIG_RTC_DRV_DS1685 is not set
# CONFIG_RTC_DRV_DS1689 is not set
# CONFIG_RTC_DRV_DS17285 is not set
CONFIG_RTC_DRV_DS17485=y
# CONFIG_RTC_DRV_DS17885 is not set
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_DS2404=y
CONFIG_RTC_DRV_DA9052=m
# CONFIG_RTC_DRV_DA9063 is not set
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=m
# CONFIG_RTC_DRV_M48T35 is not set
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=m
CONFIG_RTC_DRV_WM831X=y
CONFIG_RTC_DRV_PCF50633=m
CONFIG_RTC_DRV_AB3100=y
# CONFIG_RTC_DRV_ZYNQMP is not set

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_CADENCE=y
CONFIG_RTC_DRV_FTRTC010=m
CONFIG_RTC_DRV_MC13XXX=m
# CONFIG_RTC_DRV_R7301 is not set

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_GOLDFISH is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_DMA_OF=y
CONFIG_ALTERA_MSGDMA=m
# CONFIG_DW_AXI_DMAC is not set
# CONFIG_FSL_EDMA is not set
CONFIG_INTEL_IDMA64=m
CONFIG_INTEL_IDXD=y
# CONFIG_INTEL_IOATDMA is not set
# CONFIG_PLX_DMA is not set
CONFIG_XILINX_ZYNQMP_DPDMA=m
# CONFIG_QCOM_HIDMA_MGMT is not set
CONFIG_QCOM_HIDMA=m
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
CONFIG_DW_DMAC_PCI=m
CONFIG_DW_EDMA=m
# CONFIG_DW_EDMA_PCIE is not set
CONFIG_HSU_DMA=y
CONFIG_SF_PDMA=m

#
# DMA Clients
#
# CONFIG_ASYNC_TX_DMA is not set
CONFIG_DMATEST=m
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_SW_SYNC=y
CONFIG_UDMABUF=y
# CONFIG_DMABUF_MOVE_NOTIFY is not set
# CONFIG_DMABUF_SELFTESTS is not set
CONFIG_DMABUF_HEAPS=y
# CONFIG_DMABUF_HEAPS_SYSTEM is not set
CONFIG_DMABUF_HEAPS_CMA=y
# end of DMABUF options

# CONFIG_AUXDISPLAY is not set
# CONFIG_PANEL is not set
CONFIG_UIO=m
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV_GENIRQ=m
CONFIG_UIO_DMEM_GENIRQ=m
CONFIG_UIO_AEC=m
CONFIG_UIO_SERCOS3=m
CONFIG_UIO_PCI_GENERIC=m
CONFIG_UIO_NETX=m
CONFIG_UIO_PRUSS=m
CONFIG_UIO_MF624=m
# CONFIG_VFIO is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VBOXGUEST=m
CONFIG_VIRTIO=y
# CONFIG_VIRTIO_MENU is not set
CONFIG_VDPA=y
CONFIG_VDPA_SIM=m
CONFIG_VDPA_SIM_NET=m
CONFIG_IFCVF=m
CONFIG_VHOST_IOTLB=m
CONFIG_VHOST_RING=m
# CONFIG_VHOST_MENU is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# end of Microsoft Hyper-V guest support

# CONFIG_GREYBUS is not set
CONFIG_STAGING=y
CONFIG_COMEDI=y
# CONFIG_COMEDI_DEBUG is not set
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=20480
CONFIG_COMEDI_MISC_DRIVERS=y
CONFIG_COMEDI_BOND=y
CONFIG_COMEDI_TEST=y
CONFIG_COMEDI_PARPORT=y
# CONFIG_COMEDI_ISA_DRIVERS is not set
# CONFIG_COMEDI_PCI_DRIVERS is not set
CONFIG_COMEDI_PCMCIA_DRIVERS=m
# CONFIG_COMEDI_CB_DAS16_CS is not set
# CONFIG_COMEDI_DAS08_CS is not set
CONFIG_COMEDI_NI_DAQ_700_CS=m
CONFIG_COMEDI_NI_DAQ_DIO24_CS=m
CONFIG_COMEDI_NI_LABPC_CS=m
# CONFIG_COMEDI_NI_MIO_CS is not set
# CONFIG_COMEDI_QUATECH_DAQP_CS is not set
CONFIG_COMEDI_USB_DRIVERS=m
# CONFIG_COMEDI_DT9812 is not set
# CONFIG_COMEDI_NI_USB6501 is not set
CONFIG_COMEDI_USBDUX=m
# CONFIG_COMEDI_USBDUXFAST is not set
CONFIG_COMEDI_USBDUXSIGMA=m
# CONFIG_COMEDI_VMK80XX is not set
CONFIG_COMEDI_8254=m
CONFIG_COMEDI_8255=y
CONFIG_COMEDI_8255_SA=y
CONFIG_COMEDI_KCOMEDILIB=y
CONFIG_COMEDI_NI_LABPC=m
# CONFIG_RTL8192U is not set
# CONFIG_RTLLIB is not set
# CONFIG_RTS5208 is not set
CONFIG_FB_SM750=m
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# end of Android

CONFIG_STAGING_BOARD=y
# CONFIG_LTE_GDM724X is not set
CONFIG_GS_FPGABOOT=m
# CONFIG_UNISYSSPAR is not set

#
# Gasket devices
#
CONFIG_STAGING_GASKET_FRAMEWORK=m
# CONFIG_STAGING_APEX_DRIVER is not set
# end of Gasket devices

CONFIG_XIL_AXIS_FIFO=y
CONFIG_FIELDBUS_DEV=y
# CONFIG_HMS_ANYBUSS_BUS is not set
# CONFIG_KPC2000 is not set
# CONFIG_QLGE is not set
# CONFIG_WIMAX is not set
CONFIG_SPMI_HISI3670=y
CONFIG_MFD_HI6421_SPMI=m
CONFIG_REGULATOR_HI6421V600=m
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACPI_WMI=y
CONFIG_WMI_BMOF=y
# CONFIG_ALIENWARE_WMI is not set
CONFIG_INTEL_WMI_SBL_FW_UPDATE=y
CONFIG_INTEL_WMI_THUNDERBOLT=m
CONFIG_MXM_WMI=y
CONFIG_PEAQ_WMI=y
CONFIG_XIAOMI_WMI=y
# CONFIG_ACERHDF is not set
CONFIG_ACER_WIRELESS=m
CONFIG_ACER_WMI=m
# CONFIG_AMD_PMC is not set
CONFIG_APPLE_GMUX=m
# CONFIG_ASUS_LAPTOP is not set
CONFIG_ASUS_WIRELESS=m
# CONFIG_DCDBAS is not set
CONFIG_DELL_SMBIOS=m
# CONFIG_DELL_SMBIOS_WMI is not set
CONFIG_DELL_LAPTOP=m
CONFIG_DELL_RBU=m
CONFIG_DELL_SMO8800=y
# CONFIG_DELL_WMI is not set
# CONFIG_DELL_WMI_SYSMAN is not set
CONFIG_DELL_WMI_AIO=y
CONFIG_DELL_WMI_LED=m
# CONFIG_FUJITSU_LAPTOP is not set
CONFIG_FUJITSU_TABLET=m
CONFIG_GPD_POCKET_FAN=y
# CONFIG_HP_ACCEL is not set
CONFIG_HP_WIRELESS=y
CONFIG_HP_WMI=y
# CONFIG_IBM_RTL is not set
CONFIG_SENSORS_HDAPS=y
CONFIG_INTEL_ATOMISP2_LED=m
# CONFIG_INTEL_ATOMISP2_PM is not set
CONFIG_INTEL_HID_EVENT=y
# CONFIG_INTEL_INT0002_VGPIO is not set
# CONFIG_INTEL_MENLOW is not set
CONFIG_INTEL_VBTN=y
CONFIG_MSI_WMI=y
# CONFIG_PCENGINES_APU2 is not set
CONFIG_SAMSUNG_LAPTOP=m
CONFIG_SAMSUNG_Q10=m
CONFIG_TOSHIBA_BT_RFKILL=y
CONFIG_TOSHIBA_HAPS=y
CONFIG_TOSHIBA_WMI=m
# CONFIG_ACPI_CMPC is not set
CONFIG_LG_LAPTOP=y
# CONFIG_PANASONIC_LAPTOP is not set
CONFIG_SYSTEM76_ACPI=m
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_I2C_MULTI_INSTANTIATE is not set
# CONFIG_MLX_PLATFORM is not set
# CONFIG_TOUCHSCREEN_DMI is not set
# CONFIG_INTEL_IPS is not set
CONFIG_INTEL_RST=y
# CONFIG_INTEL_SMARTCONNECT is not set

#
# Intel Speed Select Technology interface support
#
CONFIG_INTEL_SPEED_SELECT_INTERFACE=y
# end of Intel Speed Select Technology interface support

# CONFIG_INTEL_UNCORE_FREQ_CONTROL is not set
CONFIG_INTEL_BXTWC_PMIC_TMU=m
CONFIG_INTEL_MID_POWER_BUTTON=m
# CONFIG_INTEL_PMC_CORE is not set
CONFIG_INTEL_PMT_CLASS=y
CONFIG_INTEL_PMT_TELEMETRY=y
# CONFIG_INTEL_PMT_CRASHLOG is not set
CONFIG_INTEL_PUNIT_IPC=m
CONFIG_INTEL_SCU_IPC=y
CONFIG_INTEL_SCU=y
CONFIG_INTEL_SCU_PCI=y
CONFIG_INTEL_SCU_PLATFORM=y
# CONFIG_INTEL_SCU_IPC_UTIL is not set
# CONFIG_INTEL_TELEMETRY is not set
CONFIG_PMC_ATOM=y
# CONFIG_CHROME_PLATFORMS is not set
# CONFIG_MELLANOX_PLATFORM is not set
# CONFIG_SURFACE_PLATFORMS is not set
CONFIG_HAVE_CLK=y
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y
CONFIG_COMMON_CLK_WM831X=m
# CONFIG_COMMON_CLK_MAX77686 is not set
CONFIG_COMMON_CLK_MAX9485=m
CONFIG_COMMON_CLK_RK808=m
CONFIG_COMMON_CLK_SI5341=m
CONFIG_COMMON_CLK_SI5351=m
CONFIG_COMMON_CLK_SI514=y
CONFIG_COMMON_CLK_SI544=y
CONFIG_COMMON_CLK_SI570=y
CONFIG_COMMON_CLK_CDCE706=y
# CONFIG_COMMON_CLK_CDCE925 is not set
CONFIG_COMMON_CLK_CS2000_CP=y
# CONFIG_COMMON_CLK_S2MPS11 is not set
CONFIG_COMMON_CLK_PWM=m
CONFIG_COMMON_CLK_VC5=m
CONFIG_COMMON_CLK_BD718XX=y
# CONFIG_COMMON_CLK_FIXED_MMIO is not set
CONFIG_CLK_LGM_CGU=y
CONFIG_HWSPINLOCK=y

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MICROCHIP_PIT64B is not set
# end of Clock Source drivers

CONFIG_MAILBOX=y
CONFIG_PLATFORM_MHU=y
# CONFIG_PCC is not set
CONFIG_ALTERA_MBOX=m
CONFIG_MAILBOX_TEST=m
CONFIG_IOMMU_IOVA=y
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
# end of Generic IOMMU Pagetable Support

CONFIG_IOMMU_DEBUGFS=y
CONFIG_IOMMU_DEFAULT_PASSTHROUGH=y
CONFIG_OF_IOMMU=y
CONFIG_IOMMU_DMA=y
CONFIG_AMD_IOMMU=y
# CONFIG_AMD_IOMMU_V2 is not set
CONFIG_AMD_IOMMU_DEBUGFS=y
CONFIG_DMAR_TABLE=y
# CONFIG_INTEL_IOMMU is not set
CONFIG_IRQ_REMAP=y

#
# Remoteproc drivers
#
# CONFIG_REMOTEPROC is not set
# end of Remoteproc drivers

#
# Rpmsg drivers
#
CONFIG_RPMSG=m
# CONFIG_RPMSG_CHAR is not set
# CONFIG_RPMSG_NS is not set
CONFIG_RPMSG_QCOM_GLINK=m
CONFIG_RPMSG_QCOM_GLINK_RPM=m
# CONFIG_RPMSG_VIRTIO is not set
# end of Rpmsg drivers

CONFIG_SOUNDWIRE=m

#
# SoundWire Devices
#

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#
# end of Amlogic SoC drivers

#
# Broadcom SoC drivers
#
# end of Broadcom SoC drivers

#
# NXP/Freescale QorIQ SoC drivers
#
# end of NXP/Freescale QorIQ SoC drivers

#
# i.MX SoC drivers
#
# end of i.MX SoC drivers

#
# Enable LiteX SoC Builder specific drivers
#
# CONFIG_LITEX_SOC_CONTROLLER is not set
# end of Enable LiteX SoC Builder specific drivers

#
# Qualcomm SoC drivers
#
# end of Qualcomm SoC drivers

CONFIG_SOC_TI=y

#
# Xilinx SoC drivers
#
CONFIG_XILINX_VCU=y
# end of Xilinx SoC drivers
# end of SOC (System On Chip) specific Drivers

CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
CONFIG_DEVFREQ_GOV_USERSPACE=m
CONFIG_DEVFREQ_GOV_PASSIVE=y

#
# DEVFREQ Drivers
#
CONFIG_PM_DEVFREQ_EVENT=y
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_AXP288 is not set
# CONFIG_EXTCON_FSA9480 is not set
# CONFIG_EXTCON_GPIO is not set
CONFIG_EXTCON_INTEL_INT3496=y
# CONFIG_EXTCON_MAX3355 is not set
CONFIG_EXTCON_MAX77693=y
CONFIG_EXTCON_MAX77843=m
CONFIG_EXTCON_MAX8997=y
# CONFIG_EXTCON_PTN5150 is not set
# CONFIG_EXTCON_RT8973A is not set
CONFIG_EXTCON_SM5502=m
CONFIG_EXTCON_USB_GPIO=y
CONFIG_EXTCON_USBC_TUSB320=y
CONFIG_MEMORY=y
# CONFIG_IIO is not set
CONFIG_NTB=y
# CONFIG_NTB_MSI is not set
# CONFIG_NTB_AMD is not set
CONFIG_NTB_IDT=y
CONFIG_NTB_INTEL=y
# CONFIG_NTB_SWITCHTEC is not set
CONFIG_NTB_PINGPONG=m
CONFIG_NTB_TOOL=m
CONFIG_NTB_PERF=y
CONFIG_NTB_TRANSPORT=y
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_DEBUG is not set
CONFIG_PWM_ATMEL_HLCDC_PWM=m
CONFIG_PWM_ATMEL_TCB=m
CONFIG_PWM_DWC=m
# CONFIG_PWM_FSL_FTM is not set
# CONFIG_PWM_INTEL_LGM is not set
# CONFIG_PWM_IQS620A is not set
CONFIG_PWM_LPSS=y
CONFIG_PWM_LPSS_PCI=m
CONFIG_PWM_LPSS_PLATFORM=y
CONFIG_PWM_PCA9685=m
CONFIG_PWM_STMPE=y

#
# IRQ chip support
#
CONFIG_IRQCHIP=y
# CONFIG_AL_FIC is not set
CONFIG_MADERA_IRQ=m
# end of IRQ chip support

CONFIG_IPACK_BUS=y
CONFIG_BOARD_TPCI200=y
CONFIG_SERIAL_IPOCTAL=y
CONFIG_RESET_CONTROLLER=y
CONFIG_RESET_BRCMSTB_RESCAL=y
CONFIG_RESET_INTEL_GW=y
CONFIG_RESET_TI_SYSCON=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_GENERIC_PHY_MIPI_DPHY=y
CONFIG_USB_LGM_PHY=y
CONFIG_BCM_KONA_USB2_PHY=m
# CONFIG_PHY_CADENCE_TORRENT is not set
CONFIG_PHY_CADENCE_DPHY=m
# CONFIG_PHY_CADENCE_SIERRA is not set
CONFIG_PHY_CADENCE_SALVO=y
CONFIG_PHY_FSL_IMX8MQ_USB=y
CONFIG_PHY_MIXEL_MIPI_DPHY=m
CONFIG_PHY_PXA_28NM_HSIC=y
CONFIG_PHY_PXA_28NM_USB2=m
CONFIG_PHY_MAPPHONE_MDM6600=y
CONFIG_PHY_OCELOT_SERDES=m
# CONFIG_PHY_QCOM_USB_HS is not set
CONFIG_PHY_QCOM_USB_HSIC=m
# CONFIG_PHY_TUSB1210 is not set
CONFIG_PHY_INTEL_LGM_COMBO=y
# CONFIG_PHY_INTEL_LGM_EMMC is not set
# end of PHY Subsystem

CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL_CORE=m
CONFIG_INTEL_RAPL=m
CONFIG_IDLE_INJECT=y
CONFIG_MCB=m
CONFIG_MCB_PCI=m
CONFIG_MCB_LPC=m

#
# Performance monitor support
#
# end of Performance monitor support

CONFIG_RAS=y
CONFIG_RAS_CEC=y
# CONFIG_RAS_CEC_DEBUG is not set
CONFIG_USB4=m
# CONFIG_USB4_DEBUGFS_WRITE is not set
CONFIG_USB4_DMA_TEST=m

#
# Android
#
# CONFIG_ANDROID is not set
# end of Android

# CONFIG_LIBNVDIMM is not set
CONFIG_DAX=y
CONFIG_NVMEM=y
CONFIG_NVMEM_SYSFS=y
CONFIG_NVMEM_SPMI_SDAM=m

#
# HW tracing support
#
CONFIG_STM=y
CONFIG_STM_PROTO_BASIC=y
# CONFIG_STM_PROTO_SYS_T is not set
CONFIG_STM_DUMMY=m
# CONFIG_STM_SOURCE_CONSOLE is not set
# CONFIG_STM_SOURCE_HEARTBEAT is not set
# CONFIG_STM_SOURCE_FTRACE is not set
CONFIG_INTEL_TH=m
CONFIG_INTEL_TH_PCI=m
# CONFIG_INTEL_TH_ACPI is not set
# CONFIG_INTEL_TH_GTH is not set
CONFIG_INTEL_TH_STH=m
CONFIG_INTEL_TH_MSU=m
CONFIG_INTEL_TH_PTI=m
# CONFIG_INTEL_TH_DEBUG is not set
# end of HW tracing support

CONFIG_FPGA=y
CONFIG_ALTERA_PR_IP_CORE=y
# CONFIG_ALTERA_PR_IP_CORE_PLAT is not set
CONFIG_FPGA_MGR_ALTERA_CVP=y
# CONFIG_FPGA_BRIDGE is not set
# CONFIG_FPGA_DFL is not set
CONFIG_FSI=m
CONFIG_FSI_NEW_DEV_NODE=y
# CONFIG_FSI_MASTER_GPIO is not set
CONFIG_FSI_MASTER_HUB=m
CONFIG_FSI_MASTER_ASPEED=m
CONFIG_FSI_SCOM=m
CONFIG_FSI_SBEFIFO=m
CONFIG_FSI_OCC=m
CONFIG_TEE=y

#
# TEE drivers
#
# end of TEE drivers

CONFIG_MULTIPLEXER=m

#
# Multiplexer drivers
#
# CONFIG_MUX_ADG792A is not set
CONFIG_MUX_GPIO=m
CONFIG_MUX_MMIO=m
# end of Multiplexer drivers

CONFIG_PM_OPP=y
CONFIG_UNISYS_VISORBUS=y
CONFIG_SIOX=y
# CONFIG_SIOX_BUS_GPIO is not set
CONFIG_SLIMBUS=m
CONFIG_SLIM_QCOM_CTRL=m
CONFIG_INTERCONNECT=y
# CONFIG_COUNTER is not set
# CONFIG_MOST is not set
# end of Device Drivers

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_VALIDATE_FS_PARSER=y
CONFIG_FS_IOMAP=y
CONFIG_EXT2_FS=m
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=y
# CONFIG_EXT4_FS_POSIX_ACL is not set
# CONFIG_EXT4_FS_SECURITY is not set
CONFIG_EXT4_DEBUG=y
# CONFIG_EXT4_KUNIT_TESTS is not set
CONFIG_JBD2=y
CONFIG_JBD2_DEBUG=y
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=m
CONFIG_REISERFS_CHECK=y
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_REISERFS_FS_XATTR is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
CONFIG_JFS_SECURITY=y
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set
# CONFIG_XFS_FS is not set
CONFIG_GFS2_FS=y
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=m
# CONFIG_BTRFS_FS_POSIX_ACL is not set
CONFIG_BTRFS_FS_CHECK_INTEGRITY=y
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
CONFIG_BTRFS_ASSERT=y
# CONFIG_BTRFS_FS_REF_VERIFY is not set
CONFIG_NILFS2_FS=y
CONFIG_F2FS_FS=m
CONFIG_F2FS_STAT_FS=y
CONFIG_F2FS_FS_XATTR=y
# CONFIG_F2FS_FS_POSIX_ACL is not set
CONFIG_F2FS_FS_SECURITY=y
CONFIG_F2FS_CHECK_FS=y
CONFIG_F2FS_IO_TRACE=y
# CONFIG_F2FS_FAULT_INJECTION is not set
# CONFIG_F2FS_FS_COMPRESSION is not set
CONFIG_ZONEFS_FS=m
CONFIG_FS_DAX=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FS_ENCRYPTION=y
CONFIG_FS_ENCRYPTION_ALGS=y
# CONFIG_FS_ENCRYPTION_INLINE_CRYPT is not set
CONFIG_FS_VERITY=y
CONFIG_FS_VERITY_DEBUG=y
CONFIG_FS_VERITY_BUILTIN_SIGNATURES=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
# CONFIG_FANOTIFY is not set
# CONFIG_QUOTA is not set
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_QUOTACTL=y
# CONFIG_AUTOFS4_FS is not set
CONFIG_AUTOFS_FS=y
CONFIG_FUSE_FS=m
CONFIG_CUSE=m
# CONFIG_VIRTIO_FS is not set
CONFIG_OVERLAY_FS=m
CONFIG_OVERLAY_FS_REDIRECT_DIR=y
CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW=y
# CONFIG_OVERLAY_FS_INDEX is not set
CONFIG_OVERLAY_FS_XINO_AUTO=y
CONFIG_OVERLAY_FS_METACOPY=y

#
# Caches
#
# CONFIG_FSCACHE is not set
# end of Caches

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
# CONFIG_ZISOFS is not set
CONFIG_UDF_FS=m
# end of CD-ROM/DVD Filesystems

#
# DOS/FAT/EXFAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_FAT_DEFAULT_UTF8=y
# CONFIG_EXFAT_FS is not set
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set
# end of DOS/FAT/EXFAT/NT Filesystems

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_VMCORE=y
# CONFIG_PROC_VMCORE_DEVICE_DUMP is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_PROC_PID_ARCH_STATUS=y
CONFIG_PROC_CPU_RESCTRL=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
CONFIG_TMPFS_XATTR=y
# CONFIG_TMPFS_INODE64 is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_MEMFD_CREATE=y
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_EFIVAR_FS=m
# end of Pseudo filesystems

# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=m
# CONFIG_NFS_V4_1 is not set
# CONFIG_ROOT_NFS is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFS_DISABLE_UDP_SUPPORT=y
# CONFIG_NFSD is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=m
# CONFIG_SUNRPC_DEBUG is not set
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=m
# CONFIG_CIFS_STATS2 is not set
CONFIG_CIFS_ALLOW_INSECURE_LEGACY=y
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_UPCALL is not set
# CONFIG_CIFS_XATTR is not set
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DEBUG_DUMP_KEYS is not set
# CONFIG_CIFS_DFS_UPCALL is not set
# CONFIG_CIFS_SWN_UPCALL is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
# CONFIG_9P_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
CONFIG_NLS_CODEPAGE_737=y
# CONFIG_NLS_CODEPAGE_775 is not set
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=m
# CONFIG_NLS_CODEPAGE_865 is not set
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=m
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
CONFIG_NLS_ISO8859_8=m
CONFIG_NLS_CODEPAGE_1250=y
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=m
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=m
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=m
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
CONFIG_NLS_MAC_ICELAND=y
# CONFIG_NLS_MAC_INUIT is not set
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
# CONFIG_NLS_UTF8 is not set
# CONFIG_DLM is not set
# CONFIG_UNICODE is not set
CONFIG_IO_WQ=y
# end of File systems

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_KEYS_REQUEST_CACHE is not set
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_TRUSTED_KEYS=m
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
# CONFIG_SECURITY_NETWORK is not set
# CONFIG_PAGE_TABLE_ISOLATION is not set
CONFIG_SECURITY_PATH=y
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
CONFIG_HARDENED_USERCOPY=y
# CONFIG_HARDENED_USERCOPY_FALLBACK is not set
# CONFIG_HARDENED_USERCOPY_PAGESPAN is not set
# CONFIG_FORTIFY_SOURCE is not set
# CONFIG_STATIC_USERMODEHELPER is not set
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
CONFIG_SECURITY_LOADPIN=y
# CONFIG_SECURITY_LOADPIN_ENFORCE is not set
CONFIG_SECURITY_YAMA=y
CONFIG_SECURITY_SAFESETID=y
CONFIG_SECURITY_LOCKDOWN_LSM=y
CONFIG_SECURITY_LOCKDOWN_LSM_EARLY=y
CONFIG_LOCK_DOWN_KERNEL_FORCE_NONE=y
# CONFIG_LOCK_DOWN_KERNEL_FORCE_INTEGRITY is not set
# CONFIG_LOCK_DOWN_KERNEL_FORCE_CONFIDENTIALITY is not set
# CONFIG_INTEGRITY is not set
# CONFIG_IMA_SECURE_AND_OR_TRUSTED_BOOT is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_LSM="lockdown,yama,loadpin,safesetid,integrity,bpf"

#
# Kernel hardening options
#

#
# Memory initialization
#
CONFIG_INIT_STACK_NONE=y
CONFIG_INIT_ON_ALLOC_DEFAULT_ON=y
CONFIG_INIT_ON_FREE_DEFAULT_ON=y
# end of Memory initialization
# end of Kernel hardening options
# end of Security options

CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=m
CONFIG_ASYNC_RAID6_RECOV=m
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_SKCIPHER=y
CONFIG_CRYPTO_SKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
# CONFIG_CRYPTO_TEST is not set
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y
CONFIG_CRYPTO_ENGINE=y

#
# Public-key cryptography
#
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=y
CONFIG_CRYPTO_ECC=y
CONFIG_CRYPTO_ECDH=y
CONFIG_CRYPTO_ECRDSA=m
CONFIG_CRYPTO_SM2=m
CONFIG_CRYPTO_CURVE25519=m
# CONFIG_CRYPTO_CURVE25519_X86 is not set

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=m
CONFIG_CRYPTO_CHACHA20POLY1305=m
CONFIG_CRYPTO_AEGIS128=m
# CONFIG_CRYPTO_AEGIS128_AESNI_SSE2 is not set
CONFIG_CRYPTO_SEQIV=y
# CONFIG_CRYPTO_ECHAINIV is not set

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_CFB is not set
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_OFB=y
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=y
# CONFIG_CRYPTO_KEYWRAP is not set
CONFIG_CRYPTO_NHPOLY1305=y
# CONFIG_CRYPTO_NHPOLY1305_SSE2 is not set
CONFIG_CRYPTO_NHPOLY1305_AVX2=y
# CONFIG_CRYPTO_ADIANTUM is not set
CONFIG_CRYPTO_ESSIV=m

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=m
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=m
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_XXHASH=m
CONFIG_CRYPTO_BLAKE2B=m
CONFIG_CRYPTO_BLAKE2S=y
CONFIG_CRYPTO_BLAKE2S_X86=m
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_POLY1305_X86_64=m
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=m
CONFIG_CRYPTO_RMD128=m
CONFIG_CRYPTO_RMD160=m
CONFIG_CRYPTO_RMD256=m
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=m
CONFIG_CRYPTO_SHA256_SSSE3=m
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=m
CONFIG_CRYPTO_SM3=y
CONFIG_CRYPTO_STREEBOG=y
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=m
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_TI is not set
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
# CONFIG_CRYPTO_DES is not set
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_SALSA20=m
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=m
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
CONFIG_CRYPTO_SM4=m
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=m
CONFIG_CRYPTO_TWOFISH_X86_64=m
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=m
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=m

#
# Compression
#
# CONFIG_CRYPTO_DEFLATE is not set
# CONFIG_CRYPTO_LZO is not set
CONFIG_CRYPTO_842=m
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=m
CONFIG_CRYPTO_ZSTD=m

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y

#
# Crypto library routines
#
CONFIG_CRYPTO_LIB_AES=y
CONFIG_CRYPTO_LIB_ARC4=m
CONFIG_CRYPTO_ARCH_HAVE_LIB_BLAKE2S=m
CONFIG_CRYPTO_LIB_BLAKE2S_GENERIC=y
CONFIG_CRYPTO_LIB_BLAKE2S=m
CONFIG_CRYPTO_ARCH_HAVE_LIB_CHACHA=m
CONFIG_CRYPTO_LIB_CHACHA_GENERIC=y
CONFIG_CRYPTO_LIB_CHACHA=m
CONFIG_CRYPTO_LIB_CURVE25519_GENERIC=y
CONFIG_CRYPTO_LIB_CURVE25519=y
CONFIG_CRYPTO_LIB_DES=m
CONFIG_CRYPTO_LIB_POLY1305_RSIZE=11
CONFIG_CRYPTO_ARCH_HAVE_LIB_POLY1305=m
CONFIG_CRYPTO_LIB_POLY1305_GENERIC=y
CONFIG_CRYPTO_LIB_POLY1305=m
# CONFIG_CRYPTO_LIB_CHACHA20POLY1305 is not set
CONFIG_CRYPTO_LIB_SHA256=y
CONFIG_CRYPTO_HW=y
# CONFIG_CRYPTO_DEV_PADLOCK is not set
CONFIG_CRYPTO_DEV_ATMEL_I2C=y
CONFIG_CRYPTO_DEV_ATMEL_ECC=y
# CONFIG_CRYPTO_DEV_ATMEL_SHA204A is not set
CONFIG_CRYPTO_DEV_CCP=y
# CONFIG_CRYPTO_DEV_CCP_DD is not set
CONFIG_CRYPTO_DEV_QAT=y
CONFIG_CRYPTO_DEV_QAT_DH895xCC=y
CONFIG_CRYPTO_DEV_QAT_C3XXX=y
# CONFIG_CRYPTO_DEV_QAT_C62X is not set
CONFIG_CRYPTO_DEV_QAT_4XXX=m
CONFIG_CRYPTO_DEV_QAT_DH895xCCVF=y
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
CONFIG_CRYPTO_DEV_QAT_C62XVF=m
CONFIG_CRYPTO_DEV_NITROX=m
CONFIG_CRYPTO_DEV_NITROX_CNN55XX=m
CONFIG_CRYPTO_DEV_VIRTIO=y
# CONFIG_CRYPTO_DEV_SAFEXCEL is not set
# CONFIG_CRYPTO_DEV_CCREE is not set
# CONFIG_CRYPTO_DEV_AMLOGIC_GXL is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_ASYMMETRIC_TPM_KEY_SUBTYPE=m
CONFIG_X509_CERTIFICATE_PARSER=y
# CONFIG_PKCS8_PRIVATE_KEY_PARSER is not set
# CONFIG_TPM_KEY_PARSER is not set
CONFIG_PKCS7_MESSAGE_PARSER=y
# CONFIG_PKCS7_TEST_KEY is not set
CONFIG_SIGNED_PE_FILE_VERIFICATION=y

#
# Certificates for signature checking
#
CONFIG_MODULE_SIG_KEY="certs/signing_key.pem"
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
CONFIG_SYSTEM_EXTRA_CERTIFICATE=y
CONFIG_SYSTEM_EXTRA_CERTIFICATE_SIZE=4096
# CONFIG_SECONDARY_TRUSTED_KEYRING is not set
CONFIG_SYSTEM_BLACKLIST_KEYRING=y
CONFIG_SYSTEM_BLACKLIST_HASH_LIST=""
# end of Certificates for signature checking

CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=m
CONFIG_RAID6_PQ_BENCHMARK=y
CONFIG_LINEAR_RANGES=y
# CONFIG_PACKING is not set
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_CORDIC=m
# CONFIG_PRIME_NUMBERS is not set
CONFIG_RATIONAL=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_ARCH_USE_SYM_ANNOTATIONS=y
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=m
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
CONFIG_CRC32_BIT=y
CONFIG_CRC64=y
CONFIG_CRC4=y
CONFIG_CRC7=m
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_XXHASH=y
CONFIG_RANDOM32_SELFTEST=y
CONFIG_842_COMPRESS=m
CONFIG_842_DECOMPRESS=m
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=m
CONFIG_LZO_DECOMPRESS=m
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=m
CONFIG_LZ4_DECOMPRESS=y
CONFIG_ZSTD_COMPRESS=m
CONFIG_ZSTD_DECOMPRESS=m
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=m
CONFIG_BCH_CONST_PARAMS=y
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_DMA_OPS=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DMA_DECLARE_COHERENT=y
CONFIG_ARCH_HAS_FORCE_DMA_UNENCRYPTED=y
CONFIG_SWIOTLB=y
CONFIG_DMA_COHERENT_POOL=y
CONFIG_DMA_CMA=y
CONFIG_DMA_PERNUMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=0
CONFIG_CMA_SIZE_PERCENTAGE=0
# CONFIG_CMA_SIZE_SEL_MBYTES is not set
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
CONFIG_CMA_SIZE_SEL_MAX=y
CONFIG_CMA_ALIGNMENT=8
# CONFIG_DMA_API_DEBUG is not set
CONFIG_DMA_MAP_BENCHMARK=y
CONFIG_SGL_ALLOC=y
CONFIG_IOMMU_HELPER=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_GLOB=y
CONFIG_GLOB_SELFTEST=m
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_LIBFDT=y
CONFIG_OID_REGISTRY=y
CONFIG_UCS2_STRING=y
CONFIG_HAVE_GENERIC_VDSO=y
CONFIG_GENERIC_GETTIMEOFDAY=y
CONFIG_GENERIC_VDSO_TIME_NS=y
CONFIG_FONT_SUPPORT=y
CONFIG_FONT_8x16=y
CONFIG_FONT_AUTOSELECT=y
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_ARCH_HAS_COPY_MC=y
CONFIG_ARCH_STACKWALK=y
CONFIG_STACKDEPOT=y
CONFIG_SBITMAP=y
CONFIG_STRING_SELFTEST=y
# end of Library routines

#
# Kernel hacking
#

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
# CONFIG_PRINTK_CALLER is not set
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_CONSOLE_LOGLEVEL_QUIET=4
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_DYNAMIC_DEBUG is not set
CONFIG_DYNAMIC_DEBUG_CORE=y
CONFIG_SYMBOLIC_ERRNAME=y
CONFIG_DEBUG_BUGVERBOSE=y
# end of printk and dmesg options

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_COMPRESSED is not set
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
CONFIG_FRAME_WARN=8192
CONFIG_STRIP_ASM_SYMS=y
CONFIG_READABLE_ASM=y
# CONFIG_HEADERS_INSTALL is not set
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
# CONFIG_DEBUG_FORCE_FUNCTION_ALIGN_32B is not set
CONFIG_STACK_VALIDATION=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# end of Compile-time checks and compiler options

#
# Generic Kernel Debugging Instruments
#
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_MAGIC_SYSRQ_SERIAL_SEQUENCE=""
CONFIG_DEBUG_FS=y
# CONFIG_DEBUG_FS_ALLOW_ALL is not set
CONFIG_DEBUG_FS_DISALLOW_MOUNT=y
# CONFIG_DEBUG_FS_ALLOW_NONE is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_HAVE_ARCH_KCSAN=y
# end of Generic Kernel Debugging Instruments

CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_MISC=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_OWNER is not set
# CONFIG_PAGE_POISONING is not set
CONFIG_DEBUG_PAGE_REF=y
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_ARCH_HAS_DEBUG_WX=y
CONFIG_DEBUG_WX=y
CONFIG_GENERIC_PTDUMP=y
CONFIG_PTDUMP_CORE=y
CONFIG_PTDUMP_DEBUGFS=y
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
CONFIG_DEBUG_OBJECTS_FREE=y
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
CONFIG_DEBUG_OBJECTS_WORK=y
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_SCHED_STACK_END_CHECK=y
CONFIG_ARCH_HAS_DEBUG_VM_PGTABLE=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_VMACACHE is not set
# CONFIG_DEBUG_VM_RB is not set
CONFIG_DEBUG_VM_PGFLAGS=y
CONFIG_DEBUG_VM_PGTABLE=y
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_KMAP_LOCAL=y
CONFIG_ARCH_SUPPORTS_KMAP_LOCAL_FORCE_MAP=y
CONFIG_DEBUG_KMAP_LOCAL_FORCE_MAP=y
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_HAVE_ARCH_KASAN_VMALLOC=y
CONFIG_CC_HAS_KASAN_GENERIC=y
CONFIG_CC_HAS_WORKING_NOSANITIZE_ADDRESS=y
CONFIG_KASAN=y
CONFIG_KASAN_GENERIC=y
CONFIG_KASAN_OUTLINE=y
# CONFIG_KASAN_INLINE is not set
CONFIG_KASAN_STACK=1
CONFIG_KASAN_VMALLOC=y
# CONFIG_KASAN_KUNIT_TEST is not set
CONFIG_TEST_KASAN_MODULE=m
# end of Memory Debugging

CONFIG_DEBUG_SHIRQ=y

#
# Debug Oops, Lockups and Hangs
#
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
# CONFIG_HARDLOCKUP_DETECTOR is not set
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_WQ_WATCHDOG=y
CONFIG_TEST_LOCKUP=m
# end of Debug Oops, Lockups and Hangs

#
# Scheduler Debugging
#
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
CONFIG_SCHEDSTATS=y
# end of Scheduler Debugging

CONFIG_DEBUG_TIMEKEEPING=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
CONFIG_PROVE_LOCKING=y
# CONFIG_PROVE_RAW_LOCK_NESTING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_RWSEMS=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_LOCKDEP=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=m
CONFIG_WW_MUTEX_SELFTEST=y
# CONFIG_SCF_TORTURE_TEST is not set
CONFIG_CSD_LOCK_WAIT_DEBUG=y
# end of Lock Debugging (spinlocks, mutexes, etc...)

CONFIG_TRACE_IRQFLAGS=y
CONFIG_TRACE_IRQFLAGS_NMI=y
CONFIG_STACKTRACE=y
CONFIG_WARN_ALL_UNSEEDED_RANDOM=y
# CONFIG_DEBUG_KOBJECT is not set

#
# Debug kernel data structures
#
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PLIST is not set
CONFIG_DEBUG_SG=y
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# end of Debug kernel data structures

# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
CONFIG_PROVE_RCU_LIST=y
CONFIG_TORTURE_TEST=m
CONFIG_RCU_SCALE_TEST=m
CONFIG_RCU_TORTURE_TEST=m
# CONFIG_RCU_REF_SCALE_TEST is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
CONFIG_RCU_STRICT_GRACE_PERIOD=y
# end of RCU Debugging

CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_LATENCYTOP=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_DIRECT_CALLS=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_ARGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_PREEMPTIRQ_TRACEPOINTS=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_BOOTTIME_TRACING=y
CONFIG_FUNCTION_TRACER=y
# CONFIG_FUNCTION_GRAPH_TRACER is not set
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_DYNAMIC_FTRACE_WITH_DIRECT_CALLS=y
# CONFIG_FUNCTION_PROFILER is not set
CONFIG_STACK_TRACER=y
# CONFIG_IRQSOFF_TRACER is not set
# CONFIG_SCHED_TRACER is not set
CONFIG_HWLAT_TRACER=y
CONFIG_MMIOTRACE=y
# CONFIG_FTRACE_SYSCALLS is not set
# CONFIG_TRACER_SNAPSHOT is not set
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_BLK_DEV_IO_TRACE is not set
# CONFIG_KPROBE_EVENTS is not set
# CONFIG_UPROBE_EVENTS is not set
CONFIG_DYNAMIC_EVENTS=y
CONFIG_FTRACE_MCOUNT_RECORD=y
CONFIG_SYNTH_EVENTS=y
# CONFIG_HIST_TRIGGERS is not set
CONFIG_TRACE_EVENT_INJECT=y
# CONFIG_TRACEPOINT_BENCHMARK is not set
CONFIG_RING_BUFFER_BENCHMARK=y
# CONFIG_TRACE_EVAL_MAP_FILE is not set
CONFIG_FTRACE_RECORD_RECURSION=y
CONFIG_FTRACE_RECORD_RECURSION_SIZE=128
CONFIG_RING_BUFFER_RECORD_RECURSION=y
# CONFIG_GCOV_PROFILE_FTRACE is not set
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
CONFIG_RING_BUFFER_VALIDATE_TIME_DELTAS=y
CONFIG_MMIOTRACE_TEST=m
CONFIG_PREEMPTIRQ_DELAY_TEST=m
CONFIG_SYNTH_EVENT_GEN_TEST=y
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
# CONFIG_SAMPLES is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_STRICT_DEVMEM=y
CONFIG_IO_STRICT_DEVMEM=y

#
# x86 Debugging
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_TRACE_IRQFLAGS_NMI_SUPPORT=y
CONFIG_EARLY_PRINTK_USB=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
CONFIG_EARLY_PRINTK_USB_XDBC=y
CONFIG_EFI_PGT_DUMP=y
CONFIG_DEBUG_TLBFLUSH=y
# CONFIG_IOMMU_DEBUG is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_X86_DECODER_SELFTEST is not set
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
CONFIG_PUNIT_ATOM_DEBUG=m
CONFIG_UNWINDER_ORC=y
# CONFIG_UNWINDER_FRAME_POINTER is not set
# end of x86 Debugging

#
# Kernel Testing and Coverage
#
CONFIG_KUNIT=m
CONFIG_KUNIT_DEBUGFS=y
CONFIG_KUNIT_TEST=m
CONFIG_KUNIT_EXAMPLE_TEST=m
# CONFIG_KUNIT_ALL_TESTS is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FUNCTION_ERROR_INJECTION=y
CONFIG_FAULT_INJECTION=y
CONFIG_FAILSLAB=y
CONFIG_FAIL_PAGE_ALLOC=y
CONFIG_FAULT_INJECTION_USERCOPY=y
CONFIG_FAIL_MAKE_REQUEST=y
CONFIG_FAIL_IO_TIMEOUT=y
CONFIG_FAIL_FUTEX=y
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
CONFIG_ARCH_HAS_KCOV=y
CONFIG_CC_HAS_SANCOV_TRACE_PC=y
# CONFIG_KCOV is not set
CONFIG_RUNTIME_TESTING_MENU=y
# CONFIG_LKDTM is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_TEST_MIN_HEAP is not set
# CONFIG_TEST_SORT is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_REED_SOLOMON_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
# CONFIG_PERCPU_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_STRSCPY is not set
# CONFIG_TEST_KSTRTOX is not set
CONFIG_TEST_PRINTF=y
# CONFIG_TEST_BITMAP is not set
# CONFIG_TEST_UUID is not set
# CONFIG_TEST_XARRAY is not set
# CONFIG_TEST_OVERFLOW is not set
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_TEST_HASH is not set
# CONFIG_TEST_IDA is not set
CONFIG_TEST_LKM=m
CONFIG_TEST_BITOPS=m
# CONFIG_TEST_VMALLOC is not set
# CONFIG_TEST_USER_COPY is not set
# CONFIG_TEST_BPF is not set
# CONFIG_TEST_BLACKHOLE_DEV is not set
# CONFIG_FIND_BIT_BENCHMARK is not set
# CONFIG_TEST_FIRMWARE is not set
CONFIG_TEST_SYSCTL=y
CONFIG_BITFIELD_KUNIT=m
CONFIG_RESOURCE_KUNIT_TEST=m
CONFIG_SYSCTL_KUNIT_TEST=m
CONFIG_LIST_KUNIT_TEST=m
CONFIG_LINEAR_RANGES_TEST=m
CONFIG_CMDLINE_KUNIT_TEST=m
CONFIG_BITS_TEST=m
# CONFIG_TEST_UDELAY is not set
CONFIG_TEST_STATIC_KEYS=m
# CONFIG_TEST_KMOD is not set
# CONFIG_TEST_MEMCAT_P is not set
CONFIG_TEST_STACKINIT=y
# CONFIG_TEST_MEMINIT is not set
CONFIG_TEST_FREE_PAGES=m
# CONFIG_TEST_FPU is not set
CONFIG_MEMTEST=y
# end of Kernel Testing and Coverage
# end of Kernel hacking

--pQhZXvAqiZgbeUkD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=job-script

#!/bin/sh

export_top_env()
{
	export suite='trinity'
	export testcase='trinity'
	export category='functional'
	export need_memory='300MB'
	export runtime=300
	export job_origin='trinity.yaml'
	export queue_cmdline_keys='branch
commit'
	export queue='bisect'
	export testbox='vm-snb-124'
	export tbox_group='vm-snb'
	export branch='linux-devel/devel-catchup-20210215-205258'
	export commit='f009495a8def89a71b9e0b9025a39379d6f9097d'
	export kconfig='x86_64-randconfig-a011-20210215'
	export nr_vm=160
	export submit_id='602c567eaf2a968304f2cd91'
	export job_file='/lkp/jobs/scheduled/vm-snb-124/trinity-300s-debian-10.4-x86_64-20200603.cgz-f009495a8def89a71b9e0b9025a39379d6f9097d-20210217-33540-1tuu5rt-2.yaml'
	export id='169e3a656fa780563b0be6a752fa1e676fb74183'
	export queuer_version='/lkp-src'
	export model='qemu-system-x86_64 -enable-kvm -cpu SandyBridge'
	export nr_cpu=2
	export memory='8G'
	export need_kconfig='CONFIG_KVM_GUEST=y'
	export ssh_base_port=23032
	export kernel_cmdline='vmalloc=512M'
	export rootfs='debian-10.4-x86_64-20200603.cgz'
	export compiler='gcc-9'
	export enqueue_time='2021-02-17 07:34:22 +0800'
	export _id='602c5cdaaf2a968304f2cd93'
	export _rt='/result/trinity/300s/vm-snb/debian-10.4-x86_64-20200603.cgz/x86_64-randconfig-a011-20210215/gcc-9/f009495a8def89a71b9e0b9025a39379d6f9097d'
	export user='lkp'
	export LKP_SERVER='internal-lkp-server'
	export result_root='/result/trinity/300s/vm-snb/debian-10.4-x86_64-20200603.cgz/x86_64-randconfig-a011-20210215/gcc-9/f009495a8def89a71b9e0b9025a39379d6f9097d/2'
	export scheduler_version='/lkp/lkp/src'
	export arch='x86_64'
	export max_uptime=2100
	export initrd='/osimage/debian/debian-10.4-x86_64-20200603.cgz'
	export bootloader_append='root=/dev/ram0
user=lkp
job=/lkp/jobs/scheduled/vm-snb-124/trinity-300s-debian-10.4-x86_64-20200603.cgz-f009495a8def89a71b9e0b9025a39379d6f9097d-20210217-33540-1tuu5rt-2.yaml
ARCH=x86_64
kconfig=x86_64-randconfig-a011-20210215
branch=linux-devel/devel-catchup-20210215-205258
commit=f009495a8def89a71b9e0b9025a39379d6f9097d
BOOT_IMAGE=/pkg/linux/x86_64-randconfig-a011-20210215/gcc-9/f009495a8def89a71b9e0b9025a39379d6f9097d/vmlinuz-5.11.0-rc7-00017-gf009495a8def
vmalloc=512M
max_uptime=2100
RESULT_ROOT=/result/trinity/300s/vm-snb/debian-10.4-x86_64-20200603.cgz/x86_64-randconfig-a011-20210215/gcc-9/f009495a8def89a71b9e0b9025a39379d6f9097d/2
LKP_SERVER=internal-lkp-server
selinux=0
debug
apic=debug
sysrq_always_enabled
rcupdate.rcu_cpu_stall_timeout=100
net.ifnames=0
printk.devkmsg=on
panic=-1
softlockup_panic=1
nmi_watchdog=panic
oops=panic
load_ramdisk=2
prompt_ramdisk=0
drbd.minor_count=8
systemd.log_level=err
ignore_loglevel
console=tty0
earlyprintk=ttyS0,115200
console=ttyS0,115200
vga=normal
rw'
	export modules_initrd='/pkg/linux/x86_64-randconfig-a011-20210215/gcc-9/f009495a8def89a71b9e0b9025a39379d6f9097d/modules.cgz'
	export bm_initrd='/osimage/deps/debian-10.4-x86_64-20200603.cgz/lkp_20201211.cgz,/osimage/deps/debian-10.4-x86_64-20200603.cgz/run-ipconfig_20200608.cgz,/osimage/deps/debian-10.4-x86_64-20200603.cgz/rsync-rootfs_20200608.cgz,/osimage/pkg/debian-10.4-x86_64-20200603.cgz/trinity-x86_64-4d2343bd-1_20210105.cgz'
	export lkp_initrd='/osimage/user/lkp/lkp-x86_64.cgz'
	export site='cfdcab994d34'
	export kernel='/pkg/linux/x86_64-randconfig-a011-20210215/gcc-9/f009495a8def89a71b9e0b9025a39379d6f9097d/vmlinuz-5.11.0-rc7-00017-gf009495a8def'
	export dequeue_time='2021-02-17 08:02:58 +0800'
	export job_initrd='/lkp/jobs/scheduled/vm-snb-124/trinity-300s-debian-10.4-x86_64-20200603.cgz-f009495a8def89a71b9e0b9025a39379d6f9097d-20210217-33540-1tuu5rt-2.cgz'

	[ -n "$LKP_SRC" ] ||
	export LKP_SRC=/lkp/${user:-lkp}/src
}

run_job()
{
	echo $$ > $TMP/run-job.pid

	. $LKP_SRC/lib/http.sh
	. $LKP_SRC/lib/job.sh
	. $LKP_SRC/lib/env.sh

	export_top_env

	run_monitor $LKP_SRC/monitors/wrapper kmsg
	run_monitor $LKP_SRC/monitors/wrapper heartbeat
	run_monitor $LKP_SRC/monitors/wrapper meminfo

	run_test $LKP_SRC/tests/wrapper trinity
}

extract_stats()
{
	export stats_part_begin=
	export stats_part_end=

	$LKP_SRC/stats/wrapper kmsg
	$LKP_SRC/stats/wrapper meminfo

	$LKP_SRC/stats/wrapper time trinity.time
	$LKP_SRC/stats/wrapper dmesg
	$LKP_SRC/stats/wrapper kmsg
	$LKP_SRC/stats/wrapper last_state
	$LKP_SRC/stats/wrapper stderr
	$LKP_SRC/stats/wrapper time
}

"$@"

--pQhZXvAqiZgbeUkD
Content-Type: application/x-xz
Content-Disposition: attachment; filename="dmesg.xz"
Content-Transfer-Encoding: base64

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
AAAABFla

--pQhZXvAqiZgbeUkD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=trinity

Seeding trinity based on x86_64-randconfig-a011-20210215
2021-02-17 00:04:53 chroot --userspec nobody:nogroup / trinity -q -q -l off -s 782031929 -x get_robust_list -x remap_file_pages -N 999999999
Trinity 2019.06  Dave Jones <davej@codemonkey.org.uk>
shm:0x7f79709c5000-0x7f797d5c1d00 (4 pages)
[main] Marking syscall get_robust_list (64bit:274 32bit:312) as to be disabled.
[main] Marking syscall remap_file_pages (64bit:216 32bit:257) as to be disabled.
[main] Couldn't chmod tmp/ to 0777.
[main] Using user passed random seed: 782031929.
[main] Kernel was tainted on startup. Will ignore flags that are already set.
Marking all syscalls as enabled.
[main] Disabling syscalls marked as disabled by command line options
[main] Marked 64-bit syscall remap_file_pages (216) as deactivated.
[main] Marked 64-bit syscall get_robust_list (274) as deactivated.
[main] Marked 32-bit syscall remap_file_pages (257) as deactivated.
[main] Marked 32-bit syscall get_robust_list (312) as deactivated.
[main] 32-bit syscalls: 426 enabled, 3 disabled.  64-bit syscalls: 345 enabled, 91 disabled.
[main] Using pid_max = 32768
[main] futex: 0 owner:0 global:1
[main] futex: 0 owner:0 global:1
[main] futex: 0 owner:0 global:1
[main] futex: 0 owner:0 global:1
[main] futex: 0 owner:0 global:1
[main] Reserved/initialized 5 futexes.
[main] sysv_shm: id:0 size:8192 flags:7b0 ptr:(nil) global:1
[main] sysv_shm: id:1 size:4096 flags:17b0 ptr:(nil) global:1
[main] Added 17 filenames from /dev
[main] Added 18962 filenames from /proc
[main] Added 5710 filenames from /sys
[main] Couldn't open socket (35:5:2). Address family not supported by protocol
Can't do protocol KEY
Can't do protocol SNA
[main] Couldn't open socket (40:5:3). Address family not supported by protocol
[main] Couldn't open socket (36:5:2). Address family not supported by protocol
[main] Couldn't open socket (30:1:0). Address family not supported by protocol
[main] Couldn't open socket (27:1:3). Address family not supported by protocol
[main] Couldn't open socket (44:3:0). Address family not supported by protocol
Can't do protocol NETBEUI
[main] Couldn't open socket (42:2:0). Address family not supported by protocol
[main] Couldn't open socket (23:2:1). Address family not supported by protocol
[main] Couldn't open socket (34:2:5). Address family not supported by protocol
Can't do protocol SECURITY
Can't do protocol ECONET
[main] Couldn't open socket (43:1:1). Address family not supported by protocol
[main] Couldn't open socket (10:5:0). Socket type not supported
[main] Couldn't open socket (34:5:3). Address family not supported by protocol
[main] Couldn't open socket (44:3:0). Address family not supported by protocol
[main] Couldn't open socket (44:3:0). Address family not supported by protocol
[main] Couldn't open socket (44:3:0). Address family not supported by protocol
Can't do protocol ASH
[main] Couldn't open socket (9:5:0). Address family not supported by protocol
Can't do protocol LLC
Can't do protocol SNA
[main] Couldn't open socket (29:3:1). Address family not supported by protocol
[main] Couldn't open socket (40:3:5). Address family not supported by protocol
[main] Couldn't open socket (24:3:1). Address family not supported by protocol
Can't do protocol PACKET
[main] Couldn't open socket (35:2:1). Address family not supported by protocol
[main] Couldn't open socket (40:2:1). Address family not supported by protocol
[main] Couldn't open socket (36:2:5). Address family not supported by protocol
[main] Couldn't open socket (44:3:0). Address family not supported by protocol
Can't do protocol SECURITY
Can't do protocol ECONET
[main] Couldn't open socket (39:5:0). Address family not supported by protocol
Can't do protocol LLC
[main] Couldn't open socket (21:5:0). Address family not supported by protocol
[main] Couldn't open socket (12:5:2). Address family not supported by protocol
[main] Couldn't open socket (8:2:0). Address family not supported by protocol
[main] Couldn't open socket (39:1:1). Address family not supported by protocol
Can't do protocol ASH
[main] Couldn't open socket (16:3:20). Protocol not supported
Can't do protocol BRIDGE
[main] Enabled 14/14 fd providers. initialized:14.
[main] Error opening tracing_on : No such file or directory
[child0:705] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:706] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:707] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:711] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:704] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:716] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:717] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:710] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:723] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:722] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:725] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:726] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:729] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:730] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:734] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:737] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:739] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:728] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:743] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:693] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:719] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:749] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:746] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:754] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:745] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:755] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:757] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:747] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:759] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:760] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:762] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:764] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:767] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:752] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:758] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:773] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:774] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:775] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:777] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:770] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:785] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:769] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:786] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:778] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:792] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:796] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:798] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:799] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:801] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:780] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:802] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:805] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:807] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:795] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:812] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:811] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:815] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:816] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:810] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:787] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:822] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:824] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:828] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:832] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:813] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:834] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:817] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:837] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:842] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:840] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:844] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:845] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:846] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:847] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:848] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:850] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:835] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:852] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:855] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:826] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:853] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:858] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:857] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:860] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:863] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:867] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:868] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:872] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:875] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:877] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:865] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:861] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:878] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:884] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:871] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:892] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:883] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:893] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:896] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:881] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:902] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:909] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:911] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:898] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:913] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:914] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:916] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:897] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:917] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:891] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:925] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:922] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:931] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:929] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:935] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:918] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:939] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:941] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:942] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:943] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:945] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:927] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:952] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:947] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:956] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:958] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:962] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:949] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:976] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:966] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:977] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:978] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:983] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:980] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:985] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:986] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:959] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:989] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:993] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:992] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:974] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:998] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:999] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1000] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1002] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1005] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1011] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1003] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1014] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1012] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1016] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:994] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1019] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1021] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1020] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1026] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1028] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1029] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1031] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1018] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1036] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1038] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1039] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1032] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1046] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1001] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1050] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1051] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1052] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1053] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1057] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1041] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1034] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1065] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1068] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1071] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1054] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1069] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1074] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1075] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[main] 10011 iterations. [F:7262 S:2521 HI:263]
[child1:1076] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1077] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1078] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1082] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1062] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1080] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1086] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1092] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1096] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1088] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1079] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1102] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1103] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1098] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1094] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1108] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1115] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1112] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1118] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1105] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1121] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1110] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1122] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1123] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1129] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1124] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1126] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1138] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1141] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1142] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1146] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1148] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1130] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1137] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1150] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1140] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1154] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1156] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1152] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1159] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1161] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1164] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1149] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1168] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1167] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1172] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1174] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1176] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1180] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1158] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1183] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1160] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1189] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1179] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1191] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1190] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1181] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1184] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1192] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1195] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1200] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1197] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1204] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1199] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1206] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1209] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1215] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1214] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1202] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1219] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1222] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1223] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1225] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1224] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1228] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1229] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1210] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1227] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1235] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1244] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1252] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1226] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1245] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1267] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1272] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1257] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1264] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1296] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1286] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1297] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1299] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1279] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1301] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1306] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1305] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1312] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1314] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1316] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1317] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1300] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1303] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1327] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1308] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1332] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1333] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1337] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1325] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1340] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1342] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1339] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1318] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1347] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1348] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1344] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1350] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1351] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1355] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1358] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1357] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1359] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1362] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1345] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1364] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1366] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1367] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1368] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1356] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1379] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1380] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1360] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1386] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1365] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1387] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1393] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1397] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1391] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1381] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1401] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1403] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1405] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1409] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1404] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1416] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1417] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1418] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1419] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1375] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1421] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1420] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1422] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1424] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1426] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1425] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1428] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1429] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1433] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1399] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1442] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1443] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1446] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1447] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1432] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1448] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1437] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1453] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1449] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1441] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1458] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1461] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1459] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1465] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1463] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1462] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[main] 20037 iterations. [F:14506 S:5095 HI:295]
[child3:1467] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1456] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1475] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1477] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1468] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1471] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1482] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1492] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1487] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1494] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1485] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1498] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1500] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1504] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1505] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1506] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1480] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1499] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1516] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1519] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1512] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1521] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1520] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1510] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1524] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1508] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1531] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1533] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1529] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1536] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1539] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1535] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1541] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1542] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1547] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1548] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1551] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1530] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1552] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1553] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1555] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1523] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1560] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1561] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1567] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1563] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1568] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1569] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1572] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1573] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1549] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1574] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1570] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1576] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1579] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1584] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1586] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1590] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1591] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1592] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1593] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1595] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1594] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1596] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1600] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1575] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1597] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1606] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1608] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1612] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1614] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1615] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1617] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1616] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1619] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1622] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1625] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1623] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1628] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1627] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1629] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1634] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1635] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1637] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1639] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1577] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1620] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1641] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1642] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1643] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1644] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1633] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1645] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1646] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1654] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1655] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1656] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1658] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1661] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1663] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1665] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1666] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1657] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1673] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1660] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1676] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1677] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1683] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1690] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1670] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1691] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1678] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1640] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1698] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1701] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1697] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1706] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1710] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1708] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1711] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1713] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1693] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1715] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1714] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1717] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1718] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1692] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1722] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1723] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1725] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1724] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1727] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1728] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1731] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1732] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1734] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1729] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1741] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1742] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1733] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1744] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1745] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1746] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1747] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1712] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1749] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1748] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1751] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1752] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1758] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1759] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1763] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1761] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1765] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1767] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1769] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1768] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1750] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1771] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1772] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1774] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1778] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1779] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1781] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1782] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1784] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1785] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1786] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1787] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1788] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1792] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1756] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1780] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1796] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1797] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1783] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1802] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1800] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[main] 30052 iterations. [F:21742 S:7667 HI:391]
[child0:1794] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1806] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1812] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1809] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1813] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1816] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1817] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1820] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1823] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1824] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1799] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1826] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1828] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1827] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1829] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1835] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1834] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1836] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1837] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1842] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1843] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1841] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1840] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1844] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1852] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1848] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1855] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1849] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1860] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1864] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1865] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1866] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1868] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1872] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1854] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1873] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1876] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1875] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1861] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1814] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1878] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1880] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1885] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1877] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1891] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1892] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1882] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1879] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1900] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1904] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1906] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1907] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1909] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1910] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1912] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1886] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1913] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1917] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1918] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1905] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1919] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1921] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1893] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1924] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1926] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1927] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1920] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1933] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1934] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1923] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1935] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1932] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1953] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1954] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1955] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1956] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1957] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1958] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1922] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1959] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1961] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1964] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1965] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1947] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1971] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1973] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1975] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1976] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1962] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1978] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1979] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1980] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1986] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1988] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1970] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1990] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1991] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1960] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1992] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:1993] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:1995] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2000] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:1998] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2002] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2001] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2008] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2004] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2012] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:1977] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2013] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2014] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2015] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2018] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2020] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2022] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2009] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2027] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2028] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2029] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2030] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2032] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2016] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2037] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2039] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2040] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2026] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2047] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2048] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2049] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2051] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2034] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2053] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2017] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2057] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2050] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2063] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2052] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2068] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2067] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2069] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2072] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2076] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2070] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2081] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2082] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2083] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2085] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2086] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2058] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2087] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2080] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2096] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2099] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2101] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2059] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2104] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2097] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2108] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2105] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2109] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2114] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2113] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2115] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2117] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2119] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2116] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2120] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2122] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2102] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2125] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2127] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2128] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[main] 40062 iterations. [F:29041 S:10157 HI:391]
[child2:2129] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2133] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2134] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2139] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2121] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2143] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2141] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2123] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2146] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2147] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2126] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2145] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2148] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2158] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2152] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2160] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2159] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2166] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2164] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2169] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2167] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2174] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2171] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2175] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2177] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2180] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2153] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2184] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2185] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2186] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2187] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2188] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2189] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2191] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2194] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2192] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2195] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2196] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2198] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2207] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2208] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2210] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2211] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2213] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2218] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2220] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2202] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2176] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2226] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2227] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2228] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2232] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2230] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2234] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2237] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2221] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2239] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2238] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2179] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2241] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2242] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2247] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2246] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2248] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2251] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2254] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2255] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2252] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2256] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2267] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2269] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2253] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2266] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2276] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2277] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2279] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2280] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2281] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2258] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2273] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2286] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2287] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2289] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2291] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2290] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2296] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2297] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2299] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2300] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2301] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2302] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2307] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2309] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2275] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2317] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2298] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2318] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2320] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2321] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2311] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2327] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2293] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2332] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2329] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2333] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2334] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2323] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2341] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2342] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2322] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2336] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2343] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2344] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2347] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2348] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2349] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2351] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2352] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2346] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2357] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2361] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2363] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2368] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2362] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2370] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2369] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2375] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2381] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2356] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2384] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2387] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2392] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2393] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2350] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2398] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2399] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2400] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2405] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2406] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2407] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2409] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2410] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2395] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2415] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2417] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2418] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2376] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2385] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2423] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2413] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2428] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2429] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2431] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2427] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2432] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2433] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2434] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2440] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2435] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2441] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2442] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2446] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2426] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2447] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2449] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2450] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2452] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2453] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2443] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2459] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2445] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2460] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2461] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2463] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2462] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2464] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2451] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2465] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2466] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2467] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2474] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2475] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2469] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2476] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2486] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2487] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2454] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2468] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2492] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2490] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2496] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2499] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2502] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2489] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2503] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2505] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2484] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2514] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2515] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[main] 50122 iterations. [F:36316 S:12689 HI:391]
[child1:2508] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2518] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2521] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2509] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2527] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2528] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2529] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2530] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2532] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2533] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2534] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2535] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2536] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2504] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2540] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2537] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2539] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2545] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2549] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2544] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2553] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2552] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2555] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2554] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2557] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2558] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2560] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2559] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2562] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2563] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2565] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2523] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2570] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2571] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2572] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2550] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2574] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2579] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2577] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2576] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2581] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2584] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2582] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2586] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2564] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2592] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2591] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2599] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2601] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2603] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2602] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2608] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2606] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2587] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2611] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2594] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2617] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2618] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2619] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2609] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2622] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2623] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2625] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2627] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2624] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2637] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2628] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2630] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2638] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2640] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2621] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2644] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2645] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2646] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2647] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2648] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2649] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2654] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2653] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2656] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2657] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2660] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2662] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2663] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2665] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2659] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2639] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2667] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2678] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2680] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2681] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2672] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2690] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2674] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2693] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2682] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2696] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2698] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2666] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2691] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2705] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2706] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2707] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2694] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2708] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2709] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2699] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2711] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2713] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2719] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2714] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2723] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2718] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2729] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2703] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2735] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2736] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2724] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2730] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2737] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2739] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2747] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2746] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2726] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2749] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2755] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2740] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2760] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2761] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2762] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2764] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2767] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2763] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2771] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2769] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2772] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2748] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2775] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2759] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2782] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2783] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2785] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2773] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2788] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2789] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2774] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2781] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2795] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2794] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2797] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2796] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2798] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2799] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2801] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2802] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2803] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2804] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2806] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2805] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2807] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2786] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2813] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2800] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2815] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2818] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2820] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2816] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2827] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2812] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2817] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2821] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2834] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2832] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2840] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2847] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2829] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2848] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[main] 60143 iterations. [F:43601 S:15200 HI:391]
[child2:2849] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2850] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2852] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2857] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2858] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2851] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2861] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2863] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2859] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2865] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2866] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2839] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2872] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2874] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2868] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2877] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2880] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2881] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2830] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2888] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2890] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2879] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2892] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2894] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2893] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2882] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2895] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2897] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2904] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2898] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2902] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2906] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2911] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2915] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2916] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2921] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2907] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2922] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2923] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2927] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2910] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2928] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2909] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2934] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2936] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2937] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2938] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2943] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2924] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2929] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2947] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2946] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2955] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2956] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2960] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2961] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2963] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2966] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2967] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2941] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2969] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2974] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2970] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2982] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2983] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2965] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2962] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2989] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2990] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2991] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2993] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2984] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:2998] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3002] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3008] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3009] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:2988] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3013] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:2976] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3015] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3017] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:2997] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3023] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3022] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3026] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3027] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3011] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3028] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3031] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3029] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3035] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3033] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3042] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3045] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3046] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3047] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3052] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3053] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3054] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3055] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3044] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3040] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3058] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3061] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3067] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3063] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3014] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3072] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3073] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3074] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3075] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3077] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3082] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3081] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3083] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3084] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3085] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3086] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3065] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3087] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3089] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3094] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3093] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3095] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3100] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3105] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3109] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3103] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3113] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3112] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3115] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3117] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3118] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3098] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3121] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3123] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3124] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3130] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3131] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3132] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3133] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3135] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3136] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3119] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3137] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3138] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3097] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3129] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3143] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3144] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3146] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3147] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3142] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3150] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3149] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3152] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3155] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3153] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3160] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3162] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3163] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[main] 70253 iterations. [F:50872 S:17850 HI:391]
[child1:3145] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3164] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3166] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3156] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3170] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3167] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3175] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3177] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3169] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3179] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3181] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3174] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3185] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3190] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3191] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3194] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3195] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3196] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3188] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3202] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3168] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3203] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3197] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3204] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3178] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3205] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3206] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3209] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3213] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3208] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3216] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3218] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3219] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3221] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3225] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3227] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3217] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3232] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3235] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3236] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3220] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3214] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3239] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3228] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3248] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3245] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3254] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3253] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3251] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3258] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3256] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3260] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3265] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3266] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3271] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3270] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3273] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3274] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3272] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3278] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3277] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3275] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3263] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3282] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3280] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3292] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3295] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3281] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3297] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3300] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3303] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3304] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3306] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3310] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3287] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3311] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3314] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3315] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3299] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3318] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3320] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3321] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3325] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3302] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3312] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3332] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3333] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3334] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3328] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3336] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3337] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3341] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3319] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3342] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3349] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3354] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3347] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3343] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3357] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3362] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3359] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3368] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3369] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3327] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3367] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3376] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3371] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3358] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3379] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3372] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3384] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3386] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3390] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3393] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3382] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3394] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3383] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3380] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3398] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3403] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3396] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3410] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3412] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3413] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3402] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3416] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3419] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3417] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3425] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3420] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3429] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3435] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3436] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3437] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3430] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3442] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3440] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3450] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3453] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3422] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3456] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3457] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3405] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3459] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3461] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3465] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3467] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3468] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3473] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3469] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3475] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3476] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3477] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3479] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3480] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3482] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3483] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3464] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3485] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3486] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3490] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[main] 80272 iterations. [F:58190 S:20348 HI:454]
[child0:3492] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3493] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3494] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3496] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3500] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3501] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3478] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3484] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3503] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3507] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3512] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3497] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3511] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3517] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3502] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3520] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3515] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3521] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3527] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3529] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3530] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3531] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3528] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3533] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3535] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3514] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3537] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3536] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3539] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3547] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3542] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3551] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3552] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3553] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3555] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3519] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3532] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3560] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3561] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3562] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3563] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3565] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3564] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3570] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3573] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3549] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3566] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3581] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3575] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3580] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3587] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3572] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3597] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3594] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3599] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3603] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3586] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3604] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3610] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3611] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3612] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3613] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3615] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3614] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3589] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3618] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3621] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3622] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3619] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3623] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3624] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3632] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3635] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3638] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3617] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3640] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3643] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3644] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3645] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3629] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3607] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3650] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3649] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3654] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3656] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3657] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3662] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3663] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3664] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3665] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3667] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3641] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3668] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3672] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3674] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3673] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3676] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3678] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3679] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3681] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3652] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3684] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3686] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3687] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3690] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3689] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3694] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3698] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3699] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3661] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3701] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3704] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3705] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3702] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3706] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3708] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3709] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3712] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3717] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3707] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3719] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3710] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3720] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3722] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3727] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3718] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3731] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3733] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3735] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3736] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3737] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3723] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3745] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3716] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3746] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3730] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3748] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3751] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3754] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3752] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3755] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3756] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3758] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3759] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3744] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3763] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3764] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3765] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3766] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3750] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3770] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3768] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3771] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3773] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3775] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3757] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3777] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3782] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3767] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3785] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3784] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3788] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3786] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3789] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3774] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3776] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3791] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3795] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3799] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3802] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3803] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3804] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3805] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3806] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3807] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3809] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3810] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3811] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3813] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3815] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3796] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3816] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3793] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3821] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3820] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3824] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3822] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3825] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3826] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3828] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3830] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3832] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3837] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3831] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3842] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3827] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3840] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3838] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3853] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3855] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3863] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[main] 90306 iterations. [F:65445 S:22893 HI:454]
[child1:3845] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3867] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3864] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3870] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3871] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3873] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3857] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3877] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3881] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3883] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3884] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3885] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3887] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3888] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3890] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3891] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3872] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3869] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3895] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3889] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3900] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3892] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3896] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3894] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3909] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3902] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3913] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3915] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3917] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3918] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3905] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3922] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3923] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3924] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3925] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3929] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3930] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3932] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3933] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3935] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3920] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3919] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3921] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child3:3938] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3937] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3940] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3941] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3943] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3948] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3944] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3951] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3949] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3953] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3954] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3956] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child1:3957] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child2:3959] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[child0:3958] Tried 8 32-bit syscalls unsuccessfully. Disabling all 32-bit syscalls.
[main] kernel became tainted! (8224/8192) Last seed was 782038633
trinity: Detected kernel tainting. Last seed was 782038633
[main] exit_reason=7, but 3 children still running.
[main] Bailing main loop because kernel became tainted..
[main] Ran 93208 syscalls. Successes: 23634  Failures: 67538

--pQhZXvAqiZgbeUkD
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--pQhZXvAqiZgbeUkD--
