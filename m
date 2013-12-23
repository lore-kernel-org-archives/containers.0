From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC Part1 PATCH 00/20 v2] Add namespace support for audit
Date: Mon, 23 Dec 2013 18:47:23 -0500
Message-ID: <20131223234723.GA23101@madcap2.tricolour.ca>
References: <1382599925-25143-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20131206213135.GA22445@mail.hallyn.com>
	<52A52AFB.2020703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52A52AFB.2020703-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On 13/12/09, Gao feng wrote:
> On 12/07/2013 05:31 AM, Serge E. Hallyn wrote:
> > Quoting Gao feng (gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):

> >> The main target of this patchset is allowing user in audit
> >> namespace to generate the USER_MSG type of audit message,
> >> some userspace tools need to generate audit message, or
> >> these tools will broken.
> >>
> >> And the login process in container may want to setup
> >> /proc/<pid>/loginuid, right now this value is unalterable
> >> once it being set. this will also broke the login problem
> >> in container. After this patchset, we can reset this loginuid
> >> to zero if task is running in a new audit namespace.
> >>
> >> Same with v1 patchset, in this patchset, only the privileged
> >> user in init_audit_ns and init_user_ns has rights to
> >> add/del audit rules. and these rules are gloabl. all
> >> audit namespace will comply with the rules.
> >>
> >> Compared with v1, v2 patch has some big changes.
> >> 1, the audit namespace is not assigned to user namespace.
> >>    since there is no available bit of flags for clone, we
> >>    create audit namespace through netlink, patch[18/20]
> >>    introduces a new audit netlink type AUDIT_CREATE_NS.
> >>    the privileged user in userns has rights to create a
> >>    audit namespace, it means the unprivileged user can
> >>    create auditns through create userns first. In order
> >>    to prevent them from doing harm to host, the default
> >>    audit_backlog_limit of un-init-audit-ns is zero(means
> >>    audit is unavailable in audit namespace). and it can't
> >>    be changed in auditns through netlink.
> > 
> > So the unprivileged user can create an audit-ns, but can't
> > then actually send any messages there?  I guess setting it
> > to something small would just be hacky?
> 
> Yes, if unprivileged user wants to send audit message, he should
> ask privileged user to setup the audit_backlog_limit for him.
> 
> I know it's a little of hack, but I don't have good idea :(

There's a recent patch that actually clarifies the way
audit_backlog_limit works, since different parts of the code seemed to
think different things.  It now means unlimited, since there are other
places to shut off logging.
	audit: allow unlimited backlog queue

At first, I'd say each audit_ns should be able to set its own
audit_backlog_limit.  The most obvious argument against this would be
the vulnerability of a DoS.  Could there be some automatic metrics to
set sub audit_ns backlog limits, such as default to the same as
init_audit_ns and have the init_audit_ns override those defaults?
Could this be done per user like ulimiit?

- RGB

--
Richard Guy Briggs <rbriggs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
