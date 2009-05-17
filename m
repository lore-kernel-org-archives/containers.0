From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [C/R] threaded application
Date: Sat, 16 May 2009 19:31:25 -0700
Message-ID: <20090517023125.GA30716@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Probably premature :-) but tried to C/R a simple threaded application
(running as container-init).

First got an -EINVAL due to following check in may_checkpoint_task():

        /*
         * FIX: for now, disallow siblings of container init created
         * via CLONE_PARENT (unclear if they will remain possible)
         */
        if (ctx->root_init && t != ctx->root_task &&
            t->real_parent == ctx->root_task->real_parent)

Assuming we are unintentionally excluding CLONE_THREAD with the
above check, I added a check for tgid:

        if (ctx->root_init && t != ctx->root_task &&
            t->real_parent == ctx->root_task->real_parent &&
            t->tgid != ctx->root_task->tgid) {

This got past the -EINVAL but the test failed the ckpt_obj_contained() check.

	c/r: FILE users 2 != count 6 objref 9

The main-thread opened a single file (log file). The other threads don't
write to it (yet). The count '6' corresponds to the number of threads in
the application.

I suspect that C/R code is incrementing obj->users once per thread for
the log file even though the threads share the file_struct reference.
(pthread_create() sets CLONE_FILES so the file_struct is shared between
threads).

Will post my test programs to Serge's new git-tree next week.

Sukadev
