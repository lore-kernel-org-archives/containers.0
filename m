From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH net-next 0/3] eBPF Seccomp filters
Date: Wed, 14 Feb 2018 01:47:10 +0100
Message-ID: <6b930450-37f8-ee3d-fab5-503ee50fa50b__12897.6516462446$1518569788$gmane$org@digikod.net>
References: <20180213154244.GA3292@ircssh-2.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3135921308213365088=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180213154244.GA3292-du9IEJ8oIxHXYT48pCVpJ3c7ZZ+wIVaZYkHkVr5ML8kVGlcevz2xqA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Cc: wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org
List-Id: containers.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--===============3135921308213365088==
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="4Nmvlvy6xTr9Am6iRU1HOnu8KKLKp1UTH"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--4Nmvlvy6xTr9Am6iRU1HOnu8KKLKp1UTH
Content-Type: multipart/mixed; boundary="hDf9t0OfSG2UBfMfCZA4pBENSwOR8y6Gq";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
To: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
 daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
 luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org
Message-ID: <6b930450-37f8-ee3d-fab5-503ee50fa50b-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH net-next 0/3] eBPF Seccomp filters
References: <20180213154244.GA3292-du9IEJ8oIxHXYT48pCVpJ3c7ZZ+wIVaZYkHkVr5ML8kVGlcevz2xqA@public.gmane.org>
In-Reply-To: <20180213154244.GA3292-du9IEJ8oIxHXYT48pCVpJ3c7ZZ+wIVaZYkHkVr5ML8kVGlcevz2xqA@public.gmane.org>

--hDf9t0OfSG2UBfMfCZA4pBENSwOR8y6Gq
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

seccomp-bpf does not use cBPF but a subset of it. The reason is that it
is meant to reduce the attack surface of the kernel. By limiting the
number of instructions allowed by seccomp-bpf, it really reduce the
possibilities for an attacker to use seccomp-bpf as an entry point to
attack the kernel. Moreover, this subset of cBPF is just fine to filter
simple things as syscall numbers and arguments. Additional return codes
may be added to extend seccomp features.

FYI, I'm tweaking a new version of Landlock, which is not an extension
of seccomp-bpf (as it was at first) but a standalone LSM leveraging eBPF
to create security sandboxes (what seccomp-bpf does not do). I'll send
this version soon but you can get a sneak peek here (the documentation
will come with the final version):
https://github.com/landlock-lsm/linux/commit/6c9131a5ccdf7aa599999b23f3a9=
ae2b73008f41
(please, do not comment this code now)

I think the current seccomp-bpf bytecode is excellent for what it is
meant to do. Landlock leverage eBPF to tackle a more complex problem
(e.g. control access to files, and much more). It is not a seccomp
replacement but a complementary layer of security.

About the verbosity of seccomp filters, you may want to try other ways
to write policies (e.g. https://github.com/google/kafel/ or
https://android.googlesource.com/platform/external/minijail/+/master/tool=
s/generate_seccomp_policy.py
or https://github.com/servo/gaol/blob/master/platform/linux/seccomp.rs).

Regards,
 Micka=EBl

On 13/02/2018 16:42, Sargun Dhillon wrote:
> This patchset enables seccomp filters to be written in eBPF. Although,
> this patchset doesn't introduce much of the functionality enabled by
> eBPF, it lays the ground work for it.
>=20
> It also introduces the capability to dump eBPF filters via the PTRACE
> API in order to make it so that CHECKPOINT_RESTORE will be satisifed.
> In the attached samples, there's an example of this. One can then use
> BPF_OBJ_GET_INFO_BY_FD in order to get the actual code of the program,
> and use that at reload time.
>=20
> The primary reason for not adding maps support in this patchset is
> to avoid introducing new complexities around PR_SET_NO_NEW_PRIVS.
> If we have a map that the BPF program can read, it can potentially
> "change" privileges after running. It seems like doing writes only
> is safe, because it can be pure, and side effect free, and therefore
> not negatively effect PR_SET_NO_NEW_PRIVS. Nonetheless, if we come
> to an agreement, this can be in a follow-up patchset.
>=20
>=20
> Sargun Dhillon (3):
>   bpf, seccomp: Add eBPF filter capabilities
>   seccomp, ptrace: Add a mechanism to retrieve attached eBPF seccomp
>     filters
>   bpf: Add eBPF seccomp sample programs
>=20
>  arch/Kconfig                 |   7 ++
>  include/linux/bpf_types.h    |   3 +
>  include/linux/seccomp.h      |  12 +++
>  include/uapi/linux/bpf.h     |   2 +
>  include/uapi/linux/ptrace.h  |   5 +-
>  include/uapi/linux/seccomp.h |  15 ++--
>  kernel/bpf/syscall.c         |   1 +
>  kernel/ptrace.c              |   3 +
>  kernel/seccomp.c             | 185 +++++++++++++++++++++++++++++++++++=
+++-----
>  samples/bpf/Makefile         |   9 +++
>  samples/bpf/bpf_load.c       |   9 ++-
>  samples/bpf/seccomp1_kern.c  |  17 ++++
>  samples/bpf/seccomp1_user.c  |  34 ++++++++
>  samples/bpf/seccomp2_kern.c  |  24 ++++++
>  samples/bpf/seccomp2_user.c  |  66 +++++++++++++++
>  15 files changed, 362 insertions(+), 30 deletions(-)
>  create mode 100644 samples/bpf/seccomp1_kern.c
>  create mode 100644 samples/bpf/seccomp1_user.c
>  create mode 100644 samples/bpf/seccomp2_kern.c
>  create mode 100644 samples/bpf/seccomp2_user.c
>=20


--hDf9t0OfSG2UBfMfCZA4pBENSwOR8y6Gq--

--4Nmvlvy6xTr9Am6iRU1HOnu8KKLKp1UTH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlqDhxsACgkQIt7+33O9
apVO9wgAiOTDg0a+LmxQ70ShlwBWmWJiEC7g0+xyW+O9WCo3m2xnXhalki/hQ5nq
rb8Ila07v9WBETNFqDgkXaEHI1QGe1afkZZwE57/JD3jFyskQJTdBaOt98incN5l
+c9A0Qc5i6qNN/qfn3Yo47tb3Y241YHrHkACk9devrvmObu7FCwfBp7bp+GmuGaP
ACMC3YeDDKoksQYggo4nvMwQi7HvrNJfDtygbV7Y9HM/aLHG43CjyJLNISdrsBvH
c17xCfpHIiCvfimN/kVW9MOmGjDhmIZD3tg7jVLcrk0sAToXx0DFWX1CLw6ZmlSE
MZQs8yE/AiI3wpvrYBxrcSOloED/RQ==
=wd36
-----END PGP SIGNATURE-----

--4Nmvlvy6xTr9Am6iRU1HOnu8KKLKp1UTH--

--===============3135921308213365088==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============3135921308213365088==--
