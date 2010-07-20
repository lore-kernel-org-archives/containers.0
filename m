From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: multi-threaded app fails to restart
Date: Tue, 20 Jul 2010 19:12:40 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.1007201906370.15255@takamine.ncl.cs.columbia.edu>
References: <AANLkTilxfsYGyYLwO__VmDLSFQ_s_Qe03G49kIEztVja@mail.gmail.com>
	<1279569285.25071.98.camel@localhost>
	<AANLkTimpXSXQr1wew1wvZKnBFsOXD7f2tblY4EGmJoFM@mail.gmail.com>
	<4C4516DD.1000809@cs.columbia.edu>
	<AANLkTimPENgm-LSh6iMv2uxegRdHEivbGMTYmEfiOEJG@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <AANLkTimPENgm-LSh6iMv2uxegRdHEivbGMTYmEfiOEJG-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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


Hi John

In your program, it is a thread of the root task (of the hierarchy)
that is missed. Indeed the previous patch was incomplete - it did
fix the non-root-threads case but spoiled the root-threads case.
That was silly... well, can you try this little patch:

Thanks for following up, was very helpful !

Oren.

---
diff --git a/kernel/checkpoint/sys.c b/kernel/checkpoint/sys.c
index 171c867..3288af0 100644
--- a/kernel/checkpoint/sys.c
+++ b/kernel/checkpoint/sys.c
@@ -605,13 +605,13 @@ int walk_task_subtree(struct task_struct *root,
 			continue;
 		}
 
+		/* if not last thread - proceed with thread */
+		task = next_thread(task);
+		if (!thread_group_leader(task))
+			continue;
+
 		/* by definition, skip siblings of root */
 		while (task != root) {
-			/* if not last thread - proceed with thread */
-			task = next_thread(task);
-			if (!thread_group_leader(task))
-				break;
-
 			/* if has sibling - proceed with sibling */
 			if (!list_is_last(&task->sibling, &parent->children)) {
 				task = list_entry(task->sibling.next,
---

On Tue, 20 Jul 2010, John Paul Walters wrote:

> >
> > Hi John,
> >
> > I just pushed a few more fixes related to signals to ckpt-v22-dev.
> > Can you please see if they fix your problem ?
> >
> > Also, can you please post the test program that you are using, so
> > we can try to replicate the problem ?
> >
> > Note that it is usually ok for sys_restart() to return -512 -- it
> > means that the process/thread was interrupted when the checkpoint,
> > and it will now retry the same syscall from then.
> >
> > You can use the -F (--freezer) switch of restart(1) to freeze the
> > restarted tasks/threads before they are allowed to run in userspace.
> > Using it you can tell whether the other thread dies immediately
> > after restart, or is not at all restarted.
> >
> > Thanks,
> >
> > Oren.
> >
> 
> Hi Oren,
> 
> I grabbed the most recent v22-dev that includes the updates.  I'm
> still experiencing the same issue.  Testing with -F indicates that the
> second thread isn't being restarted.  The code that I'm using is:
> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <pthread.h>
> #include <sys/syscall.h>
> #include <errno.h>
> #include <string.h>
> #include <unistd.h>
> 
> #define OUTFILE "/tmp/cr-self.out"
> 
> void *
> func (void *arg)
> {
>   FILE *file;
>   int counter = 0;
> 
>   file = fopen(OUTFILE, "w+");
> 
>     while (1){
>         sleep(2);
>         counter++;
>         fprintf(file, "Count %d\n", counter);
>         fflush(file);
>     }
> 
> return NULL;
> }
> 
> int
> main (int argc, char **argv)
> {
>   pthread_t thread;
>   close (0);
>   close (1);
>   close (2);
>   unlink (OUTFILE);
> 
>   pthread_create(&thread, NULL, func, NULL);
>   pthread_join(thread, NULL);
>   return 0;
> }
> 
> Thanks for your help,
> JP
> 
> 
