From: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by
	tgid at once
Date: Wed, 05 Aug 2009 18:53:52 +0200
Message-ID: <1249491232.32113.14.camel__29863.2388156422$1249491359$gmane$org@twins>
References: <20090731015154.27908.9639.stgit@hastromil.mtv.corp.google.com>
	<20090803175452.GA5481@us.ibm.com>
	<2f86c2480908031113y525b6cbdhe418b8a0364c7760@mail.gmail.com>
	<20090803185556.GA8469@us.ibm.com> <20090803194555.GA10158@us.ibm.com>
	<6599ad830908041148h6d3f3e9bxfef9f3eedec0ab6d@mail.gmail.com>
	<2f86c2480908041214r1f23c1b7q9a25b04e26c92a1a@mail.gmail.com>
	<6599ad830908041228w67bc6f7fh57e28f244e1923b3@mail.gmail.com>
	<20090805102057.GT29252@hawkmoon.kerlabs.com>
	<6599ad830908050911t6f23f810i65fe8fe17f3ee698@mail.gmail.com>
	<20090805164218.GB26446@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090805164218.GB26446-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2009-08-05 at 18:42 +0200, Louis Rilling wrote:
> On 05/08/09  9:11 -0700, Paul Menage wrote:
> > On Wed, Aug 5, 2009 at 3:20 AM, Louis Rilling<Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org> wrote:
> > >
> > > The downside of this is teaching lockdep about this recursive locking. Not that
> > > simple actually...
> > 
> > Don't we just give each thread's lock its own lock class? That's what
> > we did for the cgroup hierarchy_mutex.
> 
> Given that lock classes must be static and that lockdep only supports a limited
> lock depth, this is an issue for processes having many threads.
> 
> > 
> > > so that such cases are currently handled using a higher-level
> > > lock that prevents races in locking the whole chain (there was one such example
> > > for locking all vmas with KVM). IIUC, the intent here is to avoid such
> > > higher-level lock.
> > 
> > cgroup_mutex already fulfills the role of the higher-level lock.
> 
> If so (that is, here cgroup_mutex is taken before write-locking all threads'
> rw_sem), then enhancing rwsem's interface in a similar way to the
> spin_lock_nest_lock() interface could do it. There will still be an issue with
> many threads and lockdep limited lock depth though.
> 
> Added Peter in CC.

Ah, I recently tinkered with that, see the below commit from -tip.

It should start counting instances instead of tracking each once you
start using the _nest_lock() variant with multiple instances of the same
class.

We loose some precision (can't match exact instance on unlock, and
lockstat looses out), but it keeps lockdep going up to 2048 instances
(those 11 bits).

---
commit bb97a91e2549a7f2df9c21d32542582f549ab3ec
Author: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Date:   Mon Jul 20 19:15:35 2009 +0200

    lockdep: Deal with many similar locks
    
    spin_lock_nest_lock() allows to take many instances of the same
    class, this can easily lead to overflow of MAX_LOCK_DEPTH.
    
    To avoid this overflow, we'll stop accounting instances but
    start reference counting the class in the held_lock structure.
    
    [ We could maintain a list of instances, if we'd move the hlock
      stuff into __lock_acquired(), but that would require
      significant modifications to the current code. ]
    
    We restrict this mode to spin_lock_nest_lock() only, because it
    degrades the lockdep quality due to lost of instance.
    
    For lockstat this means we don't track lock statistics for any
    but the first lock in the series.
    
    Currently nesting is limited to 11 bits because that was the
    spare space available in held_lock. This yields a 2048
    instances maximium.
    
    Signed-off-by: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
    Cc: Marcelo Tosatti <mtosatti-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
    Signed-off-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index a6d5e5e..47d42ef 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -213,10 +213,12 @@ struct held_lock {
 	 * interrupt context:
 	 */
 	unsigned int irq_context:2; /* bit 0 - soft, bit 1 - hard */
-	unsigned int trylock:1;
+	unsigned int trylock:1;						/* 16 bits */
+
 	unsigned int read:2;        /* see lock_acquire() comment */
 	unsigned int check:2;       /* see lock_acquire() comment */
 	unsigned int hardirqs_off:1;
+	unsigned int references:11;					/* 32 bits */
 };
 
 /*
diff --git a/kernel/lockdep.c b/kernel/lockdep.c
index 28914a5..0bb246e 100644
--- a/kernel/lockdep.c
+++ b/kernel/lockdep.c
@@ -2708,13 +2708,15 @@ EXPORT_SYMBOL_GPL(lockdep_init_map);
  */
 static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 			  int trylock, int read, int check, int hardirqs_off,
