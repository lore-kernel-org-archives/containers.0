From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: What can OpenVZ do?
Date: Thu, 12 Feb 2009 13:51:23 -0800
Message-ID: <1234475483.30155.194.camel__45305.8530147702$1234475630$gmane$org@nimitz>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1234285547.30155.6.camel@nimitz>
	<20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090212114207.e1c2de82.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2009-02-12 at 11:42 -0800, Andrew Morton wrote:
> On Thu, 12 Feb 2009 13:30:35 -0600
> Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org> wrote:
> 
> > On Thu, 2009-02-12 at 10:11 -0800, Dave Hansen wrote:
> > 
> > > > - In bullet-point form, what features are missing, and should be added?
> > > 
> > >  * support for more architectures than i386
> > >  * file descriptors:
> > >   * sockets (network, AF_UNIX, etc...)
> > >   * devices files
> > >   * shmfs, hugetlbfs
> > >   * epoll
> > >   * unlinked files
> > 
> > >  * Filesystem state
> > >   * contents of files
> > >   * mount tree for individual processes
> > >  * flock
> > >  * threads and sessions
> > >  * CPU and NUMA affinity
> > >  * sys_remap_file_pages()
> > 
> > I think the real questions is: where are the dragons hiding? Some of
> > these are known to be hard. And some of them are critical checkpointing
> > typical applications. If you have plans or theories for implementing all
> > of the above, then great. But this list doesn't really give any sense of
> > whether we should be scared of what lurks behind those doors.
> 
> How close has OpenVZ come to implementing all of this?  I think the
> implementatation is fairly complete?

I also believe it is "fairly complete".  At least able to be used
practically.

> If so, perhaps that can be used as a guide.  Will the planned feature
> have a similar design?  If not, how will it differ?  To what extent can
> we use that implementation as a tool for understanding what this new
> implementation will look like?

Yes, we can certainly use it as a guide.  However, there are some
barriers to being able to do that:

dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... | diffstat | tail -1
 628 files changed, 59597 insertions(+), 2927 deletions(-)
dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... | wc 
  84887  290855 2308745

Unfortunately, the git tree doesn't have that great of a history.  It
appears that the forward-ports are just applications of huge single
patches which then get committed into git.  This tree has also
historically contained a bunch of stuff not directly related to
checkpoint/restart like resource management.

We'd be idiots not to take a hard look at what has been done in OpenVZ.
But, for the time being, we have absolutely no shortage of things that
we know are important and know have to be done.  Our largest problem is
not finding things to do, but is our large out-of-tree patch that is
growing by the day. :(

-- Dave
