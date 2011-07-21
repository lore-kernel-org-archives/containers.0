From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Thu, 21 Jul 2011 16:30:58 +0100
Message-ID: <20110721153058.GN17632@redhat.com>
References: <20110720192029.GD2482@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110720192029.GD2482-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Development discussions related to Fedora <devel-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org>
Cc: fedora-devel-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, duffy-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cg-manager-developers-TuqUDEhatI7GMZAyRF5v151Ccm5ICvs9@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Jul 20, 2011 at 03:20:30PM -0400, Jason Baron wrote:
> However, I think we need to discuss how we envision cgroup configuration
> working longer term. The current consumers out of the box, that I'm aware of
> are libvirt and systemd. Currently, these consumers manage cgroups as they see
> fit. However, since they are managing shared resources, I think there probably
> is an argument to be made that its useful, to have some sort of global view
> of things, to understand how resources are being allocated, and thus a global
> way of configuring cgroups (as opposed to each new consumer doing its own
> thing).

One thing I should mention is that it is an explicit design goal of
libvirt, that the concept of "cgroups" is not exposed to users of
the libvirt API. This is because the libvirt goal is to provide an
API / XML format that is independent of the specific implementation
that a hypervisor uses. Cgroups is an implementation detail of the
libvirt KVM & LXC drivers. The libvirt VMWare, Hyper-V, VirtualBox
drivers use completely different mechanisms to provide resource
controls. Thus the guest resource controls are expressed with a
common vocabularly, which is then internally translated to changes
in cgroups  or some other mechanism as appropriate for the driver.

Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
