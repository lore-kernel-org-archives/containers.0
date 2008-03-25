From: Herbert Poetzl <herbert-dBHVzrDq9nF4Lj/PQRBjDg@public.gmane.org>
Subject: Re: [PATCH] ptrace: it is fun to strace /sbin/init
Date: Tue, 25 Mar 2008 20:07:43 +0100
Message-ID: <20080325190743.GA2379@MAIL.13thfloor.at>
References: <20080323135110.GA294@tv-sign.ru>
	<20080324160102.GB4069@atrey.karlin.mff.cuni.cz>
	<20080324164059.GA4767@tv-sign.ru>
	<20080324223925.GD2426@elf.ucw.cz>
	<20080324230458.GA173@tv-sign.ru>
	<1206446637.3302.134.camel@moss-spartans.epoch.ncsc.mil>
	<20080325134001.GB5984@sergelap.austin.rr.com>
	<1206455835.3302.185.camel@moss-spartans.epoch.ncsc.mil>
	<20080325180611.GB19176@sergelap.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080325180611.GB19176-6s5zFf/epYL1ENwx4SLHqw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>, Andrew Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 25, 2008 at 01:06:11PM -0500, Serge E. Hallyn wrote:
> Quoting Stephen Smalley (sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org):
> > 
> > On Tue, 2008-03-25 at 08:40 -0500, Serge E. Hallyn wrote:
> > > Quoting Stephen Smalley (sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org):
> > > > 
> > > > On Tue, 2008-03-25 at 02:04 +0300, Oleg Nesterov wrote:
> > > > > On 03/24, Pavel Machek wrote:
> > > > > >
> > > > > > > /sbin/init is important, but there are other important (and sometimes
> > > > > > > much more important) services. Why it is so special so that we can't
> > > > > > > debug/strace it?
> > > > > > 
> > > > > > Maybe. Let's kill /sbin/init protection in 2.6.26. But making it
> > > > > > optional is wrong.
> > > > > 
> > > > > You are right, the boot parameter is silly. How about sysctl?
> > > > > 
> > > > > Stephen, do you see any security problems if we make /sbin/init
> > > > > ptraceable by default?
> > > > 
> > > > Not an issue for SELinux (we apply an orthogonal check based on security
> > > > context, so we can already block ptrace of init independent of whether
> > > > root/CAP_SYS_PTRACE can do it).  I'm not sure though as to whether
> > > > people using capabilities have ever relied on this special protection of
> > > > init (e.g. custom init spawns children with lesser capabilities and
> > > > relies on the fact that they cannot ptrace init to effectively re-gain
> > > > those capabilities, even if they possess CAP_SYS_PTRACE).
> > > 
> > > Still thinking it through, but it seems like special casing init isn't
> > > useful.  There are likely to be other tasks with all capabilities
> > > set which the malicious task could just as well ptrace to do his
> > > mischief, right?
> > 
> > Depends on the bounding set.  Didn't it used to be the case that only
> > init had CAP_SETPCAP (until the meaning of it was changed by the
> > filesystem capability support)?
> 
> Not quite.  CAP_SETPCAP was taken out of everyone's bounding set.  But
> kernel/sysctl.c allowed only init to add capabilities to the bounding
> set.  (Whereas CAP_SYS_MODULE was sufficient to remove them).
> 
> > Might want to double check with e.g. the vservers folks that they
> > weren't relying in any way on special handling of init.
> 
> Herbert, Pavel, do you have objections to allowing ptrace of init?
> (I believe Eric has already Acked the idea iirc?)

inside a guest, by default no (i.e. there simply is
no capability for that), on the host the behaviour is
unmodified .. note that there are guests without init
where the blend through init is protected in a special
way

HTH,
Herbert

> thanks,
> -serge
