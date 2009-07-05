From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: BUG in tty_open when using containers and ptrace
Date: Sun, 5 Jul 2009 14:08:06 +0200
Message-ID: <20090705120806.GA16706@megiteam.pl>
References: <d06d0dd6a4ddf760bea53291c048e291@[::1]>
	<20090413142038.GB13007@us.ibm.com>
	<20090704132851.GA16373@megiteam.pl>
	<20090704143412.GA27523@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090704143412.GA27523-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

> That means that %rdx should contain tty->driver, but contains
> 0x6973646e65732f64, which looks like a part of '/etc/init.d/sendsigs'.
> So, we're possibly using an already freed and overwritten tty struct.

Okay, got another one:

Jul  5 13:47:29 sback kernel: [83780.950357] ------------[ cut here ]------------
Jul  5 13:47:29 sback kernel: [83780.950395] WARNING: at drivers/char/tty_io.c:1335 tty_open+0x245/0x423()
Jul  5 13:47:29 sback kernel: [83780.950426] Hardware name: S2891
Jul  5 13:47:29 sback kernel: [83780.950449] Modules linked in: veth ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT bridge stp llc sha1_generic xt_SYSRQ compat_xtables ip6_tables xt_tcpudp iptable_filter ip_tables x_tables ipv6 w83627hf lm85 hwmon_vid loop evdev tg3 libphy k8temp shpchp pci_hotplug i2c_nforce2 i2c_core container button thermal processor thermal_sys
Jul  5 13:47:29 sback kernel: [83780.950668] Pid: 32628, comm: init Not tainted 2.6.30-sback #3
Jul  5 13:47:29 sback kernel: [83780.950697] Call Trace:
Jul  5 13:47:29 sback kernel: [83780.950723]  [<ffffffff8043795e>] ? tty_open+0x245/0x423
Jul  5 13:47:29 sback kernel: [83780.950754]  [<ffffffff802399d0>] warn_slowpath_common+0x7c/0xa9
Jul  5 13:47:29 sback kernel: [83780.950785]  [<ffffffff80239a11>] warn_slowpath_null+0x14/0x16
Jul  5 13:47:29 sback kernel: [83780.950815]  [<ffffffff8043795e>] tty_open+0x245/0x423
Jul  5 13:47:29 sback kernel: [83780.950846]  [<ffffffff802d5b25>] chrdev_open+0x15f/0x17e
Jul  5 13:47:29 sback kernel: [83780.950878]  [<ffffffff803baa3b>] ? selinux_dentry_open+0xf2/0xfb
Jul  5 13:47:29 sback kernel: [83780.950908]  [<ffffffff802d59c6>] ? chrdev_open+0x0/0x17e
Jul  5 13:47:29 sback kernel: [83780.950939]  [<ffffffff802d1082>] __dentry_open+0x155/0x274
Jul  5 13:47:29 sback kernel: [83780.950970]  [<ffffffff802d1278>] nameidata_to_filp+0x46/0x57
Jul  5 13:47:29 sback kernel: [83780.951001]  [<ffffffff802deb1b>] do_filp_open+0x4ca/0x924
Jul  5 13:47:29 sback kernel: [83780.951033]  [<ffffffff802e7ce8>] ? alloc_fd+0x122/0x133
Jul  5 13:47:29 sback kernel: [83780.951063]  [<ffffffff802d0e61>] do_sys_open+0x5b/0xdb
Jul  5 13:47:29 sback kernel: [83780.951093]  [<ffffffff802d0f14>] sys_open+0x20/0x22
Jul  5 13:47:29 sback kernel: [83780.951124]  [<ffffffff8020bc9b>] system_call_fastpath+0x16/0x1b
Jul  5 13:47:29 sback kernel: [83780.951154] ---[ end trace b453453d8c153fcc ]---
Jul  5 13:47:29 sback kernel: [83780.951187] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
Jul  5 13:47:29 sback kernel: [83780.951233] IP: [<ffffffff802d387f>] file_move+0x3c/0x55
Jul  5 13:47:29 sback kernel: [83780.951257] PGD 7bc58067 PUD 7bd8c067 PMD 0
Jul  5 13:47:29 sback kernel: [83780.951257] Oops: 0002 [#1] SMP

(ends here, no netconsole or anything and 'ssh tail -f' managed to only
get this far).

I didn't strace anything this time, was playing with libvirt's apparent
mishandling of container shutdown and I (eventually) sent SIGTERM and
then SIGINT to container init, which caused it first to reexec, and then
to exit. Immediately after sending SIGINT the box froze solid.

I remember that I have issued that same sequence when I got the first
crash, so it looks vaguely related.

Best regards,
 Grzegorz Nosek
