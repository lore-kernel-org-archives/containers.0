From: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Subject: [cr][git]linux-cr annotated tag, v2.6.27-rc6, created. v2.6.27-rc6
Date: Wed, 16 Sep 2009 14:36:26 -0400
Message-ID: <200909161836.n8GIaQuF000881@gorgona.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9162273289416002368=="
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

--===============9162273289416002368==
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by smtp1.linux-foundation.org id n8GIhRu2003818

This is an automated email from the git hooks/post-receive script. It was
generated because a ref change was pushed to the repository containing
the project "linux-cr".

The annotated tag, v2.6.27-rc6 has been created
        at  89c44b4a5ad50f8b85846b16af5f977f3861d197 (tag)
   tagging  adee14b2e1557d0a8559f29681732d05a89dfc35 (commit)
  replaces  v2.6.27-rc5
 tagged by  Linus Torvalds
        on  Tue Sep 9 16:28:05 2008 -0700

- Log -----------------------------------------------------------------
Linux 2.6.27-rc6
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkjHBokACgkQF3YsRnbiHLvgggCeLoZz3DDlfk5kA8foXEjqf+42
M6MAnRFKCyXk3y8jCK8t1ikpg0dDHjO4
=3Dinl6
-----END PGP SIGNATURE-----

Adam Litke (1):
      mm: make setup_zone_migrate_reserve() aware of overlapping nodes

Adrian Bunk (9):
      sh64: re-add the __strnlen_user() prototype
      sh: fix ptrace_64.c:user_disable_single_step()
      dabusb_fpga_download(): fix a memory leak
      wireless/libertas/if_cs.c: fix memory leaks
      NTFS: update homepage
      V4L/DVB (8678): Remove the dead CONFIG_RADIO_MIROPCM20{,_RDS} code
      V4L/DVB (8842): vivi_release(): fix use-after-free
      V4L/DVB (8843): tda10048_firmware_upload(): fix a memory leak
      V4L/DVB (8844): dabusb_fpga_download(): fix a memory leak

Adrian Hunter (2):
      UBIFS: always read hashed-key nodes under TNC mutex
      UBIFS: allow for racing between GC and TNC

Al Viro (1):
      forgotten refcount on sysctl root table

Alan Cox (1):
      ahci, pata_marvell: play nicely together

Alexander Beregalov (1):
      V4L/DVB (8681): v4l2-ioctl.c: fix warning

Alexey Dobriyan (3):
      netfilter: nf_conntrack_sip: de-static helper pointers
      netfilter: nf_conntrack_gre: more locking around keymap list
      netfilter: nf_conntrack_gre: nf_ct_gre_keymap_flush() fixlet

Alok N Kataria (1):
      x86: Change warning message in TSC calibration.

Andi Kleen (10):
      Merge branch 'thermal-fix' into release-2.6.27
      Merge branch 'compal-fix' into release-2.6.27
      Merge branch 'acpica-release-fixes' into release-2.6.27
      Merge branch 'pnp-fix' into release-2.6.27
      Merge branch 'release-2.6.27' of ssh://master.kernel.org/pub/scm/li=
nux/kernel/git/ak/linux-acpi-2.6 into release-2.6.27
      Merge branch 'wan' into release-2.6.27
      Don't trigger softlockup detector on network fs blocked tasks
      ACPI: Make Len Brown the ACPI maintainer again
      Merge branches 'smbus' and 'fujitsu-fix' into release-2.6.27
      Merge branch 'wmi-fix' into release-2.6.27

Andre Detsch (1):
      powerpc/spufs: Fix possible scheduling of a context to multiple SPE=
s

Andreas Herrmann (2):
      x86: pda_init(): fix memory leak when using CPU hotplug
      x86: cpu_init(): fix memory leak when using CPU hotplug

Andrew Morton (2):
      drivers/char/random.c: fix a race which can lead to a bogus BUG()
      drivers/mmc/card/block.c: fix refcount leak in mmc_block_open()

Andy Adamson (1):
      nfsd: fix compound state allocation error handling

Andy Gospodarek (1):
      ixgbe: initialize interrupt throttle rate

