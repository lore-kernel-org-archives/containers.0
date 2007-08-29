From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Switch nfs/callback.c to using struct pid, not pid_t
Date: Wed, 29 Aug 2007 10:10:41 -0400
Message-ID: <1188396641.6580.62.camel@heimdal.trondhjem.org>
References: <46D57658.2040704@openvz.org>
	 <20070829135205.GA13879@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754217AbXH2OLV@vger.kernel.org>
In-Reply-To: <20070829135205.GA13879@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@osdl.org>, Oleg Nesterov <oleg@tv-sign.ru>, Sukadev Bhattiprolu <sukadev@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On Wed, 2007-08-29 at 14:52 +0100, Christoph Hellwig wrote:
> On Wed, Aug 29, 2007 at 05:36:24PM +0400, Pavel Emelyanov wrote:
> > Pid namespaces make it dangerous to use pid and tgid values
> > when run in some namespace. The struct pid itself is going
> > to be the only way for working with task pids, so make the
> > nfs callback thread use it.
> > 
> > Since nfs_callback_info.pid is set to current's one and reset
> > on the thread exit, it is safe not to get the struct pid. 
> > 
> > Since this pid is used later under lock_kernel() w/o sleeping 
> > operations, checking for i to be not NULL and killing the 
> > thread with kill_pid() is safe.
> 
> NACK.  This just makes the code even more obscure.  Please get rid
> of the pid references entirely and convert the code to the kthread
> API.

That would require converting the full sunrpc server code to use
kthreads, which again means changing nfsd, and lockd too.

I'm not saying that is a bad thing, but it is nontrivial to do. In
particular, kthread's abominable shutdown mechanism simply does not work
or scale when the thread is listening for new requests in svc_recv().

Cheers
  Trond
