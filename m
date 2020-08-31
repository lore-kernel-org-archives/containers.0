Return-Path: <SRS0=Gfcc=CJ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0C67C433E2
	for <containers@archiver.kernel.org>; Mon, 31 Aug 2020 08:12:29 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8283F206F0
	for <containers@archiver.kernel.org>; Mon, 31 Aug 2020 08:12:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8283F206F0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=cyphar.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 33CBF85B25;
	Mon, 31 Aug 2020 08:12:29 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id cgidZVYIxaCR; Mon, 31 Aug 2020 08:12:27 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 2627685A84;
	Mon, 31 Aug 2020 08:12:27 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 17345C07FF;
	Mon, 31 Aug 2020 08:12:27 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7BE5BC0051
 for <containers@lists.linux-foundation.org>;
 Mon, 31 Aug 2020 08:12:24 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 4136420519
 for <containers@lists.linux-foundation.org>;
 Mon, 31 Aug 2020 08:12:24 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id ZBfobxHGsv3O
 for <containers@lists.linux-foundation.org>;
 Mon, 31 Aug 2020 08:12:22 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mout-p-103.mailbox.org (mout-p-103.mailbox.org [80.241.56.161])
 by silver.osuosl.org (Postfix) with ESMTPS id 06B2320131
 for <containers@lists.linux-foundation.org>;
 Mon, 31 Aug 2020 08:12:21 +0000 (UTC)
Received: from smtp1.mailbox.org (smtp1.mailbox.org
 [IPv6:2001:67c:2050:105:465:1:1:0])
 (using TLSv1.2 with cipher ECDHE-RSA-CHACHA20-POLY1305 (256/256 bits))
 (No client certificate requested)
 by mout-p-103.mailbox.org (Postfix) with ESMTPS id 4Bg2xH5hK0zKmWR;
 Mon, 31 Aug 2020 10:12:19 +0200 (CEST)
X-Virus-Scanned: amavisd-new at heinlein-support.de
Received: from smtp1.mailbox.org ([80.241.60.240])
 by spamfilter05.heinlein-hosting.de (spamfilter05.heinlein-hosting.de
 [80.241.56.123]) (amavisd-new, port 10030)
 with ESMTP id NPM41nPI0kIw; Mon, 31 Aug 2020 10:12:15 +0200 (CEST)
Date: Mon, 31 Aug 2020 18:12:07 +1000
From: Aleksa Sarai <cyphar@cyphar.com>
To: Aleksa Sarai <asarai@suse.de>
Subject: Re: Per user rlimits
Message-ID: <20200831081207.b6kajp5jhcyelwnt@yavin.dot.cyphar.com>
References: <87imd2incs.fsf@x220.int.ebiederm.org>
 <CAMp4zn9M783PTkq0q5BV5n2x=4P4ed4F6F9b7p7ex97=_3J0GA@mail.gmail.com>
 <20200831080941.ikc7ltacf6n3q6fm@yavin.dot.cyphar.com>
MIME-Version: 1.0
In-Reply-To: <20200831080941.ikc7ltacf6n3q6fm@yavin.dot.cyphar.com>
X-MBO-SPAM-Probability: 
X-Rspamd-Score: -7.05 / 15.00 / 15.00
X-Rspamd-Queue-Id: 2C44899A
X-Rspamd-UID: b85e40
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
Content-Type: multipart/mixed; boundary="===============0524140013388709581=="
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>


--===============0524140013388709581==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="4dvj3jnfa6ghabrs"
Content-Disposition: inline


--4dvj3jnfa6ghabrs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2020-08-31, Aleksa Sarai <asarai@suse.de> wrote:
> On 2020-08-28, Sargun Dhillon <sargun@sargun.me> wrote:
> > On Fri, Aug 28, 2020 at 12:29 PM Eric W. Biederman
> > <ebiederm@xmission.com> wrote:
> > > Just to scope how much work it would be to fix rlimits
> > > so they are not a problem for user namespaces I took a quick
> > > survey.
> > >
> > > The rlimits can be found in
> > > include/uapi/asm-generic/resource.h
> > >
> > > There are a total of 16 rlimits.
> > > There are only 4 rlimits that are enforced at anything other
> > > than process granularity.
> > >
> > > RLIMIT_NPROC
> > > RLIMIT_MEMLOCK
> > > RLIMIT_SIGPENDING
> > > RLIMIT_MSGQUEUE
> > >
> > > So it should not be difficult to fix those rlimits.
> >=20
> > What are your proposed semantics for what the "fix" would look like? Or
> > are you saying that once we take on Christian's proposal of 64-bit kuid
> > they would be trivial to fix? I think the reason we didn't move forward=
 with
> > fixing it is the only real thing we could agree upon is an rlimit names=
pace,
>=20
> From memory, we did briefly discuss how this would work in the call. I
> believe the basic idea was that the host rlimit would act as a maximum
> setting but there would be an optional lower limit that a user namespace
> could set and would be accounted separately. That way containers
> wouldn't interfere with each others' rlimit settings. I imagine this
> would be nested with user namespaces and presumable means that rlimit
> would now be attached to userns directly.
>=20
> (But I might be misremembering the details of the proposal. I do
> remember Eric mentioning that the "maximum namespaces" sysctl semantics
> were a useful model to look at.)
>=20
> > and then you get into a question of why do these even exist, and should
> > they just be cgroup(v2) controllers, and should calling setrlimit just
> > be a wrapper around a cgroup(v2) controller that has a map of
> > uid -> limit?
>=20
> To mirror what I said when this came up in the actual discussion, the
> reason why we don't have cgroups for all of these things is that some of
> those limits aren't "real resources" and arguably should all be managed
> through kmemcg policies.
>=20
> Right after getting the pids cgroup controller merged, I did mention
> adding controllers for the other rlimits and Tejun said that they didn't
> make sense to add ([1] is one of the responses I found through a quick
> search). The only reason the pids controller was merged is that you
> could still fork-bomb a system even with modest kmemcg limits.
>=20
> [1]: https://lore.kernel.org/lkml/20150227114940.GB3964@htj.duckdns.org/

[2] is a more explicit NACK from Tejun in that thread.

[2]: https://lore.kernel.org/lkml/20150227170640.GK3964@htj.duckdns.org/

--=20
Aleksa Sarai
Senior Software Engineer (Containers)
SUSE Linux GmbH
<https://www.cyphar.com/>

--4dvj3jnfa6ghabrs
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYIAB0WIQSxZm6dtfE8gxLLfYqdlLljIbnQEgUCX0yw1AAKCRCdlLljIbnQ
EudzAP9Q+62UILHjeBSumu/AXmMb9MPf2t40RSU+0YIzjGy33AD+IOF72Vvf7YQb
n3JfdO6R/SQpQk88JAek8JkA9/9zgQI=
=fvpY
-----END PGP SIGNATURE-----

--4dvj3jnfa6ghabrs--

--===============0524140013388709581==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============0524140013388709581==--
