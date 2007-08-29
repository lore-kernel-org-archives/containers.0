From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH] Send quota messages via netlink
Date: Wed, 29 Aug 2007 17:19:42 -0400
Message-ID: <21957.1188422382@turing-police.cc.vt.edu>
References: <20070828141318.GC5869@duck.suse.cz> <20070828211335.37fce4c9.akpm@linux-foundation.org> <20070829122647.GB7814@duck.suse.cz> <m1mywa42g7.fsf@ebiederm.dsl.xmission.com> <20070829192653.GD7814@duck.suse.cz>
            <m1wsve2gpo.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1188422382_2981P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760196AbXH2VUn@vger.kernel.org>
In-Reply-To: Your message of "Wed, 29 Aug 2007 15:06:43 MDT."
             <m1wsve2gpo.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@in.ibm.com>, "Serge E. Hallyn" <serue@us.ibm.com>, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

--==_Exmh_1188422382_2981P
Content-Type: text/plain; charset=us-ascii

On Wed, 29 Aug 2007 15:06:43 MDT, Eric W. Biederman said:

> So we have to figure out how to do the hard thing which is look at
> who opened our netlink broadcast see if they are in the same user
> namespace as current->user.  Which is a pain and we don't currently
> have the infrastructure for.

Provision also needs to be made for things that are listening to the
netlink broadcasts that don't match the user doing the operation or
the owner of the file - similar to the way auditd wants events.


--==_Exmh_1188422382_2981P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFG1eLtcC3lWbTT17ARAqa9AJ9Sugsdn3Liim3qnKp9qiaXZrhLlwCgyMwq
P2A9qGQqdSjrvHU1FzAQd9E=
=quRd
-----END PGP SIGNATURE-----

--==_Exmh_1188422382_2981P--
