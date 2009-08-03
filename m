From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by tgid
	at once
Date: Mon, 3 Aug 2009 11:07:54 -0700
Message-ID: <6599ad830908031107l4b924a86r423c4fedc06b0040__16748.8852436238$1249323024$gmane$org@mail.gmail.com>
References: <20090731012908.27908.62208.stgit@hastromil.mtv.corp.google.com>
	<20090731015154.27908.9639.stgit@hastromil.mtv.corp.google.com>
	<20090803175452.GA5481@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090803175452.GA5481-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Aug 3, 2009 at 10:54 AM, Serge E. Hallyn<serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>> + =A0 =A0 if (guarantee) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* our caller promises us that the css_set w=
e want already
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* exists, so we use find_existing_css_set d=
irectly.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_subsys_state *template[CGROUP_SU=
BSYS_COUNT];
>> + =A0 =A0 =A0 =A0 =A0 =A0 read_lock(&css_set_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 newcg =3D find_existing_css_set(oldcg, cgrp, t=
emplate);
>> + =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(!newcg);
>> + =A0 =A0 =A0 =A0 =A0 =A0 get_css_set(newcg);
>> + =A0 =A0 =A0 =A0 =A0 =A0 read_unlock(&css_set_lock);
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 might_sleep();
>
> So cgroup_task_migrate() might sleep, but
>

might sleep if guarantee=3D=3D0

>> + =A0 =A0 =A0 =A0 =A0 =A0 retval =3D cgroup_task_migrate(cgrp, oldcgrp, =
tsk, 1);
>
> Here it is called under rcu_read_lock().

With guarantee=3D=3D1

>
> What *exactly* is it we are protecting with cgroup_fork_mutex?
> 'fork' (as the name implies) is not a good answer, since we should be
> protecting data, not code. =A0If it is solely tsk->cgroups, then perhaps
> we should in fact try switching to (s?)rcu. =A0Then cgroup_fork() could
> just do rcu_read_lock, while cgroup_task_migrate() would make the change
> under a spinlock (to protect against concurrent cgroup_task_migrate()s),
> and using rcu_assign_pointer to let cgroup_fork() see consistent data
> either before or after the update... =A0That might mean that any checks d=
one
> before completing the migrate which involve the # of tasks might become
> invalidated before the migration completes?

What's being protected is the ability to move an entire thread group
to the new destination cgroup, even in the presence of concurrent
thread clone operations. New threads aren't visible to other threads
until the point when they're attached to the tasklist, so if any
concurrent do_fork() operation is somewhere between the call to
cgroup_fork() and the attachment to the tasklist when the "attach proc
to new cgroup" operation occurs, it may get left behind.

Paul
