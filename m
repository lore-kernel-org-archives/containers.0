From: Jerome Marchand <jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/24] io-controller: Core of the elevator fair queuing
Date: Thu, 20 Aug 2009 16:51:46 +0200
Message-ID: <4A8D6302.3080301__972.838517236774$1250780174$gmane$org@redhat.com>
References: <1250451046-9966-1-git-send-email-vgoyal@redhat.com>
	<1250451046-9966-3-git-send-email-vgoyal@redhat.com>
	<4A8C21DE.1080001@redhat.com> <20090819184142.GD4391@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090819184142.GD4391-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
> On Wed, Aug 19, 2009 at 06:01:34PM +0200, Jerome Marchand wrote:
>> Hi Vivek,
>>
>> Vivek Goyal wrote:
>>> o This is core of the io scheduler implemented at elevator layer. This is a mix
>>>   of cpu CFS scheduler and CFQ IO scheduler. Some of the bits from CFS have
>>>   to be derived so that we can support hierarchical scheduling. Without
>>>   cgroups or with-in group, we should essentially get same behavior as CFQ.
>>>
>>> o This patch only shows non-hierarchical bits. Hierarhical code comes in later
>>>   patches.
>>>
>>> o This code is the building base of introducing fair queuing logic in common
>>>   elevator layer so that it can be used by all the four IO schedulers.
>>> +static void enqueue_io_entity(struct io_entity *entity)
>>> +{
>>> +	struct io_service_tree *st = entity->st;
>>> +	struct io_sched_data *sd = io_entity_sched_data(entity);
>>> +
>>> +	/* In case task ioprio class changed while entity was off tree */
>>> +	io_entity_update_prio(entity);
>>> +	st->nr_active++;
>>> +	sd->nr_active++;
>>> +	entity->on_st = 1;
>>> +	place_entity(st, entity, 0);
>>> +	__enqueue_io_entity(st, entity);
>>> +}

One more thing. io_entity_update_prio(entity) can change entity->st, so we'd
better set st after io_entity_update_prio() call. I think it fixes a bug I've
seen when changing elevator and ioprio_class at the same time:

------------[ cut here ]------------
kernel BUG at block/elevator-fq.c:1921!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/block/sda/queue/scheduler
Modules linked in: ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp ipv6 autofs4 hidp rfcomm l2cap bluetooth rfkill sunrpc dm_mirror dm_region_hash dm_log dm_multipath scsi_dh dm_mod video output sbs sbshc battery ac netconsole lp snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device sg snd_pcm_oss snd_mixer_oss rtc_cmos sr_mod snd_pcm cdrom rtc_core tg3 snd_timer libphy snd serio_raw dcdbas i2c_i801 soundcore button pcspkr rtc_lib snd_page_alloc i2c_core parport_pc parport ata_piix libatasd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]

Pid: 9127, comm: change_elevator Tainted: G   M       (2.6.31-rc6-io-controller-v8 #69) OptiPlex 745
EIP: 0060:[<c0537867>] EFLAGS: 00010286 CPU: 1
EIP is at elv_put_iog+0x61/0x83
EAX: 00000000 EBX: 00000000 ECX: f607c000 EDX: f607c001
ESI: f725d300 EDI: f3b59ee0 EBP: f60e5ec0 ESP: f60e5ebc
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process change_elevator (pid: 9127, ti=f60e5000 task=f38083f0 task.ti=f60e5000)
Stack:
 f607c000 f60e5ee8 c05382f5 f70ab480 f6abb368 00000086 f70ab480 00000000
<0> f725d300 f725d334 f38d3cc0 f60e5ef8 c05248f7 f725d30c f6abb368 f60e5f28
<0> c0524a67 00000005 00000000 f725d300 706f6f6e c0820000 f60e5f28 c069e51b
Call Trace:
 [<c05382f5>] ? elv_exit_fq_data+0x18d/0x195
 [<c05248f7>] ? elevator_exit+0x28/0x4e
 [<c0524a67>] ? elv_iosched_store+0x14a/0x1db
 [<c069e51b>] ? mutex_lock_nested+0x2e/0x36
 [<c052d1f8>] ? queue_attr_store+0x50/0x61
 [<c04e9f56>] ? sysfs_write_file+0xb9/0xe4
 [<c04e9e9d>] ? sysfs_write_file+0x0/0xe4
 [<c04a9e57>] ? vfs_write+0x84/0xdf
 [<c04a9f4b>] ? sys_write+0x3b/0x60
 [<c04029b4>] ? sysenter_do_call+0x12/0x32
Code: 0b eb fe 83 79 48 00 75 18 83 79 4c 00 75 1c 83 79 60 00 75 0c 83 79 64 00 75 10 83 79 78 00 74 04 0f 0b eb fe 83 79 7c 00 74 04 <0f> 0b eb fe 8d 81 ec 00 00 00 ba f6 65 53 c0 e8 e9 41 f3 ff 85
EIP: [<c0537867>] elv_put_iog+0x61/0x83 SS:ESP 0068:f60e5ebc
---[ end trace f56eaa89c47eb665 ]---

With the following patch, I can't reproduce it anymore.

Regards,
Jerome

Signed-off-by: Jerome Marchand <jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 elevator-fq.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
--- block/elevator-fq.c.orig	2009-08-20 16:39:13.000000000 +0200
+++ block/elevator-fq.c	2009-08-20 14:29:04.000000000 +0200
@@ -519,11 +519,12 @@ __enqueue_io_entity(struct io_service_tr
 
 static void enqueue_io_entity(struct io_entity *entity)
 {
-	struct io_service_tree *st = entity->st;
+	struct io_service_tree *st;
 	struct io_sched_data *sd = io_entity_sched_data(entity);
 
 	/* In case task ioprio class changed while entity was off tree */
 	io_entity_update_prio(entity);
+	st = entity->st;
 	st->nr_active++;
 	sd->nr_active++;
 	entity->on_st = 1;
