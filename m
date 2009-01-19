From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: nsgroup autoremoving
Date: Mon, 19 Jan 2009 12:05:33 +0900
Message-ID: <20090119120533.bfc2c804.kamezawa.hiroyu@jp.fujitsu.com>
References: <49706006.80002@free.fr> <20090116165217.GA8477@us.ibm.com>
	<4973A0AD.6090508@free.fr> <20090118233216.GA10126@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090118233216.GA10126-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, 18 Jan 2009 17:32:16 -0600
"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> > Serge E. Hallyn wrote:
> >> Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> >>   
> >>> Hi,
> >>>
> >>> While trying to unshare a namespace with the clone syscall with an  
> >>> inifinite loop, I got an EEXIST.
> >>> That looks weird to have such syscall returning EEXIST ... :)
> >>>
> >>> After investigating, it appears the ns_cgroup creates automatically a 
> >>> control group named with the pid number when we call the clone 
> >>> syscall with a namespace parameter and when the namespace exits, the 
> >>> control group is not automatically removed. So when the pid numbers 
> >>> are recycled we conflict with a previous ns_cgroup name and the clone 
> >>> fails.
> >>>
> >>> IMHO, if the nsgroup is automatically created, it should 
> >>> automatically destroyed, otherwise what will happen to application 
> >>> using the namespaces (eg. mount namespace) wrote before nsgroup 
> >>> appeared ?
> >>>     
> >>
> >> but you can have it automatically destroyed.  I.e. I did the
> >> following:
> >>
> >> mount -t cgroup -o freezer,ns freezer /cgroup
> >> cat > /bin/release_cgroup.sh << EOF
> >> #!/bin/sh
> >> echo "Removing dead cgroup .$*." >> /var/log/cgroup
> >> rmdir /cgroup/$* >> /var/log/cgroup 2>&1
> >> echo "return value was $?" >> /var/log/cgroup
> >> EOF
> >> echo /bin/release_cgroup.sh > /cgroup/release_agent
> >> echo 1 > /cgroup/notify_on_release
> >> chmod ugo+x /bin/release_cgroup.sh
> >> ns_exec -m /bin/sh
> >> ls /cgroup`
> >> 	3581  notify_on_release  release_agent  tasks
> >> exit
> >> ls /cgroup
> >> 	notify_on_release  release_agent  tasks
> >>   
> > Assuming you mount with all the subsystems, this script will destroy the  
> > non-nsgroup too. Each time I create a control group manually, I have to  
> > unset the notify_on_release, right ?
> 
> I assume notify_on_release is per-hierarchy.  So you're just asking
> about manually created cgroups in a hierarchy which has ns mounted,
> right?
> 
> I suppose you could use a naming convention and do some name
> checking in the release_agent to not delete manually created
> ones.
> 
> Would that be too much of a hassle?
> 
> Maybe you're right.  Maybe we should tag auto-created cgroups,
> and auto-remove them.

I think auto-remove is more useful.

>  It's more convenient for me that way...
> Paul, would you have any objections?  Daniel do you have a patch
> written?
> 

Just a notice:
When the memory subsystem is mounted, notify_on_release will not work as you
expected. Because refcnts from pages still exits.

But you will be able to do rmdir() in many case because of pre_destroy()
handler. (so, the directroy is releasable.)
I'd like to fix this. But now, it doesn't work for memory subsys.

Thanks,
-Kame
