From: Lennart Poettering <mzxreary-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Tue, 13 Mar 2012 00:43:19 +0100
Message-ID: <20120312234319.GA23392@tango.0pointer.de>
References: <20120221211938.GE12236@google.com>
	<20120312221050.GG23255@google.com>
	<1331590938.18960.57.camel@twins>
	<20120312222817.GI23255@google.com>
	<20120312223113.GB18359@tango.0pointer.de>
	<20120312230020.GL23255@google.com>
	<1331593367.18960.66.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1331593367.18960.66.camel@twins>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 13.03.12 00:02, Peter Zijlstra (peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org) wrote:

> 
> On Mon, 2012-03-12 at 16:00 -0700, Tejun Heo wrote:
> > 
> > Ooh, both will be available to choose from.  I was trying to explain
> > that there can be configuration only at one layer for any task so that
> > it can be mapped to flat hierarchy.  Where to apply the config will be
> > selected by the user (or system tool). 
> 
> Thus in effect this is a false choice, since Lennart and assorted idiots
> conspire against sanity by pushing systemd into our every orifice, and
> since he just said systemd requires one of the two, the choice will be
> made for us, lest we forfeit wanting to boot our system.

I didn't say that that we require one of the two. I just pointed out
that for us the first option makes more sense. Also, as I pointed out I
am happy to adapt systemd to whatever Tejun decides.

BTW, I actually believe the hierachial design of cgroups is pretty neat,
since it allows us to label things hierarchially, so that for example
user services can have their own labels all beneath a per-user label. So
for the purpose of grouping things and naming them I very much
appreciate hierarchial cgroups. For the purpose of actually applying
resource controls I care much less for it, but I still do see its
use.

Lennart

PS: Awesome choice of words! I totally appreciate how you talk to and
about me. This creates such a strong urge inside of me to care about the
problems you have with systemd and fix them for you.

-- 
Lennart Poettering - Red Hat, Inc.