Andy Walls (2):
      V4L/DVB (8701): cx18: Add missing lock for when the irq handler man=
ipulates the queues
      V4L/DVB (8769): cx18: Simplify queue flush logic to prevent oops in=
 cx18_flush_queues()

Arjan van de Ven (1):
      don't diff generated firmware files

Artem Bityutskiy (13):
      UBIFS: fix zero-length truncations
      UBIFS: do not update min_idx_lebs in stafs
      UBIFS: push empty flash hack down
      UBIFS: remove incorrect index space check
      UBIFS: improve statfs reporting
      UBIFS: fix assertion
      UBIFS: add forgotten gc_idx_lebs component
      UBIFS: introduce LEB overhead
      UBIFS: improve statfs reporting even more
      UBIFS: fill f_fsid
      UBIFS: amend f_fsid
      UBIFS: fix division by zero
      UBIFS: make minimum fanout 3

Assaf Krauss (1):
      iwlwifi: W/A for the TSF correction in IBSS

Atsushi Nemoto (3):
      [MIPS] TXx9: Fix txx9_pcode initialization
      [MIPS] TX39xx: Add missing local_flush_icache_range initialization
      [MIPS] Probe initrd header only if explicitly specified

Balbir Singh (1):
      sched: fix process time monotonicity

Bartlomiej Zolnierkiewicz (3):
      ide: fix hwif_to_node()
      ide-disk: remove stale init_idedisk_capacity() documentation
      ide/Kconfig: mark ide-scsi as deprecated

Benjamin Herrenschmidt (1):
      powerpc: Fix build error with 64K pages and !hugetlbfs

Bjorn Helgaas (1):
      PNPACPI: ignore the producer/consumer bit for extended IRQ descript=
ors

Boaz Harrosh (1):
      rt2x00: Compiler warning unmasked by fix of BUILD_BUG_ON

Breno Leitao (1):
      ipv: Re-enable IP when MTU > 68

Carmelo Amoroso (1):
      sh: resume_kernel fix for kernel oops built with CONFIG_BKL_PREEMPT=
=3Dy.

Chris Snook (1):
      MAINTAINERS: add Atheros maintainer for atlx

Christoph Hellwig (1):
      update Documentation/filesystems/Locking for 2.6.27 changes

Chuck Ebbert (1):
      x86: add io delay quirk for Presario F700

Chuck Lever (1):
      NFS: Restore missing hunk in NFS mount option parser

Clemens Ladisch (1):
      ALSA: oxygen: fix distorted output on AK4396-based cards

Cordelia (1):
      audit: Moved variable declaration to beginning of function

Cornelia Huck (2):
      [S390] cio: Correct cleanup on error.
      [S390] cio: handle ssch() return codes correctly.

Cyrill Gorcunov (2):
      acpi: add checking for NULL early param
      sunrpc: fix possible overrun on read of /proc/sys/sunrpc/transports

Daniel Lezcano (1):
      netns : fix kernel panic in timewait socket destruction

Dave Airlie (1):
      drm/radeon: downgrade debug message from info to debug.

David Brownell (3):
      palm_bk3710: improve IDE registration
      mmc: at91_mci: don't use coherent dma buffers
      net/usb/pegasus: avoid hundreds of diagnostics

David Kilroy (1):
      orinoco: Multicast to the specified addresses

David Milburn (1):
      pata_sil680: remove duplicate pcim_enable_device

David S. Miller (11):
      sparc32: Implement smp_call_function_single().
      sparc: Fix resource flags for PCI children in OF device tree.
      net: Unbreak userspace usage of linux/mroute.h
      sparc64: setup_valid_addr_bitmap_from_pavail() should be __init
      ipsec: Fix deadlock in xfrm_state management.
      tipc: Don't use structure names which easily globally conflict.
      sparc64: Fix IPI call locking.
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/linville/wireless-2.6
      Merge branch 'davem-fixes' of master.kernel.org:/pub/scm/linux/kern=
el/git/jgarzik/netdev-2.6
      sparc64: Disable timer interrupts in fixup_irqs().
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/holtmann/bluetooth-2.6

