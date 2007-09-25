From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] allow "unlimited" limit value.
Date: Tue, 25 Sep 2007 12:07:58 -0700 (PDT)
Message-ID: <alpine.DEB.0.9999.0709251205390.19001@chino.kir.corp.google.com>
References: <20070925193900.1af6d871.kamezawa.hiroyu@jp.fujitsu.com>
	<46F8E7AE.2090309@linux.vnet.ibm.com>
	<20070925202954.4e477564.kamezawa.hiroyu@jp.fujitsu.com>
	<46F8F6FE.7040006@linux.vnet.ibm.com> <46F907CE.1060807@openvz.org>
	<46F90DCA.5030209@linux.vnet.ibm.com> <46F90E48.6080603@openvz.org>
	<20070926000510.7d956db8.kamezawa.hiroyu@jp.fujitsu.com>
	<46F925ED.20303@openvz.org>
	<20070926003056.7df087a0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070926003056.7df087a0.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 26 Sep 2007, KAMEZAWA Hiroyuki wrote:

> > > #define RES_COUNTER_INIFINITY 		(~0ULL)
> > > or some nice name
> > 
> > Why do we need this at all? We can simply push -1 there and be happy.
> > 
> Hm, can this work now ?
> ==
> echo -1 > /cgroup/memory.limit_in_bytes
> ==
> Or users have to do following for unlimit resource ?
> ==
> echo some-very-very-big-number > /cgroup/memory.limit_in_bytes
> 
> 
> I just think when some special value "-1" has a nice nick name, users will
> be happy. If I'm a novice user, I don't imagine I can write -1 to limit value.
> (but ok, tools can hide it for them.)
> 

Please simply use 0 to denote unconstrained memory, it's quite obvious 
that nobody will sanely attach tasks to a cgroup that has no bytes of 
memory allowed.

In fact, I proposed this in a patch on August 27.



I really don't like the use of ULONG_MAX to denote the absence of any 
memory controls for a particular container.  I think 0 would be suitable 
since its use doesn't make any logical sense (you're not going to be 
assigning a set of tasks to a resource void of pages).

Signed-off-by: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 Documentation/controllers/memory.txt |    5 ++++-
 kernel/res_counter.c                 |    7 +++++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/Documentation/controllers/memory.txt b/Documentation/controllers/memory.txt
--- a/Documentation/controllers/memory.txt
+++ b/Documentation/controllers/memory.txt
@@ -164,13 +164,16 @@ c. Enable CONFIG_CONTAINER_MEM_CONT
 # echo $$ >  /containers/0/tasks
 
 Since now we're in the 0 container,
-We can alter the memory limit:
+We can alter the memory limit (in pages):
 # echo -n 6000 > /containers/0/memory.limit
 
 We can check the usage:
 # cat /containers/0/memory.usage
 25
 
+If memory.limit is set to 0, no charge is accumlated for that resource
+controller.
+
 The memory.failcnt field gives the number of times that the container limit was
 exceeded.
 
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -16,12 +16,15 @@
 void res_counter_init(struct res_counter *counter)
 {
 	spin_lock_init(&counter->lock);
-	counter->limit = (unsigned long)LONG_MAX;
 }
 
 int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
 {
-	if (counter->usage + val > counter->limit) {
+	/*
+	 * If 'memory.limit' is set to 0, there is no charge to this
+	 * res_counter.
+	 */
+	if (counter->limit && counter->usage + val > counter->limit) {
 		counter->failcnt++;
 		return -ENOMEM;
 	}
