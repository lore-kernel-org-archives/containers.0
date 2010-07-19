From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: multi-threaded app fails to restart
Date: Mon, 19 Jul 2010 14:54:45 -0500
Message-ID: <1279569285.25071.98.camel@localhost>
References: <AANLkTilxfsYGyYLwO__VmDLSFQ_s_Qe03G49kIEztVja@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTilxfsYGyYLwO__VmDLSFQ_s_Qe03G49kIEztVja-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: John Paul Walters <jpnwalters-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2010-07-19 at 15:36 -0400, John Paul Walters wrote:
> [ 3210.327227] pthread_test[4033]: segfault at b781f424 ip b781f424 sp
> b75cc1c0 error 4
> [ 3210.330254] [4031:4031:c/r:wait_task_sync:919] task sync done (errno 0)
> [ 3210.330257] [4031:4031:c/r:clear_task_ctx:852] task 4031 clear checkpoint_ctx
> [ 3210.330259] [4031:4031:c/r:restore_debug_free:144] 4 tasks
> registered, nr_tasks was 0 nr_total 0
> [ 3210.330261] [4031:4031:c/r:restore_debug_free:147] active pid was
> 2, ctx->errno 0
> [ 3210.330263] [4031:4031:c/r:restore_debug_free:149] kflags 22 uflags
> 0 oflags 1
> [ 3210.330265] [4031:4031:c/r:restore_debug_free:151] task[0] to run 4031
> [ 3210.330267] [4031:4031:c/r:restore_debug_free:151] task[1] to run 4033
> [ 3210.330269] [4031:4031:c/r:restore_debug_free:176] pid 4029 type
> Coord state Success
> [ 3210.330272] [4031:4031:c/r:restore_debug_free:176] pid 4031 type
> Root state Success
> [ 3210.330274] [4031:4031:c/r:restore_debug_free:176] pid 4033 type
> Task state Success
> [ 3210.330276] [4031:4031:c/r:restore_debug_free:176] pid 4032 type
> Ghost state Success
> [ 3210.330285] [4031:4031:c/r:pgarr_release_pages:102] total pages 0
> [ 3210.330288] [4031:4031:c/r:do_restart:1451] sys_restart returns -512
> 
> Any thoughts?

There were two patches posted to the containers list on 11 July - "fix
task tree traversal for threads" and "save/restore 'sysenter_return' for
threads".  Can you try with those on top of ckpt-v22-dev?
