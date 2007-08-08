From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: Fw: Re: [PATCH] Fix capability.c to work with threaded init
Date: Wed, 08 Aug 2007 11:16:18 +0400
Message-ID: <46B96DC2.3060202@openvz.org>
References: <20070807213132.GB32539@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070807213132.GB32539-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> Hi Pavel,
> 
> This patch seems to be missing from your most recent patchset.
> Do you want to include it in the set as a helper or should I
> just send this to Andrew separately ?

Well, AFAIS this is also relevant to current kernel, so I think
that if you send it to Andrew this will be just fine. Besides,
the pid namespaces patchset is already huge, so pushing patches
separately from it is also very good.

Thanks,
Pavel

> Suka
> 
> ----- Forwarded message from sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org -----
> 
> | Date: Fri, 3 Aug 2007 13:51:20 -0700
> | From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
> | To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
> | Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> | Subject: Re: [PATCH] Fix capability.c to work with threaded init
> | 
> | Oleg Nesterov [oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org] wrote:
> | | On 08/03, Dave Hansen wrote:
> | | >
> | | > On Thu, 2007-08-02 at 23:26 -0700, sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> | | > > 
> | | > > Callers of is_container_init() should pass in task->group_leader
> | | > > to ensure they work with threaded-init.
> | | > 
> | | > Can you explain this in a little more detail?  That's a pretty sparse
> | | > changelog.
> | |
> | 
> | You are right. The changelog could be better. How about this:
> | 
> | | 
> | | Without this change cap_set_all() skips only the main thread of /sbin/init,
> | | but we should skip the entire process as the comment states.
> | | 
> | | Oleg.
> | 
> | 
> | ---
> | 
> | From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> | Subject: [PATCH] cap_set_all() must skip all threads of init
> | 
> | When setting capabilities, cap_set_all() must skip all threads of the
> | container_init process - not just the main thread. 
> | 
> | Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> | ---
> |  kernel/capability.c |    2 +-
> |  1 file changed, 1 insertion(+), 1 deletion(-)
> | 
> | Index: lx26-23-rc1-mm1/kernel/capability.c
> | ===================================================================
> | --- lx26-23-rc1-mm1.orig/kernel/capability.c	2007-08-02 22:58:02.000000000 -0700
> | +++ lx26-23-rc1-mm1/kernel/capability.c	2007-08-02 22:58:17.000000000 -0700
> | @@ -137,7 +137,7 @@ static inline int cap_set_all(kernel_cap
> |       int found = 0;
> | 
> |       do_each_thread(g, target) {
> | -             if (target == current || is_container_init(target))
> | +             if (target == current || is_container_init(target->group_leader))
> |                       continue;
> |               found = 1;
> |  	     if (security_capset_check(target, effective, inheritable,
> | 
> | _______________________________________________
> | Containers mailing list
> | Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> | https://lists.linux-foundation.org/mailman/listinfo/containers
> 
> ----- End forwarded message -----
> 
