From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Thu, 31 Jul 2008 15:57:03 +0200
Message-ID: <20080731135703.GC22403@hawkmoon.kerlabs.com>
References: <Pine.LNX.4.64.0807292325290.9868@takamine.ncl.cs.columbia.edu>
	<20080730220752.GA3518@us.ibm.com>
	<4890E930.9090204@cs.columbia.edu>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4890E930.9090204-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jul 30, 2008 at 06:20:32PM -0400, Oren Laadan wrote:
> =

> =

> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >> +int do_checkpoint(struct cr_ctx *ctx)
> >> +{
> >> +	int ret;
> >> +
> >> +	/* FIX: need to test whether container is checkpointable */
> >> +
> >> +	ret =3D cr_write_hdr(ctx);
> >> +	if (!ret)
> >> +		ret =3D cr_write_task(ctx, current);
> >> +	if (!ret)
> >> +		ret =3D cr_write_tail(ctx);
> >> +
> >> +	/* on success, return (unique) checkpoint identifier */
> >> +	if (!ret)
> >> +		ret =3D ctx->crid;
> > =

> > Does this crid have a purpose?
> =

> yes, at least three; both are for the future, but important to set the
> meaning of the return value of the syscall already now. The "crid" is
> the CR-identifier that identifies the checkpoint. Every checkpoint is
> assigned a unique number (using an atomic counter).
> =

> 1) if a checkpoint is taken and kept in memory (instead of to a file) then
> this will be the identifier with which the restart (or cleanup) would ref=
er
> to the (in memory) checkpoint image
> =

> 2) to reduce downtime of the checkpoint, data will be aggregated on the
> checkpoint context, as well as referenced to (cow-ed) pages. This data can
> persist between calls to sys_checkpoint(), and the 'crid', again, will be
> used to identify the (in-memory-to-be-dumped-to-storage) context.
> =

> 3) for incremental checkpoint (where a successive checkpoint will only
> save what has changed since the previous checkpoint) there will be a need
> to identify the previous checkpoints (to be able to know where to take
> data from during restart). Again, a 'crid' is handy.
> =

> [in fact, for the 3rd use, it will make sense to write that number as
> part of the checkpoint image header]
> =

> Note that by doing so, a process that checkpoints itself (in its own
> context), can use code that is similar to the logic of fork():
> =

> 	...
> 	crid =3D checkpoint(...);
> 	switch (crid) {
> 	case -1:
> 		perror("checkpoint failed");
> 		break;
> 	default:
> 		fprintf(stderr, "checkpoint succeeded, CRID=3D%d\n", ret);
> 		/* proceed with execution after checkpoint */
> 		...
> 		break;
> 	case 0:
> 		fprintf(stderr, "returned after restart\n");
> 		/* proceed with action required following a restart */
> 		...
> 		break;
> 	}
> 	...

If I understand correctly, this crid can live for quite a long time. So man=
y of
them could be generated while some container would accumulate incremental
checkpoints on, say crid 5, and possibly crid 5 could be reused for another
unrelated checkpoint during that time. This brings the issue of allocating =
crids
reliably (using something like a pidmap for instance). Moreover, if such id=
s are
exposed to userspace, we need to remember which ones are allocated accross
reboots and migrations.

I'm afraid that this becomes too complex...

It would be way easier if the only (kernel-level) references=A0to a checkpo=
int
were pointers to its context. Ideally, the only reference would live in a
'struct container' and would be easily updated at restart-time.

My $0.02 ...

Louis

-- =

Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes
