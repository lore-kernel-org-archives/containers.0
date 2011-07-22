From: Ben Boeckel <mathstuf@gmail.com>
Subject: Re: new cg-manager gui tool for managin cgroups
Date: Fri, 22 Jul 2011 01:38:59 +0000 (UTC)
Message-ID: <j0akbj$a1k$1@dough.gmane.org>
References: <20110720192029.GD2482@redhat.com>
	<20110720202831.GA11395@tango.0pointer.de>
	<20110721142053.GA2454@redhat.com>
	<1311268987.6273.18.camel@vespa.frost.loc>
Reply-To: Development discussions related to Fedora
	<devel@lists.fedoraproject.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@lists.fedoraproject.org>
List-Unsubscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=unsubscribe>
List-Archive: <http://lists.fedoraproject.org/pipermail/devel>
List-Post: <mailto:devel@lists.fedoraproject.org>
List-Help: <mailto:devel-request@lists.fedoraproject.org?subject=help>
List-Subscribe: <https://admin.fedoraproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@lists.fedoraproject.org?subject=subscribe>
Sender: devel-bounces@lists.fedoraproject.org
Errors-To: devel-bounces@lists.fedoraproject.org
To: devel@lists.fedoraproject.org
Cc: containers@lists.osdl.org
List-Id: containers.vger.kernel.org

In gmane.linux.redhat.fedora.devel Tomas Mraz <tmraz@redhat.com> wrote:
>> Right, as Dan Walsh, mentioned I need to separate this into two parts -
>> the front end UI and a backend communicating via DBUS. This is had been
>> a todo item.
> 
> Note that in case the services that the backend provides for the GUI are
> really powerful there is no real security benefit in separating the GUI
> and backend. 

Not to mention that if, say KDE wants a GUI for it, or XFCE, or an
ncurses app pops up, being able to reuse the DBUS interface for doing
the actual work will make things a lot easier.

--Ben

-- 
devel mailing list
devel@lists.fedoraproject.org
https://admin.fedoraproject.org/mailman/listinfo/devel
