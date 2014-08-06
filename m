From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Wed, 6 Aug 2014 16:06:08 +1000
Message-ID: <20140806160608.218b6944@canb.auug.org.au>
References: <87fvhav3ic.fsf@x220.int.ebiederm.org>
	<20140806144643.45e5dab8@canb.auug.org.au>
	<87lhr2tcyx.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6027861668369101811=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87lhr2tcyx.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

--===============6027861668369101811==
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/UDert/OUbJNSkXl1TZUQu.4"; protocol="application/pgp-signature"

--Sig_/UDert/OUbJNSkXl1TZUQu.4
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Eric,

On Tue, 05 Aug 2014 22:16:06 -0700 ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman=
) wrote:
>
> I am not certain what your point is.

I am just trying to give Linus a heads up for branches that have not
had much exposure before he is asked to pull them.

> There have been no commits added since the merge window opened.
>=20
> There was one commit changed to fix a typo.  I documented that already.

Yes, that is what confused my, sorry, since that commit and the ones
following are new commits but unchanged patches.

> There were some commits pushed to the tree as late as friday that had
> been out for review earlier than that and it is possible that you did
> not pick them up in linux-next until monday.  That doesn't mean I added
> anything after the merge window opened.

Correct.

> I have also made certain all of these commits have at least had a chance
> to show up in linux-next.
>=20
> As for missing cool tags shrug.  The people looking at my code didn't
> feel like saying the magic words so I didn't include cool tags.

Maybe you should push them ... these tags are not just "cool", they
give less involved people some indications of what has happened in the
life of a patch.

> Beyond that I have been quite out of it recently and this is what I had
> time to do.  If I had had a little more time and energy I would have
> included unmount on unlink patches that still need magic to happen to
> keep from blowing the stack in pathological cases on everything except
> x86_64.  That code has been sitting in linux-next.
>=20
> Which is a my long winded way of say it sounds like you are accusing me
> of being irresponsible, and my way of saying that I have tested and

I did not mean to accuse, there are reasons (as you have pointed out)
that things get added late, or rewritten.

--=20
Cheers,
Stephen Rothwell                    sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org

--Sig_/UDert/OUbJNSkXl1TZUQu.4
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJT4cXeAAoJEMDTa8Ir7ZwVZSoP/0g+Wm1niCnsxXZ4PEBpN9LX
APPokAEis+gA2gL8PIhc+AbijkGi/VCr6wiY/tzM59luPRL627Va0gK6m2nRhYPO
7yYmk62mDPdN202CE7NZaNsupXTsdPDgs1sKGrzBSaeghD1v9V51jiEPGDyLt9oS
mB9Zx/CFnCaNrWJYIGsT38FpfB7dbookmPwo0kHpSqitv1YUdxqFHcLR1zkBlLsK
JpnRLGP21FYotdrqM16XpzHcyGXE1TicsAwQ3KFm4gucRVkas+39oBk1LA3ZZNtL
hT5yDhDQffvR/R2QwdfvAzjfMEGuNFZJRduUG0rJDzl3uSbxSCsfZtBQMPhMMfhs
9EiSbMdu5uT45uw4RbB55y36QcK8+5DErAKtCM1XW9D1zLCk+vmkMvzWjzmg49/y
ldemUoDAxf6NsC33d8EyH3sOYys6hD4/2y9goVheBEKPOzLjfS4+q2LodygvEEyG
l5UZdEVQURoseDRMRW+y6Un9MLhm7BJjF81NVqKgh0BhMFXPqD5sdAJT834YNohk
3Wbo5wAUpnB/0dRPmSLVB+gq6gd3FOJkGXs9niMV2gFmMjtKWQg7g4r14pPeNGTN
bJrwfjmt7+8I5ajQhzZqGRXG+k7VaRv71BuOFJOpspC3CVIoXtlMbmQ1dHyq7sNX
IEOBvhLcGeCtbubASXAD
=Mdkb
-----END PGP SIGNATURE-----

--Sig_/UDert/OUbJNSkXl1TZUQu.4--

--===============6027861668369101811==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============6027861668369101811==--
