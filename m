From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH RFC] audit: provide namespace information in user
	originated records
Date: Mon, 18 Mar 2013 15:16:52 -0700
Message-ID: <877gl48iaz.fsf@xmission.com>
References: <1363619405-6419-1-git-send-email-arozansk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1363619405-6419-1-git-send-email-arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Aristeu
	Rozanski's message of "Mon, 18 Mar 2013 11:09:57 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Adding the containers list so folks with container expertise can see
what is being proposed.

Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> This patchset introduces a new audit record to follow all USER records which
> provides namespace information of the process. The idea is to allow processes
> in containers to create records in the host system while providing means to be
> filtered out.

It looks like this mechanism makes it easy for an unprivileged program
to spam and overwhelm the audit log.

> For each new namespace, a unique procfs inode number is allocated and this
> number has been used by userspace to determine which processes belong to the
> same namespace. These numbers are used in the new audit record.
>
> Applications such as libvirt-sandbox and lxc can then report the same numbers
> when a container is created and destroyed allowing to map records to a certain
> container. Maybe the next step would be having a record for whenever a new
> namespace is created?
>
> First 6 patches are needed in order to get each namespace's inode number.

Grumble the existing methods can be used you don't have to introduce a
whole new set of methods.  Grumble.  Besides the bug of assuming that
the inodes now and forever will be the same across all instances of
proc.

> Patch 7 properly defines the new record that is related to the USER
> record

Not agmenting the current user records seems a little odd to me.

You also continue in this my current policy of not allowing any audit
records in the container itself, so I a don't quite know what the point
of all of this is.

> Patch 8 allows USER records to be generated from different namespaces

Which essentially allows any user to create any USER record they want
whenever they want.

> Here's an example of output:
> type=CRED_DISP msg=audit(1363528861.403:311): pid=20016 uid=0 auid=0 ses=45 subj=system_u:system_r:crond_t:s0-s0:c0.c1023 msg='op=PAM:setcred acct="root" exe="/usr/sbin/crond" hostname=? addr=? terminal=cron res=success'

Ok.  This seems totally bizarre.  You are running a container with a
user namespace with some uid mapped to uid 0?

That defeats about half the point of having user namespaces, as half the
files in the world are owned by uid 0, and can be written by uid 0
outside of your user namespace.

Hmm.  I need to look at this in a little more detail but I believe our
use of task_pid_vnr here in the audit record is a long standing bug.

> type=UNKNOWN[1327] msg=audit(1363528861.403:311): mnt=4026531840 net=4026531956 uts=4026531838 ipc=4026531839 pid=4026531836 user=4026531837
>
> Notes:
> - this is a RFC, all sorts of feedback are much appreciated
> - while the last patch allows a new userns to send audit records, I haven't
>   look yet on making sure it has proper capabilities so regular users'
>   containers can create records

I don't think it does.

> - the record number allocated is just a draft. If this patchset evolves into
>   something that can be merged, please advise which number number is the best
>   choice
> - I'm not subscribed to the list, so please make sure I'm on the Cc list
>
>  fs/namespace.c                 |   14 +++++++
>  include/linux/ipc_namespace.h  |    1
>  include/linux/mnt_namespace.h  |    2 +
>  include/linux/pid_namespace.h  |    1
>  include/linux/user_namespace.h |    1
>  include/linux/utsname.h        |    1
>  include/net/net_namespace.h    |    1
>  include/uapi/linux/audit.h     |    1
>  ipc/namespace.c                |   14 +++++++
>  kernel/audit.c                 |   76 +++++++++++++++++++++++++++++++++++++----
>  kernel/pid_namespace.c         |   11 +++++
>  kernel/user_namespace.c        |    5 ++
>  kernel/utsname.c               |   14 +++++++
>  net/core/net_namespace.c       |   14 +++++++
>  14 files changed, 150 insertions(+), 6 deletions(-)
