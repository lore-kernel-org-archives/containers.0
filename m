From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH] Add linux-next specific files for 20110121
Date: Tue, 25 Jan 2011 10:39:07 +0100
Message-ID: <1295948347-15023-1-git-send-email-daniel.lezcano__35392.2926159159$1295948508$gmane$org@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>

Signed-off-by: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
---
 Next/SHA1s            |  187 ++++
 Next/Trees            |  189 ++++
 Next/merge.log        | 2800 +++++++++++++++++++++++++++++++++++++++++++++++++
 Next/quilt-import.log |   32 +
 localversion-next     |    1 +
 5 files changed, 3209 insertions(+), 0 deletions(-)
 create mode 100644 Next/SHA1s
 create mode 100644 Next/Trees
 create mode 100644 Next/merge.log
 create mode 100644 Next/quilt-import.log
 create mode 100644 localversion-next

diff --git a/Next/SHA1s b/Next/SHA1s
new file mode 100644
index 0000000..70bf6bd
--- /dev/null
+++ b/Next/SHA1s
@@ -0,0 +1,187 @@
+Name		SHA1
+----		----
+origin		12fcdba1b7ae8b25696433f420b775aeb556d89b
+fixes		8a335bc631ac9c43675821580c26ebf95a3044ba
+arm-current	c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
+m68k-current	4565b6d898bfc3c8a79256b1dcbdf62349a0968a
+powerpc-merge	f2e785ed5fb8e5fe5063ee2ba1c8f150396c53c6
+52xx-and-virtex-current	020862648445d7c1b12ea213c152f27def703f3b
+sparc-current	5edddaab1d5d6143c23fef119a24ea768915681a
+scsi-rc-fixes	29687512c0b084957112cc2c0743ce34cd0d5055
+net-current	4580ccc04ddd8c17a470573a7fdb8def2e036dfa
+sound-current	27de094f54a4d96bae2cd3121eb157bb8a34f729
+pci-current	994e0b2c3646ce0ca0e4546e6b10c5cf66b976bf
+wireless-current	38d59392b29437af3a702209b6a5196ef01f79a8
+kbuild-current	7ad1227818f09242cfe9bf1845fd24211f5f99bd
+driver-core.current	c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
+tty.current	df6212529c646710502657b18d8f42927f3dda81
+usb.current	c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
+staging.current	85d139c977dd13cd1ca5cb3b9d8e39cb477eaf0c
+cpufreq-current	948e1f8f08692e35255aea6e417dc62e347a63c7
+input-current	b0f05aadf1516c166ba301b7a535bc9429ce1961
+md-current	bf2cb0dab8c97f00a71875d9b13dbac17a2f47ca
+audit-current	def57543418a5f47debae28a0a9dea2effc11692
+crypto-current	55db8387a5e8d07407f0b7c6b2526417a2bc6243
+ide-curent	dd8717da6da9b0e745df49762be4573010f1013c
+dwmw2		244dc4e54b73567fae7f8fd9ba56584be9375442
+sh-current	30f2ba38011247ad95bffbf0743a0dc0656a5eb7
+rmobile-current	1cf215a5b43950d1a304373037828158057ff9fc
+fbdev-current	cb59bfc59024115279de0d7612558caa72ec95f1
+devicetree-current	5d1034f01b3616d6636ab7851ad9e63d42abbbd6
+spi-current	0bc463426ab5eb39e76df637b29a4f191d01b8a0
+arm		82b69479f66cf7708c7d14052dd2a562ecd421fb
+davinci		28bd2c341120db346f30b3ba11b4eac06b2cc981
+i.MX		33a1af3e417f6cb0e225e0240eb46d8021f0abb9
+linux-spec	5111711d3ed8f4f1012cac3ec3f2b463b549fbfd
+msm		c6d92e9b84da2002ee7a75b784834970ddfd3bfd
+omap		baa600085b266e12076642a86149d3e1aea56e8c
+pxa		19d6c13b56a78b3757e747f469285c2a546d634a
+samsung		6965f4727f4e62ec3a866d46268cf23333127590
+s5p		ccbc87693dcb428443a72d644e63484676517c2d
+tegra		145d43d75daa1a5bc7ce4992c6f36128e44cac56
+ux500-core	c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
+avr32		cbf8de1620cdb1abb5b0618ff561004f816064fc
+blackfin	a780c6e86851c6479851186c5d5b9fb2b201bec7
+cris		bc723779659c2de39a21ef7fa9301736dcfab4bb
+ia64		2016b49522dfec4b139ea2dd2afd90b610baa3b1
+m68k		4565b6d898bfc3c8a79256b1dcbdf62349a0968a
+m68knommu	c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
+microblaze	658b368da198a1436c7d6a0f1f4029d3c6e30b20
+mips		60572c90e7db3c8dd033b64263f085676d067a68
+parisc		7141ee3815191ed4cd2c6b1a7b7f893dea7792ae
+powerpc		5d7d8072edc11080a7cf6cc37c9f4e61ca1e93c9
+4xx		ee2ffd8bbb2170f9b52fc8ff4aebe9702e0de651
+52xx-and-virtex	c9de9333f5a860cab82052bce6ac28bcac9b2c26
+galak		b49d81ded47e9d01f7128fce50d224ccc2150960
+s390		21190e2190e90f61884d7b256532f3089e54ee1a
+sh		8a5a778665efb3a5f16ebb6fbc13356907e45775
+rmobile		170c7ab58f41c526c54e9dd04044857d5d73f9e6
+sparc		0c21e3aaf6ae85bee804a325aa29c325209180fd
+tile		81711cee933599fa114abb0d258d8bbabef8adfb
+xtensa		944afcb4c53f3b841d63ce337fe37b71cea2f52f
+ceph		766fc43973b16f9becb6b7402b3e052dbb84adee
+cifs		76dcc26f1d7f1c98c3f595379dcd9562f01bf38d
+configfs	420118caa32c8ccdf9fce5a623b9de3f951573c5
+ecryptfs	e0e48d45a911888684f87eef18363b17e5fb0b5b
+ext3		f00c9e44ad1a9660fe8cd3ca15b6cd9497172eab
+ext4		0f0a25bf516843adae479636dc1cf75fd0bd003c
+fatfs		7845bc3e132605e3e8a1f37748e29281164b65f5
+fuse		c2061de83c45192f9cc48b6bfdec390b56a68351
+gfs2		3c9a122d8d0a250adcad46d0b9900ed485c39ad0
+hfsplus		b2837fcf4994e699a4def002e26f274d95b387c1
+jfs		c7f2e1f0ac142a657a1de00d404e1c8345b20598
+logfs		ddbb5dd99c40a695d5d75645b5a18bef394acb16
+nfs		12fcdba1b7ae8b25696433f420b775aeb556d89b
+nfsd		a8f2800b4f7b76cecb7209cb6a7d2b14904fc711
+nilfs2		4bde9376e9e56c177bf4e6ed4ece425ef2dbb9d0
+ocfs2		d6351db2073315ddebac72cc1935e912f60f86e0
+omfs		ffc18879903e55487bc5ac3c774b99a07de06029
+squashfs	01a678c5a2f41663b8faf03d17e2bbdbf44158a9
+udf		a4264b3f4049ae7aeeb0017f8158119e22fa354f
+v9fs		52cfd503ad7176d23a5dd7af3981744feb60622f
+ubifs		3c0eee3fe6a3a1c745379547c7e7c904aa64f6d5
+xfs		c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
+vfs		f03c65993b98eeb909a4012ce7833c5857d74755
+vfs-scale	32385c7cf60a78375b63afc4f02001df84dfd1a0
+pci		0f953bf6b4efa0daddb7c418130a9bd3ee97f7ed
+hid		fd82be6c0a359fc706a805a49b1f167af21e63ea
+i2c		c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
+bjdooks-i2c	28d3ccefad07982cd1289dc16fe040f020f1f491
+jdelvare-hwmon	c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
+hwmon-staging	549244756a371b437a499a5007d83fcd347ae454
+kernel-doc	e8a7e48bb248a1196484d3f8afa53bded2b24e71
+v4l-dvb		8cc3ea05eeddc9cd480c69c2683041471879b32e
+kbuild		bef6a5a83edaa8feca5c20e23bd390c34f1e54ee
+kconfig		eae1c36aea9cfe4d123b8af3ffe54109c6579810
+ide		45d7f32c7a43cbb9592886d38190e379e2eb2226
+libata		b9b7b243d991e655cf13e5b6b7df48886f1ba0b3
+infiniband	a25cecce88194b2edf38b8c3b1665e9318eb2d22
+acpi		c703d12b069736bd7a24af161330781f0efb4617
+idle-test	080c9ff973b4f3683293abf8e8bf66b4f082fe65
+ieee1394	1427130425c1239d977e8891c3a8923f53a6e352
+ubi		3c0eee3fe6a3a1c745379547c7e7c904aa64f6d5
+kvm		2d5a857b6090188638b1cc673c2dd3dbf8937e91
+dlm		b9d41052794385f9d47ebb7acf4a772f3ad02398
+swiotlb		e79f86b2ef9c0a8c47225217c1018b7d3d90101c
+ibft		3e0f686e6bf347eea4a41d7d415f003c2f42b1a0
+scsi		c32e061fa19893ce4acf95d97d5613a161f0f1b7
+async_tx	94ae85220a07d357d4937086c490854f63344de4
+net		a5db219f4cf9f67995eabd53b81a1232c82f5852
+wireless	fbb327c5945448e98480d610815143a6d4a63638
+bluetooth	e567f216e97dc78ce5dfa347434c2411a64db7ce
+mtd		154bf89f5e3e3dc59666926f27ca4a0866f39157
+crypto		55db8387a5e8d07407f0b7c6b2526417a2bc6243
+sound		7c3487b6f12c4b2b20fd3c1251296583600f533b
+sound-asoc	9978007befa5efdc16dc940631c594f420f96b09
+cpufreq		62bfdfa1de1361b2fb8201c72def1bbca5e7a395
+rr		cb941980e273dd27825ac12b6003e3f69c65eb29
+input		50a88cb7eddb971077ae7dff76b116747c12c371
+input-mt	c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
+lsm		ca05a99a54db1db5bca72eccb5866d2a86f8517f
+block		c553f8e335c00a7cff3ab3f13e793b13d3f2207f
+device-mapper	52cfd503ad7176d23a5dd7af3981744feb60622f
+embedded	4744b43431e8613f920c5cba88346756f53c5165
+firmware	6e03a201bbe8137487f340d26aa662110e324b20
+pcmcia		106665d937df6eff33c71997a52f7bc3aefa6c12
+battery		359ab9f5b154cbd807a11e22792235f0f36b0cd5
+leds		a4b4433c511cf4361bb0afabba69e16632002d32
+backlight	67e67df8da723debf24f7763605776891203e8d5
+mmc		ad1979d80f778155a1a89d4d1e74b5e0c87bda3e
+kgdb		62f6d9b5d890c6dacf17e629d91085937990ccc0
+slab		06ab9b76ecf2e4796b0b5a88f673cb693b4448d5
+uclinux		6e86841d05f371b5b9b86ce76c02aaee83352298
+md		a761565816d16ffc698b872c49a7d33224d2f317
+mfd		92d50a4132977b932ed830fa58c05deeb5c524f0
+hdlc		4a6908a3a050aacc9c3a2f36b276b46c0629ad91
+drm		56bec7c009872ef33fe452ea75fecba481351b44
+fbdev		0b7f1cc79d61427961e311c6a21f528bdb226e40
+viafb		b884a94ed16d1a633e76f80fb1bd75d0e7373ce3
+omap_dss2	18016e35d448d35739f8640b51476709c07e95db
+voltage		c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
+security-testing	7898e1f8e9eb1bee88c92d636e0ab93f2cbe31c6
+selinux		350e4f31e0eaf56dfc3b328d24a11bdf42a41fb8
+lblnet		7e27d6e778cd87b6f2415515d7127eba53fe5d02
+agp		7f32e2e05c240201b42b58dec1b4a072e2127792
+watchdog	7c169fa3b101c92b3b409f852a815a5cfa2b3587
+bdev		feaf3848a813a106f163013af6fcf6c4bfec92d9
+dwmw2-iommu	7a6610139a1e1d9297dd1c5d178022eac36839cb
+cputime		96830a57de1197519b62af6a4c9ceea556c18c3d
+osd		fe2fd9ed5bf184f797412be8b86f4589d1b77bb8
+jc_docs		4047f8b1f9f4b4ecc4863f5f10cd9ba388b32a94
+nommu		9a100a4464917b5ffff3a8ce1c2758088fd9bb32
+trivial		42b16b3fbb5ee4555f5dee6220f3ccaa6e1ebe47
+audit		def57543418a5f47debae28a0a9dea2effc11692
+suspend		a08948812b30653eb2c536ae613b635a989feb6f
+fsnotify	ef9bf3b7144bee6ce1da5616015cabc8771206af
+irda		94d57c4cfaa43e29ca5fa5ff874048cfc67276f5
+catalin		c8ddb2713c624f432fa5fe3c7ecffcdda46ea0d4
+alacrity	17d1061f5d87eff7d50942399414845d1f7a8a08
+i7core_edac	24c70a0e06fbadbe66fbb26f41b64153c5c1efbd
+i7300_edac	bbab9984d7e65f08d3083814103b91b3dd382381
+devicetree	8c34482c17d8fd07966328c7b1cfc35ee290bd1c
+spi		94a1b6d8eb903818773ad24fe48529b0d295052d
+tip		b04de4f73d80637eac60a94b7b5045292c3990c4
+rcu		b24efdfdf679cf9b05947c531971905fc727dd40
+oprofile	5ee0fcc34833c7e6acfd8692af33a78ae529d9c5
+swiotlb-xen	090b92e4778fed19aa4378c2bda3edb0e4c5bbf1
+xen-pvhvm	e0b58be59e4e278480b120ba827b8cfee7c7ddbd
+edac-amd	295839e770f95a272d25dc707183cb5f9ba14c1c
+percpu		2485b6464cf86a5bc361666838f2439c99c00567
+workqueues	42c025f3de9042d9c9abd9a6f6205d1a0f4bcadf
+sfi		5b026c4e3af52fda22c9313a3388344f82f3ba15
+asm-generic	35dbc0e020c6587f78a6c17693beca73aead7b54
+drivers-x86	1a7d946993aaf2a79e9c65abbe169a108e351bcb
+hwpoison	46e387bbd82d438b9131e237e6e2cb55a825da49
+sysctl		c656ae95d1c5c8ed5763356263ace2d03087efec
+driver-core	c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
+tty		c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
+usb		c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
+staging		651bd3a9ff2bd1c25998d5f66be3e2eb220c5910
+slabh		7f3c1fa4c3f52ef65005ae5162e5173e875b8c0c
+bkl-trivial	2a48fc0ab24241755dc93bfd4f01d68efab47f5a
+bkl-llseek	776c163b1b93c8dfa5edba885bc2bfbc2d228a5f
+bkl-vfs		6d7bccc2215c37205ede6c9cf84db64e7c4f9443
+bkl-config	a3ba01b63468c925518da2da0ac3be11358f60cb
+irqflags	df9ee29270c11dba7d0fe0b83ce47a4d8e8d2101
+cleancache	5231e92e133d6db6681a4485b1794a01469ca9ad
+scsi-post-merge	c66ac9db8d4ad9994a02b3e933ea2ccc643e1fe5
diff --git a/Next/Trees b/Next/Trees
new file mode 100644
index 0000000..f2db88b
--- /dev/null
+++ b/Next/Trees
@@ -0,0 +1,189 @@
+Trees included into this release:
+
+Name		Type	URL
+----		----	---
+origin		git	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git#master
+fixes		git	-#fixes
+arm-current	git	ssh://master.kernel.org/home/rmk/linux-2.6-arm.git#master
+m68k-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/geert/linux-m68k.git#for-linus
+powerpc-merge	git	git://git.kernel.org/pub/scm/linux/kernel/git/benh/powerpc.git#merge
+52xx-and-virtex-current	git	git://git.secretlab.ca/git/linux-2.6#powerpc/merge
+sparc-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6.git#master
+scsi-rc-fixes	git	git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-rc-fixes-2.6.git#master
+net-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git#master
+sound-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound-2.6.git#for-linus
+pci-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/jbarnes/pci-2.6#for-linus
+wireless-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git#master
+kbuild-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/mmarek/kbuild-2.6.git#rc-fixes
+driver-core.current	git	git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core-2.6.git#driver-core-linus
+tty.current	git	git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/tty-2.6.git#tty-linus
+usb.current	git	git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6.git#usb-linus
+staging.current	git	git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-2.6.git#staging-linus
+cpufreq-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/davej/cpufreq.git#fixes
+input-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/dtor/input.git#for-linus
+md-current	git	git://neil.brown.name/md#for-linus
+audit-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/viro/audit-current.git#for-linus
+crypto-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-2.6#master
+ide-curent	git	git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide-2.6.git#master
+dwmw2		git	git://git.infradead.org/users/dwmw2/random-2.6.git#master
+sh-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6.git#sh-fixes-for-linus
+rmobile-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6.git#rmobile-fixes-for-linus
+fbdev-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/lethal/fbdev-2.6.git#fbdev-fixes-for-linus
+devicetree-current	git	git://git.secretlab.ca/git/linux-2.6#devicetree/merge
+spi-current	git	git://git.secretlab.ca/git/linux-2.6#spi/merge
+arm		git	ssh://master.kernel.org/home/rmk/linux-2.6-arm.git#devel
+davinci		git	git://git.kernel.org/pub/scm/linux/kernel/git/khilman/linux-davinci.git#davinci-next
+i.MX		git	git://git.pengutronix.de/git/imx/linux-2.6.git#for-next
+linux-spec	git	http://git.kernel.org/pub/scm/linux/kernel/git/dwalker/linux-spec#for-next
+msm		git	git://codeaurora.org/quic/kernel/davidb/linux-msm.git#for-next
+omap		git	git://git.kernel.org/pub/scm/linux/kernel/git/tmlind/linux-omap-2.6.git#for-next
+pxa		git	git://git.kernel.org/pub/scm/linux/kernel/git/ycmiao/pxa-linux-2.6.git#for-next
+samsung		git	git://git.fluff.org/bjdooks/linux.git#next-samsung
+s5p		git	git://git.kernel.org/pub/scm/linux/kernel/git/kgene/linux-samsung.git#for-next
+tegra		git	git://android.git.kernel.org/kernel/tegra.git#for-next
+ux500-core	git	git://git.kernel.org/pub/scm/linux/kernel/git/linusw/linux-stericsson.git#ux500-core
+avr32		git	git://git.kernel.org/pub/scm/linux/kernel/git/hskinnemoen/avr32-2.6.git#avr32-arch
+blackfin	git	git://git.kernel.org/pub/scm/linux/kernel/git/vapier/blackfin.git#for-linus
+cris		git	git://www.jni.nu/cris.git#for-next
+ia64		git	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git#test
+m68k		git	git://git.kernel.org/pub/scm/linux/kernel/git/geert/linux-m68k.git#for-next
+m68knommu	git	git://git.kernel.org/pub/scm/linux/kernel/git/gerg/m68knommu.git#for-next
+microblaze	git	git://git.monstr.eu/linux-2.6-microblaze.git#next
+mips		git	git://git.linux-mips.org/pub/scm/upstream-sfr.git#mips-for-linux-next
+parisc		git	git://git.kernel.org/pub/scm/linux/kernel/git/jejb/parisc-2.6.git#for-next
+powerpc		git	git://git.kernel.org/pub/scm/linux/kernel/git/benh/powerpc.git#next
+4xx		git	git://git.kernel.org/pub/scm/linux/kernel/git/jwboyer/powerpc-4xx.git#next
+52xx-and-virtex	git	git://git.secretlab.ca/git/linux-2.6#powerpc/next
+galak		git	git://git.kernel.org/pub/scm/linux/kernel/git/galak/powerpc.git#next
+s390		git	git://git390.marist.edu/pub/scm/linux-2.6.git#features
+sh		git	git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6.git#sh-latest
+rmobile		git	git://git.kernel.org/pub/scm/linux/kernel/git/lethal/sh-2.6.git#rmobile-latest
+sparc		git	git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-next-2.6.git#master
+tile		git	git://git.kernel.org/pub/scm/linux/kernel/git/cmetcalf/linux-tile.git#master
+xtensa		git	git://git.kernel.org/pub/scm/linux/kernel/git/czankel/xtensa-next.git#master
+ceph		git	git://git.kernel.org/pub/scm/linux/kernel/git/sage/ceph-client.git#for-next
+cifs		git	git://git.kernel.org/pub/scm/linux/kernel/git/sfrench/cifs-2.6.git#master
+configfs	git	git://git.kernel.org/pub/scm/linux/kernel/git/jlbec/configfs.git#linux-next
+ecryptfs	git	git://git.kernel.org/pub/scm/linux/kernel/git/ecryptfs/ecryptfs-2.6.git#next
+ext3		git	git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs-2.6.git#for_next
+ext4		git	git://git.kernel.org/pub/scm/linux/kernel/git/tytso/ext4.git#next
+fatfs		git	git://git.kernel.org/pub/scm/linux/kernel/git/hirofumi/fatfs-2.6.git#master
+fuse		git	git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/fuse.git#for-next
+gfs2		git	git://git.kernel.org/pub/scm/linux/kernel/git/steve/gfs2-2.6-nmw.git#master
+hfsplus		git	git://git.kernel.org/pub/scm/linux/kernel/git/hch/hfsplus.git#for-next
+jfs		git	git://git.kernel.org/pub/scm/linux/kernel/git/shaggy/jfs-2.6.git#next
+logfs		git	git://git.kernel.org/pub/scm/linux/kernel/git/joern/logfs.git#master
+nfs		git	git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git#linux-next
+nfsd		git	git://git.linux-nfs.org/~bfields/linux.git#nfsd-next
+nilfs2		git	git://git.kernel.org/pub/scm/linux/kernel/git/ryusuke/nilfs2.git#for-next
+ocfs2		git	git://git.kernel.org/pub/scm/linux/kernel/git/jlbec/ocfs2.git#linux-next
+omfs		git	git://git.kernel.org/pub/scm/linux/kernel/git/bcopeland/omfs.git#for-next
+squashfs	git	git://git.kernel.org/pub/scm/linux/kernel/git/pkl/squashfs-linus.git#master
+udf		git	git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-udf-2.6.git#for_next
+v9fs		git	git://git.kernel.org/pub/scm/linux/kernel/git/ericvh/v9fs.git#for-next
+ubifs		git	git://git.infradead.org/ubifs-2.6.git#linux-next
+xfs		git	git://oss.sgi.com/xfs/xfs#master
+vfs		git	git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git#for-next
+vfs-scale	git	git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git#vfs-scale-working
+pci		git	git://git.kernel.org/pub/scm/linux/kernel/git/jbarnes/pci-2.6#linux-next
+hid		git	git://git.kernel.org/pub/scm/linux/kernel/git/jikos/hid.git#for-next
+i2c		quilt	http://kernel.org/pub/linux/kernel/people/jdelvare/linux-2.6/jdelvare-i2c/
+bjdooks-i2c	git	git://git.fluff.org/bjdooks/linux.git#next-i2c
+jdelvare-hwmon	quilt	http://kernel.org/pub/linux/kernel/people/jdelvare/linux-2.6/jdelvare-hwmon/
+hwmon-staging	git	git://git.kernel.org/pub/scm/linux/kernel/git/groeck/linux-staging.git#hwmon-next
+kernel-doc	quilt	http://oss.oracle.com/~rdunlap/kernel-doc-patches/current/
+v4l-dvb		git	git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/linux-next.git#master
+kbuild		git	git://git.kernel.org/pub/scm/linux/kernel/git/mmarek/kbuild-2.6.git#for-next
+kconfig		git	git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-kconfig.git#for-next
+ide		git	git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide-next-2.6.git#master
+libata		git	git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/libata-dev.git#NEXT
+infiniband	git	git://git.kernel.org/pub/scm/linux/kernel/git/roland/infiniband.git#for-next
+acpi		git	git://git.kernel.org/pub/scm/linux/kernel/git/lenb/linux-acpi-2.6.git#test
+idle-test	git	git://git.kernel.org/pub/scm/linux/kernel/git/lenb/linux-acpi-2.6.git#idle-test
+ieee1394	git	git://git.kernel.org/pub/scm/linux/kernel/git/ieee1394/linux1394-2.6.git#for-next
+ubi		git	git://git.infradead.org/ubi-2.6.git#linux-next
+kvm		git	git://git.kernel.org/pub/scm/linux/kernel/git/avi/kvm.git#linux-next
+dlm		git	git://git.kernel.org/pub/scm/linux/kernel/git/teigland/dlm.git#next
+swiotlb		git	git://git.kernel.org/pub/scm/linux/kernel/git/konrad/swiotlb-2.6.git#master
+ibft		git	git://git.kernel.org/pub/scm/linux/kernel/git/konrad/ibft-2.6.git#master
+scsi		git	git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-misc-2.6.git#master
+async_tx	git	git://git.kernel.org/pub/scm/linux/kernel/git/djbw/async_tx.git#next
+net		git	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git#master
+wireless	git	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git#master
+bluetooth	git	git://git.kernel.org/pub/scm/linux/kernel/git/padovan/bluetooth-next-2.6.git#master
+mtd		git	git://git.infradead.org/mtd-2.6.git#master
+crypto		git	git://git.kernel.org/pub/scm/linux/kernel/git/herbert/cryptodev-2.6#master
+sound		git	git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound-2.6.git#for-next
+sound-asoc	git	git://git.kernel.org/pub/scm/linux/kernel/git/broonie/sound-2.6.git#for-next
+cpufreq		git	git://git.kernel.org/pub/scm/linux/kernel/git/davej/cpufreq.git#next
+rr		quilt	http://ozlabs.org/~rusty/kernel/rr-latest/
+input		git	git://git.kernel.org/pub/scm/linux/kernel/git/dtor/input.git#next
+input-mt	git	git://git.kernel.org/pub/scm/linux/kernel/git/rydberg/input-mt.git#next
+lsm		git	git://git.kernel.org/pub/scm/linux/kernel/git/chrisw/lsm-2.6.git#for-next
+block		git	git://git.kernel.dk/linux-2.6-block.git#for-next
+device-mapper	quilt	http://www.kernel.org/pub/linux/kernel/people/agk/patches/2.6/editing/
+embedded	git	git://git.infradead.org/embedded-2.6.git#master
+firmware	git	git://git.infradead.org/users/dwmw2/firmware-2.6.git#master
+pcmcia		git	git://git.kernel.org/pub/scm/linux/kernel/git/brodo/pcmcia-2.6.git#master
+battery		git	git://git.infradead.org/battery-2.6.git#master
+leds		git	git://git.o-hand.com/linux-rpurdie-leds#for-mm
+backlight	git	git://git.o-hand.com/linux-rpurdie-backlight#for-mm
+mmc		git	git://git.kernel.org/pub/scm/linux/kernel/git/cjb/mmc.git#mmc-next
+kgdb		git	git://git.kernel.org/pub/scm/linux/kernel/git/jwessel/linux-2.6-kgdb#kgdb-next
+slab		git	git://git.kernel.org/pub/scm/linux/kernel/git/penberg/slab-2.6.git#for-next
+uclinux		git	git://git.kernel.org/pub/scm/linux/kernel/git/gerg/uclinux.git#for-next
+md		git	git://neil.brown.name/md#for-next
+mfd		git	git://git.kernel.org/pub/scm/linux/kernel/git/sameo/mfd-2.6.git#for-next
+hdlc		git	git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git#hdlc-next
+drm		git	git://git.kernel.org/pub/scm/linux/kernel/git/airlied/drm-2.6.git#drm-next
+fbdev		git	git://git.kernel.org/pub/scm/linux/kernel/git/lethal/fbdev-2.6.git#master
+viafb		git	git://github.com/schandinat/linux-2.6.git#viafb-next
+omap_dss2	git	git://gitorious.org/linux-omap-dss2/linux.git#for-next
+voltage		git	git://git.kernel.org/pub/scm/linux/kernel/git/lrg/voltage-2.6.git#for-next
+security-testing	git	git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/security-testing-2.6.git#next
+selinux		git	git://git.infradead.org/users/eparis/selinux.git#master
+lblnet		git	git://git.infradead.org/users/pcmoore/lblnet-2.6_next#master
+agp		git	git://git.kernel.org/pub/scm/linux/kernel/git/airlied/agp-2.6.git#agp-next
+watchdog	git	git://git.kernel.org/pub/scm/linux/kernel/git/wim/linux-2.6-watchdog-next.git#master
+bdev		git	git://git.kernel.org/pub/scm/linux/kernel/git/viro/bdev.git#master
+dwmw2-iommu	git	git://git.infradead.org/iommu-2.6.git#master
+cputime		git	git://git390.marist.edu/pub/scm/linux-2.6.git#cputime
+osd		git	git://git.open-osd.org/linux-open-osd.git#linux-next
+jc_docs		git	git://git.lwn.net/linux-2.6.git#docs-next
+nommu		git	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-2.6-nommu.git#master
+trivial		git	git://git.kernel.org/pub/scm/linux/kernel/git/jikos/trivial.git#for-next
+audit		git	git://git.kernel.org/pub/scm/linux/kernel/git/viro/audit-current.git#for-next
+suspend		git	git://git.kernel.org/pub/scm/linux/kernel/git/rafael/suspend-2.6.git#linux-next
+fsnotify	git	git://git.infradead.org/users/eparis/notify.git#for-next
+irda		git	git://git.kernel.org/pub/scm/linux/kernel/git/sameo/irda-2.6.git#for-next
+catalin		git	git://linux-arm.org/linux-2.6.git#for-next
+alacrity	git	git://git.kernel.org/pub/scm/linux/kernel/git/ghaskins/alacrityvm/linux-2.6.git#linux-next
+i7core_edac	git	git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/i7core.git#linux_next
+i7300_edac	git	git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/edac.git#linux_next
+devicetree	git	git://git.secretlab.ca/git/linux-2.6#devicetree/next
+spi		git	git://git.secretlab.ca/git/linux-2.6#spi/next
+tip		git	git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git#auto-latest
+rcu		git	git://git.kernel.org/pub/scm/linux/kernel/git/paulmck/linux-2.6-rcu.git#rcu/next
+oprofile	git	git://git.kernel.org/pub/scm/linux/kernel/git/rric/oprofile.git#for-next
+swiotlb-xen	git	git://git.kernel.org/pub/scm/linux/kernel/git/konrad/xen.git#master
+xen-pvhvm	git	git://xenbits.xen.org/people/sstabellini/linux-pvhvm.git#linux-next
+edac-amd	git	git://git.kernel.org/pub/scm/linux/kernel/git/bp/bp.git#for-next
+percpu		git	git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu.git#for-next
+workqueues	git	git://git.kernel.org/pub/scm/linux/kernel/git/tj/wq.git#for-next
+sfi		git	git://git.kernel.org/pub/scm/linux/kernel/git/lenb/linux-sfi-2.6.git#sfi-test
+asm-generic	git	git://git.kernel.org/pub/scm/linux/kernel/git/arnd/asm-generic#next
+drivers-x86	git	git://git.kernel.org/pub/scm/linux/kernel/git/mjg59/platform-drivers-x86#linux-next
+hwpoison	git	git://git.kernel.org/pub/scm/linux/kernel/git/ak/linux-mce-2.6.git#hwpoison
+sysctl		git	git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/sysctl-2.6.git#master
+driver-core	git	git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core-2.6.git#driver-core-next
+tty		git	git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/tty-2.6.git#tty-next
+usb		git	git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6.git#usb-next
+staging		git	git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-2.6.git#staging-next
+slabh		git	git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git#slabh
+bkl-trivial	git	git://git.kernel.org/pub/scm/linux/kernel/git/arnd/bkl.git#trivial
+bkl-llseek	git	git://git.kernel.org/pub/scm/linux/kernel/git/arnd/bkl.git#llseek
+bkl-vfs		git	git://git.kernel.org/pub/scm/linux/kernel/git/arnd/bkl.git#vfs
+bkl-config	git	git://git.kernel.org/pub/scm/linux/kernel/git/arnd/bkl.git#config
+irqflags	git	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-2.6-irqflags.git#master
+cleancache	git	git://git.kernel.org/pub/scm/linux/kernel/git/djm/tmem.git#linux-next
+scsi-post-merge	git	git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-post-merge-2.6.git#master
diff --git a/Next/merge.log b/Next/merge.log
new file mode 100644
index 0000000..b52d58e
--- /dev/null
+++ b/Next/merge.log
@@ -0,0 +1,2800 @@
+$ git checkout master
+Already on 'master'
+$ git reset --hard stable
+HEAD is now at c56eb8f Linux 2.6.38-rc1
+Merging origin/master
+$ git merge origin/master
+Updating c56eb8f..12fcdba
+Fast-forward
+ arch/x86/include/asm/numa_32.h                     |    2 +
+ arch/x86/include/asm/numa_64.h                     |    1 +
+ arch/x86/kernel/vmlinux.lds.S                      |   11 +-
+ arch/x86/mm/numa.c                                 |   22 ++
+ arch/x86/mm/numa_64.c                              |   24 +--
+ arch/x86/mm/srat_32.c                              |    1 -
+ drivers/net/bnx2x/bnx2x.h                          |    4 +-
+ drivers/net/bnx2x/bnx2x_hsi.h                      |    4 +
+ drivers/net/bnx2x/bnx2x_link.c                     |  173 ++++++++++---
+ drivers/net/bnx2x/bnx2x_reg.h                      |    4 +
+ drivers/net/gianfar.c                              |    2 +-
+ drivers/net/irda/sh_irda.c                         |   14 +-
+ drivers/net/ns83820.c                              |    5 +-
+ drivers/net/usb/cdc_ncm.c                          |   19 +-
+ drivers/net/vmxnet3/vmxnet3_drv.c                  |   93 +++++---
+ drivers/net/vmxnet3/vmxnet3_ethtool.c              |  274 ++++++++++++--------
+ drivers/net/vmxnet3/vmxnet3_int.h                  |    7 +-
+ drivers/net/wireless/ath/ath5k/base.c              |    4 +
+ drivers/net/wireless/ath/ath9k/ar9002_calib.c      |   10 +-
+ .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |    2 +-
+ drivers/net/wireless/ath/ath9k/ar9003_hw.c         |    4 +-
+ drivers/net/wireless/ath/ath9k/htc.h               |    2 +-
+ drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |    8 +-
+ drivers/net/wireless/iwlwifi/iwl-agn-eeprom.c      |    2 +-
+ drivers/net/wireless/iwmc3200wifi/netdev.c         |    2 +
+ drivers/net/wireless/rt2x00/rt2x00firmware.c       |    1 +
+ drivers/s390/net/qeth_l2_main.c                    |   18 ++-
+ drivers/s390/net/qeth_l3_main.c                    |   22 ++-
+ include/linux/ieee80211.h                          |    2 +-
+ include/net/sctp/user.h                            |    1 +
+ net/batman-adv/main.h                              |    6 +-
+ net/batman-adv/packet.h                            |   14 +-
+ net/batman-adv/types.h                             |    4 +-
+ net/batman-adv/unicast.c                           |    6 +-
+ net/caif/cfcnfg.c                                  |    9 +-
+ net/can/bcm.c                                      |    3 +
+ net/can/raw.c                                      |    3 +
+ net/core/dev.c                                     |    6 +-
+ net/core/rtnetlink.c                               |    2 +-
+ net/ipv4/inet_diag.c                               |    2 +-
+ net/ipv6/addrconf.c                                |    3 -
+ net/mac80211/agg-rx.c                              |   11 +-
+ net/mac80211/main.c                                |   12 +-
+ net/netfilter/nf_conntrack_netlink.c               |    4 +-
+ net/netlink/genetlink.c                            |    2 +-
+ net/sctp/socket.c                                  |    4 +-
+ net/xfrm/xfrm_user.c                               |    2 +-
+ 47 files changed, 544 insertions(+), 287 deletions(-)
+Merging fixes/fixes
+$ git merge fixes/fixes
+Already up-to-date.
+Merging arm-current/master
+$ git merge arm-current/master
+Already up-to-date.
+Merging m68k-current/for-linus
+$ git merge m68k-current/for-linus
+Merge made by recursive.
+ arch/m68k/include/asm/string.h |   12 ------------
+ 1 files changed, 0 insertions(+), 12 deletions(-)
+Merging powerpc-merge/merge
+$ git merge powerpc-merge/merge
+Already up-to-date.
+Merging 52xx-and-virtex-current/powerpc/merge
+$ git merge 52xx-and-virtex-current/powerpc/merge
+Already up-to-date.
+Merging sparc-current/master
+$ git merge sparc-current/master
+Already up-to-date.
+Merging scsi-rc-fixes/master
+$ git merge scsi-rc-fixes/master
+Already up-to-date.
+Merging net-current/master
+$ git merge net-current/master
+Already up-to-date.
+Merging sound-current/for-linus
+$ git merge sound-current/for-linus
+Already up-to-date.
+Merging pci-current/for-linus
+$ git merge pci-current/for-linus
+Already up-to-date.
+Merging wireless-current/master
+$ git merge wireless-current/master
+Already up-to-date.
+Merging kbuild-current/rc-fixes
+$ git merge kbuild-current/rc-fixes
+Already up-to-date.
+Merging driver-core.current/driver-core-linus
+$ git merge driver-core.current/driver-core-linus
+Already up-to-date.
+Merging tty.current/tty-linus
+$ git merge tty.current/tty-linus
+Auto-merging MAINTAINERS
+Auto-merging drivers/Makefile
+Merge made by recursive.
+ MAINTAINERS                                       |   50 ++++++++++----------
+ drivers/Makefile                                  |    3 +-
+ drivers/char/Kconfig                              |    2 +-
+ drivers/char/Makefile                             |   13 -----
+ drivers/tty/Makefile                              |    2 +
+ drivers/tty/hvc/Makefile                          |   13 +++++
+ drivers/{char => tty/hvc}/hvc_beat.c              |    0
+ drivers/{char => tty/hvc}/hvc_console.c           |    0
+ drivers/{char => tty/hvc}/hvc_console.h           |    0
+ drivers/{char => tty/hvc}/hvc_dcc.c               |    0
+ drivers/{char => tty/hvc}/hvc_irq.c               |    0
+ drivers/{char => tty/hvc}/hvc_iseries.c           |    0
+ drivers/{char => tty/hvc}/hvc_iucv.c              |    0
+ drivers/{char => tty/hvc}/hvc_rtas.c              |    0
+ drivers/{char => tty/hvc}/hvc_tile.c              |    0
+ drivers/{char => tty/hvc}/hvc_udbg.c              |    0
+ drivers/{char => tty/hvc}/hvc_vio.c               |    0
+ drivers/{char => tty/hvc}/hvc_xen.c               |    0
+ drivers/{char => tty/hvc}/hvcs.c                  |    0
+ drivers/{char => tty/hvc}/hvsi.c                  |    0
+ drivers/{char => tty/hvc}/virtio_console.c        |    0
+ drivers/{ => tty}/serial/21285.c                  |    0
+ drivers/{ => tty}/serial/68328serial.c            |    0
+ drivers/{ => tty}/serial/68328serial.h            |    0
+ drivers/{ => tty}/serial/68360serial.c            |    0
+ drivers/{ => tty}/serial/8250.c                   |    0
+ drivers/{ => tty}/serial/8250.h                   |    0
+ drivers/{ => tty}/serial/8250_accent.c            |    0
+ drivers/{ => tty}/serial/8250_acorn.c             |    0
+ drivers/{ => tty}/serial/8250_boca.c              |    0
+ drivers/{ => tty}/serial/8250_early.c             |    0
+ drivers/{ => tty}/serial/8250_exar_st16c554.c     |    0
+ drivers/{ => tty}/serial/8250_fourport.c          |    0
+ drivers/{ => tty}/serial/8250_gsc.c               |    0
+ drivers/{ => tty}/serial/8250_hp300.c             |    0
+ drivers/{ => tty}/serial/8250_hub6.c              |    0
+ drivers/{ => tty}/serial/8250_mca.c               |    0
+ drivers/{ => tty}/serial/8250_pci.c               |    0
+ drivers/{ => tty}/serial/8250_pnp.c               |    0
+ drivers/{ => tty}/serial/Kconfig                  |    0
+ drivers/{ => tty}/serial/Makefile                 |    0
+ drivers/{ => tty}/serial/altera_jtaguart.c        |    0
+ drivers/{ => tty}/serial/altera_uart.c            |    0
+ drivers/{ => tty}/serial/amba-pl010.c             |    0
+ drivers/{ => tty}/serial/amba-pl011.c             |    0
+ drivers/{ => tty}/serial/apbuart.c                |    0
+ drivers/{ => tty}/serial/apbuart.h                |    0
+ drivers/{ => tty}/serial/atmel_serial.c           |    0
+ drivers/{ => tty}/serial/bcm63xx_uart.c           |    0
+ drivers/{ => tty}/serial/bfin_5xx.c               |    0
+ drivers/{ => tty}/serial/bfin_sport_uart.c        |    0
+ drivers/{ => tty}/serial/bfin_sport_uart.h        |    0
+ drivers/{ => tty}/serial/clps711x.c               |    0
+ drivers/{ => tty}/serial/cpm_uart/Makefile        |    0
+ drivers/{ => tty}/serial/cpm_uart/cpm_uart.h      |    0
+ drivers/{ => tty}/serial/cpm_uart/cpm_uart_core.c |    0
+ drivers/{ => tty}/serial/cpm_uart/cpm_uart_cpm1.c |    0
+ drivers/{ => tty}/serial/cpm_uart/cpm_uart_cpm1.h |    0
+ drivers/{ => tty}/serial/cpm_uart/cpm_uart_cpm2.c |    0
+ drivers/{ => tty}/serial/cpm_uart/cpm_uart_cpm2.h |    0
+ drivers/{ => tty}/serial/crisv10.c                |    0
+ drivers/{ => tty}/serial/crisv10.h                |    0
+ drivers/{ => tty}/serial/dz.c                     |    0
+ drivers/{ => tty}/serial/dz.h                     |    0
+ drivers/{ => tty}/serial/icom.c                   |    0
+ drivers/{ => tty}/serial/icom.h                   |    0
+ drivers/{ => tty}/serial/ifx6x60.c                |    0
+ drivers/{ => tty}/serial/ifx6x60.h                |    0
+ drivers/{ => tty}/serial/imx.c                    |    0
+ drivers/{ => tty}/serial/ioc3_serial.c            |    0
+ drivers/{ => tty}/serial/ioc4_serial.c            |    0
+ drivers/{ => tty}/serial/ip22zilog.c              |    0
+ drivers/{ => tty}/serial/ip22zilog.h              |    0
+ drivers/{ => tty}/serial/jsm/Makefile             |    0
+ drivers/{ => tty}/serial/jsm/jsm.h                |    0
+ drivers/{ => tty}/serial/jsm/jsm_driver.c         |    0
+ drivers/{ => tty}/serial/jsm/jsm_neo.c            |    0
+ drivers/{ => tty}/serial/jsm/jsm_tty.c            |    0
+ drivers/{ => tty}/serial/kgdboc.c                 |    0
+ drivers/{ => tty}/serial/m32r_sio.c               |    0
+ drivers/{ => tty}/serial/m32r_sio.h               |    0
+ drivers/{ => tty}/serial/m32r_sio_reg.h           |    0
+ drivers/{ => tty}/serial/max3100.c                |    0
+ drivers/{ => tty}/serial/max3107-aava.c           |    0
+ drivers/{ => tty}/serial/max3107.c                |    0
+ drivers/{ => tty}/serial/max3107.h                |    0
+ drivers/{ => tty}/serial/mcf.c                    |    0
+ drivers/{ => tty}/serial/mfd.c                    |    0
+ drivers/{ => tty}/serial/mpc52xx_uart.c           |    0
+ drivers/{ => tty}/serial/mpsc.c                   |    0
+ drivers/{ => tty}/serial/mrst_max3110.c           |    0
+ drivers/{ => tty}/serial/mrst_max3110.h           |    0
+ drivers/{ => tty}/serial/msm_serial.c             |    0
+ drivers/{ => tty}/serial/msm_serial.h             |    0
+ drivers/{ => tty}/serial/mux.c                    |    0
+ drivers/{ => tty}/serial/netx-serial.c            |    0
+ drivers/{ => tty}/serial/nwpserial.c              |    0
+ drivers/{ => tty}/serial/of_serial.c              |    0
+ drivers/{ => tty}/serial/omap-serial.c            |    0
+ drivers/{ => tty}/serial/pch_uart.c               |    0
+ drivers/{ => tty}/serial/pmac_zilog.c             |    0
+ drivers/{ => tty}/serial/pmac_zilog.h             |    0
+ drivers/{ => tty}/serial/pnx8xxx_uart.c           |    0
+ drivers/{ => tty}/serial/pxa.c                    |    0
+ drivers/{ => tty}/serial/s3c2400.c                |    0
+ drivers/{ => tty}/serial/s3c2410.c                |    0
+ drivers/{ => tty}/serial/s3c2412.c                |    0
+ drivers/{ => tty}/serial/s3c2440.c                |    0
+ drivers/{ => tty}/serial/s3c24a0.c                |    0
+ drivers/{ => tty}/serial/s3c6400.c                |    0
+ drivers/{ => tty}/serial/s5pv210.c                |    0
+ drivers/{ => tty}/serial/sa1100.c                 |    0
+ drivers/{ => tty}/serial/samsung.c                |    0
+ drivers/{ => tty}/serial/samsung.h                |    0
+ drivers/{ => tty}/serial/sb1250-duart.c           |    0
+ drivers/{ => tty}/serial/sc26xx.c                 |    0
+ drivers/{ => tty}/serial/serial_core.c            |    0
+ drivers/{ => tty}/serial/serial_cs.c              |    0
+ drivers/{ => tty}/serial/serial_ks8695.c          |    0
+ drivers/{ => tty}/serial/serial_lh7a40x.c         |    0
+ drivers/{ => tty}/serial/serial_txx9.c            |    0
+ drivers/{ => tty}/serial/sh-sci.c                 |    0
+ drivers/{ => tty}/serial/sh-sci.h                 |    0
+ drivers/{ => tty}/serial/sn_console.c             |    0
+ drivers/{ => tty}/serial/suncore.c                |    0
+ drivers/{ => tty}/serial/suncore.h                |    0
+ drivers/{ => tty}/serial/sunhv.c                  |    0
+ drivers/{ => tty}/serial/sunsab.c                 |    0
+ drivers/{ => tty}/serial/sunsab.h                 |    0
+ drivers/{ => tty}/serial/sunsu.c                  |    0
+ drivers/{ => tty}/serial/sunzilog.c               |    0
+ drivers/{ => tty}/serial/sunzilog.h               |    0
+ drivers/{ => tty}/serial/timbuart.c               |    0
+ drivers/{ => tty}/serial/timbuart.h               |    0
+ drivers/{ => tty}/serial/uartlite.c               |    0
+ drivers/{ => tty}/serial/ucc_uart.c               |    0
+ drivers/{ => tty}/serial/vr41xx_siu.c             |    0
+ drivers/{ => tty}/serial/vt8500_serial.c          |    0
+ drivers/{ => tty}/serial/zs.c                     |    0
+ drivers/{ => tty}/serial/zs.h                     |    0
+ 140 files changed, 42 insertions(+), 41 deletions(-)
+ create mode 100644 drivers/tty/hvc/Makefile
+ rename drivers/{char => tty/hvc}/hvc_beat.c (100%)
+ rename drivers/{char => tty/hvc}/hvc_console.c (100%)
+ rename drivers/{char => tty/hvc}/hvc_console.h (100%)
+ rename drivers/{char => tty/hvc}/hvc_dcc.c (100%)
+ rename drivers/{char => tty/hvc}/hvc_irq.c (100%)
+ rename drivers/{char => tty/hvc}/hvc_iseries.c (100%)
+ rename drivers/{char => tty/hvc}/hvc_iucv.c (100%)
+ rename drivers/{char => tty/hvc}/hvc_rtas.c (100%)
+ rename drivers/{char => tty/hvc}/hvc_tile.c (100%)
+ rename drivers/{char => tty/hvc}/hvc_udbg.c (100%)
+ rename drivers/{char => tty/hvc}/hvc_vio.c (100%)
+ rename drivers/{char => tty/hvc}/hvc_xen.c (100%)
+ rename drivers/{char => tty/hvc}/hvcs.c (100%)
+ rename drivers/{char => tty/hvc}/hvsi.c (100%)
+ rename drivers/{char => tty/hvc}/virtio_console.c (100%)
+ rename drivers/{ => tty}/serial/21285.c (100%)
+ rename drivers/{ => tty}/serial/68328serial.c (100%)
+ rename drivers/{ => tty}/serial/68328serial.h (100%)
+ rename drivers/{ => tty}/serial/68360serial.c (100%)
+ rename drivers/{ => tty}/serial/8250.c (100%)
+ rename drivers/{ => tty}/serial/8250.h (100%)
+ rename drivers/{ => tty}/serial/8250_accent.c (100%)
+ rename drivers/{ => tty}/serial/8250_acorn.c (100%)
+ rename drivers/{ => tty}/serial/8250_boca.c (100%)
+ rename drivers/{ => tty}/serial/8250_early.c (100%)
+ rename drivers/{ => tty}/serial/8250_exar_st16c554.c (100%)
+ rename drivers/{ => tty}/serial/8250_fourport.c (100%)
+ rename drivers/{ => tty}/serial/8250_gsc.c (100%)
+ rename drivers/{ => tty}/serial/8250_hp300.c (100%)
+ rename drivers/{ => tty}/serial/8250_hub6.c (100%)
+ rename drivers/{ => tty}/serial/8250_mca.c (100%)
+ rename drivers/{ => tty}/serial/8250_pci.c (100%)
+ rename drivers/{ => tty}/serial/8250_pnp.c (100%)
+ rename drivers/{ => tty}/serial/Kconfig (100%)
+ rename drivers/{ => tty}/serial/Makefile (100%)
+ rename drivers/{ => tty}/serial/altera_jtaguart.c (100%)
+ rename drivers/{ => tty}/serial/altera_uart.c (100%)
+ rename drivers/{ => tty}/serial/amba-pl010.c (100%)
+ rename drivers/{ => tty}/serial/amba-pl011.c (100%)
+ rename drivers/{ => tty}/serial/apbuart.c (100%)
+ rename drivers/{ => tty}/serial/apbuart.h (100%)
+ rename drivers/{ => tty}/serial/atmel_serial.c (100%)
+ rename drivers/{ => tty}/serial/bcm63xx_uart.c (100%)
+ rename drivers/{ => tty}/serial/bfin_5xx.c (100%)
+ rename drivers/{ => tty}/serial/bfin_sport_uart.c (100%)
+ rename drivers/{ => tty}/serial/bfin_sport_uart.h (100%)
+ rename drivers/{ => tty}/serial/clps711x.c (100%)
+ rename drivers/{ => tty}/serial/cpm_uart/Makefile (100%)
+ rename drivers/{ => tty}/serial/cpm_uart/cpm_uart.h (100%)
+ rename drivers/{ => tty}/serial/cpm_uart/cpm_uart_core.c (100%)
+ rename drivers/{ => tty}/serial/cpm_uart/cpm_uart_cpm1.c (100%)
+ rename drivers/{ => tty}/serial/cpm_uart/cpm_uart_cpm1.h (100%)
+ rename drivers/{ => tty}/serial/cpm_uart/cpm_uart_cpm2.c (100%)
+ rename drivers/{ => tty}/serial/cpm_uart/cpm_uart_cpm2.h (100%)
+ rename drivers/{ => tty}/serial/crisv10.c (100%)
+ rename drivers/{ => tty}/serial/crisv10.h (100%)
+ rename drivers/{ => tty}/serial/dz.c (100%)
+ rename drivers/{ => tty}/serial/dz.h (100%)
+ rename drivers/{ => tty}/serial/icom.c (100%)
+ rename drivers/{ => tty}/serial/icom.h (100%)
+ rename drivers/{ => tty}/serial/ifx6x60.c (100%)
+ rename drivers/{ => tty}/serial/ifx6x60.h (100%)
+ rename drivers/{ => tty}/serial/imx.c (100%)
+ rename drivers/{ => tty}/serial/ioc3_serial.c (100%)
+ rename drivers/{ => tty}/serial/ioc4_serial.c (100%)
+ rename drivers/{ => tty}/serial/ip22zilog.c (100%)
+ rename drivers/{ => tty}/serial/ip22zilog.h (100%)
+ rename drivers/{ => tty}/serial/jsm/Makefile (100%)
+ rename drivers/{ => tty}/serial/jsm/jsm.h (100%)
+ rename drivers/{ => tty}/serial/jsm/jsm_driver.c (100%)
+ rename drivers/{ => tty}/serial/jsm/jsm_neo.c (100%)
+ rename drivers/{ => tty}/serial/jsm/jsm_tty.c (100%)
+ rename drivers/{ => tty}/serial/kgdboc.c (100%)
+ rename drivers/{ => tty}/serial/m32r_sio.c (100%)
+ rename drivers/{ => tty}/serial/m32r_sio.h (100%)
+ rename drivers/{ => tty}/serial/m32r_sio_reg.h (100%)
+ rename drivers/{ => tty}/serial/max3100.c (100%)
+ rename drivers/{ => tty}/serial/max3107-aava.c (100%)
+ rename drivers/{ => tty}/serial/max3107.c (100%)
+ rename drivers/{ => tty}/serial/max3107.h (100%)
+ rename drivers/{ => tty}/serial/mcf.c (100%)
+ rename drivers/{ => tty}/serial/mfd.c (100%)
+ rename drivers/{ => tty}/serial/mpc52xx_uart.c (100%)
+ rename drivers/{ => tty}/serial/mpsc.c (100%)
+ rename drivers/{ => tty}/serial/mrst_max3110.c (100%)
+ rename drivers/{ => tty}/serial/mrst_max3110.h (100%)
+ rename drivers/{ => tty}/serial/msm_serial.c (100%)
+ rename drivers/{ => tty}/serial/msm_serial.h (100%)
+ rename drivers/{ => tty}/serial/mux.c (100%)
+ rename drivers/{ => tty}/serial/netx-serial.c (100%)
+ rename drivers/{ => tty}/serial/nwpserial.c (100%)
+ rename drivers/{ => tty}/serial/of_serial.c (100%)
+ rename drivers/{ => tty}/serial/omap-serial.c (100%)
+ rename drivers/{ => tty}/serial/pch_uart.c (100%)
+ rename drivers/{ => tty}/serial/pmac_zilog.c (100%)
+ rename drivers/{ => tty}/serial/pmac_zilog.h (100%)
+ rename drivers/{ => tty}/serial/pnx8xxx_uart.c (100%)
+ rename drivers/{ => tty}/serial/pxa.c (100%)
+ rename drivers/{ => tty}/serial/s3c2400.c (100%)
+ rename drivers/{ => tty}/serial/s3c2410.c (100%)
+ rename drivers/{ => tty}/serial/s3c2412.c (100%)
+ rename drivers/{ => tty}/serial/s3c2440.c (100%)
+ rename drivers/{ => tty}/serial/s3c24a0.c (100%)
+ rename drivers/{ => tty}/serial/s3c6400.c (100%)
+ rename drivers/{ => tty}/serial/s5pv210.c (100%)
+ rename drivers/{ => tty}/serial/sa1100.c (100%)
+ rename drivers/{ => tty}/serial/samsung.c (100%)
+ rename drivers/{ => tty}/serial/samsung.h (100%)
+ rename drivers/{ => tty}/serial/sb1250-duart.c (100%)
+ rename drivers/{ => tty}/serial/sc26xx.c (100%)
+ rename drivers/{ => tty}/serial/serial_core.c (100%)
+ rename drivers/{ => tty}/serial/serial_cs.c (100%)
+ rename drivers/{ => tty}/serial/serial_ks8695.c (100%)
+ rename drivers/{ => tty}/serial/serial_lh7a40x.c (100%)
+ rename drivers/{ => tty}/serial/serial_txx9.c (100%)
+ rename drivers/{ => tty}/serial/sh-sci.c (100%)
+ rename drivers/{ => tty}/serial/sh-sci.h (100%)
+ rename drivers/{ => tty}/serial/sn_console.c (100%)
+ rename drivers/{ => tty}/serial/suncore.c (100%)
+ rename drivers/{ => tty}/serial/suncore.h (100%)
+ rename drivers/{ => tty}/serial/sunhv.c (100%)
+ rename drivers/{ => tty}/serial/sunsab.c (100%)
+ rename drivers/{ => tty}/serial/sunsab.h (100%)
+ rename drivers/{ => tty}/serial/sunsu.c (100%)
+ rename drivers/{ => tty}/serial/sunzilog.c (100%)
+ rename drivers/{ => tty}/serial/sunzilog.h (100%)
+ rename drivers/{ => tty}/serial/timbuart.c (100%)
+ rename drivers/{ => tty}/serial/timbuart.h (100%)
+ rename drivers/{ => tty}/serial/uartlite.c (100%)
+ rename drivers/{ => tty}/serial/ucc_uart.c (100%)
+ rename drivers/{ => tty}/serial/vr41xx_siu.c (100%)
+ rename drivers/{ => tty}/serial/vt8500_serial.c (100%)
+ rename drivers/{ => tty}/serial/zs.c (100%)
+ rename drivers/{ => tty}/serial/zs.h (100%)
+Merging usb.current/usb-linus
+$ git merge usb.current/usb-linus
+Already up-to-date.
+Merging staging.current/staging-linus
+$ git merge staging.current/staging-linus
+Removing drivers/staging/vme/bridges/Module.symvers
+Merge made by recursive.
+ .../staging/ath6kl/miscdrv/ar3kps/ar3kpsconfig.c   |    4 +-
+ drivers/staging/comedi/drivers/ni_labpc.c          |    3 +-
+ drivers/staging/hv/blkvsc_drv.c                    |    1 +
+ drivers/staging/hv/netvsc.c                        |    2 +-
+ drivers/staging/hv/netvsc_drv.c                    |    1 -
+ drivers/staging/iio/adc/ad7476_core.c              |    2 +-
+ drivers/staging/iio/adc/ad799x_core.c              |    2 +-
+ drivers/staging/rt2860/rt_main_dev.c               |    2 -
+ drivers/staging/rt2860/usb_main_dev.c              |    1 +
+ drivers/staging/rtl8712/hal_init.c                 |   11 ++++++---
+ drivers/staging/speakup/kobjects.c                 |    2 +-
+ drivers/staging/ste_rmi4/synaptics_i2c_rmi4.c      |   19 ++++++++---------
+ drivers/staging/tidspbridge/core/io_sm.c           |    8 +++---
+ drivers/staging/tidspbridge/core/tiomap3430.c      |   15 ++++++-------
+ .../staging/tidspbridge/include/dspbridge/io_sm.h  |   21 +++++++------------
+ drivers/staging/xgifb/vb_setmode.c                 |    6 ++--
+ 16 files changed, 48 insertions(+), 52 deletions(-)
+ delete mode 100644 drivers/staging/vme/bridges/Module.symvers
+Merging cpufreq-current/fixes
+$ git merge cpufreq-current/fixes
+Auto-merging arch/x86/kernel/cpu/cpufreq/powernow-k8.c
+Merge made by recursive.
+ arch/x86/kernel/cpu/cpufreq/powernow-k8.c |   13 ++++++++++---
+ 1 files changed, 10 insertions(+), 3 deletions(-)
+Merging input-current/for-linus
+$ git merge input-current/for-linus
+Merge made by recursive.
+ drivers/input/keyboard/tnetv107x-keypad.c |    5 ++-
+ drivers/input/serio/ct82c710.c            |    8 +++--
+ drivers/input/touchscreen/bu21013_ts.c    |   39 ++++++++++++++++++++++++++--
+ drivers/input/touchscreen/tnetv107x-ts.c  |    5 ++-
+ include/linux/input/bu21013.h             |    4 ---
+ 5 files changed, 47 insertions(+), 14 deletions(-)
+Merging md-current/for-linus
+$ git merge md-current/for-linus
+Already up-to-date.
+Merging audit-current/for-linus
+$ git merge audit-current/for-linus
+Already up-to-date.
+Merging crypto-current/master
+$ git merge crypto-current/master
+Already up-to-date.
+Merging ide-curent/master
+$ git merge ide-curent/master
+Already up-to-date.
+Merging dwmw2/master
+$ git merge dwmw2/master
+Already up-to-date.
+Merging sh-current/sh-fixes-for-linus
+$ git merge sh-current/sh-fixes-for-linus
+Already up-to-date.
+Merging rmobile-current/rmobile-fixes-for-linus
+$ git merge rmobile-current/rmobile-fixes-for-linus
+Already up-to-date.
+Merging fbdev-current/fbdev-fixes-for-linus
+$ git merge fbdev-current/fbdev-fixes-for-linus
+Already up-to-date.
+Merging devicetree-current/devicetree/merge
+$ git merge devicetree-current/devicetree/merge
+Merge made by recursive.
+ arch/powerpc/platforms/83xx/mpc830x_rdb.c |    4 ++--
+ arch/powerpc/platforms/83xx/mpc831x_rdb.c |    4 ++--
+ 2 files changed, 4 insertions(+), 4 deletions(-)
+Merging spi-current/spi/merge
+$ git merge spi-current/spi/merge
+Already up-to-date.
+Merging arm/devel
+$ git merge arm/devel
+Removing arch/arm/mach-realview/headsmp.S
+Removing arch/arm/mach-realview/localtimer.c
+Merge made by recursive.
+ Documentation/arm/SH-Mobile/Makefile               |    8 +
+ Documentation/arm/SH-Mobile/vrl4.c                 |  169 +++++++++++
+ Documentation/arm/SH-Mobile/zboot-rom-mmcif.txt    |   29 ++
+ arch/arm/Kconfig                                   |   60 ++++-
+ arch/arm/Makefile                                  |    5 +-
+ arch/arm/boot/Makefile                             |    4 +
+ arch/arm/boot/compressed/Makefile                  |   17 +-
+ arch/arm/boot/compressed/head-shmobile.S           |   30 ++
+ arch/arm/boot/compressed/head-vt8500.S             |   46 +++
+ arch/arm/boot/compressed/head.S                    |    2 +-
+ arch/arm/boot/compressed/misc.c                    |    2 +-
+ arch/arm/boot/compressed/mmcif-sh7372.c            |   87 ++++++
+ arch/arm/include/asm/bitops.h                      |   60 ++---
+ arch/arm/include/asm/cacheflush.h                  |    5 +-
+ arch/arm/include/asm/cputype.h                     |    3 +-
+ arch/arm/include/asm/memory.h                      |   66 ++++-
+ arch/arm/include/asm/module.h                      |   19 ++-
+ arch/arm/include/asm/pgalloc.h                     |    2 +-
+ arch/arm/include/asm/pgtable.h                     |   24 +-
+ arch/arm/include/asm/proc-fns.h                    |    2 +-
+ arch/arm/include/asm/spinlock.h                    |   37 ++-
+ arch/arm/include/asm/system.h                      |   17 +-
+ arch/arm/include/asm/tlb.h                         |    1 +
+ arch/arm/include/asm/tls.h                         |   11 +-
+ arch/arm/kernel/armksyms.c                         |   22 +-
+ arch/arm/kernel/bios32.c                           |    5 +
+ arch/arm/kernel/debug.S                            |    2 +-
+ arch/arm/kernel/entry-header.S                     |   14 +-
+ arch/arm/kernel/head-common.S                      |   90 ------
+ arch/arm/kernel/head-nommu.S                       |    3 -
+ arch/arm/kernel/head.S                             |  131 +++++++--
+ arch/arm/kernel/module.c                           |   50 +++-
+ arch/arm/kernel/perf_event_v6.c                    |    4 +-
+ arch/arm/kernel/return_address.c                   |    1 +
+ arch/arm/kernel/setup.c                            |   43 +++-
+ arch/arm/kernel/tcm.c                              |    2 +-
+ arch/arm/kernel/traps.c                            |    2 +-
+ arch/arm/kernel/vmlinux.lds.S                      |    4 +
+ arch/arm/lib/bitops.h                              |   46 ++--
+ arch/arm/lib/changebit.S                           |   10 +-
+ arch/arm/lib/clearbit.S                            |   11 +-
+ arch/arm/lib/setbit.S                              |   11 +-
+ arch/arm/lib/testchangebit.S                       |    9 +-
+ arch/arm/lib/testclearbit.S                        |    9 +-
+ arch/arm/lib/testsetbit.S                          |    9 +-
+ arch/arm/lib/uaccess_with_memcpy.c                 |    7 +-
+ arch/arm/mach-aaec2000/include/mach/memory.h       |    2 +-
+ arch/arm/mach-at91/include/mach/memory.h           |    2 +-
+ arch/arm/mach-bcmring/include/mach/hardware.h      |    2 +-
+ arch/arm/mach-bcmring/include/mach/memory.h        |    2 +-
+ arch/arm/mach-clps711x/include/mach/memory.h       |    2 +-
+ arch/arm/mach-cns3xxx/include/mach/memory.h        |    2 +-
+ arch/arm/mach-davinci/include/mach/memory.h        |    4 +-
+ arch/arm/mach-dove/Kconfig                         |    2 +-
+ arch/arm/mach-dove/include/mach/memory.h           |    2 +-
+ arch/arm/mach-ebsa110/include/mach/memory.h        |    2 +-
+ arch/arm/mach-ep93xx/include/mach/memory.h         |   10 +-
+ arch/arm/mach-footbridge/include/mach/memory.h     |    2 +-
+ arch/arm/mach-gemini/include/mach/memory.h         |    4 +-
+ arch/arm/mach-h720x/include/mach/memory.h          |    2 +-
+ arch/arm/mach-integrator/Kconfig                   |    1 +
+ arch/arm/mach-integrator/common.h                  |    1 +
+ arch/arm/mach-integrator/core.c                    |    7 +-
+ arch/arm/mach-integrator/include/mach/cm.h         |    4 +-
+ arch/arm/mach-integrator/include/mach/memory.h     |    2 +-
+ arch/arm/mach-integrator/integrator_ap.c           |   44 +--
+ arch/arm/mach-integrator/integrator_cp.c           |  231 ++++------------
+ arch/arm/mach-iop13xx/include/mach/memory.h        |    2 +-
+ arch/arm/mach-iop32x/include/mach/memory.h         |    2 +-
+ arch/arm/mach-iop33x/include/mach/memory.h         |    2 +-
+ arch/arm/mach-ixp2000/include/mach/memory.h        |    2 +-
+ arch/arm/mach-ixp23xx/include/mach/memory.h        |    2 +-
+ arch/arm/mach-ixp4xx/include/mach/memory.h         |    2 +-
+ arch/arm/mach-kirkwood/include/mach/memory.h       |    2 +-
+ arch/arm/mach-ks8695/include/mach/memory.h         |    2 +-
+ arch/arm/mach-lh7a40x/include/mach/memory.h        |    2 +-
+ arch/arm/mach-loki/include/mach/memory.h           |    2 +-
+ arch/arm/mach-lpc32xx/include/mach/memory.h        |    2 +-
+ arch/arm/mach-mmp/include/mach/memory.h            |    2 +-
+ arch/arm/mach-msm/board-msm7x27.c                  |    8 +-
+ arch/arm/mach-msm/board-msm7x30.c                  |    8 +-
+ arch/arm/mach-msm/board-qsd8x50.c                  |    4 +-
+ arch/arm/mach-msm/board-sapphire.c                 |    2 +-
+ arch/arm/mach-msm/include/mach/memory.h            |   10 +-
+ arch/arm/mach-mv78xx0/include/mach/memory.h        |    2 +-
+ arch/arm/mach-mx3/mach-kzm_arm11_01.c              |    2 +-
+ arch/arm/mach-netx/include/mach/memory.h           |    2 +-
+ arch/arm/mach-nomadik/include/mach/memory.h        |    2 +-
+ arch/arm/mach-ns9xxx/include/mach/memory.h         |    2 +-
+ arch/arm/mach-nuc93x/include/mach/memory.h         |    2 +-
+ arch/arm/mach-orion5x/include/mach/memory.h        |    2 +-
+ arch/arm/mach-pnx4008/include/mach/memory.h        |    2 +-
+ arch/arm/mach-pxa/balloon3.c                       |    2 +-
+ arch/arm/mach-pxa/include/mach/memory.h            |    2 +-
+ arch/arm/mach-realview/Kconfig                     |    5 +-
+ arch/arm/mach-realview/Makefile                    |    3 +-
+ arch/arm/mach-realview/core.c                      |  232 +++-------------
+ arch/arm/mach-realview/core.h                      |    2 +-
+ arch/arm/mach-realview/headsmp.S                   |   40 ---
+ arch/arm/mach-realview/include/mach/memory.h       |    4 +-
+ arch/arm/mach-realview/localtimer.c                |   26 --
+ arch/arm/mach-realview/platsmp.c                   |   98 +-------
+ arch/arm/mach-realview/realview_eb.c               |   24 +--
+ arch/arm/mach-realview/realview_pb1176.c           |   24 +--
+ arch/arm/mach-realview/realview_pb11mp.c           |   24 +--
+ arch/arm/mach-realview/realview_pba8.c             |   24 +--
+ arch/arm/mach-realview/realview_pbx.c              |   24 +--
+ arch/arm/mach-rpc/include/mach/memory.h            |    2 +-
+ arch/arm/mach-s3c2400/include/mach/memory.h        |    2 +-
+ arch/arm/mach-s3c2410/include/mach/memory.h        |    2 +-
+ arch/arm/mach-s3c24a0/include/mach/memory.h        |    2 +-
+ arch/arm/mach-s3c64xx/include/mach/memory.h        |    2 +-
+ arch/arm/mach-s5p6442/include/mach/memory.h        |    2 +-
+ arch/arm/mach-s5p64x0/include/mach/memory.h        |    2 +-
+ arch/arm/mach-s5pc100/include/mach/memory.h        |    2 +-
+ arch/arm/mach-s5pv210/include/mach/memory.h        |    2 +-
+ arch/arm/mach-s5pv210/sleep.S                      |    2 +-
+ arch/arm/mach-s5pv310/include/mach/memory.h        |    2 +-
+ arch/arm/mach-sa1100/include/mach/memory.h         |    2 +-
+ arch/arm/mach-shark/include/mach/memory.h          |    2 +-
+ arch/arm/mach-shmobile/include/mach/memory.h       |    2 +-
+ arch/arm/mach-shmobile/include/mach/mmcif-ap4eb.h  |   29 ++
+ .../mach-shmobile/include/mach/mmcif-mackerel.h    |   39 +++
+ arch/arm/mach-shmobile/include/mach/mmcif.h        |   18 ++
+ arch/arm/mach-tcc8k/board-tcc8000-sdk.c            |    2 +-
+ arch/arm/mach-tegra/include/mach/memory.h          |    2 +-
+ arch/arm/mach-u300/include/mach/memory.h           |    6 +-
+ arch/arm/mach-u300/u300.c                          |    2 +-
+ arch/arm/mach-ux500/include/mach/memory.h          |    2 +-
+ arch/arm/mach-versatile/core.c                     |  294 +++++---------------
+ arch/arm/mach-versatile/core.h                     |    2 +-
+ arch/arm/mach-versatile/include/mach/hardware.h    |    2 +-
+ arch/arm/mach-versatile/include/mach/memory.h      |    2 +-
+ arch/arm/mach-versatile/versatile_ab.c             |    1 +
+ arch/arm/mach-versatile/versatile_pb.c             |    6 +-
+ arch/arm/mach-vexpress/Makefile                    |    3 +-
+ arch/arm/mach-vexpress/core.h                      |    1 +
+ arch/arm/mach-vexpress/ct-ca9x4.c                  |   69 ++----
+ arch/arm/mach-vexpress/include/mach/memory.h       |    2 +-
+ arch/arm/mach-vexpress/platsmp.c                   |   94 +------
+ arch/arm/mach-vexpress/v2m.c                       |    6 +-
+ arch/arm/mach-vt8500/Kconfig                       |   73 +++++
+ arch/arm/mach-vt8500/Makefile                      |    9 +
+ arch/arm/mach-vt8500/Makefile.boot                 |    3 +
+ arch/arm/mach-vt8500/bv07.c                        |   77 +++++
+ arch/arm/mach-vt8500/devices-vt8500.c              |   91 ++++++
+ arch/arm/mach-vt8500/devices-wm8505.c              |   99 +++++++
+ arch/arm/mach-vt8500/devices.c                     |  270 ++++++++++++++++++
+ arch/arm/mach-vt8500/devices.h                     |   88 ++++++
+ arch/arm/mach-vt8500/gpio.c                        |  240 ++++++++++++++++
+ arch/arm/mach-vt8500/include/mach/debug-macro.S    |   31 ++
+ arch/arm/mach-vt8500/include/mach/entry-macro.S    |   32 +++
+ arch/arm/mach-vt8500/include/mach/gpio.h           |    6 +
+ arch/arm/mach-vt8500/include/mach/hardware.h       |   12 +
+ arch/arm/mach-vt8500/include/mach/i8042.h          |   18 ++
+ arch/arm/mach-vt8500/include/mach/io.h             |   28 ++
+ arch/arm/mach-vt8500/include/mach/irqs.h           |   22 ++
+ arch/arm/mach-vt8500/include/mach/memory.h         |   28 ++
+ arch/arm/mach-vt8500/include/mach/system.h         |   18 ++
+ arch/arm/mach-vt8500/include/mach/timex.h          |   26 ++
+ arch/arm/mach-vt8500/include/mach/uncompress.h     |   37 +++
+ arch/arm/mach-vt8500/include/mach/vmalloc.h        |   20 ++
+ arch/arm/mach-vt8500/include/mach/vt8500_irqs.h    |   88 ++++++
+ arch/arm/mach-vt8500/include/mach/vt8500_regs.h    |   79 ++++++
+ arch/arm/mach-vt8500/include/mach/vt8500fb.h       |   31 ++
+ arch/arm/mach-vt8500/include/mach/wm8505_irqs.h    |  115 ++++++++
+ arch/arm/mach-vt8500/include/mach/wm8505_regs.h    |   78 +++++
+ arch/arm/mach-vt8500/irq.c                         |  177 ++++++++++++
+ arch/arm/mach-vt8500/pwm.c                         |  265 ++++++++++++++++++
+ arch/arm/mach-vt8500/timer.c                       |  155 ++++++++++
+ arch/arm/mach-vt8500/wm8505_7in.c                  |   77 +++++
+ arch/arm/mach-w90x900/include/mach/memory.h        |    2 +-
+ arch/arm/mm/Kconfig                                |   52 ++--
+ arch/arm/mm/Makefile                               |    1 +
+ arch/arm/mm/abort-ev6.S                            |    6 +-
+ arch/arm/mm/dma-mapping.c                          |   11 +-
+ arch/arm/mm/fault-armv.c                           |    7 +-
+ arch/arm/mm/fault.c                                |   29 ++-
+ arch/arm/mm/idmap.c                                |   35 ++-
+ arch/arm/mm/mm.h                                   |    2 +-
+ arch/arm/mm/mmap.c                                 |    2 +-
+ arch/arm/mm/mmu.c                                  |   22 ++-
+ arch/arm/mm/pgd.c                                  |   24 ++-
+ arch/arm/mm/vmregion.c                             |   17 +-
+ arch/arm/plat-mxc/include/mach/memory.h            |   18 +-
+ arch/arm/plat-omap/include/plat/memory.h           |    4 +-
+ arch/arm/plat-omap/include/plat/serial.h           |    2 +-
+ arch/arm/plat-spear/include/plat/memory.h          |    2 +-
+ arch/arm/plat-stmp3xxx/include/mach/memory.h       |    2 +-
+ arch/arm/plat-tcc/include/mach/memory.h            |    2 +-
+ arch/arm/plat-versatile/Kconfig                    |   16 +
+ arch/arm/plat-versatile/Makefile                   |   13 +-
+ arch/arm/plat-versatile/clcd.c                     |  175 ++++++++++++
+ arch/arm/plat-versatile/fpga-irq.c                 |   72 +++++
+ .../{mach-vexpress => plat-versatile}/headsmp.S    |    8 +-
+ arch/arm/plat-versatile/include/plat/clcd.h        |    9 +
+ arch/arm/plat-versatile/include/plat/fpga-irq.h    |   12 +
+ .../{mach-vexpress => plat-versatile}/localtimer.c |    2 +-
+ arch/arm/plat-versatile/platsmp.c                  |  104 +++++++
+ arch/arm/vfp/vfpmodule.c                           |    2 +-
+ drivers/video/amba-clcd.c                          |   20 +-
+ include/linux/amba/clcd.h                          |   10 +-
+ 202 files changed, 4147 insertions(+), 1566 deletions(-)
+ create mode 100644 Documentation/arm/SH-Mobile/Makefile
+ create mode 100644 Documentation/arm/SH-Mobile/vrl4.c
+ create mode 100644 Documentation/arm/SH-Mobile/zboot-rom-mmcif.txt
+ create mode 100644 arch/arm/boot/compressed/head-vt8500.S
+ create mode 100644 arch/arm/boot/compressed/mmcif-sh7372.c
+ delete mode 100644 arch/arm/mach-realview/headsmp.S
+ delete mode 100644 arch/arm/mach-realview/localtimer.c
+ create mode 100644 arch/arm/mach-shmobile/include/mach/mmcif-ap4eb.h
+ create mode 100644 arch/arm/mach-shmobile/include/mach/mmcif-mackerel.h
+ create mode 100644 arch/arm/mach-shmobile/include/mach/mmcif.h
+ create mode 100644 arch/arm/mach-vt8500/Kconfig
+ create mode 100644 arch/arm/mach-vt8500/Makefile
+ create mode 100644 arch/arm/mach-vt8500/Makefile.boot
+ create mode 100644 arch/arm/mach-vt8500/bv07.c
+ create mode 100644 arch/arm/mach-vt8500/devices-vt8500.c
+ create mode 100644 arch/arm/mach-vt8500/devices-wm8505.c
+ create mode 100644 arch/arm/mach-vt8500/devices.c
+ create mode 100644 arch/arm/mach-vt8500/devices.h
+ create mode 100644 arch/arm/mach-vt8500/gpio.c
+ create mode 100644 arch/arm/mach-vt8500/include/mach/debug-macro.S
+ create mode 100644 arch/arm/mach-vt8500/include/mach/entry-macro.S
+ create mode 100644 arch/arm/mach-vt8500/include/mach/gpio.h
+ create mode 100644 arch/arm/mach-vt8500/include/mach/hardware.h
+ create mode 100644 arch/arm/mach-vt8500/include/mach/i8042.h
+ create mode 100644 arch/arm/mach-vt8500/include/mach/io.h
+ create mode 100644 arch/arm/mach-vt8500/include/mach/irqs.h
+ create mode 100644 arch/arm/mach-vt8500/include/mach/memory.h
+ create mode 100644 arch/arm/mach-vt8500/include/mach/system.h
+ create mode 100644 arch/arm/mach-vt8500/include/mach/timex.h
+ create mode 100644 arch/arm/mach-vt8500/include/mach/uncompress.h
+ create mode 100644 arch/arm/mach-vt8500/include/mach/vmalloc.h
+ create mode 100644 arch/arm/mach-vt8500/include/mach/vt8500_irqs.h
+ create mode 100644 arch/arm/mach-vt8500/include/mach/vt8500_regs.h
+ create mode 100644 arch/arm/mach-vt8500/include/mach/vt8500fb.h
+ create mode 100644 arch/arm/mach-vt8500/include/mach/wm8505_irqs.h
+ create mode 100644 arch/arm/mach-vt8500/include/mach/wm8505_regs.h
+ create mode 100644 arch/arm/mach-vt8500/irq.c
+ create mode 100644 arch/arm/mach-vt8500/pwm.c
+ create mode 100644 arch/arm/mach-vt8500/timer.c
+ create mode 100644 arch/arm/mach-vt8500/wm8505_7in.c
+ create mode 100644 arch/arm/plat-versatile/Kconfig
+ create mode 100644 arch/arm/plat-versatile/clcd.c
+ create mode 100644 arch/arm/plat-versatile/fpga-irq.c
+ rename arch/arm/{mach-vexpress => plat-versatile}/headsmp.S (75%)
+ create mode 100644 arch/arm/plat-versatile/include/plat/clcd.h
+ create mode 100644 arch/arm/plat-versatile/include/plat/fpga-irq.h
+ rename arch/arm/{mach-vexpress => plat-versatile}/localtimer.c (92%)
+ create mode 100644 arch/arm/plat-versatile/platsmp.c
+Merging davinci/davinci-next
+$ git merge davinci/davinci-next
+Already up-to-date.
+Merging i.MX/for-next
+$ git merge i.MX/for-next
+Already up-to-date!
+Merge made by recursive.
+Merging linux-spec/for-next
+$ git merge linux-spec/for-next
+Already up-to-date.
+Merging msm/for-next
+$ git merge msm/for-next
+Already up-to-date.
+Merging omap/for-next
+$ git merge omap/for-next
+Merge made by recursive.
+ arch/arm/mach-omap1/Kconfig                      |    2 +
+ arch/arm/mach-omap1/Makefile                     |    5 +-
+ arch/arm/mach-omap1/board-ams-delta.c            |   14 ++--
+ arch/arm/mach-omap1/board-fsample.c              |    2 +-
+ arch/arm/mach-omap1/board-h2.c                   |    2 +-
+ arch/arm/mach-omap1/board-h3.c                   |    2 +-
+ arch/arm/mach-omap1/board-htcherald.c            |    4 +-
+ arch/arm/mach-omap1/board-innovator.c            |    2 +-
+ arch/arm/mach-omap1/board-palmte.c               |   13 ---
+ arch/arm/mach-omap1/board-voiceblue.c            |  107 ++++++++++++----------
+ arch/arm/mach-omap1/reset.c                      |   25 +++++
+ arch/arm/mach-omap1/time.c                       |  101 +++++++++++++++++++--
+ arch/arm/mach-omap1/timer32k.c                   |   13 +--
+ arch/arm/mach-omap2/Kconfig                      |   16 ++--
+ arch/arm/mach-omap2/Makefile                     |   20 ++--
+ arch/arm/mach-omap2/clock2xxx.h                  |    4 +-
+ arch/arm/mach-omap2/clock44xx_data.c             |    1 -
+ arch/arm/mach-omap2/clockdomain.c                |   30 +++++-
+ arch/arm/mach-omap2/clockdomains2xxx_3xxx_data.c |   16 ++--
+ arch/arm/mach-omap2/clockdomains44xx_data.c      |    2 -
+ arch/arm/mach-omap2/common.c                     |    4 +-
+ arch/arm/mach-omap2/devices.c                    |    6 +-
+ arch/arm/mach-omap2/io.c                         |    8 +-
+ arch/arm/mach-omap2/irq.c                        |    4 +-
+ arch/arm/mach-omap2/mailbox.c                    |    2 +-
+ arch/arm/mach-omap2/mcbsp.c                      |    4 +-
+ arch/arm/mach-omap2/mux.c                        |    2 +-
+ arch/arm/mach-omap2/opp2xxx.h                    |    2 +-
+ arch/arm/mach-omap2/powerdomain2xxx_3xxx.c       |    1 -
+ arch/arm/mach-omap2/powerdomains2xxx_data.c      |    6 +-
+ arch/arm/mach-omap2/prcm.c                       |    5 +-
+ arch/arm/mach-omap2/timer-gp.c                   |   10 ++-
+ arch/arm/plat-omap/Kconfig                       |    8 +-
+ arch/arm/plat-omap/counter_32k.c                 |   26 +++--
+ arch/arm/plat-omap/dma.c                         |    2 +-
+ arch/arm/plat-omap/i2c.c                         |    2 +-
+ arch/arm/plat-omap/include/plat/common.h         |    3 +
+ arch/arm/plat-omap/include/plat/cpu.h            |   10 +-
+ arch/arm/plat-omap/include/plat/fpga.h           |   92 +++++++++---------
+ arch/arm/plat-omap/include/plat/io.h             |    4 +-
+ arch/arm/plat-omap/include/plat/multi.h          |    4 +-
+ arch/arm/plat-omap/include/plat/prcm.h           |    1 -
+ arch/arm/plat-omap/include/plat/system.h         |   38 +-------
+ arch/arm/plat-omap/sram.c                        |    4 +-
+ drivers/mmc/host/Kconfig                         |    2 +-
+ drivers/spi/omap2_mcspi.c                        |    4 +-
+ drivers/usb/musb/musb_core.c                     |    2 +-
+ drivers/usb/musb/musb_core.h                     |    6 +-
+ drivers/usb/musb/musbhsdma.h                     |    2 +-
+ drivers/w1/masters/Kconfig                       |    2 +-
+ sound/soc/omap/omap-mcbsp.c                      |    6 +-
+ sound/soc/omap/omap-mcbsp.h                      |    4 +-
+ 52 files changed, 383 insertions(+), 274 deletions(-)
+ create mode 100644 arch/arm/mach-omap1/reset.c
+Merging pxa/for-next
+$ git merge pxa/for-next
+Already up-to-date.
+Merging samsung/next-samsung
+$ git merge samsung/next-samsung
+Auto-merging arch/arm/mach-s3c2410/mach-h1940.c
+Auto-merging arch/arm/mach-s3c2440/mach-rx1950.c
+Merge made by recursive.
+ arch/arm/mach-s3c2410/h1940-bluetooth.c    |   11 +-
+ arch/arm/mach-s3c2410/include/mach/h1940.h |    3 +
+ arch/arm/mach-s3c2410/mach-h1940.c         |  302 ++++++++++++++++++++++++++--
+ arch/arm/mach-s3c2440/mach-rx1950.c        |   57 ++++++
+ 4 files changed, 356 insertions(+), 17 deletions(-)
+Merging s5p/for-next
+$ git merge s5p/for-next
+Already up-to-date.
+Merging tegra/for-next
+$ git merge tegra/for-next
+Resolved 'arch/arm/mach-tegra/timer.c' using previous resolution.
+Auto-merging arch/arm/mach-tegra/timer.c
+CONFLICT (content): Merge conflict in arch/arm/mach-tegra/timer.c
+Automatic merge failed; fix conflicts and then commit the result.
+$ git commit -v -a
+[master 5adba42] Merge remote branch 'tegra/for-next'
+$ git diff -M --stat --summary HEAD^..
+Merging ux500-core/ux500-core
+$ git merge ux500-core/ux500-core
+Already up-to-date.
+Merging avr32/avr32-arch
+$ git merge avr32/avr32-arch
+Already up-to-date.
+Merging blackfin/for-linus
+$ git merge blackfin/for-linus
+Already up-to-date.
+Merging cris/for-next
+$ git merge cris/for-next
+Merge made by recursive.
+ arch/cris/Kconfig                         |    1 -
+ arch/cris/arch-v10/drivers/axisflashmap.c |    6 ------
+ arch/cris/arch-v32/drivers/Kconfig        |    1 -
+ arch/cris/arch-v32/drivers/axisflashmap.c |    6 ------
+ 4 files changed, 0 insertions(+), 14 deletions(-)
+Merging ia64/test
+$ git merge ia64/test
+Auto-merging fs/Kconfig
+Auto-merging include/linux/magic.h
+Merge made by recursive.
+ Documentation/ABI/testing/pstore          |   35 ++++
+ Documentation/ABI/testing/sysfs-fs-pstore |    7 +
+ arch/ia64/include/asm/dma-mapping.h       |    2 +
+ drivers/acpi/apei/Kconfig                 |    1 +
+ drivers/acpi/apei/erst.c                  |  136 ++++++++++++++
+ fs/Kconfig                                |    1 +
+ fs/Makefile                               |    1 +
+ fs/pstore/Kconfig                         |   13 ++
+ fs/pstore/Makefile                        |    7 +
+ fs/pstore/inode.c                         |  285 +++++++++++++++++++++++++++++
+ fs/pstore/internal.h                      |    7 +
+ fs/pstore/platform.c                      |  202 ++++++++++++++++++++
+ include/linux/magic.h                     |    1 +
+ include/linux/pstore.h                    |   60 ++++++
+ 14 files changed, 758 insertions(+), 0 deletions(-)
+ create mode 100644 Documentation/ABI/testing/pstore
+ create mode 100644 Documentation/ABI/testing/sysfs-fs-pstore
+ create mode 100644 fs/pstore/Kconfig
+ create mode 100644 fs/pstore/Makefile
+ create mode 100644 fs/pstore/inode.c
+ create mode 100644 fs/pstore/internal.h
+ create mode 100644 fs/pstore/platform.c
+ create mode 100644 include/linux/pstore.h
+Merging m68k/for-next
+$ git merge m68k/for-next
+Already up-to-date.
+Merging m68knommu/for-next
+$ git merge m68knommu/for-next
+Already up-to-date.
+Merging microblaze/next
+$ git merge microblaze/next
+Already up-to-date.
+Merging mips/mips-for-linux-next
+$ git merge mips/mips-for-linux-next
+Auto-merging arch/mips/Kconfig
+Auto-merging arch/mips/kernel/module.c
+Auto-merging arch/mips/txx9/generic/pci.c
+Merge made by recursive.
+Merging parisc/for-next
+$ git merge parisc/for-next
+Merge made by recursive.
+ arch/parisc/include/asm/cacheflush.h |    7 +-
+ arch/parisc/include/asm/pgtable.h    |   14 +--
+ arch/parisc/kernel/cache.c           |  109 +++-------------
+ arch/parisc/kernel/entry.S           |  217 +++++++++++++++++-------------
+ arch/parisc/kernel/pacache.S         |  245 +++++++++++++++-------------------
+ 5 files changed, 260 insertions(+), 332 deletions(-)
+Merging powerpc/next
+$ git merge powerpc/next
+Already up-to-date.
+Merging 4xx/next
+$ git merge 4xx/next
+Already up-to-date.
+Merging 52xx-and-virtex/powerpc/next
+$ git merge 52xx-and-virtex/powerpc/next
+Already up-to-date.
+Merging galak/next
+$ git merge galak/next
+Auto-merging arch/powerpc/boot/dts/mpc8308rdb.dts
+Auto-merging arch/powerpc/sysdev/fsl_rio.c
+Merge made by recursive.
+ arch/powerpc/boot/dts/mpc8308rdb.dts      |    2 +-
+ arch/powerpc/boot/dts/p1022ds.dts         |    4 ++--
+ arch/powerpc/include/asm/immap_qe.h       |   21 +++++++++++++++------
+ arch/powerpc/include/asm/reg.h            |    2 ++
+ arch/powerpc/include/asm/reg_booke.h      |   14 ++++++++++++++
+ arch/powerpc/kernel/cpu_setup_fsl_booke.S |    6 ++++++
+ arch/powerpc/platforms/83xx/mpc83xx.h     |    2 ++
+ arch/powerpc/platforms/83xx/usb.c         |   21 ++++++++++++++++-----
+ arch/powerpc/sysdev/fsl_rio.c             |    2 --
+ 9 files changed, 58 insertions(+), 16 deletions(-)
+Merging s390/features
+$ git merge s390/features
+Merge made by recursive.
+ arch/s390/include/asm/tlb.h     |    1 +
+ arch/s390/lib/uaccess_std.c     |   10 ++++------
+ arch/s390/mm/pgtable.c          |    3 ++-
+ drivers/s390/block/dasd_alias.c |    6 ++++++
+ 4 files changed, 13 insertions(+), 7 deletions(-)
+Merging sh/sh-latest
+$ git merge sh/sh-latest
+Merge made by recursive.
+ arch/sh/Kconfig                      |    1 +
+ arch/sh/Makefile                     |    3 ++-
+ arch/sh/boards/mach-ecovec24/setup.c |    2 ++
+ arch/sh/boot/Makefile                |   11 +++++++++--
+ arch/sh/boot/compressed/Makefile     |    4 +++-
+ arch/sh/boot/compressed/misc.c       |    4 ++++
+ arch/sh/include/asm/pgtable.h        |    1 +
+ arch/sh/kernel/topology.c            |    1 +
+ drivers/sh/intc/chip.c               |    6 ++++--
+ 9 files changed, 27 insertions(+), 6 deletions(-)
+Merging rmobile/rmobile-latest
+$ git merge rmobile/rmobile-latest
+Merge made by recursive.
+ arch/arm/mach-shmobile/Kconfig          |    2 +
+ arch/arm/mach-shmobile/board-ag5evm.c   |  180 ++++++++++++++++++++++++++++++-
+ arch/arm/mach-shmobile/board-g3evm.c    |    1 -
+ arch/arm/mach-shmobile/board-mackerel.c |    5 +-
+ arch/arm/mach-shmobile/clock-sh7372.c   |    4 +-
+ arch/arm/mach-shmobile/clock-sh73a0.c   |   29 +++++-
+ arch/arm/mach-shmobile/intc-sh7372.c    |   11 ++-
+ arch/arm/mach-shmobile/intc-sh73a0.c    |    5 +-
+ include/linux/mmc/sh_mmcif.h            |    4 +-
+ 9 files changed, 222 insertions(+), 19 deletions(-)
+Merging sparc/master
+$ git merge sparc/master
+Already up-to-date.
+Merging tile/master
+$ git merge tile/master
+Already up-to-date.
+Merging xtensa/master
+$ git merge xtensa/master
+Resolved 'arch/xtensa/configs/iss_defconfig' using previous resolution.
+Auto-merging arch/xtensa/Kconfig
+Auto-merging arch/xtensa/Makefile
+Auto-merging arch/xtensa/configs/iss_defconfig
+CONFLICT (content): Merge conflict in arch/xtensa/configs/iss_defconfig
+Auto-merging arch/xtensa/include/asm/coprocessor.h
+Auto-merging arch/xtensa/kernel/Makefile
+Auto-merging arch/xtensa/kernel/time.c
+Automatic merge failed; fix conflicts and then commit the result.
+$ git commit -v -a
+[master 6afb33c] Merge remote branch 'xtensa/master'
+$ git diff -M --stat --summary HEAD^..
+ arch/xtensa/Kconfig                                |   17 +-
+ arch/xtensa/Makefile                               |    5 +-
+ arch/xtensa/boot/Makefile                          |    1 +
+ arch/xtensa/include/asm/coprocessor.h              |    9 +-
+ arch/xtensa/include/asm/io.h                       |   40 ++--
+ arch/xtensa/include/asm/irq.h                      |    7 +-
+ arch/xtensa/include/asm/serial.h                   |   12 +-
+ arch/xtensa/kernel/Makefile                        |    4 +-
+ arch/xtensa/kernel/time.c                          |    2 +-
+ arch/xtensa/platforms/xtavnet/Makefile             |   10 +
+ .../platforms/xtavnet/include/platform/hardware.h  |   85 ++++++
+ .../platforms/xtavnet/include/platform/lcd.h       |   22 ++
+ .../platforms/xtavnet/include/platform/serial.h    |    1 +
+ arch/xtensa/platforms/xtavnet/lcd.c                |   79 ++++++
+ arch/xtensa/platforms/xtavnet/setup.c              |  269 ++++++++++++++++++++
+ 15 files changed, 526 insertions(+), 37 deletions(-)
+ create mode 100644 arch/xtensa/platforms/xtavnet/Makefile
+ create mode 100644 arch/xtensa/platforms/xtavnet/include/platform/hardware.h
+ create mode 100644 arch/xtensa/platforms/xtavnet/include/platform/lcd.h
+ create mode 100644 arch/xtensa/platforms/xtavnet/include/platform/serial.h
+ create mode 100644 arch/xtensa/platforms/xtavnet/lcd.c
+ create mode 100644 arch/xtensa/platforms/xtavnet/setup.c
+Merging ceph/for-next
+$ git merge ceph/for-next
+Already up-to-date.
+Merging cifs/master
+$ git merge cifs/master
+Merge made by recursive.
+ fs/cifs/cifs_debug.c |   10 +-
+ fs/cifs/cifsacl.c    |   13 ++-
+ fs/cifs/cifsfs.c     |    6 +-
+ fs/cifs/cifsfs.h     |    2 +-
+ fs/cifs/cifsglob.h   |   28 +++-
+ fs/cifs/cifspdu.h    |   15 ++
+ fs/cifs/cifsproto.h  |    9 +-
+ fs/cifs/cifssmb.c    |   59 +++++++-
+ fs/cifs/connect.c    |  149 +++++++++---------
+ fs/cifs/file.c       |  114 +++++++-------
+ fs/cifs/misc.c       |    2 +-
+ fs/cifs/sess.c       |    2 +-
+ fs/cifs/transport.c  |  427 ++++++++++++++++++++++++--------------------------
+ 13 files changed, 455 insertions(+), 381 deletions(-)
+Merging configfs/linux-next
+$ git merge configfs/linux-next
+Already up-to-date.
+Merging ecryptfs/next
+$ git merge ecryptfs/next
+Merge made by recursive.
+ fs/ecryptfs/ecryptfs_kernel.h |    3 +--
+ fs/ecryptfs/kthread.c         |   19 +++++++++++++++----
+ fs/ecryptfs/main.c            |    3 +--
+ 3 files changed, 17 insertions(+), 8 deletions(-)
+Merging ext3/for_next
+$ git merge ext3/for_next
+Auto-merging fs/ext3/super.c
+Auto-merging fs/ext4/super.c
+Auto-merging fs/ocfs2/super.c
+Merge made by recursive.
+ fs/ext3/super.c          |   25 +++++++------------------
+ fs/ext4/super.c          |   25 +++++++------------------
+ fs/ocfs2/super.c         |    5 ++---
+ fs/quota/dquot.c         |   18 ++----------------
+ fs/quota/quota.c         |   41 +++++++++++++++++++++++++++--------------
+ fs/reiserfs/super.c      |   17 ++++++-----------
+ include/linux/quota.h    |    5 ++++-
+ include/linux/quotaops.h |    4 +---
+ 8 files changed, 56 insertions(+), 84 deletions(-)
+Merging ext4/next
+$ git merge ext4/next
+Already up-to-date.
+Merging fatfs/master
+$ git merge fatfs/master
+Already up-to-date.
+Merging fuse/for-next
+$ git merge fuse/for-next
+Auto-merging fs/fuse/dir.c
+Merge made by recursive.
+ fs/fuse/dir.c |   36 +++++++++++++++++++++++++-----------
+ 1 files changed, 25 insertions(+), 11 deletions(-)
+Merging gfs2/master
+$ git merge gfs2/master
+Merge made by recursive.
+ fs/gfs2/acl.c        |    7 +-
+ fs/gfs2/glock.c      |  390 +++++++++++++++++++-------------------------------
+ fs/gfs2/glock.h      |   39 +++---
+ fs/gfs2/glops.c      |   23 ++--
+ fs/gfs2/incore.h     |    5 +-
+ fs/gfs2/inode.c      |   72 +++-------
+ fs/gfs2/inode.h      |    1 -
+ fs/gfs2/lock_dlm.c   |   14 +--
+ fs/gfs2/lops.c       |    3 +-
+ fs/gfs2/main.c       |    6 +-
+ fs/gfs2/ops_fstype.c |    7 +-
+ fs/gfs2/ops_inode.c  |   10 +-
+ fs/gfs2/super.c      |    1 +
+ 13 files changed, 223 insertions(+), 355 deletions(-)
+Merging hfsplus/for-next
+$ git merge hfsplus/for-next
+Already up-to-date.
+Merging jfs/next
+$ git merge jfs/next
+Already up-to-date.
+Merging logfs/master
+$ git merge logfs/master
+Resolved 'fs/logfs/logfs.h' using previous resolution.
+Auto-merging fs/logfs/dir.c
+Auto-merging fs/logfs/file.c
+Auto-merging fs/logfs/logfs.h
+CONFLICT (content): Merge conflict in fs/logfs/logfs.h
+Automatic merge failed; fix conflicts and then commit the result.
+$ git commit -v -a
+[master 9603fa1] Merge remote branch 'logfs/master'
+$ git diff -M --stat --summary HEAD^..
+Merging nfs/linux-next
+$ git merge nfs/linux-next
+Already up-to-date.
+Merging nfsd/nfsd-next
+$ git merge nfsd/nfsd-next
+Already up-to-date.
+Merging nilfs2/for-next
+$ git merge nilfs2/for-next
+Merge made by recursive.
+ fs/nilfs2/dir.c           |    3 --
+ fs/nilfs2/inode.c         |   19 ++++--------
+ fs/nilfs2/ioctl.c         |   70 +++++++++++++++++++++++++++++++++++++++++++++
+ fs/nilfs2/nilfs.h         |   17 +++++++++++
+ include/linux/nilfs2_fs.h |   20 -------------
+ 5 files changed, 94 insertions(+), 35 deletions(-)
+Merging ocfs2/linux-next
+$ git merge ocfs2/linux-next
+Already up-to-date.
+Merging omfs/for-next
+$ git merge omfs/for-next
+Already up-to-date.
+Merging squashfs/master
+$ git merge squashfs/master
+Already up-to-date.
+Merging udf/for_next
+$ git merge udf/for_next
+Already up-to-date.
+Merging v9fs/for-next
+$ git merge v9fs/for-next
+Already up-to-date.
+Merging ubifs/linux-next
+$ git merge ubifs/linux-next
+Already up-to-date.
+Merging xfs/master
+$ git merge xfs/master
+Already up-to-date.
+Merging vfs/for-next
+$ git merge vfs/for-next
+Already up-to-date.
+Merging vfs-scale/vfs-scale-working
+$ git merge vfs-scale/vfs-scale-working
+Already up-to-date.
+Merging pci/linux-next
+$ git merge pci/linux-next
+Already up-to-date.
+Merging hid/for-next
+$ git merge hid/for-next
+Merge made by recursive.
+ .../ABI/testing/sysfs-driver-hid-roccat-arvo       |   48 ++
+ drivers/hid/Kconfig                                |    7 +
+ drivers/hid/Makefile                               |    1 +
+ drivers/hid/hid-core.c                             |    1 +
+ drivers/hid/hid-ids.h                              |    1 +
+ drivers/hid/hid-roccat-arvo.c                      |  516 ++++++++++++++++++++
+ drivers/hid/hid-roccat-arvo.h                      |   98 ++++
+ drivers/hid/hid-roccat-koneplus.c                  |    7 +
+ 8 files changed, 679 insertions(+), 0 deletions(-)
+ create mode 100644 Documentation/ABI/testing/sysfs-driver-hid-roccat-arvo
+ create mode 100644 drivers/hid/hid-roccat-arvo.c
+ create mode 100644 drivers/hid/hid-roccat-arvo.h
+Merging quilt/i2c
+$ git merge quilt/i2c
+Already up-to-date.
+Merging bjdooks-i2c/next-i2c
+$ git merge bjdooks-i2c/next-i2c
+Resolved 'arch/arm/mach-pxa/devices.c' using previous resolution.
+Resolved 'arch/arm/mach-pxa/poodle.c' using previous resolution.
+Resolved 'arch/arm/mach-pxa/pxa27x.c' using previous resolution.
+Resolved 'arch/arm/mach-pxa/pxa3xx.c' using previous resolution.
+Resolved 'arch/arm/mach-pxa/z2.c' using previous resolution.
+CONFLICT (rename/rename): Rename "arch/arm/mach-pxa/include/mach/pxa2xx_spi.h"->"arch/arm/mach-s5pv310/include/mach/dma.h" in branch "HEAD" rename "arch/arm/mach-pxa/include/mach/pxa2xx_spi.h"->"include/linux/spi/pxa2xx_spi.h" in "bjdooks-i2c/next-i2c"
+Renaming arch/arm/plat-pxa/include/plat/ssp.h->include/linux/pxa2xx_ssp.h
+Auto-merging include/linux/pxa2xx_ssp.h
+Auto-merging arch/arm/mach-mmp/include/mach/mmp2.h
+Auto-merging arch/arm/mach-pxa/balloon3.c
+Auto-merging arch/arm/mach-pxa/cm-x300.c
+Auto-merging arch/arm/mach-pxa/colibri-pxa270-income.c
+Auto-merging arch/arm/mach-pxa/corgi.c
+Auto-merging arch/arm/mach-pxa/csb726.c
+Auto-merging arch/arm/mach-pxa/devices.c
+CONFLICT (content): Merge conflict in arch/arm/mach-pxa/devices.c
+Auto-merging arch/arm/mach-pxa/em-x270.c
+Auto-merging arch/arm/mach-pxa/ezx.c
+Auto-merging arch/arm/mach-pxa/hx4700.c
+Auto-merging arch/arm/mach-pxa/icontrol.c
+Auto-merging arch/arm/mach-pxa/littleton.c
+Auto-merging arch/arm/mach-pxa/lubbock.c
+Auto-merging arch/arm/mach-pxa/magician.c
+Auto-merging arch/arm/mach-pxa/mainstone.c
+Auto-merging arch/arm/mach-pxa/mioa701.c
+Auto-merging arch/arm/mach-pxa/mxm8x10.c
+Auto-merging arch/arm/mach-pxa/pcm027.c
+Auto-merging arch/arm/mach-pxa/pcm990-baseboard.c
+Auto-merging arch/arm/mach-pxa/poodle.c
+CONFLICT (content): Merge conflict in arch/arm/mach-pxa/poodle.c
+Auto-merging arch/arm/mach-pxa/pxa27x.c
+CONFLICT (content): Merge conflict in arch/arm/mach-pxa/pxa27x.c
+Auto-merging arch/arm/mach-pxa/pxa3xx.c
+CONFLICT (content): Merge conflict in arch/arm/mach-pxa/pxa3xx.c
+Auto-merging arch/arm/mach-pxa/raumfeld.c
+Auto-merging arch/arm/mach-pxa/saar.c
+Auto-merging arch/arm/mach-pxa/spitz.c
+Auto-merging arch/arm/mach-pxa/stargate2.c
+Auto-merging arch/arm/mach-pxa/tavorevb3.c
+Auto-merging arch/arm/mach-pxa/tosa.c
+Auto-merging arch/arm/mach-pxa/trizeps4.c
+CONFLICT (content): Merge conflict in arch/arm/mach-pxa/trizeps4.c
+Auto-merging arch/arm/mach-pxa/viper.c
+Auto-merging arch/arm/mach-pxa/vpac270.c
+Auto-merging arch/arm/mach-pxa/xcep.c
+Auto-merging arch/arm/mach-pxa/z2.c
+CONFLICT (content): Merge conflict in arch/arm/mach-pxa/z2.c
+Auto-merging arch/arm/mach-pxa/zeus.c
+Auto-merging drivers/spi/pxa2xx_spi.c
+Automatic merge failed; fix conflicts and then commit the result.
+$ git rm -f arch/arm/mach-pxa/include/mach/pxa2xx_spi.h
+arch/arm/mach-pxa/devices.c: needs merge
+arch/arm/mach-pxa/include/mach/pxa2xx_spi.h: needs merge
+arch/arm/mach-pxa/poodle.c: needs merge
+arch/arm/mach-pxa/pxa27x.c: needs merge
+arch/arm/mach-pxa/pxa3xx.c: needs merge
+arch/arm/mach-pxa/trizeps4.c: needs merge
+arch/arm/mach-pxa/z2.c: needs merge
+arch/arm/mach-s5pv310/include/mach/dma.h: needs merge
+include/linux/spi/pxa2xx_spi.h: needs merge
+rm 'arch/arm/mach-pxa/include/mach/pxa2xx_spi.h'
+$ git commit -v -a
+Recorded resolution for 'arch/arm/mach-pxa/trizeps4.c'.
+[master 1492ace] Merge remote branch 'bjdooks-i2c/next-i2c'
+$ git diff -M --stat --summary HEAD^..
+ arch/arm/mach-mmp/include/mach/mmp2.h              |    2 +-
+ arch/arm/mach-mmp/include/mach/pxa168.h            |    2 +-
+ arch/arm/mach-mmp/include/mach/pxa910.h            |    2 +-
+ arch/arm/mach-pxa/balloon3.c                       |    3 +-
+ arch/arm/mach-pxa/cm-x300.c                        |    2 +-
+ arch/arm/mach-pxa/colibri-pxa270-income.c          |    3 +-
+ arch/arm/mach-pxa/corgi.c                          |    2 +-
+ arch/arm/mach-pxa/csb726.c                         |    2 +-
+ arch/arm/mach-pxa/devices.c                        |    2 +-
+ arch/arm/mach-pxa/em-x270.c                        |    2 +-
+ arch/arm/mach-pxa/ezx.c                            |    2 +-
+ arch/arm/mach-pxa/hx4700.c                         |    2 +-
+ arch/arm/mach-pxa/littleton.c                      |    2 +-
+ arch/arm/mach-pxa/magician.c                       |    2 +-
+ arch/arm/mach-pxa/mainstone.c                      |    2 +-
+ arch/arm/mach-pxa/mioa701.c                        |    2 +-
+ arch/arm/mach-pxa/mxm8x10.c                        |    2 +-
+ arch/arm/mach-pxa/palm27x.c                        |    3 +-
+ arch/arm/mach-pxa/pcm990-baseboard.c               |    2 +-
+ arch/arm/mach-pxa/poodle.c                         |    2 +-
+ arch/arm/mach-pxa/pxa27x.c                         |    3 +-
+ arch/arm/mach-pxa/pxa3xx.c                         |    2 +-
+ arch/arm/mach-pxa/raumfeld.c                       |    2 +-
+ arch/arm/mach-pxa/saar.c                           |    2 +-
+ arch/arm/mach-pxa/spitz.c                          |    3 +-
+ arch/arm/mach-pxa/stargate2.c                      |    2 +-
+ arch/arm/mach-pxa/tavorevb3.c                      |    3 +-
+ arch/arm/mach-pxa/tosa.c                           |    2 +-
+ arch/arm/mach-pxa/trizeps4.c                       |    2 +-
+ arch/arm/mach-pxa/viper.c                          |    2 +-
+ arch/arm/mach-pxa/vpac270.c                        |    3 +-
+ arch/arm/mach-pxa/xcep.c                           |    3 +-
+ arch/arm/mach-pxa/z2.c                             |    3 +-
+ arch/arm/mach-pxa/zeus.c                           |    3 +-
+ arch/arm/mach-pxa/zylonite_pxa300.c                |    2 +-
+ drivers/i2c/busses/Kconfig                         |    7 +-
+ drivers/i2c/busses/Makefile                        |    1 +
+ drivers/i2c/busses/i2c-pxa-pci.c                   |  173 ++++++++++++++++++++
+ drivers/i2c/busses/i2c-pxa.c                       |  116 ++++++++++---
+ .../plat/i2c.h => include/linux/i2c/pxa-i2c.h      |    0
+ 40 files changed, 304 insertions(+), 73 deletions(-)
+ create mode 100644 drivers/i2c/busses/i2c-pxa-pci.c
+ rename arch/arm/plat-pxa/include/plat/i2c.h => include/linux/i2c/pxa-i2c.h (100%)
+Merging quilt/jdelvare-hwmon
+$ git merge quilt/jdelvare-hwmon
+Already up-to-date.
+Merging hwmon-staging/hwmon-next
+$ git merge hwmon-staging/hwmon-next
+Merge made by recursive.
+ Documentation/hwmon/max6639 |   49 ++++
+ drivers/hwmon/Kconfig       |   10 +
+ drivers/hwmon/Makefile      |    1 +
+ drivers/hwmon/max6639.c     |  639 +++++++++++++++++++++++++++++++++++++++++++
+ include/linux/i2c/max6639.h |   14 +
+ 5 files changed, 713 insertions(+), 0 deletions(-)
+ create mode 100644 Documentation/hwmon/max6639
+ create mode 100644 drivers/hwmon/max6639.c
+ create mode 100644 include/linux/i2c/max6639.h
+Merging quilt/kernel-doc
+$ git merge quilt/kernel-doc
+Already up-to-date.
+Merging v4l-dvb/master
+$ git merge v4l-dvb/master
+Removing drivers/media/radio/radio-gemtek-pci.c
+Removing drivers/media/video/mt9v011.h
+Removing drivers/media/video/tda9875.c
+Merge made by recursive.
+ Documentation/DocBook/dvb/dvbapi.xml               |    2 +-
+ Documentation/DocBook/media-entities.tmpl          |    8 +
+ Documentation/DocBook/media.tmpl                   |    4 +-
+ Documentation/DocBook/v4l/common.xml               |    2 +
+ Documentation/DocBook/v4l/compat.xml               |   11 +
+ Documentation/DocBook/v4l/dev-capture.xml          |   13 +-
+ Documentation/DocBook/v4l/dev-output.xml           |   13 +-
+ Documentation/DocBook/v4l/dev-rds.xml              |    6 +-
+ Documentation/DocBook/v4l/func-mmap.xml            |   10 +-
+ Documentation/DocBook/v4l/func-munmap.xml          |    3 +-
+ Documentation/DocBook/v4l/io.xml                   |  283 ++-
+ Documentation/DocBook/v4l/pixfmt-nv12m.xml         |  154 ++
+ Documentation/DocBook/v4l/pixfmt-yuv420m.xml       |  162 ++
+ Documentation/DocBook/v4l/pixfmt.xml               |  118 +-
+ Documentation/DocBook/v4l/planar-apis.xml          |   81 +
+ Documentation/DocBook/v4l/v4l2.xml                 |   25 +-
+ Documentation/DocBook/v4l/vidioc-enum-fmt.xml      |    2 +
+ Documentation/DocBook/v4l/vidioc-g-fmt.xml         |   15 +-
+ Documentation/DocBook/v4l/vidioc-qbuf.xml          |   24 +-
+ Documentation/DocBook/v4l/vidioc-querybuf.xml      |   14 +-
+ Documentation/DocBook/v4l/vidioc-querycap.xml      |   24 +-
+ Documentation/dvb/get_dvb_firmware                 |    8 +-
+ Documentation/video4linux/v4l2-controls.txt        |   12 +
+ drivers/media/common/saa7146_core.c                |    2 +-
+ drivers/media/common/saa7146_fops.c                |    8 +-
+ drivers/media/common/saa7146_vbi.c                 |    2 +-
+ drivers/media/common/saa7146_video.c               |   20 +-
+ drivers/media/common/tuners/tda8290.c              |  130 +-
+ drivers/media/dvb/dvb-usb/Kconfig                  |    8 +
+ drivers/media/dvb/dvb-usb/Makefile                 |    3 +
+ drivers/media/dvb/dvb-usb/dib0700.h                |    2 +
+ drivers/media/dvb/dvb-usb/dib0700_core.c           |   53 +-
+ drivers/media/dvb/dvb-usb/dib0700_devices.c        | 1410 +++++++++++--
+ drivers/media/dvb/dvb-usb/dvb-usb-ids.h            |    6 +
+ drivers/media/dvb/dvb-usb/dvb-usb-remote.c         |    2 +-
+ drivers/media/dvb/dvb-usb/dvb-usb.h                |    2 +
+ drivers/media/dvb/dvb-usb/technisat-usb2.c         |  808 +++++++
+ drivers/media/dvb/firewire/firedtv-rc.c            |    9 +-
+ drivers/media/dvb/frontends/Kconfig                |    8 +
+ drivers/media/dvb/frontends/Makefile               |    1 +
+ drivers/media/dvb/frontends/af9013.c               |    4 +-
+ drivers/media/dvb/frontends/dib0090.c              | 1595 +++++++++++---
+ drivers/media/dvb/frontends/dib0090.h              |   31 +
+ drivers/media/dvb/frontends/dib7000p.c             | 1945 ++++++++++++-----
+ drivers/media/dvb/frontends/dib7000p.h             |   96 +-
+ drivers/media/dvb/frontends/dib8000.c              |  821 +++++---
+ drivers/media/dvb/frontends/dib8000.h              |   20 +
+ drivers/media/dvb/frontends/dib9000.c              | 2350 ++++++++++++++++++++
+ drivers/media/dvb/frontends/dib9000.h              |  131 ++
+ drivers/media/dvb/frontends/dibx000_common.c       |  279 +++-
+ drivers/media/dvb/frontends/dibx000_common.h       |  152 +-
+ drivers/media/dvb/frontends/ix2505v.c              |    2 +-
+ drivers/media/dvb/frontends/mb86a20s.c             |   36 +-
+ drivers/media/dvb/frontends/stv090x.c              |  286 ++-
+ drivers/media/dvb/frontends/stv090x.h              |   16 +
+ drivers/media/dvb/frontends/stv090x_reg.h          |   16 +-
+ drivers/media/dvb/ngene/Makefile                   |    3 +
+ drivers/media/dvb/ngene/ngene-cards.c              |  179 ++-
+ drivers/media/dvb/ngene/ngene-core.c               |  236 ++-
+ drivers/media/dvb/ngene/ngene-dvb.c                |   71 +-
+ drivers/media/dvb/ngene/ngene.h                    |   24 +
+ drivers/media/dvb/ttpci/av7110_ca.c                |    2 +-
+ drivers/media/radio/Kconfig                        |   14 -
+ drivers/media/radio/Makefile                       |    1 -
+ drivers/media/radio/radio-aimslab.c                |    1 +
+ drivers/media/radio/radio-gemtek-pci.c             |  478 ----
+ drivers/media/radio/radio-maxiradio.c              |    4 +-
+ drivers/media/radio/radio-wl1273.c                 |    2 +-
+ drivers/media/radio/si470x/radio-si470x-common.c   |    9 +-
+ drivers/media/rc/ene_ir.c                          |   23 +-
+ drivers/media/rc/ene_ir.h                          |    2 -
+ drivers/media/rc/imon.c                            |   60 +-
+ drivers/media/rc/ir-raw.c                          |    2 +-
+ drivers/media/rc/keymaps/Makefile                  |    1 +
+ drivers/media/rc/keymaps/rc-dib0700-nec.c          |   52 +-
+ drivers/media/rc/keymaps/rc-technisat-usb2.c       |   93 +
+ drivers/media/rc/mceusb.c                          |    3 +-
+ drivers/media/video/Kconfig                        |   45 +-
+ drivers/media/video/Makefile                       |    8 +-
+ drivers/media/video/adv7175.c                      |   11 +
+ drivers/media/video/adv7343.c                      |  167 +-
+ drivers/media/video/adv7343_regs.h                 |    8 +-
+ drivers/media/video/bt819.c                        |  129 +-
+ drivers/media/video/bt8xx/bttv-cards.c             |   39 -
+ drivers/media/video/bt8xx/bttv.h                   |    1 -
+ drivers/media/video/cafe_ccic.c                    |   11 +-
+ drivers/media/video/cpia2/cpia2.h                  |    2 +-
+ drivers/media/video/cpia2/cpia2_core.c             |   65 +-
+ drivers/media/video/cpia2/cpia2_v4l.c              |  104 +-
+ drivers/media/video/cs5345.c                       |   87 +-
+ drivers/media/video/cx18/cx18-av-audio.c           |   92 +-
+ drivers/media/video/cx18/cx18-av-core.c            |  175 +-
+ drivers/media/video/cx18/cx18-av-core.h            |   12 +-
+ drivers/media/video/cx18/cx18-controls.c           |  285 +---
+ drivers/media/video/cx18/cx18-controls.h           |    7 +-
+ drivers/media/video/cx18/cx18-driver.c             |   54 +-
+ drivers/media/video/cx18/cx18-driver.h             |    5 +-
+ drivers/media/video/cx18/cx18-fileops.c            |   32 +-
+ drivers/media/video/cx18/cx18-ioctl.c              |   24 +-
+ drivers/media/video/cx18/cx18-mailbox.c            |    5 +-
+ drivers/media/video/cx18/cx18-mailbox.h            |    5 -
+ drivers/media/video/cx18/cx18-streams.c            |   16 +-
+ drivers/media/video/cx18/cx18-streams.h            |    3 +-
+ drivers/media/video/cx231xx/cx231xx-dvb.c          |    5 +-
+ drivers/media/video/cx25840/cx25840-core.c         |   22 +-
+ drivers/media/video/davinci/vpif.c                 |  177 ++
+ drivers/media/video/davinci/vpif.h                 |   18 +-
+ drivers/media/video/davinci/vpif_capture.c         |  451 +++-
+ drivers/media/video/davinci/vpif_capture.h         |    2 +
+ drivers/media/video/davinci/vpif_display.c         |  474 +++-
+ drivers/media/video/davinci/vpif_display.h         |    2 +
+ drivers/media/video/em28xx/em28xx-cards.c          |   19 +-
+ drivers/media/video/et61x251/et61x251.h            |   24 -
+ drivers/media/video/gspca/benq.c                   |    2 +-
+ drivers/media/video/gspca/conex.c                  |    4 +-
+ drivers/media/video/gspca/cpia1.c                  |    2 +-
+ drivers/media/video/gspca/etoms.c                  |    4 +-
+ drivers/media/video/gspca/finepix.c                |    2 +-
+ drivers/media/video/gspca/gl860/gl860.c            |    2 +-
+ drivers/media/video/gspca/gspca.c                  |  210 +-
+ drivers/media/video/gspca/gspca.h                  |    2 -
+ drivers/media/video/gspca/jeilinj.c                |    2 +-
+ drivers/media/video/gspca/jpeg.h                   |    4 +-
+ drivers/media/video/gspca/konica.c                 |    2 +-
+ drivers/media/video/gspca/m5602/m5602_core.c       |    2 +-
+ drivers/media/video/gspca/mars.c                   |    2 +-
+ drivers/media/video/gspca/mr97310a.c               |    2 +-
+ drivers/media/video/gspca/ov519.c                  |    8 +-
+ drivers/media/video/gspca/ov534.c                  |   29 +-
+ drivers/media/video/gspca/ov534_9.c                |    2 +-
+ drivers/media/video/gspca/pac207.c                 |    2 +-
+ drivers/media/video/gspca/pac7302.c                |    4 +-
+ drivers/media/video/gspca/pac7311.c                |    4 +-
+ drivers/media/video/gspca/sn9c2028.c               |    2 +-
+ drivers/media/video/gspca/sn9c20x.c                |    2 +-
+ drivers/media/video/gspca/sonixb.c                 |  270 ++-
+ drivers/media/video/gspca/sonixj.c                 |  155 +-
+ drivers/media/video/gspca/spca1528.c               |    2 +-
+ drivers/media/video/gspca/spca500.c                |    2 +-
+ drivers/media/video/gspca/spca501.c                |    2 +-
+ drivers/media/video/gspca/spca505.c                |    2 +-
+ drivers/media/video/gspca/spca508.c                |    2 +-
+ drivers/media/video/gspca/spca561.c                |    2 +-
+ drivers/media/video/gspca/sq905.c                  |    2 +-
+ drivers/media/video/gspca/sq905c.c                 |    2 +-
+ drivers/media/video/gspca/sq930x.c                 |    2 +-
+ drivers/media/video/gspca/stk014.c                 |    2 +-
+ drivers/media/video/gspca/stv0680.c                |    2 +-
+ drivers/media/video/gspca/stv06xx/stv06xx.c        |    2 +-
+ drivers/media/video/gspca/sunplus.c                |    2 +-
+ drivers/media/video/gspca/t613.c                   |    2 +-
+ drivers/media/video/gspca/tv8532.c                 |    2 +-
+ drivers/media/video/gspca/vc032x.c                 |    2 +-
+ drivers/media/video/gspca/xirlink_cit.c            |    2 +-
+ drivers/media/video/gspca/zc3xx.c                  |    2 +-
+ drivers/media/video/hdpvr/Makefile                 |    4 +-
+ drivers/media/video/hdpvr/hdpvr-core.c             |   10 +-
+ drivers/media/video/hdpvr/hdpvr-i2c.c              |  143 +-
+ drivers/media/video/hdpvr/hdpvr-video.c            |    7 +-
+ drivers/media/video/hdpvr/hdpvr.h                  |    5 +-
+ drivers/media/video/ir-kbd-i2c.c                   |   12 +-
+ drivers/media/video/ivtv/ivtv-i2c.c                |    9 +-
+ drivers/media/video/mem2mem_testdev.c              |  227 +-
+ drivers/media/video/mt9v011.c                      |   54 +-
+ drivers/media/video/mt9v011.h                      |   36 -
+ drivers/media/video/noon010pc30.c                  |  792 +++++++
+ drivers/media/video/ov7670.c                       |   74 +-
+ drivers/media/video/pvrusb2/pvrusb2-hdw-internal.h |    2 +
+ drivers/media/video/pvrusb2/pvrusb2-i2c-core.c     |   62 +-
+ drivers/media/video/s5p-fimc/fimc-capture.c        |  550 +++--
+ drivers/media/video/s5p-fimc/fimc-core.c           |  872 ++++----
+ drivers/media/video/s5p-fimc/fimc-core.h           |  134 +-
+ drivers/media/video/s5p-fimc/fimc-reg.c            |  199 +-
+ drivers/media/video/s5p-fimc/regs-fimc.h           |   29 +-
+ drivers/media/video/saa7110.c                      |  115 +-
+ drivers/media/video/saa7134/saa7134-cards.c        |   51 +-
+ drivers/media/video/saa7134/saa7134-dvb.c          |   80 +-
+ drivers/media/video/sn9c102/sn9c102_devtable.h     |   74 +-
+ drivers/media/video/sr030pc30.c                    |   10 -
+ drivers/media/video/tda9875.c                      |  411 ----
+ drivers/media/video/tlg2300/pd-video.c             |   13 +-
+ drivers/media/video/tlv320aic23b.c                 |   74 +-
+ drivers/media/video/tvp514x.c                      |  236 +--
+ drivers/media/video/tvp5150.c                      |  157 +-
+ drivers/media/video/tvp7002.c                      |  117 +-
+ drivers/media/video/v4l2-common.c                  |   19 +-
+ drivers/media/video/v4l2-compat-ioctl32.c          |  229 ++-
+ drivers/media/video/v4l2-ctrls.c                   |   34 +-
+ drivers/media/video/v4l2-dev.c                     |    9 +-
+ drivers/media/video/v4l2-device.c                  |   16 +-
+ drivers/media/video/v4l2-ioctl.c                   |  475 ++++-
+ drivers/media/video/v4l2-mem2mem.c                 |  232 +-
+ drivers/media/video/videobuf2-core.c               | 1804 +++++++++++++++
+ drivers/media/video/videobuf2-dma-contig.c         |  185 ++
+ drivers/media/video/videobuf2-dma-sg.c             |  292 +++
+ drivers/media/video/videobuf2-memops.c             |  232 ++
+ drivers/media/video/videobuf2-vmalloc.c            |  132 ++
+ drivers/media/video/vivi.c                         |  585 +++--
+ drivers/media/video/vpx3220.c                      |  137 +-
+ drivers/media/video/w9966.c                        |    1 +
+ drivers/media/video/zoran/zoran_card.c             |    2 +-
+ drivers/staging/Kconfig                            |    2 +
+ drivers/staging/Makefile                           |    1 +
+ drivers/staging/cxd2099/Kconfig                    |   11 +
+ drivers/staging/cxd2099/Makefile                   |    5 +
+ drivers/staging/cxd2099/TODO                       |   12 +
+ drivers/staging/cxd2099/cxd2099.c                  |  574 +++++
+ drivers/staging/cxd2099/cxd2099.h                  |   41 +
+ drivers/staging/lirc/TODO.lirc_zilog               |   36 +-
+ drivers/staging/lirc/lirc_imon.c                   |    1 +
+ drivers/staging/lirc/lirc_it87.c                   |    1 +
+ drivers/staging/lirc/lirc_parallel.c               |   19 +-
+ drivers/staging/lirc/lirc_sasem.c                  |    1 +
+ drivers/staging/lirc/lirc_serial.c                 |    3 +-
+ drivers/staging/lirc/lirc_sir.c                    |    1 +
+ drivers/staging/lirc/lirc_zilog.c                  |  650 +++---
+ drivers/staging/tm6000/tm6000-video.c              |   46 +-
+ include/linux/videodev2.h                          |  131 ++-
+ include/media/mt9v011.h                            |   17 +
+ include/media/noon010pc30.h                        |   28 +
+ include/media/rc-core.h                            |    3 +
+ include/media/rc-map.h                             |    1 +
+ include/media/{s3c_fimc.h => s5p_fimc.h}           |   20 +-
+ include/media/saa7146.h                            |    2 +-
+ include/media/v4l2-chip-ident.h                    |    3 +
+ include/media/v4l2-common.h                        |   13 +-
+ include/media/v4l2-ctrls.h                         |    7 +-
+ include/media/v4l2-ioctl.h                         |   16 +
+ include/media/v4l2-mem2mem.h                       |   56 +-
+ include/media/v4l2-subdev.h                        |   23 +-
+ include/media/videobuf2-core.h                     |  380 ++++
+ include/media/videobuf2-dma-contig.h               |   29 +
+ include/media/videobuf2-dma-sg.h                   |   32 +
+ include/media/videobuf2-memops.h                   |   45 +
+ include/media/videobuf2-vmalloc.h                  |   20 +
+ 235 files changed, 20048 insertions(+), 6975 deletions(-)
+ create mode 100644 Documentation/DocBook/v4l/pixfmt-nv12m.xml
+ create mode 100644 Documentation/DocBook/v4l/pixfmt-yuv420m.xml
+ create mode 100644 Documentation/DocBook/v4l/planar-apis.xml
+ create mode 100644 drivers/media/dvb/dvb-usb/technisat-usb2.c
+ create mode 100644 drivers/media/dvb/frontends/dib9000.c
+ create mode 100644 drivers/media/dvb/frontends/dib9000.h
+ delete mode 100644 drivers/media/radio/radio-gemtek-pci.c
+ create mode 100644 drivers/media/rc/keymaps/rc-technisat-usb2.c
+ delete mode 100644 drivers/media/video/mt9v011.h
+ create mode 100644 drivers/media/video/noon010pc30.c
+ delete mode 100644 drivers/media/video/tda9875.c
+ create mode 100644 drivers/media/video/videobuf2-core.c
+ create mode 100644 drivers/media/video/videobuf2-dma-contig.c
+ create mode 100644 drivers/media/video/videobuf2-dma-sg.c
+ create mode 100644 drivers/media/video/videobuf2-memops.c
+ create mode 100644 drivers/media/video/videobuf2-vmalloc.c
+ create mode 100644 drivers/staging/cxd2099/Kconfig
+ create mode 100644 drivers/staging/cxd2099/Makefile
+ create mode 100644 drivers/staging/cxd2099/TODO
+ create mode 100644 drivers/staging/cxd2099/cxd2099.c
+ create mode 100644 drivers/staging/cxd2099/cxd2099.h
+ create mode 100644 include/media/mt9v011.h
+ create mode 100644 include/media/noon010pc30.h
+ rename include/media/{s3c_fimc.h => s5p_fimc.h} (75%)
+ create mode 100644 include/media/videobuf2-core.h
+ create mode 100644 include/media/videobuf2-dma-contig.h
+ create mode 100644 include/media/videobuf2-dma-sg.h
+ create mode 100644 include/media/videobuf2-memops.h
+ create mode 100644 include/media/videobuf2-vmalloc.h
+Merging kbuild/for-next
+$ git merge kbuild/for-next
+Already up-to-date!
+Merge made by recursive.
+Merging kconfig/for-next
+$ git merge kconfig/for-next
+Already up-to-date!
+Merge made by recursive.
+Merging ide/master
+$ git merge ide/master
+Already up-to-date.
+Merging libata/NEXT
+$ git merge libata/NEXT
+Merge made by recursive.
+ drivers/ata/ahci.c         |    3 +
+ drivers/ata/pata_hpt366.c  |    6 +-
+ drivers/ata/pata_hpt37x.c  |  112 +++++++++++++++++++++-----------------------
+ drivers/ata/pata_hpt3x2n.c |   12 ++---
+ drivers/ata/pata_mpc52xx.c |    2 +-
+ 5 files changed, 66 insertions(+), 69 deletions(-)
+Merging infiniband/for-next
+$ git merge infiniband/for-next
+Already up-to-date.
+Merging acpi/test
+$ git merge acpi/test
+Auto-merging drivers/acpi/acpica/acglobal.h
+Auto-merging drivers/acpi/acpica/acobject.h
+Auto-merging drivers/acpi/acpica/evmisc.c
+Auto-merging drivers/acpi/acpica/nsinit.c
+Auto-merging drivers/acpi/acpica/utmutex.c
+Auto-merging include/acpi/actbl1.h
+Merge made by recursive.
+ drivers/acpi/acpica/accommon.h  |    2 +-
+ drivers/acpi/acpica/acconfig.h  |    2 +-
+ drivers/acpi/acpica/acdebug.h   |    2 +-
+ drivers/acpi/acpica/acdispat.h  |    2 +-
+ drivers/acpi/acpica/acevents.h  |    2 +-
+ drivers/acpi/acpica/acglobal.h  |    2 +-
+ drivers/acpi/acpica/achware.h   |    2 +-
+ drivers/acpi/acpica/acinterp.h  |    2 +-
+ drivers/acpi/acpica/aclocal.h   |    2 +-
+ drivers/acpi/acpica/acmacros.h  |    2 +-
+ drivers/acpi/acpica/acnamesp.h  |    2 +-
+ drivers/acpi/acpica/acobject.h  |   16 +++++++---
+ drivers/acpi/acpica/acopcode.h  |    2 +-
+ drivers/acpi/acpica/acparser.h  |    2 +-
+ drivers/acpi/acpica/acpredef.h  |    2 +-
+ drivers/acpi/acpica/acresrc.h   |    2 +-
+ drivers/acpi/acpica/acstruct.h  |    2 +-
+ drivers/acpi/acpica/actables.h  |    2 +-
+ drivers/acpi/acpica/acutils.h   |    2 +-
+ drivers/acpi/acpica/amlcode.h   |   10 +-----
+ drivers/acpi/acpica/amlresrc.h  |    2 +-
+ drivers/acpi/acpica/dsfield.c   |    2 +-
+ drivers/acpi/acpica/dsinit.c    |    2 +-
+ drivers/acpi/acpica/dsmethod.c  |   64 +++++++++++++++++++++++++++++----------
+ drivers/acpi/acpica/dsmthdat.c  |    2 +-
+ drivers/acpi/acpica/dsobject.c  |    2 +-
+ drivers/acpi/acpica/dsopcode.c  |    2 +-
+ drivers/acpi/acpica/dsutils.c   |    2 +-
+ drivers/acpi/acpica/dswexec.c   |    2 +-
+ drivers/acpi/acpica/dswload.c   |    2 +-
+ drivers/acpi/acpica/dswscope.c  |    2 +-
+ drivers/acpi/acpica/dswstate.c  |    2 +-
+ drivers/acpi/acpica/evevent.c   |    2 +-
+ drivers/acpi/acpica/evgpe.c     |    4 ++-
+ drivers/acpi/acpica/evgpeblk.c  |    2 +-
+ drivers/acpi/acpica/evgpeinit.c |    2 +-
+ drivers/acpi/acpica/evgpeutil.c |    2 +-
+ drivers/acpi/acpica/evmisc.c    |    2 +-
+ drivers/acpi/acpica/evregion.c  |    2 +-
+ drivers/acpi/acpica/evrgnini.c  |    6 ++--
+ drivers/acpi/acpica/evsci.c     |    2 +-
+ drivers/acpi/acpica/evxface.c   |    2 +-
+ drivers/acpi/acpica/evxfevnt.c  |    2 +-
+ drivers/acpi/acpica/evxfgpe.c   |    2 +-
+ drivers/acpi/acpica/evxfregn.c  |    2 +-
+ drivers/acpi/acpica/exconfig.c  |    2 +-
+ drivers/acpi/acpica/exconvrt.c  |    2 +-
+ drivers/acpi/acpica/excreate.c  |   10 +++---
+ drivers/acpi/acpica/exdebug.c   |    2 +-
+ drivers/acpi/acpica/exdump.c    |    4 +-
+ drivers/acpi/acpica/exfield.c   |    2 +-
+ drivers/acpi/acpica/exfldio.c   |    2 +-
+ drivers/acpi/acpica/exmisc.c    |    2 +-
+ drivers/acpi/acpica/exmutex.c   |    2 +-
+ drivers/acpi/acpica/exnames.c   |    2 +-
+ drivers/acpi/acpica/exoparg1.c  |    2 +-
+ drivers/acpi/acpica/exoparg2.c  |    2 +-
+ drivers/acpi/acpica/exoparg3.c  |    2 +-
+ drivers/acpi/acpica/exoparg6.c  |    2 +-
+ drivers/acpi/acpica/exprep.c    |    2 +-
+ drivers/acpi/acpica/exregion.c  |    2 +-
+ drivers/acpi/acpica/exresnte.c  |    2 +-
+ drivers/acpi/acpica/exresolv.c  |    2 +-
+ drivers/acpi/acpica/exresop.c   |    2 +-
+ drivers/acpi/acpica/exstore.c   |    2 +-
+ drivers/acpi/acpica/exstoren.c  |    2 +-
+ drivers/acpi/acpica/exstorob.c  |    2 +-
+ drivers/acpi/acpica/exsystem.c  |    2 +-
+ drivers/acpi/acpica/exutils.c   |    2 +-
+ drivers/acpi/acpica/hwacpi.c    |    2 +-
+ drivers/acpi/acpica/hwgpe.c     |    2 +-
+ drivers/acpi/acpica/hwpci.c     |    2 +-
+ drivers/acpi/acpica/hwregs.c    |    2 +-
+ drivers/acpi/acpica/hwsleep.c   |    2 +-
+ drivers/acpi/acpica/hwtimer.c   |    2 +-
+ drivers/acpi/acpica/hwvalid.c   |    2 +-
+ drivers/acpi/acpica/hwxface.c   |    2 +-
+ drivers/acpi/acpica/nsaccess.c  |    8 ++--
+ drivers/acpi/acpica/nsalloc.c   |   15 +++++++--
+ drivers/acpi/acpica/nsdump.c    |   17 ++++++++++-
+ drivers/acpi/acpica/nsdumpdv.c  |    2 +-
+ drivers/acpi/acpica/nseval.c    |    4 +-
+ drivers/acpi/acpica/nsinit.c    |    2 +-
+ drivers/acpi/acpica/nsload.c    |    2 +-
+ drivers/acpi/acpica/nsnames.c   |    2 +-
+ drivers/acpi/acpica/nsobject.c  |    2 +-
+ drivers/acpi/acpica/nsparse.c   |    2 +-
+ drivers/acpi/acpica/nspredef.c  |    2 +-
+ drivers/acpi/acpica/nsrepair.c  |    2 +-
+ drivers/acpi/acpica/nsrepair2.c |    2 +-
+ drivers/acpi/acpica/nssearch.c  |    2 +-
+ drivers/acpi/acpica/nsutils.c   |    2 +-
+ drivers/acpi/acpica/nswalk.c    |    2 +-
+ drivers/acpi/acpica/nsxfeval.c  |    2 +-
+ drivers/acpi/acpica/nsxfname.c  |    7 ++--
+ drivers/acpi/acpica/nsxfobj.c   |    2 +-
+ drivers/acpi/acpica/psargs.c    |    2 +-
+ drivers/acpi/acpica/psloop.c    |    4 +-
+ drivers/acpi/acpica/psopcode.c  |    2 +-
+ drivers/acpi/acpica/psparse.c   |   27 +++++-----------
+ drivers/acpi/acpica/psscope.c   |    2 +-
+ drivers/acpi/acpica/pstree.c    |    2 +-
+ drivers/acpi/acpica/psutils.c   |    2 +-
+ drivers/acpi/acpica/pswalk.c    |    2 +-
+ drivers/acpi/acpica/psxface.c   |    9 ++---
+ drivers/acpi/acpica/rsaddr.c    |    2 +-
+ drivers/acpi/acpica/rscalc.c    |    2 +-
+ drivers/acpi/acpica/rscreate.c  |    2 +-
+ drivers/acpi/acpica/rsdump.c    |    2 +-
+ drivers/acpi/acpica/rsinfo.c    |    2 +-
+ drivers/acpi/acpica/rsio.c      |    2 +-
+ drivers/acpi/acpica/rsirq.c     |    2 +-
+ drivers/acpi/acpica/rslist.c    |    2 +-
+ drivers/acpi/acpica/rsmemory.c  |    2 +-
+ drivers/acpi/acpica/rsmisc.c    |    2 +-
+ drivers/acpi/acpica/rsutils.c   |    2 +-
+ drivers/acpi/acpica/rsxface.c   |    2 +-
+ drivers/acpi/acpica/tbfadt.c    |    2 +-
+ drivers/acpi/acpica/tbfind.c    |    2 +-
+ drivers/acpi/acpica/tbinstal.c  |    2 +-
+ drivers/acpi/acpica/tbutils.c   |    2 +-
+ drivers/acpi/acpica/tbxface.c   |    2 +-
+ drivers/acpi/acpica/tbxfroot.c  |    2 +-
+ drivers/acpi/acpica/utalloc.c   |    2 +-
+ drivers/acpi/acpica/utcopy.c    |    2 +-
+ drivers/acpi/acpica/utdebug.c   |    2 +-
+ drivers/acpi/acpica/utdelete.c  |    2 +-
+ drivers/acpi/acpica/uteval.c    |    2 +-
+ drivers/acpi/acpica/utglobal.c  |    2 +-
+ drivers/acpi/acpica/utids.c     |    2 +-
+ drivers/acpi/acpica/utinit.c    |    2 +-
+ drivers/acpi/acpica/utlock.c    |    2 +-
+ drivers/acpi/acpica/utmath.c    |    2 +-
+ drivers/acpi/acpica/utmisc.c    |    2 +-
+ drivers/acpi/acpica/utmutex.c   |    2 +-
+ drivers/acpi/acpica/utobject.c  |    2 +-
+ drivers/acpi/acpica/utosi.c     |    2 +-
+ drivers/acpi/acpica/utresrc.c   |    2 +-
+ drivers/acpi/acpica/utstate.c   |    2 +-
+ drivers/acpi/acpica/utxface.c   |    2 +-
+ drivers/acpi/acpica/utxferror.c |    2 +-
+ include/acpi/acexcep.h          |    2 +-
+ include/acpi/acnames.h          |    2 +-
+ include/acpi/acoutput.h         |    2 +-
+ include/acpi/acpi.h             |    2 +-
+ include/acpi/acpiosxf.h         |    2 +-
+ include/acpi/acpixf.h           |    4 +-
+ include/acpi/acrestyp.h         |    2 +-
+ include/acpi/actbl.h            |    2 +-
+ include/acpi/actbl1.h           |    2 +-
+ include/acpi/actbl2.h           |    2 +-
+ include/acpi/actypes.h          |    2 +-
+ include/acpi/platform/acenv.h   |    2 +-
+ include/acpi/platform/acgcc.h   |    2 +-
+ include/acpi/platform/aclinux.h |    2 +-
+ 155 files changed, 267 insertions(+), 220 deletions(-)
+Merging idle-test/idle-test
+$ git merge idle-test/idle-test
+Merge made by recursive.
+ arch/x86/include/asm/msr-index.h |    4 ++++
+ drivers/idle/intel_idle.c        |   30 ++++++++++++++++++++++++++++++
+ 2 files changed, 34 insertions(+), 0 deletions(-)
+Merging ieee1394/for-next
+$ git merge ieee1394/for-next
+Already up-to-date.
+Merging ubi/linux-next
+$ git merge ubi/linux-next
+Already up-to-date.
+Merging kvm/linux-next
+$ git merge kvm/linux-next
+Merge made by recursive.
+ arch/x86/kvm/svm.c |    2 +-
+ 1 files changed, 1 insertions(+), 1 deletions(-)
+Merging dlm/next
+$ git merge dlm/next
+Already up-to-date.
+Merging swiotlb/master
+$ git merge swiotlb/master
+Already up-to-date.
+Merging ibft/master
+$ git merge ibft/master
+Already up-to-date.
+Merging scsi/master
+$ git merge scsi/master
+Already up-to-date.
+Merging async_tx/next
+$ git merge async_tx/next
+Already up-to-date.
+Merging net/master
+$ git merge net/master
+Auto-merging net/core/dev.c
+Auto-merging net/core/rtnetlink.c
+Auto-merging net/netfilter/nf_conntrack_netlink.c
+Merge made by recursive.
+ drivers/net/vxge/vxge-config.c                     |   32 +-
+ drivers/net/vxge/vxge-config.h                     |   10 +
+ drivers/net/vxge/vxge-main.c                       |  216 +++-
+ drivers/net/vxge/vxge-main.h                       |   23 +-
+ drivers/net/vxge/vxge-traffic.c                    |  116 ++-
+ drivers/net/vxge/vxge-traffic.h                    |   14 +-
+ drivers/net/vxge/vxge-version.h                    |    4 +-
+ include/linux/audit.h                              |    2 +
+ include/linux/if_link.h                            |    1 +
+ include/linux/ip_vs.h                              |    8 +
+ include/linux/netdevice.h                          |   75 ++
+ include/linux/netfilter.h                          |   27 +-
+ include/linux/netfilter/Kbuild                     |    2 +
+ include/linux/netfilter/nf_conntrack_snmp.h        |    9 +
+ include/linux/netfilter/nfnetlink_conntrack.h      |    9 +
+ include/linux/netfilter/x_tables.h                 |    3 +-
+ include/linux/netfilter/xt_AUDIT.h                 |   30 +
+ include/linux/netfilter/xt_CT.h                    |   10 +-
+ include/linux/netfilter/xt_NFQUEUE.h               |    6 +
+ include/linux/netfilter/xt_TCPOPTSTRIP.h           |    2 +-
+ include/linux/netfilter/xt_TPROXY.h                |    8 +-
+ include/linux/netfilter/xt_cluster.h               |    8 +-
+ include/linux/netfilter/xt_comment.h               |    2 +-
+ include/linux/netfilter/xt_conntrack.h             |   15 +
+ include/linux/netfilter/xt_quota.h                 |    6 +-
+ include/linux/netfilter/xt_time.h                  |   14 +-
+ include/linux/netfilter/xt_u32.h                   |   16 +-
+ include/linux/netfilter_bridge/ebt_802_3.h         |   24 +-
+ include/linux/netfilter_bridge/ebt_among.h         |    2 +-
+ include/linux/netfilter_bridge/ebt_arp.h           |    4 +-
+ include/linux/netfilter_bridge/ebt_ip.h            |   12 +-
+ include/linux/netfilter_bridge/ebt_ip6.h           |   23 +-
+ include/linux/netfilter_bridge/ebt_limit.h         |    8 +-
+ include/linux/netfilter_bridge/ebt_log.h           |    6 +-
+ include/linux/netfilter_bridge/ebt_mark_m.h        |    4 +-
+ include/linux/netfilter_bridge/ebt_nflog.h         |   10 +-
+ include/linux/netfilter_bridge/ebt_pkttype.h       |    4 +-
+ include/linux/netfilter_bridge/ebt_stp.h           |   24 +-
+ include/linux/netfilter_bridge/ebt_ulog.h          |    2 +-
+ include/linux/netfilter_bridge/ebt_vlan.h          |    8 +-
+ include/linux/netfilter_ipv4/ipt_CLUSTERIP.h       |   14 +-
+ include/linux/netfilter_ipv4/ipt_ECN.h             |    6 +-
+ include/linux/netfilter_ipv4/ipt_SAME.h            |    6 +-
+ include/linux/netfilter_ipv4/ipt_TTL.h             |    4 +-
+ include/linux/netfilter_ipv4/ipt_addrtype.h        |   14 +-
+ include/linux/netfilter_ipv4/ipt_ah.h              |    4 +-
+ include/linux/netfilter_ipv4/ipt_ecn.h             |    8 +-
+ include/linux/netfilter_ipv4/ipt_ttl.h             |    4 +-
+ include/linux/netfilter_ipv6/ip6t_HL.h             |    4 +-
+ include/linux/netfilter_ipv6/ip6t_REJECT.h         |    2 +-
+ include/linux/netfilter_ipv6/ip6t_ah.h             |    8 +-
+ include/linux/netfilter_ipv6/ip6t_frag.h           |    8 +-
+ include/linux/netfilter_ipv6/ip6t_hl.h             |    4 +-
+ include/linux/netfilter_ipv6/ip6t_ipv6header.h     |    6 +-
+ include/linux/netfilter_ipv6/ip6t_mh.h             |    4 +-
+ include/linux/netfilter_ipv6/ip6t_opts.h           |   10 +-
+ include/linux/netfilter_ipv6/ip6t_rt.h             |   12 +-
+ include/linux/pkt_sched.h                          |   12 +
+ include/net/dst.h                                  |    2 +-
+ include/net/ip_fib.h                               |    6 +-
+ include/net/ip_vs.h                                |  295 ++++--
+ include/net/net_namespace.h                        |    2 +
+ include/net/netfilter/nf_conntrack.h               |   23 +-
+ include/net/netfilter/nf_conntrack_ecache.h        |   12 +-
+ include/net/netfilter/nf_conntrack_extend.h        |   10 +
+ include/net/netfilter/nf_conntrack_helper.h        |    6 +
+ include/net/netfilter/nf_conntrack_l3proto.h       |    2 +-
+ include/net/netfilter/nf_conntrack_timestamp.h     |   53 +
+ include/net/netfilter/nf_nat.h                     |    6 +
+ include/net/netfilter/nf_nat_core.h                |    4 +-
+ include/net/netns/conntrack.h                      |    4 +-
+ include/net/netns/ip_vs.h                          |  143 +++
+ include/net/netns/ipv4.h                           |    1 -
+ include/net/sock.h                                 |    2 +-
+ kernel/audit.c                                     |    2 +
+ net/9p/trans_rdma.c                                |    1 -
+ net/bridge/netfilter/ebt_ip6.c                     |   46 +-
+ net/bridge/netfilter/ebtables.c                    |    1 +
+ net/caif/cfcnfg.c                                  |    2 -
+ net/caif/cfdgml.c                                  |    1 -
+ net/caif/cfserl.c                                  |    1 -
+ net/caif/cfutill.c                                 |    2 +-
+ net/caif/cfveil.c                                  |    2 +-
+ net/core/dev.c                                     |   67 ++-
+ net/core/filter.c                                  |    6 +-
+ net/core/rtnetlink.c                               |   38 +-
+ net/decnet/dn_table.c                              |    1 -
+ net/ipv4/Kconfig                                   |    4 +-
+ net/ipv4/fib_rules.c                               |   10 +-
+ net/ipv4/fib_semantics.c                           |   14 +-
+ net/ipv4/ip_input.c                                |    2 +-
+ net/ipv4/netfilter/Kconfig                         |    3 +-
+ net/ipv4/netfilter/arp_tables.c                    |    2 +
+ net/ipv4/netfilter/ip_tables.c                     |    2 +
+ net/ipv4/netfilter/ipt_CLUSTERIP.c                 |    7 +-
+ net/ipv4/netfilter/ipt_LOG.c                       |    3 +-
+ .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |   17 +-
+ net/ipv4/netfilter/nf_nat_amanda.c                 |    8 +-
+ net/ipv4/netfilter/nf_nat_core.c                   |   15 +-
+ net/ipv4/netfilter/nf_nat_snmp_basic.c             |    9 +-
+ net/ipv4/route.c                                   |   26 +-
+ net/ipv6/netfilter/ip6_tables.c                    |    2 +
+ net/ipv6/netfilter/ip6t_LOG.c                      |    3 +-
+ net/ipv6/netfilter/nf_conntrack_reasm.c            |    2 +-
+ net/netfilter/Kconfig                              |   43 +-
+ net/netfilter/Makefile                             |    4 +
+ net/netfilter/core.c                               |   20 +-
+ net/netfilter/ipvs/ip_vs_app.c                     |   98 +-
+ net/netfilter/ipvs/ip_vs_conn.c                    |  195 ++--
+ net/netfilter/ipvs/ip_vs_core.c                    |  378 ++++--
+ net/netfilter/ipvs/ip_vs_ctl.c                     |  887 +++++++++------
+ net/netfilter/ipvs/ip_vs_est.c                     |  134 ++-
+ net/netfilter/ipvs/ip_vs_ftp.c                     |   61 +-
+ net/netfilter/ipvs/ip_vs_lblc.c                    |   67 +-
+ net/netfilter/ipvs/ip_vs_lblcr.c                   |   72 +-
+ net/netfilter/ipvs/ip_vs_nfct.c                    |    6 +-
+ net/netfilter/ipvs/ip_vs_pe.c                      |   17 +-
+ net/netfilter/ipvs/ip_vs_pe_sip.c                  |    3 +
+ net/netfilter/ipvs/ip_vs_proto.c                   |  125 ++-
+ net/netfilter/ipvs/ip_vs_proto_ah_esp.c            |   45 +-
+ net/netfilter/ipvs/ip_vs_proto_sctp.c              |  153 ++--
+ net/netfilter/ipvs/ip_vs_proto_tcp.c               |  142 ++--
+ net/netfilter/ipvs/ip_vs_proto_udp.c               |  110 +-
+ net/netfilter/ipvs/ip_vs_sync.c                    | 1235 ++++++++++++++++----
+ net/netfilter/ipvs/ip_vs_xmit.c                    |   26 +-
+ net/netfilter/nf_conntrack_broadcast.c             |   82 ++
+ net/netfilter/nf_conntrack_core.c                  |   57 +-
+ net/netfilter/nf_conntrack_expect.c                |   34 +-
+ net/netfilter/nf_conntrack_extend.c                |   11 +-
+ net/netfilter/nf_conntrack_helper.c                |   20 +-
+ net/netfilter/nf_conntrack_netbios_ns.c            |   74 +-
+ net/netfilter/nf_conntrack_netlink.c               |   47 +-
+ net/netfilter/nf_conntrack_proto.c                 |   24 +-
+ net/netfilter/nf_conntrack_proto_dccp.c            |    3 +
+ net/netfilter/nf_conntrack_proto_sctp.c            |    1 +
+ net/netfilter/nf_conntrack_proto_tcp.c             |   14 +-
+ net/netfilter/nf_conntrack_snmp.c                  |   77 ++
+ net/netfilter/nf_conntrack_standalone.c            |   45 +-
+ net/netfilter/nf_conntrack_timestamp.c             |  120 ++
+ net/netfilter/nf_log.c                             |    6 +-
+ net/netfilter/nf_queue.c                           |   82 +-
+ net/netfilter/nfnetlink_log.c                      |    6 +-
+ net/netfilter/nfnetlink_queue.c                    |   22 +-
+ net/netfilter/x_tables.c                           |   98 +-
+ net/netfilter/xt_AUDIT.c                           |  204 ++++
+ net/netfilter/xt_CLASSIFY.c                        |   36 +-
+ net/netfilter/xt_IDLETIMER.c                       |    2 +
+ net/netfilter/xt_LED.c                             |    2 +
+ net/netfilter/xt_NFQUEUE.c                         |   34 +-
+ net/netfilter/xt_connlimit.c                       |    6 +-
+ net/netfilter/xt_conntrack.c                       |   75 ++-
+ net/netfilter/xt_cpu.c                             |    2 +
+ net/netfilter/xt_ipvs.c                            |    2 +-
+ net/packet/af_packet.c                             |    7 +-
+ net/rds/rds.h                                      |    1 -
+ net/sched/Kconfig                                  |   17 +-
+ net/sched/Makefile                                 |    1 +
+ net/sched/act_api.c                                |   46 +-
+ net/sched/act_csum.c                               |    2 +-
+ net/sched/act_gact.c                               |    8 +-
+ net/sched/act_ipt.c                                |   16 +-
+ net/sched/act_mirred.c                             |    4 +-
+ net/sched/act_nat.c                                |    2 +-
+ net/sched/act_pedit.c                              |   10 +-
+ net/sched/act_police.c                             |    9 +-
+ net/sched/act_simple.c                             |   10 +-
+ net/sched/act_skbedit.c                            |    8 +-
+ net/sched/cls_api.c                                |   33 +-
+ net/sched/cls_basic.c                              |   17 +-
+ net/sched/cls_cgroup.c                             |    8 +-
+ net/sched/cls_flow.c                               |    6 +-
+ net/sched/cls_fw.c                                 |   38 +-
+ net/sched/cls_route.c                              |  126 ++-
+ net/sched/cls_rsvp.h                               |   95 +-
+ net/sched/cls_tcindex.c                            |    2 +-
+ net/sched/cls_u32.c                                |   77 +-
+ net/sched/em_cmp.c                                 |   47 +-
+ net/sched/em_meta.c                                |   44 +-
+ net/sched/em_nbyte.c                               |    3 +-
+ net/sched/em_text.c                                |    3 +-
+ net/sched/em_u32.c                                 |    2 +-
+ net/sched/ematch.c                                 |   37 +-
+ net/sched/sch_api.c                                |  137 ++-
+ net/sched/sch_atm.c                                |   16 +-
+ net/sched/sch_cbq.c                                |  358 +++---
+ net/sched/sch_dsmark.c                             |   21 +-
+ net/sched/sch_fifo.c                               |    9 +-
+ net/sched/sch_generic.c                            |   33 +-
+ net/sched/sch_gred.c                               |   85 +-
+ net/sched/sch_hfsc.c                               |   35 +-
+ net/sched/sch_htb.c                                |  104 +-
+ net/sched/sch_mqprio.c                             |  417 +++++++
+ net/sched/sch_multiq.c                             |    8 +-
+ net/sched/sch_netem.c                              |    6 +-
+ net/sched/sch_prio.c                               |   34 +-
+ net/sched/sch_red.c                                |   61 +-
+ net/sched/sch_sfq.c                                |   18 +-
+ net/sched/sch_tbf.c                                |   37 +-
+ net/sched/sch_teql.c                               |   36 +-
+ net/unix/af_unix.c                                 |   66 +-
+ net/wanrouter/wanmain.c                            |    2 -
+ 201 files changed, 6318 insertions(+), 2650 deletions(-)
+ create mode 100644 include/linux/netfilter/nf_conntrack_snmp.h
+ create mode 100644 include/linux/netfilter/xt_AUDIT.h
+ create mode 100644 include/net/netfilter/nf_conntrack_timestamp.h
+ create mode 100644 include/net/netns/ip_vs.h
+ create mode 100644 net/netfilter/nf_conntrack_broadcast.c
+ create mode 100644 net/netfilter/nf_conntrack_snmp.c
+ create mode 100644 net/netfilter/nf_conntrack_timestamp.c
+ create mode 100644 net/netfilter/xt_AUDIT.c
+ create mode 100644 net/sched/sch_mqprio.c
+$ git reset --hard HEAD^
+HEAD is now at 2e6182b Merge remote branch 'kvm/linux-next'
+Merging refs/next/20110120/net
+$ git merge refs/next/20110120/net
+Already up-to-date!
+Merge made by recursive.
+Merging wireless/master
+$ git merge wireless/master
+Auto-merging drivers/net/wireless/ath/ath9k/ar9002_calib.c
+Auto-merging drivers/net/wireless/ath/ath9k/htc.h
+Auto-merging net/mac80211/agg-rx.c
+Auto-merging net/mac80211/main.c
+Merge made by recursive.
+ drivers/net/wireless/ath/ar9170/main.c        |    3 +-
+ drivers/net/wireless/ath/ath.h                |    2 +
+ drivers/net/wireless/ath/ath5k/ahb.c          |    7 +-
+ drivers/net/wireless/ath/ath5k/eeprom.c       |   24 +-
+ drivers/net/wireless/ath/ath5k/eeprom.h       |    5 +-
+ drivers/net/wireless/ath/ath5k/pci.c          |    9 +-
+ drivers/net/wireless/ath/ath9k/ar9002_calib.c |    5 +-
+ drivers/net/wireless/ath/ath9k/ar9003_mac.c   |    8 +-
+ drivers/net/wireless/ath/ath9k/ath9k.h        |   23 ++-
+ drivers/net/wireless/ath/ath9k/beacon.c       |   14 +-
+ drivers/net/wireless/ath/ath9k/calib.c        |    5 +-
+ drivers/net/wireless/ath/ath9k/eeprom.c       |   32 ++
+ drivers/net/wireless/ath/ath9k/eeprom.h       |    2 +
+ drivers/net/wireless/ath/ath9k/eeprom_4k.c    |   41 ++-
+ drivers/net/wireless/ath/ath9k/eeprom_9287.c  |   45 ++-
+ drivers/net/wireless/ath/ath9k/eeprom_def.c   |   32 ++-
+ drivers/net/wireless/ath/ath9k/htc.h          |    2 +-
+ drivers/net/wireless/ath/ath9k/htc_drv_init.c |   29 ++
+ drivers/net/wireless/ath/ath9k/htc_drv_main.c |    9 +-
+ drivers/net/wireless/ath/ath9k/hw.h           |    3 +
+ drivers/net/wireless/ath/ath9k/mac.c          |   14 +-
+ drivers/net/wireless/ath/ath9k/main.c         |  323 +++++++++++++-----
+ drivers/net/wireless/ath/ath9k/recv.c         |   16 +-
+ drivers/net/wireless/ath/ath9k/virtual.c      |   48 ---
+ drivers/net/wireless/ath/ath9k/xmit.c         |   18 +-
+ drivers/net/wireless/ath/carl9170/main.c      |    2 +-
+ drivers/net/wireless/iwlwifi/iwl-agn.c        |    3 +-
+ drivers/net/wireless/iwlwifi/iwl-agn.h        |    3 +-
+ drivers/net/wireless/mac80211_hwsim.c         |    3 +-
+ drivers/net/wireless/mwl8k.c                  |  450 ++++++++++++++++++++++++-
+ drivers/net/wireless/rt2x00/rt2800.h          |    6 +
+ drivers/net/wireless/rt2x00/rt2800lib.c       |   34 +-
+ drivers/net/wireless/rt2x00/rt2800lib.h       |    3 +-
+ drivers/net/wireless/rt2x00/rt2800pci.c       |   36 +--
+ drivers/net/wireless/rtlwifi/core.c           |    3 +-
+ include/net/mac80211.h                        |   20 +-
+ net/mac80211/agg-rx.c                         |    7 +-
+ net/mac80211/agg-tx.c                         |   23 +-
+ net/mac80211/driver-ops.h                     |    6 +-
+ net/mac80211/driver-trace.h                   |   11 +-
+ net/mac80211/main.c                           |    1 +
+ net/mac80211/mesh.c                           |    2 +-
+ net/mac80211/mlme.c                           |    8 +-
+ net/mac80211/rx.c                             |   25 ++-
+ net/mac80211/sta_info.h                       |    2 +
+ net/mac80211/tx.c                             |   17 +-
+ 46 files changed, 1070 insertions(+), 314 deletions(-)
+Merging bluetooth/master
+$ git merge bluetooth/master
+Merge made by recursive.
+ net/bluetooth/mgmt.c |    4 +++-
+ 1 files changed, 3 insertions(+), 1 deletions(-)
+Merging mtd/master
+$ git merge mtd/master
+Already up-to-date.
+Merging crypto/master
+$ git merge crypto/master
+Already up-to-date.
+Merging sound/for-next
+$ git merge sound/for-next
+Merge made by recursive.
+ Documentation/sound/alsa/soc/codec.txt    |   45 +++++++++++++---------------
+ Documentation/sound/alsa/soc/machine.txt  |   38 ++++++------------------
+ Documentation/sound/alsa/soc/platform.txt |   12 ++++++-
+ sound/pci/hda/patch_realtek.c             |   26 +++++++++++------
+ sound/pci/ice1712/delta.c                 |    7 ++++
+ sound/soc/blackfin/Kconfig                |   11 ++++---
+ sound/soc/blackfin/bf5xx-ac97.c           |    4 +-
+ sound/soc/blackfin/bf5xx-tdm.c            |   10 +++---
+ sound/soc/pxa/z2.c                        |    3 +-
+ 9 files changed, 79 insertions(+), 77 deletions(-)
+Merging sound-asoc/for-next
+$ git merge sound-asoc/for-next
+Removing sound/soc/samsung/ac97.h
+Merge made by recursive.
+ include/sound/soc-dapm.h                       |   16 +
+ include/sound/soc.h                            |   49 +-
+ sound/soc/Kconfig                              |    2 +
+ sound/soc/Makefile                             |    2 +
+ sound/soc/codecs/Kconfig                       |    8 +
+ sound/soc/codecs/Makefile                      |    4 +
+ sound/soc/codecs/cs4270.c                      |    4 +-
+ sound/soc/codecs/max98088.c                    |    2 +-
+ sound/soc/codecs/sn95031.c                     |  495 ++++++++
+ sound/soc/codecs/sn95031.h                     |   99 ++
+ sound/soc/codecs/wm8523.c                      |    8 +-
+ sound/soc/codecs/wm8741.c                      |   13 +-
+ sound/soc/codecs/wm8804.c                      |    2 +-
+ sound/soc/codecs/wm8900.c                      |    2 +-
+ sound/soc/codecs/wm8903.c                      |    2 +-
+ sound/soc/codecs/wm8904.c                      |   43 +-
+ sound/soc/codecs/wm8955.c                      |   27 +-
+ sound/soc/codecs/wm8961.c                      |    2 +-
+ sound/soc/codecs/wm8962.c                      |   34 +-
+ sound/soc/codecs/wm8978.c                      |    2 +-
+ sound/soc/codecs/wm8991.c                      | 1427 ++++++++++++++++++++++++
+ sound/soc/codecs/wm8991.h                      |  833 ++++++++++++++
+ sound/soc/codecs/wm8993.c                      |    2 +-
+ sound/soc/codecs/wm8994.c                      |   12 +-
+ sound/soc/codecs/wm8995.c                      |  105 ++-
+ sound/soc/codecs/wm9081.c                      |    2 +-
+ sound/soc/codecs/wm9090.c                      |   45 +-
+ sound/soc/mid-x86/Kconfig                      |   14 +
+ sound/soc/mid-x86/Makefile                     |    5 +
+ sound/soc/mid-x86/mfld_machine.c               |  296 +++++
+ sound/soc/mid-x86/sst_platform.c               |  459 ++++++++
+ sound/soc/mid-x86/sst_platform.h               |   63 ++
+ sound/soc/samsung/ac97.c                       |    8 +-
+ sound/soc/samsung/ac97.h                       |   21 -
+ sound/soc/samsung/dma.c                        |   11 +-
+ sound/soc/samsung/dma.h                        |    8 -
+ sound/soc/samsung/goni_wm8994.c                |   10 +-
+ sound/soc/samsung/h1940_uda1380.c              |    9 -
+ sound/soc/samsung/i2s.c                        |    3 +-
+ sound/soc/samsung/jive_wm8750.c                |   11 -
+ sound/soc/samsung/ln2440sbc_alc650.c           |    7 -
+ sound/soc/samsung/neo1973_gta02_wm8753.c       |   14 +-
+ sound/soc/samsung/pcm.c                        |  118 ++-
+ sound/soc/samsung/pcm.h                        |  107 --
+ sound/soc/samsung/rx1950_uda1380.c             |   11 -
+ sound/soc/samsung/s3c-i2s-v2.c                 |    3 +-
+ sound/soc/samsung/s3c2412-i2s.c                |   12 +-
+ sound/soc/samsung/s3c24xx-i2s.c                |   14 +-
+ sound/soc/samsung/s3c24xx_simtec.c             |    7 -
+ sound/soc/samsung/s3c24xx_simtec_hermes.c      |   10 -
+ sound/soc/samsung/s3c24xx_simtec_tlv320aic23.c |   12 -
+ sound/soc/samsung/s3c24xx_uda134x.c            |    9 +-
+ sound/soc/samsung/smartq_wm8987.c              |    6 -
+ sound/soc/samsung/smdk2443_wm9710.c            |    7 -
+ sound/soc/samsung/smdk_spdif.c                 |    5 -
+ sound/soc/samsung/smdk_wm8580.c                |    7 +-
+ sound/soc/samsung/smdk_wm9713.c                |    5 -
+ sound/soc/samsung/spdif.c                      |    3 +-
+ sound/soc/sh/fsi-ak4642.c                      |   11 +-
+ sound/soc/soc-cache.c                          |  357 +++----
+ sound/soc/soc-core.c                           |  166 ++--
+ sound/soc/soc-dapm.c                           |   64 +-
+ sound/soc/tegra/Kconfig                        |   26 +
+ sound/soc/tegra/Makefile                       |   14 +
+ sound/soc/tegra/harmony.c                      |  210 ++++
+ sound/soc/tegra/tegra_asoc_utils.c             |  152 +++
+ sound/soc/tegra/tegra_asoc_utils.h             |   31 +
+ sound/soc/tegra/tegra_das.c                    |  264 +++++
+ sound/soc/tegra/tegra_das.h                    |  135 +++
+ sound/soc/tegra/tegra_i2s.c                    |  502 +++++++++
+ sound/soc/tegra/tegra_i2s.h                    |  165 +++
+ sound/soc/tegra/tegra_pcm.c                    |  401 +++++++
+ sound/soc/tegra/tegra_pcm.h                    |   55 +
+ 73 files changed, 6393 insertions(+), 677 deletions(-)
+ create mode 100644 sound/soc/codecs/sn95031.c
+ create mode 100644 sound/soc/codecs/sn95031.h
+ create mode 100644 sound/soc/codecs/wm8991.c
+ create mode 100644 sound/soc/codecs/wm8991.h
+ create mode 100644 sound/soc/mid-x86/Kconfig
+ create mode 100644 sound/soc/mid-x86/Makefile
+ create mode 100644 sound/soc/mid-x86/mfld_machine.c
+ create mode 100644 sound/soc/mid-x86/sst_platform.c
+ create mode 100644 sound/soc/mid-x86/sst_platform.h
+ delete mode 100644 sound/soc/samsung/ac97.h
+ create mode 100644 sound/soc/tegra/Kconfig
+ create mode 100644 sound/soc/tegra/Makefile
+ create mode 100644 sound/soc/tegra/harmony.c
+ create mode 100644 sound/soc/tegra/tegra_asoc_utils.c
+ create mode 100644 sound/soc/tegra/tegra_asoc_utils.h
+ create mode 100644 sound/soc/tegra/tegra_das.c
+ create mode 100644 sound/soc/tegra/tegra_das.h
+ create mode 100644 sound/soc/tegra/tegra_i2s.c
+ create mode 100644 sound/soc/tegra/tegra_i2s.h
+ create mode 100644 sound/soc/tegra/tegra_pcm.c
+ create mode 100644 sound/soc/tegra/tegra_pcm.h
+Merging cpufreq/next
+$ git merge cpufreq/next
+Merge made by recursive.
+ drivers/cpufreq/cpufreq_conservative.c |    2 +-
+ 1 files changed, 1 insertions(+), 1 deletions(-)
+Merging quilt/rr
+$ git merge quilt/rr
+Merge made by recursive.
+ Documentation/lguest/lguest.c     |   73 +++++++++++++++++++++++++++++++++----
+ Documentation/lguest/lguest.txt   |    5 +++
+ arch/x86/lguest/Kconfig           |    1 +
+ arch/x86/lguest/boot.c            |    2 +-
+ drivers/lguest/page_tables.c      |    2 +-
+ drivers/lguest/x86/core.c         |    4 +-
+ drivers/net/arm/ks8695net.c       |    2 +-
+ drivers/virtio/virtio_pci.c       |   20 +---------
+ include/asm-generic/vmlinux.lds.h |    7 ++++
+ include/linux/gfp.h               |    2 +-
+ include/linux/kernel.h            |   32 +++++++++++++---
+ include/linux/kmemcheck.h         |    2 +-
+ include/linux/module.h            |   27 ++++++++++++++
+ include/linux/moduleparam.h       |    6 ++-
+ include/linux/virtio_config.h     |    5 ++-
+ kernel/params.c                   |   65 +++++++++++++++++++++++++++------
+ net/dsa/dsa.c                     |    2 +-
+ 17 files changed, 203 insertions(+), 54 deletions(-)
+Merging input/next
+$ git merge input/next
+Already up-to-date.
+Merging input-mt/next
+$ git merge input-mt/next
+Already up-to-date.
+Merging lsm/for-next
+$ git merge lsm/for-next
+Already up-to-date.
+Merging block/for-next
+$ git merge block/for-next
+Already up-to-date.
+Merging quilt/device-mapper
+$ git merge quilt/device-mapper
+Already up-to-date.
+Merging embedded/master
+$ git merge embedded/master
+Already up-to-date.
+Merging firmware/master
+$ git merge firmware/master
+Already up-to-date.
+Merging pcmcia/master
+$ git merge pcmcia/master
+Already up-to-date.
+Merging battery/master
+$ git merge battery/master
+Already up-to-date.
+Merging leds/for-mm
+$ git merge leds/for-mm
+Resolved 'drivers/leds/Kconfig' using previous resolution.
+Auto-merging drivers/leds/Kconfig
+CONFLICT (content): Merge conflict in drivers/leds/Kconfig
+Auto-merging drivers/leds/leds-gpio.c
+Automatic merge failed; fix conflicts and then commit the result.
+$ git commit -v -a
+[master acad0a4] Merge remote branch 'leds/for-mm'
+$ git diff -M --stat --summary HEAD^..
+Merging backlight/for-mm
+$ git merge backlight/for-mm
+Already up-to-date.
+Merging mmc/mmc-next
+$ git merge mmc/mmc-next
+Merge made by recursive.
+ drivers/mmc/host/bfin_sdh.c   |    2 +-
+ drivers/mmc/host/jz4740_mmc.c |    5 +++--
+ drivers/mmc/host/mmci.c       |   10 +++++-----
+ drivers/mmc/host/sdhci-s3c.c  |   36 ++++++++++++++++++++++++++++++++++++
+ drivers/mmc/host/ushc.c       |    1 -
+ 5 files changed, 45 insertions(+), 9 deletions(-)
+Merging kgdb/kgdb-next
+$ git merge kgdb/kgdb-next
+Renaming drivers/serial/kgdboc.c => drivers/tty/serial/kgdboc.c
+Auto-merging drivers/tty/serial/kgdboc.c
+Auto-merging arch/x86/kernel/kgdb.c
+Auto-merging kernel/debug/kdb/kdb_main.c
+Merge made by recursive.
+ arch/x86/kernel/kgdb.c      |    4 ++--
+ drivers/misc/kgdbts.c       |    2 +-
+ drivers/tty/serial/kgdboc.c |    2 +-
+ kernel/debug/kdb/kdb_main.c |    2 +-
+ 4 files changed, 5 insertions(+), 5 deletions(-)
+Merging slab/for-next
+$ git merge slab/for-next
+Already up-to-date!
+Merge made by recursive.
+Merging uclinux/for-next
+$ git merge uclinux/for-next
+Already up-to-date.
+Merging md/for-next
+$ git merge md/for-next
+Auto-merging drivers/md/md.c
+Merge made by recursive.
+ drivers/md/md.c    |    2 +
+ drivers/md/raid5.c |   60 ++++++++++++++++++++++++++--------------------------
+ 2 files changed, 32 insertions(+), 30 deletions(-)
+Merging mfd/for-next
+$ git merge mfd/for-next
+Already up-to-date.
+Merging hdlc/hdlc-next
+$ git merge hdlc/hdlc-next
+Already up-to-date.
+Merging drm/drm-next
+$ git merge drm/drm-next
+Already up-to-date.
+Merging fbdev/master
+$ git merge fbdev/master
+Merge made by recursive.
+ drivers/video/nuc900fb.c   |    6 ++++--
+ drivers/video/pxa3xx-gcu.c |    4 ++--
+ 2 files changed, 6 insertions(+), 4 deletions(-)
+Merging viafb/viafb-next
+$ git merge viafb/viafb-next
+Already up-to-date.
+Merging omap_dss2/for-next
+$ git merge omap_dss2/for-next
+Already up-to-date.
+Merging voltage/for-next
+$ git merge voltage/for-next
+Already up-to-date.
+Merging security-testing/next
+$ git merge security-testing/next
+Merge made by recursive.
+ include/linux/xattr.h         |    2 +
+ security/smack/smack.h        |    9 +-
+ security/smack/smack_access.c |   52 ++++--
+ security/smack/smack_lsm.c    |  269 +++++++++++++++++++++++++-----
+ security/smack/smackfs.c      |  370 ++++++++++++++++++++++++++++-------------
+ 5 files changed, 524 insertions(+), 178 deletions(-)
+Merging selinux/master
+$ git merge selinux/master
+Already up-to-date.
+Merging lblnet/master
+$ git merge lblnet/master
+Already up-to-date.
+Merging agp/agp-next
+$ git merge agp/agp-next
+Auto-merging drivers/char/agp/backend.c
+Auto-merging drivers/char/agp/hp-agp.c
+Merge made by recursive.
+Merging watchdog/master
+$ git merge watchdog/master
+Merge made by recursive.
+ arch/mips/include/asm/mach-jz4740/platform.h |    1 +
+ arch/mips/jz4740/platform.c                  |   16 ++
+ drivers/watchdog/Kconfig                     |    6 +
+ drivers/watchdog/Makefile                    |    1 +
+ drivers/watchdog/booke_wdt.c                 |   17 +-
+ drivers/watchdog/jz4740_wdt.c                |  322 ++++++++++++++++++++++++++
+ 6 files changed, 354 insertions(+), 9 deletions(-)
+ create mode 100644 drivers/watchdog/jz4740_wdt.c
+Merging bdev/master
+$ git merge bdev/master
+Already up-to-date.
+Merging dwmw2-iommu/master
+$ git merge dwmw2-iommu/master
+Merge made by recursive.
+ drivers/pci/intel-iommu.c |    2 +-
+ 1 files changed, 1 insertions(+), 1 deletions(-)
+Merging cputime/cputime
+$ git merge cputime/cputime
+Already up-to-date.
+Merging osd/linux-next
+$ git merge osd/linux-next
+Already up-to-date.
+Merging jc_docs/docs-next
+$ git merge jc_docs/docs-next
+Already up-to-date.
+Merging nommu/master
+$ git merge nommu/master
+Already up-to-date.
+Merging trivial/for-next
+$ git merge trivial/for-next
+Auto-merging Documentation/device-mapper/dm-crypt.txt
+Auto-merging init/Kconfig
+Auto-merging net/mac80211/tx.c
+Merge made by recursive.
+ Documentation/device-mapper/dm-crypt.txt |    2 +-
+ arch/x86/oprofile/op_model_p4.c          |    2 +-
+ arch/xtensa/configs/s6105_defconfig      |    2 +-
+ drivers/bluetooth/btusb.c                |    4 ++--
+ drivers/cpuidle/sysfs.c                  |    2 +-
+ drivers/dma/shdma.c                      |    2 +-
+ drivers/edac/i7300_edac.c                |    2 +-
+ drivers/gpu/drm/drm_sman.c               |    4 +---
+ drivers/message/i2o/i2o_config.c         |    3 +--
+ drivers/net/atl1c/atl1c.h                |    4 ++--
+ drivers/net/sungem.h                     |    2 +-
+ drivers/scsi/aic7xxx/aic79xx.h           |    2 +-
+ drivers/scsi/aic7xxx/aic7xxx.h           |    2 +-
+ drivers/scsi/aic7xxx/aic7xxx_core.c      |    2 +-
+ drivers/scsi/osst.c                      |   10 ++++------
+ drivers/usb/wusbcore/rh.c                |    2 +-
+ fs/direct-io.c                           |    6 +++---
+ fs/ocfs2/dir.c                           |    2 +-
+ init/Kconfig                             |    6 +++---
+ kernel/trace/ring_buffer.c               |    2 +-
+ net/ipv6/inet6_hashtables.c              |    2 +-
+ net/mac80211/tx.c                        |    2 +-
+ sound/pci/au88x0/au88x0.h                |    4 ++--
+ sound/pci/au88x0/au88x0_core.c           |    4 ++--
+ 24 files changed, 35 insertions(+), 40 deletions(-)
+Merging audit/for-next
+$ git merge audit/for-next
+Already up-to-date.
+Merging suspend/linux-next
+$ git merge suspend/linux-next
+Already up-to-date.
+Merging fsnotify/for-next
+$ git merge fsnotify/for-next
+Auto-merging fs/nfsd/vfs.c
+Auto-merging include/linux/fsnotify_backend.h
+Merge made by recursive.
+ fs/cachefiles/namei.c              |    1 -
+ fs/cachefiles/xattr.c              |    1 -
+ fs/nfsd/vfs.c                      |    3 -
+ fs/notify/dnotify/dnotify.c        |   15 +++---
+ fs/notify/fanotify/fanotify.c      |   24 +++++----
+ fs/notify/fanotify/fanotify_user.c |  101 +++++++++++++++++++++++++-----------
+ fs/notify/group.c                  |    1 +
+ fs/notify/mark.c                   |   36 +++++--------
+ include/linux/fanotify.h           |    5 ++-
+ include/linux/fsnotify_backend.h   |   14 ++++-
+ 10 files changed, 121 insertions(+), 80 deletions(-)
+Merging irda/for-next
+$ git merge irda/for-next
+Already up-to-date.
+Merging catalin/for-next
+$ git merge catalin/for-next
+Already up-to-date.
+Merging alacrity/linux-next
+$ git merge alacrity/linux-next
+Resolved 'drivers/Makefile' using previous resolution.
+Resolved 'include/linux/Kbuild' using previous resolution.
+Resolved 'lib/Kconfig' using previous resolution.
+Auto-merging MAINTAINERS
+Auto-merging arch/x86/Kconfig
+Auto-merging drivers/Makefile
+CONFLICT (content): Merge conflict in drivers/Makefile
+Auto-merging drivers/net/Kconfig
+Auto-merging drivers/net/Makefile
+Auto-merging include/linux/Kbuild
+CONFLICT (content): Merge conflict in include/linux/Kbuild
+Auto-merging lib/Kconfig
+CONFLICT (content): Merge conflict in lib/Kconfig
+Auto-merging lib/Makefile
+Automatic merge failed; fix conflicts and then commit the result.
+$ git commit -v -a
+[master 9676f44] Merge remote branch 'alacrity/linux-next'
+$ git diff -M --stat --summary HEAD^..
+ MAINTAINERS                 |   25 +
+ arch/x86/Kconfig            |    2 +
+ drivers/Makefile            |    1 +
+ drivers/net/Kconfig         |   14 +
+ drivers/net/Makefile        |    1 +
+ drivers/net/vbus-enet.c     | 1560 +++++++++++++++++++++++++++++++++++++++++++
+ drivers/vbus/Kconfig        |   25 +
+ drivers/vbus/Makefile       |    6 +
+ drivers/vbus/bus-proxy.c    |  248 +++++++
+ drivers/vbus/pci-bridge.c   | 1016 ++++++++++++++++++++++++++++
+ include/linux/Kbuild        |    4 +
+ include/linux/ioq.h         |  414 ++++++++++++
+ include/linux/shm_signal.h  |  189 ++++++
+ include/linux/vbus_driver.h |   83 +++
+ include/linux/vbus_pci.h    |  145 ++++
+ include/linux/venet.h       |  133 ++++
+ lib/Kconfig                 |   21 +
+ lib/Makefile                |    2 +
+ lib/ioq.c                   |  304 +++++++++
+ lib/shm_signal.c            |  196 ++++++
+ 20 files changed, 4389 insertions(+), 0 deletions(-)
+ create mode 100644 drivers/net/vbus-enet.c
+ create mode 100644 drivers/vbus/Kconfig
+ create mode 100644 drivers/vbus/Makefile
+ create mode 100644 drivers/vbus/bus-proxy.c
+ create mode 100644 drivers/vbus/pci-bridge.c
+ create mode 100644 include/linux/ioq.h
+ create mode 100644 include/linux/shm_signal.h
+ create mode 100644 include/linux/vbus_driver.h
+ create mode 100644 include/linux/vbus_pci.h
+ create mode 100644 include/linux/venet.h
+ create mode 100644 lib/ioq.c
+ create mode 100644 lib/shm_signal.c
+Merging i7core_edac/linux_next
+$ git merge i7core_edac/linux_next
+Auto-merging drivers/edac/i7core_edac.c
+Merge made by recursive.
+ drivers/edac/i7core_edac.c |   23 ++++++++++++++++++++---
+ 1 files changed, 20 insertions(+), 3 deletions(-)
+Merging i7300_edac/linux_next
+$ git merge i7300_edac/linux_next
+Already up-to-date!
+Merge made by recursive.
+Merging devicetree/devicetree/next
+$ git merge devicetree/devicetree/next
+Already up-to-date.
+Merging spi/spi/next
+$ git merge spi/spi/next
+Already up-to-date.
+Merging tip/auto-latest
+$ git merge tip/auto-latest
+Merge made by recursive.
+ kernel/sched.c           |    8 +++-----
+ kernel/sched_autogroup.c |   32 ++++++++++++++++++++++++++++++++
+ kernel/sched_autogroup.h |    4 ++++
+ kernel/sched_debug.c     |   42 +++++++++++++++++++++++++++++++++++++++++-
+ kernel/sched_fair.c      |   35 +++++++++++++++++++----------------
+ 5 files changed, 99 insertions(+), 22 deletions(-)
+Merging rcu/rcu/next
+$ git merge rcu/rcu/next
+Already up-to-date.
+Merging oprofile/for-next
+$ git merge oprofile/for-next
+Already up-to-date!
+Merge made by recursive.
+Merging swiotlb-xen/master
+$ git merge swiotlb-xen/master
+Merge made by recursive.
+ arch/x86/xen/irq.c            |    2 +-
+ arch/x86/xen/p2m.c            |   20 +++++++++++++++++++-
+ drivers/clocksource/acpi_pm.c |    6 +++++-
+ 3 files changed, 25 insertions(+), 3 deletions(-)
+Merging xen-pvhvm/linux-next
+$ git merge xen-pvhvm/linux-next
+Resolved 'arch/x86/include/asm/xen/page.h' using previous resolution.
+Auto-merging arch/x86/include/asm/xen/page.h
+CONFLICT (content): Merge conflict in arch/x86/include/asm/xen/page.h
+Auto-merging arch/x86/xen/enlighten.c
+Auto-merging arch/x86/xen/mmu.c
+Auto-merging include/xen/interface/memory.h
+Automatic merge failed; fix conflicts and then commit the result.
+$ git commit -v -a
+[master 1c67313] Merge remote branch 'xen-pvhvm/linux-next'
+$ git diff -M --stat --summary HEAD^..
+Merging edac-amd/for-next
+$ git merge edac-amd/for-next
+Auto-merging drivers/edac/edac_core.h
+Merge made by recursive.
+Merging percpu/for-next
+$ git merge percpu/for-next
+Merge made by recursive.
+ arch/x86/include/asm/percpu.h |    8 ++++----
+ 1 files changed, 4 insertions(+), 4 deletions(-)
+Merging workqueues/for-next
+$ git merge workqueues/for-next
+Merge made by recursive.
+ include/linux/lockdep.h |    3 +++
+ kernel/workqueue.c      |   20 +++++++++++++++++---
+ 2 files changed, 20 insertions(+), 3 deletions(-)
+Merging sfi/sfi-test
+$ git merge sfi/sfi-test
+Already up-to-date.
+Merging asm-generic/next
+$ git merge asm-generic/next
+Already up-to-date.
+Merging drivers-x86/linux-next
+$ git merge drivers-x86/linux-next
+Already up-to-date.
+Merging hwpoison/hwpoison
+$ git merge hwpoison/hwpoison
+Already up-to-date.
+Merging sysctl/master
+$ git merge sysctl/master
+Already up-to-date.
+Merging driver-core/driver-core-next
+$ git merge driver-core/driver-core-next
+Already up-to-date.
+Merging tty/tty-next
+$ git merge tty/tty-next
+Already up-to-date.
+Merging usb/usb-next
+$ git merge usb/usb-next
+Already up-to-date.
+Merging staging/staging-next
+$ git merge staging/staging-next
+Removing drivers/staging/brcm80211/include/packed_section_end.h
+Removing drivers/staging/brcm80211/include/packed_section_start.h
+Removing drivers/staging/brcm80211/include/proto/ethernet.h
+Removing drivers/staging/brcm80211/include/proto/wpa.h
+Merge made by recursive.
+ drivers/staging/brcm80211/brcmfmac/dhd.h           |    4 +-
+ drivers/staging/brcm80211/brcmfmac/dhd_cdc.c       |    2 +-
+ drivers/staging/brcm80211/brcmfmac/dhd_common.c    |   10 +-
+ .../staging/brcm80211/brcmfmac/dhd_custom_gpio.c   |    4 +-
+ drivers/staging/brcm80211/brcmfmac/dhd_linux.c     |   28 +-
+ drivers/staging/brcm80211/brcmfmac/dhd_sdio.c      |    1 -
+ drivers/staging/brcm80211/brcmfmac/wl_cfg80211.c   |   20 +-
+ drivers/staging/brcm80211/brcmfmac/wl_cfg80211.h   |    3 +-
+ drivers/staging/brcm80211/brcmfmac/wl_iw.c         |  110 +++--
+ drivers/staging/brcm80211/brcmfmac/wl_iw.h         |    3 +-
+ drivers/staging/brcm80211/include/bcmcdc.h         |    4 +-
+ drivers/staging/brcm80211/include/bcmutils.h       |    9 +-
+ drivers/staging/brcm80211/include/bcmwifi.h        |   18 -
+ drivers/staging/brcm80211/include/d11.h            |   36 +-
+ drivers/staging/brcm80211/include/dhdioctl.h       |    7 -
+ drivers/staging/brcm80211/include/msgtrace.h       |   10 +-
+ .../staging/brcm80211/include/packed_section_end.h |   32 --
+ .../brcm80211/include/packed_section_start.h       |   36 --
+ drivers/staging/brcm80211/include/proto/802.11.h   |  117 +-----
+ drivers/staging/brcm80211/include/proto/bcmeth.h   |    8 +-
+ drivers/staging/brcm80211/include/proto/bcmevent.h |   16 +-
+ drivers/staging/brcm80211/include/proto/ethernet.h |   72 ---
+ drivers/staging/brcm80211/include/proto/wpa.h      |   33 --
+ drivers/staging/brcm80211/include/sdiovar.h        |    6 -
+ drivers/staging/brcm80211/include/wlioctl.h        |   33 +-
+ drivers/staging/brcm80211/sys/wl_mac80211.c        |    2 +-
+ drivers/staging/brcm80211/sys/wlc_alloc.c          |    6 +-
+ drivers/staging/brcm80211/sys/wlc_ampdu.c          |   35 +-
+ drivers/staging/brcm80211/sys/wlc_bmac.c           |   37 +-
+ drivers/staging/brcm80211/sys/wlc_bmac.h           |    8 +-
+ drivers/staging/brcm80211/sys/wlc_bsscfg.h         |    6 +-
+ drivers/staging/brcm80211/sys/wlc_key.h            |    2 +-
+ drivers/staging/brcm80211/sys/wlc_mac80211.c       |  235 ++++++-----
+ drivers/staging/brcm80211/sys/wlc_mac80211.h       |   13 +-
+ drivers/staging/brcm80211/sys/wlc_pub.h            |   17 +-
+ drivers/staging/brcm80211/sys/wlc_scb.h            |    2 +-
+ drivers/staging/brcm80211/sys/wlc_stf.c            |   11 +-
+ drivers/staging/brcm80211/util/bcmsrom.c           |   18 +-
+ drivers/staging/brcm80211/util/bcmutils.c          |    5 +-
+ drivers/staging/brcm80211/util/bcmwifi.c           |   30 --
+ drivers/staging/hv/Makefile                        |    1 +
+ drivers/staging/hv/blkvsc.c                        |    2 +-
+ drivers/staging/hv/channel.c                       |    6 +-
+ drivers/staging/hv/channel_mgmt.c                  |   23 +-
+ drivers/staging/hv/hv.c                            |    4 +-
+ drivers/staging/hv/hv_kvp.c                        |  346 ++++++++++++++
+ drivers/staging/hv/hv_kvp.h                        |  184 ++++++++
+ drivers/staging/hv/{hv_utils.c => hv_util.c}       |   14 +
+ drivers/staging/hv/osd.h                           |   10 +-
+ drivers/staging/hv/storvsc.c                       |    6 +-
+ drivers/staging/hv/storvsc_drv.c                   |    4 +-
+ drivers/staging/hv/tools/hv_kvp_daemon.c           |  470 ++++++++++++++++++++
+ drivers/staging/hv/utils.h                         |    1 +
+ include/linux/connector.h                          |    3 +-
+ 54 files changed, 1410 insertions(+), 713 deletions(-)
+ delete mode 100644 drivers/staging/brcm80211/include/packed_section_end.h
+ delete mode 100644 drivers/staging/brcm80211/include/packed_section_start.h
+ delete mode 100644 drivers/staging/brcm80211/include/proto/ethernet.h
+ delete mode 100644 drivers/staging/brcm80211/include/proto/wpa.h
+ create mode 100644 drivers/staging/hv/hv_kvp.c
+ create mode 100644 drivers/staging/hv/hv_kvp.h
+ rename drivers/staging/hv/{hv_utils.c => hv_util.c} (97%)
+ create mode 100644 drivers/staging/hv/tools/hv_kvp_daemon.c
+Merging slabh/slabh
+$ git merge slabh/slabh
+Already up-to-date.
+Merging bkl-trivial/trivial
+$ git merge bkl-trivial/trivial
+Already up-to-date.
+Merging bkl-llseek/llseek
+$ git merge bkl-llseek/llseek
+Already up-to-date.
+Merging bkl-vfs/vfs
+$ git merge bkl-vfs/vfs
+Already up-to-date.
+Merging bkl-config/config
+$ git merge bkl-config/config
+Resolved 'arch/powerpc/kernel/setup_64.c' using previous resolution.
+Resolved 'fs/nfsd/nfs4state.c' using previous resolution.
+Resolved 'include/linux/hardirq.h' using previous resolution.
+Resolved 'include/linux/smp_lock.h' using previous resolution.
+Auto-merging arch/powerpc/kernel/setup_64.c
+CONFLICT (content): Merge conflict in arch/powerpc/kernel/setup_64.c
+Auto-merging arch/tile/kernel/compat.c
+Auto-merging arch/tile/kernel/compat_signal.c
+Auto-merging arch/tile/kernel/signal.c
+Auto-merging block/compat_ioctl.c
+Auto-merging block/ioctl.c
+Auto-merging drivers/block/drbd/drbd_receiver.c
+Auto-merging drivers/block/drbd/drbd_worker.c
+Auto-merging drivers/char/agp/frontend.c
+Auto-merging drivers/char/amiserial.c
+Auto-merging drivers/char/specialix.c
+Auto-merging drivers/gpu/drm/Kconfig
+Auto-merging drivers/gpu/drm/drm_fops.c
+Auto-merging drivers/hid/hidraw.c
+Auto-merging drivers/hid/usbhid/hiddev.c
+Auto-merging drivers/infiniband/hw/ipath/ipath_file_ops.c
+Auto-merging drivers/input/input.c
+Auto-merging drivers/media/dvb/ngene/ngene-core.c
+Auto-merging drivers/media/dvb/ngene/ngene-dvb.c
+Auto-merging drivers/media/radio/si470x/radio-si470x.h
+Auto-merging drivers/media/video/bt8xx/bttv-driver.c
+Auto-merging drivers/media/video/cx88/cx88-blackbird.c
+Auto-merging drivers/media/video/cx88/cx88-video.c
+Auto-merging drivers/media/video/pwc/pwc-if.c
+Auto-merging drivers/media/video/s2255drv.c
+Auto-merging drivers/media/video/saa7134/saa7134-empress.c
+Auto-merging drivers/media/video/saa7164/saa7164.h
+Auto-merging drivers/media/video/usbvision/usbvision-video.c
+Auto-merging drivers/media/video/v4l2-compat-ioctl32.c
+Auto-merging drivers/pci/proc.c
+Auto-merging drivers/s390/block/dasd_eer.c
+Auto-merging drivers/s390/char/vmlogrdr.c
+Auto-merging drivers/s390/char/vmur.c
+Auto-merging drivers/s390/crypto/zcrypt_api.c
+Auto-merging drivers/scsi/hpsa.c
+Auto-merging drivers/scsi/sd.c
+Auto-merging drivers/staging/Kconfig
+Auto-merging drivers/staging/cx25821/cx25821.h
+Auto-merging drivers/staging/easycap/easycap.h
+Auto-merging drivers/staging/intel_sst/intel_sst_app_interface.c
+Auto-merging drivers/staging/rtl8712/osdep_service.h
+CONFLICT (delete/modify): drivers/staging/stradis/Kconfig deleted in HEAD and modified in bkl-config/config. Version bkl-config/config of drivers/staging/stradis/Kconfig left in tree.
+Auto-merging drivers/usb/core/devio.c
+Auto-merging drivers/usb/core/inode.c
+Auto-merging drivers/usb/gadget/f_fs.c
+Auto-merging drivers/usb/host/isp1362-hcd.c
+Auto-merging drivers/usb/mon/mon_bin.c
+Auto-merging drivers/usb/serial/usb-serial.c
+Auto-merging drivers/video/console/vgacon.c
+Auto-merging drivers/xen/xenfs/privcmd.c
+Auto-merging fs/block_dev.c
+Auto-merging fs/ceph/inode.c
+Auto-merging fs/ceph/mds_client.c
+Auto-merging fs/compat_ioctl.c
+Auto-merging fs/ecryptfs/super.c
+Auto-merging fs/ext3/super.c
+Auto-merging fs/ioctl.c
+Auto-merging fs/lockd/clntlock.c
+Auto-merging fs/lockd/clntproc.c
+Auto-merging fs/lockd/svc4proc.c
+Auto-merging fs/lockd/svclock.c
+Auto-merging fs/lockd/svcproc.c
+Auto-merging fs/locks.c
+Auto-merging fs/namespace.c
+Auto-merging fs/ncpfs/dir.c
+Auto-merging fs/ncpfs/file.c
+Auto-merging fs/ncpfs/inode.c
+Auto-merging fs/ncpfs/ioctl.c
+Auto-merging fs/nfs/callback.c
+Auto-merging fs/nfs/delegation.c
+Auto-merging fs/nfs/super.c
+Auto-merging fs/nfsd/nfs4state.c
+CONFLICT (content): Merge conflict in fs/nfsd/nfs4state.c
+Auto-merging fs/ocfs2/super.c
+Auto-merging fs/proc/inode.c
+Auto-merging fs/read_write.c
+Auto-merging fs/reiserfs/ioctl.c
+Auto-merging fs/reiserfs/journal.c
+Auto-merging fs/reiserfs/super.c
+Auto-merging include/linux/hardirq.h
+CONFLICT (content): Merge conflict in include/linux/hardirq.h
+Auto-merging include/linux/smp_lock.h
+CONFLICT (content): Merge conflict in include/linux/smp_lock.h
+Auto-merging include/linux/tty.h
+Auto-merging init/main.c
+Auto-merging kernel/trace/trace.c
+Auto-merging lib/Kconfig.debug
+Auto-merging net/irda/af_irda.c
+Auto-merging net/sunrpc/svc_xprt.c
+Auto-merging sound/core/pcm_native.c
+Auto-merging sound/core/sound.c
+Automatic merge failed; fix conflicts and then commit the result.
+$ git rm -f drivers/staging/stradis/Kconfig
+arch/powerpc/kernel/setup_64.c: needs merge
+drivers/staging/stradis/Kconfig: needs merge
+fs/nfsd/nfs4state.c: needs merge
+include/linux/hardirq.h: needs merge
+include/linux/smp_lock.h: needs merge
+rm 'drivers/staging/stradis/Kconfig'
+$ git commit -v -a
+[master c590101] Merge remote branch 'bkl-config/config'
+$ git diff -M --stat --summary HEAD^..
+ drivers/gpu/drm/Kconfig           |    4 ++--
+ drivers/gpu/drm/i810/i810_dma.c   |   18 +-----------------
+ drivers/gpu/drm/i810/i810_drv.c   |    6 +++++-
+ drivers/staging/Kconfig           |   11 +++++++++++
+ drivers/staging/cx25821/cx25821.h |    1 -
+ include/linux/smp_lock.h          |   15 ++-------------
+ lib/Kconfig.debug                 |    9 ---------
+ 7 files changed, 21 insertions(+), 43 deletions(-)
+Merging irqflags/master
+$ git merge irqflags/master
+Already up-to-date.
+Merging cleancache/linux-next
+$ git merge cleancache/linux-next
+Resolved 'fs/ocfs2/super.c' using previous resolution.
+Resolved 'fs/super.c' using previous resolution.
+Resolved 'include/linux/fs.h' using previous resolution.
+Resolved 'mm/Kconfig' using previous resolution.
+Auto-merging arch/x86/include/asm/xen/hypercall.h
+Auto-merging drivers/xen/Makefile
+Auto-merging fs/btrfs/extent_io.c
+Auto-merging fs/btrfs/super.c
+Auto-merging fs/buffer.c
+Auto-merging fs/ext3/super.c
+Auto-merging fs/ext4/super.c
+Auto-merging fs/mpage.c
+Auto-merging fs/ocfs2/super.c
+CONFLICT (content): Merge conflict in fs/ocfs2/super.c
+Auto-merging fs/super.c
+CONFLICT (content): Merge conflict in fs/super.c
+Auto-merging include/linux/fs.h
+CONFLICT (content): Merge conflict in include/linux/fs.h
+Auto-merging mm/Kconfig
+CONFLICT (content): Merge conflict in mm/Kconfig
+Auto-merging mm/Makefile
+Auto-merging mm/filemap.c
+Auto-merging mm/truncate.c
+Automatic merge failed; fix conflicts and then commit the result.
+$ git commit -v -a
+[master 6084e02] Merge remote branch 'cleancache/linux-next'
+$ git diff -M --stat --summary HEAD^..
+ .../ABI/testing/sysfs-kernel-mm-cleancache         |   11 +
+ Documentation/vm/cleancache.txt                    |  267 ++++++++++++++++++++
+ arch/x86/include/asm/xen/hypercall.h               |    7 +
+ drivers/xen/Makefile                               |    1 +
+ drivers/xen/tmem.c                                 |  264 +++++++++++++++++++
+ fs/btrfs/extent_io.c                               |    9 +
+ fs/btrfs/super.c                                   |    2 +
+ fs/buffer.c                                        |    5 +
+ fs/ext3/super.c                                    |    2 +
+ fs/ext4/super.c                                    |    2 +
+ fs/mpage.c                                         |    7 +
+ fs/ocfs2/super.c                                   |    2 +
+ fs/super.c                                         |    3 +
+ include/linux/cleancache.h                         |  118 +++++++++
+ include/linux/fs.h                                 |    5 +
+ include/xen/interface/xen.h                        |   22 ++
+ mm/Kconfig                                         |   22 ++
+ mm/Makefile                                        |    1 +
+ mm/cleancache.c                                    |  245 ++++++++++++++++++
+ mm/filemap.c                                       |   11 +
+ mm/truncate.c                                      |   10 +
+ 21 files changed, 1016 insertions(+), 0 deletions(-)
+ create mode 100644 Documentation/ABI/testing/sysfs-kernel-mm-cleancache
+ create mode 100644 Documentation/vm/cleancache.txt
+ create mode 100644 drivers/xen/tmem.c
+ create mode 100644 include/linux/cleancache.h
+ create mode 100644 mm/cleancache.c
+Merging scsi-post-merge/merge-base:master
+$ git clone -s -l -n -q . ../rebase-tmp
+$ cd ../rebase-tmp
+$ git fetch --no-tags ../next refs/remotes/scsi-post-merge/master:scsi-post-merge/master
+From ../next
+ * [new branch]      scsi-post-merge/master -> scsi-post-merge/master
+$ git fetch --no-tags ../next refs/remotes/scsi-post-merge/merge-base:scsi-post-merge/merge-base
+From ../next
+ * [new branch]      scsi-post-merge/merge-base -> scsi-post-merge/merge-base
+$ git checkout scsi-post-merge/master
+Switched to branch 'scsi-post-merge/master'
+$ git rebase --onto master scsi-post-merge/merge-base
+First, rewinding head to replay your work on top of it...
+Fast-forwarded scsi-post-merge/master to master.
+$ cd ../next
+$ git pull -f ../rebase-tmp scsi-post-merge/master
+From ../rebase-tmp
+ * branch            scsi-post-merge/master -> FETCH_HEAD
+Already up-to-date.
+$ rm -rf ../rebase-tmp
diff --git a/Next/quilt-import.log b/Next/quilt-import.log
new file mode 100644
index 0000000..de0def4
--- /dev/null
+++ b/Next/quilt-import.log
@@ -0,0 +1,32 @@
+Importing i2c based on 2.6.38-rc1
+Unchanged quilt series i2c
+Importing jdelvare-hwmon based on 2.6.38-rc1
+Unchanged quilt series jdelvare-hwmon
+Importing kernel-doc based on 2.6.37-rc4
+Unchanged quilt series kernel-doc
+Importing rr based on v2.6.37-7787-g8a335bc
+$ git clone -s -l -n -q . ../quilt-tmp
+$ cd ../quilt-tmp
+$ git reset --hard 8a335bc631ac9c43675821580c26ebf95a3044ba
+HEAD is now at 8a335bc Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/nab/scsi-post-merge-2.6
+$ git quiltimport --author Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org> --patches ../quilt/rr
+lguest:username-and-chroot.patch
+lguest:guard-pages.patch
+lguest:document-rng.patch
+Context reduced to (1/1) to apply fragment at 119
+lguest:use_this_cpu_ops.patch
+lguest-use_this_cpu_ops-fixes.patch
+lguest:guest_fix_unmet_direct_dependencies_virtualization_virtio.patch
+virtio:remove_pci_root_device.patch
+module:show_version_information_for_built_in_s_in_sysfs.patch
+module-show_version_information_for_built_in_s_in_sysfs-fix.patch
+module:param_add_null_statement_to_compiled_in_params.patch
+module-fixup-missing-semicolons.patch
+misc:enhance-BUILD_BUG_ON.patch
+misc:remove-MAYBE_BUILD_BUG_ON.patch
+$ cd ../next
+$ git fetch -f ../quilt-tmp master:quilt/rr
+From ../quilt-tmp
+ + 1b399e7...cb94198 master     -> quilt/rr  (forced update)
+Importing device-mapper based on v2.6.37-7185-g52cfd50
+Unchanged quilt series device-mapper
diff --git a/localversion-next b/localversion-next
new file mode 100644
index 0000000..ed30abb
--- /dev/null
+++ b/localversion-next
@@ -0,0 +1 @@
+-next-20110121
-- 
1.7.1
