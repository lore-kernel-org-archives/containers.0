From: Jon Zhu <jon.zhu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: lxc-checkpoint crash when checkpointing a soapaligner application
Date: Mon, 14 Mar 2011 10:05:53 -0400
Message-ID: <AANLkTi=EZWiGv5TGvcKi01V0SeUcFW2BOpcA-JwriJmM@mail.gmail.com>
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
To: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

When we run Soapaligner application(
http://soap.genomics.org.cn/soapaligner.html#down2) on LXC/LINUX-CR (
https://ckpt.wiki.kernel.org/index.php/Link-LXC-USERCR#Checkpoint.2Frestart_a_simple_LXC_container),
we use lxc-checkpoint to try to create a checkpoint of the running process,
at that time the application crashed, here's the system event
log(/var/log/message)

Mar 14 13:16:41 ip-10-98-14-121 kernel: rr:325]_pgarr:325]
go_pgarr:32_pgarr:32_pgarr:325] _pgarr:32_pgarr:325]
g_pgarr:32_pgarr:325]_pgarr:325]_pgarr:325]
go_pgarr:325]_pgarr:32_pgarr:325] go_pgarr:325]_pgarr:325]_pgarr:325]
g_pgarr:325] _pgarr:325] got p_pgarr:325] got p_pgarr:325]_pgarr:325]
go_pgarr:32_pgarr:32_pgarr:32_pgarr:325]_pgarr:325]_pgarr:325]
got_pgarr:325]_pgarr:32_pgarr:32_pgarr:325] g_pgarr:325]_pgarr:325]
g_pgarr:325] g_pgarr:325]_pgarr:325]_pgarr:32_pgarr:325]
_pgarr:325]_pgarr:325] g_pgarr:325]
g_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]
g_pgarr:325]_pgarr:325]_pgarr:325] got_pgarr:325] go_pgarr:325]
got_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325] g_pgarr:325]_pgarr:325]
g_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]
g_pgarr:325]_pgarr:325]
g_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]
g_pgarr:325]_pgarr:325]_pgarr:325] got pag_pgarr:325]
got_pgarr:325]_pgarr:325
Mar 14 13:16:41 ip-10-98-14-121 kernel: ] g_pgarr:325]_pgarr:325]_pgarr:325]
g_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]
got p_pgarr:325] g_pgarr:325] got_pgarr:325]_pgarr:325]
go_pgarr:32_pgarr:32_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]
g_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]
g_pgarr:325]_pgarr:32_pgarr:325] got_pgarr:325] g_pgarr:325] g_pgarr:325]
g_pgarr:325] got_pgarr:32_pgarr:32_pgarr:325]
g_pgarr:325]_pgarr:325]_pgarr:32_pgarr:32_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]
_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]_pgarr:325]
g_pgarr:32_pgarr:32_pgarr:325]_pgarr:325]
got_pgarr:325]_pgarr:325]_pgarr:325] got_pgarr:325] got page 0x7f844262b000
Mar 14 13:16:46 ip-10-98-14-121 kernel: _pgarr:325] got page 0x7f84466c5000
Mar 14 13:16:48 ip-10-98-14-121 kernel: _pgarr:325] got page 0x7f84484cc000
Mar 14 13:16:51 ip-10-98-14-121 kernel: _pgarr:325] got page 0x7f844a6c5000
Mar 14 13:16:53 ip-10-98-14-121 kernel: _pgarr:325] got page 0x7f844c6c5000
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.821949] CPU 1
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.821951] Modules linked in:
[last unloaded: acpiphp]
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.821960]
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.821965] Pid: 1112, comm:
lxc-checkpoint Not tainted 2.6.34-rc5 #1 /
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.821970] RIP:
e030:[<ffffffff810396d9>]  [<ffffffff810396d9>] encode_segment+0x79/0x80
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.821986] RSP:
e02b:ffff8801c512dd10  EFLAGS: 00010286
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.821991] RAX: 0000000000000036
RBX: ffff880179f44240 RCX: 0000000000000000
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.821997] RDX: 0000000000000000
RSI: 0000000000000000 RDI: 0000000000000200
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822003] RBP: ffff8801c512dd10
R08: 0000000000000000 R09: ffffffff81640b60
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822009] R10: 0000000000000001
R11: 0000000000000000 R12: ffff8801d6b0dc80
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822015] R13: ffff8801c51aa000
R14: ffff8801be4c89c0 R15: 00000000fffffff4
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822028] FS:
 00007f20b1ba1700(0000) GS:ffff88001a7a2000(0000) knlGS:0000000000000000
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822035] CS:  e033 DS: 0000
ES: 0000 CR0: 000000008005003b
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822041] CR2: 00007fa64e02f000
CR3: 00000001d6b47000 CR4: 0000000000002660
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822048] DR0: 0000000000000000
DR1: 0000000000000000 DR2: 0000000000000000
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822054] DR3: 0000000000000000
DR6: 00000000ffff0ff0 DR7: 0000000000000400
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822061] Process
lxc-checkpoint (pid: 1112, threadinfo ffff8801c512c000, task
ffff880018edae40)
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822071]  ffff8801c512dd80
ffffffff810397c0 ffff8801bec3c000 00000000991d414b
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822081] <0> 0000000000000458
00000000000000c0 000000000000006b ffff8801d6b0dc80
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822092] <0> ffff8801be4c89c0
ffff880179f44240 ffff8801bec3c000 ffff8801d6b0dc80
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822114]  [<ffffffff810397c0>]
save_cpu_regs+0xe0/0x240
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822121]  [<ffffffff810338af>]
checkpoint_cpu+0x4f/0x200
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822131]  [<ffffffff810fbb43>]
checkpoint_task+0x1a3/0xa40
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822138]  [<ffffffff810f7a70>]
do_checkpoint+0x740/0xc20
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822146]  [<ffffffff810f572b>]
do_sys_checkpoint+0x6b/0xe0
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822153]  [<ffffffff81033a7e>]
sys_checkpoint+0xe/0x10
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822164]  [<ffffffff8100a453>]
stub_checkpoint+0x13/0x20
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822171]  [<ffffffff8100a072>]
? system_call_fastpath+0x16/0x1b
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822274]  RSP
<ffff8801c512dd10>
Mar 14 13:16:55 ip-10-98-14-121 kernel: [  634.822296] ---[ end trace
144b71d3d7a94bd7 ]---

We are using LXC 0.7.1 based stack according to the Wiki listed above. Do we
need to use a recent version of LXC? Is this a known issue of LXC 0.7.1?

Thanks,
-Jon.
jon.zhu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
