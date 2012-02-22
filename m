From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Wed, 22 Feb 2012 14:30:59 +0100
Message-ID: <1329917459.24994.14.camel__2697.62279135666$1329917483$gmane$org@twins>
References: <20120221211938.GE12236@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120221211938.GE12236-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2012-02-21 at 13:19 -0800, Tejun Heo wrote:
> So, I mean, I don't know.  What do other people think?  Is this a
> unnecessary worry?  Are people generally happy with the way things
> are?  Lennart, Kay, what do you guys think? 

FWIW I'm all for ripping the orthogonal hierarchy crap out, I hate it
just about as much as you do judging from your write-up.

Yes it will make some people unhappy, but I can live with that since my
life will be easier.. :-)

I'm not sure on your process hierarchy pie though, I rather like being
able to assign tasks to cgroups of my making without having to mirror
that in the process hierarchy.

Having seen what userspace does (libvirt in particular, I've still
managed to not get infected by the systemd crap) its utterly and
completely insane. Now I don't think any of my machines actually still
have libvirt on it, so I don't care if we break that either ;-)

Another thing I dislike about all the cgroup crap is all the dozens of
tiny controllers being proposed left right and center. Like WTF isn't
the hugetlb controller part of memcg? Its all memory, right?

Now I appreciate all this is new and exciting and Linux does the
evolutionary development thing so its bound to be a mess sometimes, but
shees.. 

So +1 on just ripping everything apart and trying again.
