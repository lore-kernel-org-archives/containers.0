From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.30-rc8, created. v2.6.30-rc8
Date: Wed, 16 Sep 2009 14:36:52 -0400
Message-ID: <200909161836.n8GIaqi5001529@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5761778402679888718=="
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

--===============5761778402679888718==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GIulNh005728

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.30-rc8 has been created
        at  e6c72abc9d239d788b0cdb20cb3d20ba04c33707 (tag)
   tagging  9fa7eb283c5cdc2b0f4a8cfe6387ed82e5e9a3d3 (commit)
  replaces  v2.6.30-rc7
 tagged by  Linus Torvalds
        on  Tue Jun 2 20:07:34 2009 -0700

- Log -----------------------------------------------------------------
Linux 2.6.30-rc8
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkol6QEACgkQF3YsRnbiHLsk/ACgkP94xhuASs3W3TAf1tNYiHNg
+4MAoID36jU1Z+zTC67IyGWX9DKWSF9a
=3DdRHq
-----END PGP SIGNATURE-----

Alan Cox (3):
      8250: Fix oops from setserial
      pata_netcell: LBA48 force identify bits correct
      parport: quickfix the proc registration bug

Alan Stern (1):
      usb-serial: fix crash when sub-driver updates firmware

Alex Chiang (2):
      atlx: move modinfo data from atlx.h to atl1.c
      PCI Hotplug: acpiphp: don't store a pci_dev in acpiphp_func

Alex Riesen (1):
      Use a format for linux_banner

Alexander Beregalov (2):
      parport_gsc: fix printk format error
      serial: 8250_gsc: fix printk format error

Alexey Dobriyan (1):
      cred: #include init.h in cred.h

Andreas Herrmann (1):
      [CPUFREQ] powernow-k8: determine exact CPU frequency for HW Pstates

Andrew Morton (1):
      sysfs: file.c: use create_singlethread_workqueue()

Avi Kivity (2):
      KVM: Make paravirt tlb flush also reload the PAE PDPTRs
      KVM: Fix PDPTR reloading on CR4 writes

Bartlomiej Zolnierkiewicz (1):
      ide_pci_generic: add quirk for Netcell ATA RAID

Benjamin Herrenschmidt (5):
      Revert "powerpc: Rework dma-noncoherent to use generic vmalloc laye=
r"
      powerpc: Move dma-noncoherent.c from arch/powerpc/lib to arch/power=
pc/mm
      powerpc: Minor cleanups of kernel virt address space definitions
      powerpc: Fix up dma_alloc_coherent() on platforms without cache coh=
erency.
      powerpc/pmac: Update PowerMac 32-bit defconfig

Christian Engelmayer (1):
      hwmon: Update documentation on fan_max

Clemens Ladisch (1):
      sound: usb-audio: make the MotU Fastlane work again

Coly Li (1):
      [ARM] pxa: add parameter to clksrc_read() for pxa168/910

Daisuke Nishimura (1):
      memcg: fix deadlock between lock_page_cgroup and mapping tree_lock

Dan Carpenter (1):
      RxRPC: Error handling for rxrpc_alloc_connection()

Daniel Ribeiro (3):
      [ARM] pxa: save/restore PGSR on suspend/resume.
      [ARM] pxa: allow gpio_reset drive high during normal work
      [ARM] pxa/ezx: fix pin configuration for low power mode

Dave Jones (1):
      [CPUFREQ] powernow-k7 build fix when ACPI=3Dn

Dave Young (1):
      Bluetooth: Remove useless flush_work() causing lockdep warnings

David Dillow (1):
      r8169: avoid losing MSI interrupts

David Howells (2):
      FS-Cache: Fixup renamed filenames in comments in internal.h
      CacheFiles: Fixup renamed filenames in comments in internal.h

David Rientjes (1):
      oom: fix possible oom_dump_tasks NULL pointer

David S. Miller (7):
      sparc64: Fix SET_PERSONALITY to not clip bits outside of PER_MASK.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      Merge branch 'linux-2.6.30.y' of git://git.kernel.org/pub/scm/linux=
