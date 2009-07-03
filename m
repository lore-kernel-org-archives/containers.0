From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] Adds a read-only "procs" file similar to "tasks" that
	shows only unique tgids
Date: Fri, 3 Jul 2009 08:52:46 -0700
Message-ID: <6599ad830907030852p2cd667e3m353d68448e0cdc6a__43317.2158235267$1246636540$gmane$org@mail.gmail.com>
References: <20090702231814.3969.44308.stgit@menage.mtv.corp.google.com>
	<20090702232620.3969.16680.stgit@menage.mtv.corp.google.com>
	<20090702164649.303c4952.akpm@linux-foundation.org>
	<2f86c2480907021731h13e0bb95q94f06829eded9aa6@mail.gmail.com>
	<20090702175341.fd2e26d5.akpm@linux-foundation.org>
	<6599ad830907021808o6f3bb51eh324e4bf13544d83e@mail.gmail.com>
	<20090702183004.1e3f4315.akpm@linux-foundation.org>
	<20090703145441.f526793f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090703145441.f526793f.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, lizf-BthXqXjhjHXBeW8qKU6YJg@public.gmane.org, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jul 2, 2009 at 10:54 PM, KAMEZAWA
Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>
> Why we can't do what readdir(/proc) does ? I'm sorry I misunderstand.
> Following is an easy example.
>
>
> 0. at open, inilialize f_pos to 0. f_pos is used as "pid"
> =A0 remember "css_set with hole" as template in f_private?(or somewhere) =
at open
> =A0 ...like this.
> --
> =A0 struct cgroupfs_root *root =3D cgrp->root;
> =A0 struct cgroup *template =3D kzalloc(sizeof(void*) * CGROUP_SUBSYS_COU=
NT);
>
> =A0 for (i =3D 0; i < CGROUP_SUBSYS_COUNT; i++)
> =A0 =A0 =A0 =A0if (root->subsys_bits & (1UL << i))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0template[i] =3D =A0cgrp->subsys[i];
> --
>
>
> 1. at read(), find task_struct of "pid" in f_pos.
> 2. look up task_struct of "pid" and compare with f_private
> --
> =A0 struct cgroup *template =3D f_private;
>
> =A0 for (i =3D 0; i < CGROUP_SUBSYS_COUNT; i++) {
> =A0 =A0 =A0 =A0if (!template[i])
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0contiue;
> =A0 =A0 =A0 =A0if (template[i] !=3D task_subsys_state(task, i))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 }
> =A0 if (i =3D=3D CGROUP_SUBSYS_COUNT)
> =A0 =A0 =A0 =A0print task;

The problem with this is that the time taken to scan a single cgroup
is linear in the total number of threads in the system, so if you have
a lot of threads and a lot of cgroups (even if most of the threads are
concentrated in a single cgroup) the time taken to scan all the tasks
files in O(N^2) in the number of threads in the system. The current
scheme is linear in the number of threads in a cgroup, so looking at
all cgroups is linear in the number of threads in the system. (This
O(N^2) problem is something that we've actually observed as an
overhead on some busy systems at Google).

Paul
