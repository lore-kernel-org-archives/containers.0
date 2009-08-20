From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/8] Lets ss->can_attach and ss->attach do whole
	threadgroups at a time
Date: Wed, 19 Aug 2009 21:38:58 -0700
Message-ID: <20090820043858.GD29801__27805.8572476313$1250743280$gmane$org@count0.beaverton.ibm.com>
References: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>
	<20090818235837.22531.86001.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090818235837.22531.86001.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 18, 2009 at 04:58:38PM -0700, Paul Menage wrote:
> From: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> 
> Lets ss->can_attach and ss->attach do whole threadgroups at a time
> 
> This patch alters the ss->can_attach and ss->attach functions to be able to
> deal with a whole threadgroup at a time, for use in cgroup_attach_proc. (This
> is a pre-patch to cgroup-procs-writable.patch.)
> 
> Currently, new mode of the attach function can only tell the subsystem about
> the old cgroup of the threadgroup leader. No subsystem currently needs that
> information for each thread that's being moved, but if one were to be added
> (for example, one that counts tasks within a group) this bit would need to be
> reworked a bit to tell the subsystem the right information.
> 
> Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

freezer bits:

Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
