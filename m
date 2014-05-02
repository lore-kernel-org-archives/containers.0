From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/2] namespaces: log namespaces per task
Date: Fri, 2 May 2014 21:00:44 +0000
Message-ID: <20140502210044.GF2631@ubuntumail>
References: <cover.1398176489.git.rgb@redhat.com>
	<20140501223212.GA25669@mail.hallyn.com>
	<20140502142851.GC24111@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140502142851.GC24111-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Richard Guy Briggs (rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> On 14/05/02, Serge E. Hallyn wrote:
> > Quoting Richard Guy Briggs (rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> > > I saw no replies to my questions when I replied a year after Aris' posting, so
> > > I don't know if it was ignored or got lost in stale threads:
> > >         https://www.redhat.com/archives/linux-audit/2013-March/msg00020.html
> > >         https://www.redhat.com/archives/linux-audit/2013-March/msg00033.html
> > > 	(https://lists.linux-foundation.org/pipermail/containers/2013-March/032063.html)
> > >         https://www.redhat.com/archives/linux-audit/2014-January/msg00180.html
> > > 
> > > I've tried to answer a number of questions that were raised in that thread.
> > > 
> > > The goal is not quite identical to Aris' patchset.
> > > 
> > > The purpose is to track namespaces in use by logged processes from the
> > > perspective of init_*_ns.  The first patch defines a function to list them.
> > > The second patch provides an example of usage for audit_log_task_info() which
> > > is used by syscall audits, among others.  audit_log_task() and
> > > audit_common_recv_message() would be other potential use cases.
> > > 
> > > Use a serial number per namespace (unique across one boot of one kernel)
> > > instead of the inode number (which is claimed to have had the right to change
> > > reserved and is not necessarily unique if there is more than one proc fs).  It
> > > could be argued that the inode numbers have now become a defacto interface and
> > > can't change now, but I'm proposing this approach to see if this helps address
> > > some of the objections to the earlier patchset.
> > > 
> > > There could also have messages added to track the creation and the destruction
> > > of namespaces, listing the parent for hierarchical namespaces such as pidns,
> > > userns, and listing other ids for non-hierarchical namespaces, as well as other
> > > information to help identify a namespace.
> > > 
> > > There has been some progress made for audit in net namespaces and pid
> > > namespaces since this previous thread.  net namespaces are now served as peers
> > > by one auditd in the init_net namespace with processes in a non-init_net
> > > namespace being able to write records if they are in the init_user_ns and have
> > > CAP_AUDIT_WRITE.  Processes in a non-init_pid_ns can now similarly write
> > > records.  As for CAP_AUDIT_READ, I just posted a patchset to check capabilities
> > > of userspace processes that try to join netlink broadcast groups.
> > > 
> > > 
> > > Questions:
> > > Is there a way to link serial numbers of namespaces involved in migration of a
> > > container to another kernel?  (I had a brief look at CRIU.)  Is there a unique
> > > identifier for each running instance of a kernel?  Or at least some identifier
> > > within the container migration realm?
> > 
> > Eric Biederman has always been adamantly opposed to adding new namespaces
> > of namespaces, so the fact that you're asking this question concerns me.
> 
> I have seen that position and I don't fully understand the justification
> for it other than added complexity.
> 
> One way that occured to me to be able to identify a kernel instance was
> to look at CPU serial numbers or other CPU entity intended to be
> globally unique, but that isn't universally available.

That's one issue, which is uniqueness of namespaces cross-machines.

But it gets worse if we consider that after allowing in-container audit,
we'll have a nested container running, then have the parent container
migrated to another host (or just checkpointed and restarted);  Now the
nexted container's indexes will all be changed.  Is there any way audit
can track who's who after the migration?

That's not an indictment of the serial # approach, since (a) we don't
have in-container audit yet and (b) we don't have c/r/migration of nested
containers.  But it's worth considering whether we can solve the issue
with serial #s, and, if not, whether we can solve it with any other
approach.

I guess one approach to solve it would be to allow userspace to request
a next serial #.  Which will immediately lead us to a namespace of serial
#s (since the requested # might be lower than the last used one on the
new host).

As you've said inode #s for /proc/self/ns/* probably aren't sufficiently
unique, though perhaps we could attach a generation # for the sake of
audit.  Then after a c/r/migration the generation # may be different,
but we may have a better shot at at least using the same ino#.

> Another possibility was RTC reading at time of boot, but that isn't good
> enough either.
> 
> Both are dubious in VMs anyways.
> 
> > The way things are right now, since audit belongs to the init userns,
> > we can get away with saying if a container 'migrates', the new kernel
> > will see a different set of serials, and noone should care.  However,
> > if we're going to be allowing containers to have their own audit
> > namespace/layer/whatever, then this becomes more of a concern.
> 
> Having a container have its own audit daemon (partitionned appropriately
> in the kernel) would be a long-term goal.

Agreed, fwiw.

> > That said, I'll now look at the patches while pretending that problem
> > does not exist :)  If I ack, it'll be on correctness of the code, but
> > we'll still have to deal with this issue.
> 
> Getting some discussion about this migration challenge was a significant
> motivation for posting this patch, so I'm hoping others will weigh in.
> 
> Thanks for your review, Serge.
> 
> > > What additional events should list this information?
> > > 
> > > Does this present any kind of information leak?  Only CAP_AUDIT_CONTROL (and
> > > proposed CAP_AUDIT_READ) in init_user_ns can get to this information in the
> > > init namespace at the moment.
> > > 
> > > 
> > > Proposed output format:
> > > This differs slightly from Aristeu's patch because of the label conflict with
> > > "pid=" due to including it in existing records rather than it being a seperate
> > > record:
> > >         type=SYSCALL msg=audit(1398112249.996:65): arch=c000003e syscall=272 success=yes exit=0 a0=40000000 a1=ffffffffffffffff a2=0 a3=22 items=0 ppid=1 pid=566 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="(t-daemon)" exe="/usr/lib/systemd/systemd" mntns=5 netns=97 utsns=2 ipcns=1 pidns=4 userns=3 subj=system_u:system_r:init_t:s0 key=(null)
> > > 
> > > 
> > > Note: This set does not try to solve the non-init namespace audit messages and
> > > auditd problem yet.  That will come later, likely with additional auditd
> > > instances running in another namespace with a limited ability to influence the
> > > master auditd.  I echo Eric B's idea that messages destined for different
> > > namespaces would have to be tailored for that namespace with references that
> > > make sense (such as the right pid number reported to that pid namespace, and
> > > not leaking info about parents or peers).
> > > 
> > > 
> > > Richard Guy Briggs (2):
> > >   namespaces: give each namespace a serial number
> > >   audit: log namespace serial numbers
> > > 
> > >  fs/mount.h                     |    1 +
> > >  fs/namespace.c                 |    1 +
> > >  include/linux/audit.h          |    7 +++++++
> > >  include/linux/ipc_namespace.h  |    1 +
> > >  include/linux/nsproxy.h        |    8 ++++++++
> > >  include/linux/pid_namespace.h  |    1 +
> > >  include/linux/user_namespace.h |    1 +
> > >  include/linux/utsname.h        |    1 +
> > >  include/net/net_namespace.h    |    1 +
> > >  init/version.c                 |    1 +
> > >  ipc/msgutil.c                  |    1 +
> > >  ipc/namespace.c                |    2 ++
> > >  kernel/audit.c                 |   38 ++++++++++++++++++++++++++++++++++++++
> > >  kernel/nsproxy.c               |   24 ++++++++++++++++++++++++
> > >  kernel/pid.c                   |    1 +
> > >  kernel/pid_namespace.c         |    2 ++
> > >  kernel/user.c                  |    1 +
> > >  kernel/user_namespace.c        |    2 ++
> > >  kernel/utsname.c               |    2 ++
> > >  net/core/net_namespace.c       |    4 +++-
> > >  20 files changed, 99 insertions(+), 1 deletions(-)
> > > 
> > > _______________________________________________
> > > Containers mailing list
> > > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > > https://lists.linuxfoundation.org/mailman/listinfo/containers
> 
> - RGB
> 
> --
> Richard Guy Briggs <rbriggs-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
> Remote, Ottawa, Canada
> Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545
