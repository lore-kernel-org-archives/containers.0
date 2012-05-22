From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix device deny of DEV_ALL
Date: Tue, 22 May 2012 01:54:26 +0000
Message-ID: <20120522015426.GA10344@mail.hallyn.com>
References: <CAFeW=pZ8Y7ycxjxro7zBMqdtaCOYs4RmoxtDrsN8+mqLhOL--g@mail.gmail.com>
	<20120518081912.16779.21065.stgit@t>
	<20120521140324.GA5091@sergelap> <4FBADF1A.6040303@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4FBADF1A.6040303-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mtosatti-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Amos Kong <akong-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Li Zefan (lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org):
> Serge Hallyn wrote:
> 
> > Quoting Amos Kong (akong-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> >> @ mount -t cgroup -o devices none /cgroup
> >> @ mkdir /cgroups/devices
> >> @ ls -l /dev/dm-3
> >>  brw-rw----. 1 root disk 253, 3 Oct 14 19:03 /dev/dm-3
> >> @ echo 'b 253:3 rw' > devices.deny
> >> but I can still write it by 'dd if=/dev/zero of=/dev/dm-3'
> >>
> >> In devcgroup_create(), we create a new whitelist, and add first
> >> entry which type is 'DEV_ALL'. Execute "# echo 'b 253:3 rw' >
> >> devices.deny", dev_whitelist_rm() will update access of first
> >> entry to 1(m), but type of first entry is still 'DEV_ALL'.
> > 
> > Hi,
> > 
> > thanks.  You raise a good point, but I think it needs some discussion.
> > 
> > What happens right now is that if you have the 'a *:* rwm' entry and do
> > echo 'b 253:3 rw' > devices.deny, then when you next cat devices.list you
> > will still see the 'a *:* rwm' entry.  So there should be no confusion
> > over why the dd succeeds.  You didn't remove the entry, because there
> > was no match echoed into devices.deny.
> 
> 
> No, you'll see the entry has been changed to 'a *:* m', so I think we
> should at least fix this.

Yikes.  Agreed.  That's a bug.

thanks,
-serge
