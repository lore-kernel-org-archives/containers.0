From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [-mm PATCH] Memory controller improve user interface
Date: Wed, 29 Aug 2007 15:25:52 -0700
Message-ID: <1188426352.28903.143.camel@localhost>
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
	 <1188413148.28903.113.camel@localhost>
	 <46D5ED5C.9030405@linux.vnet.ibm.com>
	 <1188425894.28903.140.camel@localhost>
	 <6599ad830708291520t2bc9ea20m2bdcd9e042b3a423@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761044AbXH2W0P@vger.kernel.org>
In-Reply-To: <6599ad830708291520t2bc9ea20m2bdcd9e042b3a423@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Wed, 2007-08-29 at 15:20 -0700, Paul Menage wrote:
> 
> I'd argue that having the user's specified limit be truncated to the
> page size is less confusing than giving an EINVAL if it's not page
> aligned.

Do we truncate mmap() values to the nearest page so to not confuse the
user? ;)

Imagine a careful application setting and accounting for limits on a
long-running system.  Might its internal accounting get sufficiently
misaligned from the kernel's after a while to cause a problem?
Truncating values like that would appear reserve significantly less
memory than desired over a long period of time.

-- Dave
