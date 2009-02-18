From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: What can OpenVZ do?
Date: Wed, 18 Feb 2009 13:27:27 -0800
Message-ID: <1234992447.26788.12.camel__18518.5528047898$1234992593$gmane$org@nimitz>
References: <20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz>
	<20090212141014.2cd3d54d.akpm@linux-foundation.org>
	<20090213105302.GC4608@elte.hu> <1234817490.30155.287.camel@nimitz>
	<20090217222319.GA10546@elte.hu> <1234909849.4816.9.camel@nimitz>
	<20090218003217.GB25856@elte.hu> <1234917639.4816.12.camel@nimitz>
	<20090218051123.GA9367@x200.localdomain>
	<20090218181644.GD19995@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090218181644.GD19995-X9Un+BFzKDI@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2009-02-18 at 19:16 +0100, Ingo Molnar wrote:
> Nothing motivates more than app designers complaining about the 
> one-way flag.
> 
> Furthermore, it's _far_ easier to make a one-way flag SMP-safe. 
> We just set it and that's it. When we unset it, what do we about 
> SMP races with other threads in the same MM installing another 
> non-linear vma, etc.

After looking at this for file descriptors, I have to really agree with
Ingo on this one, at least as far as the flag is concerned.  I want to
propose one teeny change, though:  I think the flag should be
per-resource.

We should have one flag in mm_struct, one in files_struct, etc...  The
task_is_checkpointable() function can just query task->mm, task->files,
etc...  This gives us nice behavior at clone() *and* fork that just
works.

I'll do this for files_struct and see how it comes out so you can take a
peek.

-- Dave