David Woodhouse (3):
      Fix modules_install on RO nfs-exported trees.
      Remove '#include <stddef.h>' from mm/page_isolation.c
      Revert "[ARM] use the new byteorder headers"

Dennis Jansen (2):
      ACPI: Fix typo in "Disable MWAIT via DMI on broken Compal board"
      ACPI: Fix typo in "Disable MWAIT via DMI on broken Compal board"

Dhananjay Phadke (1):
      netxen: Remove workaround for chipset quirk

Dmitry Baryshkov (2):
      ALSA: ASoC: fix pxa2xx-i2s clk_get call
      [MTD] [NAND] tmio_nand: fix base address programming

Dominik Brodowski (2):
      clocksource, acpi_pm.c: use proper read function also in errata mod=
e
      clocksource, acpi_pm.c: check for monotonicity

Eduardo Habkost (1):
      x86, xen: Use native_pte_flags instead of native_pte_val for .pte_f=
lags

Eilon Greenstein (1):
      bnx2x: Accessing un-mapped page

Eric Paris (1):
      SELinux: memory leak in security_context_to_sid_core

FUJITA Tomonori (1):
      remove blk_register_filter and blk_unregister_filter in gendisk

Florian Mickler (1):
      net/wireless/Kconfig: clarify the description for CONFIG_WIRELESS_E=
XT_SYSFS

Gregory Greenman (2):
      iwlwifi: call apm stop on exit
      iwlwifi: fix STATUS_EXIT_PENDING is not set on pci_remove

H. Peter Anvin (3):
      x86: boot: stub out unimplemented CPU feature words
      x86: add NOPL as a synthetic CPU feature bit
      x86: use X86_FEATURE_NOPL in alternatives

Haavard Skinnemoen (1):
      avr32: Fix lockup after Java stack underflow in user mode

Hans Verkuil (7):
      V4L/DVB (8629): v4l2-ioctl: do not try to handle private V4L1 ioctl=
s
      V4L/DVB (8633): ivtv: update ivtv version number
      V4L/DVB (8648): ivtv: improve CC support
      V4L/DVB (8757): v4l-dvb: fix a bunch of sparse warnings
      V4L/DVB (8778): radio: fix incorrect video_register_device result c=
heck
      V4L/DVB (8779): v4l: fix more incorrect video_register_device resul=
t checks
      V4L/DVB (8790): saa7115: call i2c_set_clientdata only when state !=3D=
 NULL

Hans de Goede (21):
      V4L/DVB (8667): gspca: Bad probe of Z-Star/Vimicro webcams with pas=
106 sensor.
      V4L/DVB (8720): gspca: V4L2_CAP_SENSOR_UPSIDE_DOWN added as a cap f=
or some webcams.
      V4L/DVB (8809): gspca: Revert commit 9a9335776548d01525141c6e8f0c12=
e86bbde982
      V4L/DVB (8812): gspca: Do pac73xx webcams work.
      V4L/DVB (8813): gspca: Adjust SOF detection for pac73xx.
      V4L/DVB (8815): gspca: Fix problems with disabled controls.
      V4L/DVB (8816): gspca: Set disabled ctrls and fix a register pb wit=
h ovxxxx in sonixb.
      V4L/DVB (8817): gspca: LED and proble changes in sonixb.
      V4L/DVB (8825): gspca: More controls for pac73xx and new webcam 093=
a:2624.
      V4L/DVB (8827): gspca: Stop pac7302 autogain oscillation.
      V4L/DVB (8830): gspca: Move some probe code to the new init functio=
n.
      V4L/DVB (8831): gspca: Resolve webcam conflicts between some driver=
s.
      V4L/DVB (8833): gspca: Cleanup the sonixb code.
      V4L/DVB (8834): gspca: Have a bigger buffer for sn9c10x compressed =
images.
      V4L/DVB (8835): gspca: Same pixfmt as the sn9c102 driver and raw Ba=
yer added in sonixb.
      V4L/DVB (8868): gspca: Support for vga modes with sif sensors in so=
nixb.
      V4L/DVB (8869): gspca: Move the Sonix webcams with TAS5110C1B from =
