From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm PATCH] Memory controller improve user interface
Date: Wed, 29 Aug 2007 09:17:40 -0700
Message-ID: <6599ad830708290917w599210fbx31b361a3529bdf3@mail.gmail.com>
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
	 <6599ad830708290828t5164260eid548757d404e31a5@mail.gmail.com>
	 <46D599CA.1020504@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964830AbXH2QSJ@vger.kernel.org>
In-Reply-To: <46D599CA.1020504@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Linux Containers <containers@lists.osdl.org>, Linux MM Mailing List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>
List-Id: containers.vger.kernel.org

On 8/29/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >
> > This seems a bit inconsistent - if you write a value to a limit file,
> > then the value that you read back is reduced by a factor of 1024?
> > Having the "(kB)" suffix isn't really a big help to automated
> > middleware.
> >
>
> Why is that? Is it because you could write 4M and see it show up
> as 4096 kilobytes? We'll that can be fixed with another variant
> of the memparse() utility.

I was thinking the other way around - you can write 1048576 (i.e. 1MB)
to the file and read back 1024. It just seems to me that it's clearer
if you write X to the file to get X back.

>
> 64 bit might be an overkill for 32 bit machines. 32 bit machines with
> PAE cannot use 32 bit values, they need 64 bits.

How is using a 64-bit value for consistency overkill?

As someone pointed out, 4TB machines probably aren't that far around
the corner (if they're not here already) so even if you use KB rather
than bytes, userspace needs to be using an int64 for this value in
case it ends up running as a 32-bit-compiled app on a 64-bit kernel
with lots of memory.

Paul
