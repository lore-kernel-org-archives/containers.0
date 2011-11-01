From: Toerless Eckert <Toerless.Eckert-vrlraubKdiR4tiELkoLHDcSSVFg4/55HhC4ANOJQIlc@public.gmane.org>
Subject: Re: LXC L3 network isolation, yes/no ?, how ?
Date: Tue, 1 Nov 2011 16:26:24 +0100
Message-ID: <20111101152624.GB14734@faui40p.informatik.uni-erlangen.de>
References: <20111101021230.GE15906@faui40p.informatik.uni-erlangen.de>
	<m1r51swmun.fsf@fess.ebiederm.org>
	<20111101043201.GA14734@faui40p.informatik.uni-erlangen.de>
	<m1lis0vxu6.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1lis0vxu6.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Toerless Eckert <Toerless.Eckert-vrlraubKdiR4tiELkoLHDcSSVFg4/55HhC4ANOJQIlc@public.gmane.org>
List-Id: containers.vger.kernel.org

THanks for replying,

Sorry for asking what probably are a lot of naive questions, my excuse is
that the documentation is somewhat scattered/incomplete ? ;-))

I am trying to figure out how to minimize the virtualization to just the network
name space and instantiate it in a lightweight fashion that can easily
be counterfitted into some existing system. 

What i would like to have is some simple program like "run-ns XXXX <program> <args>"
that would run program <args> within namespace XXXX.

So i was looking for some system call like set_ns(XXXX), but it seems there
is no API like that. Instead i guess i would need to have a "server" process
with pid XXXX that does an unshare(CLONE_NEWNS) and then listens for requests
to fork client programs, and run-ns would need to send a request to that XXXX
process to fork off <program> <args> and make sure that it can transfer all
the pre-existing context of run-ns like pid/gid(s), cwd, environment, and i don't
even know all the other context a linux process has these days. And then of course
communicate exit status of <program> back from XXXX to run-ns.

Meaning: it's great to have something like network name spaces, but without
some setns(XXXX) system call, it's really difficult to use these network name
spaces outside of a concept like LXC - which is a shame, because otherwise
the nework name space woudl exactly be what i am looking for.

I guess i will have to look how much of an isolated network behvior i can
get by using fwmark's. Alas, there is no process-level fwmark context, but
it has to be set via setsockopt(SO_MARK) AFAIK, so one would need some
LD_PRELOAD library or the like to use it.

*sigh* ;-))

Cheers
    Toerless

On Tue, Nov 01, 2011 at 05:20:01AM -0700, Eric W. Biederman wrote:
> Toerless Eckert <Toerless.Eckert-vrlraubKdiR4tiELkoLHDcSSVFg4/55HhC4ANOJQIlc@public.gmane.org> writes:
> 
> > Thanks, Eric
> >
> > How do i configure eg: an LXC container to use a specific network name space XXXX ?
> >
> > Also: if an app within some LXC container does a socket() and then a 
> > bind(..INADDR_ANY...) how does the kernel know which subset of IP interfaces
> > it should bind to ? does the process context have a network name space
> > ?
> 
> The network namespace.
> 
> > And how do i create per namespace routing tables ?
> 
> Just like nomral.  From inside the network namespace you setup your
> routing tables.
> 
> > Example or pointer to docs would be great. or just walk me through the rough
> > outline of my use case...:
> >
> >   - create container e0procs, configure just the physical eth0 interface into it ??
> >     - without assigning an IP address ?
> >     - run a dhcp daemon from withing container e0proces and that
> >       will correctly get ip address/mask and default route configured in a
> >       routing table solely used by container e0procs ?
> >     - container e0procs DHCPd will also populate containerized /etc/resolv.conf with
> >       eth0 domain prefix/DNS-servers...
> >
> >   - same approach for container c1procs, confgiure phys eth1 interface into it,
> >     start DHCP daemon inside container inside it, get routing table and dNS
> >     for container c1procs from it.
> >
> > Is that it ? Of not, then how. If yes, then what type of routing table would
> > i actually see outside of the containers ? And back to the original question,
> > would socket(), bind(INADDR_ANY) from inside the containers work correctly ?
> 
> 
> Yes.  bind(INADDR_ANY) works correctly inside a network namespace.
> 
> A network namespace is from an application perspective like having a
> separate copy of the networking stack.  
> 
> Eric
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
