From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC] Per-user namespace process accounting
Date: Thu, 29 May 2014 03:06:31 -0700
Message-ID: <87tx88nbko.fsf@x220.int.ebiederm.org>
References: <5386D58D.2080809@1h.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5386D58D.2080809-108MBtLGafw@public.gmane.org> (Marian Marinov's message of "Thu, 29
	May 2014 09:37:01 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Marian Marinov <mm-108MBtLGafw@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LXC development mailing-list <lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org>
List-Id: containers.vger.kernel.org

Marian Marinov <mm-108MBtLGafw@public.gmane.org> writes:

> Hello,
>
> I have the following proposition.
>
> Number of currently running processes is accounted at the root user namespace. The problem I'm facing is that multiple
> containers in different user namespaces share the process counters.

That is deliberate.

> So if containerX runs 100 with UID 99, containerY should have NPROC limit of above 100 in order to execute any
> processes with ist own UID 99.
>
> I know that some of you will tell me that I should not provision all of my containers with the same UID/GID maps, but
> this brings another problem.
>
> We are provisioning the containers from a template. The template has a lot of files 500k and more. And chowning these
> causes a lot of I/O and also slows down provisioning considerably.
>
> The other problem is that when we migrate one container from one host machine to another the IDs may be already in use
> on the new machine and we need to chown all the files again.

You should have the same uid allocations for all machines in your fleet
as much as possible.   That has been true ever since NFS was invented
and is not new here.  You can avoid the cost of chowning if you untar
your files inside of your user namespace.  You can have different maps
per machine if you are crazy enough to do that.  You can even have
shared uids that you use to share files between containers as long as
none of those files is setuid.  And map those shared files to some kind
of nobody user in your user namespace.

> Finally if we use different UID/GID maps we can not do live migration to another node because the UIDs may be already
> in use.
>
> So I'm proposing one hack modifying unshare_userns() to allocate new user_struct for the cred that is created for the
> first task creating the user_ns and free it in exit_creds().

I do not like the idea of having user_structs be per user namespace, and
deliberately made the code not work that way.

> Can you please comment on that?

I have been pondering having some recursive resources limits that are
per user namespace and if all you are worried about are process counts
that might work.  I don't honestly know what makes sense at the moment.

Eric
