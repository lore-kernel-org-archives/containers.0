Return-Path: <SRS0=8SPi=CG=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A964C433E2
	for <containers@archiver.kernel.org>; Fri, 28 Aug 2020 15:59:02 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6404A2075B
	for <containers@archiver.kernel.org>; Fri, 28 Aug 2020 15:59:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6404A2075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 4BB8E20433;
	Fri, 28 Aug 2020 15:59:02 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id gjk0i0m39GBw; Fri, 28 Aug 2020 15:59:01 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 5D87D2037A;
	Fri, 28 Aug 2020 15:59:01 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 3F1A6C016F;
	Fri, 28 Aug 2020 15:59:01 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 9DE98C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 15:58:59 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 8C61D87C52
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 15:58:59 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id v+JpBBaUXoh6
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 15:58:58 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mx2.suse.de (mx2.suse.de [195.135.220.15])
 by whitealder.osuosl.org (Postfix) with ESMTPS id A01C887C0A
 for <containers@lists.linux-foundation.org>;
 Fri, 28 Aug 2020 15:58:58 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.221.27])
 by mx2.suse.de (Postfix) with ESMTP id 1A69FAE33;
 Fri, 28 Aug 2020 15:59:30 +0000 (UTC)
Date: Sat, 29 Aug 2020 01:58:49 +1000
From: Aleksa Sarai <asarai@suse.de>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: Overlayfs @Plumbers
Message-ID: <20200828155849.k46uk3x63aio3g3o@yavin.dot.cyphar.com>
References: <CAOQ4uxjXZdXZAaeiJ_p9n7NJziBv2yvWqSDs0hDd1ONUrVKxOQ@mail.gmail.com>
 <87tuwmiy4j.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
In-Reply-To: <87tuwmiy4j.fsf@x220.int.ebiederm.org>
Cc: Linux Containers <containers@lists.linux-foundation.org>,
 overlayfs <linux-unionfs@vger.kernel.org>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============0140765944450176032=="
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>


--===============0140765944450176032==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="64q7cgtfjbzz72kq"
Content-Disposition: inline


--64q7cgtfjbzz72kq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2020-08-28, Eric W. Biederman <ebiederm@xmission.com> wrote:
> Amir Goldstein <amir73il@gmail.com> writes:
>=20
> > Hi Guys,
> >
> > It's been nice to virtually meet with you yesterday.
> > Some of you wanted to follow up on overlayfs related issues.
> >
> > If you want to discuss, try to find me in one of the
> > https://meet.2020.linuxplumbersconf.org/hackrooms
> > today between 16:00-17:00 UTC
> > (No need to enter the room to see who's inside)
> >
> > If those times do not work for you, contact me and we can try
> > to schedule another time.
>=20
> Did this conversation wind up happening?  Do we need to reschedule?

This conversation already happened in a Hackroom on Tuesday. I'm not
sure if the Hackrooms will have their recordings published, so maybe
Amir can post any of the takeaways we had?

--=20
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
<https://www.cyphar.com/>

--64q7cgtfjbzz72kq
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEXzbGxhtUYBJKdfWmnhiqJn3bjbQFAl9JKbYACgkQnhiqJn3b
jbRxtA/8CDIRnaVZFFR7O5KU/N/W7OVpiiBU7eysBq03gxJRNy6MvXXp9zxyaZWH
2yeq0qnpFnbmCYBUUxCQowGlcgLwtkVvN28Q7UtC7kH8qYIPoWFUl1MS9gFn3OQi
+O+dPN/TOLVV2mtwb4FsJlFyQTP6TSqRKzp/nZsA8uqmD7dcW3zoESf0SKwXBOuO
lLi4xCtDBiIOIaggMg8lQQVF9GGxyQykPQi3m4V8wdBL1xxeIKaJd0IcIQ9U2Sgz
8I8WB/uHFWfgUEFYYIJSrVpubRvY7vNr7LmVts+ETsZbwmhp9nDFbliSajDXHhpO
wsTk2AefZzPFmkCCgP7/MfnmbR/fqqDW8da3duC05OYpLlDpmu7AGjXmOFwJMiuE
qgTa3uiIhaPAg8Uz1ORYk/Dk1Zwp9QuFMLvSVUh7xAQGoMbryc9bcHt5d6Ym5OJY
wBTLwqRcnH9cjMn7MYvYiht24KvwEBQVkpvp2Fee7HnCrv+reb+C4MAeXNsgJIyW
XriXS4z6CYCjPWhCNyDn2Ie7DOq9OgbaH9cx2IbyykCiEF6f8oUFXgFtqcRl2i75
I0iE4qhgX93xFxj8v3aHc6ZHu3Wxh7CHwQkd17GFx+4Nxv81qu5bAN9jiSqk1GlG
Vt7taY0TAkTYNWdm6gEljl/AeDqdxZddHqw5A/5Bon5YI0alBLY=
=5YKN
-----END PGP SIGNATURE-----

--64q7cgtfjbzz72kq--

--===============0140765944450176032==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============0140765944450176032==--
