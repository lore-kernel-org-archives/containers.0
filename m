From: Lennart Poettering <mzxreary-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
Subject: Re: [PATCH] cgroup: deprecate remount option changes mount option
Date: Thu, 15 Mar 2012 20:36:35 +0100
Message-ID: <20120315193635.GD32661@tango.0pointer.de>
References: <20120314215228.GI7349@google.com>
	<20120315165655.GD32137@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120315165655.GD32137-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 15.03.12 09:56, Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org) wrote:

> This patch marks the following features for deprecation.
> 
> * Rebinding subsys by remount: Never reached useful state - only works
>   on empty hierarchies.
> 
> * release_agent update by remount: release_agent itself will be
>   replaced with conventional fsnotify notification.

Just wondering, what kind of event do you plan to emit if a cgroup runs
empty? To userspace, with fanotify, will this be FAN_MODIFY? I'd very
much prefer if we only get events really when a group runs empty, and
not each time a PID is added/removed from a cgroup, which FAN_NOTIFY
might suggest?

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
