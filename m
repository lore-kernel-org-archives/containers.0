From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.31-rc8, created. v2.6.31-rc8
Date: Wed, 16 Sep 2009 14:36:59 -0400
Message-ID: <200909161836.n8GIax9R001715@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3271047029813285755=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

--===============3271047029813285755==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GIu1Df005279

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.31-rc8 has been created
        at  da1ee8b71154887fe5298ae683c089050f2c49a5 (tag)
   tagging  326ba5010a5429a5a528b268b36a5900d4ab0eba (commit)
  replaces  v2.6.31-rc7
 tagged by  Linus Torvalds
        on  Thu Aug 27 17:59:15 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.31-rc8
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkqXK+YACgkQF3YsRnbiHLsm9gCfZyxaVy44Q72pkjLkBlA9QcQf
CUcAoIRr6pjXA89Vju0uZn3x7SHI/5nj
=3Do6jm
-----END PGP SIGNATURE-----

Abhishek Kulkarni (10):
      9p: Check for error in return value of v9fs_fid_add
      9p: Fix possible inode leak in v9fs_get_inode.
      9p: minor comment fixes
      9p: Fix possible memleak in v9fs_inode_from fid.
      9p: Fix v9fs show_options
      9p: Fix possible regressions when ->get_sb fails.
      9p: Remove redundant inode uid/gid assignment
      9p: Add missing cast for the error return value in v9fs_get_inode
      net/9p: insulate the client against an invalid error code sent by a=
 9p server
      9p: remove unnecessary v9fses->options which duplicates the mount s=
tring

Alek Du (1):
      PCI: check saved state before restore

Alexander Beregalov (2):
      irda/au1k_ir: fix broken netdev_ops conversion
      irda/sa1100_ir: fix broken netdev_ops conversion

Alexey Dobriyan (2):
      smc91x: fix compilation on SMP
      m68k: Fix redefinition of pgprot_noncached

Amerigo Wang (2):
      timers: Drop write permission on /proc/timer_list
      x86: Fix an incorrect argument of reserve_bootmem()

Andreas Mohr (1):
      net: Fix Micrel KSZ8842 Kconfig description

Andrew Morton (1):
      arch/m68k/include/asm/motorola_pgalloc.h: fix kunmap arg

Bartlomiej Zolnierkiewicz (1):
      ALSA: ali5451: fix timeout handling in snd_ali_{codecs,timer}_ready=
()

Ben Nizette (1):
      favr32: improve touchscreen response

Benjamin Herrenschmidt (1):
      lmb: Remove __init from lmb_end_of_DRAM()

Bruno Pr=C3=A9mont (1):
      ipv6: Fix commit 63d9950b08184e6531adceb65f64b429909cc101 (ipv6: Ma=
ke v4-mapped bindings consistent with IPv4)

Clemens Ladisch (2):
      sound: vx222: fix input level control range check
      sound: pcm_lib: fix unsorted list constraint handling

Costantino Leandro (1):
      wmi: fix kernel panic when stack protection enabled.

David Howells (1):
      AFS: Stop readlink() on AFS crashing due to NULL 'file' ptr

David Rientjes (4):
      flex_array: fix get function for elements in base starting at non-z=
ero
      flex_array: fix flex_array_free_parts comment
      flex_array: declare parts member to have incomplete type
      flex_array: convert element_nr formals to unsigned

David S. Miller (12):
      sparc: Fix cleanup crash in bbc_envctrl_cleanup()
      sparc64: Sign extend length arg to truncate syscalls when compat.
      sparc: Use page_fault_out_of_memory() for VM_FAULT_OOM.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      sparc32: Kill trap table freeing code.
      sparc32: Update defconfig.
      sparc64: Update defconfig.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      pkt_sched: Convert qdisc_watchdog to tasklet_hrtimer
      pkt_sched: Convert CBQ to tasklet_hrtimer.
      pkt_sched: Fix bogon in tasklet_hrtimer changes.
      sparc64: Validate linear D-TLB misses.

Dmitry Torokhov (1):
      Input: wacom - don't use on-stack memory for report buffers

