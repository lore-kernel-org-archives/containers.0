From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Tue, 28 Feb 2012 16:35:26 -0500
Message-ID: <20120228213526.GI9920@redhat.com>
References: <20120221211938.GE12236@google.com>
	<20120222163858.GB4128@redhat.com>
	<20120222165714.GC4128@redhat.com>
	<1329990094.24994.64.camel@twins>
	<20120223213847.GK19691@redhat.com>
	<20120223223457.GJ22536@google.com>
	<20120228211627.GH9920@redhat.com>
	<1330464100.11248.94.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1330464100.11248.94.camel@twins>
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

On Tue, Feb 28, 2012 at 10:21:40PM +0100, Peter Zijlstra wrote:
> On Tue, 2012-02-28 at 16:16 -0500, Vivek Goyal wrote:
> > 
> > But in this case, if task and groups are treated at same level, things
> > are not static and % share will change dynamically. 
> 
> which is exactly how the scheduler stuff behaves for the proportional
> bits.. so there's no reason not to do it too.

Yes this is how scheduler does to handle hierarchy. Treat task and group
at same level. Tejun was giving example of HTB and I was saying that there
class/queues or whatever, seem to be static and are not created
dynamically as tasks come in/go. So its not same.

So coming back to scheduler, handling tasks and groups at same level only
provides us with notion of priority for group. It does not provide any
notion of % (neither minimum, nor maximum). To calculate the % one needs
to know the proportioanal share/weight of all entities at same level and
currently number of entities vary hence % share can't be determined.

Whether it is a good thing or bad thing, I don't know. I think previous
design was allocating a group for every user. I guess, in that case we
will have fixed % share of each user (until and unless users are created/
removed).

So I don't know what's the right behavior. With this discussion, I am just
trying to make it explicit what to expect out of cgroup controllers. For
cpu controller, it is priority at the group level no fixed minimum/maximum
% shares. And that's a limitation of treating task and group at same level.

Thanks
Vivek
