From: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [cgroup_init_early] WARNING: at mm/percpu.c:292 pcpu_mem_zalloc()
Date: Fri, 14 Jun 2013 07:00:04 +0800
Message-ID: <20130613230004.GA8096__34857.953983783$1371164449$gmane$org@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="6TrnltStXW4iwmi0"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

I got the below dmesg and the first bad commit is

commit f284b77333b1320491f138b76f11006bbc962569
Author: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date:   Wed Jun 12 13:50:58 2013 -0700

    cgroup: use percpu refcnt for cgroup_subsys_states
    
    A css (cgroup_subsys_state) is how each cgroup is represented to a
    controller.  As such, it can be used in hot paths across the various
    subsystems different controllers are associated with.
    
    One of the common operations is reference counting, which up until now
    has been implemented using a global atomic counter and can have
    significant adverse impact on scalability.  For example, css refcnt
    can be gotten and put multiple times by blkcg for each IO request.
    For highops configurations which try to do as much per-cpu as
    possible, the global frequent refcnting can be very expensive.
    
    In general, given the various hugely diverse paths css's end up being
    used from, we need to make it cheap and highly scalable.  In its
    usage, css refcnting isn't very different from module refcnting.
    
    This patch converts css refcnting to use the recently added
    percpu_ref.  css_get/tryget/put() directly maps to the matching
    percpu_ref operations and the deactivation logic is no longer
    necessary as percpu_ref already has refcnt killing.
    
    The only complication is that as the refcnt is per-cpu,
    percpu_ref_kill() in itself doesn't ensure that further tryget
    operations will fail, which we need to guarantee before invoking
    ->css_offline()'s.  This is resolved collecting kill confirmation
    using percpu_ref_kill_and_confirm() and initiating the offline phase
    of destruction after all css refcnt's are confirmed to be seen as
    killed on all CPUs.  The previous patches already splitted destruction
    into two phases, so percpu_ref_kill_and_confirm() can be hooked up
    easily.
    
    This patch removes css_refcnt() which is used for rcu dereference
    sanity check in css_id().  While we can add a percpu refcnt API to ask
    the same question, css_id() itself is scheduled to be removed fairly
    soon, so let's not bother with it.  Just drop the sanity check and use
    rcu_dereference_raw() instead.
    
    Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
    Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
    Cc: Mike Snitzer <snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: "Alasdair G. Kergon" <agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
    Cc: Mikulas Patocka <mpatocka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
    Cc: Kent Overstreet <koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>


[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] ------------[ cut here ]------------
[    0.000000] WARNING: at /c/kernel-tests/src/tip/mm/percpu.c:292 pcpu_mem_zalloc+0x2f/0x80()
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.10.0-rc4-00064-gf284b773 #57
[    0.000000]  0000000000000009 ffffffff82133d58 ffffffff81c259e5 ffffffff82133d98
[    0.000000]  ffffffff810818c6 ffffffff82133da8 0000000000000000 0000000000000004
[    0.000000]  0000000000000082 0000000000000004 0000000000000004 ffffffff82133da8
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff81c259e5>] dump_stack+0x19/0x1b
[    0.000000]  [<ffffffff810818c6>] warn_slowpath_common+0x66/0x90
[    0.000000]  [<ffffffff810819b5>] warn_slowpath_null+0x15/0x20
[    0.000000]  [<ffffffff8113f81f>] pcpu_mem_zalloc+0x2f/0x80
[    0.000000]  [<ffffffff8114077d>] pcpu_alloc+0x28d/0xb30
[    0.000000]  [<ffffffff810de45e>] ? lock_acquired+0x2ae/0x2f0
[    0.000000]  [<ffffffff810dd248>] ? trace_hardirqs_off_caller+0x38/0xc0
[    0.000000]  [<ffffffff810ef0c0>] ? cgroup_pidlist_release+0x50/0x50
[    0.000000]  [<ffffffff811410ab>] __alloc_percpu+0xb/0x10
[    0.000000]  [<ffffffff8152d11b>] percpu_ref_init+0x2b/0x60
[    0.000000]  [<ffffffff810ee670>] init_cgroup_css.isra.24+0x30/0xc0
[    0.000000]  [<ffffffff8255b5a6>] cgroup_init_subsys+0x79/0xe9
[    0.000000]  [<ffffffff8255ba91>] cgroup_init_early+0x1af/0x1bf
[    0.000000]  [<ffffffff82541ae1>] start_kernel+0x1e/0x4a8
[    0.000000]  [<ffffffff81c1ad84>] ? memblock_reserve+0x46/0x4b
[    0.000000]  [<ffffffff825415c0>] x86_64_start_reservations+0x2a/0x2c
[    0.000000]  [<ffffffff825416ae>] x86_64_start_kernel+0xec/0xfb
[    0.000000] ---[ end trace 4eaa2a86a8e2da22 ]---

git bisect start f284b77333b1320491f138b76f11006bbc962569 f722406faae2d073cc1d01063d1123c35425939e --
git bisect good c7153d0643dd161df9e7a2fcb952418055aa5fca  # 09:39     60+  Merge tag 'driver-core-3.10-rc2' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core
git bisect good 088d812fe97a4cc8edaed69f91511ea063b14cef  # 09:54     60+  Merge tag 'for-linus-v3.10-rc3' of git://oss.sgi.com/xfs/xfs
git bisect good 977b55cf988b86cdc929fef730a78aca98a8ebdb  # 10:19     60+  Merge tag 'please-pull-aertracefix' of git://git.kernel.org/pub/scm/linux/kernel/git/ras/ras
git bisect good aa3ae6de36c86994c3446bdbc6b69ece9193732a  # 10:33     60+  Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/git/benh/powerpc
git bisect good 0ab60871b451b857206d7afc0d3033be866f76b4  # 11:01     60+  Merge tag 'jfs-3.10-rc5' of git://github.com/kleikamp/linux-shaggy
git bisect good de3c0749e2c1960afcc433fc5da136b85c8bd896  # 11:34     60+  percpu-refcount: implement percpu_tryget() along with percpu_ref_kill_and_confirm()
git bisect good cc5943a7816ba6c00639837a62131386619548dc  # 12:04     60+  cgroup: mark "notify_on_release" and "release_agent" cgroup files insane
git bisect good b5f1b7123762411e6a432f8236304e4dcaf5b4d8  # 12:26     60+  cgroup: use kzalloc() and list_del_init()
git bisect good 919e0c4a614fce2fdf8a57e5500841e18bb523e6  # 12:36     60+  cgroup: drop unnecessary RCU dancing from __put_css_set()
git bisect good fbcc713b2b109bd180688b65c3967d5a1cd46010  # 12:52     60+  cgroup: reorder the operations in cgroup_destroy_locked()
git bisect good 903c63033fff6a0f2f60b7c71831fe3b25ea9abc  # 15:34     60+  cgroup: split cgroup destruction into two steps
git bisect good 903c63033fff6a0f2f60b7c71831fe3b25ea9abc  # 19:12    180+  cgroup: split cgroup destruction into two steps
git bisect  bad f284b77333b1320491f138b76f11006bbc962569  # 19:12      0-  cgroup: use percpu refcnt for cgroup_subsys_states
git bisect good a2c764c7dbc632ab6ac48b2d833f44dce26ba1ed  # 22:43    180+  Revert "cgroup: use percpu refcnt for cgroup_subsys_states"
git bisect good 26e04462c8b78d079d3231396ec72d58a14f114b  # 00:32    180+  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect good c04efed734409f5a44715b54a6ca1b54b0ccf215  # 03:51    180+  Add linux-next specific files for 20130607

Thanks,
Fengguang

