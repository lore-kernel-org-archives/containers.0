From: sukadev@us.ibm.com
Subject: Re: [PATCH 3/3] add the clone64() and unshare64() syscalls
Date: Wed, 9 Apr 2008 19:15:23 -0700
Message-ID: <20080410021523.GB28477@us.ibm.com>
References: <20080409222611.GA28087@us.ibm.com> <20080409223459.GC28267@us.ibm.com> <20080409230733.GR20478@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755711AbYDJCQ4@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080409230733.GR20478@devserv.devel.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Jakub Jelinek <jakub@redhat.com>
Cc: Andrew Morton <akpm@osdl.org>, clg@fr.ibm.com, serue@us.ibm.com, "David C. Hansen" <haveblue@us.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Jakub Jelinek [jakub@redhat.com] wrote:
| On Wed, Apr 09, 2008 at 03:34:59PM -0700, sukadev@us.ibm.com wrote:
| > From: Cedric Le Goater <clg@fr.ibm.com>
| > Subject: [PATCH 3/3] add the clone64() and unshare64() syscalls
| > 
| > This patch adds 2 new syscalls :
| > 
| >      long sys_clone64(unsigned long flags_high, unsigned long flags_low,
| > 		unsigned long newsp);
| > 
| >      long sys_unshare64(unsigned long flags_high, unsigned long flags_low);
| 
| Can you explain why are you adding it for 64-bit arches too?  unsigned long
| is there already 64-bit, and both sys_clone and sys_unshare have unsigned
| long flags, rather than unsigned int.

Hmm,

By simply resuing clone() on 64 bit and adding a new call for 32-bit won't
the semantics of clone() differ between the two ?

i.e clone() on 64 bit supports say CLONE_NEWPTS clone() on 32bit does not ?

Wouldn't it be simpler/cleaner if clone() and clone64() behaved the same
on both 32 and 64 bit systems ?

Sukadev
