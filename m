From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Tue, 9 Apr 2013 12:11:45 -0700
Message-ID: <20130409191145.GI6186@mtj.dyndns.org>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<5162CA21.4060108@parallels.com> <51635371.7070104@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51635371.7070104-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lennart Poettering <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Tue, Apr 09, 2013 at 01:32:01AM +0200, Lennart Poettering wrote:
> The other big thing we want from the systemd side is saner
> notifications when cgroups run empty. i.e. currently we don't get
> these at all in containers (since the agent can be only installed
> once, for the host). And the way we get this is awful, via
> kernel-spawned processes. I am looking for a way how I can establish
> a watch on a certain subtree (not just one directory) and get simple
> notifications in a race-free whenever a cgroup runs empty.

Oh yeah, it's horrifying.  There was something going on a while ago
but I couldn't get hold of Eric Paris.  We probably should resurrect
that patch.

As for delegating to namespaces, I'm not exactly sure what to do.  At
least for now, it could be an acceptable trade-off to delegate the
subdirectory with some limits on the number of cgroups / depth of
hierarchy / whatever.  That said, I'm not really fond of the idea.  It
isn't likely to work seamlessly.  The root cgroup is special anyway
and I don't really like the idea of putting NS related stuff directly
into cgroupfs.

Thanks.

-- 
tejun
