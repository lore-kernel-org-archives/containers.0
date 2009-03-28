From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: lxc configuration help - only network isolated?
Date: Fri, 27 Mar 2009 20:27:45 -0700
Message-ID: <20090328032745.GE27803@us.ibm.com>
References: <20090326224541.GA25769@versecorp.net> <49CC9262.40302@free.fr>
	<20090327130859.GA9643@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090327130859.GA9643-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 27, 2009 at 08:08:59AM -0500, Serge E. Hallyn wrote:
> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> > Chris R. Jones wrote:
> > > I have a couple of basic configuration questions on linux containers.  I'm using lxc-0.6.1.
> > >
> > > I'm trying to configure a setup where I have two containers, where the only virtualized/isolated resources are network resources, but I can still do IPC between processes in the two containers.
> > >
> > > The lxc.conf man page indicates that, "by default, the pids, sysv ipc, and mount points are virtualized and isolated. "
> > >
> > > Is there a way in the configuration to specify that those resources should NOT be isolated?  I'd really like to have communication between two processes running in different containers using sysV IPC and signals.  The only thing I really want to be isolated are two different network namespaces.
> > >
> > > Is there a setting I use in the lxc.conf file to accomplish this?
> > >
> > >   
> > I thought no one would be interested by less isolation :)
> > 
> > I see you want to share the signals, that means no pid namespace, right ?
> > 
> > The design of the lxc is build around the pid namespace, if you kill the 
> > first process of the pid namespace, you kill all the process of the 
> > container. That allows to implement the 'lxc-stop' command.
> > 
> > So no pid namespace, no container :)
> 
> There has been discussion before about having a 'kill' or 'signal'
> cgroup, analogous to the freezer, for sending signals to all tasks
> in a cgroup.  We could push that, and have lxc-stop optionally use
> that.
> 
> If there were interest.

I've got some ancient patches for that! :) I think we'd want to
use Paul Menage's recent empty hierarchy, multiply-bound, and stateless
subsystem patches for a signal subsystem. In fact, it may be such a
simple task that using the old patches would be more of a hindrance...

Cheers,
	-Matt Helsley
