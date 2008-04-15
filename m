From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] eCryptfs: Introduce device handle
 for userspace daemon communications
Date: Tue, 15 Apr 2008 14:04:53 -0700
Message-ID: <20080415140453.a45a15b4.akpm@linux-foundation.org>
References: <20080415202313.GM4627@localhost.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ecryptfs-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080415202313.GM4627@localhost.austin.ibm.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ecryptfs-devel>,
	<mailto:ecryptfs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ecryptfs-devel>
List-Post: <mailto:ecryptfs-devel@lists.sourceforge.net>
List-Help: <mailto:ecryptfs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ecryptfs-devel>,
	<mailto:ecryptfs-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ecryptfs-devel-bounces@lists.sourceforge.net
Errors-To: ecryptfs-devel-bounces@lists.sourceforge.net
To: Michael Halcrow <mhalcrow@us.ibm.com>
Cc: linux-fsdevel@vger.kernel.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, ecryptfs-devel@lists.sourceforge.net
List-Id: containers.vger.kernel.org

On Tue, 15 Apr 2008 15:23:13 -0500
Michael Halcrow <mhalcrow@us.ibm.com> wrote:

> Functions to facilitate reading and writing to the eCryptfs
> miscellaneous device handle. This will replace the netlink interface
> as the preferred mechanism for communicating with the userspace
> eCryptfs daemon.
> 
> Each user has his own daemon, which registers itself by opening the
> eCryptfs device handle. Only one daemon per euid may be registered at
> any given time. The eCryptfs module sends a message to a daemon by
> adding its message to the daemon's outgoing message queue. The daemon
> reads the device handle to get the oldest message off the queue.
> 
> Incoming messages from the userspace daemon are immediately
> handled. If the message is a response, then the corresponding process
> that is blocked waiting for the response is awakened.
> 

This is a drastic change, but the changelog doesn't tell us why it is being
made!

> ...
> +	rc = ecryptfs_find_daemon_by_euid(&daemon, current->euid);
> +	if (daemon->pid != current->pid) {
> +	rc = ecryptfs_find_daemon_by_euid(&daemon, current->euid);
> +	BUG_ON(current->euid != daemon->euid);
> +	BUG_ON(current->pid != daemon->pid);

This code uses pids and uids all over the place.  Will it operate correctly
in a containerised environment?


-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
eCryptfs-devel mailing list
eCryptfs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/ecryptfs-devel
