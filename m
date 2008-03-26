From: Andrew Morgan <morgan@kernel.org>
Subject: Re: [PATCH] ptrace: it is fun to strace /sbin/init
Date: Wed, 26 Mar 2008 08:31:11 -0700
Message-ID: <47EA6C3F.40408@kernel.org>
References: <20080323135110.GA294@tv-sign.ru> <20080324160102.GB4069@atrey.karlin.mff.cuni.cz> <20080324164059.GA4767@tv-sign.ru> <20080324223925.GD2426@elf.ucw.cz> <20080324230458.GA173@tv-sign.ru> <1206446637.3302.134.camel@moss-spartans.epoch.ncsc.mil> <20080325134001.GB5984@sergelap.austin.rr.com> <1206455835.3302.185.camel@moss-spartans.epoch.ncsc.mil> <20080325180611.GB19176@sergelap.ibm.com> <20080325215555.GB12770@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756923AbYCZPcS@vger.kernel.org>
In-Reply-To: <20080325215555.GB12770@elf.ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Stephen Smalley <sds@tycho.nsa.gov>, Oleg Nesterov <oleg@tv-sign.ru>, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@openvz.org>, Roland McGrath <roland@redhat.com>, linux-kernel@vger.kernel.org, Chris Wright <chrisw@sous-sol.org>, Linux Containers <containers@lists.osdl.org>, Herbert Poetzl <herbert@13thfloor.at>
List-Id: containers.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

FWIW. I completely concur.

Pavel Machek wrote:
|> Herbert, Pavel, do you have objections to allowing ptrace of init?
|> (I believe Eric has already Acked the idea iirc?)
|
| No problem from me...
|
| (..but do not introduce command line option or sysctl. It is not worth
it).

Cheers

Andrew
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFH6mw8+bHCR3gb8jsRAsKjAJ40JnoyrqGzgIZPgz5gv9uqeeiZ1wCdFKSv
snEU/yiVdWQ4cGSwbU3A8Hg=
=xArK
-----END PGP SIGNATURE-----
