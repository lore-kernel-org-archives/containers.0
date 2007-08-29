From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [-mm PATCH]  Memory controller improve user interface
Date: Wed, 29 Aug 2007 15:36:40 -0700
Message-ID: <1188427000.28903.148.camel@localhost>
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
	 <1188413148.28903.113.camel@localhost>
	 <46D5ED5C.9030405@linux.vnet.ibm.com>
	 <1188425894.28903.140.camel@localhost>
	 <46D5F2BB.8010203@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761276AbXH2Wgy@vger.kernel.org>
In-Reply-To: <46D5F2BB.8010203@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>
List-Id: containers.vger.kernel.org

On Thu, 2007-08-30 at 03:57 +0530, Balbir Singh wrote:
> True, mmap() is a good example of such an interface for developers, I
> am not sure about system admins though.
> 
> To quote Andrew
> <quote>
> Reporting tools could run getpagesize() and do the arithmetic, but we
> generally try to avoid exposing PAGE_SIZE, HZ, etc to userspace in this
> manner.
> </quote>

Well, rounding to PAGE_SIZE exposes PAGE_SIZE as well, just in a
non-intuitive fashion. :)

If we're going to modify what the user specifies, we should probably at
least mandate that writes are only a "suggestion" and users must read
back the value to ensure what actually got committed.

If we're going to round in any direction, shouldn't we round up?  If a
user specifies 4097 bytes and uses two pages, we don't want to complain
when they hit that second page.  

-- Dave
