From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add support for the per-task sem_undo list (v2)
Date: Wed, 04 Aug 2010 13:17:12 -0700
Message-ID: <87pqxyku9j.fsf@caffeine.danplanet.com>
References: <1280941345-27566-1-git-send-email-danms@us.ibm.com>
	<1280941345-27566-3-git-send-email-danms@us.ibm.com>
	<4C59B625.7000007@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4C59B625.7000007-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Wed\, 04 Aug 2010 14\:49\:09 -0400")
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

>> +static void put_undo_list(struct sem_undo_list *ulp);

OL> nit: to me it makes more sense to move
OL> grab/drop/checkpoint/restart code, as well sem_init(), to the end
OL> of the file (and avoid those statics...).

Okay, was trying to avoid chopping the file up too much.

OL> Can get rid of ..._users() since we don't collect them.

Oops :)

OL> semadj is short, so:
OL> s/__u16/__s16/

Gah, yeah, I always want everything to be unsigned for some reason :D

>> -		sma = sem_lock_check(tsk->nsproxy->ipc_ns, un->semid);
>> +		sma = sem_lock_check(ulp->ipc_ns, un->semid);

OL> This hunk belongs to previous patch, no ?

It could, but it seems more relevant when converting the function from
using a task to using just the undo_list itself...

>> +	atomic_inc(&ulp->refcnt);

OL> I suspect there is a leak here: atomic_inc is needed only for
OL> tasks other than the first task; The first task already gets the
OL> refcount deep inside find_alloc_undo(), and the hash-table gets
OL> its ref via the obj->grab method.

But then it drops that ref right after it inserts it, thus we need
another one, right?.  I think the confusion may come from the fact
that the hash assumes the first refcount is its own and the caller of
restore_obj() will grab another (for the task, in this case).  Since
we don't do that, we need to grab both early on.  I hit this in
another place in the network stuff, IIRC, which generated a similar
review comment ;)

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
