From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V2 2/6] audit: log namespace serial numbers
Date: Tue, 13 May 2014 10:19:44 -0400
Message-ID: <20140513141944.GB27560@madcap2.tricolour.ca>
References: <cover.1399681022.git.rgb@redhat.com>
	<e1b3ea66770e9e8d067c4fb725a6940c41ccf2f2.1399681022.git.rgb@redhat.com>
	<1399734444.3558.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1399734444.3558.19.camel@localhost>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 14/05/10, Eric Paris wrote:
> On Fri, 2014-05-09 at 20:27 -0400, Richard Guy Briggs wrote:
> > Log the namespace serial numbers of a task in audit_log_task_info() which
> > is used by syscall audits, among others..
> > 
> > Idea first presented:
> > 	https://www.redhat.com/archives/linux-audit/2013-March/msg00020.html
> > 
> > Typical output format would look something like:
> > 	        type=SYSCALL msg=audit(1399651071.433:72): arch=c000003e syscall=272 success=yes exit=0 a0=40000000 a1=ffffffffffffffff a2=0 a3=22 items=0 ppid=1 pid=483 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="(t-daemon)" exe="/usr/lib/systemd/systemd" netns=97 utsns=2 ipcns=1 pidns=4 userns=3 mntns=5 subj=system_u:system_r:init_t:s0 key=(null)
> > 
> > The serial numbers are printed in hex.
> > 
> > Suggested-by: Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> > ---
> >  include/linux/audit.h |    7 +++++++
> >  kernel/audit.c        |   38 ++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 45 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/audit.h b/include/linux/audit.h
> > index 22cfddb..0ef404a 100644
> > --- a/include/linux/audit.h
> > +++ b/include/linux/audit.h
> > @@ -101,6 +101,13 @@ extern int __weak audit_classify_compat_syscall(int abi, unsigned syscall);
> >  struct filename;
> >  
> >  extern void audit_log_session_info(struct audit_buffer *ab);
> > +#ifdef CONFIG_NAMESPACES
> > +extern void audit_log_namespace_info(struct audit_buffer *ab, struct task_struct *tsk);
> > +#else
> > +void audit_log_namespace_info(struct audit_buffer *ab, struct task_struct *tsk)
> > +{
> > +}
> > +#endif
> >  
> >  #ifdef CONFIG_AUDIT_COMPAT_GENERIC
> >  #define audit_is_compat(arch)  (!((arch) & __AUDIT_ARCH_64BIT))
> > diff --git a/kernel/audit.c b/kernel/audit.c
> > index 59c0bbe..fe783ad 100644
> > --- a/kernel/audit.c
> > +++ b/kernel/audit.c
> > @@ -64,7 +64,15 @@
> >  #endif
> >  #include <linux/freezer.h>
> >  #include <linux/tty.h>
> > +#include <linux/nsproxy.h>
> > +#include <linux/utsname.h>
> > +#include <linux/ipc_namespace.h>
> > +#include "../fs/mount.h"
> 
> I don't think such an include is ever a good idea and likely to get us
> SHOT by Viro...

Which is why patch 6 would replace it, but that depends on getting
buy-in to expose ns_entries in patch 5.

> Why do we need this include?

For "struct mnt_namespace", to get access to the serial number.

I agree.  It is ugly.  In fact, it is the one below that isn't necessary
since it is pulled in by ../fs/mount.h

> > +#include <linux/mount.h>
> > +#include <linux/mnt_namespace.h>
> >  #include <linux/pid_namespace.h>
> > +#include <net/net_namespace.h>
> > +#include <linux/user_namespace.h>
> >  #include <net/netns/generic.h>
> >  
> >  #include "audit.h"
> > @@ -1617,6 +1625,35 @@ void audit_log_session_info(struct audit_buffer *ab)
> >  	audit_log_format(ab, " auid=%u ses=%u", auid, sessionid);
> >  }
> >  
> > +#ifdef CONFIG_NAMESPACES
> > +void audit_log_namespace_info(struct audit_buffer *ab, struct task_struct *tsk)
> > +{
> > +	struct nsproxy *nsproxy;
> > +
> > +	rcu_read_lock();
> > +	nsproxy = task_nsproxy(tsk);
> > +	if (nsproxy != NULL) {
> > +		audit_log_format(ab, " mntns=%llx", nsproxy->mnt_ns->serial_num);
> > +#ifdef CONFIG_NET_NS
> > +		audit_log_format(ab, " netns=%llx", nsproxy->net_ns->serial_num);
> > +#endif
> > +#ifdef CONFIG_UTS_NS
> > +		audit_log_format(ab, " utsns=%llx", nsproxy->uts_ns->serial_num);
> > +#endif
> > +#ifdef CONFIG_IPC_NS
> > +		audit_log_format(ab, " ipcns=%llx", nsproxy->ipc_ns->serial_num);
> > +#endif
> > +	}
> > +#ifdef CONFIG_PID_NS
> > +	audit_log_format(ab, " pidns=%llx", task_active_pid_ns(tsk)->serial_num);
> > +#endif
> > +#ifdef CONFIG_USER_NS
> > +	audit_log_format(ab, " userns=%llx", task_cred_xxx(tsk, user_ns)->serial_num);
> > +#endif
> > +	rcu_read_unlock();
> > +}
> > +#endif /* CONFIG_NAMESPACES */
> > +
> >  void audit_log_key(struct audit_buffer *ab, char *key)
> >  {
> >  	audit_log_format(ab, " key=");
> > @@ -1861,6 +1898,7 @@ void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk)
> >  		up_read(&mm->mmap_sem);
> >  	} else
> >  		audit_log_format(ab, " exe=(null)");
> > +	audit_log_namespace_info(ab, tsk);
> >  	audit_log_task_context(ab);
> >  }
> >  EXPORT_SYMBOL(audit_log_task_info);
> 
> 

- RGB

--
Richard Guy Briggs <rbriggs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
