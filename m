From: Dilip Daya <dilip.daya-VXdhtT5mjnY@public.gmane.org>
Subject: Network namespace and bonding WARNING at fs/proc/generic.c
	remove_proc_entry
Date: Thu, 28 Jun 2012 12:18:40 -0400
Message-ID: <1340900320.3441.88.camel@pro6455b.example.com>
Reply-To: dilip.daya-VXdhtT5mjnY@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

I'd discussed the following with Serge Hallyn.

=> Environment based on 3.2.18 / x86_64 kernel.
=> WARNING: at fs/proc/generic.c:808 remove_proc_entry+0xdb/0x21f()
=> WARNING: at fs/proc/generic.c:849 remove_proc_entry+0x208/0x21f()


network namespace and bonding
-----------------------------

* Migrate two phy nics from host to netns (netns0).
  - ip link set ethX netns netns0

* In host environment:
  - load bonding module, /sbin/modprobe -v bonding mode=1 miimon=100
  - /sys/class/net/bond0 exists.
  - /proc/net/bonding/bond0 exists.
  - /sys/class/net/bonding_masters has bond0.

* Migrate bond0 to netns (netns0):
  - ip link set bond0 netns netns0.

* Within netns (netns0):
  - /sys/class/net/bonding_masters is empty.
  - /sys/class/net/bond0 exist.
  - configure bond0 and ifenslave with two phy nics.
  - /proc/net/bonding/bond0 does not exist within netns0, but does
    exist in the host environment.
  - /sys/class/net/bonding_masters is empty.
  - ping to remote end of bond0 works.

