From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [lxc-devel] Containerized syslog
Date: Wed, 12 May 2010 23:15:05 +0200
Message-ID: <4BEB1A59.6010905__40208.8277660825$1273699045$gmane$org@free.fr>
References: <4BEAC1E8.1070506@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BEAC1E8.1070506-zanJymNeSEOeCSforKHNpg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: jean-philippe.menil-zanJymNeSEOeCSforKHNpg@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Jean-Philippe Menil wrote:
> Hi,
>
> I'm playing with containers under debian (squeeze, 2.6.33.3) with the 
> lxc tools.
> I'm really happy about all the features (attach veth on bridge, filter 
> with iptables inside the containers, etc ...), and i was thinking to 
> replace some of our vservers (and maybe some of our kvm) with this 
> solution.
>
> But actually, i experiment a problem with the iptables logs:
> i've iptables on the host to filter some container, basically a squid 
> proxy. I've another container who act as router, and he has his own 
> iptables inside.
> All the log are deported to a dedicated syslog server.
> It appear that, the iptables log of the host are also deported by the 
> syslog container (proxy).
>
> Some of our guest (container, vserver, etc ) are administer by other 
> sys-admin, that should not have access to theses informations.
>
> This point is blocking me today, before going into production with 
> containers.
>
> I've seen some patch made by Jean-Marc Pigeon about this problem,
> but they have not been commited.

I thing a consensus was not reach. The big deal with syslog is netfilter 
logs in an interrupt context where it is difficult to find the right log 
buffer ring as we are not in the process context making possible to 
identify the namespace.

IMHO, there are two parts to implement, (1) multiple instances of 
/dev/log with a new ring buffer each time attached to the file and (2) 
add an iptables rules to specify the file to log. This approach allows 
to get rid of namespace (in all the cases the clone flags are exhausted 
now), and provides a generic mechanism for other use cases (eg. separate 
logs for iptables) different from a container specific problem.

This is from a kernel POV, but from the userspace POV, that will means 
the iptables rules in the vps configuration files should be modified, I 
don't know if it's acceptable.
> Is there any reason for that?
> Can someone advice me to circumvent this problem?
I don't know a workaround for this problem.

Thanks
  -- Daniel
