From: Michael Halcrow <mhalcrow@us.ibm.com>
Subject: Re: [PATCH 1/2] eCryptfs: Introduce device handle
	for userspace daemon communications
Date: Tue, 15 Apr 2008 17:47:50 -0500
Message-ID: <20080415224750.GN4627@localhost.austin.ibm.com>
References: <20080415202313.GM4627@localhost.austin.ibm.com>
	<20080415140453.a45a15b4.akpm@linux-foundation.org>
Reply-To: Michael Halcrow <mhalcrow@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <ecryptfs-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080415140453.a45a15b4.akpm@linux-foundation.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ecryptfs-devel>,
	<mailto:ecryptfs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ecryptfs-devel>
List-Post: <mailto:ecryptfs-devel@lists.sourceforge.net>
List-Help: <mailto:ecryptfs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ecryptfs-devel>,
	<mailto:ecryptfs-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ecryptfs-devel-bounces@lists.sourceforge.net
Errors-To: ecryptfs-devel-bounces@lists.sourceforge.net
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, ecryptfs-devel@lists.sourceforge.net
List-Id: containers.vger.kernel.org

On Tue, Apr 15, 2008 at 02:04:53PM -0700, Andrew Morton wrote:
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
> 
> This is a drastic change, but the changelog doesn't tell us why it
> is being made!

This resurrects the question from 2006:

On Thu, Aug 24, 2006 at 08:54:19PM -0700, Andrew Morton wrote:
> - _why_ does it use netlink?

I responded:

> Netlink provides the transport mechanism that would minimize the
> complexity of the implementation, given that we can have multiple
> daemons (one per user).

A regular device file was my real preference from the get-go, but I
went with netlink at the time because I thought it would be less
complex for managing send queues (i.e., just do a unicast and move
on). It turns out that we do not really get that much complexity
reduction with netlink, and netlink is more heavyweight than a device
handle.

In addition, the netlink interface to eCryptfs has been broken since
2.6.24. I am assuming this is a bug in how eCryptfs uses netlink,
since the other in-kernel users of netlink do not seem to be having
any problems. I have had one report of a user successfully using
eCryptfs with netlink on 2.6.24, but for my own systems, when starting
the userspace daemon, the initial helo message sent to the eCryptfs
kernel module results in an oops right off the bat. I spent some time
looking at it, but I have not yet found the cause. The netlink
interface breaking gave me the motivation to just finish my patch to
migrate to a regular device handle. If I cannot find out soon why the
netlink interface in eCryptfs broke, I am likely to just send a patch
to disable it in 2.6.24 and 2.6.25. I would like the device handle to
be the preferred means of communicating with the userspace daemon from
2.6.26 on forward.

Mike

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
eCryptfs-devel mailing list
eCryptfs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/ecryptfs-devel
