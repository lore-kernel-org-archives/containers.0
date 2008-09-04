From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v3][PATCH 2/9] General infrastructure for checkpoint restart
Date: Thu, 4 Sep 2008 11:12:30 +0200
Message-ID: <20080904091230.GW14473@hawkmoon.kerlabs.com>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0809040402170.5982@takamine.ncl.cs.columbia.edu>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3593648907999082878=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0809040402170.5982-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============3593648907999082878==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-6060-1220519417-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-6060-1220519417-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 04, 2008 at 04:02:38AM -0400, Oren Laadan wrote:
>
> Add those interfaces, as well as helpers needed to easily manage the
> file format. The code is roughly broken out as follows:
>
> checkpoint/sys.c - user/kernel data transfer, as well as setup of the
> checkpoint/restart context (a per-checkpoint data structure for
> housekeeping)
>
> checkpoint/checkpoint.c - output wrappers and basic checkpoint handling
>
> checkpoint/restart.c - input wrappers and basic restart handling
>
> Patches to add the per-architecture support as well as the actual
> work to do the memory checkpoint follow in subsequent patches.
>

[...]

> diff --git a/include/linux/ckpt_hdr.h b/include/linux/ckpt_hdr.h
> new file mode 100644
> index 0000000..629ad5a
> --- /dev/null
> +++ b/include/linux/ckpt_hdr.h
> @@ -0,0 +1,82 @@
> +#ifndef _CHECKPOINT_CKPT_HDR_H_
> +#define _CHECKPOINT_CKPT_HDR_H_
> +/*
> + *  Generic container checkpoint-restart
> + *
> + *  Copyright (C) 2008 Oren Laadan
> + *
> + *  This file is subject to the terms and conditions of the GNU General =
Public
> + *  License.  See the file COPYING in the main directory of the Linux
> + *  distribution for more details.
> + */
> +
> +#include <linux/types.h>
> +#include <linux/utsname.h>
> +
> +/*
> + * To maintain compatibility between 32-bit and 64-bit architecture flav=
ors,
> + * keep data 64-bit aligned: use padding for structure members, and use
> + * __attribute__ ((aligned (8))) for the entire structure.
> + */
> +
> +/* records: generic header */
> +
> +struct cr_hdr {
> +	__s16 type;
> +	__s16 len;
> +	__u32 parent;
> +};
> +
> +/* header types */
> +enum {
> +	CR_HDR_HEAD =3D 1,
> +	CR_HDR_STRING,
> +
> +	CR_HDR_TASK =3D 101,
> +	CR_HDR_THREAD,
> +	CR_HDR_CPU,
> +
> +	CR_HDR_MM =3D 201,
> +	CR_HDR_VMA,
> +	CR_HDR_MM_CONTEXT,
> +
> +	CR_HDR_TAIL =3D 5001
> +};
> +
> +struct cr_hdr_head {
> +	__u64 magic;
> +
> +	__u16 major;
> +	__u16 minor;
> +	__u16 patch;
> +	__u16 rev;
> +
> +	__u64 time;	/* when checkpoint taken */
> +	__u64 flags;	/* checkpoint options */
> +
> +	char release[__NEW_UTS_LEN];
> +	char version[__NEW_UTS_LEN];
> +	char machine[__NEW_UTS_LEN];
> +} __attribute__((aligned(8)));
> +
> +struct cr_hdr_tail {
> +	__u64 magic;
> +} __attribute__((aligned(8)));
> +
> +struct cr_hdr_task {
> +	__u64 state;
> +	__u32 exit_state;
> +	__u32 exit_code, exit_signal;

64bits alignment issue?
I probably missed it in previous versions...

Louis

> +
> +	__u64 utime, stime, utimescaled, stimescaled;
> +	__u64 gtime;
> +	__u64 prev_utime, prev_stime;
> +	__u64 nvcsw, nivcsw;
> +	__u64 start_time_sec, start_time_nsec;
> +	__u64 real_start_time_sec, real_start_time_nsec;
> +	__u64 min_flt, maj_flt;
> +
> +	__s32 task_comm_len;
> +} __attribute__((aligned(8)));
> +
> +#endif /* _CHECKPOINT_CKPT_HDR_H_ */

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-6060-1220519417-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIv6Z+VKcRuvQ9Q1QRAhVkAJ9nIWbXFmGlEyDnI2IQGu87lv746gCeIfTw
/5vn592JmSqbB4bIkeVUkuA=
=EgkY
-----END PGP SIGNATURE-----

--=_bohort-6060-1220519417-0001-2--

--===============3593648907999082878==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============3593648907999082878==--
