From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by
	tgid at once
Date: Tue, 4 Aug 2009 09:01:58 -0500
Message-ID: <20090804140158.GA663__19849.7049896561$1249395067$gmane$org@us.ibm.com>
References: <20090731012908.27908.62208.stgit@hastromil.mtv.corp.google.com>
	<20090731015154.27908.9639.stgit@hastromil.mtv.corp.google.com>
	<20090803175452.GA5481@us.ibm.com>
	<2f86c2480908031113y525b6cbdhe418b8a0364c7760@mail.gmail.com>
	<20090803185556.GA8469@us.ibm.com>
	<20090803194555.GA10158@us.ibm.com>
	<6599ad830908031255j68ce047x7165bfefa62ed53c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830908031255j68ce047x7165bfefa62ed53c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> On Mon, Aug 3, 2009 at 12:45 PM, Serge E. Hallyn<serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> >
> > This is probably a stupid idea, but... =A0what about having zero
> > overhead at clone(), and instead, at cgroup_task_migrate(),
> > dequeue_task()ing all of the affected threads for the duration of
> > the migrate?
> =

> That doesn't sound too unreasonable, actually - it would certainly
> simplify things a fair bit. Is there a standard API for doing that?
> dequeue_task() itself doesn't really look like a public API. I guess
> that the task freezer would be one way to accomplish this?

Actually if we wanted to try to avoid -EINTRs for the tasks, which
they get with the freezer, we might want to code our own helpers
in sched.c based on dequeue_task().  Instead of interrupting ongoing
system calls, we'll want to set a flag saying if the syscall exits
(before we unset the flag) then dequeue it real quick.

> I can imagine that the set of people who'd complain about the latency
> hit when migrating with your solution would be smaller than the people
> who'd complain about the increased overhead in the normal clone case.
> =

> Paul
