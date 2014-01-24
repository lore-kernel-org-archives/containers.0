From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC 7/8] audit: report namespace information along with
	USER events
Date: Fri, 24 Jan 2014 01:19:25 -0500
Message-ID: <20140124061925.GE1981@madcap2.tricolour.ca>
References: <1363619405-6419-1-git-send-email-arozansk@redhat.com>
	<1363619405-6419-8-git-send-email-arozansk@redhat.com>
	<871ubc9yda.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <871ubc9yda.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 13/03/18, Eric W. Biederman wrote:
> Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

(Digging up an old thread...)

> > For userspace generated events, include a record with the namespace
> > procfs inode numbers the process belongs to. This allows to track down
> > and filter audit messages by userspace.
> 
> I am not comfortable with using the inode numbers this way.  It does not
> pass the test of can I migrate a container and still have this work
> test.  Any kind of kernel assigned name for namespaces fails that test.

Any kind?  How about if we have a systemwide atomically incremented
serial number assigned every time a namespace is created?  This is close
to what the inode number was except the inode could be in a different
proc device, as pointed out.

> I also don't like that you don't include the procfs device number.  An
> inode number means nothing without knowing which filesystem you are
> referring to.

I'm looking at having everything relative to init_*_ns to start with, so
this isn't a problem initially, but may become so if it isn't the case.

Can anyone point out off-hand how to find that proc device number?
(I'll start looking...)

> It may never happen but I reserve the right to have the inode numbers
> for namespaces to show up differently in different instances of procfs.

So would that serial number idea work better?

> Beyond that I think this usage is possibly buggy by using two audit
> records for one event.

I'm looking at integrating this information into a standard message.

> > Signed-off-by: Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > ---
> >  include/uapi/linux/audit.h |    1 +
> >  kernel/audit.c             |   51 +++++++++++++++++++++++++++++++++++++++++++-
> >  2 files changed, 51 insertions(+), 1 deletions(-)
> >
> > diff --git a/include/uapi/linux/audit.h b/include/uapi/linux/audit.h
> > index 9f096f1..3ec3ccb 100644
> > --- a/include/uapi/linux/audit.h
> > +++ b/include/uapi/linux/audit.h
> > @@ -106,6 +106,7 @@
> >  #define AUDIT_NETFILTER_PKT	1324	/* Packets traversing netfilter chains */
> >  #define AUDIT_NETFILTER_CFG	1325	/* Netfilter chain modifications */
> >  #define AUDIT_SECCOMP		1326	/* Secure Computing event */
> > +#define AUDIT_USER_NAMESPACE	1327	/* Information about process' namespaces */
> >  
> >  #define AUDIT_AVC		1400	/* SE Linux avc denial or grant */
> >  #define AUDIT_SELINUX_ERR	1401	/* Internal SE Linux Errors */
> > diff --git a/kernel/audit.c b/kernel/audit.c
> > index 58db117..b17f9c0 100644
> > --- a/kernel/audit.c
> > +++ b/kernel/audit.c
> > @@ -62,6 +62,11 @@
> >  #include <linux/freezer.h>
> >  #include <linux/tty.h>
> >  #include <linux/pid_namespace.h>
> > +#include <linux/ipc_namespace.h>
> > +#include <linux/mnt_namespace.h>
> > +#include <linux/utsname.h>
> > +#include <linux/user_namespace.h>
> > +#include <net/net_namespace.h>
> >  
> >  #include "audit.h"
> >  
> > @@ -641,6 +646,49 @@ static int audit_log_common_recv_msg(struct audit_buffer **ab, u16 msg_type,
> >  	return rc;
> >  }
> >  
> > +#ifdef CONFIG_NAMESPACES
> > +static int audit_log_namespaces(struct task_struct *tsk,
> > +				struct sk_buff *skb)
> > +{
> > +	struct audit_context *ctx = tsk->audit_context;
> > +	struct audit_buffer *ab;
> > +
> > +	if (!audit_enabled)
> > +		return 0;
> > +
> > +	ab = audit_log_start(ctx, GFP_KERNEL, AUDIT_USER_NAMESPACE);
> > +	if (unlikely(!ab))
> > +		return -ENOMEM;
> > +
> > +	audit_log_format(ab, "mnt=%u", mntns_get_inum(tsk));
> > +#ifdef CONFIG_NET_NS
> > +	audit_log_format(ab, " net=%u", netns_get_inum(tsk));
> > +#endif
> > +#ifdef CONFIG_UTS_NS
> > +	audit_log_format(ab, " uts=%u", utsns_get_inum(tsk));
> > +#endif
> > +#ifdef CONFIG_IPC_NS
> > +	audit_log_format(ab, " ipc=%u", ipcns_get_inum(tsk));
> > +#endif
> > +#ifdef CONFIG_PID_NS
> > +	audit_log_format(ab, " pid=%u", pidns_get_inum(tsk));
> > +#endif
> > +#ifdef CONFIG_USER_NS
> > +	audit_log_format(ab, " user=%u", userns_get_inum(tsk));
> > +#endif  
> > +	audit_set_pid(ab, NETLINK_CB(skb).portid);
> > +	audit_log_end(ab);
> > +
> > +	return 0;
> > +}
> > +#else
> > +static inline int audit_log_namespaces(struct task_struct *tsk,
> > +				       struct sk_buff *skb)
> > +{
> > +	return 0;
> > +}
> > +#endif
> > +
> >  static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
> >  {
> >  	u32			seq, sid;
> > @@ -741,7 +789,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
> >  			}
> >  			audit_log_common_recv_msg(&ab, msg_type,
> >  						  loginuid, sessionid, sid,
> > -						  NULL);
> > +						  current->audit_context);
> >  
> >  			if (msg_type != AUDIT_USER_TTY)
> >  				audit_log_format(ab, " msg='%.1024s'",
> > @@ -758,6 +806,7 @@ static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
> >  			}
> >  			audit_set_pid(ab, NETLINK_CB(skb).portid);
> >  			audit_log_end(ab);
> > +			audit_log_namespaces(current, skb);
> >  		}
> >  		break;
> >  	case AUDIT_ADD:
> 
> --
> Linux-audit mailing list
> Linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
> https://www.redhat.com/mailman/listinfo/linux-audit

- RGB

--
Richard Guy Briggs <rbriggs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
