From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][BUGFIX] cgroups: fix pid namespace bug
Date: Thu, 2 Jul 2009 11:37:31 -0500
Message-ID: <20090702163731.GA14267__15583.4416197196$1246553016$gmane$org@us.ibm.com>
References: <4A4C0C60.4050106@cn.fujitsu.com>
	<6599ad830907020926t6305bec9t44a50cc165f6fc28@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830907020926t6305bec9t44a50cc165f6fc28-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> On Wed, Jul 1, 2009 at 6:24 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> > + =A0 =A0 =A0 cp =3D kzalloc(sizeof(*cp), GFP_KERNEL);
> > + =A0 =A0 =A0 if (!cp) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 up_write(&cgrp->pids_mutex);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(pidarray);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> > + =A0 =A0 =A0 }
> > + =A0 =A0 =A0 cp->cgrp =3D cgrp;
> > + =A0 =A0 =A0 cp->pid_ns =3D pid_ns;
> =

> You're storing an uncounted reference to the pid ns here - there's no
> guarantee that the pid_ns will outlive the open file.

Yeah I was thinking about that, but

	1. the only way it won't outlive the open file is if the =

		task opens the file, hands the open fd over a
		unix socket, then exits as the last task of its
		pidns
	2. We don't dereference the pid_ns, so there is no actual
		safety issue.  So it would become a problem only
		if a new pidns gets created at that same address
		*and* a task in the new pidns opens the same
		tasks file.

Still, it wouldn't hurt to do get_pid_ns/put_pid_ns at the open
and release :)

-serge
