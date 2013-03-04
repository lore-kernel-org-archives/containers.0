From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 1/2] userns: Stop oopsing in key_change_session_keyring
Date: Sun, 03 Mar 2013 23:50:15 -0800
Message-ID: <87ehfvmwnc.fsf_-_@xmission.com>
References: <CAGXu5jK7x+gFKgCN5=ZF+kSc4xSNbGtSERHCoOnCEgiJ1_wNGg@mail.gmail.com>
	<20130303005700.GA32213@austin.hallyn.com>
	<874ngtxgt5.fsf@xmission.com>
	<CAGXu5j+bwUx6r++ttvYg4yJrUUHxoQ86tQ0JzEBoQQU6KAh9ww@mail.gmail.com>
	<874ngsrvrh.fsf@xmission.com>
	<CAGXu5jJiO=BmjVbpVJhxHbafn5T_SQbe5g-RLxRbmknNnQMyfQ@mail.gmail.com>
	<87k3pnmwpk.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k3pnmwpk.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Sun, 03 Mar 2013 23:48:55 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kees Cook <keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Brad Spengler <spender-JNS0hek0TMl4qEwOxq4T+Q@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, PaX Team <pageexec-Y8qEzhMunLyT9ig0jae3mg@public.gmane.org>, Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> Just hit this on Linus' current tree.
>
> [   89.621770] BUG: unable to handle kernel NULL pointer dereference at 00000000000000c8
> [   89.623111] IP: [<ffffffff810784b0>] commit_creds+0x250/0x2f0
> [   89.624062] PGD 122bfd067 PUD 122bfe067 PMD 0
> [   89.624901] Oops: 0000 [#1] PREEMPT SMP
> [   89.625678] Modules linked in: caif_socket caif netrom bridge hidp 8021q garp stp mrp rose llc2 af_rxrpc phonet af_key binfmt_misc bnep l2tp_ppp can_bcm l2tp_core pppoe pppox can_raw scsi_transport_iscsi ppp_generic slhc nfnetlink can ipt_ULOG ax25 decnet irda nfc rds x25 crc_ccitt appletalk atm ipx p8023 psnap p8022 llc lockd sunrpc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack nf_conntrack ip6table_filter ip6_tables btusb bluetooth snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_pcm vhost_net snd_page_alloc snd_timer tun macvtap usb_debug snd rfkill microcode macvlan edac_core pcspkr serio_raw kvm_amd soundcore kvm r8169 mii
> [   89.637846] CPU 2
> [   89.638175] Pid: 782, comm: trinity-main Not tainted 3.8.0+ #63 Gigabyte Technology Co., Ltd. GA-MA78GM-S2H/GA-MA78GM-S2H
> [   89.639850] RIP: 0010:[<ffffffff810784b0>]  [<ffffffff810784b0>] commit_creds+0x250/0x2f0
> [   89.641161] RSP: 0018:ffff880115657eb8  EFLAGS: 00010207
> [   89.641984] RAX: 00000000000003e8 RBX: ffff88012688b000 RCX: 0000000000000000
> [   89.643069] RDX: 0000000000000000 RSI: ffffffff81c32960 RDI: ffff880105839600
> [   89.644167] RBP: ffff880115657ed8 R08: 0000000000000000 R09: 0000000000000000
> [   89.645254] R10: 0000000000000001 R11: 0000000000000246 R12: ffff880105839600
> [   89.646340] R13: ffff88011beea490 R14: ffff88011beea490 R15: 0000000000000000
> [   89.647431] FS:  00007f3ac063b740(0000) GS:ffff88012b200000(0000) knlGS:0000000000000000
> [   89.648660] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   89.649548] CR2: 00000000000000c8 CR3: 0000000122bfc000 CR4: 00000000000007e0
> [   89.650635] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [   89.651723] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [   89.652812] Process trinity-main (pid: 782, threadinfo ffff880115656000, task ffff88011beea490)
> [   89.654128] Stack:
> [   89.654433]  0000000000000000 ffff8801058396a0 ffff880105839600 ffff88011beeaa78
> [   89.655769]  ffff880115657ef8 ffffffff812c7d9b ffffffff82079be0 0000000000000000
> [   89.657073]  ffff880115657f28 ffffffff8106c665 0000000000000002 ffff880115657f58
> [   89.658399] Call Trace:
> [   89.658822]  [<ffffffff812c7d9b>] key_change_session_keyring+0xfb/0x140
> [   89.659845]  [<ffffffff8106c665>] task_work_run+0xa5/0xd0
> [   89.660698]  [<ffffffff81002911>] do_notify_resume+0x71/0xb0
> [   89.661581]  [<ffffffff816c9a4a>] int_signal+0x12/0x17
> [   89.662385] Code: 24 90 00 00 00 48 8b b3 90 00 00 00 49 8b 4c 24 40 48 39 f2 75 08 e9 83 00 00 00 48 89 ca 48 81 fa 60 29 c3 81 0f 84 41 fe ff ff <48> 8b 8a c8 00 00 00 48 39 ce 75 e4 3b 82 d0 00 00 00 0f 84 4b
> [   89.667778] RIP  [<ffffffff810784b0>] commit_creds+0x250/0x2f0
> [   89.668733]  RSP <ffff880115657eb8>
> [   89.669301] CR2: 00000000000000c8
>
> My fastest trinity induced oops yet!
>
>
> Appears to be..
>
>                 if ((set_ns == subset_ns->parent)  &&
>      850:       48 8b 8a c8 00 00 00    mov    0xc8(%rdx),%rcx
>
> from the inlined cred_cap_issubset

By historical accident we have been reading trying to set new->user_ns
from new->user_ns.  Which is totally silly as new->user_ns is NULL (as
is every other field in new except session_keyring at that point).

The intent is clearly to copy all of the fields from old to new so copy
old->user_ns into  into new->user_ns.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Reported-by: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Tested-by: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 security/keys/process_keys.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index 58dfe08..a571fad 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -839,7 +839,7 @@ void key_change_session_keyring(struct callback_head *twork)
 	new-> sgid	= old-> sgid;
 	new->fsgid	= old->fsgid;
 	new->user	= get_uid(old->user);
-	new->user_ns	= get_user_ns(new->user_ns);
+	new->user_ns	= get_user_ns(old->user_ns);
 	new->group_info	= get_group_info(old->group_info);
 
 	new->securebits	= old->securebits;
-- 
1.7.5.4
