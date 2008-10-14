From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Building a SECURE cointainer using Cgroups ?
Date: Tue, 14 Oct 2008 09:53:39 +0100
Message-ID: <20081014085339.GA10745@redhat.com>
References: <0A97A441BFADC74EA1E299A79C69DF9212D3F6C9E2@orsmsx504.amr.corp.intel.com>
	<1223920496.29877.22.camel@nimitz>
	<0A97A441BFADC74EA1E299A79C69DF9212D3F6CA1B@orsmsx504.amr.corp.intel.com>
	<1223922341.29877.29.camel@nimitz>
	<20081013192921.GA10814@us.ibm.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081013192921.GA10814-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Tanaka,
	Thomas" <thomas.tanaka-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Oct 13, 2008 at 02:29:21PM -0500, Serge E. Hallyn wrote:
> Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> > On Mon, 2008-10-13 at 11:01 -0700, Tanaka, Thomas wrote:
> > > Yes absolutely that is what I am trying to achieve.
> > 
> > I'm going to put on my Serge hat and bet that you can do it with
> > security modules. :)
> 
> Right, your goal is still not very precise, but a security module -
> smack or selinux - might be your best bet.
> 
> > There's nothing that cgroups or containers gives you that will help with
> > your problem.  We actually haven't touched the fs namespaces at all, yet
> > because they work great as they stand today.
> 
> No, but there is the device whitelist cgroup and capability bounding
> sets - perhaps that is what he is asking about?
> 
> If you have a normal chroot - or a container created with
> clone(CLONE_NEWNS) followed by pivot_root into a completely isolated
> file system tree (say, created using debootstrap), then a root user in
> that pivot_root can simply mount /dev/hda1 /mnt and chroot back into
> that.
> 
> So to make the above a little more secure, you can
> 
> 	1. restrict the container's device whitelist so that it can't
> 	   create or use the devices representing the hard drive.

We follow this appraoch & use the device whitelist capability in libvirt's
LXC driver now for exactly this purpose. Works quite nicely really. There
are still some other holes like a private dev-pts but those are in progress

Daniel
-- 
|: Red Hat, Engineering, London   -o-   http://people.redhat.com/berrange/ :|
|: http://libvirt.org  -o-  http://virt-manager.org  -o-  http://ovirt.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: GnuPG: 7D3B9505  -o-  F3C9 553F A1DA 4AC2 5648 23C1 B3DF F742 7D3B 9505 :|
