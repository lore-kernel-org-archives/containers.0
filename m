From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 14/20] Allow cloning of new namespace
Date: Wed, 08 Aug 2007 11:29:59 +0400
Message-ID: <46B970F7.3070200@openvz.org>
References: <46B83B9A.mailG5N11PRTB@openvz.org>
	<20070807224827.GA2375@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070807224827.GA2375-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> Pavel Emelianov [xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org] wrote:
> | When clone() is invoked with CLONE_NEWPID, create a new pid namespace
> | and then create a new struct pid for the new process. Allocate pid_t's
> | for the new process in the new pid namespace and all ancestor pid
> | namespaces. Make the newly cloned process the session and process group
> | leader.
> | 
> | Since the active pid namespace is special and expected to be the first
> 
> active pid ns is the *last entry* in this patchset (not first) right ?

yes. thanks.

> | entry in pid->upid_list, preserve the order of pid namespaces.
> | 
> | The size of 'struct pid' is dependent on the the number of pid namespaces
> | the process exists in, so we use multiple pid-caches'. Only one pid cache
> | is created during system startup and this used by processes that exist
> | only in init_pid_ns.
> | 
> | When a process clones its pid namespace, we create additional pid caches
> | as necessary and use the pid cache to allocate 'struct pids' for that depth.
> | 
> | Note, that with this patch the newly created namespace won't work, since
> | the rest of the kernel still uses global pids, but this is to be fixed
> | soon. Init pid namespace still works.
> | 
> | Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> | Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> | 
> | ---
> | 
> |  include/linux/sched.h |    1 
> |  kernel/fork.c         |   48 +++++++++++++++++---------
> |  kernel/nsproxy.c      |    3 +
> |  kernel/pid.c          |   91 +++++++++++++++++++++++++++++++++++++++++++++-----
> |  4 files changed, 118 insertions(+), 25 deletions(-)
> | 
> | --- ./include/linux/sched.h.ve14	2007-08-06 15:00:09.000000000 +0400
> | +++ ./include/linux/sched.h	2007-08-06 15:00:09.000000000 +0400
> | @@ -27,6 +27,7 @@
> |  #define CLONE_NEWUTS		0x04000000	/* New utsname group? */
> |  #define CLONE_NEWIPC		0x08000000	/* New ipcs */
> |  #define CLONE_NEWUSER		0x10000000	/* New user namespace */
> | +#define CLONE_NEWPID		0x20000000	/* New pids */
> 
> Nit. I think "New pid namespace" would be a better comment.

ok.

> Suka
> 

Thanks,
Pavel
