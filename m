From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 1/2] eCryptfs: Introduce device handle for userspace
	daemon communications
Date: Tue, 15 Apr 2008 16:34:02 -0500
Message-ID: <20080415213402.GA6446@sergelap.austin.ibm.com>
References: <20080415202313.GM4627@localhost.austin.ibm.com> <20080415140453.a45a15b4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080415140453.a45a15b4.akpm@linux-foundation.org>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Halcrow <mhalcrow@us.ibm.com>, linux-fsdevel@vger.kernel.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, ecryptfs-devel@lists.sourceforge.net
List-Id: containers.vger.kernel.org

Quoting Andrew Morton (akpm@linux-foundation.org):
> On Tue, 15 Apr 2008 15:23:13 -0500
> Michael Halcrow <mhalcrow@us.ibm.com> wrote:
> 
> > Functions to facilitate reading and writing to the eCryptfs
> > miscellaneous device handle. This will replace the netlink interface
> > as the preferred mechanism for communicating with the userspace
> > eCryptfs daemon.
> > 
> > Each user has his own daemon, which registers itself by opening the
> > eCryptfs device handle. Only one daemon per euid may be registered at
> > any given time. The eCryptfs module sends a message to a daemon by
> > adding its message to the daemon's outgoing message queue. The daemon
> > reads the device handle to get the oldest message off the queue.
> > 
> > Incoming messages from the userspace daemon are immediately
> > handled. If the message is a response, then the corresponding process
> > that is blocked waiting for the response is awakened.
> > 
> 
> This is a drastic change, but the changelog doesn't tell us why it is being
> made!
> 
> > ...
> > +	rc = ecryptfs_find_daemon_by_euid(&daemon, current->euid);
> > +	if (daemon->pid != current->pid) {
> > +	rc = ecryptfs_find_daemon_by_euid(&daemon, current->euid);
> > +	BUG_ON(current->euid != daemon->euid);
> > +	BUG_ON(current->pid != daemon->pid);
> 
> This code uses pids and uids all over the place.  Will it operate correctly
> in a containerised environment?

Thanks Andrew.

Mike, the pid_t definately needs to be replaced with a struct pid.

As for the euid, it'd be best if you also compared the user_namespace *
to make sure we support one ecryptfs deamon per user namespace.

thanks,
-serge
