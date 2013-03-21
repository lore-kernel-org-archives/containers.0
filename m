From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC] audit: provide namespace information in user
	originated records
Date: Wed, 20 Mar 2013 21:48:39 -0700
Message-ID: <87fvzp4au0.fsf@xmission.com>
References: <877gl48iaz.fsf@xmission.com> <20130319122408.GC20187@redhat.com>
	<874ng7gcst.fsf@xmission.com> <20130320154503.GF20187@redhat.com>
	<20130320183652.GA13839@sergelap>
	<1363804924.2333.12.camel@localhost>
	<20130320184952.GA16488@sergelap> <1363806092.2333.19.camel@localhost>
	<87y5dh8xl7.fsf@xmission.com> <1363830363.17962.18.camel@localhost>
	<20130321022116.GA14502@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130321022116.GA14502@sergelap> (Serge Hallyn's message of
	"Wed, 20 Mar 2013 21:21:16 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric Paris (eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
>> So the kernel socket(s) would be per network namespace, but we divide
>> messages per user namespace?  Which socket do I send them on,
>> considering the possible crazy many<->many mappings between user and
>> network namespaces.  It all makes me cry a little.
>
> not many-many - each netns is owned by exactly one userns.  The userns
> from which the netns was created.

Doh.  I missed this question and I think I misunderstood when Eric
Paris was talking about multicasting audit messages.

If what we are really talking about is sending some audit messages to
an auditd in a container what appears obvious to me is that we define
a per user namespace capability something like CAP_AUDIT_CONTROL.  That
does most or all of what CAP_AUDIT_CONTROL does in the init user
namespace.  Especially capturing audit_pid and audit_nlk_portid to
decide who to send the message to.

Something like:

struct audit_control {
	int	initialized;
	pid_t	pid;
	u32	nlk_portid;
};

struct user_namespace {
       ...
       struct audit_contol audit;
};

Then the transmission would be something like:
	struct user_namespace *user_ns = ...;
        for (;;) {
		if (ns->audit_pid) {
        		err = netlink_unicast(ns->audit.sock, skb, ns->audit.nlk_portid, 0);
		}
                if (!ns->parent)
                	break;
		ns = ns->parent;
	}

If someone finds auditd interesting enough to do that work.

In general I think it only makes sense if we can reuse the existing
userspace auditd.

Eric