--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-kvm-lkp-nex04-41895-20130613035323-3.10.0-rc4-00064-gf284b773-57"

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] ------------[ cut here ]------------
[    0.000000] WARNING: at /c/kernel-tests/src/tip/mm/percpu.c:292 pcpu_mem_zalloc+0x2f/0x80()
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 3.10.0-rc4-00064-gf284b773 #57
[    0.000000]  0000000000000009 ffffffff82133d58 ffffffff81c259e5 ffffffff82133d98
[    0.000000]  ffffffff810818c6 ffffffff82133da8 0000000000000000 0000000000000004
[    0.000000]  0000000000000082 0000000000000004 0000000000000004 ffffffff82133da8
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff81c259e5>] dump_stack+0x19/0x1b
[    0.000000]  [<ffffffff810818c6>] warn_slowpath_common+0x66/0x90
[    0.000000]  [<ffffffff810819b5>] warn_slowpath_null+0x15/0x20
[    0.000000]  [<ffffffff8113f81f>] pcpu_mem_zalloc+0x2f/0x80
[    0.000000]  [<ffffffff8114077d>] pcpu_alloc+0x28d/0xb30
[    0.000000]  [<ffffffff810de45e>] ? lock_acquired+0x2ae/0x2f0
[    0.000000]  [<ffffffff810dd248>] ? trace_hardirqs_off_caller+0x38/0xc0
[    0.000000]  [<ffffffff810ef0c0>] ? cgroup_pidlist_release+0x50/0x50
[    0.000000]  [<ffffffff811410ab>] __alloc_percpu+0xb/0x10
[    0.000000]  [<ffffffff8152d11b>] percpu_ref_init+0x2b/0x60
[    0.000000]  [<ffffffff810ee670>] init_cgroup_css.isra.24+0x30/0xc0
[    0.000000]  [<ffffffff8255b5a6>] cgroup_init_subsys+0x79/0xe9
[    0.000000]  [<ffffffff8255ba91>] cgroup_init_early+0x1af/0x1bf
[    0.000000]  [<ffffffff82541ae1>] start_kernel+0x1e/0x4a8
[    0.000000]  [<ffffffff81c1ad84>] ? memblock_reserve+0x46/0x4b
[    0.000000]  [<ffffffff825415c0>] x86_64_start_reservations+0x2a/0x2c
[    0.000000]  [<ffffffff825416ae>] x86_64_start_kernel+0xec/0xfb
[    0.000000] ---[ end trace 4eaa2a86a8e2da22 ]---
[    0.000000] PERCPU: allocation failed, size=4 align=4, failed to allocate new chunk
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G        W    3.10.0-rc4-00064-gf284b773 #57
[    0.000000]  0000000000000004 ffffffff82133dc8 ffffffff81c259e5 ffffffff82133e78
[    0.000000]  ffffffff81140ee4 0000000000000046 0000000000000004 0000000000000000
[    0.000000]  0000000000000046 0000000000000004 ffffffff810de45e ffffffff82133e48
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff81c259e5>] dump_stack+0x19/0x1b
[    0.000000]  [<ffffffff81140ee4>] pcpu_alloc+0x9f4/0xb30
[    0.000000]  [<ffffffff810de45e>] ? lock_acquired+0x2ae/0x2f0
[    0.000000]  [<ffffffff810dd248>] ? trace_hardirqs_off_caller+0x38/0xc0
[    0.000000]  [<ffffffff810ef0c0>] ? cgroup_pidlist_release+0x50/0x50
[    0.000000]  [<ffffffff811410ab>] __alloc_percpu+0xb/0x10
[    0.000000]  [<ffffffff8152d11b>] percpu_ref_init+0x2b/0x60
[    0.000000]  [<ffffffff810ee670>] init_cgroup_css.isra.24+0x30/0xc0
[    0.000000]  [<ffffffff8255b5a6>] cgroup_init_subsys+0x79/0xe9
[    0.000000]  [<ffffffff8255ba91>] cgroup_init_early+0x1af/0x1bf
[    0.000000]  [<ffffffff82541ae1>] start_kernel+0x1e/0x4a8
[    0.000000]  [<ffffffff81c1ad84>] ? memblock_reserve+0x46/0x4b
[    0.000000]  [<ffffffff825415c0>] x86_64_start_reservations+0x2a/0x2c
[    0.000000]  [<ffffffff825416ae>] x86_64_start_kernel+0xec/0xfb
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] PERCPU: allocation failed, size=4 align=4, failed to allocate new chunk
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G        W    3.10.0-rc4-00064-gf284b773 #57
[    0.000000]  0000000000000004 ffffffff82133dc8 ffffffff81c259e5 ffffffff82133e78
[    0.000000]  ffffffff81140ee4 0000000000000046 0000000000000004 0000000000000000
[    0.000000]  0000000000000046 0000000000000004 ffffffff810de45e ffffffff82133e48
[    0.000000] Call Trace:
[    0.000000]  [<ffffffff81c259e5>] dump_stack+0x19/0x1b
[    0.000000]  [<ffffffff81140ee4>] pcpu_alloc+0x9f4/0xb30
[    0.000000]  [<ffffffff810de45e>] ? lock_acquired+0x2ae/0x2f0
[    0.000000]  [<ffffffff810dd248>] ? trace_hardirqs_off_caller+0x38/0xc0
[    0.000000]  [<ffffffff810ef0c0>] ? cgroup_pidlist_release+0x50/0x50
[    0.000000]  [<ffffffff811410ab>] __alloc_percpu+0xb/0x10
[    0.000000]  [<ffffffff8152d11b>] percpu_ref_init+0x2b/0x60
[    0.000000]  [<ffffffff810ee670>] init_cgroup_css.isra.24+0x30/0xc0
[    0.000000]  [<ffffffff8255b5a6>] cgroup_init_subsys+0x79/0xe9
[    0.000000]  [<ffffffff8255ba91>] cgroup_init_early+0x1af/0x1bf
[    0.000000]  [<ffffffff82541ae1>] start_kernel+0x1e/0x4a8
[    0.000000]  [<ffffffff81c1ad84>] ? memblock_reserve+0x46/0x4b
[    0.000000]  [<ffffffff825415c0>] x86_64_start_reservations+0x2a/0x2c
[    0.000000]  [<ffffffff825416ae>] x86_64_start_kernel+0xec/0xfb
[    0.000000] Linux version 3.10.0-rc4-00064-gf284b773 (kbuild@athens) (gcc version 4.7.2 (Debian 4.7.2-4) ) #57 SMP PREEMPT Thu Jun 13 04:58:37 CST 2013
[    0.000000] Command line: hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=/kernel-tests/run-queue/kvm/x86_64-randconfig-a02-0612/cgroup:review-css-percpu-ref/.vmlinuz-f284b77333b1320491f138b76f11006bbc962569-20130613045909-1-lkp-nex04 branch=cgroup/review-css-percpu-ref  BOOT_IMAGE=/kernel/x86_64-randconfig-a02-0612/f284b77333b1320491f138b76f11006bbc962569/vmlinuz-3.10.0-rc4-00064-gf284b773
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009f3ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009f400-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2007
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0xfffe max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 00E0000000 mask FFE0000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdae0-0x000fdaef] mapped at [ffff8800000fdae0]
[    0.000000]   mpc: fdaf0-fdbec
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x030a3000, 0x030a3fff] PGTABLE
[    0.000000] BRK [0x030a4000, 0x030a4fff] PGTABLE
[    0.000000] BRK [0x030a5000, 0x030a5fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x0e600000-0x0e7fffff]
[    0.000000]  [mem 0x0e600000-0x0e7fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0c000000-0x0e5fffff]
[    0.000000]  [mem 0x0c000000-0x0e5fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0bffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x0bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0e800000-0x0fffdfff]
[    0.000000]  [mem 0x0e800000-0x0fdfffff] page 2M
[    0.000000]  [mem 0x0fe00000-0x0fffdfff] page 4k
[    0.000000] BRK [0x030a6000, 0x030a6fff] PGTABLE
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 122632(93%)
[    0.000000] RAMDISK: [mem 0x0e8d6000-0x0ffeffff]
[    0.000000] ACPI: RSDP 00000000000fd950 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000000fffe550 00038 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000000fffff80 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000000fffe590 01121 (v01   BXPC   BXDSDT 00000001 INTL 20100528)
[    0.000000] ACPI: FACS 000000000fffff40 00040
[    0.000000] ACPI: SSDT 000000000ffffe40 000FF (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000000ffffd50 00080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000000ffffd10 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: SSDT 000000000ffff6c0 00644 (v01   BXPC BXSSDTPC 00000001 INTL 20100528)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5bb000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000000fffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x0fffdfff]
[    0.000000]   NODE_DATA [mem 0x0e0af000-0x0e0d5fff]
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:e06f001, boot clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 960 pages used for memmap
[    0.000000]   DMA32 zone: 61438 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5bb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 2, APIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 2, APIC INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 2, APIC INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 2, APIC INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 2, APIC INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 2, APIC INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 2, APIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 2, APIC INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 2, APIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 2, APIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 2, APIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 2, APIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 2, APIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 2, APIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 2, APIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5ba000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:4096 nr_cpumask_bits:2 nr_cpu_ids:2 nr_node_ids:1
[    0.000000] PERCPU: Embedded 473 pages/cpu @ffff88000da00000 s1913600 r0 d23808 u2097152
[    0.000000] pcpu-alloc: s1913600 r0 d23808 u2097152 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1 
[    0.000000] kvm-clock: cpu 0, msr 0:e06f001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr da0ce00
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 64391
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=/kernel-tests/run-queue/kvm/x86_64-randconfig-a02-0612/cgroup:review-css-percpu-ref/.vmlinuz-f284b77333b1320491f138b76f11006bbc962569-20130613045909-1-lkp-nex04 branch=cgroup/review-css-percpu-ref  BOOT_IMAGE=/kernel/x86_64-randconfig-a02-0612/f284b77333b1320491f138b76f11006bbc962569/vmlinuz-3.10.0-rc4-00064-gf284b773
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 187352k/262136k available (12517k kernel code, 392k absent, 74392k reserved, 7367k data, 3020k init)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] 
[    0.000000] 
[    0.000000] 
[    0.000000] 
[    0.000000] 
[    0.000000] 
[    0.000000] 
[    0.000000] NR_IRQS:262400 nr_irqs:56 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 6367 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] allocated 1048576 bytes of page_cgroup
[    0.000000] please try 'cgroup_disable=memory' option if you don't want memory cgroups
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2261.066 MHz processor
[    0.003333] Calibrating delay loop (skipped) preset value.. 4523.55 BogoMIPS (lpj=7536886)
[    0.006690] pid_max: default: 32768 minimum: 301
[    0.008559] Security Framework initialized
[    0.010050] AppArmor: AppArmor initialized
[    0.013441] Dentry cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.017182] Inode-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.020259] Mount-cache hash table entries: 256
[    0.024936] Initializing cgroup subsys memory
[    0.026782] Initializing cgroup subsys devices
[    0.028508] Initializing cgroup subsys freezer
[    0.030045] Initializing cgroup subsys blkio
[    0.036679] Initializing cgroup subsys perf_event
[    0.038336] Initializing cgroup subsys net_prio
[    0.040154] mce: CPU supports 10 MCE banks
[    0.041705] numa_add_cpu cpu 0 node 0: mask now 0
[    0.043354] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.043354] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.043354] tlb_flushall_shift: 6
[    0.046900] Freeing SMP alternatives: 32k freed
[    0.053149] ACPI: Core revision 20130328
[    0.058747] ACPI: All ACPI Tables successfully acquired
[    0.067397] Getting VERSION: 50014
[    0.070052] Getting VERSION: 50014
[    0.073364] Getting ID: 0
[    0.076699] Getting ID: ff000000
[    0.078353] Getting LVT0: 8700
[    0.080027] Getting LVT1: 8400
[    0.081651] enabled ExtINT on CPU#0
[    0.084992] ENABLING IO-APIC IRQs
[    0.086696] init IO_APIC IRQs
[    0.088593]  apic 2 pin 0 not connected
[    0.090051] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
[    0.093394] IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
[    0.096722] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:1)
[    0.100061] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
[    0.103387] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Active:0 Dest:1)
[    0.106759] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
[    0.110057] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
[    0.113390] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
[    0.120027] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
[    0.123405] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
[    0.126724] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
[    0.130062] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
[    0.133391] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:1)
[    0.136666] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:1)
[    0.136722] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:1)
[    0.139999]  apic 2 pin 16 not connected
[    0.140021]  apic 2 pin 17 not connected
[    0.143369]  apic 2 pin 18 not connected
[    0.146666]  apic 2 pin 19 not connected
[    0.146688]  apic 2 pin 20 not connected
[    0.150021]  apic 2 pin 21 not connected
[    0.153354]  apic 2 pin 22 not connected
[    0.156666]  apic 2 pin 23 not connected
[    0.157949] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.159999] smpboot: CPU0: Intel Common KVM processor (fam: 0f, model: 06, stepping: 01)
[    0.159999] Using local APIC timer interrupts.
[    0.159999] calibrating APIC timer ...
[    0.159999] ... lapic delta = 7916497
[    0.159999] ... PM-Timer delta = 453486
[    0.159999] APIC calibration not consistent with PM-Timer: 126ms instead of 100ms
[    0.159999] APIC delta adjusted to PM-Timer: 6248796 (7916497)
[    0.159999] TSC delta adjusted to PM-Timer: 226098763 (286440783)
[    0.159999] ..... delta 6248796
[    0.159999] ..... mult: 268383771
[    0.159999] ..... calibration result: 3332691
[    0.159999] ..... CPU clock speed is 2261.0712 MHz.
[    0.159999] ..... host bus clock speed is 999.3024 MHz.
[    0.163667] Performance Events: unsupported Netburst CPU model 6 no PMU driver, software events only.
[    0.197575] SMP alternatives: lockdep: fixing up alternatives
[    0.200052] smpboot: Booting Node   0, Processors  #1 OK
[    0.003333] kvm-clock: cpu 1, msr 0:e06f041, secondary cpu clock
[    0.003333] masked ExtINT on CPU#1
[    0.003333] numa_add_cpu cpu 1 node 0: mask now 0-1
[    0.234243] KVM setup async PF for cpu 1
[    0.234434] Brought up 2 CPUs
[    0.234438] smpboot: Total of 2 processors activated (9047.10 BogoMIPS)
[    0.236666] kvm-stealtime: cpu 1, msr dc0ce00
[    0.247123] CPU0 attaching sched-domain:
[    0.248616]  domain 0: span 0-1 level CPU
[    0.251537]   groups: 0 (cpu_power = 960) 1 (cpu_power = 1014)
[    0.256694] CPU1 attaching sched-domain:
[    0.260065]  domain 0: span 0-1 level CPU
[    0.263342]   groups: 1 (cpu_power = 1014) 0 (cpu_power = 960)
[    0.278959] EVM: security.ima
[    0.280021] EVM: security.capability
[    0.284624] regulator-dummy: no parameters
[    0.287199] NET: Registered protocol family 16
[    0.294584] ACPI: bus type PCI registered
[    0.296749] PCI: Using configuration type 1 for base access
[    0.333840] bio: create slab <bio-0> at 0
[    0.340875] ACPI: Added _OSI(Module Device)
[    0.343358] ACPI: Added _OSI(Processor Device)
[    0.345467] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.346690] ACPI: Added _OSI(Processor Aggregator Device)
[    0.354489] ACPI: EC: Look up EC in DSDT
[    0.365619] ACPI: Interpreter enabled
[    0.366697] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20130328/hwxface-568)
[    0.371216] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20130328/hwxface-568)
[    0.376166] ACPI: (supports S0 S3 S5)
[    0.376687] ACPI: Using IOAPIC for interrupt routing
[    0.380097] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.405077] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.406803] acpi PNP0A03:00: host bridge window [io  0x0000-0x0cf7] (ignored)
[    0.410022] acpi PNP0A03:00: host bridge window [io  0x0d00-0xffff] (ignored)
[    0.413355] acpi PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff] (ignored)
[    0.416691] acpi PNP0A03:00: host bridge window [mem 0xe0000000-0xfebfffff] (ignored)
[    0.420023] PCI: root bus 00: using default resources
[    0.423437] PCI host bridge to bus 0000:00
[    0.425357] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.426688] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.430024] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffffff]
[    0.433466] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.437475] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.441099] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.447616] pci 0000:00:01.1: reg 20: [io  0xc060-0xc06f]
[    0.451932] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.454088] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    0.460093] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
[    0.467150] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.476739] pci 0000:00:02.0: reg 10: [mem 0xfc000000-0xfdffffff pref]
[    0.483415] pci 0000:00:02.0: reg 14: [mem 0xfebe0000-0xfebe0fff]
[    0.523405] pci 0000:00:02.0: reg 30: [mem 0xfebc0000-0xfebcffff pref]
[    0.533800] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
[    0.543361] pci 0000:00:03.0: reg 10: [io  0xc040-0xc05f]
[    0.551664] pci 0000:00:03.0: reg 14: [mem 0xfebe1000-0xfebe1fff]
[    0.571687] pci 0000:00:03.0: reg 30: [mem 0xfebd0000-0xfebdffff pref]
[    0.578476] pci 0000:00:04.0: [8086:100e] type 00 class 0x020000
[    0.589546] pci 0000:00:04.0: reg 10: [mem 0xfeb80000-0xfeb9ffff]
[    0.598245] pci 0000:00:04.0: reg 14: [io  0xc000-0xc03f]
[    0.616690] pci 0000:00:04.0: reg 30: [mem 0xfeba0000-0xfebbffff pref]
[    0.624937] pci 0000:00:05.0: [8086:25ab] type 00 class 0x088000
[    0.631809] pci 0000:00:05.0: reg 10: [mem 0xfebe2000-0xfebe200f]
[    0.650263] acpi PNP0A03:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    0.666198] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.675464] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.683810] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.693406] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.700859] ACPI: PCI Interrupt Link [LNKS] (IRQs 9) *0
[    0.709514] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.713389] acpi root: \_SB_.PCI0 notify handler is installed
[    0.720273] Found 1 acpi root devices
[    0.731022] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.733360] vgaarb: loaded
[    0.736686] vgaarb: bridge control possible 0000:00:02.0
[    0.740538] tps65010: version 2 May 2005
[    0.770115] tps65010: no chip?
[    0.772731] SCSI subsystem initialized
[    0.773370] ACPI: bus type ATA registered
[    0.777066] libata version 3.00 loaded.
[    0.779450] pps_core: LinuxPPS API ver. 1 registered
[    0.780019] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>
[    0.786738] PTP clock support registered
[    0.793977] PCI: Using ACPI for IRQ routing
[    0.796696] PCI: pci_cache_line_size set to 64 bytes
[    0.800340] e820: reserve RAM buffer [mem 0x0009f400-0x0009ffff]
[    0.803369] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.807870] NET: Registered protocol family 23
[    0.813475] NET: Registered protocol family 8
[    0.815525] NET: Registered protocol family 20
[    0.816862] nfc: nfc_init: NFC Core ver 0.1
[    0.820142] NET: Registered protocol family 39
[    0.824113] Switching to clocksource kvm-clock
[    0.827468] FS-Cache: Loaded
[    0.829612] AppArmor: AppArmor Filesystem Enabled
[    0.832029] pnp: PnP ACPI init
[    0.833712] ACPI: bus type PNP registered
[    0.850883] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:3)
[    0.854772] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.857787] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:3)
[    0.861690] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.877731] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:3)
[    0.881596] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.884621] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:3)
[    0.888412] pnp 00:03: [dma 2]
[    0.901984] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.909355] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:3)
[    0.917509] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.923430] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:3)
[    0.926958] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.949396] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.952785] pnp: PnP ACPI: found 7 devices
[    0.954789] ACPI: bus type PNP unregistered
[    0.967178] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    0.969645] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffffff]
[    0.972626] NET: Registered protocol family 1
[    0.974886] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.977560] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.980204] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.983000] pci 0000:00:02.0: Boot video device
[    0.985216] PCI: CLS 0 bytes, default 64
[    1.001161] Trying to unpack rootfs image as initramfs...
[    5.046068] Freeing initrd memory: 23656k freed
[    5.116825] Machine check injector initialized
[    5.120000] Scanning for low memory corruption every 60 seconds
[    5.124939] camellia-x86_64: performance on this CPU would be suboptimal: disabling camellia-x86_64.
[    5.130140] blowfish-x86_64: performance on this CPU would be suboptimal: disabling blowfish-x86_64.
[    5.157521] twofish-x86_64-3way: performance on this CPU would be suboptimal: disabling twofish-x86_64-3way.
[    5.202146] sha1_ssse3: Neither AVX nor SSSE3 is available/usable.
[    5.204822] PCLMULQDQ-NI instructions are not detected.
[    5.207139] sha512_ssse3: Neither AVX nor SSSE3 is available/usable.
[    5.209708] AVX or AES-NI instructions are not detected.
[    5.211964] AVX instructions are not detected.
[    5.214015] AVX instructions are not detected.
[    5.215956] AVX2 instructions are not detected.
[    5.243933] audit: initializing netlink socket (disabled)
[    5.246558] type=2000 audit(1371066719.243:1): initialized
[    5.296636] VFS: Disk quotas dquot_6.5.2
[    5.298654] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    5.315238] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    5.320966] NTFS driver 2.1.30 [Flags: R/W].
[    5.323209] EFS: 1.0a - http://aeschi.ch.eu.org/efs/
[    5.325531] jffs2: version 2.2. 
[    5.328527] ROMFS MTD (C) 2007 Red Hat, Inc.
[    5.330750] QNX4 filesystem 0.2.3 registered.
[    5.332748] QNX6 filesystem 1.0.0 registered.
[    5.340573] fuse init (API version 7.22)
[    5.342650] SGI XFS with ACLs, security attributes, realtime, large block/inode numbers, debug enabled
[    5.373904] BeFS version: 0.9.3
[    5.375590] OCFS2 1.5.0
[    5.377570] ocfs2: Registered cluster interface o2cb
[    5.379708] OCFS2 DLMFS 1.5.0
[    5.381714] OCFS2 User DLM kernel interface loaded
[    5.384066] OCFS2 Node Manager 1.5.0
[    5.387062] OCFS2 DLM 1.5.0
[    5.402479] GFS2 installed
[    5.467947] alg: No test for crc32 (crc32-table)
[    5.470454] alg: No test for stdrng (krng)
[    5.510812] alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
[    5.513486] NET: Registered protocol family 38
[    5.515628] Key type asymmetric registered
[    5.517759] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[    5.522531] io scheduler noop registered (default)
[    5.524794] io scheduler deadline registered
[    5.526833] test_string_helpers: Running tests...
[    5.529589] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    5.532170] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    5.544147] cr_bllcd: INTEL CARILLO RANCH LPC not found.
[    5.546557] cr_bllcd: Carillo Ranch Backlight Driver Initialized.
[    5.549793] nvidiafb_setup START
[    5.551674] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[    5.578186] vmlfb: initializing
[    5.579955] no IO addresses supplied
[    5.582050] hgafb: HGA card not detected.
[    5.584025] hgafb: probe of hgafb.0 failed with error -22
[    5.587719] cirrusfb 0000:00:02.0: Cirrus Logic chipset on PCI bus, RAM (4096 kB) at 0xfc000000
[    5.591703] CL Picasso4: enable CONFIG_FB_LITTLE_ENDIAN to support this framebuffer
[    5.608324] cirrusfb 0000:00:02.0: could not register fb device; err = -38!
[    5.611373] cirrusfb: probe of 0000:00:02.0 failed with error -38
[    5.624587] uvesafb: failed to execute /sbin/v86d
[    5.626794] uvesafb: make sure that the v86d helper is installed and executable
[    5.630285] uvesafb: Getting VBE info block failed (eax=0x4f00, err=-2)
[    5.633091] uvesafb: vbe_init() failed with -22
[    5.644341] uvesafb: probe of uvesafb.0 failed with error -22
[    5.647450] ipmi message handler version 39.2
[    5.649529] ipmi device interface
[    5.651411] IPMI System Interface driver.
[    5.653519] ipmi_si: Adding default-specified kcs state machine
[    5.667211] ipmi_si: Trying default-specified kcs state machine at i/o address 0xca2, slave address 0x0, irq 0
[    5.671644] ipmi_si: Interface detection failed
[    5.683558] ipmi_si: Adding default-specified smic state machine
[    5.686341] ipmi_si: Trying default-specified smic state machine at i/o address 0xca9, slave address 0x0, irq 0
[    5.703622] ipmi_si: Interface detection failed
[    5.713516] ipmi_si: Adding default-specified bt state machine
[    5.716362] ipmi_si: Trying default-specified bt state machine at i/o address 0xe4, slave address 0x0, irq 0
[    5.720806] ipmi_si: Interface detection failed
[    5.730471] ipmi_si: Unable to find any System Interface(s)
[    5.733191] IPMI Watchdog: driver initialized
[    5.735932] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    5.739516] ACPI: Power Button [PWRF]
[    5.764593] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    5.767282] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:3)
[    5.784513] virtio-pci 0000:00:03.0: setting latency timer to 64
[    5.817444] HDLC line discipline maxframe=4096
[    5.819559] N_HDLC line discipline registered.
[    5.821841] r3964: Philips r3964 Driver $Revision: 1.10 $
[    5.824425] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    5.850924] 00:05: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    5.855928] MOXA Intellio family driver version 6.0k
[    5.858389] Initializing Nozomi driver 2.1d
[    5.860509] RocketPort device driver module, version 2.09, 12-June-2003
[    5.863503] No rocketport ports found; unloading driver
[    5.865788] SyncLink GT
[    5.867222] SyncLink GT, tty major#247
[    5.869122] SyncLink GT no devices found
[    5.871172] SyncLink MultiPort driver $Revision: 4.38 $
[    5.881792] SyncLink MultiPort driver $Revision: 4.38 $, tty major#246
[    5.884751] SyncLink serial driver $Revision: 4.38 $
[    5.912559] SyncLink serial driver $Revision: 4.38 $, tty major#245
[    5.915837] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
[    5.919065] ac.o: No PCI boards found.
[    5.921003] ac.o: For an ISA board you must supply memory and irq parameters.
[    5.937472] Non-volatile memory driver v1.3
[    5.940149] smapi::smapi_init, ERROR invalid usSmapiID
[    5.942481] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is not available on this machine
[    5.946740] mwave: mwavedd::mwave_init: Error: Failed to initialize board data
[    5.964882] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    5.967684] Linux agpgart interface v0.103
[    5.969863] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 seconds, margin is 60 seconds).
[    5.974009] Hangcheck: Using getrawmonotonic().
[    5.976608] [drm] Initialized drm 1.1.0 20060810
[    5.987796] [drm] radeon kernel modesetting enabled.
[    5.992176] [TTM] Zone  kernel: Available graphics memory: 105520 kiB
[    5.995045] [TTM] Initializing pool allocator
[    6.007328] [TTM] Initializing DMA pool allocator
[    6.015052] [drm] fb mappable at 0x0
[    6.016896] [drm] vram aper at 0x0
[    6.018592] [drm] size 0
[    6.032491] [drm] fb depth is 24
[    6.034208] [drm]    pitch is 3840
[    6.035955] cirrusdrmfb: enable CONFIG_FB_LITTLE_ENDIAN to support this framebuffer
[    6.039626] [drm] Initialized cirrus 1.0.0 20110418 for 0000:00:02.0 on minor 0
[    6.067101] brd: module loaded
[    6.079426] loop: module loaded
[    6.081253] HP CISS Driver (v 3.6.26)
[    6.086905] mtip32xx Version 1.2.6os3
[    6.089089] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[    6.092558] lkdtm: No crash points registered, enable through debugfs
[    6.095837] Phantom Linux Driver, version n0.9.8, init OK
[    6.098865] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Giometti
[    6.102334] c2port c2port0: C2 port uc added
[    6.104300] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 bytes total)
[    6.108638] Uniform Multi-Platform E-IDE driver
[    6.110907] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[    6.113992] piix 0000:00:01.1: not 100% native mode: will probe irqs later
[    6.117073] pci 0000:00:01.1: setting latency timer to 64
[    6.119719]     ide0: BM-DMA at 0xc060-0xc067
[    6.122180]     ide1: BM-DMA at 0xc068-0xc06f
[    6.122614] tsc: Refined TSC clocksource calibration: 2260.997 MHz
[    6.127293] Probing IDE interface ide0...
[    6.670394] Probing IDE interface ide1...
[    7.373867] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
[    8.023723] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[    8.026604] hdc: MWDMA2 mode selected
[    8.028692] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    8.030992] ide1 at 0x170-0x177,0x376 on irq 15
[    8.034643] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
[    8.053578] ide-gd driver 1.18
[    8.055126] ide-cd driver 5.00
[    8.057465] ide-cd: hdc: ATAPI 4X DVD-ROM drive, 512kB Cache
[    8.060711] cdrom: Uniform CD-ROM driver Revision: 3.20
[    8.069040] Loading iSCSI transport class v2.0-870.
[    8.079553] rdac: device handler registered
[    8.084355] hp_sw: device handler registered
[    8.086403] emc: device handler registered
[    8.089658] alua: device handler registered
[    8.092946] osst :I: Tape driver with OnStream support version 0.99.4
[    8.092946] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    8.126165] Rounding down aligned max_sectors from 4294967295 to 4294967288
[    8.148963] SSFDC read-only Flash Translation layer
[    8.167632] L440GX flash mapping: failed to find PIIX4 ISA bridge, cannot continue
[    8.171622] device id = 2440
[    8.173103] device id = 2480
[    8.174932] device id = 24c0
[    8.176465] device id = 24d0
[    8.178250] device id = 25a1
[    8.179817] device id = 2670
[    8.181708] Could not find PAR responsible for SC520CDP Flash Bank #0
[    8.184699] Trying default address 0x8400000
[    8.187201] Could not find PAR responsible for SC520CDP Flash Bank #1
[    8.190610] Trying default address 0x8c00000
[    8.192929] Could not find PAR responsible for SC520CDP DIL Flash
[    8.195916] Trying default address 0x9400000
[    8.198077] SC520 CDP flash device: 0x800000 at 0x8400000
[    8.200687] Failed to ioremap_nocache
[    8.202625] NetSc520 flash device: 0x100000 at 0x200000
[    8.205179] Failed to ioremap_nocache
[    8.207162] Failed to ioremap_nocache
[    8.209793] Ramix PMC551 PCI Mezzanine Ram Driver. (C) 1999,2000 Nortel Networks.
[    8.213879] pmc551: not detected
[    8.217826] ftl_cs: FTL header not found.
[    8.267254] No valid DiskOnChip devices found
[    8.269692] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    8.274194] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    8.285901] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    8.290914] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    8.295585] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    8.300154] [nandsim] warning: read_byte: unexpected data output cycle, state is STATE_READY return 0x0
[    8.304608] NAND device: Manufacturer ID: 0x98, Chip ID: 0x39 (Toshiba NAND 128MiB 1,8V 8-bit), 128MiB, page size: 512, OOB size: 16
[    8.310223] flash size: 128 MiB
[    8.311930] page size: 512 bytes
[    8.314038] OOB area size: 16 bytes
[    8.316027] sector size: 16 KiB
[    8.318234] pages number: 262144
[    8.320273] pages per sector: 32
[    8.322051] bus width: 8
[    8.323645] bits in sector size: 14
[    8.325444] bits in page size: 9
[    8.327234] bits in OOB size: 4
[    8.329006] flash size with OOB: 135168 KiB
[    8.331135] page address bytes: 4
[    8.332932] sector address bytes: 3
[    8.336845] options: 0x42
[    8.343661] Scanning device for bad blocks
[    8.457865] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[    8.463849] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[    8.473475] ftl_cs: FTL header not found.
[    8.506095] HSI/SSI char device loaded
[    8.509345] spi_ks8995: Micrel KS8995 Ethernet switch SPI driver version 0.1.1
[    8.512827] vcan: Virtual CAN interface driver
[    8.514934] slcan: serial line CAN interface driver
[    8.517186] slcan: 10 dynamic interface channels.
[    8.519424] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[    8.534728] YAM driver version 0.8 by F1OAT/F6FBB
[    8.538333] AX.25: bpqether driver version 004
[    8.540466] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    8.540466] baycom_ser_fdx: version 0.10
[    8.559443] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[    8.561954] hdlcdrv: version 0.8
[    8.564807] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=256).
[    8.600997] Generic UIO driver for PCI 2.3 devices version: 0.01.0
[    8.607834] aoe: AoE v81 initialised.
[    8.610136] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    8.615219] serio: i8042 KBD port at 0x60,0x64 irq 1
[    8.617598] serio: i8042 AUX port at 0x60,0x64 irq 12
[    8.632085] mousedev: PS/2 mouse device common for all mice
[    8.634495] evbug: Connected device: input0 (Power Button at LNXPWRBN/button/input0)
[    8.638650] apanel: Fujitsu BIOS signature 'FJKEYINF' not found...
[    8.641817] input: PC Speaker as /devices/platform/pcspkr/input/input1
[    8.644746] evbug: Connected device: input1 (PC Speaker at isa0061/input0)
[    8.648129] I2O subsystem v1.325
[    8.648979] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input2
[    8.649097] evbug: Connected device: input2 (AT Translated Set 2 keyboard at isa0060/serio0/input0)
[    8.658116] i2o: max drivers = 8
[    8.673490] I2O Block Device OSM v1.325
[    8.675937] I2O ProcFS OSM v1.316
[    8.679546] rtc-test rtc-test.0: rtc core: registered test as rtc0
[    8.688562] rtc-test rtc-test.1: rtc core: registered test as rtc1
[    8.692099] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, revision 0
[    8.797789] pps pps0: new PPS source ktimer
[    8.799796] pps pps0: ktimer PPS source registered
[    8.802085] Driver for 1-wire Dallas network protocol.
[    8.804679] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    8.807631] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 2004-2005, Szabolcs Gyurko
[    8.811858] power_supply test_ac: uevent
[    8.813767] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[    8.816215] power_supply test_ac: prop ONLINE=1
[    8.830523] power_supply test_ac: power_supply_changed
[    8.832823] power_supply test_ac: power_supply_changed_work
[    8.835356] power_supply test_ac: uevent
[    8.840075] power_supply test_ac: POWER_SUPPLY_NAME=test_ac
[    8.842443] power_supply test_ac: prop ONLINE=1
[    8.854496] power_supply test_battery: uevent
[    8.856527] power_supply test_battery: POWER_SUPPLY_NAME=test_battery
[    8.859375] power_supply test_battery: prop STATUS=Discharging
[    8.861962] power_supply test_battery: prop CHARGE_TYPE=Fast
[    8.864444] power_supply test_battery: prop HEALTH=Good
[    8.866794] power_supply test_battery: prop PRESENT=1
[    8.878045] power_supply test_battery: prop TECHNOLOGY=Li-ion
[    8.880613] power_supply test_battery: prop CHARGE_FULL_DESIGN=100
[    8.883295] power_supply test_battery: prop CHARGE_FULL=100
[    8.895975] power_supply test_battery: prop CHARGE_NOW=50
[    8.898378] power_supply test_battery: prop CAPACITY=50
[    8.900744] power_supply test_battery: prop CAPACITY_LEVEL=Normal
[    8.903404] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3600
[    8.916933] power_supply test_battery: prop TIME_TO_FULL_NOW=3600
[    8.921690] power_supply test_battery: prop MODEL_NAME=Test battery
[    8.926782] power_supply test_battery: prop MANUFACTURER=Linux
[    8.932539] power_supply test_battery: prop SERIAL_NUMBER=3.10.0-rc4-00064-gf284b773
[    8.940418] power_supply test_battery: prop TEMP=26
[    8.948700] power_supply test_battery: prop VOLTAGE_NOW=3300
[    8.951818] power_supply test_battery: power_supply_changed
[    8.956460] power_supply test_battery: power_supply_changed_work
[    8.962251] power_supply test_battery: uevent
[    8.962918] power_supply test_usb: uevent
[    8.962921] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[    8.962932] power_supply test_usb: prop ONLINE=1
[    8.962970] power_supply test_usb: power_supply_changed
[    8.963031] power_supply test_usb: power_supply_changed_work
[    8.963044] power_supply test_usb: uevent
[    8.963046] power_supply test_usb: POWER_SUPPLY_NAME=test_usb
[    8.963054] power_supply test_usb: prop ONLINE=1
[    9.006117] power_supply test_battery: POWER_SUPPLY_NAME=test_battery
[    9.009980] power_supply test_battery: prop STATUS=Discharging
[    9.015617] power_supply test_battery: prop CHARGE_TYPE=Fast
[    9.019780] power_supply test_battery: prop HEALTH=Good
[    9.025586] power_supply test_battery: prop PRESENT=1
[    9.035991] power_supply test_battery: prop TECHNOLOGY=Li-ion
[    9.038561] power_supply test_battery: prop CHARGE_FULL_DESIGN=100
[    9.041271] power_supply test_battery: prop CHARGE_FULL=100
[    9.043706] power_supply test_battery: prop CHARGE_NOW=50
[    9.046109] power_supply test_battery: prop CAPACITY=50
[    9.051495] power_supply test_battery: prop CAPACITY_LEVEL=Normal
[    9.057534] power_supply test_battery: prop TIME_TO_EMPTY_AVG=3600
[    9.072911] power_supply test_battery: prop TIME_TO_FULL_NOW=3600
[    9.073153] w83793: Detection failed at check vendor id
[    9.081124] power_supply test_battery: prop MODEL_NAME=Test battery
[    9.094886] power_supply test_battery: prop MANUFACTURER=Linux
[    9.097552] power_supply test_battery: prop SERIAL_NUMBER=3.10.0-rc4-00064-gf284b773
[    9.101221] power_supply test_battery: prop TEMP=26
[    9.103458] power_supply test_battery: prop VOLTAGE_NOW=3300
[    9.111651] w83793: Detection failed at check vendor id
[    9.140138] w83793: Detection failed at check vendor id
[    9.167018] w83793: Detection failed at check vendor id
[    9.184358] i2c i2c-0: w83795: Detection failed at addr 0x2c, check bank
[    9.227302] i2c i2c-0: w83795: Detection failed at addr 0x2d, check bank
[    9.286599] i2c i2c-0: w83795: Detection failed at addr 0x2e, check bank
[    9.316961] i2c i2c-0: w83795: Detection failed at addr 0x2f, check bank
[    9.400177] detect failed, chip not detected!
[    9.427117] detect failed, chip not detected!
[    9.454217] detect failed, chip not detected!
[    9.480158] detect failed, chip not detected!
[    9.506807] detect failed, chip not detected!
[    9.533464] detect failed, chip not detected!
[    9.560944] detect failed, chip not detected!
[    9.587298] detect failed, chip not detected!
[    9.613472] detect failed, chip not detected!
[    9.626815] i2c i2c-0: ADM1025 detection failed at 0x2c
[    9.641838] i2c i2c-0: ADM1025 detection failed at 0x2d
[    9.657372] i2c i2c-0: ADM1025 detection failed at 0x2e
[    9.676986] i2c i2c-0: Detecting device at 0,0x2c with COMPANY: 0xff and VERSTEP: 0xff
[    9.680500] i2c i2c-0: Autodetecting device at 0,0x2c...
[    9.682727] i2c i2c-0: Autodetection failed
[    9.705417] i2c i2c-0: Detecting device at 0,0x2d with COMPANY: 0xff and VERSTEP: 0xff
[    9.709006] i2c i2c-0: Autodetecting device at 0,0x2d...
[    9.711437] i2c i2c-0: Autodetection failed
[    9.735317] i2c i2c-0: Detecting device at 0,0x2e with COMPANY: 0xff and VERSTEP: 0xff
[    9.738882] i2c i2c-0: Autodetecting device at 0,0x2e...
[    9.741263] i2c i2c-0: Autodetection failed
[   10.094591] i2c i2c-0: detect fail: address match, 0x2c
[   10.114513] i2c i2c-0: detect fail: address match, 0x2d
[   10.136066] i2c i2c-0: detect fail: address match, 0x2e
[   10.154715] i2c i2c-0: detect fail: address match, 0x2f
[   10.480264] f71882fg: Not a Fintek device
[   10.482458] f71882fg: Not a Fintek device
[   10.616840]  (null): Unknown chip type, skipping
[   10.630152]  (null): Unknown chip type, skipping
[   15.703478] i2c i2c-0: LM83 detection failed at 0x18
[   15.716866] i2c i2c-0: LM83 detection failed at 0x19
[   15.730176] i2c i2c-0: LM83 detection failed at 0x1a
[   15.743477] i2c i2c-0: LM83 detection failed at 0x29
[   15.756860] i2c i2c-0: LM83 detection failed at 0x2a
[   15.770163] i2c i2c-0: LM83 detection failed at 0x2b
[   15.783477] i2c i2c-0: LM83 detection failed at 0x4c
[   15.796854] i2c i2c-0: LM83 detection failed at 0x4d
[   15.810191] i2c i2c-0: LM83 detection failed at 0x4e
[   15.830168] i2c i2c-0: Detecting device at 0x2c with COMPANY: 0xff and VERSTEP: 0xff
[   15.840893] i2c i2c-0: Autodetection failed: unsupported version
[   15.863462] i2c i2c-0: Detecting device at 0x2d with COMPANY: 0xff and VERSTEP: 0xff
[   15.867568] i2c i2c-0: Autodetection failed: unsupported version
[   15.890142] i2c i2c-0: Detecting device at 0x2e with COMPANY: 0xff and VERSTEP: 0xff
[   15.894884] i2c i2c-0: Autodetection failed: unsupported version
[   16.140164] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   16.157097] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   16.174286] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   16.320324] i2c i2c-0: MAX1619 detection failed at 0x18
[   16.346884] i2c i2c-0: MAX1619 detection failed at 0x19
[   16.373784] i2c i2c-0: MAX1619 detection failed at 0x1a
[   16.400794] i2c i2c-0: MAX1619 detection failed at 0x29
[   16.427333] i2c i2c-0: MAX1619 detection failed at 0x2a
[   16.453531] i2c i2c-0: MAX1619 detection failed at 0x2b
[   16.480129] i2c i2c-0: MAX1619 detection failed at 0x4c
[   16.506944] i2c i2c-0: MAX1619 detection failed at 0x4d
[   16.534077] i2c i2c-0: MAX1619 detection failed at 0x4e
[   16.707410] pc87360: PC8736x not detected, module not inserted
[   16.716842] thmc50: Probing for THMC50 at 0x2C on bus 0
[   16.743468] thmc50: Probing for THMC50 at 0x2D on bus 0
[   16.770124] thmc50: Probing for THMC50 at 0x2E on bus 0
[   16.870148] i2c i2c-0: w83l785ts: Read 0xff from register 0x40.
[   16.872602] i2c i2c-0: W83L785TS-S detection failed at 0x2e
[   16.886817] i2c i2c-0: W83L786NG detection failed at 0x2e
[   16.900133] i2c i2c-0: W83L786NG detection failed at 0x2f
[   16.903063] cpuidle: using governor ladder
[   16.905039] sdhci: Secure Digital Host Controller Interface driver
[   16.907588] sdhci: Copyright(c) Pierre Ossman
[   16.909662] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   16.912326] wbsd: Copyright(c) Pierre Ossman
[   16.916822] sdhci-pltfm: SDHCI platform and OF driver helper
[   20.626227]  (null): enodev DEV ADDR = 0xFF
[   20.631298] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   20.634906] hidraw: raw HID events driver (C) Jiri Kosina
[   20.638751] NET: Registered protocol family 26
[   20.659226] NET: Registered protocol family 17
[   20.661467] NET: Registered protocol family 9
[   20.663431] X.25 for Linux Version 0.2
[   20.666401] NET: Registered protocol family 6
[   20.671539] NET: Registered protocol family 11
[   20.673594] NET: Registered protocol family 3
[   20.675527] can: controller area network core (rev 20120528 abi 9)
[   20.678235] NET: Registered protocol family 29
[   20.680153] can: raw protocol (rev 20120528)
[   20.682486] IrCOMM protocol (Dag Brattli)
[   20.686155] 8021q: 802.1Q VLAN Support v1.8
[   20.688279] 9pnet: Installing 9P2000 support
[   20.690419] NET: Registered protocol family 36
[   20.693664] batman_adv: B.A.T.M.A.N. advanced 2013.2.0 (compatibility version 14) loaded
[   20.702797] openvswitch: Open vSwitch switching datapath
[   20.711633] 
[   20.711633] printing PIC contents
[   20.715759] ... PIC  IMR: ffff
[   20.718813] ... PIC  IRR: 9013
[   20.722601] ... PIC  ISR: 0000
[   20.726359] ... PIC ELCR: 0c00
[   20.729123] printing local APIC contents on CPU#0/0:
[   20.731301] ... APIC ID:      00000000 (0)
[   20.732439] ... APIC VERSION: 00050014
[   20.732439] ... APIC TASKPRI: 00000000 (00)
[   20.732439] ... APIC PROCPRI: 00000000
[   20.732439] ... APIC LDR: 01000000
[   20.732439] ... APIC DFR: ffffffff
[   20.732439] ... APIC SPIV: 000001ff
[   20.732439] ... APIC ISR field:
[   20.732439] 0000000000000000000000000000000000000000000000000000000000000000
[   20.732439] ... APIC TMR field:
[   20.732439] 0000000000000000000000000000000000000000000000000000000000000000
[   20.732439] ... APIC IRR field:
[   20.732439] 0000000000000000000000000000000000000000000000000000000000000000
[   20.732439] ... APIC ESR: 00000000
[   20.732439] ... APIC ICR: 000008fd
[   20.732439] ... APIC ICR2: 02000000
[   20.732439] ... APIC LVTT: 000000ef
[   20.732439] ... APIC LVTPC: 00010000
[   20.732439] ... APIC LVT0: 00010700
[   20.732439] ... APIC LVT1: 00000400
[   20.732439] ... APIC LVTERR: 000000fe
[   20.732439] ... APIC TMICT: 008566dc
[   20.732439] ... APIC TMCCT: 001972c8
[   20.732439] ... APIC TDCR: 00000003
[   20.732439] 
[   20.814438] number of MP IRQ sources: 15.
[   20.822807] number of IO-APIC #2 registers: 24.
[   20.827068] testing the IO APIC.......................
[   20.832651] IO APIC #2......
[   20.835222] .... register #00: 00000000
[   20.838416] .......    : physical APIC id: 00
[   20.842672] .......    : Delivery Type: 0
[   20.846726] .......    : LTS          : 0
[   20.850774] .... register #01: 00170011
[   20.854753] .......     : max redirection entries: 17
[   20.859150] .......     : PRQ implemented: 0
[   20.863399] .......     : IO APIC version: 11
[   20.865975] .... register #02: 00000000
[   20.867913] .......     : arbitration: 00
[   20.876139] .... IRQ redirection table:
[   20.880148] 1    0    0   0   0    0    0    00
[   20.884352] 0    0    0   0   0    1    1    31
[   20.889661] 0    0    0   0   0    1    1    30
[   20.894063] 0    0    0   0   0    1    1    33
[   20.898372] 1    0    0   0   0    1    1    34
[   20.900491] 1    1    0   0   0    1    1    35
[   20.902599] 0    0    0   0   0    1    1    36
[   20.907320] 0    0    0   0   0    1    1    37
[   20.911711] 0    0    0   0   0    1    1    38
[   20.915963] 0    1    0   0   0    1    1    39
[   20.920886] 1    1    0   0   0    1    1    3A
[   20.929182] 1    1    0   0   0    1    1    3B
[   20.932390] 0    0    0   0   0    1    1    3C
[   20.934497] 0    0    0   0   0    1    1    3D
[   20.937681] 0    0    0   0   0    1    1    3E
[   20.947100] 0    0    0   0   0    1    1    3F
[   20.951191] 1    0    0   0   0    0    0    00
[   20.954482] 1    0    0   0   0    0    0    00
[   20.956989] 1    0    0   0   0    0    0    00
[   20.960346] 1    0    0   0   0    0    0    00
[   20.965149] 1    0    0   0   0    0    0    00
[   20.973599] 1    0    0   0   0    0    0    00
[   20.975938] 1    0    0   0   0    0    0    00
[   20.978808] 1    0    0   0   0    0    0    00
[   20.981022] IRQ to pin mappings:
[   20.982814] IRQ0 -> 0:2
[   20.988168] IRQ1 -> 0:1
[   20.989872] IRQ3 -> 0:3
[   20.995173] IRQ4 -> 0:4
[   20.997590] IRQ5 -> 0:5
[   21.002915] IRQ6 -> 0:6
[   21.005639] IRQ7 -> 0:7
[   21.007455] IRQ8 -> 0:8
[   21.012741] IRQ9 -> 0:9
[   21.014543] IRQ10 -> 0:10
[   21.019809] IRQ11 -> 0:11
[   21.021788] IRQ12 -> 0:12
[   21.023611] IRQ13 -> 0:13
[   21.025538] IRQ14 -> 0:14
[   21.032426] IRQ15 -> 0:15
[   21.034338] .................................... done.
[   21.038398] registered taskstats version 1
[   21.041935] Key type trusted registered
[   21.048188] Key type encrypted registered
[   21.053781] IMA: No TPM chip found, activating TPM-bypass!
[   21.064116] register_blkdev: cannot get major 3 for hd
[   21.071386] rtc-test rtc-test.0: setting system clock to 2013-06-12 19:52:15 UTC (1371066735)
[   21.081757] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   21.087879] EDD information not available.
[   21.099357] Freeing unused kernel memory: 3020k freed
[   35.125005] CPA self-test:
[   35.126656]  4k 1022 large 126 gb 0 x 1[ffff88000009a000-ffff88000009a000] miss 0
[   35.365059]  4k 62974 large 5 gb 0 x 1[ffff88000009a000-ffff88000009a000] miss 0
[   35.540007]  4k 62974 large 5 gb 0 x 1[ffff88000009a000-ffff88000009a000] miss 0
[   35.544317] ok.
[   86.883187] Unregister pv shared memory for cpu 0
[   86.885706] Unregister pv shared memory for cpu 1
[   86.891975] Disabling non-boot CPUs ...
[   86.924849] CPU0 attaching NULL sched-domain.
[   86.926548] CPU1 attaching NULL sched-domain.
[   86.932541] CPU0 attaching NULL sched-domain.
[   86.934992] numa_remove_cpu cpu 1 node 0: mask now 0
[   86.940352] Restarting system.
[   86.941987] reboot: machine restart
Elapsed time: 115

