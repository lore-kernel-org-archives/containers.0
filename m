From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] procfs: change the owner of non-dumpable and writeable
	files
Date: Fri, 20 Jan 2017 13:35:29 +1100
Message-ID: <4025e285-9179-b98a-88c0-905f4f9c3ef8@suse.de>
References: <20170118040159.4751-1-asarai@suse.de>
	<20170119092930.GJ30786@dhcp22.suse.cz>
	<e7137350-b8a8-c7e5-e35d-8218a7df1147@suse.de>
	<87r33yv6gk.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87r33yv6gk.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, dev-IGmTWi+3HBZvNhPySn5qfx2eb7JE58TQ@public.gmane.org, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Janis Danisevskis <jdanis-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

> Please verify but the ptrace issue that allowed processes in a container
> to call setns on our processes should be fixed as of 4.10-rc1.  And the
> change has been marked for backporting.

ptrace(2) is not the only issue, the issue that we had in runC is that a 
process joining a namespace may have file descriptors that refer to the 
host filesystem. If the process joining is dumpable, a racing process 
inside the container can access those file descriptors through the 
/proc/[pid]/fd/... mechanism.

See CVE-2016-9962.

> AKA it should be this fix that removes the need for your dumpable setting.
> Fixes: bfedb589252c ("mm: Add a user_ns owner to mm_struct and fix ptrace permission checks")

I will check, though from what I recall that patch doesn't fix the 
ptrace_may_access checks. Not to mention it won't help if the container 
doesn't have it's own user namespace.

> Now with that said I believe we want to add the following change now
> that dumpable is user namespace relative.  That will use not the
> GLOBAL_ROOT_UID/GID but instead uid and gid 0 in the namespace
> that dumpable is relative too.

Sure, but that's tangential to the issue under discussion.

> But ugh!  Your case is even more confused that I had first noticed.
> Saying that a processes is undumpable is completely unnecessary
> when you are entering into a new fresh user namespace.  Touching
> setgroups at any point where there are other processes in the namespace
> makes no sense whatsoever.

Currently in runC the ordering for mixed create-and-join namespaces is 
that we first join existing namespaces and _then_ create new ones. So we 
need to be non-dumpable to avoid the problem in CVE-2016-9962.

> Clearing dumpable is to help not leak things
> into a container when you call setns on a user namespace.

It is also to help not leak things into a container when you join other 
namespaces. Most notably the PID namespace.

> +	if (mode != (S_IFDIR|S_IRUGO|S_IXUGO)) {

I'd just like to draw your attention to this special case -- why is this 
special cased? What was the original reasoning behind it? Does it make 
sense for a non-dumpable process to allow someone to change the mode of 
some random /proc/[pid]/ directories?

I get the feeling that some of this logic is a bit iffy.

-- 
Aleksa Sarai
Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/
