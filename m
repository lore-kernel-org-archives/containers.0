From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [PATCH 1/2] Extend sys_clone and sys_unshare system calls API
Date: Thu, 24 Jan 2008 09:46:57 -0800
Message-ID: <1201196817.8329.44.camel@nimitz.home.sr71.net>
References: <478DFF8F.9030006@openvz.org> <20080123205930.GA5233@ucw.cz>
	 <4798C664.1040409@fr.ibm.com>
	 <1201195474.8329.38.camel@nimitz.home.sr71.net>
	 <20080124173708.GA4473@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755534AbYAXRrU@vger.kernel.org>
In-Reply-To: <20080124173708.GA4473@elf.ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Cedric Le Goater <clg@fr.ibm.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

On Thu, 2008-01-24 at 18:37 +0100, Pavel Machek wrote:
> > Did we decide not to do something with a variable number of
> arguments?
> > 
> >       sys_clonefoo(unsigned long *flags, int len);
> 
> That is evil, because that means strace can no longer reliably print
> flags being used (for example).

Ahhh.  Just like it can't print strings for "buf"?

	write(int fd, char *buf, size_t len)

Man, strace is stupid! ;)

If that's *really* a concern, why don't we just pass, say 4 or 5 longs
in:

	sys_clonebig(unsigned long flags0, unsigned long flags1,
		     unsigned long flags2, unsigned long flags3);

-- Dave
