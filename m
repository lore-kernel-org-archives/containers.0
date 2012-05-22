From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix device deny of DEV_ALL
Date: Tue, 22 May 2012 07:48:31 -0500
Message-ID: <20120522124831.GA4760@sergelap>
References: <CAFeW=pZ8Y7ycxjxro7zBMqdtaCOYs4RmoxtDrsN8+mqLhOL--g@mail.gmail.com>
	<20120518081912.16779.21065.stgit@t>
	<20120521140324.GA5091@sergelap> <4FBADF1A.6040303@huawei.com>
	<20120522015426.GA10344@mail.hallyn.com>
	<4FBAF680.90007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4FBAF680.90007-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
> On 22/05/12 09:54, Serge E. Hallyn wrote:
> >Quoting Li Zefan (lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org):
> >>Serge Hallyn wrote:
> >>
> >>>Quoting Amos Kong (akong-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> >>>>@ mount -t cgroup -o devices none /cgroup
> >>>>@ mkdir /cgroups/devices
> >>>>@ ls -l /dev/dm-3
> >>>>  brw-rw----. 1 root disk 253, 3 Oct 14 19:03 /dev/dm-3
> >>>>@ echo 'b 253:3 rw'>  devices.deny
> >>>>but I can still write it by 'dd if=/dev/zero of=/dev/dm-3'
> >>>>
> >>>>In devcgroup_create(), we create a new whitelist, and add first
> >>>>entry which type is 'DEV_ALL'. Execute "# echo 'b 253:3 rw'>
> >>>>devices.deny", dev_whitelist_rm() will update access of first
> >>>>entry to 1(m), but type of first entry is still 'DEV_ALL'.
> >>>
> >>>Hi,
> >>>
> >>>thanks.  You raise a good point, but I think it needs some discussion.
> >>>
> >>>What happens right now is that if you have the 'a *:* rwm' entry and do
> >>>echo 'b 253:3 rw'>  devices.deny, then when you next cat devices.list you
> >>>will still see the 'a *:* rwm' entry.  So there should be no confusion
> >>>over why the dd succeeds.
> 
> >>>  You didn't remove the entry, because there
> >>>was no match echoed into devices.deny.
> 
> Hi serge,
> 
> My patch updated type,major,minor, it _equals to_ remove 'a *:* rwm'
> and add 'b *:* m'
> It's a clear logic, why need to manually remove 'a *:* rwm'?

Because until now, (apart from the special case 'a',) the devices.deny
rules have been very simple - you have to match an exact existing entry
as seen in devices.list.

I guess that was never explicitly written anywhere.  So the only reason
not to change it (apart from simplicity) is that, if I happen to have

	a *:* rwm

and accidentally give myself

	for seq in `1 254`; do
		echo "b *:$i rwm" > devices.allow
	done

and want to undo it, now i can't remove those without also removing
a *:* rwm.  (which I might not be able to get back)

> >>No, you'll see the entry has been changed to 'a *:* m', so I think we
> >>should at least fix this.
> >
> >Yikes.  Agreed.  That's a bug.
> 
> which bug? should not update walk->access if wh->access is not 'rwm'?

Well, in light of morning, I'm not so sure this is bad.  It doesn't fit
with what I am saying above that I wanted :)  But if I had 'a *:* rwm'
and I say I don't want to be able to rw to b 254:3, then leaving me
with only 'a *:* m' does achieve that.

Still I would prefer to have to match the entries in devices.list.

> diff --git a/security/device_cgroup.c b/security/device_cgroup.c
> index c43a332..e619a34 100644
> --- a/security/device_cgroup.c
> +++ b/security/device_cgroup.c
> @@ -145,7 +145,8 @@ static void dev_whitelist_rm(struct dev_cgroup
> *dev_cgroup,
>                         continue;
> 
>  remove:
> -               walk->access &= ~wh->access;
> +               if (walk->type != DEV_ALL || wh->access == ACC_MASK)
> +                       walk->access &= ~wh->access;

I'm not following what this is actually meant to do.  It'll do the
same thing as the original code, unless walk->type == DEV_ALL and
wh->access != ACC_MASK, but that is never the case per
devcgroup_update_access().

>                 if (!walk->access) {
>                         list_del_rcu(&walk->list);
>                         kfree_rcu(walk, rcu);
> 
> 
> -- 
> 			Amos.

Lastly, perhaps what we actually want to do is implement blacklists
instead of a pure whitelist?  So we could then really say "allow
everything except b 254:3 rw" with two entries.

But, while it may be nice to talk about that, I have not seen any
cases where someone actually wanted that.  For containers, at least,
a pure whitelist has always been right.

thanks,
-serge
