From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Fri, 24 Feb 2012 12:33:16 +0100
Message-ID: <1330083196.11248.24.camel@twins>
References: <20120221211938.GE12236@google.com>
	<20120222163858.GB4128@redhat.com> <20120222165714.GC4128@redhat.com>
	<1329990094.24994.64.camel@twins> <20120223213847.GK19691@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120223213847.GK19691-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2012-02-23 at 16:38 -0500, Vivek Goyal wrote:
> > > Again, it does not mean I am advocating flat hiearchy. I am just wondering
> > > in case of fully nested hierarchies (task at same level as groups), how
> > > does one explain it to a layman user who understands things in terms of
> > > % of resources. 
> > 
> > If your complete control is % based then I would assume its a % of a %.
> > Simple enough.
> 
> But % of % will vary dynamically and not be static. So if root has got
> 100% of resources and we want 25% of that for a group, then hierarchy
> might look as follows.
> 
>                                 root
>                                 / | \
>                                T1 T2 g1
> 
> T1, T2 are tasks and g1 is the group needing 25% of root's resources. Now
> number of tasks running in parallel to g1 will determine its effective %
> and tasks come and go. So the only way to do this would be that move T1
> and T2 in a child group under root and make sure new tasks don't show up
> in root. 

Which is exactly that the scheduler stuff does.. so tough luck for the
sysad who can't grasp it.

> Otherwise creating a group under root does not ensure that you get minimum
> % of resource. It just makes sure that you can't get more than 25% of
> % resources when things are tight. 

You never said anything about minimum resource guarantees in the initial
problem statement.
