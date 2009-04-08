From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: lxc configuration help - only network isolated?
Date: Wed, 8 Apr 2009 17:44:54 -0500
Message-ID: <20090408224454.GA16834@us.ibm.com>
References: <638f07d70904081538x6a132466xd0607466487e106e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <638f07d70904081538x6a132466xd0607466487e106e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Elwin Stelzer Eliazer <stelzere-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

It's safe.  So long as your applications don't get messed up with
some namespaces isolated and some not, at least.

-serge

Quoting Elwin Stelzer Eliazer (stelzere-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> Removing CLONE_NEWIPC from clone_flags and the hack suggested below,
> can this be assumed to be a safe feature, or is it only suggested for
> testing?
> I have a similar requirement like having network only isolation.
> 
> regards,
> Elwin.
> 
> 
> 
> 
> Chris R. Jones wrote:
> >* I have a couple of basic configuration questions on linux containers.  I'm using lxc-0.6.1.
> *>*
> *>* I'm trying to configure a setup where I have two containers, where
> the only virtualized/isolated resources are network resources, but I
> can still do IPC between processes in the two containers.
> *>*
> *>* The lxc.conf man page indicates that, "by default, the pids, sysv
> ipc, and mount points are virtualized and isolated. "
> *>*
> *>* Is there a way in the configuration to specify that those
> resources should NOT be isolated?  I'd really like to have
> communication between two processes running in different containers
> using sysV IPC and signals.  The only thing I really want to be
> isolated are two different network namespaces.
> *>*
> *>* Is there a setting I use in the lxc.conf file to accomplish this?
> *>*
> *>*
> *I thought no one would be interested by less isolation :)
> 
> I see you want to share the signals, that means no pid namespace, right ?
> 
> The design of the lxc is build around the pid namespace, if you kill the
> first process of the pid namespace, you kill all the process of the
> container. That allows to implement the 'lxc-stop' command.
> 
> So no pid namespace, no container :)
> >* Up to now, I've been doing some prototyping using lxc-unshare -n, but that doesn't really create a container, correct?  That mostly accomplishes my goals, but I can't find a way to spawn new processes into that same namespace.  Is there a way, without defining a container?
> *>*
> *
> No, except writing a forker and launch it inside the container and have
> a command outside to tell the forker to spawn a specific program.
> Dietmar Maurer is working on such component to be integrated in lxc.
> >* Any recommendations on how to properly configure a containers to allow IPC between processes in two different containers while still isolating the network resources?
> *>*
> *
> If you want to share the ipc to do some testing, you can hack the
> lxc_start function in start.c and remove the ipc cloning flag.
> 
> - clone_flags = CLONE_NEWPID|CLONE_NEWIPC|CLONE_NEWNS;
> +clone_flags = CLONE_NEWPID|CLONE_NEWNS;
> 
> I hope that helps.
> 
>   -- Daniel
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