Dongdong Deng (3):
      netpoll: warning for ndo_start_xmit returns with interrupts enabled
      drivers/net: fixed drivers that support netpoll use ndo_start_xmit(=
)
      smc91x: let smc91x work well under netpoll

Eric Paris (4):
      IMA: iint put in ima_counts_get and put
      inotify: seperate new watch creation updating existing watches
      inotify: do not BUG on idr entries at inotify destruction
      inotify: fix locking around inotify watching in the idr

Eric Van Hensbergen (1):
      9p: update documentation pointers

Eric W. Biederman (1):
      inotify: Ensure we alwasy write the terminating NULL.

Florian Fainelli (1):
      [WATCHDOG] ar7_wdt: fix path to ar7-specific headers

Frans Pop (2):
      ACPI processor: force throttling state when BIOS returns incorrect =
value
      acpi processor: remove superfluous warning message

Geert Uytterhoeven (2):
      m68k,m68knommu: Wire up rt_tgsigqueueinfo and perf_counter_open
      powerpc/ps3: Add missing check for PS3 to rtc-ps3 platform device r=
egistration

Geoff Levand (1):
      powerpc/ps3: Update ps3_defconfig

Goldwyn Rodrigues (1):
      ocfs2/dlm: Wait on lockres instead of erroring cancel requests

Hendrik Brueckner (1):
      [S390] set preferred console based on conmode

Herton Ronaldo Krzesinski (1):
      rtl8187: always set MSR_LINK_ENEDCA flag with RTL8187B

Hugh Dickins (1):
      mm: fix hugetlb bug due to user_shm_unlock call

Ingo Molnar (2):
      Merge branch 'bugfix' of git://git.kernel.org/pub/scm/linux/kernel/=
git/jeremy/xen into x86/urgent
      tracing: Fix too large stack usage in do_one_initcall()

James Bottomley (1):
      module: workaround duplicate section names

Jan Beulich (3):
      i386: Fix section mismatches for init code with !HOTPLUG_CPU
      x86: add vmlinux.lds to targets in arch/x86/boot/compressed/Makefil=
e
      x86: Fix build with older binutils and consolidate linker script

Jan Kara (4):
      ocfs2: Handle quota file corruption more gracefully
      ocfs2: Don't oops in ocfs2_kill_sb on a failed mount
      ocfs2: Add missing lock name
      ext3: Improve error message that changing journaling mode on remoun=
t is not possible

Jeremy Fitzhardinge (3):
      x86: make sure load_percpu_segment has no stackprotector
      xen: rearrange things to fix stackprotector
      xenfb: connect to backend before registering fb

Jiri Kosina (1):
      Input: iforce - support new revision of ACT LABS Force RS

Jiri Olsa (1):
      tracing: handle broken names in ftrace filter

Jiri Slaby (1):
      NET: llc, zero sockaddr_llc struct

Johannes Berg (1):
      mac80211: fix todo lock

John Holland (1):
      [ARM] Kirkwood: enable eSATA on QNAP TS-219P

John W. Linville (1):
      orinoco: correct key bounds check in orinoco_hw_get_tkip_iv

Joonwoo Park (1):
      pps: fix incorrect verdict check

Julia Lawall (1):
      [S390] drivers/s390: put NULL test before dereference

Julien TINNES (1):
      ipv4: make ip_append_data() handle NULL routing table

Kashyap, Desai (9):
      [SCSI] mpt2sas: Introduced check for enclosure_handle to avoid cras=
h
      [SCSI] mpt2sas: Expander fix oops saying "Already part of another p=
ort"
      [SCSI] mpt2sas: Raid 10 Value is showing as Raid 1E in /va/log/mess=
ages
      [SCSI] mpt2sas: Excessive log info causes sas iounit page time out
      [SCSI] mpt2sas: fix infinite loop inside config request
      [SCSI] mpt2sas: fix crash due to Watchdog is active while OS in sta=
ndby mode
      [SCSI] mpt2sas: fix oops because drv data points to NULL on resume =
from hibernate
      [SCSI] mpt2sas: Bump driver version 01.100.04.00
      [SCSI] mpt2sas: fix config request and diag reset deadlock

