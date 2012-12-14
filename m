From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] core_pattern: set core helpers root and namespace to
	crashing process
Date: Fri, 14 Dec 2012 09:04:18 +0000
Message-ID: <20121214090418.GA6044@redhat.com>
References: <1355255996-25953-1-git-send-email-nhorman@tuxdriver.com>
	<20121213122048.GF5246@sergelap>
	<20121213181220.GB14796@hmsreliant.think-freely.org>
	<20121213142534.ea07a3c8.akpm@linux-foundation.org>
	<20121214024938.GA6591@neilslaptop.think-freely.org>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121214024938.GA6591-0o1r3XBGOEbbgkc5XkKeNuvMHUBZFtU3YPYVAmT7z5s@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Dec 13, 2012 at 09:49:39PM -0500, Neil Horman wrote:
> On Thu, Dec 13, 2012 at 02:25:34PM -0800, Andrew Morton wrote:
> > On Thu, 13 Dec 2012 13:12:20 -0500
> > Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> > 
> > > On Thu, Dec 13, 2012 at 06:20:48AM -0600, Serge Hallyn wrote:
> > > > Quoting Neil Horman (nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org):
> > > > > Theres one problem I currently see with it, and that is that I'm not sure we can
> > > > > change the current behavior of how the root fs is set for the pipe reader, lest
> > > > > we break some user space expectations. As such, I've added a sysctl in this
> > > > > patch to allow administrators to globally select if a core reader specified via
> > > > > /proc/sys/kernel/core_pattern should use the global rootfs, or the (possibly)
> > > > > chrooted fs of the crashing process.
> > > > 
> > > > Practical question:  How is the admin to make an educated decision on
> > > > how to set the sysctl?
> > 
> > By reading the documentation which Neil didn't include?
> > 
> Yeah, that was stupid of me, I'll respin this with docs.
> 
> > > My thought was that the admin typically wouldn't touch this at all.  I really
> > > added it as a backwards compatibility option only.  Setting the user space
> > > helper task to the root of the crashing parent has the possibility of breaking
> > > existing installs because the core_pattern helper might be expecting global file
> > > system access.  Moving forward, my expectation would be that core_pattern
> > > helpers would be written with the default setting in mind, and we could
> > > eventually deprecate the control entirely.
> > > 
> > > If you have a better mechanism in mind however (or if you think that removing
> > > the control is a resaonable approach), I'm certainly open to that.
> > 
> > Yeah, this is a tiresome patch but I can't think of a better way.
> > 
> > Except, perhaps, adding a new token to the core_pattern which says
> > "switch namespaces"?
> >
> I like that idea, perhaps '||' instead of '|' as the leading token can indicate
> "use the namespace root" vs. "use the global root".  Thoughts?

That seems like a nicer idea to me, than the extra sysctl knob.

Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