--6TrnltStXW4iwmi0
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="bisect-f284b77333b1320491f138b76f11006bbc962569-x86_64-randconfig-a02-0612-pcpu_mem_zalloc-68419.log"
Content-Transfer-Encoding: base64

Z2l0IGNoZWNrb3V0IGY3MjI0MDZmYWFlMmQwNzNjYzFkMDEwNjNkMTEyM2MzNTQyNTkzOWUK
UHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgZjI4NGI3Ny4uLiBjZ3JvdXA6IHVzZSBwZXJj
cHUgcmVmY250IGZvciBjZ3JvdXBfc3Vic3lzX3N0YXRlcwpIRUFEIGlzIG5vdyBhdCBmNzIy
NDA2Li4uIExpbnV4IDMuMTAtcmMxCmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2
bS94ODZfNjQtcmFuZGNvbmZpZy1hMDItMDYxMi9jZ3JvdXA6cmV2aWV3LWNzcy1wZXJjcHUt
cmVmOmY3MjI0MDZmYWFlMmQwNzNjYzFkMDEwNjNkMTEyM2MzNTQyNTkzOWU6YmlzZWN0LWxp
bnV4CgoyMDEzLTA2LTEzLTA5OjA2OjM3IGY3MjI0MDZmYWFlMmQwNzNjYzFkMDEwNjNkMTEy
M2MzNTQyNTkzOWUgcmV1c2UgL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMDItMDYxMi9m
NzIyNDA2ZmFhZTJkMDczY2MxZDAxMDYzZDExMjNjMzU0MjU5MzllL3ZtbGludXotMy4xMC4w
LXJjMQoKMjAxMy0wNi0xMy0wOTowNjozNyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4uLgkx
CTIJNAk2CTcJMTAJMTEJMTMJMTguLgkyMS4uCTI1LgkyNgkyNy4JMzAJMzIuLgkzMy4JMzQu
CTM2CTQxCTQ3CTUwCTUzCTU2CTU4CTYwIFNVQ0NFU1MKCmJpc2VjdDogZ29vZCBjb21taXQg
ZjcyMjQwNmZhYWUyZDA3M2NjMWQwMTA2M2QxMTIzYzM1NDI1OTM5ZQpnaXQgYmlzZWN0IHN0
YXJ0IGYyODRiNzczMzNiMTMyMDQ5MWYxMzhiNzZmMTEwMDZiYmM5NjI1NjkgZjcyMjQwNmZh
YWUyZDA3M2NjMWQwMTA2M2QxMTIzYzM1NDI1OTM5ZSAtLQpQcmV2aW91cyBIRUFEIHBvc2l0
aW9uIHdhcyBmNzIyNDA2Li4uIExpbnV4IDMuMTAtcmMxClN3aXRjaGVkIHRvIGJyYW5jaCAn
bWFzdGVyJwpZb3VyIGJyYW5jaCBpcyBiZWhpbmQgJ29yaWdpbi9tYXN0ZXInIGJ5IDMwNDgg
Y29tbWl0cywgYW5kIGNhbiBiZSBmYXN0LWZvcndhcmRlZC4KQmlzZWN0aW5nOiA1ODQgcmV2
aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDkgc3RlcHMpCltjNzE1
M2QwNjQzZGQxNjFkZjllN2EyZmNiOTUyNDE4MDU1YWE1ZmNhXSBNZXJnZSB0YWcgJ2RyaXZl
ci1jb3JlLTMuMTAtcmMyJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4
L2tlcm5lbC9naXQvZ3JlZ2toL2RyaXZlci1jb3JlCmdpdCBiaXNlY3QgcnVuIC9jL2tlcm5l
bC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmot
YmlzZWN0CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVy
ZS5zaCAvaG9tZS93ZmcvbmV0L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4t
cXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWEwMi0wNjEyL2Nncm91cDpyZXZpZXctY3Nz
LXBlcmNwdS1yZWY6YzcxNTNkMDY0M2RkMTYxZGY5ZTdhMmZjYjk1MjQxODA1NWFhNWZjYTpi
aXNlY3QtbGludXgKCjIwMTMtMDYtMTMtMDk6Mjc6MDUgYzcxNTNkMDY0M2RkMTYxZGY5ZTdh
MmZjYjk1MjQxODA1NWFhNWZjYSBjb21waWxpbmcKMTgyIHJlYWwgIDE2MzUgdXNlciAgMTQx
IHN5cyAgOTc1LjQ5JSBjcHUgCXg4Nl82NC1yYW5kY29uZmlnLWEwMi0wNjEyCgoyMDEzLTA2
LTEzLTA5OjMwOjIzIGRldGVjdGluZyBib290IHN0YXRlIDMuMTAuMC1yYzItMDAxNjMtZ2M3
MTUzZDAuLi4JNQk3CTEzCTIwCTIxCTI1CTI2CTI5CTMyCTM2CTQzLgk1MAk1NAk1OAk2MCBT
VUNDRVNTCgpCaXNlY3Rpbmc6IDI5MSByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRo
aXMgKHJvdWdobHkgOCBzdGVwcykKWzA4OGQ4MTJmZTk3YTRjYzhlZGFlZDY5ZjkxNTExZWEw
NjNiMTRjZWZdIE1lcmdlIHRhZyAnZm9yLWxpbnVzLXYzLjEwLXJjMycgb2YgZ2l0Oi8vb3Nz
LnNnaS5jb20veGZzL3hmcwpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1i
b290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwt
dGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1hMDItMDYxMi9jZ3JvdXA6
cmV2aWV3LWNzcy1wZXJjcHUtcmVmOjA4OGQ4MTJmZTk3YTRjYzhlZGFlZDY5ZjkxNTExZWEw
NjNiMTRjZWY6YmlzZWN0LWxpbnV4CgoyMDEzLTA2LTEzLTA5OjM5OjU5IDA4OGQ4MTJmZTk3
YTRjYzhlZGFlZDY5ZjkxNTExZWEwNjNiMTRjZWYgY29tcGlsaW5nCjE3OCByZWFsICAxNjYx
IHVzZXIgIDE0NiBzeXMgIDEwMTQuOTQlIGNwdSAJeDg2XzY0LXJhbmRjb25maWctYTAyLTA2
MTIKCjIwMTMtMDYtMTMtMDk6NDM6MTEgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMC4wLXJj
Mi0wMDQ1Ni1nMDg4ZDgxMi4uLgk0CTYJNwk5CTEyLgkxNgkxOQkyOQkzMwkzNgkzOAk0Mwk1
Mwk1NAk1Ny4uCTU4CTYwIFNVQ0NFU1MKCkJpc2VjdGluZzogMTQ1IHJldmlzaW9ucyBsZWZ0
IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA3IHN0ZXBzKQpbOTc3YjU1Y2Y5ODhiODZj
ZGM5MjlmZWY3MzBhNzhhY2E5OGE4ZWJkYl0gTWVyZ2UgdGFnICdwbGVhc2UtcHVsbC1hZXJ0
cmFjZWZpeCcgb2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwv
Z2l0L3Jhcy9yYXMKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1m
YWlsdXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3Rz
L3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWctYTAyLTA2MTIvY2dyb3VwOnJldmll
dy1jc3MtcGVyY3B1LXJlZjo5NzdiNTVjZjk4OGI4NmNkYzkyOWZlZjczMGE3OGFjYTk4YThl
YmRiOmJpc2VjdC1saW51eAoKMjAxMy0wNi0xMy0wOTo1NDo0NCA5NzdiNTVjZjk4OGI4NmNk
YzkyOWZlZjczMGE3OGFjYTk4YThlYmRiIGNvbXBpbGluZwoxNjQgcmVhbCAgMTYzNiB1c2Vy
ICAxNDIgc3lzICAxMDc5LjM4JSBjcHUgCXg4Nl82NC1yYW5kY29uZmlnLWEwMi0wNjEyCgoy
MDEzLTA2LTEzLTA5OjU3OjQ1IGRldGVjdGluZyBib290IHN0YXRlIDMuMTAuMC1yYzMtMDAx
MjYtZzk3N2I1NWMuLi4uCTMJOQkxMAkxMQkxNAkxNQkyNAkyNwkyOAkyOS4JMzAJMzUJNDEJ
NDUJNDYJNDcJNTIJNTkuLi4uLi4uLi4uLi4uLi4uLi4uLgk2MCBTVUNDRVNTCgpCaXNlY3Rp
bmc6IDc0IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA2IHN0
ZXBzKQpbYWEzYWU2ZGUzNmM4Njk5NGMzNDQ2YmRiYzZiNjllY2U5MTkzNzMyYV0gTWVyZ2Ug
YnJhbmNoICdtZXJnZScgb2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9r
ZXJuZWwvZ2l0L2JlbmgvcG93ZXJwYwpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3Qt
dGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmotYmlzZWN0CmxzIC1hIC9r
ZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1hMDItMDYxMi9j
Z3JvdXA6cmV2aWV3LWNzcy1wZXJjcHUtcmVmOmFhM2FlNmRlMzZjODY5OTRjMzQ0NmJkYmM2
YjY5ZWNlOTE5MzczMmE6YmlzZWN0LWxpbnV4CgoyMDEzLTA2LTEzLTEwOjE5OjUwIGFhM2Fl
NmRlMzZjODY5OTRjMzQ0NmJkYmM2YjY5ZWNlOTE5MzczMmEgY29tcGlsaW5nCjE3NSByZWFs
ICAxNjM4IHVzZXIgIDE0MiBzeXMgIDEwMTQuOTMlIGNwdSAJeDg2XzY0LXJhbmRjb25maWct
YTAyLTA2MTIKCjIwMTMtMDYtMTMtMTA6MjM6MDEgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4x
MC4wLXJjMy0wMDE5Ny1nYWEzYWU2ZC4uLgkxCTMJNAkxMwkxOQkyNAkyNQkyOAkzMQkzNQkz
OAkzOQk0MAk0Ngk1Mgk1Nwk1OQk2MCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDM5IHJldmlzaW9u
cyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA1IHN0ZXBzKQpbMGFiNjA4NzFi
NDUxYjg1NzIwNmQ3YWZjMGQzMDMzYmU4NjZmNzZiNF0gTWVyZ2UgdGFnICdqZnMtMy4xMC1y
YzUnIG9mIGdpdDovL2dpdGh1Yi5jb20va2xlaWthbXAvbGludXgtc2hhZ2d5CnJ1bm5pbmcg
L2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93Zmcv
bmV0L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82
NC1yYW5kY29uZmlnLWEwMi0wNjEyL2Nncm91cDpyZXZpZXctY3NzLXBlcmNwdS1yZWY6MGFi
NjA4NzFiNDUxYjg1NzIwNmQ3YWZjMGQzMDMzYmU4NjZmNzZiNDpiaXNlY3QtbGludXgKCjIw
MTMtMDYtMTMtMTA6MzM6MzUgMGFiNjA4NzFiNDUxYjg1NzIwNmQ3YWZjMGQzMDMzYmU4NjZm
NzZiNCBjb21waWxpbmcKMzExIHJlYWwgIDE2MzkgdXNlciAgMTQyIHN5cyAgNTcyLjA4JSBj
cHUgCXg4Nl82NC1yYW5kY29uZmlnLWEwMi0wNjEyCgoyMDEzLTA2LTEzLTEwOjQyOjM5IGRl
dGVjdGluZyBib290IHN0YXRlIDMuMTAuMC1yYzQtMDAwMjQtZzBhYjYwODcuLi4uCTEJMwk0
CTUuLgkxMAkxNy4JMTgJMjIJMjMJMjQJMzIJMzQuCTM3CTM4Lgk0Mgk0NQk0Ngk0Nwk1Mgk1
Mwk1Ni4JNTcuCTU4CTU5Li4JNjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiAyNCByZXZpc2lvbnMg
bGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgNCBzdGVwcykKW2RlM2MwNzQ5ZTJj
MTk2MGFmY2M0MzNmYzVkYTEzNmI4NWM4YmQ4OTZdIHBlcmNwdS1yZWZjb3VudDogaW1wbGVt
ZW50IHBlcmNwdV90cnlnZXQoKSBhbG9uZyB3aXRoIHBlcmNwdV9yZWZfa2lsbF9hbmRfY29u
ZmlybSgpCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVy
ZS5zaCAvaG9tZS93ZmcvbmV0L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4t
cXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWEwMi0wNjEyL2Nncm91cDpyZXZpZXctY3Nz
LXBlcmNwdS1yZWY6ZGUzYzA3NDllMmMxOTYwYWZjYzQzM2ZjNWRhMTM2Yjg1YzhiZDg5Njpi
aXNlY3QtbGludXgKCjIwMTMtMDYtMTMtMTE6MDE6NDUgZGUzYzA3NDllMmMxOTYwYWZjYzQz
M2ZjNWRhMTM2Yjg1YzhiZDg5NiBjb21waWxpbmcKMTgwIHJlYWwgIDE2NjMgdXNlciAgMTQy
IHN5cyAgMTAwMS43NSUgY3B1IAl4ODZfNjQtcmFuZGNvbmZpZy1hMDItMDYxMgoKMjAxMy0w
Ni0xMy0xMTowNDo1OCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEwLjAtcmM0LTAwMDM5LWdk
ZTNjMDc0Li4uLi4uLi4JMS4uLgkyLgkzCTQuLgk1CTYuLgk4Lgk5CTEwCTExCTEyCTEzCTE1
CTIxCTI0CTI5CTMyCTM0CTQzCTQ2CTQ3Lgk0OAk1MAk1Mgk1NAk1Ngk1OS4uLi4uLi4uLi4u
Li4JNjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiAxMiByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFm
dGVyIHRoaXMgKHJvdWdobHkgNCBzdGVwcykKW2NjNTk0M2E3ODE2YmE2YzAwNjM5ODM3YTYy
MTMxMzg2NjE5NTQ4ZGNdIGNncm91cDogbWFyayAibm90aWZ5X29uX3JlbGVhc2UiIGFuZCAi
cmVsZWFzZV9hZ2VudCIgY2dyb3VwIGZpbGVzIGluc2FuZQpydW5uaW5nIC9jL2tlcm5lbC10
ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmotYmlz
ZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZp
Zy1hMDItMDYxMi9jZ3JvdXA6cmV2aWV3LWNzcy1wZXJjcHUtcmVmOmNjNTk0M2E3ODE2YmE2
YzAwNjM5ODM3YTYyMTMxMzg2NjE5NTQ4ZGM6YmlzZWN0LWxpbnV4CgoyMDEzLTA2LTEzLTEx
OjM0OjM1IGNjNTk0M2E3ODE2YmE2YzAwNjM5ODM3YTYyMTMxMzg2NjE5NTQ4ZGMgY29tcGls
aW5nCjE4OSByZWFsICAxNjUzIHVzZXIgIDE1NiBzeXMgIDk1My4wOSUgY3B1IAl4ODZfNjQt
cmFuZGNvbmZpZy1hMDItMDYxMgoKMjAxMy0wNi0xMy0xMTozNzo1NiBkZXRlY3RpbmcgYm9v
dCBzdGF0ZSAzLjEwLjAtcmMxLTAwMDE0LWdjYzU5NDNhLi4uCTEJNC4uCTcJOAk5CTEyCTEz
CTE0CTE2CTE3CTE5CTIwLi4JMjEJMjMJMjUJMjYJMjgJMzEJMzMJMzQJMzcJNDEuLi4uCTQy
Lgk0NQk0Ni4uLgk0OAk0OS4uCTUxLgk1Mi4JNTUuCTU2CTU4Lgk2MCBTVUNDRVNTCgpCaXNl
Y3Rpbmc6IDYgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDMg
c3RlcHMpCltiNWYxYjcxMjM3NjI0MTFlNmE0MzJmODIzNjMwNGU0ZGNhZjViNGQ4XSBjZ3Jv
dXA6IHVzZSBremFsbG9jKCkgYW5kIGxpc3RfZGVsX2luaXQoKQpydW5uaW5nIC9jL2tlcm5l
bC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmot
YmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNv
bmZpZy1hMDItMDYxMi9jZ3JvdXA6cmV2aWV3LWNzcy1wZXJjcHUtcmVmOmI1ZjFiNzEyMzc2
MjQxMWU2YTQzMmY4MjM2MzA0ZTRkY2FmNWI0ZDg6YmlzZWN0LWxpbnV4CgoyMDEzLTA2LTEz
LTEyOjA1OjAyIGI1ZjFiNzEyMzc2MjQxMWU2YTQzMmY4MjM2MzA0ZTRkY2FmNWI0ZDggY29t
cGlsaW5nCjE3OCByZWFsICAxNjU0IHVzZXIgIDE0MSBzeXMgIDEwMDguNDElIGNwdSAJeDg2
XzY0LXJhbmRjb25maWctYTAyLTA2MTIKCjIwMTMtMDYtMTMtMTI6MDg6MTQgZGV0ZWN0aW5n
IGJvb3Qgc3RhdGUgMy4xMC4wLXJjNC0wMDA1Ny1nYjVmMWI3MS4uLgk0CTYJNwk5Li4JMTAJ
MTEuCTE0LgkxNS4JMTYJMjAJMjMuLgkyNQkyNgkyOAkyOQkzNC4JMzgJNDUJNTEJNTIuCTUz
CTU3CTU5CTYwIFNVQ0NFU1MKCkJpc2VjdGluZzogMyByZXZpc2lvbnMgbGVmdCB0byB0ZXN0
IGFmdGVyIHRoaXMgKHJvdWdobHkgMiBzdGVwcykKWzkxOWUwYzRhNjE0ZmNlMmZkZjhhNTdl
NTUwMDg0MWUxOGJiNTIzZTZdIGNncm91cDogZHJvcCB1bm5lY2Vzc2FyeSBSQ1UgZGFuY2lu
ZyBmcm9tIF9fcHV0X2Nzc19zZXQoKQpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3Qt
dGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmotYmlzZWN0CmxzIC1hIC9r
ZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1hMDItMDYxMi9j
Z3JvdXA6cmV2aWV3LWNzcy1wZXJjcHUtcmVmOjkxOWUwYzRhNjE0ZmNlMmZkZjhhNTdlNTUw
MDg0MWUxOGJiNTIzZTY6YmlzZWN0LWxpbnV4CgoyMDEzLTA2LTEzLTEyOjI2OjIwIDkxOWUw
YzRhNjE0ZmNlMmZkZjhhNTdlNTUwMDg0MWUxOGJiNTIzZTYgY29tcGlsaW5nCjE3NyByZWFs
ICAxNjU0IHVzZXIgIDEzNyBzeXMgIDEwMDguMDclIGNwdSAJeDg2XzY0LXJhbmRjb25maWct
YTAyLTA2MTIKCjIwMTMtMDYtMTMtMTI6Mjk6MzQgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4x
MC4wLXJjNC0wMDA2MC1nOTE5ZTBjNC4uLgkxCTYJMTYJMjcJMzIJMzcuCTQ5CTU3CTYwIFNV
Q0NFU1MKCkJpc2VjdGluZzogMSByZXZpc2lvbiBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAo
cm91Z2hseSAxIHN0ZXApCltmYmNjNzEzYjJiMTA5YmQxODA2ODhiNjVjMzk2N2Q1YTFjZDQ2
MDEwXSBjZ3JvdXA6IHJlb3JkZXIgdGhlIG9wZXJhdGlvbnMgaW4gY2dyb3VwX2Rlc3Ryb3lf
bG9ja2VkKCkKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWls
dXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1
bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWctYTAyLTA2MTIvY2dyb3VwOnJldmlldy1j
c3MtcGVyY3B1LXJlZjpmYmNjNzEzYjJiMTA5YmQxODA2ODhiNjVjMzk2N2Q1YTFjZDQ2MDEw
OmJpc2VjdC1saW51eAoKMjAxMy0wNi0xMy0xMjozNjowOSBmYmNjNzEzYjJiMTA5YmQxODA2
ODhiNjVjMzk2N2Q1YTFjZDQ2MDEwIGNvbXBpbGluZwoxNjMgcmVhbCAgMTY1NCB1c2VyICAx
MzUgc3lzICAxMDk1LjM3JSBjcHUgCXg4Nl82NC1yYW5kY29uZmlnLWEwMi0wNjEyCgoyMDEz
LTA2LTEzLTEyOjM5OjA3IGRldGVjdGluZyBib290IHN0YXRlIDMuMTAuMC1yYzQtMDAwNjIt
Z2ZiY2M3MTMuLi4uCTEuLgkyCTMJOQkxMgkxNC4JMTUJMTkJMjIuLgkyNAkzOAk0MQk0Mgk0
NQk0OAk1MQk1Ngk2MCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDAgcmV2aXNpb25zIGxlZnQgdG8g
dGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDAgc3RlcHMpCls5MDNjNjMwMzNmZmY2YTBmMmY2
MGI3YzcxODMxZmUzYjI1ZWE5YWJjXSBjZ3JvdXA6IHNwbGl0IGNncm91cCBkZXN0cnVjdGlv
biBpbnRvIHR3byBzdGVwcwpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1i
b290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwt
dGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1hMDItMDYxMi9jZ3JvdXA6
cmV2aWV3LWNzcy1wZXJjcHUtcmVmOjkwM2M2MzAzM2ZmZjZhMGYyZjYwYjdjNzE4MzFmZTNi
MjVlYTlhYmM6YmlzZWN0LWxpbnV4CgoyMDEzLTA2LTEzLTEyOjUyOjQxIDkwM2M2MzAzM2Zm
ZjZhMGYyZjYwYjdjNzE4MzFmZTNiMjVlYTlhYmMgY29tcGlsaW5nCjE2NiByZWFsICAxNjQ2
IHVzZXIgIDE0MiBzeXMgIDEwNzIuMTAlIGNwdSAJeDg2XzY0LXJhbmRjb25maWctYTAyLTA2
MTIKCjIwMTMtMDYtMTMtMTI6NTU6NDIgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMC4wLXJj
NC0wMDA2My1nOTAzYzYzMC4uLgk2CTkJMTMJMjQJMjYJMzAJNDAJNTAJNTcJNTkuLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uG1sxOzM1bWFkZF90b19ydW5fcXVldWUgMRtbMG0K
Li4uCTYwIFNVQ0NFU1MKCmYyODRiNzczMzNiMTMyMDQ5MWYxMzhiNzZmMTEwMDZiYmM5NjI1
NjkgaXMgdGhlIGZpcnN0IGJhZCBjb21taXQKY29tbWl0IGYyODRiNzczMzNiMTMyMDQ5MWYx
MzhiNzZmMTEwMDZiYmM5NjI1NjkKQXV0aG9yOiBUZWp1biBIZW8gPHRqQGtlcm5lbC5vcmc+
CkRhdGU6ICAgV2VkIEp1biAxMiAxMzo1MDo1OCAyMDEzIC0wNzAwCgogICAgY2dyb3VwOiB1
c2UgcGVyY3B1IHJlZmNudCBmb3IgY2dyb3VwX3N1YnN5c19zdGF0ZXMKICAgIAogICAgQSBj
c3MgKGNncm91cF9zdWJzeXNfc3RhdGUpIGlzIGhvdyBlYWNoIGNncm91cCBpcyByZXByZXNl
bnRlZCB0byBhCiAgICBjb250cm9sbGVyLiAgQXMgc3VjaCwgaXQgY2FuIGJlIHVzZWQgaW4g
aG90IHBhdGhzIGFjcm9zcyB0aGUgdmFyaW91cwogICAgc3Vic3lzdGVtcyBkaWZmZXJlbnQg
Y29udHJvbGxlcnMgYXJlIGFzc29jaWF0ZWQgd2l0aC4KICAgIAogICAgT25lIG9mIHRoZSBj
b21tb24gb3BlcmF0aW9ucyBpcyByZWZlcmVuY2UgY291bnRpbmcsIHdoaWNoIHVwIHVudGls
IG5vdwogICAgaGFzIGJlZW4gaW1wbGVtZW50ZWQgdXNpbmcgYSBnbG9iYWwgYXRvbWljIGNv
dW50ZXIgYW5kIGNhbiBoYXZlCiAgICBzaWduaWZpY2FudCBhZHZlcnNlIGltcGFjdCBvbiBz
Y2FsYWJpbGl0eS4gIEZvciBleGFtcGxlLCBjc3MgcmVmY250CiAgICBjYW4gYmUgZ290dGVu
IGFuZCBwdXQgbXVsdGlwbGUgdGltZXMgYnkgYmxrY2cgZm9yIGVhY2ggSU8gcmVxdWVzdC4K
ICAgIEZvciBoaWdob3BzIGNvbmZpZ3VyYXRpb25zIHdoaWNoIHRyeSB0byBkbyBhcyBtdWNo
IHBlci1jcHUgYXMKICAgIHBvc3NpYmxlLCB0aGUgZ2xvYmFsIGZyZXF1ZW50IHJlZmNudGlu
ZyBjYW4gYmUgdmVyeSBleHBlbnNpdmUuCiAgICAKICAgIEluIGdlbmVyYWwsIGdpdmVuIHRo
ZSB2YXJpb3VzIGh1Z2VseSBkaXZlcnNlIHBhdGhzIGNzcydzIGVuZCB1cCBiZWluZwogICAg
dXNlZCBmcm9tLCB3ZSBuZWVkIHRvIG1ha2UgaXQgY2hlYXAgYW5kIGhpZ2hseSBzY2FsYWJs
ZS4gIEluIGl0cwogICAgdXNhZ2UsIGNzcyByZWZjbnRpbmcgaXNuJ3QgdmVyeSBkaWZmZXJl
bnQgZnJvbSBtb2R1bGUgcmVmY250aW5nLgogICAgCiAgICBUaGlzIHBhdGNoIGNvbnZlcnRz
IGNzcyByZWZjbnRpbmcgdG8gdXNlIHRoZSByZWNlbnRseSBhZGRlZAogICAgcGVyY3B1X3Jl
Zi4gIGNzc19nZXQvdHJ5Z2V0L3B1dCgpIGRpcmVjdGx5IG1hcHMgdG8gdGhlIG1hdGNoaW5n
CiAgICBwZXJjcHVfcmVmIG9wZXJhdGlvbnMgYW5kIHRoZSBkZWFjdGl2YXRpb24gbG9naWMg
aXMgbm8gbG9uZ2VyCiAgICBuZWNlc3NhcnkgYXMgcGVyY3B1X3JlZiBhbHJlYWR5IGhhcyBy
ZWZjbnQga2lsbGluZy4KICAgIAogICAgVGhlIG9ubHkgY29tcGxpY2F0aW9uIGlzIHRoYXQg
YXMgdGhlIHJlZmNudCBpcyBwZXItY3B1LAogICAgcGVyY3B1X3JlZl9raWxsKCkgaW4gaXRz
ZWxmIGRvZXNuJ3QgZW5zdXJlIHRoYXQgZnVydGhlciB0cnlnZXQKICAgIG9wZXJhdGlvbnMg
d2lsbCBmYWlsLCB3aGljaCB3ZSBuZWVkIHRvIGd1YXJhbnRlZSBiZWZvcmUgaW52b2tpbmcK
ICAgIC0+Y3NzX29mZmxpbmUoKSdzLiAgVGhpcyBpcyByZXNvbHZlZCBjb2xsZWN0aW5nIGtp
bGwgY29uZmlybWF0aW9uCiAgICB1c2luZyBwZXJjcHVfcmVmX2tpbGxfYW5kX2NvbmZpcm0o
KSBhbmQgaW5pdGlhdGluZyB0aGUgb2ZmbGluZSBwaGFzZQogICAgb2YgZGVzdHJ1Y3Rpb24g
YWZ0ZXIgYWxsIGNzcyByZWZjbnQncyBhcmUgY29uZmlybWVkIHRvIGJlIHNlZW4gYXMKICAg
IGtpbGxlZCBvbiBhbGwgQ1BVcy4gIFRoZSBwcmV2aW91cyBwYXRjaGVzIGFscmVhZHkgc3Bs
aXR0ZWQgZGVzdHJ1Y3Rpb24KICAgIGludG8gdHdvIHBoYXNlcywgc28gcGVyY3B1X3JlZl9r
aWxsX2FuZF9jb25maXJtKCkgY2FuIGJlIGhvb2tlZCB1cAogICAgZWFzaWx5LgogICAgCiAg
ICBUaGlzIHBhdGNoIHJlbW92ZXMgY3NzX3JlZmNudCgpIHdoaWNoIGlzIHVzZWQgZm9yIHJj
dSBkZXJlZmVyZW5jZQogICAgc2FuaXR5IGNoZWNrIGluIGNzc19pZCgpLiAgV2hpbGUgd2Ug
Y2FuIGFkZCBhIHBlcmNwdSByZWZjbnQgQVBJIHRvIGFzawogICAgdGhlIHNhbWUgcXVlc3Rp
b24sIGNzc19pZCgpIGl0c2VsZiBpcyBzY2hlZHVsZWQgdG8gYmUgcmVtb3ZlZCBmYWlybHkK
ICAgIHNvb24sIHNvIGxldCdzIG5vdCBib3RoZXIgd2l0aCBpdC4gIEp1c3QgZHJvcCB0aGUg
c2FuaXR5IGNoZWNrIGFuZCB1c2UKICAgIHJjdV9kZXJlZmVyZW5jZV9yYXcoKSBpbnN0ZWFk
LgogICAgCiAgICBTaWduZWQtb2ZmLWJ5OiBUZWp1biBIZW8gPHRqQGtlcm5lbC5vcmc+CiAg
ICBDYzogTWljaGFsIEhvY2tvIDxtaG9ja29Ac3VzZS5jej4KICAgIENjOiBNaWtlIFNuaXR6
ZXIgPHNuaXR6ZXJAcmVkaGF0LmNvbT4KICAgIENjOiBWaXZlayBHb3lhbCA8dmdveWFsQHJl
ZGhhdC5jb20+CiAgICBDYzogIkFsYXNkYWlyIEcuIEtlcmdvbiIgPGFna0ByZWRoYXQuY29t
PgogICAgQ2M6IEplbnMgQXhib2UgPGF4Ym9lQGtlcm5lbC5kaz4KICAgIENjOiBNaWt1bGFz
IFBhdG9ja2EgPG1wYXRvY2thQHJlZGhhdC5jb20+CiAgICBDYzogR2xhdWJlciBDb3N0YSA8
Z2xvbW1lckBnbWFpbC5jb20+CiAgICBDYzogS2VudCBPdmVyc3RyZWV0IDxrb3ZlcnN0cmVl
dEBnb29nbGUuY29tPgoKOjA0MDAwMCAwNDAwMDAgZjgyY2U2MzliYTE0ZWE3MTBjYzFkYjJj
MjFmMDMxZmVkNzYwNDcwOSBmNDQ2MjZiZDE3YTBkNWMxMDFmZDc4NjNhM2E1OTRiZTExNDU4
MjdjIE0JaW5jbHVkZQo6MDQwMDAwIDA0MDAwMCBlODkzNTMzM2EzOGY5NTc2MmJlOTQ3ZDk0
MzI5YWI0YWJjN2U3YWY5IDEyNDNmNTI5MTcyNzU5YzExYzJmYWVmMDg3NTVjODJkZTdkMjVi
NTYgTQlrZXJuZWwKYmlzZWN0IHJ1biBzdWNjZXNzCmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVu
LXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1hMDItMDYxMi9jZ3JvdXA6cmV2aWV3LWNz
cy1wZXJjcHUtcmVmOjkwM2M2MzAzM2ZmZjZhMGYyZjYwYjdjNzE4MzFmZTNiMjVlYTlhYmM6
YmlzZWN0LWxpbnV4CgoyMDEzLTA2LTEzLTE1OjM0OjU4IDkwM2M2MzAzM2ZmZjZhMGYyZjYw
YjdjNzE4MzFmZTNiMjVlYTlhYmMgcmV1c2UgL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1h
MDItMDYxMi85MDNjNjMwMzNmZmY2YTBmMmY2MGI3YzcxODMxZmUzYjI1ZWE5YWJjL3ZtbGlu
dXotMy4xMC4wLXJjNC0wMDA2My1nOTAzYzYzMAoKMjAxMy0wNi0xMy0xNTozNDo1OCBkZXRl
Y3RpbmcgYm9vdCBzdGF0ZSAuLi4JNjEuCTYyCTY1Lgk3My4JNzQJNzUuCTgwCTgxLgk4Mgk4
Mwk4NQk4OS4JOTEJOTQJOTYJOTgJMTAwCTEwNgkxMDgJMTEzLgkxMTcuCTExOAkxMTkJMTIy
LgkxMjYJMTI4Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLhtbMTszNW1hZGRfdG9f
cnVuX3F1ZXVlIDUyG1swbQouLi4uCTEyOS4JMTMwLi4JMTMxLi4uLi4uLi4uCTEzMi4uLgkx
MzMuLi4uLi4uLgkxMzQuLgkxMzYuCTEzNwkxNDAJMTQxCTE0NC4JMTQ2CTE0Ny4JMTQ4Li4u
Li4JMTQ5CTE1MgkxNTYJMTU4CTE1OS4JMTYwLi4uLgkxNjEJMTYyLi4JMTYzLi4uCTE2NC4u
CTE2NS4uLi4JMTY2Li4uCTE2Ny4uCTE2OAkxNzAuCTE3Mi4JMTc0CTE3NQkxNzgJMTc5CTE4
MCBTVUNDRVNTCgpscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJh
bmRjb25maWctYTAyLTA2MTIvY2dyb3VwOnJldmlldy1jc3MtcGVyY3B1LXJlZjpmMjg0Yjc3
MzMzYjEzMjA0OTFmMTM4Yjc2ZjExMDA2YmJjOTYyNTY5OmJpc2VjdC1saW51eAogVEVTVCBG
QUlMVVJFCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTAyLTA2MTIvZjI4NGI3NzMzM2Ix
MzIwNDkxZjEzOGI3NmYxMTAwNmJiYzk2MjU2OS9kbWVzZy1rdm0tYmF5LTI4NDQ2LTIwMTMw
NjEzMDkwNzQxLTMuMTAuMC1yYzQtMDAwNjQtZ2YyODRiNzczLTU3Ci9rZXJuZWwveDg2XzY0
LXJhbmRjb25maWctYTAyLTA2MTIvZjI4NGI3NzMzM2IxMzIwNDkxZjEzOGI3NmYxMTAwNmJi
Yzk2MjU2OS9kbWVzZy1rdm0tbGtwLW5leDA0LTQxODk1LTIwMTMwNjEzMDM1MzIzLTMuMTAu
MC1yYzQtMDAwNjQtZ2YyODRiNzczLTU3Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTAy
LTA2MTIvZjI4NGI3NzMzM2IxMzIwNDkxZjEzOGI3NmYxMTAwNmJiYzk2MjU2OS9kbWVzZy1r
dm0tbGtwLW5leDA0LTQzNjczLTIwMTMwNjEzMDM1MzQyLTMuMTAuMC1yYzQtMDAwNjQtZ2Yy
ODRiNzczLTU3Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTAyLTA2MTIvZjI4NGI3NzMz
M2IxMzIwNDkxZjEzOGI3NmYxMTAwNmJiYzk2MjU2OS9kbWVzZy1rdm0tbGtwLW5leDA0LTYy
Mzc5LTIwMTMwNjEzMDM1MzQ5LTMuMTAuMC1yYzQtMDAwNjQtZ2YyODRiNzczLTU3Ci9rZXJu
ZWwveDg2XzY0LXJhbmRjb25maWctYTAyLTA2MTIvZjI4NGI3NzMzM2IxMzIwNDkxZjEzOGI3
NmYxMTAwNmJiYzk2MjU2OS9kbWVzZy1rdm0tbGtwLW5leDA0LTY0MTExLTIwMTMwNjEzMDM1
MzMxLTMuMTAuMC1yYzQtMDAwNjQtZ2YyODRiNzczLTU3Ci9rZXJuZWwveDg2XzY0LXJhbmRj
b25maWctYTAyLTA2MTIvZjI4NGI3NzMzM2IxMzIwNDkxZjEzOGI3NmYxMTAwNmJiYzk2MjU2
OS9kbWVzZy1rdm0tdnAtMjU5MzEtMjAxMzA2MTMwNTA0MTYtMy4xMC4wLXJjNC0wMDA2NC1n
ZjI4NGI3NzMtNTcKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMDItMDYxMi9mMjg0Yjc3
MzMzYjEzMjA0OTFmMTM4Yjc2ZjExMDA2YmJjOTYyNTY5L2RtZXNnLWt2bS12cC0yODExNi0y
MDEzMDYxMzA1MDQyNi0zLjEwLjAtcmM0LTAwMDY0LWdmMjg0Yjc3My01Nwova2VybmVsL3g4
Nl82NC1yYW5kY29uZmlnLWEwMi0wNjEyL2YyODRiNzczMzNiMTMyMDQ5MWYxMzhiNzZmMTEw
MDZiYmM5NjI1NjkvZG1lc2cta3ZtLXZwLTI5NDA2LTIwMTMwNjEzMDUwNDI1LTMuMTAuMC1y
YzQtMDAwNjQtZ2YyODRiNzczLTU3Ci9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYTAyLTA2
MTIvZjI4NGI3NzMzM2IxMzIwNDkxZjEzOGI3NmYxMTAwNmJiYzk2MjU2OS9kbWVzZy1rdm0t
dnAtMzAxNDQtMjAxMzA2MTMwOTA4MDAtMy4xMC4wLXJjNC0wMDA2NC1nZjI4NGI3NzMtNTcK
L2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMDItMDYxMi9mMjg0Yjc3MzMzYjEzMjA0OTFm
MTM4Yjc2ZjExMDA2YmJjOTYyNTY5L2RtZXNnLWt2bS13YWltZWEtMjgxOTAtMjAxMzA2MTMw
OTA4NTgtMy4xMC4wLXJjNC0wMDA2NC1nZjI4NGI3NzMtNTcKL2tlcm5lbC94ODZfNjQtcmFu
ZGNvbmZpZy1hMDItMDYxMi9mMjg0Yjc3MzMzYjEzMjA0OTFmMTM4Yjc2ZjExMDA2YmJjOTYy
NTY5L2RtZXNnLWt2bS13YWltZWEtMjg3MDQtMjAxMzA2MTMwNTA0MDktMy4xMC4wLXJjNC0w
MDA2NC1nZjI4NGI3NzMtNTcKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1hMDItMDYxMi9m
Mjg0Yjc3MzMzYjEzMjA0OTFmMTM4Yjc2ZjExMDA2YmJjOTYyNTY5L2RtZXNnLWt2bS13YWlt
ZWEtMzcwOS0yMDEzMDYxMzA5MDkwMi0zLjEwLjAtcmM0LTAwMDY0LWdmMjg0Yjc3My01Nwov
a2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEwMi0wNjEyL2YyODRiNzczMzNiMTMyMDQ5MWYx
MzhiNzZmMTEwMDZiYmM5NjI1NjkvZG1lc2cta3ZtLXdhaW1lYS0zNzg1LTIwMTMwNjEzMDUw
NDE1LTMuMTAuMC1yYzQtMDAwNjQtZ2YyODRiNzczLTU3CgpbZGV0YWNoZWQgSEVBRCBhMmM3
NjRjXSBSZXZlcnQgImNncm91cDogdXNlIHBlcmNwdSByZWZjbnQgZm9yIGNncm91cF9zdWJz
eXNfc3RhdGVzIgogMiBmaWxlcyBjaGFuZ2VkLCA3MCBpbnNlcnRpb25zKCspLCA5MSBkZWxl
dGlvbnMoLSkKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5k
Y29uZmlnLWEwMi0wNjEyL2Nncm91cDpyZXZpZXctY3NzLXBlcmNwdS1yZWY6YTJjNzY0Yzdk
YmM2MzJhYjZhYzQ4YjJkODMzZjQ0ZGNlMjZiYTFlZDpiaXNlY3QtbGludXgKCjIwMTMtMDYt
MTMtMTk6MTI6MTIgYTJjNzY0YzdkYmM2MzJhYjZhYzQ4YjJkODMzZjQ0ZGNlMjZiYTFlZCBj
b21waWxpbmcKCjIwMTMtMDYtMTMtMTk6MTY6MTUgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4x
MC4wLXJjNC0wMDA2NS1nYTJjNzY0Yy4uLi4uLi4uCTEuCTMuLi4uCTUuCTcuLi4uLi4uLi4J
OC4JMTEuLi4uLi4JMTMJMTQuLgkxNi4uCTE3Li4uLi4uLgkxOC4uLi4uLi4uLi4uLi4uLgkx
OQkyMC4uCTIxLi4uLi4uLi4uCTIzLgkyNC4uCTI1Li4uLi4uLi4uLi4uLi4uLi4uLi4JMjYu
Li4uLi4uLi4uLi4JMjcuLi4uLi4JMjguLgkyOS4JMzAuLgkzMS4uLi4uLi4uLi4uLi4uCTMy
Li4uLi4uLi4uCTMzLi4uLi4uLi4uLi4uLgkzNC4uLi4uLi4JMzUJMzYuLi4uLi4uLi4uLgkz
Ny4JMzguLi4uLgkzOQk0MC4uLgk0MQk0My4JNDQuLi4uLi4uLi4uLi4JNDUuLi4JNDYuCTQ4
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLgk0OS4uCTUwLgk1MS4JNTIuLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLgk1My4uLi4uCTU0Li4uLi4uLi4uLi4uLi4uLi4uLi4JNTUuLgk1Ny4u
Li4uLi4JNTkuLi4uLi4JNjEuCTYyLi4JNjMuLi4JNjQJNjUuCTY2Li4uCTY3CTY4CTcwLgk3
MS4JNzMuCTc0CTc1CTgwCTg1CTg5CTkwLgk5NQk5OAkxMDIuCTEwNQkxMTUJMTE3CTEyMgkx
MjMJMTI4CTEzMwkxMzYJMTQwCTE0MQkxNDMJMTQ0CTE0NgkxNDkJMTUwCTE1MQkxNTIuCTE1
My4uCTE1NgkxNTcuCTE1OQkxNjAuLgkxNjMuLgkxNjQJMTY1LgkxNjYJMTY5Li4JMTczCTE3
NAkxNzYuLgkxODAgU1VDQ0VTUwoKCj09PT09PT09PSB1cHN0cmVhbSA9PT09PT09PT0KRmV0
Y2hpbmcgbGludXMKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1y
YW5kY29uZmlnLWEwMi0wNjEyL2Nncm91cDpyZXZpZXctY3NzLXBlcmNwdS1yZWY6MjZlMDQ0
NjJjOGI3OGQwNzlkMzIzMTM5NmVjNzJkNThhMTRmMTE0YjpiaXNlY3QtbGludXgKCjIwMTMt
MDYtMTMtMjI6NDM6NTAgMjZlMDQ0NjJjOGI3OGQwNzlkMzIzMTM5NmVjNzJkNThhMTRmMTE0
YiByZXVzZSAva2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWEwMi0wNjEyLzI2ZTA0NDYyYzhi
NzhkMDc5ZDMyMzEzOTZlYzcyZDU4YTE0ZjExNGIvdm1saW51ei0zLjEwLjAtcmM1LTAwMTY3
LWcyNmUwNDQ2CgoyMDEzLTA2LTEzLTIyOjQzOjUwIGRldGVjdGluZyBib290IHN0YXRlIC4u
Li4JMTAuLi4JMTEuLi4uLgkxMgkxMwkxNC4JMTUJMTcuLgkxOAkyMS4JMjIJMjYJMjcJMjku
CTMxCTM0CTM1LgkzNgkzOAkzOS4JNDAuLgk0MS4JNDMuCTQ0Lgk0NS4uCTQ3CTQ4CTQ5CTUx
Li4JNTIuLi4uLgk1My4uLgk1NAk1Ni4JNTcJNTguCTYxCTYyLgk2NC4JNjYuLi4uLi4uLi4u
Li4uCTY3CTY4Li4uLi4uLi4uLi4uLi4JNjkJNzAJNzIJNzMuLi4JNzQuCTc1CTc2Li4uLgk3
Nwk3OC4JNzkuLi4JODAJODEuLi4uLgk4Mgk4My4JODQJODYuCTg3Li4JOTAuCTkzCTk1CTk2
CTk4CTEwOC4uLi4uLi4JMTI2CTEyNy4JMTI4Li4uLgkxMjkJMTMwCTEzMi4uCTEzMy4JMTM0
CTEzNQkxMzcJMTM5CTE0Mi4JMTQzCTE0NAkxNDYJMTQ4Li4JMTUwLgkxNTEJMTUyCTE1Mwkx
NTQuLgkxNTgJMTU5Li4JMTYxCTE2My4JMTY0CTE2NgkxNjcJMTY5CTE3MQkxNzIuLgkxNzQJ
MTc2CTE3NwkxNzguLi4JMTgwIFNVQ0NFU1MKCgo9PT09PT09PT0gbGludXgtbmV4dCA9PT09
PT09PT0KRmV0Y2hpbmcgbmV4dApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0v
eDg2XzY0LXJhbmRjb25maWctYTAyLTA2MTIvY2dyb3VwOnJldmlldy1jc3MtcGVyY3B1LXJl
ZjpjMDRlZmVkNzM0NDA5ZjVhNDQ3MTViNTRhNmNhMWI1NGIwY2NmMjE1OmJpc2VjdC1saW51
eAoKMjAxMy0wNi0xNC0wMDozMjo1MyBjMDRlZmVkNzM0NDA5ZjVhNDQ3MTViNTRhNmNhMWI1
NGIwY2NmMjE1IGNvbXBpbGluZwoKMjAxMy0wNi0xNC0wMDozNzoyOSBkZXRlY3RpbmcgYm9v
dCBzdGF0ZSAzLjEwLjAtcmM0LW5leHQtMjAxMzA2MDctMDUwMDEtZ2MwNGVmZWQuLi4uLi4J
MS4uCTIuLgk0Li4uLgk1CTYuLi4uCTcJOC4uLi4uLi4uLi4JMTEuLgkxMgkxMwkxNi4uLi4u
Li4uLi4uLi4JMTcuLgkxOC4uLgkyMC4uLgkyMS4uLgkyMy4JMjQuLi4uLi4JMjcuLi4uLi4u
CTI4Li4JMzAuLi4uLgkzMS4JMzIuCTMzCTM0Li4uLi4JMzUuCTM2CTM3Li4uLi4uLi4uLi4J
MzgJMzkJNDAuCTQxLi4JNDIuLgk0NC4uLi4JNDUuCTQ2Li4uLgk0Ny4uLi4uLgk0OC4JNDku
Lgk1MAk1MS4uLgk1Mi4JNTMJNTQuLi4JNTUuLgk1Ni4uLi4uLi4uLi4uLgk1Ny4JNTgJNjAu
Lgk2Mi4JNjMuLi4uLi4uCTY0Li4uCTY1Li4uCTY2Li4JNjcuLi4uCTY4Li4JNjkuCTcwLi4J
NzEuLi4uLgk3Mgk3My4uLi4uLi4uLi4uCTc0Lgk3NQk3Ni4JNzcuLi4uLi4JNzguLi4uCTgw
CTgyLi4uLi4uLi4uCTgzLi4JODQuCTg1Li4uCTg2CTg3Li4JODguLi4uLi4uLi4uLi4JODku
Li4uLi4uLi4uLi4JOTEuLi4uCTkyLi4uLi4JOTMuCTk0Lgk5Ni4uLi4uLi4uLgk5Nwk5OC4u
Lgk5OS4JMTAxCTEwMgkxMDMJMTA1CTEwNgkxMDguCTEwOQkxMTAJMTEyLgkxMTMJMTE0Lgkx
MTgJMTIwLi4uCTEyMi4uCTEyNQkxMjYuCTEyOQkxMzEJMTMyCTEzNQkxMzYJMTQwCTE0Mwkx
NDkJMTU1CTE1NwkxNTkJMTYxCTE2MgkxNjQJMTY1CTE2OQkxNzIJMTc1LgkxNzcJMTc5CTE4
MCBTVUNDRVNTCgo=

