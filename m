From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH 3/20] Introduce MS_KERNMOUNT flag
Date: Sat, 11 Aug 2007 15:22:00 +0400
Message-ID: <20070811112200.GA121@tv-sign.ru>
References: <46BC506B.mailGIV1AXDXM@openvz.org> <20070811034721.GB22216@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760838AbXHKLTs@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070811034721.GB22216@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>, xemul@openvz.org, akpm@osdl.org, devel@openvz.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

On 08/11, Christoph Hellwig wrote:
>
> On Fri, Aug 10, 2007 at 03:47:55PM +0400, xemul@openvz.org wrote:
> > This flag tells the .get_sb callback that this is a kern_mount() call
> > so that it can trust *data pointer to be valid in-kernel one. If this
> > flag is passed from the user process, it is cleared since the *data
> > pointer is not a valid kernel object.
> > 
> > Running a few steps forward - this will be needed for proc to create the
> > superblock and store a valid pid namespace on it during the namespace
> > creation. The reason, why the namespace cannot live without proc mount
> > is described in the appropriate patch.
> 
> I don't like this at all.  We should never pass kernel and userspace
> addresses through the same pointer.  Maybe add an additional argument
> to the get_sb prototype instead.  But this whole idea of mounting /proc
> from kernelspace sounds like a really bad idea to me.  /proc should
> never be mounted from the kernel but always normally from userspace.

Can't comment because I don't understand vfs at all, and perhaps I just
misunderstood you.

But could you clarify? We already create internal proc mount from kernel
space, proc_root_init() does this. With this series we are doing the same
when a new namespace is created.

Thanks,

Oleg.
