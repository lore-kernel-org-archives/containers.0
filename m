From: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] cgroup: clean up obsolete code and comment
Date: Thu, 17 Apr 2014 22:21:27 +0800
Message-ID: <CAHz2CGUESujf3np6a6-hOwqmA5p37F8YCV3XKtZ_7K+8tuU=2w@mail.gmail.com>
References: <1397744056-31119-1-git-send-email-nasa4836@gmail.com>
	<20140417141904.GH15326@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140417141904.GH15326-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 17, 2014 at 10:19 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> And cgroup_subsys[] doesn't require cgroup_mutex protection anymore.
> That comment and BUG_ON(!mutex_is_locked()) can be removed.  Can you
> please separate these out into a separate patch?
>
>> 2. cgroup_pidlist_seq_operations has no more user, remove it.
>> 3. s/pr_warning/pr_warn/g, suggested by scripts/checkpatch.pl.
>
> And let's put 2 and 3 in separate patches too.
>
>> Signed-off-by: Jianyu Zhan <nasa4836-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
> Also, please regenerate the patches on top of the following branch.
>
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-populated-v2

Ok. This patch is based on review-populated-v2 already.


Thanks,
Jianyu Zhan
