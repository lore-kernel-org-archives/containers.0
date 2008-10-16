From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: lxc userspace tools 0.3.0 released
Date: Thu, 16 Oct 2008 14:30:07 +0100
Message-ID: <20081016133006.GQ27881@redhat.com>
References: <48F4AF2E.3000204@fr.ibm.com>
	<7fac565a0810160122n7afa6e71l929be8cb08ba05c6@mail.gmail.com>
	<48F70E53.9070002@fr.ibm.com> <48F739BB.4070201@fr.ibm.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48F739BB.4070201-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Oct 16, 2008 at 02:55:23PM +0200, Cedric Le Goater wrote:
> > Just to clarify to avoid confusion. There is a LXC project inside the 
> > libvirt and there is the lxc userspace tools (liblxc). We are talking 
> > about the liblxc.
> 
> I wouldn't say there is a "LXC project inside the libvirt" but rather
> there is a libvirt driver emulating a virtual machine using namespaces.
> This driver is called lxc for some reason I don't know and this is very 
> unfortunate IMO.

It is called LXC because it implements "LinuX Containers". When we first
released this LXC driver in libvirt this lxc userspace tools package didn't
exist so there was no naming clash.

Daniel
-- 
|: Red Hat, Engineering, London   -o-   http://people.redhat.com/berrange/ :|
|: http://libvirt.org  -o-  http://virt-manager.org  -o-  http://ovirt.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: GnuPG: 7D3B9505  -o-  F3C9 553F A1DA 4AC2 5648 23C1 B3DF F742 7D3B 9505 :|