* Within netns (netns0), flushing ethX and bondY:
  - down bond0 and its phy nic interfaces:
  - ip link set ... down
  - ip addr flush dev [bond0 | eth#]
  - deleting bond0, /sbin/ip link del dev bond0

  produced splat #1

[1863091.131448] bonding: bond0: released all slaves
[1863091.131454] (unregistered net_device): mixed no checksumming and
other settings.
[1863091.131463] ------------[ cut here ]------------
[1863091.131472] WARNING: at fs/proc/generic.c:808 remove_proc_entry
+0xdb/0x21f()
[1863091.131475] Hardware name: ProLiant DL380 G6
[1863091.131477] name 'bond0'
[1863091.131479] Modules linked in: bonding pktgen mperf
cpufreq_userspace cpufreq_stats cpufreq_ondemand freq_table
cpufreq_powersave sctp cpufreq_conservative parport_pc ppdev crc32c
libcrc32c lp parport nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs
binfmt_misc deflate zlib_deflate ctr twofish_x86_64 twofish_generic
twofish_common camellia serpent blowfish_x86_64 blowfish_generic
blowfish_common cast5 des_generic cbc cryptd aes_x86_64 aes_generic xcbc
rmd160 sha512_generic sha256_generic sha1_generic crypto_null af_key
fuse ipv6 loop ipmi_si ipmi_msghandler i7core_edac edac_core psmouse
hpilo hpwdt evdev serio_raw pcspkr processor container button ext3 jbd
mbcache usbhid hid sr_mod cdrom ide_pci_generic ide_core ata_generic sg
sd_mod crc_t10dif mpt2sas scsi_transport_sas raid_class ata_piix libata
hpsa uhci_hcd ehci_hcd scsi_mod bnx2 e1000e(O) thermal thermal_sys [last
unloaded: bonding]
[1863091.131563] Pid: 31663, comm: ip Tainted: G        W  O
3.2.18-clim-1-amd64 #1
[1863091.131566] Call Trace:
[1863091.131577]  [<ffffffff8103e54f>] warn_slowpath_common+0x80/0x98
[1863091.131582]  [<ffffffff8103e5fb>] warn_slowpath_fmt+0x41/0x43
[1863091.131587]  [<ffffffff81140235>] remove_proc_entry+0xdb/0x21f
[1863091.131593]  [<ffffffff8105e4f8>] ? raw_notifier_call_chain
+0xf/0x11
[1863091.131600]  [<ffffffff81276077>] ? netdev_features_change
+0x11/0x13
[1863091.131610]  [<ffffffffa04a4336>] bond_remove_proc_entry+0x59/0x72
[bonding]
[1863091.131617]  [<ffffffffa049b3d8>] bond_uninit+0x3a4/0x411 [bonding]
[1863091.131622]  [<ffffffff81281234>] ? rtnl_notify+0x28/0x2a
[1863091.131626]  [<ffffffff812758b0>] rollback_registered_many
+0x189/0x215
[1863091.131631]  [<ffffffff81275952>] unregister_netdevice_many
+0x16/0x63
[1863091.131634]  [<ffffffff8127f591>] rtnl_dellink+0xc8/0xec
[1863091.131642]  [<ffffffff810bb5a0>] ? get_page_from_freelist
+0x5d1/0x6f7
[1863091.131646]  [<ffffffff81281827>] rtnetlink_rcv_msg+0x220/0x23d
[1863091.131650]  [<ffffffff81281607>] ? rtnetlink_rcv+0x28/0x28
[1863091.131656]  [<ffffffff812961b0>] netlink_rcv_skb+0x3e/0x8e
[1863091.131660]  [<ffffffff81281600>] rtnetlink_rcv+0x21/0x28
[1863091.131663]  [<ffffffff81295ed8>] netlink_unicast+0x220/0x297
[1863091.131668]  [<ffffffff812966d7>] netlink_sendmsg+0x210/0x278
[1863091.131674]  [<ffffffff81263625>] sock_sendmsg+0xe1/0x104
[1863091.131679]  [<ffffffff812634de>] ? sock_recvmsg+0xed/0x112
[1863091.131684]  [<ffffffff810beea7>] ? lru_cache_add_lru+0x3c/0x3e
[1863091.131691]  [<ffffffff810da976>] ? page_add_new_anon_rmap
+0x5b/0x6c
[1863091.131696]  [<ffffffff810d27c0>] ? do_wp_page+0x65b/0x711
[1863091.131701]  [<ffffffff812631e4>] ? move_addr_to_kernel+0x44/0x49
[1863091.131707]  [<ffffffff8126cf59>] ? verify_iovec+0x4f/0xa6
[1863091.131712]  [<ffffffff81263e29>] __sys_sendmsg+0x20f/0x29c
[1863091.131716]  [<ffffffff810d3ea5>] ? handle_mm_fault+0x1fb/0x211
[1863091.131723]  [<ffffffff8130b1d8>] ? do_page_fault+0x3ab/0x3ea
[1863091.131728]  [<ffffffff810d83a5>] ? do_brk+0x2b8/0x31a
[1863091.131732]  [<ffffffff81264016>] sys_sendmsg+0x3d/0x5e
[1863091.131738]  [<ffffffff8130e852>] system_call_fastpath+0x16/0x1b
[1863091.131742] ---[ end trace 8be56c744dfb7d6c ]---


* removing bonding module from within netns0:
  - /sbin/modprobe -v -r bonding

  produced splat #2

 ------------[ cut here ]------------
[1863281.361003] WARNING: at fs/proc/generic.c:849 remove_proc_entry
+0x208/0x21f()
[1863281.361006] Hardware name: ProLiant DL380 G6
[1863281.361009] remove_proc_entry: removing non-empty directory
'net/bonding', leaking at least 'bond0'
[1863281.361012] Modules linked in: bonding(-) pktgen mperf
cpufreq_userspace cpufreq_stats cpufreq_ondemand freq_table
cpufreq_powersave sctp cpufreq_conservative parport_pc ppdev crc32c
libcrc32c lp parport nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs
binfmt_misc deflate zlib_deflate ctr twofish_x86_64 twofish_generic
twofish_common camellia serpent blowfish_x86_64 blowfish_generic
blowfish_common cast5 des_generic cbc cryptd aes_x86_64 aes_generic xcbc
rmd160 sha512_generic sha256_generic sha1_generic crypto_null af_key
fuse ipv6 loop ipmi_si ipmi_msghandler i7core_edac edac_core psmouse
hpilo hpwdt evdev serio_raw pcspkr processor container button ext3 jbd
mbcache usbhid hid sr_mod cdrom ide_pci_generic ide_core ata_generic sg
sd_mod crc_t10dif mpt2sas scsi_transport_sas raid_class ata_piix libata
hpsa uhci_hcd ehci_hcd scsi_mod bnx2 e1000e(O) thermal thermal_sys [last
unloaded: bonding]
[1863281.361091] Pid: 31678, comm: modprobe Tainted: G        W  O
3.2.18-clim-1-amd64 #1
[1863281.361094] Call Trace:
[1863281.361102]  [<ffffffff8103e54f>] warn_slowpath_common+0x80/0x98
[1863281.361106]  [<ffffffff8103e5fb>] warn_slowpath_fmt+0x41/0x43
[1863281.361111]  [<ffffffff81140362>] remove_proc_entry+0x208/0x21f
[1863281.361120]  [<ffffffffa04a428b>] bond_destroy_proc_dir+0x26/0x32
[bonding]
[1863281.361126]  [<ffffffffa049916e>] bond_net_exit+0x42/0x46 [bonding]
[1863281.361132]  [<ffffffff8126f341>] ops_exit_list+0x25/0x4e
[1863281.361137]  [<ffffffff8126f67a>] unregister_pernet_operations
+0x83/0xb1
[1863281.361141]  [<ffffffff8126f70c>] unregister_pernet_subsys
+0x20/0x31
[1863281.361148]  [<ffffffffa04a4995>] bonding_exit+0x39/0x56 [bonding]
[1863281.361154]  [<ffffffff8107136c>] sys_delete_module+0x1ba/0x226
[1863281.361159]  [<ffffffff810f117a>] ? vfs_write+0x11e/0x153
[1863281.361166]  [<ffffffff8130e852>] system_call_fastpath+0x16/0x1b
[1863281.361169] ---[ end trace 8be56c744dfb7d6d ]---

   - bonding module is removed
   - /sys/class/net/bonding_masters no longer exists in netns and host.



Workaround
----------

* Migrate two phy nics from host to netns (netns0).
  - ip link set ethX netns netns0

* Within netns (netns0):
  - Load bonding module, modprobe -v bonding mode=1 miimon=100
primary=eth6
  - /sys/class/net/bonding_masters exists.
  - create bond0, ip link add dev bond0 type bond.
  - /sys/class/net/bonding_masters contains bond0.
  - ifenslave both ethX to bond0.
  - /proc/net/bonding/bond0 exists.
  - ping on bond0 to remote works.

* Within netns (netns0), flushing ethX and bondY:
  - ip link set ethX/bond0 down
  - ip addr flush dev ethX/bond0
  - Deleting bond0 and removing bonding module works as follows:
     ip link del dev bond0
     modprobe -v -r bonding
     => No splat #1 or #2.

Note: Please cc: me--dilip.daya-VXdhtT5mjnY@public.gmane.org with your comments.

Thanks.
