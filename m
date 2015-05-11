From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [stable] Locked mount and loopback mount fixes
Date: Mon, 11 May 2015 09:04:52 -0500
Message-ID: <871tinrz0b.fsf__5069.85740871659$1431353393$gmane$org@x220.int.ebiederm.org>
References: <1431280791.2233.50.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1431280791.2233.50.camel-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org> (Ben Hutchings's
	message of "Sun, 10 May 2015 18:59:51 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Konstantin Khlebnikov <koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org> writes:

> Why were these not cc'd to stable?  Was this an oversight, or are they
> simply not needed for fixing any known bugs?
>
> commit cd4a40174b71acd021877341684d8bb1dc8ea4ae
> Author: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Date:   Wed Jan 7 14:28:26 2015 -0600
>
>     mnt: Fail collect_mounts when applied to unmounted mounts
>
> commit 820f9f147dcce2602eefd9b575bbbd9ea14f0953
> Author: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Date:   Thu Apr 2 16:35:48 2015 -0500
>
>     fs_pin: Allow for the possibility that m_list or s_list go unused.


And because I forgot to mark those two patches for stable we are getting
failures like the below in 4.0.2.  My apologies.

Please treat them as if they were marked for stable.

Konstantin Khlebnikov <koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> I've seen crash in 4.0.2 while played with namespaces. This patch helped.
> So, it should be queued into stable@ for sure, but I don't know how
> many kernel versions are affected.
>
>
> [29221.493301] BUG: unable to handle kernel NULL pointer dereference
> at           (null)
> [29221.493396] IP: [<ffffffff811d4ad8>] pin_remove+0x58/0xc0
> [29221.493456] PGD 0
> [29221.493481] Oops: 0002 [#1] SMP
> [29221.493521] Modules linked in: iwldvm iwlwifi nfsd auth_rpcgss
> oid_registry nfs_acl nfs lockd grace sunrpc ipt_MASQUERADE
> nf_nat_masquerade_ipv4 iptable_nat bridge stp llc vfat fat fuse
> snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_codec_generic
> iTCO_wdt intel_powerclamp coretemp kvm_intel uvcvideo kvm
> videobuf2_vmalloc videobuf2_memops videobuf2_core v4l2_common
> snd_hda_intel videodev snd_hda_controller snd_hda_codec snd_hwdep
> snd_pcm i915 lpc_ich mfd_core thinkpad_acpi snd_timer wmi snd
> soundcore drm_kms_helper sdhci_pci sdhci e1000e
> [29221.494197] CPU: 2 PID: 30219 Comm: ct.sh Not tainted 4.0.2-zurg+ #167
> [29221.494291] Hardware name: LENOVO 4291QY6/4291QY6, BIOS 8DET51WW
> (1.21 ) 08/02/2011
> [29221.494392] task: ffff8803cb3e3bf0 ti: ffff8803ebf00000 task.ti:
> ffff8803ebf00000
> [29221.494514] RIP: 0010:[<ffffffff811d4ad8>]  [<ffffffff811d4ad8>]
> pin_remove+0x58/0xc0
> [29221.494655] RSP: 0018:ffff8803ebf03da8  EFLAGS: 00010246
> [29221.494746] RAX: 0000000000000000 RBX: ffff88040ad33620 RCX: 000000000000000d
> [29221.494854] RDX: 0000000000000000 RSI: 0000000000000003 RDI: ffffffff81ed92f0
> [29221.494969] RBP: ffff8803ebf03db8 R08: ffffffff81cf9fa8 R09: 0000000000000246
> [29221.495081] R10: 000000000001e001 R11: 0000000000000000 R12: ffff8803ebf03e08
> [29221.495178] R13: ffff8803cb3e42e0 R14: ffff8803cb3e3bf0 R15: ffff88040a37cd68
> [29221.495260] FS:  00007f02da4f8700(0000) GS:ffff88041e280000(0000)
> knlGS:0000000000000000
> [29221.495343] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [29221.495395] CR2: 0000000000000000 CR3: 0000000002c0d000 CR4: 00000000000407e0
> [29221.495456] Stack:
> [29221.495477]  ffff8803cb3e3bf0 ffff88040ad33620 ffff8803ebf03dd8
> ffffffff811c2f82
> [29221.495554]  ffff8803ebf03df8 ffff88040ad33620 ffff8803ebf03e38
> ffffffff811d4c54
> [29221.495630]  ffffffff81c65b40 ffff880300000000 ffff8803cb3e3bf0
> ffffffff810be600
> [29221.495707] Call Trace:
> [29221.495739]  [<ffffffff811c2f82>] drop_mountpoint+0x22/0x40
> [29221.495773]  [<ffffffff811d4c54>] pin_kill+0x64/0xf0
> [29221.495790]  [<ffffffff810be600>] ? wait_woken+0x90/0x90
> [29221.495806]  [<ffffffff811d4d09>] mnt_pin_kill+0x29/0x40
> [29221.495822]  [<ffffffff811c2410>] cleanup_mnt+0x90/0xa0
> [29221.495838]  [<ffffffff811c2472>] __cleanup_mnt+0x12/0x20
> [29221.495855]  [<ffffffff810a2d67>] task_work_run+0xb7/0xf0
> [29221.495873]  [<ffffffff81089332>] do_exit+0x2d2/0xac0
> [29221.495890]  [<ffffffff811a39d8>] ? __vfs_read+0x18/0x50
> [29221.495905]  [<ffffffff811a3a9a>] ? vfs_read+0x8a/0x120
> [29221.495921]  [<ffffffff8108a887>] do_group_exit+0x47/0xc0
> [29221.495937]  [<ffffffff8108a914>] SyS_exit_group+0x14/0x20
> [29221.495961]  [<ffffffff816da20d>] system_call_fastpath+0x16/0x1b
> [29221.495978] Code: 48 89 50 08 48 b8 00 01 10 00 00 00 ad de 48 8b
> 53 28 48 89 43 30 48 b8 00 02 20 00 00 00 ad de 48 89 43 38 48 8b 43
> 20 48 85 c0 <48> 89 02 74 04 48 89 50 08 48 b8 00 01 10 00 00 00 ad de
> 48 89
> [29221.496108] RIP  [<ffffffff811d4ad8>] pin_remove+0x58/0xc0
> [29221.496126]  RSP <ffff8803ebf03da8>
> [29221.496136] CR2: 0000000000000000
>
> On Fri, Apr 3, 2015 at 4:56 AM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>> This is needed to support lazily umounting locked mounts.  Because the
>> entire unmounted subtree needs to stay together until there are no
>> users with references to any part of the subtree.
>>
>> To support this guarantee that the fs_pin m_list and s_list nodes
>> are initialized by initializing them in init_fs_pin allowing
>> for the possibility that pin_insert_group does not touch them.
>>
>> Further use hlist_del_init in pin_remove so that there is
>> a hlist_unhashed test before the list we attempt to update
>> the previous list item.
>>
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>>  fs/fs_pin.c            | 4 ++--
>>  include/linux/fs_pin.h | 2 ++
>>  2 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/fs_pin.c b/fs/fs_pin.c
>> index b06c98796afb..611b5408f6ec 100644
>> --- a/fs/fs_pin.c
>> +++ b/fs/fs_pin.c
>> @@ -9,8 +9,8 @@ static DEFINE_SPINLOCK(pin_lock);
>>  void pin_remove(struct fs_pin *pin)
>>  {
>>         spin_lock(&pin_lock);
>> -       hlist_del(&pin->m_list);
>> -       hlist_del(&pin->s_list);
>> +       hlist_del_init(&pin->m_list);
>> +       hlist_del_init(&pin->s_list);
>>         spin_unlock(&pin_lock);
>>         spin_lock_irq(&pin->wait.lock);
>>         pin->done = 1;
>> diff --git a/include/linux/fs_pin.h b/include/linux/fs_pin.h
>> index 9dc4e0384bfb..3886b3bffd7f 100644
>> --- a/include/linux/fs_pin.h
>> +++ b/include/linux/fs_pin.h
>> @@ -13,6 +13,8 @@ struct vfsmount;
>>  static inline void init_fs_pin(struct fs_pin *p, void (*kill)(struct fs_pin *))
>>  {
>>         init_waitqueue_head(&p->wait);
>> +       INIT_HLIST_NODE(&p->s_list);
>> +       INIT_HLIST_NODE(&p->m_list);
>>         p->kill = kill;
>>  }
>>
>> --
>> 2.2.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
