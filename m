From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH][cryo] Save/restore state of unnamed pipes
Date: Mon, 23 Jun 2008 16:30:28 -0700
Message-ID: <1214263828.7576.10.camel@nimitz>
References: <20080617212950.GB11826@us.ibm.com>
	<485EC6E4.4080707@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <485EC6E4.4080707-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, 2008-06-22 at 17:40 -0400, Oren Laadan wrote:
> One issue with this approach is that the operation (checkpoint) becomes
> non-transparent to the "checkpointee"s: re-writing the data back into
> the pipe/fifo may generate a SIGIO at the read-side of the pipe/fifo, or
> an inotify event on the inode, without a real reason. This may confuse
> the application if its logic relies on "normal" behavior.

Yeah, I guess this is true, somewhat.

But, for something expecting to read from a pipe, they'll get a SIGIO
when the data is first written.  If the signal has not yet been
delivered then we're fine because we won't generate *another* one.

If they've already received the signal and left the data in the pipe,
what harm does another SIGIO do?  The kernel is free to give the app a
SIGIO for every single byte stuck in the pipe, right?  So, what
difference does any number of SIGIOs make when there's data sitting in
the pipe unread?

As for inotify, yeah that might be an actual issue.  It's probably good
to note this potential issue, and to watch for anyone doing inotifies on
a pipe fd when we get to checkpointing inotify.

Overall, seems like an awfully minor issue to me.

-- Dave
