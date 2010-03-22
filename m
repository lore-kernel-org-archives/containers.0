From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH linux-cr] nested pid namespaces (v2)
Date: Mon, 22 Mar 2010 11:55:03 +0100
Message-ID: <20100322105502.GB5569@localdomain>
References: <20100319213955.GA17912@us.ibm.com>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0764961178118766441=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100319213955.GA17912-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============0764961178118766441==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-4448-1269255224-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-4448-1269255224-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 19, 2010 at 04:39:55PM -0500, Serge E. Hallyn wrote:
> Support checkpoint and restart of tasks in nested pid namespaces.  At
> Oren's request here is an alternative to my previous implementation.  In
> this one, we keep the original single pids_array to minimize memory
> allocations.  The pids array entries are augmented with a pidns depth
> (relative to the container init's pidns, and an "rpid" which is the pid
> in the checkpointer's pidns (or 0 if no valid pid exists).  The rpid
> will be used by userspace to gather more information (like
> /proc/$$/mountinfo) after the kernel sys_checkpoint.  If any tasks are
> in nested pid namespace, another single array holds all of the vpids.
> At restart those are used by userspace to determine how to call
> eclone().  Kernel ignores them.
>=20
> All cr_tests including the new pid_ns testcase pass.
>=20

IMHO this approach looks ok too. I just feel that checkpoint_vpids() could
be re-worked a bit in order to not impose an artificial limit of
CKPT_HDR_PIDS_CHUNK to the depth of pid namespaces, even if it is 256 (see
suggested changes below).

It would probably be safer too to use task_active_pid_ns() instead of
task->nsproxy->pid_ns, just in case some PID namespace unsharing like propo=
sed
by Eric makes it to mainline.

Thanks,

Louis

> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/checkpoint.c          |  113 ++++++++++++++++++++++++++++++++=
++----
>  checkpoint/process.c             |   18 +++++-
>  checkpoint/restart.c             |   45 ++++++++++++++-
>  checkpoint/sys.c                 |    2 +
>  include/linux/checkpoint.h       |    2 +-
>  include/linux/checkpoint_hdr.h   |   16 +++++
>  include/linux/checkpoint_types.h |    3 +
>  kernel/nsproxy.c                 |    9 ++-
>  8 files changed, 186 insertions(+), 22 deletions(-)
>=20
> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index f27af41..fe3546a 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -27,6 +27,7 @@
>  #include <linux/deferqueue.h>
>  #include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
> +#include <linux/pid_namespace.h>
> =20
>  /* unique checkpoint identifier (FIXME: should be per-container ?) */
>  static atomic_t ctx_count =3D ATOMIC_INIT(0);
> @@ -242,6 +243,7 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, =
struct task_struct *t)
>  	struct task_struct *root =3D ctx->root_task;
>  	struct nsproxy *nsproxy;
>  	int ret =3D 0;
> +	struct pid_namespace *pidns;
> =20
>  	ckpt_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
> =20
> @@ -293,10 +295,15 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx=
, struct task_struct *t)
>  		_ckpt_err(ctx, -EPERM, "%(T)Nested net_ns unsupported\n");
>  		ret =3D -EPERM;
>  	}
> -	/* no support for >1 private pidns */
> -	if (nsproxy->pid_ns !=3D ctx->root_nsproxy->pid_ns) {
> -		_ckpt_err(ctx, -EPERM, "%(T)Nested pid_ns unsupported\n");
> -		ret =3D -EPERM;
> +	/* pidns must be descendent of root_nsproxy */
> +	pidns =3D nsproxy->pid_ns;
> +	while (pidns !=3D ctx->root_nsproxy->pid_ns) {
> +		if (pidns =3D=3D &init_pid_ns) {
> +			ret =3D -EPERM;
> +			_ckpt_err(ctx, ret, "%(T)stranger pid_ns\n");
> +			break;
> +		}
> +		pidns =3D pidns->parent;
>  	}
>  	rcu_read_unlock();
> =20
> @@ -305,15 +312,19 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx=
, struct task_struct *t)
> =20
>  #define CKPT_HDR_PIDS_CHUNK	256
> =20
> +/*
> + * Write the pids in ctx->root_nsproxy->pidns.  This info is
> + * needed at restart to unambiguously dereference tasks.
> + */
>  static int checkpoint_pids(struct ckpt_ctx *ctx)
>  {
>  	struct ckpt_pids *h;
> -	struct pid_namespace *ns;
> +	struct pid_namespace *root_pidns;
>  	struct task_struct *task;
>  	struct task_struct **tasks_arr;
>  	int nr_tasks, n, pos =3D 0, ret =3D 0;
> =20
> -	ns =3D ctx->root_nsproxy->pid_ns;
> +	root_pidns =3D ctx->root_nsproxy->pid_ns;
>  	tasks_arr =3D ctx->tasks_arr;
>  	nr_tasks =3D ctx->nr_tasks;
>  	BUG_ON(nr_tasks <=3D 0);
> @@ -331,15 +342,21 @@ static int checkpoint_pids(struct ckpt_ctx *ctx)
>  	do {
>  		rcu_read_lock();
>  		for (n =3D 0; n < min(nr_tasks, CKPT_HDR_PIDS_CHUNK); n++) {
> +			struct pid_namespace *task_pidns;
>  			task =3D tasks_arr[pos];
> =20
> -			h[n].vpid =3D task_pid_nr_ns(task, ns);
> -			h[n].vtgid =3D task_tgid_nr_ns(task, ns);
> -			h[n].vpgid =3D task_pgrp_nr_ns(task, ns);
> -			h[n].vsid =3D task_session_nr_ns(task, ns);
> -			h[n].vppid =3D task_tgid_nr_ns(task->real_parent, ns);
> +			h[n].vpid =3D task_pid_nr_ns(task, root_pidns);
> +			h[n].vtgid =3D task_tgid_nr_ns(task, root_pidns);
> +			h[n].vpgid =3D task_pgrp_nr_ns(task, root_pidns);
> +			h[n].vsid =3D task_session_nr_ns(task, root_pidns);
> +			h[n].vppid =3D task_tgid_nr_ns(task->real_parent,
> +					root_pidns);
> +			task_pidns =3D task_nsproxy(task)->pid_ns;
> +			h[n].rpid =3D task_pid_vnr(task);
> +			h[n].depth =3D task_pidns->level - root_pidns->level;
>  			ckpt_debug("task[%d]: vpid %d vtgid %d parent %d\n",
>  				   pos, h[n].vpid, h[n].vtgid, h[n].vppid);
> +			ctx->nr_vpids +=3D h[n].depth;
>  			pos++;
>  		}
>  		rcu_read_unlock();
> @@ -356,6 +373,61 @@ static int checkpoint_pids(struct ckpt_ctx *ctx)
>  	return ret;
>  }
> =20
> +static int checkpoint_vpids(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_vpid *h;
> +	struct pid_namespace *root_pidns, *task_pidns;
> +	struct task_struct *task;
> +	int ret, nr_tasks =3D ctx->nr_tasks;
> +	int tidx =3D 0, /* index into task array */
> +		hidx =3D 0; /* pids written into current ckpt_vpids chunk */
> +
> +	root_pidns =3D ctx->root_nsproxy->pid_ns;
> +	nr_tasks =3D ctx->nr_tasks;
> +
> +	ret =3D ckpt_write_obj_type(ctx, NULL,
> +				  sizeof(*h) * ctx->nr_vpids,
> +				  CKPT_HDR_BUFFER);
> +	if (ret < 0)
> +		return ret;
> +
> +	h =3D ckpt_hdr_get(ctx, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	do {
> +		rcu_read_lock();
> +		while (tidx < nr_tasks) {
> +			int vidx; /* vpid index */
> +			int nsdelta;
> +
> +			task =3D ctx->tasks_arr[tidx];
> +			task_pidns =3D task_nsproxy(task)->pid_ns;
> +			nsdelta =3D task_pidns->level - root_pidns->level;
> +			if (hidx + nsdelta >=3D CKPT_HDR_PIDS_CHUNK)

I think that (hidx + nsdelta > CKPT_HDR_PIDS_CHUNK) checks more accurately =
the limit.

> +				break;
> +
> +			for (vidx =3D 0; vidx < nsdelta; vidx++) {
> +				h[vidx].pid =3D task_pid_nr_ns(task, task_pidns);

Here:
				h[hidx + vidx]

> +				task_pidns =3D task_pidns->parent;
> +			}
> +
> +			hidx +=3D nsdelta;
> +			tidx++;
> +		}
> +		rcu_read_unlock();
> +
> +		ret =3D ckpt_kwrite(ctx, h, hidx * sizeof(*h));
> +		if (ret < 0)
> +			break;
> +
> +		hidx =3D 0;
> +	} while (tidx < nr_tasks);
> +
> +	_ckpt_hdr_put(ctx, h, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
> +	return ret;
> +}

Maybe re-work it this way:

static int checkpoint_vpids(struct ckpt_ctx *ctx)
{
	struct ckpt_vpid *h;
	struct pid_namespace *root_pidns, *task_pidns, *active_pidns;
	struct task_struct *task;
	int ret, nr_tasks =3D ctx->nr_tasks;
	int tidx =3D 0, /* index into task array */
		hidx =3D 0; /* pids written into current ckpt_vpids chunk */
		vidx =3D 0; /* vpid index for current task */

	root_pidns =3D ctx->root_nsproxy->pid_ns;
	nr_tasks =3D ctx->nr_tasks;

	ret =3D ckpt_write_obj_type(ctx, NULL,
				  sizeof(*h) * ctx->nr_vpids,
				  CKPT_HDR_BUFFER);
	if (ret < 0)
		return ret;

	h =3D ckpt_hdr_get(ctx, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
	if (!h)
		return -ENOMEM;

	do {
		rcu_read_lock();
		while (tidx < nr_tasks && hidx < CKPT_HDR_PIDS_CHUNK) {
			int nsdelta;

			task =3D ctx->tasks_arr[tidx];
			active_pidns =3D task_active_pid_ns(task);
			nsdelta =3D active_pidns->level - root_pidns->level;
			if (hidx + nsdelta - vidx > CKPT_HDR_PIDS_CHUNK)
				/*
				 * We will release rcu before recording the
				 * remaining vpids, but neither task nor its
				 * pid can disappear.
				 */
				nsdelta =3D CKPT_HDR_PIDS_CHUNK - hidx + vidx;

			if (vidx =3D=3D 0)
				task_pidns =3D active_pidns;
			for (; vidx < nsdelta; vidx++) {
				h[hidx].pid =3D task_pid_nr_ns(task, task_pidns);
				hidx++;
				task_pidns =3D task_pidns->parent;
			}

			if (task_pidns =3D=3D root_pidns) {
				tidx++;
				vidx =3D 0;
			}
		}
		rcu_read_unlock();

		ret =3D ckpt_kwrite(ctx, h, hidx * sizeof(*h));
		if (ret < 0)
			break;

		hidx =3D 0;
	} while (tidx < nr_tasks);

	_ckpt_hdr_put(ctx, h, sizeof(*h) * CKPT_HDR_PIDS_CHUNK);
	return ret;
}

[...]

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-4448-1269255224-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkunTIYACgkQVKcRuvQ9Q1TgEgCgx+Uog0SGKcxkRXZ020hdP9OF
t1AAnj+iiqeBJtggEWD8FCTfaMtkmEO5
=YLgZ
-----END PGP SIGNATURE-----

--=_bohort-4448-1269255224-0001-2--

--===============0764961178118766441==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0764961178118766441==--
