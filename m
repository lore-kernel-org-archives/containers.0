From: Daniel Jacobowitz <dan-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for checkpoint restart
Date: Wed, 22 Oct 2008 10:29:07 -0400
Message-ID: <20081022142907.GA13574__13177.543556276$1224685970$gmane$org@caradoc.them.org>
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>
	<1224481237-4892-3-git-send-email-orenl@cs.columbia.edu>
	<20081021124130.a002e838.akpm@linux-foundation.org>
	<20081021202410.GA10423@us.ibm.com>
	<48FE82DF.6030005@cs.columbia.edu>
	<20081022025513.GA7504@caradoc.them.org>
	<1224644563.1848.232.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1224644563.1848.232.camel@nimitz>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Oct 21, 2008 at 08:02:43PM -0700, Dave Hansen wrote:
> Let's say you have a process you want to checkpoint.  If it uses a
> completely discrete IPC namespace, you *know* that nothing else depends
> on those IPC ids.  We don't even have to worry about who might have been
> using them and when.
> 
> Also think about pids.  Without containers, how can you guarantee a
> restarted process that it can regain the same pid?

OK, that makes sense.  In a lot of simple cases you can get by without
regaining the same pid; there's an implementation of checkpointing in
GDB that works by injecting fork calls into the child, and it is
useful for a reasonable selection of single-threaded programs.

-- 
Daniel Jacobowitz
CodeSourcery