/kernel/git/inaky/wimax
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/kaber/nf-2.6
      sparc64: Fix section attribute warnings.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/holtmann/bluetooth-2.6

Divy Le Ray (2):
      cxgb3: fix dma mapping regression
      cxgb3: link fault fixes

Dmitry Eremin-Solenikov (1):
      [ARM] pxa/spitz: provide spitz_ohci_exit() that unregisters USB_HOS=
T GPIO

Dmitry Torokhov (1):
      Input: libps2 - better handle bad scheduler decisions

Doug Leith (1):
      tcp: tcp_vegas ssthresh bugfix

Ed Swierk (1):
      forcedeth: add phy_power_down parameter, leave phy powered up by de=
fault (v2)

Eric Anholt (2):
      drm/i915: Fix tiling pitch handling on 8xx.
      drm/i915: Apply a big hammer to 865 GEM object CPU cache flushing.

Eric Dumazet (2):
      net: fix length computation in rt_check_expire()
      net: fix rtable leak in net/ipv4/route.c

Eric Sandeen (1):
      xfs: fix overflow in xfs_growfs_data_private

Fabio Rossi (1):
      ath5k: fix interpolation with equal power levels

Felix Blyakher (2):
      xfs: fix double unlock in xfs_swap_extents()
      xfs: prevent deadlock in xfs_qm_shake()

Finn Thain (2):
      mac8390: fix regression caused during net_device_ops conversion
      mac8390: fix build with NET_POLL_CONTROLLER

Florian Fainelli (1):
      MAINTAINERS: take maintainership of the cpmac Ethernet driver

Florian Westphal (1):
      pktgen: do not access flows[] beyond its length

Forrest Zhang (1):
      ath5k: fix exp off-by-one when computing OFDM delta slope

Frans Pop (1):
      ACPI processor: remove spurious newline from warning message

Greg Kroah-Hartman (1):
      ath1e: add new device id for asus hardware

H. Peter Anvin (1):
      x86, setup: revert ACPI 3 E820 extended attributes support

Haavard Skinnemoen (1):
      USB: atmel_usb_udc: Use kzalloc() to allocate ep structures

Harry Ciao (2):
      edac: AMD8111 & AMD8131 use dev_name()
      edac: AMD8111 & AMD8131 Kconfig fixup

Henrik Rydberg (2):
      Input: multitouch - add tracking ID to the protocol
      Input: multitouch - augment event semantics documentation

Herbert Xu (1):
      crypto: hash - Fix handling of sg entry that crosses page boundary

Herton Ronaldo Krzesinski (1):
      tomoyo: add missing call to cap_bprm_set_creds

Hideo Saito (1):
      powerpc/mm: Fix broken MMU PID stealing on !SMP

Inaky Perez-Gonzalez (1):
      wimax/i2400m: usb: fix device reset on autosuspend while not yet id=
le

Ira Snyder (4):
      fsldma: fix "DMA halt timeout!" errors
      fsldma: fix infinite loop on multi-descriptor DMA chain completion
      fsldma: snooping is not enabled for last entry in descriptor chain
      fsldma: fix memory leak on error path in fsl_dma_prep_memcpy()

J. Bruce Fields (1):
      nfsd: Revert "svcrpc: take advantage of tcp autotuning"

James Bottomley (1):
      async: make sure independent async domains can't accidentally entan=
gle

Jarod Wilson (1):
      [CPUFREQ] add atom family to p4-clockmod

Jaswinder Singh Rajput (3):
      drm/i915: acpi/video.c fix section mismatch warning
      headers_check fix: linux/auto_fs.h
      headers_check fix: linux/net_dropmon.h

Jay Sternberg (1):
      iwlwifi: update 5000 ucode support to version 2 of API

Jean-Mickael Guerin (1):
      IPv6: set RTPROT_KERNEL to initial route

