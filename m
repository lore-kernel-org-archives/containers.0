From: Lennart Poettering <mzerqung-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Thu, 21 Jul 2011 19:55:00 +0200
Message-ID: <20110721175500.GA14575@tango.0pointer.de>
References: <20110720192029.GD2482@redhat.com>
	<20110720202831.GA11395@tango.0pointer.de>
	<20110721142053.GA2454@redhat.com>
	<1311268987.6273.18.camel@vespa.frost.loc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1311268987.6273.18.camel-ToA8MW0H8sPg+ylLNZCgDw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tomas Mraz <tmraz-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Development discussions related to Fedora <devel-TuqUDEhatI4ANWPb/1PvSmm0pvjS0E/A@public.gmane.org>, fedora-devel-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cg-manager-developers-TuqUDEhatI7GMZAyRF5v151Ccm5ICvs9@public.gmane.org, dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, duffy-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 21.07.11 19:23, Tomas Mraz (tmraz-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org) wrote:

> 
> On Thu, 2011-07-21 at 10:20 -0400, Jason Baron wrote: 
> > Hi,
> > 
> > On Wed, Jul 20, 2011 at 10:28:32PM +0200, Lennart Poettering wrote:
> > > On Wed, 20.07.11 15:20, Jason Baron (jbaron-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org) wrote:
> > > 
> > > Heya,
> > > 
> > > > The memory and cpu share controllers are currently supported (I simply haven't
> > > > gotten to supporting other controllers yet). One can add/delete cgroups, change
> > > > configuration parameters, and see which processes are currently associated
> > > > with each cgroup. There is also a 'usage' view, which displays graphically the
> > > > real-time usage statistics. The cgroup configuration can then be saved
> > > > into /etc/cgconfig.conf using the 'save' menubar button.
> > > 
> > > How does it write that file? Does the UI run as root? That's not really
> > > desirable. It's not secure and it is cumbersome to mix applications
> > > running as differnt users on the same session and one the same X
> > > screen (since they cannot communicate with dbus, and so on).
> > 
> > Right, as Dan Walsh, mentioned I need to separate this into two parts -
> > the front end UI and a backend communicating via DBUS. This is had been
> > a todo item.
> 
> Note that in case the services that the backend provides for the GUI are
> really powerful there is no real security benefit in separating the GUI
> and backend. 
> 
> I am not sure that a cgroup manager would be such case though.
> 
> For example if the backend service is "interface to enable and configure
> various network based authentication services" as it would be in case of
> authconfig if it was split into GUI and backend, then you can easily
> instruct the backend to authenticate against a network service that will
> give you root user with no password. So we would have to trust the user
> X session that is the authconfig frontend running in anyway.

There's quite a substantial security benefit here. If you use stuff like
PK you can ensure that UIs only ask for and get very specific privileges
when interacting with the mechanism. That means even if you cannot trust
your UI it will be able to do very few bad things only. If you entire UI
runs as roo however, it can do pretty much everything it wants.

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
