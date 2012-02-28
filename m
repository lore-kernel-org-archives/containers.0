From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Tue, 28 Feb 2012 16:54:39 -0500
Message-ID: <20120228215439.GJ9920@redhat.com>
References: <20120221211938.GE12236@google.com>
	<20120222163858.GB4128@redhat.com>
	<20120222165714.GC4128@redhat.com>
	<1329990094.24994.64.camel@twins>
	<20120223213847.GK19691@redhat.com>
	<20120223223457.GJ22536@google.com>
	<20120228211627.GH9920@redhat.com>
	<1330464100.11248.94.camel@twins>
	<20120228213526.GI9920@redhat.com>
	<1330465434.11248.98.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1330465434.11248.98.camel@twins>
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
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 28, 2012 at 10:43:54PM +0100, Peter Zijlstra wrote:
> On Tue, 2012-02-28 at 16:35 -0500, Vivek Goyal wrote:
> > For
> > cpu controller, it is priority at the group level no fixed minimum/maximum
> > % shares. And that's a limitation of treating task and group at same level.
> 
> Depends on what you mean by min/max %, you can do it on the group level
> by using bandwidth caps (for max) or inverted (max on everybody else,
> for min).

I was referring to using pure proportional controller. max bandwidth is
new and I am looking for a quick documentation file which describes
what are the knobs and how to use it. Did not find any in
Documentation/cgroups/. Is there any documentation available?

I am assuming that max are being specified for groups in some absolute
quantity. That is fine. It will not still be max %, as again for % you
need fixed number of entities at any level and that's not the case with
tasks.

Minimum for one group (max for everyone else) will also only work if 
task and groups are not at same level.

I think the only way to get fixed % share is not to put task and group
at same level during system configuration.

Thanks
Vivek