sn9c102 to gspca.
      V4L/DVB (8870): gspca: Fix dark room problem with sonixb.
      V4L/DVB (8873): gspca: Bad image offset with rev012a of spca561 and=
 adjust exposure.
      V4L/DVB (8874): gspca: Adjust hstart for sn9c103/ov7630 and update =
usb-id's.
      V4L/DVB (8880): PATCH: Fix parents on some webcam drivers

Henrik Kretzschmar (2):
      V4L/DVB (8682): V4L: fix return value of register video func
      V4L/DVB (8750): V4L: check inval in video_register_device_index()

Henrik Rydberg (5):
      Input: bcm5974 - add maintainer entry
      MAINTAINERS: add a maintainer for the BCM5974 multitouch driver
      Input: bcm5974 - small formatting cleanup
      Input: bcm5974 - improve finger tracking and counting
      Input: bcm5974 - add BTN_TOUCH event for mousedev benefit

Herbert Xu (2):
      Revert "crypto: camellia - Use kernel-provided bitops, unaligned ac=
cess helpers"
      ipsec: Restore larval states and socket policies in dump

Hisashi Hifumi (1):
      VFS: fix dio write returning EIO when try_to_release_page fails

Huang Weiyi (1):
      [ARM] remove unused #include <version.h>

Hugh Dickins (1):
      powerpc: Fix rare boot build breakage

Humphrey Bucknell (1):
      avr32: pm_standby low-power ram bug fix

Ingo Molnar (1):
      Merge branch 'sched/cpuset' into sched/urgent

J. Bruce Fields (1):
      nfsd: fix buffer overrun decoding NFSv4 acl

James Bottomley (1):
      lib: Correct printk %pF to work on all architectures

Jan Altenberg (1):
      rtc_time_to_tm: fix signed/unsigned arithmetic

Jarek Poplawski (2):
      pkt_sched: Fix locking of qdisc_root with qdisc_root_sleeping_lock(=
)
      pkt_sched: Fix qdisc state in net_tx_action()

Jarod Wilson (1):
      [S390] CVE-2008-1514: prevent ptrace padding area read/write in 31-=
bit mode

Jason Wessel (1):
      usb: fix null deferences in low level usb serial

Jean Delvare (1):
      V4L/DVB (8837): dvb: fix I2C adapters name size

Jean-Francois Moine (41):
      V4L/DVB (8660): gspca: Simplify the scan of URB packets in pac7311.
      V4L/DVB (8661): gspca: Bug in the previous changeset about pac7311.
      V4L/DVB (8663): gspca: Webcam 0c45:6128 added in sonixj.
      V4L/DVB (8664): gspca: The bridge/sensor of the webcam 093a:2621 is=
 a PAC 7302.
      V4L/DVB (8665): gspca: Fix the 640x480 resolution of the webcam 093=
a:2621.
      V4L/DVB (8666): gspca: Bad scanning of frames in pac7311.
      V4L/DVB (8668): gspca: Conflict GSPCA / ET61X251 for the webcam 102=
c:6251.
      V4L/DVB (8669): gspca: Add white balance control for spca561 rev 01=
2A.
      V4L/DVB (8671): gspca: Remove the unused field 'dev_name' of the de=
vice structure.
      V4L/DVB (8672): gspca: Big rewrite of spca561.
      V4L/DVB (8673): gspca: Bad frame scanning again and bad init in pac=
7311.
      V4L/DVB (8674): gspca: Webcam 0c45:612e added in sonixj.
      V4L/DVB (8675): gspca: Pixmap PJPG (Pixart 73xx JPEG) added, genera=
ted by pac7311.
      V4L/DVB (8703): gspca: Do controls work for spca561 revision 12a.
      V4L/DVB (8705): gspca: Adjust some control limits in spca561.
      V4L/DVB (8706): Make contrast and brightness work for pac7302.
      V4L/DVB (8707): gspca: Colors, hflip and vflip controls added for p=
ac7302.
      V4L/DVB (8709): gspca: Fix initialization and controls of sn9x110 -=
 ov7630.
      V4L/DVB (8710): gspca: Bad color control in sonixj.
      V4L/DVB (8711): gspca: Bad controls and quantization table of pac73=
