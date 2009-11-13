From: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 14150] New: BUG: soft lockup - CPU#3 stuck for
	61s!, while running cpu controller latency testcase on two
	containers parallaly
Date: Fri, 13 Nov 2009 23:03:25 +0530
Message-ID: <20091113173324.GI9065__48752.2100600929$1258133754$gmane$org@linux.vnet.ibm.com>
References: <bug-14150-10286@http.bugzilla.kernel.org/>
	<20090911142813.dc823bf1.akpm@linux-foundation.org>
	<20090915125836.GA4087@linux.vnet.ibm.com>
	<4AB20086.8070105@linux.vnet.ibm.com>
	<4AB32EA7.20904@linux.vnet.ibm.com>
	<4AB34445.4060700@linux.vnet.ibm.com>
	<4AB8A24E.8060209@linux.vnet.ibm.com>
Reply-To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AB8A24E.8060209-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rishikesh <risrajak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: iranna.ankad-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, markwiz-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, Bharata B Rao <bharata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, lxie-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, sharyath-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, santwana.samantray-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Sep 22, 2009 at 03:39:18PM +0530, Rishikesh wrote:
> Hi Dhaval,
>
> Today i tried 2 more scenario requested by you on -tip kernel:
>
> 1> mount cpu on cgroup & other susbsystems ( ns, cpuset,freezer...  
> except cpu) on cgroup1 e.g:.
> /root/lxc on /cgroup type cgroup  
> (rw,ns,cpuset,freezer,devices,memory,cpuacct,net_cls)
> none on /cgroup1 type cgroup (rw,cpu)
>
>    Result: I am able to create container ( no crash after "lxc-execute  
> ..." command execution).
> 2> mount cpu,ns on cgroup
> [root@x335a ~]# mount
> none on /cgroup type cgroup (rw,ns,cpu)
> [root@x335a ~]# lxc-execute -n foo2 -f /etc/lxc/lxc-macvlan.conf /bin/bash
>
>    Result : The system crash with following trace once i execute  
> lxc-execute command:
>
> x335a.in.ibm.com login: BUG: NMI Watchdog detected LOCKUP on CPU1, ip  
> c0425854, registers:
> Modules linked in: nfs lockd nfs_acl auth_rpcgss bridge stp llc bnep sco  
> l2cap bluetooth autofs4 sunrpc ipv6 p4_clockmod dm_multipath uinput  
> ata_generic pata_acpi floppy i2c_piix4 i2c_core pata_serverworks tg3  
> pcspkr serio_raw mptspi mptscsih mptbase scsi_transport_spi [last  
> unloaded: scsi_wait_scan]
>
> Pid: 0, comm: swapper Not tainted (2.6.31-tip #2) eserver xSeries 335  
> -[867641X]-
> EIP: 0060:[<c0425854>] EFLAGS: 00000246 CPU: 1
> EIP is at native_safe_halt+0xa/0xc
> EAX: f70a8000 EBX: c096f0d4 ECX: b9d8d702 EDX: 00000001
> ESI: 00000001 EDI: 00000000 EBP: f70a9f74 ESP: f70a9f74
> DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process swapper (pid: 0, ti=f70a8000 task=f7086780 task.ti=f70a8000)
> Stack:
> f70a9f94 c040e63b f70a9f94 c0460b8d 00000001 c096f0d4 00000001 00000000
> <0> f70a9fa4 c0407637 00000001 00000000 f70a9fb0 c075a578 0602080b 00000000
> <0> 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> Call Trace:
> [<c040e63b>] ? default_idle+0x4a/0x7c
> [<c0460b8d>] ? tick_nohz_restart_sched_tick+0x115/0x123
> [<c0407637>] ? cpu_idle+0x58/0x79
> [<c075a578>] ? start_secondary+0x19c/0x1a1
> Code: 89 e5 0f 1f 44 00 00 50 9d 5d c3 55 89 e5 0f 1f 44 00 00 fa 5d c3  
> 55 89 e5 0f 1f 44 00 00 fb 5d c3 55 89 e5 0f 1f 44 00 00 fb f4 <5d> c3  
> 55 89 e5 0f 1f 44 00 00 f4 5d c3 55 89 e5 0f 1f 44 00 00
>
>
> Evening i am going to try 3rd scenario:
>    - Enable CONFIG_PROVE_LOCKING and then execute above scenario once  
> again.
>
> Hope above result will help you to debug further.
>

Just tested on latest -tip and this issue is no longer reproducible.

-- 
regards,
Dhaval