Krzysztof Ha=C5=82asa (1):
      E100: fix interaction with swiotlb on X86.

Kyle McMartin (1):
      dma-debug: Fix check_unmap null pointer dereference

Linus Torvalds (27):
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-rc-fi=
xes-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/hskinnemoen/avr=
32-2.6
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge branch 'fixes' of git://git.marvell.com/orion
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jlbec/ocfs2
      tty: make sure to flush any pending work when halting the ldisc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-w=
atchdog
      Merge branch 'fix/misc' of git://git.kernel.org/pub/scm/linux/kerne=
l/git/tiwai/sound-2.6
      Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jack/linux-fs-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'tracing-fixes-for-linus' of git://git.kernel.org/pub/=
scm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'perfcounters-fixes-for-linus' of git://git.kernel.org=
/pub/scm/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/geert/linux-m68k
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ericvh/v9fs
      Merge branch 'for-linus' of git://git.infradead.org/users/eparis/no=
tify
      Linux 2.6.31-rc8

Marek Vasut (2):
      Input: ucb1400_ts - enable ADC Filter
      pxaficp-ir: remove incorrect net_device_ops

Martin Michlmayr (1):
      [ARM] Kirkwood: __init requires linux/init.h

Mathieu Desnoyers (1):
      sparc: sys32.S incorrect compat-layer splice() system call

Michael Brunner (1):
      thermal_sys: check get_temp return value

Michel D=C3=A4nzer (1):
      drm/radeon/kms: Fix radeon_gem_busy_ioctl harder.

Mimi Zohar (2):
      kernel_read: redefine offset type
      ima: hashing large files bug fix

Minchan Kim (1):
      mm: fix for infinite churning of mlocked pages

Oleg Nesterov (1):
      clone(): fix race between copy_process() and de_thread()

Patrick McHardy (1):
      netfilter: xt_quota: fix wrong return value (error case)

Pavel Revak (1):
      Input: ucb1400_ts - enable interrupt unconditionally

Peter Zijlstra (2):
      perf tools: Check perf.data owner
      perf_counter: Fix typo in read() output generation

Petri Gynther (1):
      ibm_newemac: emac_close() needs to call netif_carrier_off()

Randy Dunlap (1):
      net: fix ks8851 build errors

Roel Kluin (3):
      yellowfin: Fix buffer underrun after dev_alloc_skb() failure
      m68k: count can reach 51, not 50
      m68k: cnt reaches -1, not 0

Rusty Russell (2):
      virtio: net refill on out-of-memory
      module: fix BUG_ON() for powerpc (and other function descriptor arc=
hs)

Sebastian Andrzej Siewior (2):
      avr32/lib: fix unaligned memcpy()
      avr32/lib: fix unaligned memcpy where len < 4

Sebastian Ott (1):
      [S390] cio: fix double free after failed device initialization

Simon Kagstrom (1):
      [ARM] Orion NAND: Make asm volatile avoid GCC pushing ldrd out of t=
he loop

Stephen Kitt (1):
      Input: joydev - decouple axis and button map ioctls from input cons=
tants

Suresh Siddha (2):
      x86, pat: Allow ISA memory range uncacheable mapping requests
      clockevent: Prevent dead lock on clockevents_lock

Tao Ma (1):
      ocfs2: release the buffer head in ocfs2_do_truncate.

Thadeu Lima de Souza Cascardo (2):
      leds: fix multiple requests and releases of IRQ for GPIO LED Trigge=
r
      leds: after setting inverted attribute, we must update the LED

Theodore Ts'o (1):
      ext3: Update Kconfig description of EXT3_DEFAULTS_TO_ORDERED

Trond Myklebust (1):
      NFSv4: Fix an infinite looping problem with the nfs4_state_manager

Wan ZongShun (1):
      net: Rename MAC platform driver for w90p910 platform

Yinghai Lu (1):
      acpi: don't call acpi_processor_init if acpi is disabled

Zhaolei (1):
      ftrace: Unify effect of writing to trace_options and option/*

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============3271047029813285755==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============3271047029813285755==--