--6TrnltStXW4iwmi0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=".config-bisect"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.10.0-rc4 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
CONFIG_KERNEL_LZO=y
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_FHANDLE is not set
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y
# CONFIG_AUDIT_LOGINUID_IMMUTABLE is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
# CONFIG_NO_HZ_FULL is not set
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
# CONFIG_TICK_CPU_ACCOUNTING is not set
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
CONFIG_IRQ_TIME_ACCOUNTING=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
# CONFIG_TASK_DELAY_ACCT is not set
# CONFIG_TASK_XACCT is not set

#
# RCU Subsystem
#
CONFIG_TREE_PREEMPT_RCU=y
CONFIG_PREEMPT_RCU=y
CONFIG_RCU_STALL_COMMON=y
# CONFIG_RCU_USER_QS is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_RCU_FAST_NO_HZ=y
CONFIG_TREE_RCU_TRACE=y
CONFIG_RCU_BOOST=y
CONFIG_RCU_BOOST_PRIO=1
CONFIG_RCU_BOOST_DELAY=500
CONFIG_RCU_NOCB_CPU=y
# CONFIG_RCU_NOCB_CPU_NONE is not set
# CONFIG_RCU_NOCB_CPU_ZERO is not set
CONFIG_RCU_NOCB_CPU_ALL=y
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
CONFIG_MEMCG=y
CONFIG_MEMCG_KMEM=y
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
CONFIG_RT_GROUP_SCHED=y
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_PID_NS=y
# CONFIG_NET_NS is not set
CONFIG_SCHED_AUTOGROUP=y
CONFIG_MM_OWNER=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HOTPLUG=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
# CONFIG_BLK_DEV_INTEGRITY is not set
CONFIG_BLK_DEV_THROTTLING=y

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
CONFIG_ACORN_PARTITION=y
CONFIG_ACORN_PARTITION_CUMANA=y
CONFIG_ACORN_PARTITION_EESOX=y
# CONFIG_ACORN_PARTITION_ICS is not set
CONFIG_ACORN_PARTITION_ADFS=y
# CONFIG_ACORN_PARTITION_POWERTEC is not set
CONFIG_ACORN_PARTITION_RISCIX=y
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
CONFIG_ATARI_PARTITION=y
CONFIG_MAC_PARTITION=y
# CONFIG_MSDOS_PARTITION is not set
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
# CONFIG_KARMA_PARTITION is not set
# CONFIG_EFI_PARTITION is not set
# CONFIG_SYSV68_PARTITION is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
# CONFIG_IOSCHED_CFQ is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_NOOP=y
CONFIG_DEFAULT_IOSCHED="noop"
CONFIG_PADATA=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_VSMP is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
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
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
CONFIG_CALGARY_IOMMU=y
# CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_MAXSMP=y
CONFIG_NR_CPUS=4096
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
# CONFIG_X86_MCE_INTEL is not set
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_I8K=y
# CONFIG_MICROCODE is not set
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
# CONFIG_AMD_NUMA is not set
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
CONFIG_NUMA_EMU=y
CONFIG_NODES_SHIFT=10
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MOVABLE_NODE is not set
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=999999
# CONFIG_COMPACTION is not set
# CONFIG_MIGRATION is not set
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
# CONFIG_BOUNCE is not set
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
# CONFIG_HWPOISON_INJECT is not set
# CONFIG_TRANSPARENT_HUGEPAGE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_CLEANCACHE=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
# CONFIG_PM_RUNTIME is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_PROC_EVENT=y
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_I2C=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_APEI is not set
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# x86 CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
# CONFIG_PCIEPORTBUS is not set
CONFIG_ARCH_SUPPORTS_MSI=y
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
CONFIG_PCI_STUB=y
# CONFIG_HT_IRQ is not set
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
CONFIG_HOTPLUG_PCI=y
# CONFIG_HOTPLUG_PCI_ACPI is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=y
CONFIG_RAPIDIO=y
CONFIG_RAPIDIO_DISC_TIMEOUT=30
CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS=y
# CONFIG_RAPIDIO_DMA_ENGINE is not set
# CONFIG_RAPIDIO_DEBUG is not set
CONFIG_RAPIDIO_ENUM_BASIC=y
# CONFIG_RAPIDIO_TSI57X is not set
CONFIG_RAPIDIO_CPS_XX=y
CONFIG_RAPIDIO_TSI568=y
# CONFIG_RAPIDIO_CPS_GEN2 is not set
CONFIG_RAPIDIO_TSI500=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
CONFIG_X86_X32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_KEYS_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
CONFIG_ATM=y
# CONFIG_ATM_LANE is not set
CONFIG_STP=y
CONFIG_GARP=y
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
CONFIG_NET_DSA_TAG_DSA=y
CONFIG_NET_DSA_TAG_EDSA=y
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
# CONFIG_VLAN_8021Q_MVRP is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
CONFIG_LLC2=y
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
CONFIG_X25=y
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
CONFIG_IEEE802154=y
CONFIG_MAC802154=y
# CONFIG_NET_SCHED is not set
CONFIG_DCB=y
# CONFIG_DNS_RESOLVER is not set
CONFIG_BATMAN_ADV=y
# CONFIG_BATMAN_ADV_NC is not set
# CONFIG_BATMAN_ADV_DEBUG is not set
CONFIG_OPENVSWITCH=y
CONFIG_VSOCKETS=y
# CONFIG_NETLINK_MMAP is not set
CONFIG_NETLINK_DIAG=y
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
CONFIG_NETPRIO_CGROUP=y
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=y
CONFIG_AX25_DAMA_SLAVE=y
CONFIG_NETROM=y
CONFIG_ROSE=y

