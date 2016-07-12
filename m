From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH v2 2/2] namespaces: add transparent user namespaces
Date: Tue, 12 Jul 2016 22:11:17 +0200
Message-ID: <57854EE5.1030707__23751.3036620387$1468355349$gmane$org@digikod.net>
References: <CAG48ez3ELMSsWhe9X_uq_3M7TjJxq=SnAr09g72nTkCRQY008g@mail.gmail.com>
	<1466814210-3778-1-git-send-email-jannh@google.com>
	<1466814210-3778-2-git-send-email-jannh@google.com>
	<87mvm6y8g9.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0490119178413135663=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87mvm6y8g9.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jann Horn <jannh-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>, Janis Danisevskis <jdanis-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Calvin Owens <calvinowens-b10kYP2dOMg@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--===============0490119178413135663==
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="XM3aoxrnr25pK8vPgwlFgVwTkluc5xmuD"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--XM3aoxrnr25pK8vPgwlFgVwTkluc5xmuD
Content-Type: multipart/mixed; boundary="sbc9UpFHVPG8OLdahQa4X8HLqjdJee4O8"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jann Horn <jannh-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
 Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Calvin Owens <calvinowens-b10kYP2dOMg@public.gmane.org>,
 Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
 John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
 Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
 Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
 Janis Danisevskis <jdanis-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alexey Dobriyan
 <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Message-ID: <57854EE5.1030707-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH v2 2/2] namespaces: add transparent user namespaces
References: <CAG48ez3ELMSsWhe9X_uq_3M7TjJxq=SnAr09g72nTkCRQY008g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
 <1466814210-3778-1-git-send-email-jannh-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
 <1466814210-3778-2-git-send-email-jannh-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
 <87mvm6y8g9.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
In-Reply-To: <87mvm6y8g9.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>

--sbc9UpFHVPG8OLdahQa4X8HLqjdJee4O8
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Hi,

I have been looking for this kind of feature for StemJail [1]. One of the=
 main idea is to being able to create mount points inside a jail as an un=
privileged user but to keep as much as possible the same environment from=
 outside the jail. For now, I can only create a mapping for the current u=
ser, so when a process list any files belonging to another user/group it =
get "nobody", which seems weird from a user point of view :)

Regards,
Micka=EBl


1. https://github.com/stemjail/stemjail


On 27/06/2016 17:09, Eric W. Biederman wrote:
>=20
> Added a few more relevant cc's.
>=20
> Jann Horn <jannh-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> writes:
>=20
>> This allows the admin of a user namespace to mark the namespace as
>> transparent. All other namespaces, by default, are opaque.
>=20
>=20
> I have just skimmed through this and at a high level this doesn't seem
> too scary.  Having an identity mapped user namespace that just limits
> you to using a subset of uids and gids while allowing displaying the
> full range of uids and gids.
>=20
> I don't quite get the use case and I would like to a little better
> but in the long term this shouldn't cause any significant maintenance
> issues, so I don't have any objects.
>=20
> At the same time this isn't quite the time to merge this.  I am in the
> process of slowly going through Seth's vfs changes to support things
> such as truly unprivileged fuse support.  Those changes alter which
> places can always be assumed to be init_user_ns (many fewer), and also
> slightly change the set of from_kuid calls being made.
>=20
> The changes that have made it through my review currently reside at:
>=20
>     git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespa=
ce.git for-next
>=20
> Those vfs changes make it conceivable and simple from an infrastructure=

> standpoint to transition fileystems to unprivileged user namespace
> mounts, with perhaps as little work as just setting FS_USER_NS.  At the=

> same time that won't be recommend because of the difficulty verifying
> evil filesystem contents can't cause fs implementations to do bad thing=
s
> is difficult.
>=20
> That change means your first patch that just zaps all from_kuid_munged
> users in init_user_ns isn't a particularly good idea.  I don't think it=

> is a good idea to have one set of rules for things that will always be
> init_user_ns and another set of rules for code that will change.
>=20
> The long and short of this is I am asking you to wait a week or so and
> rebase this on my for-next branch so that we can confirm this change
> interacts nicely will all of the other on-going work.
>=20
> Thank you,
> Eric Biederman
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
>=20




--sbc9UpFHVPG8OLdahQa4X8HLqjdJee4O8--

--XM3aoxrnr25pK8vPgwlFgVwTkluc5xmuD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJXhU7qAAoJECLe/t9zvWqVHOsH/iEaxCgS+yizXrURtf2xPBpV
fayy6jH7pUfuWN/qK59mhGDH+dTWi5G89pBm3Xp85JnKYG/mWznrYLy0pQojaNc5
ch0VL+p/V3oSMCNgGGHi2XKj0GqznT4QcS1IBqK4tTBxgcJ7ZvCEkKfDXCINJph3
++f2SPf6O8Vj3zCPRk6m/pRcYBF8jq6A97kw5jZCwFfwfAEq4JQ76wsirs668nzZ
fxdhdQJgBH6nWIPus38qIBIXTFNgYJR8HifeIXXcn6djXp2DkPdzzP0YcsFD/jYS
c9OtqgpvI92BQrGtQCDQCETW/F1M9Z6WsFgti+Gr3igXyBtQ608FH+PYopXrxHk=
=MB+e
-----END PGP SIGNATURE-----

--XM3aoxrnr25pK8vPgwlFgVwTkluc5xmuD--

--===============0490119178413135663==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============0490119178413135663==--
