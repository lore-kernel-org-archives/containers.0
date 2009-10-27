From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [c/r]A problem met when using linux c/r
Date: Tue, 27 Oct 2009 09:47:52 -0400
Message-ID: <4AE6FA08.9080905@librato.com>
References: <b741c2440910260416r5d045024wdb5a68b2311561db@mail.gmail.com>	<4AE642D7.1070801@cs.columbia.edu>
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
To: Liu Aleaxander <aleaxander-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Liu,


Liu Aleaxander wrote:
> I checked it again(BTW, I found some new typos, too; I'll patch it later),
> but it didn't work either. while, at least, it succeed in checkpointing, but
> failed in restarting. A error statement followed just by the restart
> command:
> $ ./self_restart < self.image
> Killed
> 
> And here is a small dump of dmesg:
> [4959:4959:c/r:ckpt_read_obj:367] type 1 len 72(72,72)
> [4959:4959:c/r:_ckpt_read_obj:259] type 4 len 73(73,73)
> [4959:4959:c/r:_ckpt_read_obj:259] type 4 len 73(73,73)
> [4959:4959:c/r:_ckpt_read_obj:259] type 4 len 73(73,73)
> [4959:4959:c/r:ckpt_read_obj:367] type 2 len 16(16,16)
> [4959:4959:c/r:do_restore_coord:1176] restore header: 0
> [4959:4959:c/r:ckpt_read_obj:367] type 3 len 8(8,8)
> [4959:4959:c/r:do_restore_coord:1180] restore container: 0
> [4959:4959:c/r:ckpt_read_obj:367] type 101 len 16(16,16)
> [4959:4959:c/r:_ckpt_read_obj:259] type 4 len 32(32,32)
> [4959:4959:c/r:do_restore_coord:1184] restore tree: 24
> [4959:4959:c/r:do_restore_coord:1218] pre restore task: 0
> [4959:4959:c/r:ckpt_read_obj:367] type 102 len 64(64,64)
> [4959:4959:c/r:_ckpt_read_obj:259] type 5 len 24(24,24)
> [4959:4959:c/r:restore_task:879] task 0
> [4959:4959:c/r:do_restore_coord:1222] restore task: -22
> [4959:4959:c/r:walk_task_subtree:338] total 0 ret 0
> [4959:4959:c/r:clear_task_ctx:763] task 4959 clear checkpoint_ctx
> [4959:4959:c/r:do_restart:1347] restart err -22, exiting
> [4959:4959:c/r:do_restart:1354] sys_restart returns -22
> [4959:4959:c/r:restore_debug_free:141] 1 tasks registered, nr_tasks was 0
> nr_total 0
> [4959:4959:c/r:restore_debug_free:144] active pid was -1, ctx->errno -22
> [4959:4959:c/r:restore_debug_free:146] kflags 10 uflags 1 oflags 1
> [4959:4959:c/r:restore_debug_free:173] pid 4959 type Coord state Failed
> 

Please try this patch:

commit 7a7048d9ec8d9f74e7521eb9756d24f24767a024
Author: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Date:   Tue Oct 27 09:42:28 2009 -0400

    c/r: self-restart to tolerate missing pgid

    In self-restart we don't generate ghost tasks. Instead we permit
    undefined pgid - tolerate inability to restore the pgid of the
    restarting process.

    Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

diff --git a/checkpoint/process.c b/checkpoint/process.c
index 6b2ef4c..8e4a823 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -823,6 +823,10 @@ static int restore_task_pgid(struct ckpt_ctx *ctx)
 	}
 	write_unlock_irq(&tasklist_lock);

+	/* self-restart: be tolerant if old pgid isn't found */
+	if (ctx->uflags & RESTART_TASKSELF)
+		ret = 0;
+
 	return ret;
 }