#
# AX.25 network device drivers
#
CONFIG_MKISS=y
# CONFIG_6PACK is not set
CONFIG_BPQETHER=y
CONFIG_BAYCOM_SER_FDX=y
# CONFIG_BAYCOM_SER_HDX is not set
CONFIG_YAM=y
CONFIG_CAN=y
CONFIG_CAN_RAW=y
# CONFIG_CAN_BCM is not set
# CONFIG_CAN_GW is not set

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
CONFIG_CAN_SLCAN=y
# CONFIG_CAN_DEV is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=y
CONFIG_IRCOMM=y
CONFIG_IRDA_ULTRA=y

#
# IrDA options
#
# CONFIG_IRDA_CACHE_LAST_LSAP is not set
CONFIG_IRDA_FAST_RR=y
# CONFIG_IRDA_DEBUG is not set

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
# CONFIG_IRTTY_SIR is not set

#
# Dongle support
#

#
# FIR device drivers
#
CONFIG_NSC_FIR=y
CONFIG_WINBOND_FIR=y
CONFIG_SMC_IRCC_FIR=y
# CONFIG_ALI_FIR is not set
# CONFIG_VLSI_FIR is not set
# CONFIG_VIA_FIR is not set
# CONFIG_BT is not set
# CONFIG_WIRELESS is not set
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_RFKILL_REGULATOR is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
CONFIG_NFC=y
CONFIG_NFC_NCI=y
CONFIG_NFC_HCI=y
CONFIG_NFC_SHDLC=y

