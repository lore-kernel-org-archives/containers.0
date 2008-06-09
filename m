From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Userspace checkpoint/restart hack: cryo
Date: Mon, 9 Jun 2008 08:04:29 -0500
Message-ID: <20080609130429.GA16297@us.ibm.com>
References: <1209144259.12718.46.camel@nimitz.home.sr71.net>
	<48159D1D.3050302@fr.ibm.com> <481735A6.8070800@bull.net>
	<48173CE1.7050503@fr.ibm.com> <481ECA42.5060603@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <481ECA42.5060603-6ktuUTfB/bM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nadia Derbey (Nadia.Derbey-6ktuUTfB/bM@public.gmane.org):
> Cedric Le Goater wrote:
> >  
> > 
> >>Looks like it has worked for me (msg1 creates 1000 msg queues, sleeps
> >>for a while and then removes the msg queues).
> > 
> > 
> > cool. which kernel are you using ? 
> > 
> > C.
> > 
> > 
> 
> 2.6.25-mm1 (sorry for the late answer - plenty of days off in France in 
> May).
> 
> Regards,
> Nadia

I'm playing with features in cryo, and keeping a git tree at:

git://git.sr71.net/~hallyn/cryodev.git

It's meant to exploit the extras which are in the -lxc kernel at
lxc.sf.net.  Current latest kernel patch is at
http://lxc.sourceforge.net/patches/2.6.26/2.6.26-rc2-mm1-lxc4/ This -lxc
tree contains, for instance, Nadia's next_id patches, exploitation for
setting ids for sysvipc and for tasks at fork, and updated ipc_setall
patches (also using next_id).  The version of cryo in my git tree
exploits these.  If you're root when you restart a task, it will clone a
new set of namespaces and recreate your sysvipc objects, and it will
reset your pids (even if you're not root if the pids are available).

Cryo is still rather touchy - I'm trying to track this down.  Older
distros seem to actually have the most success (I'm told FC6 is somewhat
useful, while my FC8 kvm image is practically useless with cryo).

So if you want to play with it, please clone and do so, and send me any
patches you think should go in.

thanks,
-serge
