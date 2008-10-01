From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 18:54:45 +0400
Message-ID: <1222872885.23573.64.camel__12609.7604552799$1222873586$gmane$org@iris.sw.ru>
References: <1222858454-7843-1-git-send-email-den@openvz.org>
	<48E35B4C.1040303@fr.ibm.com> <1222860776.23573.49.camel@iris.sw.ru>
	<48E3653C.1070701@fr.ibm.com> <1222862583.23573.54.camel@iris.sw.ru>
	<48E36ABF.8030908@fr.ibm.com> <48E36BFA.3040904@openvz.org>
	<48E36DA0.9080400@fr.ibm.com> <1222866717.23573.58.camel@iris.sw.ru>
	<48E37F1B.20601@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48E37F1B.20601-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2008-10-01 at 15:46 +0200, Daniel Lezcano wrote:
> Denis V. Lunev wrote:
> > On Wed, 2008-10-01 at 14:31 +0200, Daniel Lezcano wrote:
> >> Pavel Emelyanov wrote:
> >>>> So there are 2 cases:
> >>>>   * full isolation : restriction on VPS
> >>>>   * partial isolation : no restriction but *perhaps* problem when migrating
> >>>>
> >>>> Looks like we need an option per namespace to reduce the isolation for 
> >>>> af_unix sockets :)
> >>>>   - on (default): current behaviour => full isolation
> >>>>   - off : partial isolation
> >>> You mean some sysctl, that enables/disables this check in unix_find_socket_byinode?
> >> Yes.
> > 
> > I do not see much sense with sysctl as:
> > - check (cross-connected sockets) is required as we can start namespace
> >   with already opened socket
> 
> Check when checkpointing ? If you inherit a socket from your parent 
> namespace, this socket belongs to your parent and you should not 
> checkpoint it, no ?
> 
> In case you allow cross-connected sockets, this check is mandatory I agree.
> 
> > - this kind of sharing is not implicit but explicit as normal isolated
> >   containers _must_ have separate filesystems. In this case this
> >   sharing requires explicit host administrator action to link socket
> >   between containers
> 
> What are "normal isolated containers" ? Are they OpenVZ containers ? 
> These containers belong to the system containers family. What happens 
> with application containers, if I want to share the filesystem without 
> breaking the isolation of the afunix sockets ?

then you are doomed as you will have a FIFO opened from 2 namespaces and
checking the absences of external references is still mandatory

> The current code provides full isolation and this is in mainline. I 
> don't think it is reasonable to change that. What I propose is to keep 
> the current behaviour.
> 
> When you create a network namespace, you can change the behaviour inside 
> this namespace via /proc/sys/net/unix/isolated (for example).
> 
> This option allows:
> 1 - to connect to af_unix not belonging to the container
> 2 - to accept af_unix connection from outside the container (avoid a 
> container to forbid the checkpoint of another container);

this should be at least per/namespace option controlled from parent
container from my POW