Jesper Dangaard Brouer (1):
      netfilter: xt_hashlimit does a wrong SEQ_SKIP

Jesse Barnes (2):
      drm/i915: allocate large pointer arrays with vmalloc
      i915: support 8xx desktop cursors

Joakim Tjernlund (1):
      jffs2: Fix corruption when flash erase/write failure

Joe Perches (2):
      MAINTAINERS: pair EDAC-E752X P: and M: entries
      acpi-cpufreq: fix printk typo and indentation

Johannes Berg (1):
      wext: verify buffer size for SIOCSIWENCODEEXT

John W. Linville (3):
      airo: fix airo_get_encode{,ext} buffer overflow like I mean it...
      at76c50x-usb: avoid mutex deadlock in at76_dwork_hw_scan
      rtl8187: add USB ID for Linksys WUSB54GC-EU v2 USB wifi dongle

Jonas Bonn (1):
      drm/i915: Determine type before initialising connector

Jozsef Kadlecsik (1):
      netfilter: nf_ct_tcp: fix accepting invalid RST segments

KOSAKI Motohiro (1):
      procfs: make errno values consistent when open pident vs exit(2) ra=
ce occurs

Kay Sievers (1):
      Driver Core: do not oops when driver_unregister() is called for unr=
egistered drivers

Kenji Kaneshige (1):
      PCI/ACPI: fix wrong ref count handling in acpi_pci_bind()

Kristian H=C3=B8gsberg (1):
      i915: Set object to gtt domain when faulting it back in

Kumar Gala (1):
      fsldma: Fix compile warnings

Len Brown (4):
      i7300_idle: allow testing on i5000-series hardware w/o re-compile
      ACPI: sanity check _PSS frequency to prevent cpufreq crash
      ACPI, i915: build fix (v2)
      Merge branches 'bugzilla-13121+', 'bugzilla-13233', 'redhat-bugzill=
a-500311', 'pci-bind-oops', 'misc-2.6.30' and 'i7300_idle' into release

Lennert Buytenhek (1):
      gianfar: fix BUG under load after introduction of skb recycling

Li Yang (1):
      fsldma: update mailling list address in MAINTAINERS

Linus Torvalds (38):
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/rafael/suspend-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'kvm-updates/2.6.30' of git://git.kernel.org/pub/scm/v=
irt/kvm/kvm
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/davej/cpufreq
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'bugfixes' of git://git.linux-nfs.org/projects/trondmy=
/nfs-2.6
      Merge branch 'core-fixes-for-linus' of git://git.kernel.org/pub/scm=
/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/anholt/drm-intel
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/vapier/blackfin
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'drm-intel-next' of git://git.kernel.org/pub/scm/linux=
/kernel/git/anholt/drm-intel
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      Merge branch 'for-2.6.30' of git://linux-nfs.org/~bfields/linux
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-c=
ore-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
      Merge git://git.infradead.org/~dwmw2/mtd-2.6.30
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jbarnes/pci-2.6
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/djbw/async_tx
      Merge branch 'release' of git://git.kernel.org/pub/scm/linux/kernel=
/git/lenb/linux-acpi-2.6
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/ryusuke/nilfs2
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/bart/ide-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/jaswinder/heade=
rs-check-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge branch 'hwmon-for-linus' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/jdelvare/staging
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-=
2.6
      Merge branch 'for-linus' of git://oss.sgi.com/xfs/xfs
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/benh/powerpc
      Linux 2.6.30-rc8

Luis R. Rodriguez (1):
      cfg80211: fix race between core hint and driver's custom apply

Ma Ling (4):
      drm/i915: Fetch SDVO LVDS mode lines from VBT, then reserve them
      drm/i915: Return SDVO LVDS VBT mode if no EDID modes are detected.
      drm/i915: Use an I2C algo to do the flip to SDVO DDC bus.
      drm/i915: Add support for VGA load detection (pre-945).

Maciej W. Rozycki (1):
      3c509: Add missing EISA IDs

Manuel Traut (1):
      Input: usb1400_ts - fix access to "device data" in resume function

