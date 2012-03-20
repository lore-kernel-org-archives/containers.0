From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 09/10] cgroup: introduce struct cfent
Date: Tue, 20 Mar 2012 09:02:28 -0700
Message-ID: <20120320160228.GD5684__41135.3931100622$1332259363$gmane$org@google.com>
References: <1331940963-15756-1-git-send-email-tj@kernel.org>
	<1331940963-15756-10-git-send-email-tj@kernel.org>
	<4F688EA9.8050905@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F688EA9.8050905-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Mar 20, 2012 at 06:05:29PM +0400, Glauber Costa wrote:
> On 03/17/2012 03:36 AM, Tejun Heo wrote:
> >+static void cgroup_clear_directory(struct dentry *dir)
> >+{
> >+	struct cgroup *cgrp = __d_cgrp(dir);
> >+
> >+	while (!list_empty(&cgrp->files))
> >+		cgroup_rm_file(cgrp, NULL);
> >+	WARN_ON_ONCE(!list_empty(&dir->d_subdirs));
> >  }
> 
> 
> I am hitting this warning here under pretty much normal conditions.
> You forgot to account for trivial directories like "."
> 
> I'll send a patch ontop of what you have.

Heh, yeah, I hit that yesterday too and was gonna look into that
today.  Is the patch coming? :)

Thanks.

-- 
tejun
