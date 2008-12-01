From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [RFC v10][PATCH 08/13] Dump open file descriptors
Date: Mon, 1 Dec 2008 13:02:09 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0812011258390.3256__44666.0484806218$1228165464$gmane$org@nehalem.linux-foundation.org>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
	<1227747884-14150-9-git-send-email-orenl@cs.columbia.edu>
	<20081128101919.GO28946@ZenIV.linux.org.uk>
	<1228153645.2971.36.camel@nimitz>
	<493447DD.7010102@cs.columbia.edu>
	<1228164679.2971.91.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1228164679.2971.91.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org



On Mon, 1 Dec 2008, Dave Hansen wrote:
> 
> Why is this done in two steps?  It first grabs a list of fd numbers
> which needs to be validated, then goes back and turns those into 'struct
> file's which it saves off.  Is there a problem with doing that
> fd->'struct file' conversion under the files->file_lock?

Umm, why do we even worry about this?

Wouldn't it be much better to make sure that all other threads are 
stopped before we snapshot, and if we cannot account for some thread (ie 
there's some elevated count in the fs/files/mm structures that we cannot 
see from the threads we've stopped), just refuse to dump.

There is no sane dump from a multi-threaded app that shares resources 
without that kind of serialization _anyway_, so why even try?

In other words: any races in dumping are fundamental _bugs_ in the dumping 
at a much higher level. There's absolutely no point in trying to make 
something like "dump open fd's" be race-free, because if there are other 
people that are actively accessing the 'files' structure concurrently, you 
had a much more fundamental bug in the first place!

So do things more like the core-dumping does: make sure that all other 
threads are quiescent first!

			Linus
