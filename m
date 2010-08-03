From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 3/3] cgroup : remove the ns_cgroup
Date: Tue, 03 Aug 2010 16:31:03 +0800
Message-ID: <4C57D3C7.2010509__47163.2445035086$1280824011$gmane$org@cn.fujitsu.com>
References: <20100729195629.GA13378@hallyn.com>
	<20100729195812.GB19015@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100729195812.GB19015-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Cc: Andrew

Serge E. Hallyn wrote:
> The ns_cgroup is an annoying cgroup at the namespace / cgroup frontier.
> 
> For example, a single process can not handle a big amount of namespaces
> without interacting with this cgroup and falling in an exponential creation
> time due to the nested cgroup directory depth (eg. /cgroup/<pid>/.../<pid>/...).
> 
> That was spotted when creating a single process using multiple network namespaces,
> the objective was 4096 network namespaces, but at 820 netns, the creation time
> was dramatically slow and the creation time for a namespace increased from 10msec
> to 10sec. After five hours, the expected numbers of netns was not reached.
> Without the ns_cgroup interaction, 4K netns are created after 2 minutes.
> 
> In order to solve that, we have to mount the cgroup with all the subsystems
> except the ns_cgroup, it's a little weird and hard to manage from an administration
> pov because we have to know what are the cgroup available on the system and we
> can't do a simple 'mount -t cgroup cgroup /cgroup'.
> 
> With the previous patch which adds a 'clone_children' parameter to a cgroup,
> we should be able to remove the ns_cgroup and manage manually the creation +
> adding a task to the cgroup consistenly with the rest of the subsystems.
> 
> This patch removes the ns_cgroup as suggested in the following thread:
> 
> https://lists.linux-foundation.org/pipermail/containers/2009-June/018616.html
> 
> The 'cgroup_clone' function is removed because it is no longer used.
> 
> Changelog: Jul 29 (seh): remove references to ns_cgroup_clone(), fix up
> 	   some documentation, and remove CONFIG_CGROUP_NS references.
> 
> Signed-off-by: Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>
> Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Cc: Jamal Hadi Salim <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>

Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
