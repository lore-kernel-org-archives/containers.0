From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 1/9] cgroup: add cgroup_subsys->post_create()
Date: Mon, 5 Nov 2012 14:42:19 +0100
Message-ID: <5097C23B.3040808@parallels.com>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
	<1351931915-1701-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351931915-1701-2-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 11/03/2012 09:38 AM, Tejun Heo wrote:
> Currently, there's no way for a controller to find out whether a new
> cgroup finished all ->create() allocatinos successfully and is
> considered "live" by cgroup.
> 
> This becomes a problem later when we add generic descendants walking
> to cgroup which can be used by controllers as controllers don't have a
> synchronization point where it can synchronize against new cgroups
> appearing in such walks.
> 
> This patch adds ->post_create().  It's called after all ->create()
> succeeded and the cgroup is linked into the generic cgroup hierarchy.
> This plays the counterpart of ->pre_destroy().
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

Tejun, If we do it this way, we end up with two callbacks that are
called after create: post_clone and post_create. I myself prefer the
approach I took, that convert post_clone into post_create, and would
prefer if you would pick that up.

For me, post_clone is totally a glitch that should not exist. Merging
this with post_create gives the following semantics:

* A while after cgroup creation, you will get a callback. In that
callback, you do whatever initialization you may need that you could not
in create. Why is reacting to a flag being set any different?
