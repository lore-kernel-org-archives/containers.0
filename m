From: Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11] cgroup: disallow rename(2) if
	sane_behavior
Date: Sun, 16 Jun 2013 09:16:48 +0200
Message-ID: <20130616071648.GA1978__6413.74105257473$1371367029$gmane$org@tango.0pointer.de>
References: <20130614034717.GA31533@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130614034717.GA31533-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 13.06.13 20:47, Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org) wrote:

> cgroup's rename(2) isn't a proper migration implementation - it can't
> move the cgroup to a different parent in the hierarchy.  All it can do
> is swapping the name string for that cgroup.  This isn't useful and
> can mislead users to think that cgroup supports proper cgroup-level
> migration.  Disallow rename(2) if sane_behavior.

Note that in the long run I'd really like to see functionality added to
move a full cgroup subtree to a different point in the tree, so that we
can migrate containers and such atomically from one partition to
another, without the container having to be aware of this (which of
course implies that we have a somewhat more useful cgroup namespacing
solution in place).

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