11.
      V4L/DVB (8712): gspca: Bad start of sonixj webcams since changeset =
a8779025e7e8.
      V4L/DVB (8713): gspca: Bad color control again in sonixj.
      V4L/DVB (8714): gspca: Bad start of sn9c110 and sensor om6802.
      V4L/DVB (8715): gspca: Change the name of some webcam in the gspca =
doc.
      V4L/DVB (8716): gspca: Bad start of sn9c110 and sensor ov7630.
      V4L/DVB (8717): gspca: Frame buffer too small for small resolutions=
 (sonixj and t613).
      V4L/DVB (8718): gspca: suspend/resume added.
      V4L/DVB (8719): gspca: Have VIDIOC_QUERYCTRL more compliant to the =
spec.
      V4L/DVB (8810): gspca: Compile error when CONFIG_PM not defined.
      V4L/DVB (8814): gspca: Set DISABLED the disabled controls at query =
control time.
      V4L/DVB (8818): gspca: Reinitialize the device on resume.
      V4L/DVB (8819): gspca: Initialize the ov519 at open time and source=
 cleanup.
      V4L/DVB (8820): gspca: Change initialization and gamma of zc3xx - p=
as106.
      V4L/DVB (8822): gspca: Change some subdriver functions for suspend/=
resume.
      V4L/DVB (8823): gspca: H and V flips work for ov7670 only in ov519.
      V4L/DVB (8824): gspca: Too much code removed in the suspend/resume =
changeset.
      V4L/DVB (8826): gspca: Webcam Labtec 2200 (093a:2626) added in pac7=
311.
      V4L/DVB (8828): gspca: Set the clock at the end of initialization i=
n sonixj.
      V4L/DVB (8829): gspca: Have a clean kmalloc-ated buffer for USB exc=
hanges.
      V4L/DVB (8832): gspca: Bad pixelformat of vc0321 webcams.
      V4L/DVB (8872): gspca: Bad image format and offset with rev072a of =
spca561.

Jeff Layton (1):
      cifs: fix O_APPEND on directio mounts

Jeremy Fitzhardinge (2):
      ACPI: thinkpad-acpi: wan radio control is not experimental
      xen: fix 2.6.27-rc5 xen balloon driver warnings

Jeremy Kerr (2):
      powerpc/spufs: Fix multiple get_spu_context()
      powerpc/spufs: Fix race for a free SPU

Jiri Kosina (1):
      Input: i8042 - make Lenovo 3000 N100 blacklist entry more specific

John Kacur (1):
      pm_qos_requirement might sleep

John W. Linville (1):
      iwlwifi: do not use GFP_DMA in iwl_tx_queue_init

Jonathan Woithe (1):
      fujitsu-laptop: fix regression for P8010 in 2.6.27-rc

Jouni Malinen (3):
      mac80211: Fix debugfs union misuse and pointer corruption
      ath9k: Fix TX status reporting
      ath9k: Fix TX control flag use for no ACK and RTS/CTS

Julien Brunel (1):
      net/xfrm: Use an IS_ERR test rather than a NULL test

KOSAKI Motohiro (2):
      mm: show quicklist usage in /proc/meminfo
      mm: size of quicklists shouldn't be proportional to the number of C=
PUs

Kevin Hilman (2):
      IDE: compile fix for sff_dma_ops
      IDE: palm_bk3710: fix compile warning for unused variable

Khem Raj (1):
      Fix conditional export of kvh.h and a.out.h to userspace.

Komuro (1):
      pcnet-cs, axnet_cs: add new IDs, remove dup ID with less info

Krzysztof Helt (4):
      cirrusfb: check_par fixes
      tdfxfb: fix SDRAM memory size detection
      tdfxfb: fix frame buffer name overrun
      x86: delay early cpu initialization until cpuid is done

Kumar Gala (1):
      powerpc: Fix for getting CPU number in power_save_ppc32_restore()

Lennert Buytenhek (1):
      [ARM] 5241/1: provide ioremap_wc()

Li Zefan (3):
      devcgroup: fix race against rmdir()
      V4L/DVB (8881): gspca: After 'while (retry--) {...}', retry will be=
 -1 but not 0.
      res_counter: fix off-by-one bug in setting limit

