From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: RFC: making cn_proc work in {pid,user} namespaces
Date: Sun, 15 Oct 2017 17:40:08 -0500
Message-ID: <87r2u4nign.fsf__7459.38651166416$1508107268$gmane$org@xmission.com>
References: <a2fa1602-2280-c5e8-cac9-b718eaea5d22@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <a2fa1602-2280-c5e8-cac9-b718eaea5d22-l3A5Bk7waGM@public.gmane.org> (Aleksa Sarai's
	message of "Sun, 15 Oct 2017 21:05:49 +1100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev <dev-IGmTWi+3HBZvNhPySn5qfx2eb7JE58TQ@public.gmane.org>, "cyphar-gVpy/LI/lHzQT0dZR+AlfA@public.gmane.org >> Aleksa Sarai" <cyphar-gVpy/LI/lHzQT0dZR+AlfA@public.gmane.org>, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org> writes:

> Hi all,
>
> At the moment, cn_proc is not usable by containers or container runtimes. In
> addition, all connectors have an odd relationship with init_net (for example,
> /proc/net/connectors only exists in init_net). There are two main use-cases that
> would be perfect for cn_proc, which is the reason for me pushing this:
>
> First, when adding a process to an existing container, in certain modes runc
> would like to know that process's exit code. But, when joining a PID namespace,
> it is advisable[1] to always double-fork after doing the setns(2) to reparent
> the joining process to the init of the container (this causes the SIGCHLD to be
> received by the container init).  It would also be useful to be able to monitor
> the exit code of the init process in a container without being its parent. At
> the moment, cn_proc doesn't allow unprivileged users to use it (making it a
> problem for user namespaces and "rootless containers"). In addition, it also
> doesn't allow nested containers to use it, because it requires the process to be
> in init_pid. As a result, runc cannot use cn_proc and relies on SIGCHLD (which
> can only be used if we don't double-fork, or keep around a long-running process
> which is something that runc also cannot do).

As far as I know there are no technical issues that require a
daemonizing double fork when injecting a process into a pid namespaces.
A fork is required because the pid is changing and that requires another
process.

Monitoring and acting on the monitored state without keeping around a
single process to do the monitoring does not make sense to me.  So I am
just going to ignore that.

So I don't think fixing cn_proc for this issue makes sense.

> Secondly, there are/were some init systems that rely on cn_proc to manage
> service state. From a "it would be neat" perspective, I think it would be quite
> nice if such init systems could be used inside containers. But that requires
> cn_proc to be able to be used as an unprivileged user and in a pid namespace
> other than init_pid.

Any pointers to these init systems?  In general I agree.  Given how much
work it takes to go through a subsystem and ensure that it is safe for
non-root users I am happy to see the work done, but I am not
volunteering for the work when I have several I have as many tasks as I
have on my plate right now.

> The /proc/net/connectors thing is quite easily resolved (just make it the
> connector driver perdev and make some small changes to make sure the interfaces
> stay sane inside of a container's network namespace). I'm sure that we'll
> probably have to make some changes to the registration API, so that a connector
> can specify whether they want to be visible to non-init_net
> namespaces.
>
> However, the cn_proc problem is a bit harder to resolve nicely and there are
> quite a few interface questions that would need to be agreed upon. The basic
> idea would be that a process can only get cn_proc events if it has
> ptrace_may_access rights over said process (effectively a forced filter -- which
> would ideally be done send-side but it looks like it might have to be done
> receive-side). This should resolve possible concerns about an unprivileged
> process being able to inspect (fairly granular) information about the host. And
> obviously the pids, uids, and gids would all be translated according to the
> receiving process's user namespaces (if it cannot be translated then the message
> is not received). I guess that the translation would be done in the same way as
> SCM_CREDENTIALS (and cgroup.procs files), which is that it's done on the receive
> side not the send side.

Hmm.  We have several of these things such as bsd process accounting
which appear to be working fine.

The basic logic winds up being:
for_each_receiver:
    compose_msg in receivers namespace
    send_msg.

The tricky bit in my mind is dealing with receivers because of the
connection with the network namespace.

SCM_CREDENTIALS is an unfortunate case, that really should not be
followed as a model.  The major challenge there is not knowing
the receiving socket, or the receiver.  If I had been smarter
when I coded that originally I would have forced everything into
the namespace of the opener of the receiving socket.   I may have to
revisit that one again someday and see if there are improvements that
can be made.

> My reason for sending this email rather than just writing the patch is to see
> whether anyone has any solid NACKs against the use-case or whether there is some
> fundamental issue that I'm not seeing. If nobody objects, I'll be happy to work
> on this.

If you want a non-crazy (with respect to namespace involvement) model
please look at kernel/acct.c:acc_process()

If there are use cases that people still care about that use the
proc connector and want to run in a container it seems sensible to dig
in and sort things out.  I think I have been hoping it is little enough
used we won't have to mess with making it work in namespaces.

> [1]: https://lwn.net/Articles/532748/


Eric
