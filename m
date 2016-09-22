From: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Subject: Re: Escape from a bind mount
Date: Thu, 22 Sep 2016 15:02:53 +0200
Message-ID: <20160922130253.GB20504@pc.thejh.net>
References: <CAJH6TXhzy4XAQKaKjrK5Yqzg0sxtPjU9D=X3AHZZ76N3Cpwkwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4817611156888564793=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAJH6TXhzy4XAQKaKjrK5Yqzg0sxtPjU9D=X3AHZZ76N3Cpwkwg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gandalf Corvotempesta <gandalf.corvotempesta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============4817611156888564793==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ftEhullJWpWg/VHq"
Content-Disposition: inline


--ftEhullJWpWg/VHq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 22, 2016 at 02:49:12PM +0200, Gandalf Corvotempesta wrote:
> Last year, this thread was posted:
> https://lists.linuxfoundation.org/pipermail/containers/2015-April/035788.=
html
>=20
> is this fixed or is still possible to escape from a bind mount inside
> the container ?

This was fixed by Eric Biederman in the "Bind mount escape fixes" patch ser=
ies
in August 2015.
Relevant commits are 397d425d and cde93be4 (maybe more? I'm not sure).

--ftEhullJWpWg/VHq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX49Z9AAoJED4KNFJOeCOocK4QAImlJ80kVAKIdLfXaDNzCzI0
q/jFAqzgMOE1nGLma/nqbMY4FxCgWUFc1AOgYhIIWWKDQfih/O3eFmtRWRAteYYh
CxqApNj0bFlXwhMoxavkFNziTHC9TKSYxBgx8ZdjGUURX2uhfH764hkQfIh+jMHi
DTCpH7mA3/uWeOTzybK2TducMndzEDe2HFxdNxf+1Fra2ehU+uIyfeWl3jU6f2y1
gaBDg1dsti/rTs1wThLwoA2CsZpmXKKWJLdQijroB+0Y/w2JeDcs1Vbg3guulU4R
/KDaEUwkbc7du5uUNNbTo+bXns+IAHEPLJvOQPXcaUFbeN39dHGiVkBYStKSIIDh
QD58SL3pRnayiCU9cB4RM2FWBcwzqCM5N8vDcRM06dU7UHix97rRfGy41OsOSOwc
i+mxxE+4ZRUfmnqlK0l9BuQaxB5Chuo8Jiqf1hauHO8JSaVCEHod1KO6yfRYAdC2
fMNijHYWp+aeLdPh+0JmDlzozBZrohuIdqGNEJHWnwO9sKNig1y2J9l9etp282IE
zjk6dirPkS8joN8HdciHTlbvkS34AqsC9gcr+wa2gku28Kf+KUcQ8xeg0QYPiJ7T
vLpfSgeSEMDDU3Lm0eEfFqdJ98g8xWvhXrjZYEV9Q5am1JeDIRyZlAZqvLvmOPuJ
LZLPP4KFbZZdZzXsQB7f
=Ppc3
-----END PGP SIGNATURE-----

--ftEhullJWpWg/VHq--

--===============4817611156888564793==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============4817611156888564793==--
