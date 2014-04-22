From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 cgroup/for-3.16] cgroup: add documentation about
	unified hierarchy
Date: Tue, 22 Apr 2014 17:14:26 -0400
Message-ID: <20140422211426.GD3615@mtj.dyndns.org>
References: <20140414220917.GD1863@htj.dyndns.org>
	<20140416145248.GD1257@htj.dyndns.org>
	<20140422162707.GR29311@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140422162707.GR29311-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Brandon Philips <brandon.philips-JW9irJGTvgXQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

Hope you enjoyed the vacation. :)

On Tue, Apr 22, 2014 at 06:27:07PM +0200, Michal Hocko wrote:
> On Wed 16-04-14 10:52:48, Tejun Heo wrote:
> [....]
> > +The memory controller currently doesn't have a way to control what
> > +happens between internal tasks and child cgroups and the behavior is
> > +not clearly defined. 
> 
> I am not sure I understand this. Could you be more specific what exactly
> is not clearly defined?

Oh, the fact that there are no control knobs for the internal tasks,
so when there's contention involving both internal tasks and child
cgroups, how resources are distributed is implementation specific
without clearly defined rules.

Thanks.

-- 
tejun
