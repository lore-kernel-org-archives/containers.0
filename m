From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Tue, 13 Mar 2012 18:31:58 +0100
Message-ID: <1331659918.18960.87.camel@twins>
References: <20120221211938.GE12236@google.com>
	<20120312221050.GG23255@google.com> <1331590938.18960.57.camel@twins>
	<20120312222817.GI23255@google.com> <1331591568.18960.61.camel@twins>
	<20120312223944.GJ23255@google.com> <1331592241.18960.64.camel@twins>
	<20120312230416.GM23255@google.com> <20120313141032.GD29169@redhat.com>
	<1331659537.18960.84.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1331659537.18960.84.camel@twins>
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
Cc: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2012-03-13 at 18:25 +0100, Peter Zijlstra wrote:
> On Tue, 2012-03-13 at 10:10 -0400, Vivek Goyal wrote:
> > Implementing hierarchy is a pain and is expensive at run time. 
> 
> Yeah, suck it up :-)
> 
> I would really rather we mandate one implementation standard for
> controllers for the sake of consistency and uniformity. A direct result
> of doing away with the multiple hierarchy crap is that all controllers
> are co-mounted. Allowing differences like this just doesn't make any
> sense.
> 
> So either we drop full hierarchy support from all controllers or we
> deprecate and remove all non-hierarchical controllers.
> 
> I'm fine with either, but I'm not fine with with the half-arsed
> solutions proposed here.

Note that before this whole discussion I was under the impressions it
was mandated for a controller to be fully hierarchical. I'm very much
surprised people were allowed to merge incomplete controllers like that.