Linus Torvalds (51):
      Revert "x86: fix HPET regression in 2.6.26 versus 2.6.25, check hpe=
t against BAR, v3"
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Resource handling: add 'insert_resource_expand_to_fit()' function
      Un-break printk strings in x86 PCI probing code
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.=
6
      Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kern=
el/git/airlied/drm-2.6
      Merge branch 'for-2.6.27' of git://linux-nfs.org/~bfields/linux
      Merge git://git.infradead.org/users/dwmw2/random-2.6
      Merge branch 'for-linus' of git://neil.brown.name/md
      Merge branch 'audit.b57' of git://git.kernel.org/pub/scm/linux/kern=
el/git/viro/audit-current
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/bart/ide-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Split up PIT part of TSC calibration from native_calibrate_tsc
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/paulus/powerpc
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/jmorris/security-testing-2.6
      PCI: fix pbus_size_mem() resource alignment for CardBus controllers
      Revert "mac80211: Use IWEVASSOCREQIE instead of IWEVCUSTOM"
      Merge branch 'release-2.6.27' of git://git.kernel.org/pub/scm/linux=
/kernel/git/ak/linux-acpi-2.6
      Merge branch 'core/debugobjects' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/tip/linux-2.6-tip
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/mchehab/v4l-dvb
      Merge branch 'sh/for-2.6.27' of git://git.kernel.org/pub/scm/linux/=
kernel/git/lethal/sh-2.6
      Merge git://git.infradead.org/~dwmw2/dwmw2-2.6.27
      Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/djbw/async_tx
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/tiwai/sound-2.6
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kern=
el/git/dtor/input
      x86: disable static NOPLs on 32 bits
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux=
/kernel/git/jgarzik/libata-dev
      Merge branch 'sched-fixes-for-linus' of git://git.kernel.org/pub/sc=
m/linux/kernel/git/tip/linux-2.6-tip
      Merge master.kernel.org:/home/rmk/linux-2.6-arm
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-=
2.6
      Merge branch 'merge' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/paulus/powerpc
      Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/=
git/hskinnemoen/avr32-2.6
      Merge branch 'linux-next' of git://git.infradead.org/~dedekind/ubif=
s-2.6
      Merge branch 'upstream' of git://ftp.linux-mips.org/pub/scm/upstrea=
m-linus
      Merge branch 'for-linus' of git://git390.osdl.marist.edu/pub/scm/li=
nux-2.6
      Merge branch 'x86-fixes-for-linus' of git://git.kernel.org/pub/scm/=
linux/kernel/git/tip/linux-2.6-tip
      Merge branch 'timers-fixes-for-linus' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/tip/linux-2.6-tip
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6
      Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
      Linux 2.6.27-rc6

Maciej W. Rozycki (1):
      ntp: fix calculation of the next jiffie to trigger RTC sync

Magnus Damm (6):
      sh: crash kernel resource fix
      sh: fix kexec entry point for crash kernels
      sh: fix platform_resource_setup_memory() section mismatch
      sh: update Migo-R defconfig
      sh: update AP325RXA defconfig
      i2c: fix i2c-sh_mobile timing issues

Marcel Holtmann (3):
      [Bluetooth] Fix reference counting during ACL config stage
      [Bluetooth] Enforce correct authentication requirements
      [Bluetooth] Reject L2CAP connections on an insecure ACL link

Marcin Slusarz (1):
      mm/bootmem: silence section mismatch warning - contig_page_data/boo=
tmem_node_data

Mark Lord (1):
      sata_mv: add RocketRaid 1720 PCI ID to driver

Matthew Garrett (2):
      hp-wmi: update to match current rfkill semantics
      hp-wmi: add proper hotkey support

Matthew Ranostay (1):
      ALSA: hda: Distortion fix for dell_m6_core_init

Mauro Carvalho Chehab (3):
      V4L/DVB (8749): Fix error code, when camera is not turned on by son=
ypi
      V4L/DVB (8751): vivi: Fix some issues at vivi register routine
      Merge branch 'fixes_stg' of ../git_old into fixes

