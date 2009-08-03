From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by
	tgid at once
Date: Mon, 3 Aug 2009 14:45:55 -0500
Message-ID: <20090803194555.GA10158__27903.8006942303$1249328806$gmane$org@us.ibm.com>
References: <20090731012908.27908.62208.stgit@hastromil.mtv.corp.google.com>
	<20090731015154.27908.9639.stgit@hastromil.mtv.corp.google.com>
	<20090803175452.GA5481@us.ibm.com>
	<2f86c2480908031113y525b6cbdhe418b8a0364c7760@mail.gmail.com>
	<20090803185556.GA8469@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090803185556.GA8469-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Quoting Benjamin Blum (bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> > On Mon, Aug 3, 2009 at 1:54 PM, Serge E. Hallyn<serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > > Quoting Ben Blum (bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> > > What *exactly* is it we are protecting with cgroup_fork_mutex?
> > > 'fork' (as the name implies) is not a good answer, since we should be
> > > protecting data, not code.  If it is solely tsk->cgroups, then perhaps
> > > we should in fact try switching to (s?)rcu. =A0Then cgroup_fork() cou=
ld
> > > just do rcu_read_lock, while cgroup_task_migrate() would make the cha=
nge
> > > under a spinlock (to protect against concurrent cgroup_task_migrate()=
s),
> > > and using rcu_assign_pointer to let cgroup_fork() see consistent data
> > > either before or after the update... =A0That might mean that any chec=
ks done
> > > before completing the migrate which involve the # of tasks might beco=
me
> > > invalidated before the migration completes? =A0Seems acceptable (since
> > > it'll be a small overcharge at most and can be quickly remedied).
> > =

> > You'll notice where the rwsem is released - not until cgroup_post_fork
> > or cgroup_fork_failed. It doesn't just protect the tsk->cgroups
> > pointer, but rather guarantees atomicity between adjusting
> > tsk->cgroups and attaching it to the cgroups lists with respect to the
> > critical section in attach_proc. If you've a better name for the lock
> > for such a race condition, do suggest.
> =

> No the name is pretty accurate - it's the lock itself I'm objecting
> to.  Maybe it's the best we can do, though.

This is probably a stupid idea, but...  what about having zero
overhead at clone(), and instead, at cgroup_task_migrate(),
dequeue_task()ing all of the affected threads for the duration of
the migrate?

/me prepares to be hit by blunt objects

-serge
