From: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Subject: Re: Escape from a bind mount
Date: Thu, 22 Sep 2016 15:48:33 +0200
Message-ID: <20160922134833.GC20504@pc.thejh.net>
References: <CAJH6TXhzy4XAQKaKjrK5Yqzg0sxtPjU9D=X3AHZZ76N3Cpwkwg@mail.gmail.com>
	<20160922130253.GB20504@pc.thejh.net>
	<CAJH6TXje-Zb54scg8-UTchZEa2RCOGVdaB0DQ_ipbJtNEAPPGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0644350942687465764=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAJH6TXje-Zb54scg8-UTchZEa2RCOGVdaB0DQ_ipbJtNEAPPGA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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


--===============0644350942687465764==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XMCwj5IQnwKtuyBG"
Content-Disposition: inline


--XMCwj5IQnwKtuyBG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 22, 2016 at 03:31:45PM +0200, Gandalf Corvotempesta wrote:
> 2016-09-22 15:02 GMT+02:00 Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>:
> > This was fixed by Eric Biederman in the "Bind mount escape fixes" patch=
 series
> > in August 2015.
> > Relevant commits are 397d425d and cde93be4 (maybe more? I'm not sure).
>=20
> So, now is not possible to escape from bind ? There was a reference to
> this in official Docker docs.

It shouldn't be possible to escape from bind mounts anymore. That was a
bug, and it was fixed.
Where do the docs mention this? We should probably ask them to fix that.


> Just for my info: to escape from the container, an attacker would have
> to move the bound directory directly from the host? Having access only
> to the container would't make this issue happen ?
> In example, if I have bound as follow:
>    /mnt/dir1 =3D> /home/myuser/path_inside_container
>=20
> moving (from the host) /mnt/dir1 to somewhere else like /tmp/dir1 will
> make the container able to escape ?

No. If you had namespaced root privileges in a container, it was also
possible to trigger the bug from inside the container.
But really, that shouldn't be an issue for you anymore, considering
that this was fixed a year ago and was apparently also backported to
stable kernels. Why are you asking?

--XMCwj5IQnwKtuyBG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX4+ExAAoJED4KNFJOeCOoYIwP/iilia2JMUAv9j6JCrHAWM0Q
MN/f+h2kLLVfgoLXW45HY28DEQKhMIrvcImMwaKuW8KmNjQCKShA9KcejjkiYBNX
rAd0TluD/6FnsAhffQR06PnN/l5Yqxxdh1ZWBwKtoJqVDpcv7RXL8Z3CEdYnjhIh
LVFbjCN5jzM/UYJRXKodB4xWvmon2EIl+QgLxmh1wZz6ayDDtHdLBE0E7+qcf+w2
e8jAdF385EnMqtT8Z3HMQgM3210W5ydOFykxUX81hJidbJb1Gpt7lmfYU9QbmSXh
Ui2+Hlnl5xcczXOgGUVqH77Ib4iH0vMAAERqUryPWNrkHcCZHyeBncE48WXHe7re
cJcvQAmJm/g72J2A7M2h+0Y20KvP0dDXbBYHAXc7y6EcrXdPD9+3Se+dJ3043UoD
Ih5Bys4puyHE/ErPc9p0xFNIiPUlc0KbgTjjBtm4++cTZotPSs3vC9PIrPVcuA2o
inpGWTA+R3VV2wuRp/SE5dkhr/8o2uV6jj3sYmuSUD2Xa9E4HJeVlbQiI7XSXMsJ
MCpClg6PiVctmSUGD/fkXDmYYE0JU3B8nlUtaq/NuW5CxNCwL2VZI3g3dA/iUHTA
NkabbyWuSb/wbHUN7fzZXAXSZj8fFCNa2OAgNg0KPfpvi48EFXV5i3o2IZgMiJDu
YQXGUVVQ01kDClf/5oQH
=Dn6i
-----END PGP SIGNATURE-----

--XMCwj5IQnwKtuyBG--

--===============0644350942687465764==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============0644350942687465764==--
