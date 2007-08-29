From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Switch nfs/callback.c to using struct pid, not pid_t
Date: Wed, 29 Aug 2007 14:52:05 +0100
Message-ID: <20070829135205.GA13879@infradead.org>
References: <46D57658.2040704@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761410AbXH2NxQ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46D57658.2040704@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@osdl.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Oleg Nesterov <oleg@tv-sign.ru>, Sukadev Bhattiprolu <sukadev@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 29, 2007 at 05:36:24PM +0400, Pavel Emelyanov wrote:
> Pid namespaces make it dangerous to use pid and tgid values
> when run in some namespace. The struct pid itself is going
> to be the only way for working with task pids, so make the
> nfs callback thread use it.
> 
> Since nfs_callback_info.pid is set to current's one and reset
> on the thread exit, it is safe not to get the struct pid. 
> 
> Since this pid is used later under lock_kernel() w/o sleeping 
> operations, checking for i to be not NULL and killing the 
> thread with kill_pid() is safe.

NACK.  This just makes the code even more obscure.  Please get rid
of the pid references entirely and convert the code to the kthread
API.
