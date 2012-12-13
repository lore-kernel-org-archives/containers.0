From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] core_pattern: set core helpers root and namespace to
	crashing process
Date: Thu, 13 Dec 2012 13:12:20 -0500
Message-ID: <20121213181220.GB14796__48272.2567431212$1355422388$gmane$org@hmsreliant.think-freely.org>
References: <1355255996-25953-1-git-send-email-nhorman@tuxdriver.com>
	<20121213122048.GF5246@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121213122048.GF5246@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Dec 13, 2012 at 06:20:48AM -0600, Serge Hallyn wrote:
> Quoting Neil Horman (nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org):
> > Theres one problem I currently see with it, and that is that I'm not sure we can
> > change the current behavior of how the root fs is set for the pipe reader, lest
> > we break some user space expectations. As such, I've added a sysctl in this
> > patch to allow administrators to globally select if a core reader specified via
> > /proc/sys/kernel/core_pattern should use the global rootfs, or the (possibly)
> > chrooted fs of the crashing process.
> 
> Practical question:  How is the admin to make an educated decision on
> how to set the sysctl?
> 
My thought was that the admin typically wouldn't touch this at all.  I really
added it as a backwards compatibility option only.  Setting the user space
helper task to the root of the crashing parent has the possibility of breaking
existing installs because the core_pattern helper might be expecting global file
system access.  Moving forward, my expectation would be that core_pattern
helpers would be written with the default setting in mind, and we could
eventually deprecate the control entirely.

If you have a better mechanism in mind however (or if you think that removing
the control is a resaonable approach), I'm certainly open to that.

Neil

> -serge
> 
