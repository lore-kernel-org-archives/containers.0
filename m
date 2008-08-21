From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC v2][PATCH 4/9] Memory management - dump state
Date: Thu, 21 Aug 2008 11:53:16 +0200
Message-ID: <20080821095316.GH581__36408.3360218958$1219312693$gmane$org@hawkmoon.kerlabs.com>
References: <Pine.LNX.4.64.0808202251500.17436@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0808202304490.17436@takamine.ncl.cs.columbia.edu>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0735109440016942683=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0808202304490.17436-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============0735109440016942683==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-9815-1219312267-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-9815-1219312267-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 20, 2008 at 11:05:15PM -0400, Oren Laadan wrote:
>
> For each VMA, there is a 'struct cr_vma'; if the VMA is file-mapped,
> it will be followed by the file name.  The cr_vma->npages will tell
> how many pages were dumped for this VMA.  Then it will be followed
> by the actual data: first a dump of the addresses of all dumped
> pages (npages entries) followed by a dump of the contents of all
> dumped pages (npages pages). Then will come the next VMA and so on.

[...]

> diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
> new file mode 100644
> index 0000000..a23aa29
> --- /dev/null
> +++ b/checkpoint/ckpt_mem.c

[...]

> +/**
> + * cr_vma_fill_pgarr - fill a page-array with addr/page tuples for a vma
> + * @ctx - checkpoint context
> + * @pgarr - page-array to fill
> + * @vma - vma to scan
> + * @start - start address (updated)
> + */
> +static int cr_vma_fill_pgarr(struct cr_ctx *ctx, struct cr_pgarr *pgarr,
> +			     struct vm_area_struct *vma, unsigned long *start)
> +{
> +	unsigned long end =3D vma->vm_end;
> +	unsigned long addr =3D *start;
> +	struct page **pagep;
> +	unsigned long *addrp;
> +	int cow, nr, ret =3D 0;
> +
> +	nr =3D pgarr->nleft;
> +	pagep =3D &pgarr->pages[pgarr->nused];
> +	addrp =3D &pgarr->addrs[pgarr->nused];
> +	cow =3D !!vma->vm_file;
> +
> +	while (addr < end) {
> +		struct page *page;
> +
> +		/* simplified version of get_user_pages(): already have vma,
> +		* only need FOLL_TOUCH, and (for now) ignore fault stats */
> +
> +		cond_resched();
> +		while (!(page =3D follow_page(vma, addr, FOLL_TOUCH))) {
> +			ret =3D handle_mm_fault(vma->vm_mm, vma, addr, 0);
> +			if (ret & VM_FAULT_ERROR) {
> +				if (ret & VM_FAULT_OOM)
> +					ret =3D -ENOMEM;
> +				else if (ret & VM_FAULT_SIGBUS)
> +					ret =3D -EFAULT;
> +				else
> +					BUG();
> +				break;
> +			}

+			ret =3D 0;

> +			cond_resched();
> +		}
> +
> +		if (IS_ERR(page)) {
> +			ret =3D PTR_ERR(page);
> +			break;
> +		}

Need to check ret here:

+ 		if (ret)
			break;

> +
> +		if (page =3D=3D ZERO_PAGE(0))
> +			page =3D NULL;	/* zero page: ignore */
> +		else if (cow && page_mapping(page) !=3D NULL)
> +			page =3D NULL;	/* clean cow: ignore */
> +		else {
> +			get_page(page);
> +			*(addrp++) =3D addr;
> +			*(pagep++) =3D page;
> +			if (--nr =3D=3D 0) {
> +				addr +=3D PAGE_SIZE;
> +				break;
> +			}
> +		}
> +
> +		addr +=3D PAGE_SIZE;
> +	}
> +
> +	if (unlikely(ret < 0)) {
> +		nr =3D pgarr->nleft - nr;
> +		while (nr--)
> +			page_cache_release(*(--pagep));
> +		return ret;
> +	}
> +
> +	*start =3D addr;
> +	return (pgarr->nleft - nr);
> +}

[...]

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-9815-1219312267-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIrTsMVKcRuvQ9Q1QRAncTAJ40lNBiecQ2O15qHJkC8bC1lGxRvgCglHpn
LBg00Tw63Pe7lY14HcOzELw=
=rfRg
-----END PGP SIGNATURE-----

--=_bohort-9815-1219312267-0001-2--

--===============0735109440016942683==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============0735109440016942683==--
