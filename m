From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Tue, 28 Feb 2012 16:16:27 -0500
Message-ID: <20120228211627.GH9920@redhat.com>
References: <20120221211938.GE12236@google.com>
	<20120222163858.GB4128@redhat.com>
	<20120222165714.GC4128@redhat.com>
	<1329990094.24994.64.camel@twins>
	<20120223213847.GK19691@redhat.com>
	<20120223223457.GJ22536@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120223223457.GJ22536-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Feb 23, 2012 at 02:34:57PM -0800, Tejun Heo wrote:
> On Thu, Feb 23, 2012 at 04:38:47PM -0500, Vivek Goyal wrote:
> > On Thu, Feb 23, 2012 at 10:41:34AM +0100, Peter Zijlstra wrote:
> > > On Wed, 2012-02-22 at 11:57 -0500, Vivek Goyal wrote:
> > > > 
> > > > Again, it does not mean I am advocating flat hiearchy. I am just wondering
> > > > in case of fully nested hierarchies (task at same level as groups), how
> > > > does one explain it to a layman user who understands things in terms of
> > > > % of resources. 
> > > 
> > > If your complete control is % based then I would assume its a % of a %.
> > > Simple enough.
> > 
> > But % of % will vary dynamically and not be static. So if root has got
> > 100% of resources and we want 25% of that for a group, then hierarchy
> > might look as follows.
> 
> It is complex but semantics is pretty well defined.  It should behave
> exactly the same as HTB.  Whether the complexity would be justifiable
> is a different issue.

I don't know much about HTB but a quick read at internet seems to suggest
that hierarchy we setup is pretty static and does not change with more
task coming in/going out. That means share/configured bandwidth of each
queue in the hierarchy is fixed until and unless that tree is changed. 

But in this case, if task and groups are treated at same level, things
are not static and % share will change dynamically.

Thanks
Vivek
