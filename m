From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by
	tgid at once
Date: Tue, 4 Aug 2009 14:40:38 -0700
Message-ID: <20090804214038.GA5141__17540.4122485363$1249422106$gmane$org@count0.beaverton.ibm.com>
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
Cc: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Rafael Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>, Linux Power Management <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

[ Cc'ing Rafael and linux-pm for more eyes on proposed freezer usage. ]

On Mon, Aug 03, 2009 at 12:55:33PM -0700, Paul Menage wrote:
> On Mon, Aug 3, 2009 at 12:45 PM, Serge E. Hallyn<serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> >
> > This is probably a stupid idea, but... =A0what about having zero
> > overhead at clone(), and instead, at cgroup_task_migrate(),
> > dequeue_task()ing all of the affected threads for the duration of
> > the migrate?
> =

> That doesn't sound too unreasonable, actually - it would certainly
> simplify things a fair bit. Is there a standard API for doing that?

I'm all for simplifying cgroup locking. I doubt anybody's against
it, given the "right" simplification.

I'm not sure if the freezer is actually the right thing to
use for this though. Perhaps CFS/scheduler folks could advise?

> dequeue_task() itself doesn't really look like a public API. I guess
> that the task freezer would be one way to accomplish this?
 =

The freezer won't actually remove the task from the runqueue -- just
cause it to go into a schedule() loop until it's thawed.

[ Incidentally, sorry if this is a dumb question, but why don't frozen
tasks go onto a special wait queue rather than loop around schedule() ? =

At least for the cgroup freezer I can imagine keeping the wait queue
with the cgroup subsystem... ]

The freezer sends a fake signal to the task which will interrupt syscalls
and userspace to handle the signal. So all of the frozen tasks would be
looping around schedule() just inside the syscall entry layer "handling"
the fake signal until they are thawed.

This could interrupt a read of the cgroup pidlist for example.

I don't think it's 100% reliable -- vfork-ing tasks could delay freezing
the task "indefinitely" if the vfork'ing userspace tasks are =

clueless/malicious.

However the signaling code used there uses kick_process() which may be
needed for this idea.

So if I understand correctly it goes something like:

for each thread
	dequeue from runqueue onto ?what?
	kick thread (I think this should ensure that the thread is no longer
			"current" on any CPU since we dequeued..)

<seems we'd need something to ensure that the previous operations on each
thread have "completed" as far as all other cpus are concerned...>

for each thread
	cgroup migrate

for each thread
	enqueue back on runqueue from ?what? (is this still the right
						queue?)

Cheers,
	-Matt Helsley