-			  struct lockdep_map *nest_lock, unsigned long ip)
+			  struct lockdep_map *nest_lock, unsigned long ip,
+			  int references)
 {
 	struct task_struct *curr = current;
 	struct lock_class *class = NULL;
 	struct held_lock *hlock;
 	unsigned int depth, id;
 	int chain_head = 0;
+	int class_idx;
 	u64 chain_key;
 
 	if (!prove_locking)
@@ -2762,10 +2764,24 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 	if (DEBUG_LOCKS_WARN_ON(depth >= MAX_LOCK_DEPTH))
 		return 0;
 
+	class_idx = class - lock_classes + 1;
+
+	if (depth) {
+		hlock = curr->held_locks + depth - 1;
+		if (hlock->class_idx == class_idx && nest_lock) {
+			if (hlock->references)
+				hlock->references++;
+			else
+				hlock->references = 2;
+
+			return 1;
+		}
+	}
+
 	hlock = curr->held_locks + depth;
 	if (DEBUG_LOCKS_WARN_ON(!class))
 		return 0;
-	hlock->class_idx = class - lock_classes + 1;
+	hlock->class_idx = class_idx;
 	hlock->acquire_ip = ip;
 	hlock->instance = lock;
 	hlock->nest_lock = nest_lock;
@@ -2773,6 +2789,7 @@ static int __lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 	hlock->read = read;
 	hlock->check = check;
 	hlock->hardirqs_off = !!hardirqs_off;
+	hlock->references = references;
 #ifdef CONFIG_LOCK_STAT
 	hlock->waittime_stamp = 0;
 	hlock->holdtime_stamp = sched_clock();
@@ -2881,6 +2898,30 @@ static int check_unlock(struct task_struct *curr, struct lockdep_map *lock,
 	return 1;
 }
 
+static int match_held_lock(struct held_lock *hlock, struct lockdep_map *lock)
+{
+	if (hlock->instance == lock)
+		return 1;
+
+	if (hlock->references) {
+		struct lock_class *class = lock->class_cache;
+
+		if (!class)
+			class = look_up_lock_class(lock, 0);
+
+		if (DEBUG_LOCKS_WARN_ON(!class))
+			return 0;
+
+		if (DEBUG_LOCKS_WARN_ON(!hlock->nest_lock))
+			return 0;
+
+		if (hlock->class_idx == class - lock_classes + 1)
+			return 1;
+	}
+
+	return 0;
+}
+
 static int
 __lock_set_class(struct lockdep_map *lock, const char *name,
 		 struct lock_class_key *key, unsigned int subclass,
@@ -2904,7 +2945,7 @@ __lock_set_class(struct lockdep_map *lock, const char *name,
 		 */
 		if (prev_hlock && prev_hlock->irq_context != hlock->irq_context)
 			break;
-		if (hlock->instance == lock)
+		if (match_held_lock(hlock, lock))
 			goto found_it;
 		prev_hlock = hlock;
 	}
@@ -2923,7 +2964,8 @@ found_it:
 		if (!__lock_acquire(hlock->instance,
 			hlock_class(hlock)->subclass, hlock->trylock,
 				hlock->read, hlock->check, hlock->hardirqs_off,
-				hlock->nest_lock, hlock->acquire_ip))
+				hlock->nest_lock, hlock->acquire_ip,
+				hlock->references))
 			return 0;
 	}
 
