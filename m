From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: 3.9-rc1 NULL pointer crash at find_pid_ns
Date: Thu, 07 Mar 2013 01:59:30 -0800
Message-ID: <876213wmwt.fsf@xmission.com>
References: <611667212.10748821.1362649031475.JavaMail.root@redhat.com>
	<513860E8.4080807@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <513860E8.4080807-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> (Li Zefan's message of "Thu, 7 Mar
	2013 17:42:00 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, CAI Qian <caiqian-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> writes:

> Cc: sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
> Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Cc: container
>
> This is a second report... and the same address: 0xfffffffffffffff0 

Actually this is the third report I have seen with that address, and the
others were on x86_64.

The obvious answer is that there is something subtlely wrong with:

commit b67bfe0d42cac56c512dd5da4b1b347a23f4b70a
Author: Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date:   Wed Feb 27 17:06:00 2013 -0800

    hlist: drop the node parameter from iterators


This is the only change the pid namespace that I am aware of in 3.9-rc1.

If you can reproduce this somewhat readily can you please revert the
hlist change and see if this continues to happen.  Right now there are
no other code changes that I can see.  And the address
0xfffffffffffffff0 is consistent with a bug in hlist_for_each_entry_rcu.

Eric

> On 2013/3/7 17:37, CAI Qian wrote:
>> Just came across this during LTP run on a ppc64 system. Still trying to
>> reproduce and possible bisect, but want to give an early head-up to see
>> if anyone see anything obvious.
>> 
>> CAI Qian
>> 
>> [ 6476.040024] Unable to handle kernel paging request for data at address 0xfffffffffffffff0 
>> [ 6476.040051] Faulting instruction address: 0xc0000000000af8ac 
>> [ 6476.040060] Oops: Kernel access of bad area, sig: 11 [#1] 
>> [ 6476.040067] SMP NR_CPUS=1024 NUMA pSeries 
>> [ 6476.040077] Modules linked in: tun binfmt_misc hidp cmtp kernelcapi rfcomm l2tp_ppp l2tp_netlink l2tp_core bnep nfc af_802154 pppoe pppox ppp_generic slhc rds af_key atm sctp ip6table_filter ip6_tables iptable_filter ip_tables btrfs raid6_pq xor vfat fat nfsv3 nfs_acl nfsv2 nfs lockd sunrpc fscache nfnetlink_log nfnetlink bluetooth rfkill arc4 md4 nls_utf8 cifs dns_resolver nf_tproxy_core nls_koi8_u nls_cp932 ts_kmp fuse sg ehea xfs libcrc32c sd_mod crc_t10dif ibmvscsi scsi_transport_srp scsi_tgt dm_mirror dm_region_hash dm_log dm_mod [last unloaded: ipt_REJECT] 
>> [ 6476.040204] NIP: c0000000000af8ac LR: c0000000000b07e0 CTR: 0000000000000000 
>> [ 6476.040213] REGS: c00000011ae73480 TRAP: 0300   Not tainted  (3.9.0-rc1) 
>> [ 6476.040221] MSR: 8000000000009032 <SF,EE,ME,IR,DR,RI>  CR: 88008488  XER: 20000000 
>> [ 6476.040243] SOFTE: 1 
>> [ 6476.040248] CFAR: c000000000005f1c 
>> [ 6476.040253] DAR: fffffffffffffff0, DSISR: 40000000 
>> [ 6476.040260] TASK = c00000006be719e0[26514] 'ps' THREAD: c00000011ae70000 CPU: 26 
>> GPR00: c000000000299c34 c00000011ae73700 c0000000010f3a18 00000000000050d5  
>> GPR04: c000000001047ec0 0000000000000011 a000000000000000 9e97fbecc2b0cf95  
>> GPR08: c0000001472521c0 fffffffffffffff0 c0000000014d0000 c000000144886026  
>> GPR12: 0000000024008422 c00000000ed96800 0000000000000000 0000000000000000  
>> GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000  
>> GPR20: 0000000000000000 0000000000000000 0000000000000000 c00000011ae73ab0  
>> GPR24: c00000014488602b 0000000000000000 0000000000000004 fffffffffffff000  
>> GPR28: c0000001fd040040 c0000001fd040040 c0000001f2ed3540 0000000000000011  
>> [ 6476.040371] NIP [c0000000000af8ac] .find_pid_ns+0x8c/0xd0 
>> [ 6476.040379] LR [c0000000000b07e0] .find_task_by_pid_ns+0x10/0x50 
>> [ 6476.040385] Call Trace: 
>> [ 6476.040394] [c00000011ae73700] [c00000011ae737c0] 0xc00000011ae737c0 (unreliable) 
>> [ 6476.040407] [c00000011ae73770] [c000000000299c34] .proc_pid_lookup+0xc4/0x1a0 
>> [ 6476.040416] [c00000011ae73800] [c0000000002942f4] .proc_root_lookup+0x44/0x80 
>> [ 6476.040427] [c00000011ae73890] [c00000000021b300] .lookup_real+0x40/0x90 
>> [ 6476.040437] [c00000011ae73910] [c00000000021bd00] .__lookup_hash+0x40/0x60 
>> [ 6476.040446] [c00000011ae739a0] [c00000000021c7d0] .lookup_slow+0x60/0x100 
>> [ 6476.040456] [c00000011ae73a30] [c00000000021da08] .link_path_walk+0x8d8/0xaa0 
>> [ 6476.040466] [c00000011ae73b40] [c000000000221a98] .path_openat+0xc8/0x5c0 
>> [ 6476.040476] [c00000011ae73c60] [c0000000002223f0] .do_filp_open+0x40/0xb0 
>> [ 6476.040486] [c00000011ae73d80] [c00000000020d470] .do_sys_open+0x140/0x250 
>> [ 6476.040497] [c00000011ae73e30] [c000000000009c54] syscall_exit+0x0/0x98 
>> [ 6476.040504] Instruction dump: 
>> [ 6476.040510] 7d2a482a 3929fff0 48000020 60000000 60000000 e9490010 2faa0000 419e0048  
>> [ 6476.040528] e9290010 3929fff0 2fa90000 419e0038 <81490000> 7f8a1800 409effdc e9490008  
>> [ 6476.040551] ---[ end trace 5c3fc2ac5c10d1e8 ]--- 
>> [ 6476.042165]  
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>> .
>> 