Max Krasnyansky (2):
      sched, cpuset: rework sched domains and CPU hotplug handling (v4)
      sched: arch_reinit_sched_domains() must destroy domains to force re=
build

Michael Krufky (8):
      V4L/DVB (8555): au8522: add mechanism to configure IF frequency for=
 vsb and qam
      V4L/DVB (8556): au0828: add support for Hauppauge Woodbury
      V4L/DVB (8598): au8522: clean up function au8522_set_if
      V4L/DVB (8599): au8522: remove if frequency settings from vsb/qam m=
odulation tables
      V4L/DVB (8600): au0828: explicitly set 6 MHz IF frequency in hauppa=
uge_hvr950q_config
      V4L/DVB (8722): sms1xxx: fix typo in license header
      V4L/DVB (8839): dib0700: add comment to identify 35th USB id pair
      V4L/DVB (8840): dib0700: add basic support for Hauppauge Nova-TD-50=
0 (84xxx)

Michael Neuling (1):
      powerpc: Fix uninitialised variable in VSX alignment code

Michael Schmitz (1):
      m68k: atari_keyb_init operator precedence fix

Mike Christie (1):
      ibft: fix target info parsing in ibft module

Milan Broz (2):
      ACPI: Fix now signed module parameter.
      ACPI: Fix now signed module parameter.

Ming Ling (1):
      ACPI: Change package length error to warning

Mohamed Abbas (2):
      iwlwifi: fix apm_stop (wrong bit polarity for FLAG_INIT_DONE)
      iwlwifi: remove false rxon if rx chain changes

Nadia Derbey (1):
      ipc: document the new auto_msgmni proc file

Neil Horman (1):
      ipv6: Fix OOPS in ip6_dst_lookup_tail().

NeilBrown (2):
      Remove invalidate_partition call from do_md_stop.
      Fix problem with waiting while holding rcu read lock in md/bitmap.c

Oleg Nesterov (3):
      softlockup: minor cleanup, don't check task->state twice
      pid_ns: zap_pid_ns_processes: fix the ->child_reaper changing
      pid_ns: (BUG 11391) change ->child_reaper when init->group_leader e=
xits

Patrick McHardy (1):
      netfilter: nf_conntrack_irc: make sure string is terminated before =
calling simple_strtoul

Paul E. McKenney (1):
      sparc64: Prevent sparc64 from invoking irq handlers on offline CPUs

Paul Mackerras (1):
      powerpc: Only make kernel text pages of linear mapping executable

Paul Mundt (1):
      sh64: resume_kernel fix for kernel oops built with CONFIG_BKL_PREEM=
PT=3Dy.

Peter Oberparleiter (1):
      [S390] cio: allow offline processing for disconnected devices

Peter Zijlstra (1):
      sched_clock: fix NOHZ interaction

Prarit Bhargava (1):
      x86: fix memmap=3Dexactmap boot argument

Rafael J. Wysocki (2):
      rtc-cmos: wake again from S5
      forcedeth: fix kexec regression

Randy Dunlap (1):
      kernel/resource.c: fix new kernel-doc warning

Rene Herman (2):
      V4L/DVB (8727): V4L1: make PMS not autoprobe when builtin.
      V4L/DVB (8728): 1-make-pms-not-autoprobe-when-builtin update

Roland McGrath (1):
      tracehook: comment pasto fixes

Ron Rindjunsky (2):
      iwlwifi: fix hidden ssid discovery in passive channels
      iwlwifi: fix station mimo power save values

Russ Anderson (1):
      sysfs: document files in /sys/firmware/sgi_uv/

Russ Dill (2):
      acer-wmi: remove debugfs entries upon unloading
      acer-wmi: remove debugfs entries upon unloading

Russell King (3):
      [ARM] omap: fix gpio.c build error
      [ARM] omap: fix build error in ohci-omap.c
      [ARM] omap: fix virtual vs physical address space confusions

Senthil Balasubramanian (2):
      ath9k: Incorrect key used when group and pairwise ciphers are diffe=
rent.
      ath9: Fix ath_rx_flush_tid() for IRQs disabled kernel warning messa=
ge.

