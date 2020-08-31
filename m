Return-Path: <SRS0=Gfcc=CJ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFBC8C433E6
	for <containers@archiver.kernel.org>; Mon, 31 Aug 2020 08:09:57 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A2837206F0
	for <containers@archiver.kernel.org>; Mon, 31 Aug 2020 08:09:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2837206F0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 4C1D82076B;
	Mon, 31 Aug 2020 08:09:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id cKygZVRbhKfL; Mon, 31 Aug 2020 08:09:55 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id A38AF20131;
	Mon, 31 Aug 2020 08:09:55 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 94B8BC07FF;
	Mon, 31 Aug 2020 08:09:55 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 03881C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 31 Aug 2020 08:09:54 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id ED70485A84
 for <containers@lists.linux-foundation.org>;
 Mon, 31 Aug 2020 08:09:53 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id yNnbpOfB5KTB
 for <containers@lists.linux-foundation.org>;
 Mon, 31 Aug 2020 08:09:52 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mx2.suse.de (mx2.suse.de [195.135.220.15])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id F3923845DF
 for <containers@lists.linux-foundation.org>;
 Mon, 31 Aug 2020 08:09:51 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.221.27])
 by mx2.suse.de (Postfix) with ESMTP id 7F7A6AC85;
 Mon, 31 Aug 2020 08:10:24 +0000 (UTC)
Date: Mon, 31 Aug 2020 18:09:41 +1000
From: Aleksa Sarai <asarai@suse.de>
To: Sargun Dhillon <sargun@sargun.me>
Subject: Re: Per user rlimits
Message-ID: <20200831080941.ikc7ltacf6n3q6fm@yavin.dot.cyphar.com>
References: <87imd2incs.fsf@x220.int.ebiederm.org>
 <CAMp4zn9M783PTkq0q5BV5n2x=4P4ed4F6F9b7p7ex97=_3J0GA@mail.gmail.com>
MIME-Version: 1.0
In-Reply-To: <CAMp4zn9M783PTkq0q5BV5n2x=4P4ed4F6F9b7p7ex97=_3J0GA@mail.gmail.com>
Cc: Linux Containers <containers@lists.linux-foundation.org>,
 "Eric W. Biederman" <ebiederm@xmission.com>
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
Content-Type: multipart/mixed; boundary="===============2051703799919019020=="
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>


--===============2051703799919019020==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="sjacx7l5l4ushxkz"
Content-Disposition: inline


--sjacx7l5l4ushxkz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2020-08-28, Sargun Dhillon <sargun@sargun.me> wrote:
> On Fri, Aug 28, 2020 at 12:29 PM Eric W. Biederman
> <ebiederm@xmission.com> wrote:
> > Just to scope how much work it would be to fix rlimits
> > so they are not a problem for user namespaces I took a quick
> > survey.
> >
> > The rlimits can be found in
> > include/uapi/asm-generic/resource.h
> >
> > There are a total of 16 rlimits.
> > There are only 4 rlimits that are enforced at anything other
> > than process granularity.
> >
> > RLIMIT_NPROC
> > RLIMIT_MEMLOCK
> > RLIMIT_SIGPENDING
> > RLIMIT_MSGQUEUE
> >
> > So it should not be difficult to fix those rlimits.
>=20
> What are your proposed semantics for what the "fix" would look like? Or
> are you saying that once we take on Christian's proposal of 64-bit kuid
> they would be trivial to fix? I think the reason we didn't move forward w=
ith
> fixing it is the only real thing we could agree upon is an rlimit namespa=
ce,

=46rom memory, we did briefly discuss how this would work in the call. I
believe the basic idea was that the host rlimit would act as a maximum
setting but there would be an optional lower limit that a user namespace
could set and would be accounted separately. That way containers
wouldn't interfere with each others' rlimit settings. I imagine this
would be nested with user namespaces and presumable means that rlimit
would now be attached to userns directly.

(But I might be misremembering the details of the proposal. I do
remember Eric mentioning that the "maximum namespaces" sysctl semantics
were a useful model to look at.)

> and then you get into a question of why do these even exist, and should
> they just be cgroup(v2) controllers, and should calling setrlimit just
> be a wrapper around a cgroup(v2) controller that has a map of
> uid -> limit?

To mirror what I said when this came up in the actual discussion, the
reason why we don't have cgroups for all of these things is that some of
those limits aren't "real resources" and arguably should all be managed
through kmemcg policies.

Right after getting the pids cgroup controller merged, I did mention
adding controllers for the other rlimits and Tejun said that they didn't
make sense to add ([1] is one of the responses I found through a quick
search). The only reason the pids controller was merged is that you
could still fork-bomb a system even with modest kmemcg limits.

[1]: https://lore.kernel.org/lkml/20150227114940.GB3964@htj.duckdns.org/

--=20
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
<https://www.cyphar.com/>

--sjacx7l5l4ushxkz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEXzbGxhtUYBJKdfWmnhiqJn3bjbQFAl9MsEIACgkQnhiqJn3b
jbRR9w/+JYIm8dN1AR9sjglcB3Jg+BR/Uvmz3T44/hig6EUWSryPZoDKmgjf2trc
zJJWjGcOKo4pxezZzKD+ej/aHQK9Wc25uYA4BW0KefQZDrmOJk6yEcKkpZgFs6XJ
XlOa5pGTRaEvOiUG2ThSN7fEjQWmCC8EesJhxtZgH4Cqxs8tMwIsWR/eiNT0LaC3
VmH2pb2BicAwTwLN6sddIhEPfeMbsF8OjzZV164ekTY8R/t81FKZcA1IfMgeCJqR
B1ZNvgGnQzM9fLhjpn3CkVqzTupgAhk6zdCijPWYJJ+BHCgo42zeELFoysKg6Lp7
M80H3y4U1dt8WWhjb8dXp7ceMuniu4QLvn4l5z/kDUVaZqPvAdxIENR/CeBkdci4
PMOCIrvLeHrxS2NrFNTB8nQlZMNygAzb/2UfTx17qp3rc37Uw1h6iZkh2pxy4sCS
HnGdRa4KHUX2Q9Ys9f0IGzCTTFzYmMXOWal37hkCGEfTz/Wr+qNOjCXdhj0Hbs8v
QOjkL30B1JW7SKP3h2uhxrL2HBdyYTblrDXtAgPxFTPwwujT53OAvO0lYHtYkpvT
7kIT2aPHO5oqj6e6Vg/yVcLb5O46rOPrduefUFUlMdLhdfmZcMGtWdIKxrJUlNy+
HQ8vtjgLCRA1htC+0GfRAOLyGDXfBglKWM0tepBxOoL/El/mtGM=
=K1pg
-----END PGP SIGNATURE-----

--sjacx7l5l4ushxkz--

--===============2051703799919019020==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============2051703799919019020==--