#
# Near Field Communication (NFC) devices
#
# CONFIG_NFC_PN544 is not set
CONFIG_NFC_MICROREAD=y
CONFIG_NFC_MICROREAD_I2C=y
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
# CONFIG_DEVTMPFS is not set
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
CONFIG_NFTL=y
CONFIG_NFTL_RW=y
CONFIG_INFTL=y
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
CONFIG_SM_FTL=y
# CONFIG_MTD_OOPS is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
# CONFIG_MTD_ROM is not set
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=y
# CONFIG_MTD_PHYSMAP_COMPAT is not set
CONFIG_MTD_SC520CDP=y
CONFIG_MTD_NETSC520=y
CONFIG_MTD_TS5500=y
# CONFIG_MTD_AMD76XROM is not set
# CONFIG_MTD_ICHXROM is not set
CONFIG_MTD_ESB2ROM=y
CONFIG_MTD_CK804XROM=y
CONFIG_MTD_SCB2_FLASH=y
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
CONFIG_MTD_INTEL_VR_NOR=y
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=y
# CONFIG_MTD_PMC551_BUGFIX is not set
# CONFIG_MTD_PMC551_DEBUG is not set
CONFIG_MTD_DATAFLASH=y
CONFIG_MTD_DATAFLASH_WRITE_VERIFY=y
CONFIG_MTD_DATAFLASH_OTP=y
CONFIG_MTD_M25P80=y
CONFIG_M25PXX_USE_FAST_READ=y
CONFIG_MTD_SST25L=y
# CONFIG_MTD_SLRAM is not set
CONFIG_MTD_PHRAM=y
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTDRAM_ABS_POS=0
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_NAND_ECC=y
CONFIG_MTD_NAND_ECC_SMC=y
CONFIG_MTD_NAND=y
# CONFIG_MTD_NAND_ECC_BCH is not set
CONFIG_MTD_SM_COMMON=y
# CONFIG_MTD_NAND_DENALI is not set
CONFIG_MTD_NAND_IDS=y
CONFIG_MTD_NAND_RICOH=y
CONFIG_MTD_NAND_DISKONCHIP=y
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE=y
CONFIG_MTD_NAND_DOCG4=y
# CONFIG_MTD_NAND_CAFE is not set
CONFIG_MTD_NAND_NANDSIM=y
CONFIG_MTD_NAND_PLATFORM=y
CONFIG_MTD_ONENAND=y
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
CONFIG_MTD_ONENAND_GENERIC=y
CONFIG_MTD_ONENAND_OTP=y
CONFIG_MTD_ONENAND_2X_PROGRAM=y