@@ -2962,20 +3004,34 @@ lock_release_non_nested(struct task_struct *curr,
 		 */
 		if (prev_hlock && prev_hlock->irq_context != hlock->irq_context)
 			break;
-		if (hlock->instance == lock)
+		if (match_held_lock(hlock, lock))
 			goto found_it;
 		prev_hlock = hlock;
 	}
 	return print_unlock_inbalance_bug(curr, lock, ip);
 
 found_it:
-	lock_release_holdtime(hlock);
+	if (hlock->instance == lock)
+		lock_release_holdtime(hlock);
+
+	if (hlock->references) {
+		hlock->references--;
+		if (hlock->references) {
+			/*
+			 * We had, and after removing one, still have
+			 * references, the current lock stack is still
+			 * valid. We're done!
+			 */
+			return 1;
+		}
+	}
 
 	/*
 	 * We have the right lock to unlock, 'hlock' points to it.
 	 * Now we remove it from the stack, and add back the other
 	 * entries (if any), recalculating the hash along the way:
 	 */
+
 	curr->lockdep_depth = i;
 	curr->curr_chain_key = hlock->prev_chain_key;
 
@@ -2984,7 +3040,8 @@ found_it:
 		if (!__lock_acquire(hlock->instance,
 			hlock_class(hlock)->subclass, hlock->trylock,
 				hlock->read, hlock->check, hlock->hardirqs_off,
-				hlock->nest_lock, hlock->acquire_ip))
+				hlock->nest_lock, hlock->acquire_ip,
+				hlock->references))
 			return 0;
 	}
 
@@ -3014,7 +3071,7 @@ static int lock_release_nested(struct task_struct *curr,
 	/*
 	 * Is the unlock non-nested:
 	 */
-	if (hlock->instance != lock)
+	if (hlock->instance != lock || hlock->references)
 		return lock_release_non_nested(curr, lock, ip);
 	curr->lockdep_depth--;
 
@@ -3065,7 +3122,9 @@ static int __lock_is_held(struct lockdep_map *lock)
 	int i;
 
 	for (i = 0; i < curr->lockdep_depth; i++) {
-		if (curr->held_locks[i].instance == lock)
+		struct held_lock *hlock = curr->held_locks + i;
+
+		if (match_held_lock(hlock, lock))
 			return 1;
 	}
 
@@ -3148,7 +3207,7 @@ void lock_acquire(struct lockdep_map *lock, unsigned int subclass,
 
 	current->lockdep_recursion = 1;
 	__lock_acquire(lock, subclass, trylock, read, check,
-		       irqs_disabled_flags(flags), nest_lock, ip);
+		       irqs_disabled_flags(flags), nest_lock, ip, 0);
 	current->lockdep_recursion = 0;
 	raw_local_irq_restore(flags);
 }
@@ -3252,7 +3311,7 @@ __lock_contended(struct lockdep_map *lock, unsigned long ip)
 		 */
 		if (prev_hlock && prev_hlock->irq_context != hlock->irq_context)
 			break;
-		if (hlock->instance == lock)
+		if (match_held_lock(hlock, lock))
 			goto found_it;
 		prev_hlock = hlock;
 	}
@@ -3260,6 +3319,9 @@ __lock_contended(struct lockdep_map *lock, unsigned long ip)
 	return;
 
 found_it:
+	if (hlock->instance != lock)
+		return;
+
 	hlock->waittime_stamp = sched_clock();
 
 	contention_point = lock_point(hlock_class(hlock)->contention_point, ip);
@@ -3299,7 +3361,7 @@ __lock_acquired(struct lockdep_map *lock, unsigned long ip)
 		 */
 		if (prev_hlock && prev_hlock->irq_context != hlock->irq_context)
 			break;
-		if (hlock->instance == lock)
+		if (match_held_lock(hlock, lock))
 			goto found_it;
 		prev_hlock = hlock;
 	}
@@ -3307,6 +3369,9 @@ __lock_acquired(struct lockdep_map *lock, unsigned long ip)
 	return;
 
 found_it:
+	if (hlock->instance != lock)
+		return;
+
 	cpu = smp_processor_id();
 	if (hlock->waittime_stamp) {
 		now = sched_clock();
