From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: [PATCH] Fix capability.c to work with threaded init
Date: Fri, 3 Aug 2007 13:51:20 -0700
Message-ID: <20070803205120.GA4195@us.ibm.com>
References: <20070803062610.GB16833@us.ibm.com>
	<1186159872.18414.391.camel@localhost>
	<20070803172934.GB3783@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070803172934.GB3783-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Oleg Nesterov [oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org] wrote:
| On 08/03, Dave Hansen wrote:
| >
| > On Thu, 2007-08-02 at 23:26 -0700, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
| > > 
| > > Callers of is_container_init() should pass in task->group_leader
| > > to ensure they work with threaded-init.
| > 
| > Can you explain this in a little more detail?  That's a pretty sparse
| > changelog.
|

You are right. The changelog could be better. How about this:

| 
| Without this change cap_set_all() skips only the main thread of /sbin/init,
| but we should skip the entire process as the comment states.
| 
| Oleg.


---

From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cap_set_all() must skip all threads of init

When setting capabilities, cap_set_all() must skip all threads of the
container_init process - not just the main thread. 

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/capability.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: lx26-23-rc1-mm1/kernel/capability.c
===================================================================
--- lx26-23-rc1-mm1.orig/kernel/capability.c	2007-08-02 22:58:02.000000000 -0700
+++ lx26-23-rc1-mm1/kernel/capability.c	2007-08-02 22:58:17.000000000 -0700
@@ -137,7 +137,7 @@ static inline int cap_set_all(kernel_cap
      int found = 0;
 
      do_each_thread(g, target) {
-             if (target == current || is_container_init(target))
+             if (target == current || is_container_init(target->group_leader))
                      continue;
              found = 1;
 	     if (security_capset_check(target, effective, inheritable,
