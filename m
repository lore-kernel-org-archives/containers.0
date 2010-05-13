From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [lxc-devel] Containerized syslog
Date: Thu, 13 May 2010 14:21:39 -0700
Message-ID: <20100513212139.GT31830@count0.beaverton.ibm.com>
References: <4BEAC1E8.1070506@univ-nantes.fr>
 <4BEB1A59.6010905@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4BEB1A59.6010905-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, May 12, 2010 at 11:15:05PM +0200, Daniel Lezcano wrote:
> Jean-Philippe Menil wrote:
> > Hi,
> >
> > I'm playing with containers under debian (squeeze, 2.6.33.3) with the 
> > lxc tools.
> > I'm really happy about all the features (attach veth on bridge, filter 
> > with iptables inside the containers, etc ...), and i was thinking to 
> > replace some of our vservers (and maybe some of our kvm) with this 
> > solution.
> >
> > But actually, i experiment a problem with the iptables logs:
> > i've iptables on the host to filter some container, basically a squid 
> > proxy. I've another container who act as router, and he has his own 
> > iptables inside.
> > All the log are deported to a dedicated syslog server.
> > It appear that, the iptables log of the host are also deported by the 
> > syslog container (proxy).
> >
> > Some of our guest (container, vserver, etc ) are administer by other 
> > sys-admin, that should not have access to theses informations.
> >
> > This point is blocking me today, before going into production with 
> > containers.
> >
> > I've seen some patch made by Jean-Marc Pigeon about this problem,
> > but they have not been commited.
> 
> I thing a consensus was not reach. The big deal with syslog is netfilter 
> logs in an interrupt context where it is difficult to find the right log 
> buffer ring as we are not in the process context making possible to 
> identify the namespace.
> 
> IMHO, there are two parts to implement, (1) multiple instances of 
> /dev/log with a new ring buffer each time attached to the file and 

Just for reference, here are some archived mailing list threads on the
subject of containerized syslog:

	http://www.mail-archive.com/devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org/msg20104.html
	http://thread.gmane.org/gmane.linux.kernel.containers/16526

> (2) 
> add an iptables rules to specify the file to log. This approach allows 
> to get rid of namespace (in all the cases the clone flags are exhausted 
> now), and provides a generic mechanism for other use cases (eg. separate 
> logs for iptables) different from a container specific problem.

(3) Security implications.

	Depending on how the syslog is split off, whether the host
	expects to be "Cc'd", etc. there could be some security
	implications. More importantly, the syslog control syscalls need
	to be modified to at least prevent containers from changing syslog
	policy of the host. Serge could probably explain this much better
	than I can (cc'd). Here's a thread on the subject:

	http://lwn.net/Articles/378472/

Cheers,
	-Matt Helsley
