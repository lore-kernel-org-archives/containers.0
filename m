From: Vasily Averin <vvs-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: question about default values for per-namespace settings
Date: Tue, 24 Jun 2014 12:21:05 +0400
Message-ID: <53A934F1.7040906@parallels.com>
References: <20140512140706.GA22082@macbook.localnet>
	<cover.1399909529.git.vvs@openvz.org>
	<5370F781.7010909@parallels.com> <53711B21.1060309@pandora.be>
	<53712B0A.7060007@parallels.com> <53727246.4050306@pandora.be>
	<53748280.60906@parallels.com> <537A5BD1.90906@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <537A5BD1.90906-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, =?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <zenczykowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 05/19/2014 11:30 PM, Bart De Schuymer wrote:
> As pointed out by Maciej, always
> starting from init_net isn't really an option in case of nested
> namespaces (start from the parent's namespace instead).

Dear Bart, Serge, Maciej
thank you very much for your feedback!

I've analyzed possibility to inherit settings from parent net-namespace,
discovered problems described below and finally decided to follow
Maciej's way (a) "use some kernel defaults", with adding an ability
to change pre-compiled kernel defaults.

Below you can found more detailed description of discovered problems.

1) there are no (easy) ways to find parent of given network namespace.

Network namespaces in kernel are not hierarchical but flat,
"struct net" have no reference to parent netns, and my collegians expect
that Eric Biederman will likely object to adding a parent netns pointer.

Without this reference I do not see any good ways to copy parents settings.

2) settings inheriting does not work if subsystem module is loaded after
creation of network namespace. 

In this case all namespaces get pre-compiled defaults settings, and seems
there are no ways to apply "adjusted" setting to all already existing netns.

Moreover there is curious situation: to apply required sysctl settings
during module loading, Red Hat recommends to force "sysctl -p" execution
via install command in modprobe.conf
https://bugzilla.redhat.com/show_bug.cgi?id=634735#c7

However if module is loaded from inside one of network namespaces
it does not work!

In this case sysctl is executed inside netns. 
If assigned sysctl key is not virtualized -- sysctl command can fail
if key is virtualized  -- setting  in current netns  will be adjusted,
but not -- in init_net, that looks unexpected for me.

I believe initial subsystem settings of newly created namespace should
not differ from initial settings of newly created subsystem in already
existing namespace. In case in-kernel setting inheriting this behavior
cannot be reached, additional subsystem tuning is required anyway.

Therefore Maceiej's variant (a) "use some kernel defaults" looks like
right choice for me. If parent wants to assign some adjusted settings
in child environments -- it can only force loading of required modules
and apply required settings directly.

At the same time I would like to have an ability to change pre-compiled
defaults somehow. In my patch I'm going to add new module options, that
allows node owner to specify wished "safe" settings before module loading,
and change them via sysfs after this.
