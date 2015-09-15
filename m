From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC] pidns: introduce syscall getvpid
Date: Tue, 15 Sep 2015 17:41:43 +0000
Message-ID: <20150915174143.GE4699__29035.0965028212$1442338928$gmane$org@ubuntumail>
References: <20150915120924.14818.49490.stgit@buzz>
	<87h9mvg3kw.fsf@x220.int.ebiederm.org>
	<55F832D2.1070605@yandex-team.ru> <20150915151729.GA144242@dakara>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150915151729.GA144242@dakara>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting St=E9phane Graber (stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org):
> On Tue, Sep 15, 2015 at 06:01:38PM +0300, Konstantin Khlebnikov wrote:
> > On 15.09.2015 17:27, Eric W. Biederman wrote:
> > >Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org> writes:
> > >
> > >>pid_t getvpid(pid_t pid, pid_t source, pid_t target);
> > >>
> > >>This syscall converts pid from one pid-ns into pid in another pid-ns:
> > >>it takes @pid in namespace of @source task (zero for current) and
> > >>returns related pid in namespace of @target task (zero for current to=
o).
> > >>If pid is unreachable from target pid-ns then it returns zero.
> > >
> > >This interface as presented is inherently racy.  It would be better
> > >if source and target were file descriptors referring to the namespaces
> > >you wish to translate between.
> > =

> > Yep, it's racy. As well as any operation with non-child pids.
> > With file descriptors for source/target result will be racy anyway.
> > =

> > >
> > >>Such conversion is required for interaction between processes from
> > >>different pid-namespaces. For example when system service talks with
> > >>client from isolated container via socket about task in container:
> > >
> > >Sockets are already supported.  At least the metadata of sockets is.
> > >
> > >Maybe we need this but I am not convinced of it's utility.
> > >
> > >What are you trying to do that motivates this?
> > =

> > I'm working on hierarchical container management system which
> > allows to create and control nested sub-containers from containers
> > ( https://github.com/yandex/porto ). Main server works in host and
> > have to interact with all levels of nested namespaces. This syscall
> > makes some operations much easier: server must remember only pid in
> > host pid namespace and convert it into right vpid on demand.
> =

> Note that as Eric said earlier, sending a PID inside a ucred through a
> unix socket will have the pid translated.
> =

> So while your solution certainly should be faster, you can already achieve
> what you want today by doing:
> =

> =3D=3D Translate PID in container to PID in host
>  - open a socket
>  - setns to container's pidns
>  - send ucred from that container containing the requested container PID
>  - host sees the host PID
> =

> =3D=3D Translate PID on host to PID in container
>  - open a socket
>  - setns to container's pidns
>  - send ucred from the host containing the request host PID
>    (send will fail if the host PID isn't part of that container)
>  - container sees the container PID

In addition, since commit e4bc332451 : /proc/PID/status: show all sets of p=
id according to ns
we now also have 'NSpid' etc in /proc/$$/status.

-serge
