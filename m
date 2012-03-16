From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Fri, 16 Mar 2012 23:14:39 +0000
Message-ID: <1331939679.2858.56.camel__2935.37909533388$1331939696$gmane$org@dabdike>
References: <20120221211938.GE12236@google.com>
	<20120312221050.GG23255@google.com> <1331590938.18960.57.camel@twins>
	<20120312222817.GI23255@google.com> <20120313140345.GC29169@redhat.com>
	<20120313155955.GB7349@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120313155955.GB7349-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2012-03-13 at 08:59 -0700, Tejun Heo wrote:
> Hey, Vivek.
> 
> On Tue, Mar 13, 2012 at 10:03:45AM -0400, Vivek Goyal wrote:
> > > With root being treated specially, probably as just being a equal
> > > group as other groups, I'm not fully determined about that yet.
> > 
> > So what wrong with flattening the whole hierarchy and all groups being active
> > in the path? It is not worse then second option?
> > 
> >              root
> >        /   |  |  |  \
> >       G1  G2  G3 G31 G32
> 
> It is worse because while there isn't much need for orthogonal
> hierarchies, people often need to apply different limits at different
> levels of the hierarchy for different controllers.  ie. it often
> happens that the distinction between G31 and G32 matters for one
> controller but not for others.  The problem with flattening like you
> suggested above is that it isn't a hierarchy at all - membership isn't
> recursive.
> 
> Imposing limits at single level is an additional restriction and may
> cause some config complexity but it'll be at least explicit and can
> co-exist with full hierarchy in meaningful way.

Isn't there a simple fix for this?  Each controller can decide whether
to pay attention to its cgroup parent in calculating the resource limits
or counting usage.  If the controller elects not to pay attention to its
parents when counting resources and enforcing limits, it effectively
gives you a flat hierarchy from the point of view of the controller.

What actually happens depends on how the controller calculates the
limits: if it's a global fraction, then it's completely flat, if it's
just an absolute limit, then it wouldn't pay attention to the parent
anyway, if it's a proportion, then the controller has to decide how to
divide up the parent's allocation.

James
