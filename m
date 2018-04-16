From: Alexey Gladkov <gladkov.alexey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] [RFC][WIP] namespace.c: Allow some unprivileged proc
	mounts when not fully visible
Date: Mon, 16 Apr 2018 16:16:16 +0200
Message-ID: <20180416141616.GB21965__4622.06339366293$1523888649$gmane$org@comp-core-i7-2640m-0182e6>
References: <20180404115311.725-1-alban@kinvolk.io>
	<87tvsrjai0.fsf@xmission.com>
	<CAEiveUf5LWpvA-QMm3eYr9yFgUjwyQdkk-WVptze9m_EfbGMwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1499677039592681505=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAEiveUf5LWpvA-QMm3eYr9yFgUjwyQdkk-WVptze9m_EfbGMwg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Iago Lopez Galeiras <iago-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Akihiro Suda <suda.akihiro-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>, Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Michael Crosby <crosbymichael-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Stephen J Day <stephen.day-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jess Frazelle <acidburn-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============1499677039592681505==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tKW2IUtsqtDRztdT"
Content-Disposition: inline


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Apr 14, 2018 at 12:41:31AM +0200, Djalal Harouni wrote:
> On Wed, Apr 4, 2018 at 4:45 PM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>=
 wrote:
> [...]
> >
> > The only option I have seen proposed that might qualify as something
> > general purpose and simple is a new filesystem that is just the process
> > directories of proc.  As there would in essence be no files that would
> > need restrictions it would be safe to allow anyone to mount without
> > restriction.
> >
> Eric, there is a series for this:
> https://www.mail-archive.com/linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg1533642.html
>=20
> patch on top for pids:
> https://github.com/legionus/linux/commit/993a2a5b9af95b0ac901ff41d32124b7=
2ed676e3
>=20
> it was reviewed, and suggestions were integrated from Andy and Al Viro
> feedback, thanks. It works on Debian, Ubuntu and others, not on Fedora
> due to bug with dracut+systemd.
>=20
> I do not have time to work on it now, anyone can just pick them.

I continue to work on this. I am now trying to deal with the problem on
Fedora. I hope to return soon with the results.

--=20
Rgrds, legion


--tKW2IUtsqtDRztdT
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJa1LATAAoJEKRaulRM/9Q0mxgP/i5DN/dM7ff93D15xZ81YBsz
LudWQV2KVlRl09E24AQEOU806DJkxNjw5x+cQB40Oh9FgzqvLsHceseYH6dbUtz4
wrHlZnya1nQRZl32Bx+5XCDGbVN0ylBO7P1ZUUMHNYJN91q36o/RIlncKJ4m6VuW
ViGx9lb/e6frjSiHnWEui3V0kut4cCnoS/CsatpjlZK77GkwuJMwJph49FNRwZBs
w1t7exDPRI4y7nG9ufWT5/okIQv0awAo6DdPRJT/8FdRNLoeRJhYEUF1Ul+uRMVj
ZiQQBlnH+eTdMtvhr1zy99QYQSVpIwfBW8wXd2IxAEOF+l8js8GxzShShJ8cHtvP
x3Rm9yUFBuT8CoM+Y8or/Ev9HfyoECOHKzKzrYLSN2JKZVa7Jou9OnsZ/EeIbqyt
wGlAsuGEgi7Is/eXB/N0vj05QLklukNuwGaXY3tBrvcZB1GubTsnJ3wRRU2UipRz
8XP7yTDq0ntyO+d5YocC4SPCO+up7LWjT1a1+vTgpA/sWCwuVMlwkKTv6Qe3bIit
mzlIckxgJ/MjRDCruzd+xviRWy3xzlgI0NIFsIHB7nmcYjv/izlIBQ7uAK0sUkHN
2gc1phjgob8kSJiAd4icrbCKV2i1hhg1r8Lj6tCuHSGctACCsb6itZnfYA+DpJWV
3YGDyJeeO9znx/7PEhMr
=kikD
-----END PGP SIGNATURE-----

--tKW2IUtsqtDRztdT--

--===============1499677039592681505==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============1499677039592681505==--
