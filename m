From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: How do containers tie to multiple IP's on a NIC?
Date: Wed, 07 Jul 2010 05:55:22 -0700
Message-ID: <m1sk3vjvt1.fsf@fess.ebiederm.org>
References: <20100704034023.GA29753@transpect.com> <4C30BC16.9090802@free.fr>
	<20100704191841.GA31425@transpect.com> <4C30E5CB.1080902@free.fr>
	<20100704230827.GA1066@transpect.com> <4C31AAEE.5010201@gmail.com>
	<20100705140750.GA3113@transpect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100705140750.GA3113-M6G8SDWvnhfby3iVrkZq2A@public.gmane.org> (Whit Blauvelt's message of
	"Mon\, 5 Jul 2010 10\:07\:50 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Whit Blauvelt <whit-M6G8SDWvnhfby3iVrkZq2A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Whit Blauvelt <whit-M6G8SDWvnhfby3iVrkZq2A@public.gmane.org> writes:

> On Mon, Jul 05, 2010 at 05:50:38PM +0800, Pavel Labushev wrote:
>
>> What exactly are you trying to achieve? A transparent packet forwarding
>> between containers and external networks?
>
> I'm trying to get the overview of what can be achieved, and how. Unless I've
> missed it, there's not much documentation on even moderately complex use of
> containers. Since the capabilities are rapidly advancing, maybe I'm just
> asking the question a few months too early? From the outside, as someone new
> to containers, it looks like a maze where there are a number of entrances,
> each of which may lead approximately to the goal, but some of which may be
> dead ends. 
>
> The examples I have found are along the lines of: Here's how to start a
> container, bridge it to a NIC which has a single IP assigned, ssh to it ...
> and the examples stop there. What I'd like to achieve is a setup where, say,
> a box with 6 IPs on an external network - on eth0 before bridging (or its
> alternatives) - can have 5 of those IPs each dedicated to different single
> container.
>
> I'm not committed to a particular way of achieving that yet, just looking at
> the maze entrances wondering which to choose. Standard packet forwarding,
> routing and firewalling in Linux isn't what I'm asking about, I use that
> stuff frequently in complex ways, and I already run some things in simple
> chroots. I'm trying to learn how, on a test basis, to set up something like
> a production environment with lxc, where it involves multiple IPs, WAN or
> LAN, on each single NIC, behind some of which should be containers which
> effectively own individual IPs, publicly available.
>
> It's probably looking harder to me than it is, because I haven't found a
> clear description of it yet. 

The paper has probably already answered this but the sound bite answer is:

Each network namespace appears to userspace as separate instance of
the network stack.  Separate network device, separate forwarding
tables, separate iptables rules etc.  Network devices can be moved
between network namespaces.

paired veth devices are interesting because you can put one end of a
logical tunnel in each network namespace.

macvlan devices are interesting because you can create assign multiple
mac addresses to a nic and have a different network device for each
mac address.

You can use special tools like lxc to set these things up, but you can also
just run commands inside the network namespace and setup the environment
like you would normally.

Eric
