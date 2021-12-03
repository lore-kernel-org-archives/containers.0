Received: from eu-smtp-delivery-151.mimecast.com (eu-smtp-delivery-151.mimecast.com [185.58.85.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E00242C9E
	for <containers@lists.linux.dev>; Fri,  3 Dec 2021 14:20:00 +0000 (UTC)
Received: from AcuMS.aculab.com (156.67.243.121 [156.67.243.121]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 uk-mta-276-WJXXi7eCOiyQNI0Os2d2EA-1; Fri, 03 Dec 2021 14:19:57 +0000
X-MC-Unique: WJXXi7eCOiyQNI0Os2d2EA-1
Received: from AcuMS.Aculab.com (fd9f:af1c:a25b:0:994c:f5c2:35d6:9b65) by
 AcuMS.aculab.com (fd9f:af1c:a25b:0:994c:f5c2:35d6:9b65) with Microsoft SMTP
 Server (TLS) id 15.0.1497.26; Fri, 3 Dec 2021 14:19:56 +0000
Received: from AcuMS.Aculab.com ([fe80::994c:f5c2:35d6:9b65]) by
 AcuMS.aculab.com ([fe80::994c:f5c2:35d6:9b65%12]) with mapi id
 15.00.1497.026; Fri, 3 Dec 2021 14:19:56 +0000
From: David Laight <David.Laight@ACULAB.COM>
To: 'Alexey Gladkov' <legion@altlinux.ru>, Dan Carpenter
	<dan.carpenter@oracle.com>
CC: "kbuild@lists.01.org" <kbuild@lists.01.org>, Alexey Gladkov
	<legion@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux Containers
	<containers@lists.linux.dev>, "lkp@intel.com" <lkp@intel.com>,
	"kbuild-all@lists.01.org" <kbuild-all@lists.01.org>, "Eric W . Biederman"
	<ebiederm@xmission.com>
Subject: RE: [PATCH v1 2/2] ucounts: Move rlimit max values from ucounts max
Thread-Topic: [PATCH v1 2/2] ucounts: Move rlimit max values from ucounts max
Thread-Index: AQHX6E1dTG1FDFW9tE25mvS0vl4F7qwg0Mxg
Date: Fri, 3 Dec 2021 14:19:56 +0000
Message-ID: <62f96ccd41f14b3ab504184951513a90@AcuMS.aculab.com>
References: <bcc85eae4f5e3799f9efdf2d73572bb88616ebac.1637934917.git.legion@kernel.org>
 <202111280022.ugxpiKpA-lkp@intel.com>
 <20211203135453.ld2jblkd3xtlbgrv@example.org>
In-Reply-To: <20211203135453.ld2jblkd3xtlbgrv@example.org>
Accept-Language: en-GB, en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-exchange-transport-fromentityheader: Hosted
x-originating-ip: [10.202.205.107]
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Authentication-Results: relay.mimecast.com;
	auth=pass smtp.auth=C51A453 smtp.mailfrom=david.laight@aculab.com
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: aculab.com
Content-Language: en-US
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

From: Alexey Gladkov
> Sent: 03 December 2021 13:55
...
> > 25f9c0817c535a Eric W. Biederman 2016-08-08  108  =09=09for (i =3D 0; i=
 < UCOUNT_COUNTS; i++) {
> > 25f9c0817c535a Eric W. Biederman 2016-08-08 @109  =09=09=09tbl[i].data =
=3D &ns->ucount_max[i];
> >
> > The patch changes the size of ->ucount_max[] to MAX_PER_NAMESPACE_UCOUN=
TS
> > but this loop still goes up to UCOUNT_COUNTS.
> >
> >
>=20
> Thanks! But a few days ago I already post a new version of this changeset
> with fix:
>=20
> https://lore.kernel.org/containers/24c87e225c7950bf2ea1ff4b4a8f2373488082=
41.1638218242.git.legion@kernel.org/

Use ARRAY_SIZE() so that it 'just doesn't go wrong'.

=09David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1=
PT, UK
Registration No: 1397386 (Wales)

