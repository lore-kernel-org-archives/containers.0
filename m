From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] Introduce Vpid: in /proc/self/status
Date: Sat, 11 Jun 2011 18:46:16 -0700
Message-ID: <m139jf4yaf.fsf@fess.ebiederm.org>
References: <20110610094646.29106.62700.stgit@bahia.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110610094646.29106.62700.stgit-GiB8zCg7hOfDOqzlkpFKJg@public.gmane.org> (Greg Kurz's
	message of "Fri, 10 Jun 2011 11:46:46 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, legoater-GANU6spQydw@public.gmane.org
List-Id: containers.vger.kernel.org

Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

> Since pid namespaces were introduced, there's a recurring demand: how one
> can correlate a pid from a child pid ns with a pid from a parent pid ns ?
> The need arises in the LXC community when one wants to send a signal from
> the host (aka. init_pid_ns context) to a container process for which one
> only knows the pid inside the container.

You are missing taking the sighand lock which is needed to make
task_active_pid_ns safe when called on something other than current.

I really don't like the name VPid, perhaps Process Pid.  There is
nothing more or less virtual about any pid, so calling any of the
virtual is not clear, and misleading.

I'm not exactly certain that /proc/self/status is the right place
for this but this does seem reasonable.

For what it's worth if you are communicating through anything except
a pid file unix domain sockets will give you a race free to get the
pid of the process on the other end.

> In the future, this should be achievable thanks to Eric Biederman's setns()
> syscall but there's still some work to be done to support pid namespaces:
>
> https://lkml.org/lkml/2011/5/21/162
>
> As stated by Serge Hallyn in:
>
> http://sourceforge.net/mailarchive/message.php?msg_id=27424447
>
> "There is nothing that gives you a 100% guaranteed correct race-free
> correspondence right now.  You can look under /proc/<pid>/root/proc/ to
> see the pids valid in the container, and you can relate output of
> lxc-ps --forest to ps --forest output.  But nothing under /proc that I
> know of tells you "this task is the same as that task".  You can't
> even look at /proc/<pid> inode numbers since they are different
> filesystems for each proc mount."

As it happens a unix domain socket can be used to give you a guaranteed
race-free correspondence right now.

So that is what I would recommend if your source of the pid is something
other than a pid file sitting in the filesystem.

> This patch adds a single line to /proc/self/status. Provided one has kept
> track of its container tasks (with a cgroup like liblxc does for example),
> he may correlate global pids and container pids. This is still racy but
> definitely easier than what we have today.

Eric
