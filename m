From: Toerless Eckert <Toerless.Eckert-vrlraubKdiR4tiELkoLHDcSSVFg4/55HhC4ANOJQIlc@public.gmane.org>
Subject: Re: LXC L3 network isolation, yes/no ?, how ?
Date: Tue, 1 Nov 2011 05:32:01 +0100
Message-ID: <20111101043201.GA14734@faui40p.informatik.uni-erlangen.de>
References: <20111101021230.GE15906@faui40p.informatik.uni-erlangen.de>
	<m1r51swmun.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1r51swmun.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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

Thanks, Eric

How do i configure eg: an LXC container to use a specific network name space XXXX ?

Also: if an app within some LXC container does a socket() and then a 
bind(..INADDR_ANY...) how does the kernel know which subset of IP interfaces
it should bind to ? does the process context have a network name space ?

And how do i create per namespace routing tables ?

Example or pointer to docs would be great. or just walk me through the rough
outline of my use case...:

  - create container e0procs, configure just the physical eth0 interface into it ??
    - without assigning an IP address ?
    - run a dhcp daemon from withing container e0proces and that
      will correctly get ip address/mask and default route configured in a
      routing table solely used by container e0procs ?
    - container e0procs DHCPd will also populate containerized /etc/resolv.conf with
      eth0 domain prefix/DNS-servers...

  - same approach for container c1procs, confgiure phys eth1 interface into it,
    start DHCP daemon inside container inside it, get routing table and dNS
    for container c1procs from it.

Is that it ? Of not, then how. If yes, then what type of routing table would
i actually see outside of the containers ? And back to the original question,
would socket(), bind(INADDR_ANY) from inside the containers work correctly ?

Thanks
    Toerless

On Mon, Oct 31, 2011 at 08:19:44PM -0700, Eric W. Biederman wrote:
> Toerless Eckert <Toerless.Eckert-vrlraubKdiR4tiELkoLHDcSSVFg4/55HhC4ANOJQIlc@public.gmane.org> writes:
> 
> > I am trying to understand if (and if so how) i can use LXC (or any
> > other comparable lightweightc container option) to effectively
> > run applications on a linux system with two separate IP interfaces
> > as if they each had only access to a single IP interface.
> >
> > Eg:
> >     eth0 with address and default-router learned by DHCP
> >     eg: address 10.1.1.2/24, default-router 10.1.1.254
> >     DNS prefix and DNS domain name for ether0 of course also learned by DHCP.
> >
> >     eth1 with address and default-router learned by DHCP
> >     eg: address 10.2.1.a/242, default-router 10.2.1.254
> >     DNS prefix and DNS domain name for ether0 of course also learned by DHCP.
> >
> >     (no need for overlapping addresses).
> 
> That sounds like L2 level isolation.
> 
> ip link set eth1 netns XXXX.
> 
> Will let move a network device to a choose network namespace.
> 
> That is the easy trivial case.  Most people don't have the multiple
> physical interfaces so tricky things have to happen.
> 
> Does that sound like what you are looking for?
> 
> Eric
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
