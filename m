From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix device deny of DEV_ALL
Date: Mon, 21 May 2012 09:03:24 -0500
Message-ID: <20120521140324.GA5091__37978.1029922471$1337609020$gmane$org@sergelap>
References: <CAFeW=pZ8Y7ycxjxro7zBMqdtaCOYs4RmoxtDrsN8+mqLhOL--g@mail.gmail.com>
	<20120518081912.16779.21065.stgit@t>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120518081912.16779.21065.stgit@t>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Amos Kong <akong-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mtosatti-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Amos Kong (akong-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> @ mount -t cgroup -o devices none /cgroup
> @ mkdir /cgroups/devices
> @ ls -l /dev/dm-3
>  brw-rw----. 1 root disk 253, 3 Oct 14 19:03 /dev/dm-3
> @ echo 'b 253:3 rw' > devices.deny
> but I can still write it by 'dd if=/dev/zero of=/dev/dm-3'
> 
> In devcgroup_create(), we create a new whitelist, and add first
> entry which type is 'DEV_ALL'. Execute "# echo 'b 253:3 rw' >
> devices.deny", dev_whitelist_rm() will update access of first
> entry to 1(m), but type of first entry is still 'DEV_ALL'.

Hi,

thanks.  You raise a good point, but I think it needs some discussion.

What happens right now is that if you have the 'a *:* rwm' entry and do
echo 'b 253:3 rw' > devices.deny, then when you next cat devices.list you
will still see the 'a *:* rwm' entry.  So there should be no confusion
over why the dd succeeds.  You didn't remove the entry, because there
was no match echoed into devices.deny.

You have to remove the existing whitelist entries, then add the entries
you want.  In particular, catting into devices.deny will not try to be
smart by slicing an existing whitelist entry into (matching, nonmatching)
parts so as to remove the matching and keep nonmatching.

If you'd like to submit a patch to change that, I'm quite sure I would
ack it.  The problem is that your patch doesn't do that (unless I'm grossly
misunderstanding).  Rather, it will remove both (matching, nonmatching).
Of course, in your example above, (nonmatching) would amount to a huge
set of rules, so in the end I'm not sure it is worth it.

Note that the devices cgroup was meant to be a simple, useful stop-gap
until the user and devices namespaces are ready.  The user namespace is
getting close, but devices ns still needs to be designed (hopefully at
plumber's).  So I don't mind improving on the devices cgroup.  It's
turned out to be quite useful.  But I don't want to replace one (simple,
easy to verify, but) incomplete user interface with a different one.
There are sure to be existing users who would be broken.  In fact, it's
possbile that "fixing" the incomplete behavior would bother some users,
though I suspect the improvement would be worth it to them.

So for this particular patch, NACK.  But thanks for bringing it up.

thanks,
-serge

> Execute dd cmd to write device, __devcgroup_inode_permission()
> will be called, permission checking will pass if entry type
> is 'DEV_ALL'. So write operation of 'dd' is not denied.
> 
> Currently 'access' is updated by not be used, this patch updated
> the type,major,minor of first entry, then permission checking
> would work.
> 
> Signed-off-by: Amos Kong <akong-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  security/device_cgroup.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/security/device_cgroup.c b/security/device_cgroup.c
> index c43a332..d16b4bc 100644
> --- a/security/device_cgroup.c
> +++ b/security/device_cgroup.c
> @@ -146,6 +146,11 @@ static void dev_whitelist_rm(struct dev_cgroup *dev_cgroup,
>  
>  remove:
>  		walk->access &= ~wh->access;
> +		if (walk->type == DEV_ALL) {
> +			walk->type = wh->type;
> +			walk->major = wh->major;
> +			walk->minor = wh->minor;
> +		}
>  		if (!walk->access) {
>  			list_del_rcu(&walk->list);
>  			kfree_rcu(walk, rcu);
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
