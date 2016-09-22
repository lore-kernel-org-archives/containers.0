From: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Subject: Re: Escape from a bind mount
Date: Thu, 22 Sep 2016 16:34:21 +0200
Message-ID: <20160922143421.GD20504@pc.thejh.net>
References: <CAJH6TXhzy4XAQKaKjrK5Yqzg0sxtPjU9D=X3AHZZ76N3Cpwkwg@mail.gmail.com>
	<20160922130253.GB20504@pc.thejh.net>
	<CAJH6TXje-Zb54scg8-UTchZEa2RCOGVdaB0DQ_ipbJtNEAPPGA@mail.gmail.com>
	<20160922134833.GC20504@pc.thejh.net>
	<CAJH6TXi=G90x24ThdZAfZMhVRN86B0LS5R-WuCn+OtGsFNjm8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1469341645270336450=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAJH6TXi=G90x24ThdZAfZMhVRN86B0LS5R-WuCn+OtGsFNjm8Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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


--===============1469341645270336450==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3Pql8miugIZX0722"
Content-Disposition: inline


--3Pql8miugIZX0722
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 22, 2016 at 04:23:11PM +0200, Gandalf Corvotempesta wrote:
> 2016-09-22 15:48 GMT+02:00 Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>:
> > It shouldn't be possible to escape from bind mounts anymore. That was a
> > bug, and it was fixed.
> > Where do the docs mention this? We should probably ask them to fix that.
>=20
> Is this also backported to older kernel versions? From which kernel
> version is fixed ?

$ git describe --contains 397d425d
v4.3-rc1~66^2

It was fixed in kernel 4.3.

https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/?i=
d=3Drefs%2Ftags%2Fv4.1.33&qt=3Dgrep&q=3Dvfs%3A+Test+for+and+handle+paths+th=
at+are+unreachable+from+their+mnt_root
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/?i=
d=3Drefs/tags/v3.18.42&qt=3Dgrep&q=3Dvfs%3A+Test+for+and+handle+paths+that+=
are+unreachable+from+their+mnt_root
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/?i=
d=3Drefs/tags/v3.16.37&qt=3Dgrep&q=3Dvfs%3A+Test+for+and+handle+paths+that+=
are+unreachable+from+their+mnt_root
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/?i=
d=3Drefs/tags/v3.14.79&qt=3Dgrep&q=3Dvfs%3A+Test+for+and+handle+paths+that+=
are+unreachable+from+their+mnt_root
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/?i=
d=3Drefs/tags/v3.12.63&qt=3Dgrep&q=3Dvfs%3A+Test+for+and+handle+paths+that+=
are+unreachable+from+their+mnt_root
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/?i=
d=3Drefs/tags/v3.10.103&qt=3Dgrep&q=3Dvfs%3A+Test+for+and+handle+paths+that=
+are+unreachable+from+their+mnt_root
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/?i=
d=3Drefs/tags/v3.4.112&qt=3Dgrep&q=3Dvfs%3A+Test+for+and+handle+paths+that+=
are+unreachable+from+their+mnt_root
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/log/?i=
d=3Drefs/tags/v3.2.82&qt=3Dgrep&q=3Dvfs%3A+Test+for+and+handle+paths+that+a=
re+unreachable+from+their+mnt_root

The fix was backported to all longterm stable kernels listed at https://ker=
nel.org/.

--3Pql8miugIZX0722
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX4+vtAAoJED4KNFJOeCOoEoEQAN/6doYhLQOcGj2n23Z6QsxA
3r412CvdQXbLrFY7v8LM+K6PGvFBGB5vB+epArbYI8o9lZSdi+47IKQLuEFL93Jz
PHcSpf995sAY+wlSC7pMOr6l9ug/3oetmau6ErOijPfp+eFUGG3RFo/ZpRe16LGh
Av2hrWDEYx46iXlBTwhIR+fkCNAPcW8ekqe8OkJyLxSONsOtu0tGICJaDxwFZ2ms
mHra/3I6ZCTu6OofrA5b7GHpHEhlYPygMgcqHnjYx4NSmVTOFmf1LwwPooJjm2cW
EVA4LSUGgrLs4/IdHpkRs8OaQLokz+XTHUK0gtrJDXxTKfA01AmG63EWCNukLNJE
3Z1RgIf2GbFlMj7+QbKjJr+xFVU+Q9ywJ96TabtIUf3KNCC91XfFtlLXfkxJeBBv
52I4TCLH54kmpgsP08UeZUDm7s1Qci51QNArgfnMSzAJ5aU6lkosYePVFgiGovbj
/Np1vNEIhYeyk++rVsZdrfw2G2N1sOT4caoOPrzdzjab9UHwFNKTGlpnu8uyVhLG
+BlkZPGKIDWgeE97evh1B63WCvfjCiXdyXwsvDfhcqSXOevqBMAii/btQnfBcmxm
Kjnio9+S+C7fIoyfyloDox8QmFA05S+RYnLFACO/+vAtJciItncjvmjGseTYgqAo
qTDuDfkJrPNiL8MT95gS
=3COS
-----END PGP SIGNATURE-----

--3Pql8miugIZX0722--

--===============1469341645270336450==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============1469341645270336450==--
