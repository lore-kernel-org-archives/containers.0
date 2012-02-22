From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Wed, 22 Feb 2012 10:01:12 -0800
Message-ID: <20120222180112.GB32694__22210.630196105$1329933688$gmane$org@google.com>
References: <20120221211938.GE12236@google.com>
	<1329917459.24994.14.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1329917459.24994.14.camel@twins>
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
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
List-Id: containers.vger.kernel.org

Hey, Peter.

On Wed, Feb 22, 2012 at 02:30:59PM +0100, Peter Zijlstra wrote:
> FWIW I'm all for ripping the orthogonal hierarchy crap out, I hate it
> just about as much as you do judging from your write-up.

I just don't get why it's there.  Maybe, there can be some remote use
cases where orthogonal hierarchies can be useful but structuring whole
cgroup around that seems really extreme.

> I'm not sure on your process hierarchy pie though, I rather like being
> able to assign tasks to cgroups of my making without having to mirror
> that in the process hierarchy.

The only question is whether we want to allow cgroup hierarchy to be
completely orthogonal from process tree structure, which I don't think
is a good idea.  It shouldn't affect trivial use cases.  If not
explicitly configured, all tasks would live in a single root cgroup -
much like every process would belong to the same session if nobody
does setsid() since boot (or container).

I don't know how the implementation would turn out and it may as well
stay separate as it is now but I still think the topology should match
pstree.

Thanks.

-- 
tejun