Marek Szyprowski (1):
      S3C-fb: PM fix

Marek Vasut (1):
      [ARM] pxa/palm: fix PalmLD/T5/TX AC97 MFP

Martin Fuzzey (1):
      USB: atmel-usba-udc : fix control out requests.

Martin Michlmayr (1):
      [ARM] Orion: Remove explicit name for platform device resources

Mathieu Desnoyers (4):
      [CPUFREQ] remove rwsem lock from CPUFREQ_GOV_STOP call
      [CPUFREQ] fix timer teardown in conservative governor
      [CPUFREQ] fix timer teardown in ondemand governor
      [ARM] Add cmpxchg support for ARMv6+ systems (v5)

Matt Kraai (1):
      net/firmare: Ignore .cis files

Mel Gorman (2):
      x86: ignore VM_LOCKED when determining if hugetlb-backed page table=
s can be shared or not
      mm: account for MAP_SHARED mappings using VM_MAYSHARE and not VM_SH=
ARED in hugetlbfs

Mike Frysinger (9):
      bfin_mac: fix build error due to net_device_ops convert
      Blackfin: hook up preadv/pwritev syscalls
      MAINTAINERS: update Blackfin items
      MAINTAINERS: drop (subscribers-only) markings on Blackfin lists
      Blackfin: ignore generated vmlinux.lds
      Blackfin: drop unneeded asm/.gitignore
      Blackfin: fix strncmp.o build error
      Revert "USB: Correct Makefile to make isp1760 buildable"
      hwmon: (lm78) Add missing __devexit_p()

Mingwei Wang (1):
      [ARM] pxa: fix the incorrectly defined drive strength macros for px=
a{168,910}

Minoru Usui (1):
      net_cls: fix unconfigured struct tcf_proto keeps chaining and avoid=
 kernel panic when we use cls_cgroup

Neil Horman (1):
      e1000: add missing length check to e1000 receive routine

NeilBrown (8):
      md: always update level / chunk_size / layout when writing v1.x met=
adata.
      md: improve errno return when setting array_size
      md: bitmap: improve bitmap maintenance code.
      md: export 'frozen' resync state through sysfs
      md: raid5: avoid sector values going negative when testing reshape =
progress.
      md: don't update curr_resync_completed without also updating reshap=
e_position.
      md: don't use locked_ioctl.
      md: raid5: change incorrect usage of 'min' macro to 'min_t'

Nicolas Ferre (1):
      atmel_lcdfb: correct fifo size for some products

Nicolas Pitre (1):
      [ARM] add coherent DMA mask for mv643xx_eth

Nikanth Karthikesan (1):
      memcg: fix build warning and avoid checking for mem !=3D null again=
 and again

Oskar Schirmer (1):
      flat: fix data sections alignment

Ozan =C3=87a=C4=9Flayan (1):
      ALSA: hda - Add forced codec-slots for ASUS W5Fm

Pablo Neira Ayuso (2):
      netfilter: nf_ct_dccp: add missing DCCP protocol changes in event c=
ache
      netfilter: nfnetlink_log: fix wrong skbuff size	calculation

Pallipadi, Venkatesh (1):
      x86: avoid back to back on_each_cpu in cpa_flush_array

Paul Menage (1):
      cls_cgroup: read classid atomically in classifier

Paulius Zaleckas (2):
      MAINTAINER: Add F: entries for Gemini and FA526
      Gemini: Fix SRAM/ROM location after memory swap

Pavel Roskin (1):
      ath5k: fix scanning in AR2424

Rafael J. Wysocki (1):
      PM: Do not hold dpm_list_mtx while disabling/enabling nonboot CPUs

Reinette Chatre (1):
      iwlwifi: do not cancel delayed work inside spin_lock_irqsave

Robert Olsson (1):
      ipv4: Fix oops with FIB_TRIE

Robert Richter (1):
      oprofile: fix cpu buffer size