Seth Heasley (1):
      ahci: RAID mode SATA patch for Intel Ibex Peak DeviceIDs

Simon Arlott (1):
      V4L/DVB (8726): link tuner before saa7134

Stanislaw Gruszka (1):
      atmel_lcdfb: fix oops in rmmod when framebuffer fails to register

Stephen Hemminger (1):
      bridge: don't allow setting hello time to zero

Stephen Rothwell (2):
      fix typo in arch/parisc/hpux/fs.c
      powerpc: Make sure _etext is after all kernel text

Steve French (4):
      [CIFS] Fix plaintext authentication
      Merge branch 'master' of /pub/scm/linux/kernel/git/torvalds/linux-2=
.6
      [CIFS] update cifs change log
      [CIFS] Turn off Unicode during session establishment for plaintext =
authentication

Steven Toth (3):
      V4L/DVB (8803): s5h1409: Enable QAM_AUTO mode
      V4L/DVB (8804): s5h1411: Enable QAM_AUTO mode
      V4L/DVB (8805): Steven Toth email address change

Takashi Iwai (4):
      Revert "ALSA: hda - Added model selection for iMac 24""
      ALSA: hda - Fix ALC663 auto-probe
      ALSA: hda - Add mic-boost controls to ALC662/663 auto configuration
      Fix CONFIG_AC97_BUS dependency

Tejun Heo (5):
      block: restore original behavior of /proc/partition when there's no=
 partition
      mmap: fix petty bug in anonymous shared mmap offset handling
      ahci: disable PMP for marvell ahcis
      sata_nv: disable hardreset for generic
      libata-sff: kill spurious WARN_ON() in ata_hsm_move()

Thierry MERLE (2):
      V4L/DVB (8876): budget: udelay changed to mdelay
      V4L/DVB (8877): b2c2 and bt8xx: udelay to mdelay

Thomas Bogendoerfer (3):
      [MIPS] Fix data bus error recovery
      [MIPS] Fix WARNING: at kernel/smp.c:290
      [MIPS] IP22: Fix detection of second HPC3 on Challenge S

Thomas Gleixner (10):
      [x86] Fix TSC calibration issues
      clockevents: prevent endless loop in periodic broadcast handler
      clockevents: enforce reprogram in oneshot setup
      clockevents: prevent multiple init/shutdown
      clockevents: prevent endless loop lockup
      HPET: make minimum reprogramming delta useful
      clockevents: broadcast fixup possible waiters
      x86: HPET fix moronic 32/64bit thinko
      x86: HPET: read back compare register before reading counter
      clockevents: remove WARN_ON which was used to gather information

Tom Tucker (1):
      svcrdma: Fix race between svc_rdma_recvfrom thread and the dto_task=
let

Tomas Winkler (4):
      iwlwifi: workaround interrupt handling no some platforms
      iwlwifi: fix 64bit platform firmware loading
      iwlwifi: fix rx_chain computation
      iwlwifi: fix Tx cmd memory allocation failure handling

Tony Breeds (1):
      powerpc: Work around gcc's -fno-omit-frame-pointer bug

Uwe Kleine-K=C3=B6nig (1):
      Fix format of MAINTAINERS

Vegard Nossum (1):
      debugobjects: fix lockdep warning

Venkatesh Pallipadi (1):
      clockevents: prevent clockevent event_handler ending up handler_noo=
p

Will Newton (1):
      8250: improve workaround for UARTs that don't re-assert THRE correc=
tly

Yang Hongyang (1):
      ipv6: When we droped a packet, we should return NET_RX_DROP instead=
 of 0

Yinghai Lu (1):
      x86: move mtrr cpu cap setting early in early_init_xxxx

Yoshihiro Shimoda (1):
      sh: fix semtimedop syscall

Yuri Tikhonov (1):
      async_tx: fix the bug in async_tx_run_dependencies

Zev Weiss (1):
      [MTD] mtdchar.c: Fix regression in MEMGETREGIONINFO ioctl()

Zhao Yakui (1):
      ACPI: Avoid bogus timeout about SMbus check

-----------------------------------------------------------------------


hooks/post-receive
--
linux-cr

--===============9162273289416002368==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============9162273289416002368==--
