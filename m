From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] IO Controller
Date: Fri, 10 Apr 2009 10:49:39 -0700
Message-ID: <e98e18940904101049u6b40801dhb671081c3cf2418__3100.45808223567$1239386081$gmane$org@mail.gmail.com>
References: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
	<49DF1256.7080403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49DF1256.7080403-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, oz-kernel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 10, 2009 at 2:33 AM, Gui Jianfeng
<guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> Vivek Goyal wrote:
>> Hi All,
>>
>> Here is another posting for IO controller patches. Last time I had posted
>> RFC patches for an IO controller which did bio control per cgroup.
>
> =A0Hi Vivek,
>
> =A0I got the following OOPS when testing, can't reproduce again :(
>
> kernel BUG at block/elevator-fq.c:1396!
> invalid opcode: 0000 [#1] SMP
> last sysfs file: /sys/block/hdb/queue/scheduler
> Modules linked in: ipv6 cpufreq_ondemand acpi_cpufreq dm_mirror dm_multip=
ath sbd
> Pid: 5032, comm: rmdir Not tainted (2.6.29-rc7-vivek #17) Veriton M460
> EIP: 0060:[<c04ec7de>] EFLAGS: 00010082 CPU: 0
> EIP is at iocg_destroy+0xdc/0x14e
> EAX: 00000000 EBX: f62278b4 ECX: f6207800 EDX: f6227904
> ESI: f6227800 EDI: f62278a0 EBP: 00000003 ESP: c8790f00
> =A0DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process rmdir (pid: 5032, ti=3Dc8790000 task=3Df6636960 task.ti=3Dc879000=
0)
> Stack:
> =A0f53cc5c0 f62b7258 f10991c8 00000282 f6227800 c0733fa0 ec1c5140 edfc6d34
> =A0c8790000 c04463ce f6a4c84c edfc6d34 0804c840 c048883c f6a4c84c f6a4c84c
> =A0c04888d6 f6a4c84c 00000000 c04897de f6a4c84c c048504c f115f4c0 ebc37954
> Call Trace:
> =A0[<c04463ce>] cgroup_diput+0x41/0x8c
> =A0[<c048883c>] dentry_iput+0x45/0x5e
> =A0[<c04888d6>] d_kill+0x19/0x32
> =A0[<c04897de>] dput+0xd8/0xdf
> =A0[<c048504c>] do_rmdir+0x8f/0xb6
> =A0[<c06330fc>] do_page_fault+0x2a2/0x579
> =A0[<c0402fc1>] sysenter_do_call+0x12/0x21
> =A0[<c0630000>] schedule+0x641/0x830
> Code: 08 00 74 04 0f 0b eb fe 83 7f 04 00 74 04 0f 0b eb fe 45 83 c3 1c 8=
3 fd 0
> EIP: [<c04ec7de>] iocg_destroy+0xdc/0x14e SS:ESP 0068:c8790f00

We have seen this too. And have been able to reproduce it. I did not
get a chance to fix it so far, but my understanding is that one of the
async queues was active when the cgroup was getting destroyed. We
moved it to root cgroup, but did not deactivate it; so active_entity
still points to the entity of the async queue which has now been moved
to the root cgroup. I will send an update if I can verify this, or fix
it.

>
> --
> Regards
> Gui Jianfeng
>
>
