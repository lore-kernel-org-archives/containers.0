From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][BUGFIX] cgroups: more safe tasklist locking in
	cgroup_attach_proc
Date: Mon, 1 Aug 2011 12:31:59 -0700
Message-ID: <CAJniumX+L5bXoXNXTppcDTtG5gHee=_Vk=h5EuOUBnpLQYDY2Q__10042.5064018511$1312227273$gmane$org@mail.gmail.com>
References: <20110727171101.5e32d8eb@notabene.brown>
	<20110727150710.GB5242@unix33.andrew.cmu.edu>
	<20110727234235.GA2318@linux.vnet.ibm.com>
	<20110728110813.7ff84b13@notabene.brown>
	<20110728062616.GC15204@unix33.andrew.cmu.edu>
	<20110728171345.67d3797d@notabene.brown>
	<20110729142842.GA8462@unix33.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110729142842.GA8462-japSPQJXeIlCM1neWV3AGuCmf2DRS9x2@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jul 29, 2011 at 7:28 AM, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> Fix unstable tasklist locking in cgroup_attach_proc.
>
> From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
>
> According to this thread - https://lkml.org/lkml/2011/7/27/243 - RCU is
> not sufficient to guarantee the tasklist is stable w.r.t. de_thread and
> exit. Taking tasklist_lock for reading, instead of rcu_read_lock,
> ensures proper exclusion.
>
> Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks,
Paul

> ---
> =A0kernel/cgroup.c | =A0 =A06 +++---
> =A01 file changed, 3 insertions(+), 3 deletions(-)
>
> diff a/kernel/cgroup.c b/kernel/cgroup.c
> --- a/kernel/cgroup.c =A0 2011-07-21 19:17:23.000000000 -0700
> +++ b/kernel/cgroup.c =A0 2011-07-29 06:17:47.000000000 -0700
> @@ -2024,7 +2024,7 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free_group_list;
>
> =A0 =A0 =A0 =A0/* prevent changes to the threadgroup list while we take a=
 snapshot. */
> - =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 read_lock(&tasklist_lock);
> =A0 =A0 =A0 =A0if (!thread_group_leader(leader)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * a race with de_thread from another thre=
ad's exec() may strip
> @@ -2033,7 +2033,7 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * throw this task away and try again (fro=
m cgroup_procs_write);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * this is "double-double-toil-and-trouble=
-check locking".
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 read_unlock(&tasklist_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D -EAGAIN;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free_group_list;
> =A0 =A0 =A0 =A0}
> @@ -2054,7 +2054,7 @@
> =A0 =A0 =A0 =A0} while_each_thread(leader, tsk);
> =A0 =A0 =A0 =A0/* remember the number of threads in the array for later. =
*/
> =A0 =A0 =A0 =A0group_size =3D i;
> - =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 read_unlock(&tasklist_lock);
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * step 1: check that we can legitimately attach to the cg=
roup.
>
