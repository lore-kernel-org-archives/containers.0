From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] ptrace: it is fun to strace /sbin/init
Date: Tue, 25 Mar 2008 22:55:55 +0100
Message-ID: <20080325215555.GB12770@elf.ucw.cz>
References: <20080323135110.GA294@tv-sign.ru> <20080324160102.GB4069@atrey.karlin.mff.cuni.cz> <20080324164059.GA4767@tv-sign.ru> <20080324223925.GD2426@elf.ucw.cz> <20080324230458.GA173@tv-sign.ru> <1206446637.3302.134.camel@moss-spartans.epoch.ncsc.mil> <20080325134001.GB5984@sergelap.austin.rr.com> <1206455835.3302.185.camel@moss-spartans.epoch.ncsc.mil> <20080325180611.GB19176@sergelap.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760814AbYCYVzd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080325180611.GB19176@sergelap.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Stephen Smalley <sds@tycho.nsa.gov>, Oleg Nesterov <oleg@tv-sign.ru>, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@openvz.org>, Roland McGrath <roland@redhat.com>, linux-kernel@vger.kernel.org, Chris Wright <chrisw@sous-sol.org>, Andrew Morgan <morgan@kernel.org>, Linux Containers <containers@lists.osdl.org>, Herbert Poetzl <herbert@13thfloor.at>
List-Id: containers.vger.kernel.org

Hi!

> > Might want to double check with e.g. the vservers folks that they
> > weren't relying in any way on special handling of init.
> 
> Herbert, Pavel, do you have objections to allowing ptrace of init?
> (I believe Eric has already Acked the idea iirc?)

No problem from me...

(..but do not introduce command line option or sysctl. It is not worth it).

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
pomozte zachranit klanovicky les:  http://www.ujezdskystrom.info/
