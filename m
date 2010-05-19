From: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
Subject: scheduler: cleanup sched.c and extract cgroup_cpuaccount stuff into
	separate file
Date: Wed, 19 May 2010 20:58:57 +0200
Message-ID: <1274295539-7798-1-git-send-email-trenn__31619.1955855631$1274295621$gmane$org@suse.de>
References: <1274264877.5605.10541.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1274264877.5605.10541.camel@twins>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: trenn-l3A5Bk7waGM@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mike-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

The first patch should only be moving code.
To be able to access cpu_rq in sched.c:
raw_spin_lock_irq(&cpu_rq(cpu)->lock);

void unlock_runqueue(unsigned int cpu)
wrapper is added and kernel/sched.h created.

The locks and sched.h are removed again in the second
patch, this should be the only "real" change.
There atomic64_t is introduced in a per_cpu_ptr variable
to avoid the lock.
Not sure about allocating atomic64_t like that is
correct. Review is appreciated.
Both patches are compile tested on various archs and configs.

       Thomas
