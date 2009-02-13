From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: What can OpenVZ do?
Date: Fri, 13 Feb 2009 14:32:48 +0300
Message-ID: <20090213113248.GA15275__3447.07548288188$1234524558$gmane$org@x200.localdomain>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1234285547.30155.6.camel@nimitz>
	<20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz>
	<1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz> <20090213102732.GB4608@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090213102732.GB4608-X9Un+BFzKDI@public.gmane.org>
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
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Feb 13, 2009 at 11:27:32AM +0100, Ingo Molnar wrote:
> 
> * Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> 
> > > If so, perhaps that can be used as a guide.  Will the planned feature
> > > have a similar design?  If not, how will it differ?  To what extent can
> > > we use that implementation as a tool for understanding what this new
> > > implementation will look like?
> > 
> > Yes, we can certainly use it as a guide.  However, there are some
> > barriers to being able to do that:
> > 
> > dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... | diffstat | tail -1
> >  628 files changed, 59597 insertions(+), 2927 deletions(-)
> > dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... | wc 
> >   84887  290855 2308745
> > 
> > Unfortunately, the git tree doesn't have that great of a history.  It
> > appears that the forward-ports are just applications of huge single
> > patches which then get committed into git.  This tree has also
> > historically contained a bunch of stuff not directly related to
> > checkpoint/restart like resource management.
> 
> Really, OpenVZ/Virtuozzo does not seem to have enough incentive to merge
> upstream, they only seem to forward-port, keep their tree messy, do minimal
> work to reduce the cross section to the rest of the kernel (so that they can
> manage the forward ports) but otherwise are happy with their carved-out
> niche market. [which niche is also spiced with some proprietary add-ons,
> last i checked, not exactly the contribution environment that breeds a
> healthy flow of patches towards the upstream kernel.]

Oh, cut the crap!

> Merging checkpoints instead might give them the incentive to get
> their act together.

Knowing how much time it takes to beat CPT back into usable shape every time
big kernel rebase is done, OpenVZ/Virtuozzo have every single damn incentive
to have CPT mainlined.

If someone is afraid of long config options, there are always CONFIG_CPT and
CONFIG_CR available.