#
# LPDDR flash memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
CONFIG_MTD_UBI_FASTMAP=y
# CONFIG_MTD_UBI_GLUEBI is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=y
# CONFIG_BLK_CPQ_DA is not set
CONFIG_BLK_CPQ_CISS_DA=y
CONFIG_CISS_SCSI_TAPE=y
CONFIG_BLK_DEV_DAC960=y
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
CONFIG_BLK_DEV_NVME=y
CONFIG_BLK_DEV_SX8=y
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
# CONFIG_BLK_DEV_XIP is not set
# CONFIG_CDROM_PKTCDVD is not set
CONFIG_ATA_OVER_ETH=y
CONFIG_VIRTIO_BLK=y
CONFIG_BLK_DEV_HD=y
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
# CONFIG_INTEL_MID_PTI is not set
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=y
# CONFIG_TIFM_7XX1 is not set
CONFIG_ICS932S401=y
CONFIG_ATMEL_SSC=y
CONFIG_ENCLOSURE_SERVICES=y
# CONFIG_CS5535_MFGPT is not set
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
CONFIG_VMWARE_BALLOON=y
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
# CONFIG_BMP085_SPI is not set
CONFIG_PCH_PHUB=y
CONFIG_USB_SWITCH_FSA9480=y
# CONFIG_LATTICE_ECP3_CONFIG is not set
# CONFIG_SRAM is not set
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_MAX6875 is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_EEPROM_93XX46 is not set
CONFIG_CB710_CORE=y
CONFIG_CB710_DEBUG=y
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_VMWARE_VMCI is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_BLK_DEV_IDE_SATA=y
CONFIG_IDE_GD=y
# CONFIG_IDE_GD_ATA is not set
CONFIG_IDE_GD_ATAPI=y
CONFIG_BLK_DEV_IDECD=y
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
CONFIG_BLK_DEV_PLATFORM=y
# CONFIG_BLK_DEV_CMD640 is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
CONFIG_BLK_DEV_OFFBOARD=y
CONFIG_BLK_DEV_GENERIC=y
# CONFIG_BLK_DEV_OPTI621 is not set
CONFIG_BLK_DEV_RZ1000=y
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_AEC62XX is not set
CONFIG_BLK_DEV_ALI15X3=y
CONFIG_BLK_DEV_AMD74XX=y
# CONFIG_BLK_DEV_ATIIXP is not set
CONFIG_BLK_DEV_CMD64X=y
CONFIG_BLK_DEV_TRIFLEX=y
# CONFIG_BLK_DEV_CS5520 is not set
CONFIG_BLK_DEV_CS5530=y
CONFIG_BLK_DEV_HPT366=y
CONFIG_BLK_DEV_JMICRON=y
# CONFIG_BLK_DEV_SC1200 is not set
CONFIG_BLK_DEV_PIIX=y
# CONFIG_BLK_DEV_IT8172 is not set
CONFIG_BLK_DEV_IT8213=y
CONFIG_BLK_DEV_IT821X=y
CONFIG_BLK_DEV_NS87415=y
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
CONFIG_BLK_DEV_PDC202XX_NEW=y
# CONFIG_BLK_DEV_SVWKS is not set
CONFIG_BLK_DEV_SIIMAGE=y
CONFIG_BLK_DEV_SIS5513=y
CONFIG_BLK_DEV_SLC90E66=y
CONFIG_BLK_DEV_TRM290=y
CONFIG_BLK_DEV_VIA82CXXX=y
# CONFIG_BLK_DEV_TC86C001 is not set
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=y
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
CONFIG_CHR_DEV_OSST=y
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=y
# CONFIG_CHR_DEV_SCH is not set
CONFIG_SCSI_ENCLOSURE=y
CONFIG_SCSI_MULTI_LUN=y
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
# CONFIG_SCSI_FC_TGT_ATTRS is not set
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_ATA is not set
# CONFIG_SCSI_SAS_HOST_SMP is not set
CONFIG_SCSI_SRP_ATTRS=y
# CONFIG_SCSI_SRP_TGT_ATTRS is not set
# CONFIG_SCSI_LOWLEVEL is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
# CONFIG_ATA_VERBOSE_ERROR is not set
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
CONFIG_SATA_AHCI_PLATFORM=y
# CONFIG_SATA_INIC162X is not set
CONFIG_SATA_ACARD_AHCI=y
CONFIG_SATA_SIL24=y
# CONFIG_ATA_SFF is not set

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=y
CONFIG_SATA_QSTOR=y
CONFIG_SATA_SX4=y
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=y
CONFIG_SATA_HIGHBANK=y
CONFIG_SATA_MV=y
# CONFIG_SATA_NV is not set
CONFIG_SATA_PROMISE=y
CONFIG_SATA_SIL=y
CONFIG_SATA_SIS=y
CONFIG_SATA_SVW=y
CONFIG_SATA_ULI=y
# CONFIG_SATA_VIA is not set
CONFIG_SATA_VITESSE=y

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=y
CONFIG_PATA_AMD=y
CONFIG_PATA_ARTOP=y
# CONFIG_PATA_ATIIXP is not set
CONFIG_PATA_ATP867X=y
CONFIG_PATA_CMD64X=y
CONFIG_PATA_CS5520=y
# CONFIG_PATA_CS5530 is not set
CONFIG_PATA_CS5536=y
CONFIG_PATA_CYPRESS=y
CONFIG_PATA_EFAR=y
CONFIG_PATA_HPT366=y
CONFIG_PATA_HPT37X=y
CONFIG_PATA_HPT3X2N=y
CONFIG_PATA_HPT3X3=y
CONFIG_PATA_HPT3X3_DMA=y
CONFIG_PATA_IT8213=y
CONFIG_PATA_IT821X=y
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_NETCELL is not set
CONFIG_PATA_NINJA32=y
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_OPTIDMA is not set
CONFIG_PATA_PDC2027X=y
CONFIG_PATA_PDC_OLD=y
CONFIG_PATA_RADISYS=y
# CONFIG_PATA_RDC is not set
# CONFIG_PATA_SC1200 is not set
CONFIG_PATA_SCH=y
CONFIG_PATA_SERVERWORKS=y
# CONFIG_PATA_SIL680 is not set
CONFIG_PATA_SIS=y
CONFIG_PATA_TOSHIBA=y
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
CONFIG_PATA_MPIIX=y
CONFIG_PATA_NS87410=y
CONFIG_PATA_OPTI=y
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
CONFIG_ATA_GENERIC=y
CONFIG_PATA_LEGACY=y
# CONFIG_MD is not set
CONFIG_TARGET_CORE=y
CONFIG_TCM_IBLOCK=y
CONFIG_TCM_FILEIO=y
CONFIG_TCM_PSCSI=y
CONFIG_LOOPBACK_TARGET=y
# CONFIG_ISCSI_TARGET is not set
CONFIG_SBP_TARGET=y
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
# CONFIG_FIREWIRE_OHCI is not set
CONFIG_FIREWIRE_SBP2=y
CONFIG_FIREWIRE_NOSY=y
CONFIG_I2O=y
CONFIG_I2O_LCT_NOTIFY_ON_CHANGES=y
CONFIG_I2O_EXT_ADAPTEC=y
CONFIG_I2O_EXT_ADAPTEC_DMA64=y
# CONFIG_I2O_CONFIG is not set
# CONFIG_I2O_BUS is not set
CONFIG_I2O_BLOCK=y
# CONFIG_I2O_SCSI is not set
CONFIG_I2O_PROC=y
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
CONFIG_NETDEVICES=y
# CONFIG_NET_CORE is not set
# CONFIG_ARCNET is not set
# CONFIG_ATM_DRIVERS is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_NET_DSA_MV88E6XXX=y
# CONFIG_NET_DSA_MV88E6060 is not set
CONFIG_NET_DSA_MV88E6XXX_NEED_PPU=y
CONFIG_NET_DSA_MV88E6131=y
CONFIG_NET_DSA_MV88E6123_61_65=y
# CONFIG_ETHERNET is not set
CONFIG_FDDI=y
# CONFIG_DEFXX is not set
# CONFIG_SKFP is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AT803X_PHY is not set
CONFIG_AMD_PHY=y
CONFIG_MARVELL_PHY=y
# CONFIG_DAVICOM_PHY is not set
CONFIG_QSEMI_PHY=y
CONFIG_LXT_PHY=y
# CONFIG_CICADA_PHY is not set
CONFIG_VITESSE_PHY=y
# CONFIG_SMSC_PHY is not set
# CONFIG_BROADCOM_PHY is not set
CONFIG_BCM87XX_PHY=y
CONFIG_ICPLUS_PHY=y
CONFIG_REALTEK_PHY=y
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
CONFIG_MICREL_PHY=y
# CONFIG_FIXED_PHY is not set
CONFIG_MDIO_BITBANG=y
CONFIG_MDIO_GPIO=y
CONFIG_MICREL_KS8995MA=y
# CONFIG_PPP is not set
CONFIG_SLIP=y
# CONFIG_SLIP_COMPRESSED is not set
# CONFIG_SLIP_SMART is not set
# CONFIG_SLIP_MODE_SLIP6 is not set
# CONFIG_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_IEEE802154_DRIVERS is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
# CONFIG_INPUT_SPARSEKMAP is not set
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
# CONFIG_INPUT_EVDEV is not set
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5588=y
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
CONFIG_KEYBOARD_QT2160=y
CONFIG_KEYBOARD_LKKBD=y
CONFIG_KEYBOARD_GPIO=y
# CONFIG_KEYBOARD_GPIO_POLLED is not set
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_MATRIX=y
CONFIG_KEYBOARD_LM8323=y
CONFIG_KEYBOARD_LM8333=y
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
CONFIG_KEYBOARD_NEWTON=y
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_STMPE=y
# CONFIG_KEYBOARD_TWL4030 is not set
CONFIG_KEYBOARD_XTKBD=y
CONFIG_KEYBOARD_CROS_EC=y
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_88PM860X_ONKEY is not set
CONFIG_INPUT_88PM80X_ONKEY=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
CONFIG_INPUT_PCSPKR=y
# CONFIG_INPUT_MC13783_PWRBUTTON is not set
# CONFIG_INPUT_MMA8450 is not set
CONFIG_INPUT_MPU3050=y
CONFIG_INPUT_APANEL=y
CONFIG_INPUT_GP2A=y
# CONFIG_INPUT_GPIO_TILT_POLLED is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
CONFIG_INPUT_KXTJ9=y
CONFIG_INPUT_KXTJ9_POLLED_MODE=y
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_RETU_PWRBUTTON=y
CONFIG_INPUT_TWL4030_PWRBUTTON=y
# CONFIG_INPUT_TWL4030_VIBRA is not set
CONFIG_INPUT_UINPUT=y
# CONFIG_INPUT_PCF50633_PMU is not set
# CONFIG_INPUT_PCF8574 is not set
CONFIG_INPUT_GPIO_ROTARY_ENCODER=y
CONFIG_INPUT_DA9052_ONKEY=y
CONFIG_INPUT_WM831X_ON=y
# CONFIG_INPUT_ADXL34X is not set
CONFIG_INPUT_CMA3000=y
# CONFIG_INPUT_CMA3000_I2C is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=y
# CONFIG_CYCLADES is not set
CONFIG_MOXA_INTELLIO=y
# CONFIG_MOXA_SMARTIO is not set
CONFIG_SYNCLINK=y
CONFIG_SYNCLINKMP=y
CONFIG_SYNCLINK_GT=y
CONFIG_NOZOMI=y
# CONFIG_ISI is not set
CONFIG_N_HDLC=y
CONFIG_N_GSM=y
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
# CONFIG_DEVKMEM is not set
# CONFIG_STALDRV is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
# CONFIG_SERIAL_8250_RSA is not set
CONFIG_SERIAL_8250_DW=y

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
CONFIG_SERIAL_MAX310X=y
CONFIG_SERIAL_MFD_HSU=y
CONFIG_SERIAL_MFD_HSU_CONSOLE=y
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=y
CONFIG_SERIAL_SCCNXP_CONSOLE=y
CONFIG_SERIAL_TIMBERDALE=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_ALTERA_UART_CONSOLE is not set
# CONFIG_SERIAL_IFX6X60 is not set
CONFIG_SERIAL_PCH_UART=y
# CONFIG_SERIAL_PCH_UART_CONSOLE is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_WATCHDOG=y
# CONFIG_IPMI_POWEROFF is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_HW_RANDOM_TPM=y
CONFIG_NVRAM=y
CONFIG_R3964=y
CONFIG_APPLICOM=y
CONFIG_MWAVE=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_I2C_INFINEON=y
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
CONFIG_TCG_ST33_I2C=y
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
# CONFIG_I2C_MUX_PCA9541 is not set
# CONFIG_I2C_MUX_PCA954x is not set
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
CONFIG_I2C_AMD756=y
# CONFIG_I2C_AMD756_S4882 is not set
CONFIG_I2C_AMD8111=y
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
# CONFIG_I2C_NFORCE2 is not set
CONFIG_I2C_SIS5595=y
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PCI=y
CONFIG_I2C_EG20T=y
CONFIG_I2C_GPIO=y
# CONFIG_I2C_INTEL_MID is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT_LIGHT is not set
CONFIG_I2C_TAOS_EVM=y

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
CONFIG_SPI_BITBANG=y
CONFIG_SPI_GPIO=y
CONFIG_SPI_OC_TINY=y
CONFIG_SPI_PXA2XX_DMA=y
CONFIG_SPI_PXA2XX=y
CONFIG_SPI_PXA2XX_PCI=y
# CONFIG_SPI_SC18IS602 is not set
CONFIG_SPI_TOPCLIFF_PCH=y
CONFIG_SPI_XCOMM=y
CONFIG_SPI_XILINX=y
CONFIG_SPI_DESIGNWARE=y
# CONFIG_SPI_DW_PCI is not set

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y

#
# Qualcomm MSM SSBI bus support
#
CONFIG_SSBI=y
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI clients
#
CONFIG_HSI_CHAR=y

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
# CONFIG_PPS_CLIENT_LDISC is not set
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
# CONFIG_GPIO_DA9052 is not set
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_IT8761E is not set
CONFIG_GPIO_TS5500=y
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
# CONFIG_GPIO_MAX732X_IRQ is not set
# CONFIG_GPIO_PCA953X is not set
CONFIG_GPIO_PCF857X=y
# CONFIG_GPIO_RC5T583 is not set
# CONFIG_GPIO_SX150X is not set
# CONFIG_GPIO_STMPE is not set
CONFIG_GPIO_TWL4030=y
CONFIG_GPIO_WM831X=y
# CONFIG_GPIO_WM8350 is not set
CONFIG_GPIO_ADP5588=y
CONFIG_GPIO_ADP5588_IRQ=y

#
# PCI GPIO expanders:
#
CONFIG_GPIO_CS5535=y
# CONFIG_GPIO_BT8XX is not set
CONFIG_GPIO_AMD8111=y
CONFIG_GPIO_LANGWELL=y
# CONFIG_GPIO_PCH is not set
CONFIG_GPIO_ML_IOH=y
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
CONFIG_GPIO_MAX7301=y
CONFIG_GPIO_MCP23S08=y
CONFIG_GPIO_MC33880=y
CONFIG_GPIO_74X164=y

#
# AC97 GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
CONFIG_GPIO_JANZ_TTL=y
CONFIG_GPIO_PALMAS=y

#
# USB GPIO expanders:
#
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
# CONFIG_W1_SLAVE_SMEM is not set
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2408_READBACK=y
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2431=y
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2760=y
# CONFIG_W1_SLAVE_DS2780 is not set
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
# CONFIG_W1_SLAVE_BQ27000 is not set
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=y
CONFIG_WM831X_BACKUP=y
CONFIG_WM831X_POWER=y
CONFIG_WM8350_POWER=y
CONFIG_TEST_POWER=y
# CONFIG_BATTERY_88PM860X is not set
CONFIG_BATTERY_DS2760=y
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
CONFIG_BATTERY_BQ27x00=y
# CONFIG_BATTERY_BQ27X00_I2C is not set
CONFIG_BATTERY_BQ27X00_PLATFORM=y
CONFIG_BATTERY_DA9030=y
CONFIG_BATTERY_DA9052=y
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_CHARGER_PCF50633=y
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_TWL4030=y
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_MAX8998 is not set
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_SMB347=y
CONFIG_BATTERY_GOLDFISH=y
CONFIG_POWER_RESET=y
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
CONFIG_SENSORS_ABITUGURU3=y
# CONFIG_SENSORS_AD7314 is not set
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
# CONFIG_SENSORS_K10TEMP is not set
CONFIG_SENSORS_FAM15H_POWER=y
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DA9052_ADC=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_CORETEMP=y
# CONFIG_SENSORS_IBMAEM is not set
CONFIG_SENSORS_IBMPEX=y
# CONFIG_SENSORS_IT87 is not set
CONFIG_SENSORS_JC42=y
# CONFIG_SENSORS_LINEAGE is not set
# CONFIG_SENSORS_LM63 is not set
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LTC4151=y
# CONFIG_SENSORS_LTC4215 is not set
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4261=y
# CONFIG_SENSORS_LM95234 is not set
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_MAX1111=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
# CONFIG_SENSORS_MAX1668 is not set
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
# CONFIG_SENSORS_PCF8591 is not set
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
# CONFIG_SENSORS_LM25066 is not set
# CONFIG_SENSORS_LTC2978 is not set
CONFIG_SENSORS_MAX16064=y
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
# CONFIG_SENSORS_UCD9000 is not set
CONFIG_SENSORS_UCD9200=y
# CONFIG_SENSORS_ZL6100 is not set
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SIS5595=y
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_EMC1403 is not set
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_SCH56XX_COMMON is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
# CONFIG_SENSORS_AMC6821 is not set
# CONFIG_SENSORS_INA209 is not set
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_THMC50=y
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP401 is not set
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=y
# CONFIG_SENSORS_W83781D is not set
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
# CONFIG_SENSORS_W83627HF is not set
CONFIG_SENSORS_W83627EHF=y
# CONFIG_SENSORS_WM831X is not set
CONFIG_SENSORS_WM8350=y
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_MC13783_ADC=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_CPU_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
# CONFIG_BCMA_DRIVER_GPIO is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_CS5535=y
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_AAT2870_CORE=y
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
# CONFIG_MFD_CROS_EC_SPI is not set
CONFIG_PMIC_DA903X=y
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
CONFIG_MFD_DA9052_I2C=y
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_MC13783=y
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
# CONFIG_LPC_ICH is not set
CONFIG_LPC_SCH=y
CONFIG_MFD_JANZ_CMODIO=y
CONFIG_MFD_88PM800=y
# CONFIG_MFD_88PM805 is not set
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
# CONFIG_EZX_PCAP is not set
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RC5T583=y
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=y
CONFIG_MFD_SM501_GPIO=y
# CONFIG_MFD_SMSC is not set
CONFIG_ABX500_CORE=y
# CONFIG_AB3100_CORE is not set
CONFIG_MFD_STMPE=y

