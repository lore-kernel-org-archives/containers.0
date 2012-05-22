From: Amos Kong <akong-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix device deny of DEV_ALL
Date: Tue, 22 May 2012 10:23:11 +0800
Message-ID: <4FBAF88F.1040103__9235.44644979319$1337653415$gmane$org@redhat.com>
References: <CAFeW=pZ8Y7ycxjxro7zBMqdtaCOYs4RmoxtDrsN8+mqLhOL--g@mail.gmail.com>
	<20120518081912.16779.21065.stgit@t>
	<20120521140324.GA5091@sergelap> <4FBADF1A.6040303@huawei.com>
	<20120522015426.GA10344@mail.hallyn.com>
	<20120522020857.GA10499@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120522020857.GA10499-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mtosatti-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 22/05/12 10:08, Serge E. Hallyn wrote:
> At line 135, there is
>
> if (walk->type == DEV_ALL)
> 	goto remove;
>
> I wonder if that was meant to be 'if (wh->type == DEV_ALL)'.  That
> seems to fit better with what I would have meant to have happen.
> But it's already handled by line 342.  So I think deleting lines
> 135-136 might be best.  What do you think?

Hi Serge,

If we expect nothing changed ('a *:* rwm' doesn't change),
delete 135-136 will be ok.

But I have explained my patch in another email, I also think
it's unnecessary to remove 'a *:* rwm' before executing:
  @ echo 'b 253:3 rw'>  devices.deny

-- 
			Amos.
