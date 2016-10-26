From: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Subject: Re: Keyrings, user namespaces and the user_struct
Date: Wed, 26 Oct 2016 16:38:56 +0200
Message-ID: <20161026143856.GL3334__40912.4391539537$1477492770$gmane$org@pc.thejh.net>
References: <CALCETrU0PqNYmWx70pugkhj-kAD5DSzSi3swhK+v12WMYZYUZA@mail.gmail.com>
	<17576.1477412418@warthog.procyon.org.uk>
	<18335.1477414412@warthog.procyon.org.uk>
	<1477414605.3079.40.camel@HansenPartnership.com>
	<20161025170602.GB24481@laptop.thejh.net>
	<1477418708.3079.52.camel@HansenPartnership.com>
	<20161025181735.GC24481@laptop.thejh.net>
	<9243.1477492490@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2055719935502677112=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <9243.1477492490-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, LSM List <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


--===============2055719935502677112==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jtcAeju3WzRmRF+o"
Content-Disposition: inline


--jtcAeju3WzRmRF+o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 26, 2016 at 03:34:50PM +0100, David Howells wrote:
> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>=20
> > > | Not just questionable, completely wrong. The gist is that there is a
> > > | *global* name -> key mapping for accessing keys by name, and user
> > > | keyrings are stored in there under the name "_uid.%u", where %u
> > > | refers to the *namespaced* UID. (See install_user_keyrings().)
> > > | The result is that, if e.g. the user with UID 1000 has no running
> > > | processes, a local attacker can enter a new user namespace, map UID
> > > | 1000 in the namespace to some KUID he controls, do
> > > | setresuid(1000, 1000, 1000), and now he owns user 1000's keyring.
>=20
> Hmmm...  Having checked over the code, it might not be that simple.  Than=
ks to
> something Eric Biederman added into find_keyring_by_name(), unless a keyr=
ing's
> UID is a member of the current user namespace, you can't find that keyrin=
g by
> name.

find_keyring_by_name() checks that the UID of the keyring's owner is mapped=
 into
the current user namespace. But that doesn't catch the scenario I described:
The keyring is created in an attacker-created namespace and looked up from =
the
init namespace, into which all kuids are mapped.

--jtcAeju3WzRmRF+o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYEMAAAAoJED4KNFJOeCOoEKkQAKNnebS4eqnxJRvwfUIprJvd
Z4+5HJECzUUJgdxLgFEltHV3wF33e6JgE8DrHkrEo758FsfKOkyFE0WoNeudo2nJ
qBLFoupU+5B54DOEYA4fMfu107G7Wnk5nJRFIoz+otw6lCYDDpQoYE1TvAs/L23O
oyuCIr5OssMEgEsbOkCP9405B/Lbr6j1XuRunukjvfK0YWPEAWwoUIsjObz6WdUz
I07KtD6ApngzKKi3zpjmHmQBF8V6nIu/XWOvQDoWmSS7O0VOrYNawO81P/32yYmo
u2sjvOhvZQjUhmAAlgCyxqtM3Ay64/zDpZMx880nSs+pskDMK0aDjNUgtDpsj3mo
P68h0aprnp23aQlfB0W+H5VlejrpCm7Jlvhh6d0+77JUcmm0madExU4xwmzsFflY
ZUQQp/VPP21qonaMVjXhZvxCdi6Fis3o4AGF+x7Yz6I7epmIQMiCuA8+PVYjV8KE
9TelaBeJ2cEPnDEVOSiDVCoLpIiW8aAMgb2rKhn4YOhl1mB46YYka+IoP68fP0f9
BbcAJoVrlDzJeDY6LbsQd/i0t6NVrzIDPZILMuyy3Wd6XgQqSzwivI5f+N286Ci2
dsFnhaVarc2aLqJjbOcWr6weijtiMavj2TSVc7PZ4LGArYLPlsdxDLeSubSB6RiX
Mr1cmRfxRX5MobgDuxrm
=Vndc
-----END PGP SIGNATURE-----

--jtcAeju3WzRmRF+o--

--===============2055719935502677112==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============2055719935502677112==--
