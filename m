From: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH review  4/4] vfs: Do not allow escaping from bind mounts.
Date: Thu, 9 Apr 2015 15:06:01 +0200
Message-ID: <20150409130601.GA22250__25640.9602742226$1428585300$gmane$org@pc.thejh.net>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<87iod68aa3.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7381828941473244243=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87iod68aa3.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


--===============7381828941473244243==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HcAYCG3uE/tztfnV"
Content-Disposition: inline


--HcAYCG3uE/tztfnV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 08, 2015 at 06:34:12PM -0500, Eric W. Biederman wrote:
> +static unsigned d_depth(const struct dentry *dentry)
> +{
> +	unsigned depth = 0;
> +
> +	while (!IS_ROOT(dentry)) {
> +		dentry = dentry->d_parent;
> +		depth++;
> +	}
> +	return depth;
> +}

This relies on a depth of 2^32 being impossible, right? Which is guaranteed
somewhat because you would need something like a terabyte of RAM to have
that many dentries in RAM? I can't find any explicit check. Maybe it would
make sense to let the depth be 64 bits or add some kind of overflow check?
Or did I just miss some kind of check on allocation?

<https://access.redhat.com/articles/rhel-limits> claims that redhat has
tested RHEL on a machine with 6TB of physical RAM. I think that 2^32
dentries would fit in there.


> +static const struct dentry *d_common_ancestor(const struct dentry *left,
> +					      const struct dentry *right)
> +{
> +	unsigned ldepth = d_depth(left);
> +	unsigned rdepth = d_depth(right);
> +
> +	if (ldepth > rdepth) {
> +		swap(left, right);
> +		swap(ldepth, rdepth);
> +	}
> +
> +	while (rdepth > ldepth) {
> +		right = right->d_parent;
> +		rdepth--;
> +	}

At this point, the actual depths could differ by 2^32,
right?


> +	while (right != left) {
> +		if (IS_ROOT(right))
> +			return NULL;
> +		right = right->d_parent;
> +		left = left->d_parent;

And then one of these could crash with a NULL pointer deref?

--HcAYCG3uE/tztfnV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVJnk5AAoJED4KNFJOeCOoIA8P/RDR6N3bMgIzI2ww7qq4ZrvF
8P9UQOMBIrJA3TCb+k4T3m0z6gdAsWdyqy7zny7OYYfPbsxR8JOIpt5P6gVpwVGm
2V+fOxhXAWmSHc51lPUDe10DQRjdjAa+TN41nJqvDDn9sc37lxl9EUrrnTtc5TpI
tHrAUqWLPbxkdPdXOCk0rKf6ihl3aYSWBTYidO2jfDgSJi4mFzuxL1BqWa+f2h0D
Lnvrkpjzkoc0b+WXWz63WQ3sd5Y0cwvkVul2yCmU1zVuGqEe4WRzhU8f36F29pSg
xDze1GQr0mWYy2j6vdz/F0PRPbjg/mSiYLiNRZF+ray10ASr0yMZBmkHbZMW+y9X
Yyvv6D8TiAEXC3npSqmp6oWt3O9xoEcty97YQ3KDKJ1zO5WEtu9lS14qJpzRk39F
IyIFpLRP6yH5AwxVlERMM3yTH7M9uuHcyz1SL1GAL1zh5f8WPHr+Yw+AN0CYlvVY
qQeZIGiJqkDrws73PcE7nG2Vs3O9S/eolv1UaxocVces2kEnm65nkctEWNUiMEIB
1vwns0ulhCYwCpyKSg1cLE7g2YrB+w4Xr+Cf3QRfUhCsK2h6NAfDCTBV8JwxE4Fe
2XeisezlapY3VnDFjy1peMLNXKSOShOXqvLl7RwivHKew2F2lo/MhsIPABz44BU5
trU5AD6+qwXqfbcW51MU
=LzqO
-----END PGP SIGNATURE-----

--HcAYCG3uE/tztfnV--

--===============7381828941473244243==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============7381828941473244243==--