Roel Kluin (4):
      wireless: beyond ARRAY_SIZE of intf->crypto_stats
      gigaset: beyond ARRAY_SIZE of iwb->data
      fsldma: fix check on potential fdev->chan[] overflow
      drivers/serial/mpc52xx_uart.c: fix array overindexing check

Russell King (6):
      Merge branch 'fix' of git://git.kernel.org/pub/scm/linux/kernel/git=
/ycmiao/pxa-linux-2.6
      [ARM] disable NX support for OABI-supporting kernels
      Merge branch 'for-rmk' of git://git.marvell.com/orion
      [ARM] barriers: improve xchg, bitops and atomic SMP barriers
      [ARM] update mach-types
      Merge branch 'for-rmk' of git://gitorious.org/linux-gemini/mainline

Rusty Russell (1):
      lguest: fix on Intel when KVM loaded (unhandled trap 13)

Ryusuke Konishi (1):
      nilfs2: fix bh leak in nilfs_cpfile_delete_checkpoints function

Sam Ravnborg (1):
      nfs: fix build error in nfsroot with initconst

Shaohua Li (2):
      cpuidle: makes AMD C1E work in acpi_idle
      cpuidle: fix AMD C1E suspend hang

Steve Wise (1):
      svcrdma: dma unmap the correct length for the RPCRDMA header page.

Suresh Siddha (1):
      x86: introduce noxsave boot parameter

Takashi Iwai (7):
      ALSA: hda - Add 5stack-no-fp model for STAC927x
      ALSA: hda - Add missing check of pin vref 50 and others in Realtek =
codecs
      ALSA: Fix invalid jiffies check after pause
      ALSA: Enable PCM hw_ptr_jiffies check only in xrun_debug mode
      Merge branch 'fix/misc' into for-linus
      Merge branch 'fix/pcm-jiffies-check' into for-linus
      Merge branch 'fix/hda' into for-linus

Tejun Heo (2):
      x86: Remove remap percpu allocator for the time being
      x86, relocs: ignore R_386_NONE in kernel relocation entries

Tetsuo Handa (1):
      kmod: Release sub_info on cred allocation failure.

Thomas Dahlmann (1):
      MAINTAINERS: change email address for Thomas Dahlmann

Thomas Reitmayr (1):
      [ARM] Kirkwood: Correct MPP for SATA activity/presence LEDs of QNAP=
 TS-119/TS-219.

Thomas Renninger (1):
      [CPUFREQ] powernow-k8 cleanup msg if BIOS does not export ACPI _PSS=
 cpufreq data

Timothy Clacy (1):
      [ARM] pxa: enable GPIO receivers after configuring pins

Tony Vroon (1):
      ALSA: hda - Compaq Presario CQ60 patching for Conexant

Trond Myklebust (1):
      NFSv4: Fix the case where NFSv4 renewal fails

Vladimir Barinov (1):
      mtd: MXC NAND driver fixes (v5)

Vu Pham (1):
      XPRTRDMA: fix client rpcrdma FRMR registration on mlx4 devices

Warren Free (1):
      USB: isp1760: urb_dequeue doesn't always find the urbs

Wei Yongjun (1):
      nfsd: fix hung up of nfs client while sync write data to nfs server

Xiao Kaijian (1):
      USB: Yet another Conexant Clone to add to cdc-acm.c

Xiaotian Feng (1):
      gianfar: fix babbling rx error event bug

Yevgeny Petrilin (1):
      mlx4_en: Fix a kernel panic when waking tx queue

Zhang Rui (3):
      x86: DMI match for the Sony VGN-Z540N as it needs BIOS reboot
      ACPI: video: DMI workaround broken eMachines E510 BIOS enabling dis=
play brightness
      ACPI: video: DMI workaround broken Acer 5315 BIOS enabling display =
brightness

venkatesh.pallipadi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org (2):
      x86: bugfix wbinvd() model check instead of family check
      x86: cpa_flush_array wbinvd should be done on all CPUs

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============5761778402679888718==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============5761778402679888718==--
