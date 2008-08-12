From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: checkpoint/restart ABI
Date: Tue, 12 Aug 2008 08:11:10 -0700
Message-ID: <1218553870.5598.83.camel__7097.49111342735$1218554091$gmane$org@nimitz>
References: <20080807224033.FFB3A2C1@kernel>
	<200808090013.41999.arnd@arndb.de> <20080811152201.GB25930@us.ibm.com>
	<200808111853.13854.arnd@arndb.de> <1218484114.5598.43.camel@nimitz>
	<48A0CD86.6030704@goop.org> <87d4kfds5i.wl%peterc@chubb.wattle.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87d4kfds5i.wl%peterc-LkDQP0DxSMGxwJ88Py/mJxCuuivNXqWP@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Chubb <peterc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org>
Cc: Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2008-08-12 at 09:54 +1000, Peter Chubb wrote:
> Jeremy>    * multiple processes * pipes * UNIX domain sockets * INET
> Jeremy> sockets (both inter and intra machine) * unlinked open files *
> Jeremy> checkpointing file content * closed files (ie, files which
> Jeremy> aren't currently open, but will be soon, esp tmp files) *
> Jeremy> shared memory * (Peter, what have I forgotten?)
> 
> File sharing; multiple threads with wierd sharing arrangements (think:
> clone with various parameters, followed by exec in some of the threads
> but not others); MERT/system-V shared memory, semaphores and message
> queues; devices (audio, framebuffer, etc), HugeTLBFS, numa issues
> (pinning, memory layout), processes being debugged (so,
> checkpoint.restart a gdb/target pair), futexes, etc., etc.  Linux
> process state keeps expanding.

Yep, these are all challenges.  If you have some really specific
questions, or things you truly think can't be done, please speak up.
But, I really don't see any show stoppers in your list.

We also plan to do this incrementally.  The first consumers are likely
to be dumb, simple HPC apps that don't have real hardware like audio or
video.  Eventually, we'll get to real hardware like infiniband (ugh) or
audio.  Eventually.

(Actually futexes aren't that bad because they don't keep state
in-kernel)

-- Dave
