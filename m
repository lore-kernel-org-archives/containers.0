From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET] cpuset: drop cpuset->stack_list and ->parent, take#2
Date: Sun, 6 Jan 2013 17:27:46 +0800
Message-ID: <50E94392.2050509@huawei.com>
References: <1357249446-25075-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1357249446-25075-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/1/4 5:44, Tejun Heo wrote:
> Hello, guys.
> 
> This is the second take of "drop cpuset->stack_list and ->parent"
> patchset.  Other than being rebased on top of v3.8-rc2 + "cpuset:
> decouple cpuset locking from cgroup core, take#2", nothing really has
> changed.
> 
> The original patchset description follows.
> 
> cpuset implements its own descendant iteration using
> cpuset->stack_list and has its own ->parent pointer.  There's nothing
> cpuset specific about descendant walking or finding the parent.  This
> patchset makes cpuset use cgroup generic API instead.
> 
>  0001-cpuset-implement-cgroup_rightmost_descendant.patch
>  0002-cpuset-replace-cpuset-stack_list-with-cpuset_for_eac.patch
>  0003-cpuset-remove-cpuset-parent.patch
> 
> 0001 implements cgroup_rightmost_descendant() which can be used to
> skip subtree during pre-order tree walk.  Michal, maybe memcg can use
> it too?
> 
> 0002 replaces cpuset->stack_list with generic
> for_each_descendasnt_pre().
> 
> 0003 replaces cpuset->parent with cgroup->parent.
> 
> This patchset is on top of
> 
> v3.8-rc2 d1c3ed669a2d452cacfb48c2d171a1f364dae2ed
> + [1] "[PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from cgroup core, take#2"
> 
> and available in the following git branch.
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cpuset-iter
> 
>  include/linux/cgroup.h |    1 
>  kernel/cgroup.c        |   26 ++++++++
>  kernel/cpuset.c        |  151 +++++++++++++++++++++----------------------------
>  3 files changed, 92 insertions(+), 86 deletions(-)
> 

Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
