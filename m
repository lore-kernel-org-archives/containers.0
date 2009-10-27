From: Liu Aleaxander <aleaxander-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [c/r]A problem met when using linux c/r
Date: Tue, 27 Oct 2009 11:14:14 +0800
Message-ID: <b741c2440910262014t46097490kf54c5890e02cb316@mail.gmail.com>
References: <b741c2440910260416r5d045024wdb5a68b2311561db@mail.gmail.com>
	<4AE642D7.1070801@cs.columbia.edu>
	<b741c2440910261921q77e0b5bbqbc0ee1f74974ee5e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <b741c2440910261921q77e0b5bbqbc0ee1f74974ee5e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Oct 27, 2009 at 10:21 AM, Liu Aleaxander <aleaxander-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>wrote:

>
> And here is a small dump of dmesg:
>
> Oh, sorry, the dump is old(I hadn't complied the kernel with the new patch
yet); here is the new one:
[2880:2880:c/r:ckpt_read_obj:370] type 1 len 72(72,72)
[2880:2880:c/r:_ckpt_read_obj:262] type 4 len 73(73,73)
[2880:2880:c/r:_ckpt_read_obj:262] type 4 len 73(73,73)
[2880:2880:c/r:_ckpt_read_obj:262] type 4 len 73(73,73)
[2880:2880:c/r:ckpt_read_obj:370] type 2 len 16(16,16)
[2880:2880:c/r:do_restore_coord:1185] restore header: 0
[2880:2880:c/r:ckpt_read_obj:370] type 3 len 8(8,8)
[2880:2880:c/r:do_restore_coord:1189] restore container: 0
[2880:2880:c/r:ckpt_read_obj:370] type 101 len 16(16,16)
[2880:2880:c/r:_ckpt_read_obj:262] type 4 len 32(32,32)
[2880:2880:c/r:do_restore_coord:1193] restore tree: 24
[2880:2880:c/r:do_restore_coord:1227] pre restore task: 0
[2880:2880:c/r:ckpt_read_obj:370] type 102 len 64(64,64)
[2880:2880:c/r:_ckpt_read_obj:262] type 5 len 24(24,24)
[2880:2880:c/r:restore_task:879] task 0
[2880:2880:c/r:do_restore_coord:1231] restore task: -22
[2880:2880:c/r:walk_task_subtree:338] total 0 ret 0
[2880:2880:c/r:clear_task_ctx:772] task 2880 clear checkpoint_ctx
[2880:2880:c/r:do_restart:1367] restart err -22, exiting
[2880:2880:c/r:do_restart:1374] sys_restart returns -22
[2880:2880:c/r:restore_debug_free:141] 1 tasks registered, nr_tasks was 0
nr_total 0
[2880:2880:c/r:restore_debug_free:144] active pid was -1, ctx->errno -22
[2880:2880:c/r:restore_debug_free:146] kflags 10 uflags 1 oflags 1
[2880:2880:c/r:restore_debug_free:173] pid 2880 type Coord state Failed



-- 
regards
Liu Aleaxander
