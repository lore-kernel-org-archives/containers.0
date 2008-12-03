From: Valdis.Kletnieks@vt.edu
Subject: Re: [RFC][PATCH 1/5] pid: Implement ns_of_pid
Date: Tue, 02 Dec 2008 19:34:15 -0500
Message-ID: <66986.1228264455@turing-police.cc.vt.edu>
References: <20081126034242.GA23120@us.ibm.com> <20081126034442.GA23238@us.ibm.com> <20081127011910.GD13545@wavehammer.waldi.eu.org> <20081201202422.GD12493@us.ibm.com>
            <20081202115841.GC1132@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1228264455_28627P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755476AbYLCAgT@vger.kernel.org>
In-Reply-To: Your message of "Tue, 02 Dec 2008 12:58:41 +0100."
             <20081202115841.GC1132@wavehammer.waldi.eu.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Bastian Blank <bastian@waldi.eu.org>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

--==_Exmh_1228264455_28627P
Content-Type: text/plain; charset=us-ascii

On Tue, 02 Dec 2008 12:58:41 +0100, Bastian Blank said:

> pid is a function argument and the function does not call detach_pid. So
> please try again.

What he means is that if some *other* function calls detach_pid() and then
something calls the ns_of_pid() function, it may be getting passed a null.

Note that the detach_pid() and ns_of_pid() may even be racing on two totally
separate CPUs, doing different things...


--==_Exmh_1228264455_28627P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFJNdQHcC3lWbTT17ARAiQyAJ40fNmO6ATbBChO+V45GDr6q6hH1QCg8lNL
J8GvlM5jjAtrgrseV5/+LLo=
=MTSp
-----END PGP SIGNATURE-----

--==_Exmh_1228264455_28627P--
