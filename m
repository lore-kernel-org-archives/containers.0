From: Christian PERRIER <bubulle-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Subject: Re: [Pkg-shadow-devel] [PATCH 00/11] pkg-shadow support subordinate
	ids with user namespaces
Date: Fri, 8 Mar 2013 07:50:19 +0100
Message-ID: <20130308065019.GI5885@mykerinos.kheops.frmug.org>
References: <87d2wxshu0.fsf@xmission.com> <20130307102352.4a5943cd@oracle.com>
	<20130307215457.GB9348@austin.hallyn.com>
	<876212rf9b.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1480194148041002599=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <876212rf9b.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Nicolas =?utf-8?B?RnJhbsOnb2lz?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============1480194148041002599==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="k4f25fnPtRuIRUb3"
Content-Disposition: inline


--k4f25fnPtRuIRUb3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):

> Yes.  It looks like we are going to have to setup a public repository
> somewhere to collect all of the changes and bug fixes.  Not that I
> expect too many but clearly there are a few needed.

That exists.

Shadow upstream (and Debian package) is maintained in an SVN
repository hosted on alioth.debian.org.

I can make it as easy as possible to people to contribute by opening
commit access there.

We can also, if that helps in attracting contributors, convert the
repo to git (I will need help there because the repo has a quite long
history and we want to keep it). I know that, nowadays, svn often
looks a bit scary (and, TBH, feature-limited) to many FLOSS
contributors.

In short, nothing is hidden nor closed. Indeed, I think that shadow
might benefit from more input, given that my friend Nicolas has
limited time.

The only constraint is indeed giving French cheese names to
releases. This is something I won't compromise with...:-). We invented
this tradition when we took shadow over, back in 2005 (doh!) and that
has to remain the French Touch in the software..:-)

I can act as a facilitator for all this. I definitely *don't have the
skills to decide what contributions are "good" or not. Shadow being a
sensitive piece of software, we might need to be careful at the
beginning and include fixes and new features with care.

This is indeed where git and its great branching features might help a
lot.

May I welcome interested people to join the
Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org mailing list so that we
reduce the CC list of this thread?



--k4f25fnPtRuIRUb3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJROYoqAAoJEIcvcCxNbiWocysP/AoDDVkOhvQ4b48+sWfcVkkd
AJ1B2c/FFaN6RHWgJCoyZwx+Kqy1OMgEDo/jGuZe+5qYldPFoKNb1jY/hldNS6wI
sIyk1rq1QVfTNg5N7mtKJyP1xzTRWbxYHlQnEv+fiPlFgxLV2gL4Slw6vK8AjNla
F/C9GkPptOcq8OpL3bNpPSMdeNlavTv6k5/Hj4wCz1Qe08TAdnwymldkmAhLHyh9
8nY++pPSA4tKbD/lnQ8+Ed91n4Za7uePxZv3ufVNptFSkaELygZhVbrLJrtKnSpt
3MNhbnrqCFIcf4DcI29By07nM/IHmuGlWUmqZBAR1p6NQFjG+uu9EduVdtNazhcE
RU8gTXDWx4haaZb5lr2NNt5+Ku3WjoMySgTS3sdHM4TDsT9JDxH8CfA75R0NbL1G
LSz3qD0pa9QEqMdoqMmdAlm/S8nPjJGiTCD4uQzg8mFF66NvUL4FgU/NjvwnbFHH
o19vR9d3Q21c+ad7esdzVGQayWZGKiJFEW+UAxP3sQ404bSYnu8Km+W4vF0drzz9
fldFKbBVd41kp7gcXirgnhz9+zVmA04tBQ2pzhIqyQGpehBEnlAcEw3V+B1iXjTY
OBfaZCeaVjpADUAWuOLbGYXklENGQYfgx3F124N64n6P+St+dnsHBDSigxddkWk9
Or2Gj25ZOBVyRw/qW6BN
=IocZ
-----END PGP SIGNATURE-----

--k4f25fnPtRuIRUb3--

--===============1480194148041002599==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============1480194148041002599==--
