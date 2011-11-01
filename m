From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: LXC L3 network isolation, yes/no ?, how ?
Date: Tue, 01 Nov 2011 05:20:01 -0700
Message-ID: <m1lis0vxu6.fsf@fess.ebiederm.org>
References: <20111101021230.GE15906@faui40p.informatik.uni-erlangen.de>
	<m1r51swmun.fsf@fess.ebiederm.org>
	<20111101043201.GA14734@faui40p.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111101043201.GA14734-+4JsuViRYHWM0MU9lROt9PpTrGXM5HoexJJUWDj/nkeELgA04lAiVw@public.gmane.org>
	(Toerless Eckert's message of "Tue, 1 Nov 2011 05:32:01 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Toerless Eckert <Toerless.Eckert-vrlraubKdiR4tiELkoLHDcSSVFg4/55HhC4ANOJQIlc@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Toerless Eckert <Toerless.Eckert-vrlraubKdiR4tiELkoLHDcSSVFg4/55HhC4ANOJQIlc@public.gmane.org> writes:

> Thanks, Eric
>
> How do i configure eg: an LXC container to use a specific network name space XXXX ?
>
> Also: if an app within some LXC container does a socket() and then a 
> bind(..INADDR_ANY...) how does the kernel know which subset of IP interfaces
> it should bind to ? does the process context have a network name space
> ?

The network namespace.

> And how do i create per namespace routing tables ?

Just like nomral.  From inside the network namespace you setup your
routing tables.

> Example or pointer to docs would be great. or just walk me through the rough
> outline of my use case...:
>
>   - create container e0procs, configure just the physical eth0 interface into it ??
>     - without assigning an IP address ?
>     - run a dhcp daemon from withing container e0proces and that
>       will correctly get ip address/mask and default route configured in a
>       routing table solely used by container e0procs ?
>     - container e0procs DHCPd will also populate containerized /etc/resolv.conf with
>       eth0 domain prefix/DNS-servers...
>
>   - same approach for container c1procs, confgiure phys eth1 interface into it,
>     start DHCP daemon inside container inside it, get routing table and dNS
>     for container c1procs from it.
>
> Is that it ? Of not, then how. If yes, then what type of routing table would
> i actually see outside of the containers ? And back to the original question,
> would socket(), bind(INADDR_ANY) from inside the containers work correctly ?


Yes.  bind(INADDR_ANY) works correctly inside a network namespace.

A network namespace is from an application perspective like having a
separate copy of the networking stack.  

Eric
