From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 1/2] list.h: add debug version of list_empty
Date: Mon, 21 Mar 2011 16:52:06 -0700
Message-ID: <20110321165206.1deaf0ab.akpm__99.5214483284101$1300752571$gmane$org@linux-foundation.org>
References: <1300194523-19325-1-git-send-email-ext-phil.2.carmody@nokia.com>
	<1300194523-19325-2-git-send-email-ext-phil.2.carmody@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1300194523-19325-2-git-send-email-ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 15 Mar 2011 15:08:42 +0200
Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org> wrote:

> Heed the notice in list_del: "Note: list_empty() on entry does not
> return true after this, the entry is in an undefined state.", and
> check for precisely that condition.
> 
> There are currently a few instances in the code of this sequence:
>     if(!list_empty(pnode))
>         list_del(pnode);
> which seems to be useless or dangerous if intended to protect from
> repeated del's. And given that I've seen an oops pointing to a
> dereference of poison in such a list_empty, I'm veering towards
> dangerous. This patch would make such errors obvious.
> 
> Nothing is changed in the non-DEBUG_LIST build.
> 
> ...
>
> +
> +/**
> + * list_empty - tests whether a list is empty
> + * @head: the list to test.
> + */
> +int list_empty(const struct list_head *head)
> +{
> +	if ((head->prev == LIST_POISON2) || (head->prev == LIST_POISON1))
> +		WARN(1, "list_empty performed on a node "
> +		     "at %p removed from a list.\n", head);
> +	else
> +		WARN((head->prev == head) != (head->next == head),
> +		     "list_empty corruption. %p<-%p->%p is half-empty.\n",
> +		     head->prev, head, head->next);
> +
> +	return head->next == head;
> +}
> +EXPORT_SYMBOL(list_empty);

The second warning here is triggering maybe a hundred times from all
over the place just when booting the kernel.

Here's the first two:


[   64.295941] WARNING: at lib/list_debug.c:89 list_empty+0x79/0x85()
[   64.296129] list_empty corruption. ffff880255bcb788<-ffff880255bcb788->ffff88024c3a3c20 is half-empty.
[   64.296443] Modules linked in: autofs4 sunrpc ipv6 dm_mirror dm_region_hash dm_log dm_multipath dm_mod video sbs sbshc battery ac lp parport sg option usb_wwan ide_cd_mod cdrom usbserial serio_raw floppy snd_hda_intel snd_hda_codec snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device button snd_pcm_oss snd_mixer_oss snd_pcm snd_timer i2c_i801 i2c_core snd soundcore snd_page_alloc shpchp pcspkr ehci_hcd ohci_hcd uhci_hcd
[   64.299193] Pid: 3637, comm: cp Tainted: G        W   2.6.38 #1
[   64.299363] Call Trace:
[   64.299531]  [<ffffffff81037ba4>] warn_slowpath_common+0x80/0x98
[   64.299700]  [<ffffffff81037c50>] warn_slowpath_fmt+0x41/0x43
[   64.299887]  [<ffffffff811af661>] list_empty+0x79/0x85
[   64.300074]  [<ffffffff81383581>] unix_write_space+0xa5/0x10e
[   64.300246]  [<ffffffff813834dc>] ? unix_write_space+0x0/0x10e
[   64.300418]  [<ffffffff812fc62a>] sock_wfree+0x31/0x51
[   64.300586]  [<ffffffff81381bef>] unix_destruct_scm+0xc0/0xcd
[   64.300755]  [<ffffffff812feef6>] skb_release_head_state+0x7f/0xb0
[   64.300928]  [<ffffffff8130035a>] __kfree_skb+0x11/0x7c
[   64.301096]  [<ffffffff813003ed>] consume_skb+0x28/0x2a
[   64.301264]  [<ffffffff813826eb>] unix_stream_recvmsg+0x5ad/0x778
[   64.301450]  [<ffffffff810508a2>] ? autoremove_wake_function+0x0/0x38
[   64.301623]  [<ffffffff812f76c2>] sock_aio_read+0x148/0x160
[   64.301793]  [<ffffffff81172bb9>] ? file_has_perm+0x90/0x9e
[   64.301961]  [<ffffffff812f757a>] ? sock_aio_read+0x0/0x160
[   64.302130]  [<ffffffff810d2a9b>] do_sync_readv_writev+0xbc/0xfb
[   64.302303]  [<ffffffff81170840>] ? security_file_permission+0x80/0x89
[   64.302472]  [<ffffffff810d3116>] do_readv_writev+0xb6/0x182
[   64.302641]  [<ffffffff812f8896>] ? sys_connect+0x78/0x9e
[   64.302822]  [<ffffffff810d3355>] vfs_readv+0x3e/0x49
[   64.302989]  [<ffffffff810d341f>] sys_readv+0x48/0x72
[   64.303158]  [<ffffffff813b323b>] system_call_fastpath+0x16/0x1b
[   64.303326] ---[ end trace 713534840f2a9415 ]---
[  180.120065] ------------[ cut here ]------------
[  180.120154] WARNING: at lib/list_debug.c:89 list_empty+0x79/0x85()
[  180.120213] list_empty corruption. ffff88025fefd9d0<-ffff88025fefd9d0->ffff880235647c20 is half-empty.
[  180.120306] Modules linked in: autofs4 sunrpc ipv6 dm_mirror dm_region_hash dm_log dm_multipath dm_mod video sbs sbshc battery ac lp parport sg option usb_wwan ide_cd_mod cdrom usbserial serio_raw floppy snd_hda_intel snd_hda_codec snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device button snd_pcm_oss snd_mixer_oss snd_pcm snd_timer i2c_i801 i2c_core snd soundcore snd_page_alloc shpchp pcspkr ehci_hcd ohci_hcd uhci_hcd
[  180.122547] Pid: 6241, comm: sh Tainted: G        W   2.6.38 #1
[  180.122603] Call Trace:
[  180.122670]  [<ffffffff81037ba4>] warn_slowpath_common+0x80/0x98
[  180.122728]  [<ffffffff81037c50>] warn_slowpath_fmt+0x41/0x43
[  180.122785]  [<ffffffff81055b73>] ? local_clock+0x2b/0x3c
[  180.122841]  [<ffffffff811af661>] list_empty+0x79/0x85
[  180.122906]  [<ffffffff8105085c>] __wake_up_bit+0x1c/0x3d
[  180.122964]  [<ffffffff810938d4>] unlock_page+0x25/0x29
[  180.123020]  [<ffffffff810aaa16>] __do_fault+0x3da/0x411
[  180.123077]  [<ffffffff810ab5c0>] handle_pte_fault+0x289/0x79a
[  180.123146]  [<ffffffff813ad8d8>] ? _raw_spin_unlock+0x26/0x2a
[  180.123205]  [<ffffffff810acf19>] handle_mm_fault+0x1c6/0x1de
[  180.123263]  [<ffffffff813b0931>] do_page_fault+0x3cc/0x3f1
[  180.123320]  [<ffffffff813adb40>] ? restore_args+0x0/0x30
[  180.123388]  [<ffffffff811ab27d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  180.123445]  [<ffffffff813add2f>] page_fault+0x1f/0x30
[  180.123501] ---[ end trace 713534840f2a9416 ]---
