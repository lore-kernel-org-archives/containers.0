From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH] ptrace: it is fun to strace /sbin/init
Date: Tue, 25 Mar 2008 13:06:11 -0500
Message-ID: <20080325180611.GB19176@sergelap.ibm.com>
References: <20080323135110.GA294@tv-sign.ru> <20080324160102.GB4069@atrey.karlin.mff.cuni.cz> <20080324164059.GA4767@tv-sign.ru> <20080324223925.GD2426@elf.ucw.cz> <20080324230458.GA173@tv-sign.ru> <1206446637.3302.134.camel@moss-spartans.epoch.ncsc.mil> <20080325134001.GB5984@sergelap.austin.rr.com> <1206455835.3302.185.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757694AbYCYSGY@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1206455835.3302.185.camel@moss-spartans.epoch.ncsc.mil>
Sender: linux-kernel-owner@vger.kernel.org
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, Oleg Nesterov <oleg@tv-sign.ru>, Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@openvz.org>, Roland McGrath <roland@redhat.com>, linux-kernel@vger.kernel.org, Chris Wright <chrisw@sous-sol.org>, Andrew Morgan <morgan@kernel.org>, Linux Containers <containers@lists.osdl.org>, Herbert Poetzl <herbert@13thfloor.at>
List-Id: containers.vger.kernel.org

Quoting Stephen Smalley (sds@tycho.nsa.gov):
> 
> On Tue, 2008-03-25 at 08:40 -0500, Serge E. Hallyn wrote:
> > Quoting Stephen Smalley (sds@tycho.nsa.gov):
> > > 
> > > On Tue, 2008-03-25 at 02:04 +0300, Oleg Nesterov wrote:
> > > > On 03/24, Pavel Machek wrote:
> > > > >
> > > > > > /sbin/init is important, but there are other important (and sometimes
> > > > > > much more important) services. Why it is so special so that we can't
> > > > > > debug/strace it?
> > > > > 
> > > > > Maybe. Let's kill /sbin/init protection in 2.6.26. But making it
> > > > > optional is wrong.
> > > > 
> > > > You are right, the boot parameter is silly. How about sysctl?
> > > > 
> > > > Stephen, do you see any security problems if we make /sbin/init
> > > > ptraceable by default?
> > > 
> > > Not an issue for SELinux (we apply an orthogonal check based on security
> > > context, so we can already block ptrace of init independent of whether
> > > root/CAP_SYS_PTRACE can do it).  I'm not sure though as to whether
> > > people using capabilities have ever relied on this special protection of
> > > init (e.g. custom init spawns children with lesser capabilities and
> > > relies on the fact that they cannot ptrace init to effectively re-gain
> > > those capabilities, even if they possess CAP_SYS_PTRACE).
> > 
> > Still thinking it through, but it seems like special casing init isn't
> > useful.  There are likely to be other tasks with all capabilities
> > set which the malicious task could just as well ptrace to do his
> > mischief, right?
> 
> Depends on the bounding set.  Didn't it used to be the case that only
> init had CAP_SETPCAP (until the meaning of it was changed by the
> filesystem capability support)?

Not quite.  CAP_SETPCAP was taken out of everyone's bounding set.  But
kernel/sysctl.c allowed only init to add capabilities to the bounding
set.  (Whereas CAP_SYS_MODULE was sufficient to remove them).

> Might want to double check with e.g. the vservers folks that they
> weren't relying in any way on special handling of init.

Herbert, Pavel, do you have objections to allowing ptrace of init?
(I believe Eric has already Acked the idea iirc?)

thanks,
-serge
