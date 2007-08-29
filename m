From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [-mm PATCH]  Memory controller improve user interface
Date: Wed, 29 Aug 2007 15:18:14 -0700
Message-ID: <1188425894.28903.140.camel@localhost>
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
	 <1188413148.28903.113.camel@localhost>
	 <46D5ED5C.9030405@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760805AbXH2WS3@vger.kernel.org>
In-Reply-To: <46D5ED5C.9030405@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>
List-Id: containers.vger.kernel.org

On Thu, 2007-08-30 at 03:34 +0530, Balbir Singh wrote:
> I've thought about this before. The problem is that a user could
> set his limit to 10000 bytes, but would then see the usage and
> limit round to the closest page boundary. This can be confusing
> to a user. 

True, but we're lying if we allow a user to set their limit there,
because we can't actually enforce a limit at 8,192 bytes vs 10,000.
They're the same limit as far as the kernel is concerned.

Why not just -EINVAL if the value isn't page-aligned?  There are plenty
of interfaces in the kernel that require userspace to know the page
size, so this shouldn't be too difficult.

-- Dave
