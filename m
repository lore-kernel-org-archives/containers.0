From: sukadev@us.ibm.com
Subject: [PATCH 0/3] clone64() and unshare64() system calls
Date: Wed, 9 Apr 2008 15:26:11 -0700
Message-ID: <20080409222611.GA28087@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756103AbYDIW1l@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: clg@fr.ibm.com, serue@us.ibm.com, "David C. Hansen" <haveblue@us.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org


This is a resend of the patch set Cedric had sent earlier. I ported
the patch set to 2.6.25-rc8-mm1 and tested on x86 and x86_64.
---

We have run out of the 32 bits in clone_flags !

This patchset introduces 2 new system calls which support 64bit clone-flags.

     long sys_clone64(unsigned long flags_high, unsigned long flags_low,
		unsigned long newsp);

     long sys_unshare64(unsigned long flags_high, unsigned long flags_low);

The current version of clone64() does not support CLONE_PARENT_SETTID and 
CLONE_CHILD_CLEARTID because we would exceed the 6 registers limit of some 
arches. It's possible to get around this limitation but we might not
need it as we already have clone()

This is work in progress but already includes support for x86, x86_64, 
x86_64(32), ppc64, ppc64(32), s390x, s390x(31). 

ia64 already supports 64bits clone flags through the clone2() syscall.
should we harmonize the name to clone2 ?  
