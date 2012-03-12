From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Mon, 12 Mar 2012 15:55:57 -0700
Message-ID: <20120312225557.GK23255__6517.68539469248$1331592974$gmane$org@google.com>
References: <20120221211938.GE12236@google.com>
	<20120312221050.GG23255@google.com> <20120312223707.GA8272@peqn>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120312223707.GA8272@peqn>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Mon, Mar 12, 2012 at 05:37:07PM -0500, Serge Hallyn wrote:
> Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> > Hello, guys.
> > 
> > Thanks a lot for the discussion and here are my take aways:
> > 
> > * At least to me, nobody seems to have strong enough justification for
> >   orthogonal multiple hierarchies, so, yeah, unless something else
> 
> First off, can you (sorry) show an example of exactly what would no
> longer be supported?  Is this the ability to not separately mount
> freezer and cpusets (for instance)?

I think there are two aspects of it - there's actual functionality
loss and there's loss of one of the ways to achieve something.

The former is applying completely orthogonal categorizations to
processes depending on the controller in use - ie. memory limits by
user and disk IO limits by the program binary.  AFAICS, nobody seems
to have strong enough justification for this.

The latter is probably more material.  Even when people aren't using
orthogonal categorizations, they probably are using separate
hierarchies - currently, it's almost unavoidable to do so.  So, that
part would be more painful.  What I hope for is that some userland
system management tooling takes ownership of the cgroup fs interface
to impose some sane hierarchy and defaults, and expose more policy
aware interface to the rest of the system.

> I've submitted a topic for the upcoming linux foundation end user summit
> in new york, to get feedback from end users.  (Frankly I don't want to go
> so would love if someone else wanted to do this :).  I think it'd be nice
> to wait and see if this gets accepted, and see whether any end users are
> relying on this.
> 
> (IMO it's wrong to say that "if you are using a current feature, you'd
> better be reading lkml so you can speak up lest that feature might get
> removed.")

Well, these mailing lists are the widest comm channel I can make use
of and I expect there to be people to chain and propagate the
communication to many different channels as necessary.  So, yes, it
would be very appreciated if you can bring up the topic with larger /
different crowd. :)

Thank you.

-- 
tejun
