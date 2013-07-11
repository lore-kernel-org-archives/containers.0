From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [OFFLIST] status of devcg
Date: Thu, 11 Jul 2013 10:34:05 +0100
Message-ID: <20130711093405.GC2377__48906.1105334715$1373535271$gmane$org@redhat.com>
References: <20130710184655.GB16979@mtj.dyndns.org>
	<20130710195001.GW14011@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130710195001.GW14011-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jul 10, 2013 at 03:50:02PM -0400, Aristeu Rozanski wrote:
> On Wed, Jul 10, 2013 at 11:46:55AM -0700, Tejun Heo wrote:
> > Just wondering whether you're working on implementing new hierarchical
> > behavior on devcg.  If so, can you please share some details on how
> > you're planning to do it?  Please feel free to add the relevant
> > mailing lists when replying.
> 
> I did start, but still dealing with lots of company internal tasks so I
> couldn't do much.
> 
> One of the ideas is to start changing (again) how the rules are processed
> internally, moving away from the default policy + exceptions model to
> an ordered set of rules like iptables:
> 
> 	default: allow/deny
> 	allow block major 100-101, all minors
> 	deny char major 200, all minors
> 	...
> 
> That will solve most complex use cases the current model won't [1] but
> the problem with this approach is that since it relies on order, merging
> would be a problem, and it'd have test each parent all the way to / to
> make sure the access is possible.
> 
> [1] One example of usage the current model won't solve:
> 
> 	- by default deny everything
> 	- allow c,200,*
> 	- but deny c,200,100
> 
> The second idea, which is simpler, will reuse the current internal model
> of default policy + exceptions and the idea in the initial patches of having
> two lists in each cgroup: active policy+exceptions and locally set
> policy+exceptions. This way for every change that happens in a parent (or
> even change of parents when moving the cgroup around), the active
> policy+exceptions will be regenerated.
> 
> In both cases, we do need a new userspace interface (although we can
> still provide backwards compatibility with the old one).
> 
> Comments?

FWIW, libvirt's usage of devcg is to deny all by default, allow major 136
(for all /dev/pts/*), followed by allow (major,minor) pair for each specific
whitelisted devices. As such we don't have anything that relies on ordering
of rules in devcg.

Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
