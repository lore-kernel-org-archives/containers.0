From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] IP address restricting cgroup subsystem
Date: Wed, 7 Jan 2009 12:07:52 -0600
Message-ID: <20090107180752.GA19153@us.ibm.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090106230554.GB25228-IaEwMO9oKu/77SC2UrCW1JJg/dWx8T/9@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Grzegorz Nosek (root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org):
> This is a very simple cgroup subsystem to restrict IP addresses used
> by member processes. Currently it is limited to IPv4 only but IPv6 (or
> other protocols) should be easy to implement.
> 
> IP addresses are write-once (via /cgroup/.../ipaddr.ipv4 in dotted-quad
> format) and are inherited by descendant cgroups, so a process once
> restricted should never be able to get rid of the limits. Any address
> may be specified in multiple cgroups. No verification is done to ensure
> the addresses are actually configured on the machine, which has its
> advantages (may add the addresses later) and disadvantages (if you enter
> the wrong address, the cgroup will be effectively cut off from the
> network).
> 
> Whenever a process inside a restricted cgroup calls bind(2), the address
> is checked like this:
>  - INADDR_LOOPBACK is explicitly allowed (a special case)
>  - INADDR_ANY is remapped to _the_ IP address
>  - _the_ IP address is passed through unharmed
>  - everything else causes -EPERM
> 
> When a process calls connect(2), this subsystem calls bind(_the_IP_)
> quietly behind its back, while preserving the original bound port (if
> any).
> 
> Rationale (or when/why would you want it):
> The use case for ipaddr_cgroup doesn't overlap with network namespaces,
> which also allow IP address restrictions, because it aims to be much
> lighter due to its limited scope (hopefully able to easily support
> hundreds or possibly thousands of distinct cgroups). It does not attempt
> to hide the existence of other IP addresses from the user.

Have you run a test, and found that in fact a network namespace
is too heavyweight to do so?  If so, some numbers here would be
far more pursuasive.

(Mind you I've written a few version of this - based on LSM -
myself in the past, but that was before network namespaces
existed)

-serge
