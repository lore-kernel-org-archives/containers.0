From: "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH v2] ns: do not block exit_task_namespaces() for a long time
Date: Tue, 17 Jul 2012 00:05:15 +0300
Message-ID: <20120716210515.GA17813__44591.4012649611$1342472664$gmane$org@otc-wbsnb-06>
References: <20120713140806.b3d0fda8.akpm@linux-foundation.org>
	<1342451364-14787-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2558334713651061897=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1342451364-14787-1-git-send-email-kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Dmitry V. Levin" <ldv-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Id: containers.vger.kernel.org


--===============2558334713651061897==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7AUc2qLy4jB3hD7Z"
Content-Disposition: inline


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 16, 2012 at 06:09:24PM +0300, Kirill A. Shutemov wrote:
> I also move synchronize_rcu() inside free_nsproxy(). It fixes racy
> put_nsproxy() which calls free_nsproxy() without synchronize_rcu().
> I guess it was missed during switch to RCU (see cf7b708).

I was wrong here. No races. RCU protects task->ns_proxy, not ns_proxy
itself.
Sorry for misleading.

--=20
 Kirill A. Shutemov

--7AUc2qLy4jB3hD7Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQBIILAAoJEAd+omnVudOM0JAQAM5ZT5sbZGDBWZlH0re17ha6
YrmbapIDQQVnucZfgibtWnQFPxE03AxoMX2JKYha+8CFSOVD52LEFlHW790nPEhb
v1b0LbVINI/FH/Wl0F/ot4STQWZBueNGyHLRe1YHzktNf45ghRBxQfjzyMLa63rw
PTdjWM2r/IGhk4Bpb20bHJqJUzUv1pcdhWAbleXPbOCyy8g8orprfbXTGqLUBZun
XkwloEStjtpanv5Nkq7eR0pSKwmJsVXXKYGn9t850Wz3bMairwSI5GQdhjWM3Fhy
0aLRZUgwA03PN2oi7Ycclg4y2gJo08KWUUDDZFW54EltFAbyUrVB9kV0N0rT1ohf
4OMKbMEvRflAfmA8s6NYGjX49wFbX/fGOxi5lLvVsouwrVeV2iikfjs+Sq73CeYe
9vBDyI+UBCgsREtokpIqzCZNtMwlrHxw2jq4sWCQ8aUWt7DmKXymJMxXoS/8eOoa
I73+CwqLpY1Vc3iIqOnq5HQdrVqulFcqsE++hQ3f7vSoHi6g2DbiKOsXRvKlM/DI
nEW94j5cRNeKwUrqDkfWAt0BrSczaXGk6emy+4R73f/qwvgpbz6omazXIwdgTe24
ax0cAxd8qPcywRaQOKODP8bhlbIf9CspJcjHRvbVVhWQMr45vxyH+7rWF93kY2fU
+7kvzCIfzOIAoMWZN3re
=jMa7
-----END PGP SIGNATURE-----

--7AUc2qLy4jB3hD7Z--

--===============2558334713651061897==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============2558334713651061897==--
