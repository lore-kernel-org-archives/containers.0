From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [patch] util-linux-ng: unprivileged mounts support
Date: Wed, 16 Jan 2008 08:17:10 -0500
Message-ID: <200801160817.12812.vapier@gentoo.org>
References: <E1JF7Xh-0003q3-Qv@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2023442.yLlF9ht91N";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <E1JF7Xh-0003q3-Qv@pomaz-ex.szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: util-linux-ng@vger.kernel.org, akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, kzak@redhat.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

--nextPart2023442.yLlF9ht91N
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 16 January 2008, Miklos Szeredi wrote:
> This is an experimental patch for supporing unprivileged mounts and
> umounts.  The following features are added:

same feedback as last time ... the cap stuff needs to be made optional and=
=20
proper header checks added to configure ...

> 1) If mount/umount are suid, first try without privileges.
>
> This is done by forking, dropping privileges in child, and redirecting
> stderr to /dev/null.  If this succeeds, then parent exits with zero
> exit code.  Otherwise parent continues normally (with privileges).
> This isn't perfect, because the wrong error message will be printed if
> mount/umount failed not because of insufficient privileges, but some
> other error (e.g. mountpoint busy).

this normalization of error information does kind of suck ... but i think t=
he=20
way it's written, the end user will still get the real answer the second ti=
me=20
around when the mount is attempted with root privs and not stderr sent=20
to /dev/null ?
=2Dmike

--nextPart2023442.yLlF9ht91N
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.7 (GNU/Linux)

iQIVAwUAR44D2EFjO5/oN/WBAQLHGQ/+OJUNzIPbqlnFlJRi8//Cz5Mpzbsq+YiD
EOqxq46Bo4+Q2TEoSxHeBCV06/h701EpBi4vrD/SHdZTT+Druj8h5+FERGXWNd1z
4gkYHn11XsrjIeFHMTtSAyOFRQra5ccLZ71uUZ4C/d8u9av+2N6a/ULK0TF3MqBX
7O3YtABsBQ7BpG3bOxRfuHQvMZKhQxkfpUcIBdOl32q4nMjRUTDyv92P52t3lLT+
+oKywGvyaeAGia0TB4APpVDY+1V36Wxuj9catL/YVNtuzaKS+fJ1fWjbsgedwKqz
zsDsNDrmPeFjqS/6GYDQXpX3++8IWFjTzKTNcY3+Kumi5+MzpO5Hh1uk7U3BE/2c
rp84kRozAqP+17iQD6y1cI+fybwW8AFxmXbceite07tk8VMOHs84TepwdQcZPpee
YKkj+HwswKuC55sJ/9OublzIUFaIYa2BlvQKUoO6cMBk/5BSb28Hw6e/421E2vwV
kNegHZW0pvXCPTOasJU+cAXiZ/X4pRhf/F45NFyeUxCJ9AU0kuBL6RCBUo2s4qYE
/IhN/4rEeMnJNT1sZoYVedE2W5CSoWc+RAjue+Zwr1Uujad0+NaOv9zwqXHxectw
4jfZw2CcD48im7P7kYzB6JgciQm/E3DZ+sDIOTbkJE/0dvi9Gv5lxUQE/yrR1Onq
mBVWAUUbFkI=
=bJgu
-----END PGP SIGNATURE-----

--nextPart2023442.yLlF9ht91N--
