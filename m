From: Andrew Morgan <morgan@kernel.org>
Subject: Re: [PATCH 2/2] capabilities: introduce per-process capability	bounding
 set (v7)
Date: Fri, 16 Nov 2007 20:22:42 -0800
Message-ID: <473E6C92.3040302@kernel.org>
References: <20071115231615.GA3851@sergelap.austin.ibm.com> <20071115231752.GA4518@sergelap.austin.ibm.com> <473DD0CB.7090403@kernel.org> <20071117034226.GA25867@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20071117034226.GA25867@sergelap.austin.ibm.com>
Sender: linux-security-module-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Linux Containers <containers@lists.osdl.org>, linux-security-module@vger.kernel.org
List-Id: containers.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Serge E. Hallyn wrote:
>> I also think we should use CAP_SETPCAP for the privilege of manipulating
>> the bounding set. In many ways irrevocably removing a permission
>> requires the same level of due care as adding one (to pI).
> 
> Aside from being heavy-handed, it also means that we are restricting the 
> use of per-process capability bounding sets to kernels with file
> capabilities compiled in, right?  Are we ok with that?
> 

I am. :-)

Cheers

Andrew
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQFHPmyQQheEq9QabfIRAnnbAJ0c22LPNc1EnjWyvR4ZrwcyAiJDrgCeOdTj
TJFJwUK7UMkeX5M9ULzbN44=
=LMQP
-----END PGP SIGNATURE-----
