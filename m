From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 5/9] cgroup: update error handling in cgroup_populate_dir()
Date: Thu, 11 Jul 2013 10:01:23 -0700
Message-ID: <20130711170123.GA10195@mtj.dyndns.org>
References: <1372463145-4245-1-git-send-email-tj@kernel.org>
	<1372463145-4245-6-git-send-email-tj@kernel.org>
	<51DE59D7.2000203@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51DE59D7.2000203-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Li.

On Thu, Jul 11, 2013 at 03:08:07PM +0800, Li Zefan wrote:
> > -	for_each_root_subsys(cgrp->root, ss) {
> > +	for_each_subsys(ss, i) {
> 
> Why this change?

Because subsystem binding / unbinding is being made dynamic and
subsystem linking would happen only after file popluation has been
confirmed to succeed, so it should be possible to perform file
creations / deletions whether the subsystem is currently bound or not.
Besides, I find it weird for file handling functions to care about
subsystem binding status directly.

I somehow forgot to write about the above in the patch description.
Will update.

> It even increases object size a bit:

Meh... cold path.  Wrong thing to optimize for.

Thanks.

-- 
tejun
