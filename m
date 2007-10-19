From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: 2.6.23-mm1 s390 driver problem
Date: Fri, 19 Oct 2007 11:20:53 +0200
Message-ID: <1192785653.25150.9.camel@localhost>
References: <20071018200148.GA14234@vino.hallyn.com>
	 <200710182215.56428.borntraeger@de.ibm.com>
	 <20071018203151.GA15382@vino.hallyn.com>
	 <1192780036.25150.7.camel@localhost>  <471875E0.8040308@fr.ibm.com>
Reply-To: schwidefsky@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764599AbXJSJVO@vger.kernel.org>
In-Reply-To: <471875E0.8040308@fr.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Cedric Le Goater <clg@fr.ibm.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, cornelia.huck@de.ibm.com, heiko.carstens@de.ibm.com, sam@ravnborg.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org


On Fri, 2007-10-19 at 11:16 +0200, Cedric Le Goater wrote:
> > This is the vmlinux.lds.S problem. The cleanup patch from Sam Ravnborg
> > moved the __initramfs_start and __initramfs_end symbols into
> > the .init.ramfs section. This is in itself not a problem, but it
> > surfaced a bug: there is no *(.init.initramfs), that needs to be
> > *(init.ramfs). I corrected this in the upstream patch but 2.6.23-mm1 has
> > the older one that still causes the "Cannot open root device". For
> > 2.6.23-mm1 use the patch below.
> > 
> 
> thanks martin, 
> 
> that helped going a little further in the boot process but we then have 
> a network issue when bringing the network interface up :

See http://marc.info/?l=linux-kernel&m=119270398931208&w=2
 
-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.