#
# STMicroelectronics STMPE Interface Drivers
#
CONFIG_STMPE_I2C=y
# CONFIG_STMPE_SPI is not set
# CONFIG_MFD_SYSCON is not set
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP8788=y
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
CONFIG_TPS65010=y
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
# CONFIG_MFD_TPS65912 is not set
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS65912_SPI is not set
CONFIG_MFD_TPS80031=y
CONFIG_TWL4030_CORE=y
# CONFIG_TWL4030_MADC is not set
CONFIG_MFD_TWL4030_AUDIO=y
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TIMBERDALE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_ARIZONA_SPI is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM831X_SPI=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
# CONFIG_REGULATOR_DUMMY is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_AAT2870=y
# CONFIG_REGULATOR_DA903X is not set
CONFIG_REGULATOR_DA9052=y
# CONFIG_REGULATOR_FAN53555 is not set
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
# CONFIG_REGULATOR_MC13892 is not set
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_88PM8607=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8952=y
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX8998=y
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
# CONFIG_REGULATOR_LP8788 is not set
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_RC5T583=y
# CONFIG_REGULATOR_PALMAS is not set
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65217=y
CONFIG_REGULATOR_TPS6524X=y
# CONFIG_REGULATOR_TPS80031 is not set
# CONFIG_REGULATOR_TWL4030 is not set
# CONFIG_REGULATOR_WM831X is not set
# CONFIG_REGULATOR_WM8350 is not set
CONFIG_REGULATOR_WM8400=y
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
# CONFIG_AGP_INTEL is not set
# CONFIG_AGP_SIS is not set
CONFIG_AGP_VIA=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
# CONFIG_DRM_TTM is not set

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=y
CONFIG_DRM_I2C_SIL164=y
# CONFIG_DRM_I2C_NXP_TDA998X is not set
CONFIG_DRM_TDFX=y
CONFIG_DRM_R128=y
CONFIG_DRM_RADEON=y
# CONFIG_DRM_RADEON_UMS is not set
# CONFIG_DRM_NOUVEAU is not set
CONFIG_DRM_MGA=y
# CONFIG_DRM_SIS is not set
CONFIG_DRM_VIA=y
CONFIG_DRM_SAVAGE=y
CONFIG_DRM_VMWGFX=y
CONFIG_DRM_VMWGFX_FBCON=y
CONFIG_DRM_GMA500=y
CONFIG_DRM_GMA600=y
CONFIG_DRM_GMA3600=y
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
CONFIG_DRM_MGAG200=y
CONFIG_DRM_CIRRUS_QEMU=y
CONFIG_DRM_QXL=y
CONFIG_VGASTATE=y
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_HDMI=y
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
# CONFIG_FB_BOTH_ENDIAN is not set
CONFIG_FB_BIG_ENDIAN=y
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=y
# CONFIG_FB_PM2 is not set
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
CONFIG_FB_ARC=y
CONFIG_FB_ASILIANT=y
CONFIG_FB_IMSTT=y
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=y
CONFIG_FB_VESA=y
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
CONFIG_FB_NVIDIA_I2C=y
CONFIG_FB_NVIDIA_DEBUG=y
CONFIG_FB_NVIDIA_BACKLIGHT=y
CONFIG_FB_RIVA=y
# CONFIG_FB_RIVA_I2C is not set
# CONFIG_FB_RIVA_DEBUG is not set
# CONFIG_FB_RIVA_BACKLIGHT is not set
CONFIG_FB_I740=y
CONFIG_FB_LE80578=y
# CONFIG_FB_CARILLO_RANCH is not set
CONFIG_FB_MATROX=y
# CONFIG_FB_MATROX_MILLENIUM is not set
# CONFIG_FB_MATROX_MYSTIQUE is not set
# CONFIG_FB_MATROX_G is not set
# CONFIG_FB_MATROX_I2C is not set
CONFIG_FB_RADEON=y
CONFIG_FB_RADEON_I2C=y
# CONFIG_FB_RADEON_BACKLIGHT is not set
CONFIG_FB_RADEON_DEBUG=y
CONFIG_FB_ATY128=y
CONFIG_FB_ATY128_BACKLIGHT=y
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
CONFIG_FB_SAVAGE=y
# CONFIG_FB_SAVAGE_I2C is not set
CONFIG_FB_SAVAGE_ACCEL=y
# CONFIG_FB_SIS is not set
CONFIG_FB_VIA=y
CONFIG_FB_VIA_DIRECT_PROCFS=y
CONFIG_FB_VIA_X_COMPATIBILITY=y
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
CONFIG_FB_3DFX_ACCEL=y
CONFIG_FB_3DFX_I2C=y
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
CONFIG_FB_TMIO=y
# CONFIG_FB_TMIO_ACCELL is not set
CONFIG_FB_SM501=y
# CONFIG_FB_GOLDFISH is not set
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
CONFIG_FB_BROADSHEET=y
CONFIG_FB_AUO_K190X=y
# CONFIG_FB_AUO_K1900 is not set
CONFIG_FB_AUO_K1901=y
CONFIG_EXYNOS_VIDEO=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_L4F00242T03=y
CONFIG_LCD_LMS283GF05=y
CONFIG_LCD_LTV350QV=y
CONFIG_LCD_ILI922X=y
CONFIG_LCD_ILI9320=y
CONFIG_LCD_TDO24M=y
CONFIG_LCD_VGG2432A4=y
CONFIG_LCD_PLATFORM=y
CONFIG_LCD_S6E63M0=y
# CONFIG_LCD_LD9040 is not set
# CONFIG_LCD_AMS369FG06 is not set
CONFIG_LCD_LMS501KF03=y
CONFIG_LCD_HX8357=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_LM3533 is not set
CONFIG_BACKLIGHT_CARILLO_RANCH=y
CONFIG_BACKLIGHT_DA903X=y
CONFIG_BACKLIGHT_DA9052=y
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_WM831X is not set
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_88PM860X=y
# CONFIG_BACKLIGHT_PCF50633 is not set
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3630=y
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_LP855X=y
# CONFIG_BACKLIGHT_LP8788 is not set
CONFIG_BACKLIGHT_PANDORA=y
CONFIG_BACKLIGHT_TPS65217=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
CONFIG_FONTS=y
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
# CONFIG_FONT_6x11 is not set
CONFIG_FONT_7x14=y
CONFIG_FONT_PEARL_8x8=y
# CONFIG_FONT_ACORN_8x8 is not set
CONFIG_FONT_MINI_4x6=y
CONFIG_FONT_SUN8x16=y
CONFIG_FONT_SUN12x22=y
# CONFIG_FONT_10x18 is not set
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
# CONFIG_LOGO_LINUX_CLUT224 is not set
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
CONFIG_HID_UCLOGIC=y
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
# CONFIG_HID_TWINHAN is not set
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
CONFIG_HID_LOGITECH=y
# CONFIG_HID_LOGITECH_DJ is not set
CONFIG_LOGITECH_FF=y
CONFIG_LOGIRUMBLEPAD2_FF=y
CONFIG_LOGIG940_FF=y
# CONFIG_LOGIWHEELS_FF is not set
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
# CONFIG_HID_ORTEK is not set
CONFIG_HID_PANTHERLORD=y
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_PS3REMOTE is not set
CONFIG_HID_SAITEK=y
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
CONFIG_HID_TIVO=y
CONFIG_HID_TOPSEED=y
# CONFIG_HID_THINGM is not set
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
# CONFIG_HID_WACOM is not set
CONFIG_HID_WIIMOTE=y
# CONFIG_HID_WIIMOTE_EXT is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
CONFIG_HID_SENSOR_HUB=y

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set

#
# USB port drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_USB_GADGET is not set
CONFIG_UWB=y
CONFIG_UWB_WHCI=y
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
CONFIG_MMC_UNSAFE_RESUME=y
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
# CONFIG_MMC_BLOCK is not set
CONFIG_SDIO_UART=y
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
CONFIG_MMC_SDHCI_PCI=y
# CONFIG_MMC_RICOH_MMC is not set
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
CONFIG_MMC_SPI=y
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
# CONFIG_MSPRO_BLOCK is not set

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
CONFIG_MEMSTICK_JMICRON_38X=y
CONFIG_MEMSTICK_R592=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_88PM860X is not set
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_PCA9532_GPIO=y
# CONFIG_LEDS_GPIO is not set
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8788=y
CONFIG_LEDS_CLEVO_MAIL=y
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA9633=y
CONFIG_LEDS_WM831X_STATUS=y
CONFIG_LEDS_WM8350=y
# CONFIG_LEDS_DA903X is not set
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_OT200=y
CONFIG_LEDS_BLINKM=y

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGERS is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_INFINIBAND=y
# CONFIG_INFINIBAND_USER_MAD is not set
# CONFIG_INFINIBAND_USER_ACCESS is not set
# CONFIG_INFINIBAND_MTHCA is not set
CONFIG_INFINIBAND_QIB=y
# CONFIG_INFINIBAND_SRP is not set
# CONFIG_INFINIBAND_SRPT is not set
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=y
CONFIG_EDAC_MCE_INJ=y
# CONFIG_EDAC_MM_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
# CONFIG_RTC_INTF_DEV is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_88PM860X is not set
# CONFIG_RTC_DRV_88PM80X is not set
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_DS3232=y
CONFIG_RTC_DRV_LP8788=y
CONFIG_RTC_DRV_MAX6900=y
# CONFIG_RTC_DRV_MAX8907 is not set
CONFIG_RTC_DRV_MAX8998=y
CONFIG_RTC_DRV_RS5C372=y
# CONFIG_RTC_DRV_ISL1208 is not set
CONFIG_RTC_DRV_ISL12022=y
CONFIG_RTC_DRV_X1205=y
CONFIG_RTC_DRV_PALMAS=y
# CONFIG_RTC_DRV_PCF8523 is not set
CONFIG_RTC_DRV_PCF8563=y
CONFIG_RTC_DRV_PCF8583=y
# CONFIG_RTC_DRV_M41T80 is not set
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_TWL4030=y
CONFIG_RTC_DRV_TPS80031=y
CONFIG_RTC_DRV_RC5T583=y
CONFIG_RTC_DRV_S35390A=y
# CONFIG_RTC_DRV_FM3130 is not set
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
CONFIG_RTC_DRV_EM3027=y
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
# CONFIG_RTC_DRV_M41T94 is not set
CONFIG_RTC_DRV_DS1305=y
# CONFIG_RTC_DRV_DS1390 is not set
CONFIG_RTC_DRV_MAX6902=y
# CONFIG_RTC_DRV_R9701 is not set
# CONFIG_RTC_DRV_RS5C348 is not set
CONFIG_RTC_DRV_DS3234=y
CONFIG_RTC_DRV_PCF2123=y
CONFIG_RTC_DRV_RX4581=y

#
# Platform RTC drivers
#
# CONFIG_RTC_DRV_CMOS is not set
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
# CONFIG_RTC_DRV_DS1553 is not set
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_DA9052=y
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
CONFIG_RTC_DRV_M48T35=y
# CONFIG_RTC_DRV_M48T59 is not set
CONFIG_RTC_DRV_MSM6242=y
# CONFIG_RTC_DRV_BQ4802 is not set
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y
# CONFIG_RTC_DRV_DS2404 is not set
# CONFIG_RTC_DRV_WM831X is not set
CONFIG_RTC_DRV_WM8350=y
CONFIG_RTC_DRV_PCF50633=y

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_MC13XXX=y

#
# HID Sensor RTC drivers
#
# CONFIG_DMADEVICES is not set
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
CONFIG_UIO_PDRV=y
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
# CONFIG_UIO_SERCOS3 is not set
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_CHROMEOS_LAPTOP=y
# CONFIG_DELL_LAPTOP is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_EEEPC_LAPTOP is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
CONFIG_IBM_RTL=y
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_LAPTOP is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_PVPANIC is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
CONFIG_DEVFREQ_GOV_POWERSAVE=y
# CONFIG_DEVFREQ_GOV_USERSPACE is not set

#
# DEVFREQ Drivers
#
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_GPIO is not set
CONFIG_MEMORY=y
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
CONFIG_IPACK_BUS=y
CONFIG_BOARD_TPCI200=y
CONFIG_SERIAL_IPOCTAL=y
CONFIG_RESET_CONTROLLER=y

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_DMIID is not set
# CONFIG_DMI_SYSFS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
CONFIG_EXT2_FS_XIP=y
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
# CONFIG_EXT4_FS_POSIX_ACL is not set
# CONFIG_EXT4_FS_SECURITY is not set
# CONFIG_EXT4_DEBUG is not set
CONFIG_FS_XIP=y
CONFIG_JBD=y
CONFIG_JBD_DEBUG=y
CONFIG_JBD2=y
CONFIG_JBD2_DEBUG=y
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
CONFIG_REISERFS_PROC_INFO=y
# CONFIG_REISERFS_FS_XATTR is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=y
# CONFIG_XFS_QUOTA is not set
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
CONFIG_XFS_DEBUG=y
CONFIG_GFS2_FS=y
CONFIG_OCFS2_FS=y
CONFIG_OCFS2_FS_O2CB=y
# CONFIG_OCFS2_FS_STATS is not set
CONFIG_OCFS2_DEBUG_MASKLOG=y
CONFIG_OCFS2_DEBUG_FS=y
# CONFIG_BTRFS_FS is not set
# CONFIG_NILFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
# CONFIG_INOTIFY_USER is not set
CONFIG_FANOTIFY=y
# CONFIG_FANOTIFY_ACCESS_PERMISSIONS is not set
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
# CONFIG_PRINT_QUOTA_WARNING is not set
CONFIG_QUOTA_DEBUG=y
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
CONFIG_FSCACHE_HISTOGRAM=y
CONFIG_FSCACHE_DEBUG=y
CONFIG_FSCACHE_OBJECT_LIST=y
# CONFIG_CACHEFILES is not set

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
# CONFIG_TMPFS is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
CONFIG_AFFS_FS=y
CONFIG_ECRYPT_FS=y
# CONFIG_ECRYPT_FS_MESSAGING is not set
# CONFIG_HFS_FS is not set
CONFIG_HFSPLUS_FS=y
CONFIG_BEFS_FS=y
CONFIG_BEFS_DEBUG=y
CONFIG_BFS_FS=y
CONFIG_EFS_FS=y
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
# CONFIG_JFFS2_FS_WRITEBUFFER is not set
# CONFIG_JFFS2_SUMMARY is not set
CONFIG_JFFS2_FS_XATTR=y
# CONFIG_JFFS2_FS_POSIX_ACL is not set
# CONFIG_JFFS2_FS_SECURITY is not set
# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
CONFIG_JFFS2_ZLIB=y
# CONFIG_JFFS2_LZO is not set
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
# CONFIG_UBIFS_FS is not set
# CONFIG_LOGFS is not set
# CONFIG_CRAMFS is not set
CONFIG_SQUASHFS=y
# CONFIG_SQUASHFS_XATTR is not set
# CONFIG_SQUASHFS_ZLIB is not set
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
CONFIG_SQUASHFS_4K_DEVBLK_SIZE=y
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=y
# CONFIG_MINIX_FS is not set
CONFIG_OMFS_FS=y
CONFIG_HPFS_FS=y
CONFIG_QNX4FS_FS=y
CONFIG_QNX6FS_FS=y
# CONFIG_QNX6FS_DEBUG is not set
CONFIG_ROMFS_FS=y
# CONFIG_ROMFS_BACKED_BY_BLOCK is not set
# CONFIG_ROMFS_BACKED_BY_MTD is not set
CONFIG_ROMFS_BACKED_BY_BOTH=y
CONFIG_ROMFS_ON_BLOCK=y
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
CONFIG_PSTORE_CONSOLE=y
# CONFIG_PSTORE_RAM is not set
CONFIG_SYSV_FS=y
# CONFIG_UFS_FS is not set
# CONFIG_F2FS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
# CONFIG_LOCKUP_DETECTOR is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_PREEMPT is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_RB is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_WRITECOUNT is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_LIST=y
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_BOOT_PRINTK_DELAY is not set

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
# CONFIG_PROVE_RCU_REPEATEDLY is not set
CONFIG_PROVE_RCU_DELAY=y
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_CPU_STALL_VERBOSE=y
CONFIG_RCU_CPU_STALL_INFO=y
CONFIG_RCU_TRACE=y
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_LKDTM=y
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_LATENCYTOP=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_BUILD_DOCSRC is not set
CONFIG_DYNAMIC_DEBUG=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
CONFIG_TEST_STRING_HELPERS=y
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_STRICT_DEVMEM is not set
# CONFIG_X86_VERBOSE_BOOTUP is not set
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_X86_PTDUMP=y
# CONFIG_DEBUG_RODATA is not set
CONFIG_DEBUG_TLBFLUSH=y
CONFIG_IOMMU_DEBUG=y
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
CONFIG_IO_DELAY_NONE=y
CONFIG_DEFAULT_IO_DELAY_TYPE=3
# CONFIG_DEBUG_BOOT_PARAMS is not set
CONFIG_CPA_DEBUG=y
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_NMI_SELFTEST is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_PATH=y
# CONFIG_SECURITY_TOMOYO is not set
CONFIG_SECURITY_APPARMOR=y
CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=1
# CONFIG_SECURITY_YAMA is not set
CONFIG_INTEGRITY=y
CONFIG_INTEGRITY_SIGNATURE=y
# CONFIG_INTEGRITY_ASYMMETRIC_KEYS is not set
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
# CONFIG_IMA_AUDIT is not set
CONFIG_IMA_APPRAISE=y
CONFIG_EVM=y
CONFIG_EVM_HMAC_VERSION=2
CONFIG_DEFAULT_SECURITY_APPARMOR=y
# CONFIG_DEFAULT_SECURITY_DAC is not set
CONFIG_DEFAULT_SECURITY="apparmor"
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_FIPS=y
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER_X86=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
# CONFIG_CRYPTO_GHASH is not set
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
# CONFIG_CRYPTO_RMD256 is not set
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
# CONFIG_CRYPTO_SHA256_SSSE3 is not set
CONFIG_CRYPTO_SHA512_SSSE3=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_BLOWFISH_AVX2_X86_64=y
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
# CONFIG_CRYPTO_SERPENT_AVX_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y
# CONFIG_CRYPTO_TWOFISH_AVX2_X86_64 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
# CONFIG_CRYPTO_LZO is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
# CONFIG_X509_CERTIFICATE_PARSER is not set
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
CONFIG_CRC32_SLICEBY4=y
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
# CONFIG_XZ_DEC_ARMTHUMB is not set
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_SIGNATURE=y
# CONFIG_IIO_SIMPLE_DUMMY is not set
# CONFIG_ISDN_DRV_LOOP is not set
# CONFIG_PCI_ATS is not set

--6TrnltStXW4iwmi0
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--6TrnltStXW4iwmi0--
