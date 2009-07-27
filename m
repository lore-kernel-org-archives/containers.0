From: Jerome Marchand <jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 03/24] io-controller: bfq support of in-class preemption
Date: Mon, 27 Jul 2009 18:54:54 +0200
Message-ID: <4A6DDBDE.8020608__15267.0484422289$1248713837$gmane$org@redhat.com>
References: <1248467274-32073-1-git-send-email-vgoyal@redhat.com>
	<1248467274-32073-4-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248467274-32073-4-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
> o Generally preemption is associated with cross class where if an request
>   from RT class is pending it will preempt the ongoing BE or IDLE class
>   request.
> 
> o CFQ also does in-class preemtions like a sync request queue preempting the
>   async request queue. In that case it looks like preempting queue gains
>   share and it is not fair.
> 
> o Implement the similar functionality in bfq so that we can retain the
>   existing CFQ behavior.
> 
> o This patch creates a bypass path so that a queue can be put at the
>   front of the service tree (add_front, similar to CFQ), so that it will
>   be selected next to run. That's a different thing that in the process
>   this queue gains share.
> 
> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  block/elevator-fq.c |   46 +++++++++++++++++++++++++++++++++++++++++-----
>  1 files changed, 41 insertions(+), 5 deletions(-)
> 
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index e5f39cf..f1ab0dc 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -267,7 +267,8 @@ static void bfq_get_entity(struct io_entity *entity)
>  		elv_get_ioq(ioq);
>  }
>  
> -static void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
> +static inline void
> +bfq_init_entity(struct io_entity *entity, struct io_group *iog)
>  {
>  	entity->sched_data = &iog->sched_data;
>  }
> @@ -580,7 +581,7 @@ static struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
>   * service received if @entity is active) of the queue to calculate its
>   * timestamps.
>   */
> -static void __bfq_activate_entity(struct io_entity *entity)
> +static void __bfq_activate_entity(struct io_entity *entity, int add_front)
>  {
>  	struct io_sched_data *sd = entity->sched_data;
>  	struct io_service_tree *st = io_entity_service_tree(entity);
> @@ -625,7 +626,42 @@ static void __bfq_activate_entity(struct io_entity *entity)
>  	}
>  
>  	st = __bfq_entity_update_prio(st, entity);
> -	bfq_calc_finish(entity, entity->budget);
> +	/*
> +	 * This is to emulate cfq like functionality where preemption can
> +	 * happen with-in same class, like sync queue preempting async queue
> +	 * May be this is not a very good idea from fairness point of view
> +	 * as preempting queue gains share. Keeping it for now.
> +	 */
> +	if (add_front) {
> +		struct io_entity *next_entity;
> +
> +		/*
> +		 * Determine the entity which will be dispatched next
> +		 * Use sd->next_active once hierarchical patch is applied
> +		 */
> +		next_entity = bfq_lookup_next_entity(sd, 0);
> +
> +		if (next_entity && next_entity != entity) {
> +			struct io_service_tree *new_st;
> +			u64 delta;
> +
> +			new_st = io_entity_service_tree(next_entity);
> +
> +			/*
> +			 * At this point, both entities should belong to
> +			 * same service tree as cross service tree preemption
> +			 * is automatically taken care by algorithm
> +			 */
> +			BUG_ON(new_st != st);

Hi Vivek,

I don't quite understand how cross service tree preemption is taken care
by algorithm, but I've hit this bug while doing some RT I/O and then
killing it.

$ ionice -c 1 dd if=/dev/zero of=/tmp/foo bs=1M count=1000 &
$ killall dd


------------[ cut here ]------------
kernel BUG at block/elevator-fq.c:963!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/block/sdb/size
Modules linked in: usb_storage netconsole ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp ipv6 autofs4 hidp rfcomm l2cap bluetooth rfkill sunrpc dm_mirror dm_region_hash dm_log dm_multipath scsi_dh dm_mod video output sbs sbshc battery ac lp snd_hda_codec_analog snd_hda_intel sg dcdbas snd_hda_codec snd_seq_dummy sr_mod snd_seq_oss snd_seq_midi_event snd_seq cdrom snd_seq_device snd_pcm_oss snd_mixer_oss serio_raw snd_pcm snd_timer button parport_pc snd tg3 libphy rtc_cmos i2c_i801 soundcore snd_page_alloc i2c_core pcspkr parport rtc_core rtc_lib ata_piix libata sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcdehci_hcd [last unloaded: microcode]

Pid: 5627, comm: crond Not tainted (2.6.31-rc4-io-controller-v7 #62) OptiPlex 745
EIP: 0060:[<c0535194>] EFLAGS: 00010012 CPU: 0
EIP is at __bfq_activate_entity+0x1f6/0x370
EAX: f6af607c EBX: f6af6098 ECX: f6af6070 EDX: f5d1f84c
ESI: f6af6070 EDI: f5d1f3a8 EBP: f387bcd4 ESP: f387bca4
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process crond (pid: 5627, ti=f387b000 task=f38942b0 task.ti=f387b000)
Stack:
 f6af6070 00000001 f6af6098 00000000 00000001 f6ab4a00 000b3614 00000000
<0> 00000001 f5d1f3a8 c05323fe f5d1f3a8 f387bce0 c0535cf4 f5d1f3a8 f387bd10
<0> c05372ff f644fdf4 f71ab368 00000000 f6af6070 00000000 f5d1f84c f6ab4a00
Call Trace:
 [<c05323fe>] ? cfq_should_preempt+0x0/0xfc
 [<c0535cf4>] ? elv_activate_ioq+0xf/0x27
 [<c05372ff>] ? elv_ioq_request_add+0x2d3/0x30b
 [<c0522b51>] ? elv_insert+0x12c/0x1c0
 [<c0522c74>] ? __elv_add_request+0x8f/0x94
 [<c0528b8d>] ? __make_request+0x303/0x372
 [<c044d23f>] ? mark_held_locks+0x43/0x5b
 [<c052687e>] ? generic_make_request+0x260/0x29c
 [<c0484ca1>] ? mempool_alloc_slab+0xe/0x10
 [<c0484f10>] ? mempool_alloc+0x42/0xe0
 [<c052696f>] ? submit_bio+0xb5/0xbd
 [<c04c5cf1>] ? bio_alloc_bioset+0x25/0xbd
 [<c04c2937>] ? submit_bh+0xdf/0xfc
 [<c04c3fe1>] ? ll_rw_block+0xa4/0xd8
 [<f80bd73c>] ? ext3_bread+0x35/0x5b [ext3]
 [<f80c182f>] ? htree_dirblock_to_tree+0x1f/0x118 [ext3]
 [<f80c198a>] ? ext3_htree_fill_tree+0x62/0x1ac [ext3]
 [<c044d483>] ? trace_hardirqs_on_caller+0xff/0x120
 [<c044d4af>] ? trace_hardirqs_on+0xb/0xd
 [<f80b9a1b>] ? ext3_readdir+0x18f/0x5fe [ext3]
 [<c04b33b5>] ? filldir+0x0/0xb7
 [<c044d483>] ? trace_hardirqs_on_caller+0xff/0x120
 [<c069c632>] ? __mutex_lock_common+0x293/0x2d2
 [<c069c6d4>] ? mutex_lock_killable_nested+0x2e/0x35
 [<c04b3591>] ? vfs_readdir+0x68/0x94
 [<c04b33b5>] ? filldir+0x0/0xb7
 [<c04b36bf>] ? sys_getdents+0x62/0xa1
 [<c04029b4>] ? sysenter_do_call+0x12/0x32
Code: 00 0f b7 42 4c 8b 4a 44 48 83 f8 02 76 04 0f 0b eb fe 85 c9 75 04 0f 0b eb fe 6b c0 1c 8d 04 01 8945 d0 83 c0 0c 39 45 d8 74 04 <0f> 0b eb fe 8b 5a 10 8b 72 14 8b 47 30 8b 57 34 83 c3 ff 83 d6
EIP: [<c0535194>] __bfq_activate_entity+0x1f6/0x370 SS:ESP 0068:f387bca4
---[ end trace 048abafbc8ce5bf7 ]---

Regards,
Jerome

> +			entity->finish = next_entity->finish - 1;
> +			delta = bfq_delta(entity->budget, entity->weight);
> +			entity->start = entity->finish - delta;
> +			if (bfq_gt(entity->start, st->vtime))
> +				entity->start = st->vtime;
> +		}
> +	} else {
> +		bfq_calc_finish(entity, entity->budget);
> +	}
>  	bfq_active_insert(st, entity);
>  }
>  
> @@ -633,9 +669,9 @@ static void __bfq_activate_entity(struct io_entity *entity)
>   * bfq_activate_entity - activate an entity.
>   * @entity: the entity to activate.
>   */
> -static void bfq_activate_entity(struct io_entity *entity)
> +static void bfq_activate_entity(struct io_entity *entity, int add_front)
>  {
> -	__bfq_activate_entity(entity);
> +	__bfq_activate_entity(entity, add_front);
>  }
>  
>  /**
