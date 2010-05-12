From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 1/4][cr]: Add uid, euid params to f_modown()
Date: Wed, 12 May 2010 10:30:48 -0700
Message-ID: <20100512173048.GC11144__25554.1779719808$1273685217$gmane$org@us.ibm.com>
References: <1273617500-13653-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1273617500-13653-2-git-send-email-sukadev@linux.vnet.ibm.com>
	<20100512170513.GD19314@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100512170513.GD19314-yetKDKU6eevNLxjTenLetw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Jamie Lokier [jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org] wrote:
| Sukadev Bhattiprolu wrote:
| > Checkpoint/restart of file-owner.
| > 
| > Add uid, euid parameters to f_modown(). These parameters will be needed
| > when restarting an application (and hence restoring the file information),
| > from a checkpoint image.
| 
| This is used to make sure I/O signals on sockets, ttys, devices and so
| on are delivered to a particular process.

Good point.
| 
| If any of those signals are lost when an event happens around the same

Well, signals are not lost across C/R - if they were pending at
checkpoint, they will be pending on restart.

| time as c/r (for example, more data arriving on a pipe, a device
| becomes readable/writable, or room becoming available to write, or
| urgent data on a socket), a process depending on it can get stuck -
| unless the process knows that c/r happened, so it knows to call
| select() on all those fds after the c/r.

Real devices like ttys are still TBD from C/R perspective - so data
arriving from the tty is still a problem. Applications using such
devices cannot be checkpointed.

But for pipes, (and sockets ?) we expect that both ends are checkpointed
as a container. So before the container is frozen for checkpoint, either
both the write() and SIGIO (due to new data on the pipe) both happen or
neither.


Sukadev
