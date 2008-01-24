From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/2] Extend sys_clone and sys_unshare system calls API
Date: Thu, 24 Jan 2008 18:37:08 +0100
Message-ID: <20080124173708.GA4473@elf.ucw.cz>
References: <478DFF8F.9030006@openvz.org> <20080123205930.GA5233@ucw.cz> <4798C664.1040409@fr.ibm.com> <1201195474.8329.38.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755656AbYAXRhM@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1201195474.8329.38.camel@nimitz.home.sr71.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Cedric Le Goater <clg@fr.ibm.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

On Thu 2008-01-24 09:24:34, Dave Hansen wrote:
> On Thu, 2008-01-24 at 18:09 +0100, Cedric Le Goater wrote:
> > yes but we would need more something like  : 
> > 
> >  long sys_clone64(unsigned long flags_high, unsigned long flag_low)
> > 
> > if we want the syscall to be supported on 32bit arch. clone2 is also 
> > being used on ia64 already.
> 
> Did we decide not to do something with a variable number of arguments?
> 
> 	sys_clonefoo(unsigned long *flags, int len);

That is evil, because that means strace can no longer reliably print
flags being used (for example).
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
