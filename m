Return-Path: <SRS0=DMKn=EC=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F05CBC55178
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 23:40:02 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5BFF82223C
	for <containers@archiver.kernel.org>; Tue, 27 Oct 2020 23:40:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BFF82223C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cyphar.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id B65E68671E;
	Tue, 27 Oct 2020 23:40:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id idpAmdjF8J5O; Tue, 27 Oct 2020 23:40:01 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 0156C86265;
	Tue, 27 Oct 2020 23:40:00 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id DF954C088B;
	Tue, 27 Oct 2020 23:40:00 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 4C923C0051
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:40:00 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 30D72873E2
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:40:00 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 9AhqzP2TUX8h
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:39:58 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mout-p-202.mailbox.org (mout-p-202.mailbox.org [80.241.56.172])
 by hemlock.osuosl.org (Postfix) with ESMTPS id ADFFD872E5
 for <containers@lists.linux-foundation.org>;
 Tue, 27 Oct 2020 23:39:58 +0000 (UTC)
Received: from smtp1.mailbox.org (smtp1.mailbox.org [80.241.60.240])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange ECDHE (P-384) server-signature RSA-PSS (4096 bits) server-digest
 SHA256) (No client certificate requested)
 by mout-p-202.mailbox.org (Postfix) with ESMTPS id 4CLSqJ0KrwzQlKH;
 Wed, 28 Oct 2020 00:39:56 +0100 (CET)
X-Virus-Scanned: amavisd-new at heinlein-support.de
Received: from smtp1.mailbox.org ([80.241.60.240])
 by spamfilter03.heinlein-hosting.de (spamfilter03.heinlein-hosting.de
 [80.241.56.117]) (amavisd-new, port 10030)
 with ESMTP id rUkT73ePuCba; Wed, 28 Oct 2020 00:39:52 +0100 (CET)
Date: Wed, 28 Oct 2020 10:39:41 +1100
From: Aleksa Sarai <cyphar@cyphar.com>
To: Shuah Khan <skhan@linuxfoundation.org>
Subject: Re: [PATCH] openat2: reject RESOLVE_BENEATH|RESOLVE_IN_ROOT
Message-ID: <20201027233941.ux23xlzlzgv4ym5u@yavin.dot.cyphar.com>
References: <20201007103608.17349-1-cyphar@cyphar.com>
 <4ce6ba2c-8b23-78aa-47c0-8c9673273e8f@linuxfoundation.org>
MIME-Version: 1.0
In-Reply-To: <4ce6ba2c-8b23-78aa-47c0-8c9673273e8f@linuxfoundation.org>
X-MBO-SPAM-Probability: 
X-Rspamd-Score: -7.31 / 15.00 / 15.00
X-Rspamd-Queue-Id: 8E7F014AF
X-Rspamd-UID: 27b986
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
 stable@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 linux-kselftest@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 Shuah Khan <shuah@kernel.org>
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
Content-Type: multipart/mixed; boundary="===============6000466674388910354=="
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>


--===============6000466674388910354==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ny23ujh7bz6tha2k"
Content-Disposition: inline


--ny23ujh7bz6tha2k
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2020-10-27, Shuah Khan <skhan@linuxfoundation.org> wrote:
> On 10/7/20 4:36 AM, Aleksa Sarai wrote:
> > This was an oversight in the original implementation, as it makes no
> > sense to specify both scoping flags to the same openat2(2) invocation
> > (before this patch, the result of such an invocation was equivalent to
> > RESOLVE_IN_ROOT being ignored).
> >=20
> > This is a userspace-visible ABI change, but the only user of openat2(2)
> > at the moment is LXC which doesn't specify both flags and so no
> > userspace programs will break as a result.
> >=20
> > Cc: <stable@vger.kernel.org> # v5.6+
> > Fixes: fddb5d430ad9 ("open: introduce openat2(2) syscall")
> > Acked-by: Christian Brauner <christian.brauner@ubuntu.com>
> > Signed-off-by: Aleksa Sarai <cyphar@cyphar.com>
> > ---
> >   fs/open.c                                      | 4 +++
> >   tools/testing/selftests/openat2/openat2_test.c | 8 +++++++-
>=20
> You are combining fs change with selftest change.
>=20
> Is there a reason why these two changes are combined?
> 2 separate patches is better.

Not really, I'll split it into two patches.

--=20
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
<https://www.cyphar.com/>

--ny23ujh7bz6tha2k
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYIAB0WIQSxZm6dtfE8gxLLfYqdlLljIbnQEgUCX5ivugAKCRCdlLljIbnQ
ElB1AQC+LI0Cu57CZjVg3AJHg+G4wN4YH4pI1gRLhtWeQsBCGQD/Zf+bS2I6bDdK
qS/PwIlKl6NwXBKxsb3MH09z1tIswwM=
=1JlE
-----END PGP SIGNATURE-----

--ny23ujh7bz6tha2k--

--===============6000466674388910354==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============6000466674388910354==--
