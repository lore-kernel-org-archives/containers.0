From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.11] cgroup: miscellaneous cleanups
Date: Mon, 24 Jun 2013 15:32:01 -0700
Message-ID: <20130624223201.GL1918__22277.0096887418$1372113137$gmane$org@mtj.dyndns.org>
References: <1371864854-28364-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1371864854-28364-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Jun 21, 2013 at 06:34:08PM -0700, Tejun Heo wrote:
> Hello,
> 
> These are misc clean up patches mostly focused on subsys handling that
> I ended up with while working on unified hierarchy support.  Nothing
> too interesting.  Just cleanups.
> 
>  0001-cgroup-convert-CFTYPE_-flags-to-enums.patch
>  0002-cgroup-prefix-global-variables-with-cgroup_.patch
>  0003-cgroup-remove-cgroup-actual_subsys_mask.patch
>  0004-cgroup-clean-up-find_css_set-and-friends.patch
>  0005-cgroup-s-for_each_subsys-for_each_root_subsys.patch
>  0006-cgroup-implement-for_each_-builtin_-subsys.patch

Applied 0001-0005.  The patches are re-sequenced so that they can be
applied before the RCU fixes.  Nothing noteworthy, just a couple
trivial context conflicts.  Will soon post updated version of 0006.

Thanks.

-- 
tejun
