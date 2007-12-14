From: "Dmitry Adamushko" <dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Re: Hang with fair cgroup scheduler (reproducer is attached.)
Date: Fri, 14 Dec 2007 20:51:28 +0100
Message-ID: <b647ffbd0712141151k697d9bbemda9a7e90515e4400@mail.gmail.com>
References: <20071214141528.GA6161@linux.vnet.ibm.com>
	<20071214161834.034e6efe.kamezawa.hiroyu@jp.fujitsu.com>
	<20071214171759.59f7ba57.kamezawa.hiroyu@jp.fujitsu.com>
	<20071214094909.GG11266@elte.hu>
	<20071214195837.0d3511db.kamezawa.hiroyu@jp.fujitsu.com>
	<b647ffbd0712140447kfba5945ybde40f18653dd164@mail.gmail.com>
	<20442799.1197642268756.kamezawa.hiroyu@jp.fujitsu.com>
	<20071214153607.GB23670@linux.vnet.ibm.com>
	<20071214153823.GC23670@linux.vnet.ibm.com>
	<b647ffbd0712140825h4f541be0xa7a7866e70b3af7a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <b647ffbd0712140825h4f541be0xa7a7866e70b3af7a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

> [ ... ]
>
>  [<a0000001002e0480>] rb_erase+0x300/0x7e0
>  [<a000000100076290>] __dequeue_entity+0x70/0xa0
>  [<a000000100076300>] set_next_entity+0x40/0xa0
>  [<a0000001000763a0>] set_curr_task_fair+0x40/0xa0
>  [<a000000100078d90>] sched_move_task+0x2d0/0x340
>  [<a000000100078e20>] cpu_cgroup_attach+0x20/0x40
>
> [ ... ]

argh... it's a consequence of the 'current is not kept within the tree" indeed.

When sched_move_task() is called for the 'current' (running on another CPU),
we get the following:

...
        running = task_running(rq, tsk);
        on_rq = tsk->se.on_rq;

        if (on_rq) {
                dequeue_task(rq, tsk, 0);
                if (unlikely(running))
                        tsk->sched_class->put_prev_task(rq, tsk);
        }

[1]  tsk->sched_class->put_prev_task() actually _inserts_ 'tsk' back
into the cfs_rq of its _old_ group :

        set_task_cfs_rq(tsk, task_cpu(tsk));

[2] now task.se->cfs_rq gets changed

        if (on_rq) {
                if (unlikely(running))
                        tsk->sched_class->set_curr_task(rq);

[3] and now,  tsk->sched_class->set_curr_task(rq) _removes_ the
'current' from the tree... but this tree belongs to the _new_ group
(the task is still within the 'old_group->cfs_rq->rb_tree') ---> oops!

                enqueue_task(rq, tsk, 0);
        }

Anyway, I have to admit that this problem is a consequence of the
special-case treatment for the 'current' by
'dequeue/enqueue_task()'... it makes the interface less transparent
indeed.

/me thinking on how to get it fixed (e.g. set_task_cfs_rq() might take
care of it) or just get this special-case issue removed (have to check
whether we lose anything in this case)... sigh.


-- 
Best regards,
Dmitry Adamushko
