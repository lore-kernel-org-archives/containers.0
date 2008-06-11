From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH RFC] cgroup_clone: use pid of newly created task for new cgroup
Date: Wed, 11 Jun 2008 07:30:27 -0700
Message-ID: <87ve0ggi2k.fsf@caffeine.beaverton.ibm.com>
References: <20080610212302.GA1946@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758139AbYFKOay@vger.kernel.org>
In-Reply-To: <20080610212302.GA1946@us.ibm.com> (Serge E. Hallyn's message of
	"Tue, 10 Jun 2008 16:23:02 -0500")
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Paul Menage <menage@google.com>, Linux Containers <containers@lists.osdl.org>, lkml <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

--=-=-=
Content-Transfer-Encoding: quoted-printable

SH> As a result, the new cgroup was created with current's pid.

This works for me and results in the creation of a cgroup named after
the new task's pid instead of the parent's pid.

Thanks!

=2D-=20
Dan Smith
IBM Linux Technology Center
Open Hypervisor Team
email: danms@us.ibm.com

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIT+GFwtEf7b4GJVQRAifMAJ9YTZozv5RLTXrn9g/T1Wb02pD8sgCfW7mP
spo2eU8qEU0/cJhpyxGJIjw=
=HIvH
-----END PGP SIGNATURE-----
--=-=-=--
