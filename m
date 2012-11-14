From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 04/17] cgroup: create directory before linking while
	creating a new cgroup
Date: Wed, 14 Nov 2012 11:04:07 -0800
Message-ID: <20121114190407.GI21185__43383.9013604031$1352919876$gmane$org@mtj.dyndns.org>
References: <1352775704-9023-1-git-send-email-tj@kernel.org>
	<1352775704-9023-5-git-send-email-tj@kernel.org>
	<50A30E0F.7000408@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50A30E0F.7000408-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Li.

On Wed, Nov 14, 2012 at 11:20:47AM +0800, Li Zefan wrote:
> > It also removes the need to check whether cgroup->dentry is %NULL in
> > cgroup_path.  If a cgroup is visible, its dentry is guaranteed to be
> > visible too.
> 
> I'm afraid this isn't safe.
> 
> The cgroup is visible to a controller soon after ss->create(), and then
> the controller might call cgroup_path() while cgrp->dentry is still NULL.

Hmmm... I can't find any case where ss->create() is calling
cgroup_path().  Do you remember which one that was?

> This can happen for cpu cgroup I think, and in fact the NULL check was
> added for this reason IIRC.

Then, I think we better move the dentry assignment further up.  It's
really silly to be unable to answer "what's this new cgroup's name?"
for any callback really.  Will update accordingly.

Thanks.

-- 
tejun
