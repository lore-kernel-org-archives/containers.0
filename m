From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC PATCH 1/2] devices cgroup: allow can_attach() if ns_capable
Date: Tue, 5 Nov 2013 07:06:59 +0900
Message-ID: <20131104220659.GB24165@mtj.dyndns.org>
References: <20130723181606.GA6342@sergelap>
	<20130723183018.GF21100@mtj.dyndns.org> <20130723183841.GA9021@tp>
	<CAOS58YPynQ-QBx5nZEnYrP5kGTVvv9VAj0cV0aYeikTitvTQbA@mail.gmail.com>
	<20130723190426.GA9577@tp> <20130723191245.GI21100@mtj.dyndns.org>
	<20130723192801.GA9923@tp>
	<CAOS58YPEKtEiZWsn-8u6OPr-UsyQp=XR+ecGmXyOdT0JnYAmsA@mail.gmail.com>
	<20131104215135.GA26190@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131104215135.GA26190-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Mon, Nov 04, 2013 at 09:51:35PM +0000, Serge E. Hallyn wrote:
> Do you have a list of such issues which you see with delegation?  That is,
> cases where, if ownership of a subtree is granted to a non-root user,
> that user can affect tasks owned by other users who are in other
> cgroups?

A lot of security is about logistics and cgroup simply doesn't have
them - depth, number of cgroups quota, even config changes or
subdirectory operations which involve RCU operations can easily be
used for DoS attacks.  Just think about how much complexity and effort
need to be spent on making and maintaining anything properly
delegatable to !priv users.  cgroup has never spent such design or
implementation effort - e.g. take a look at how event_control thing is
implemented, it's extremely easy to trigger OOM if you give that out
to !priv users.

cgroup has *never* been safe to give out to !priv users and it is
highly unlikely to be in any foreseeable future.  It will be a big new
giant feature which I frankly don't think is worth the risk or effort.
Think of it as giving out sysctl or firewall rule control to !priv
users.  Giving out subset of those controls do make sense in terms of
function but we don't do that and don't have infrastructure to support
such usage.  cgroup at this stage isn't that different.  If you insist
on doing that, you can but it is severely compromising in terms of
security and it'll stay that way for the foreseeable future.

Thanks.

-- 
tejun
