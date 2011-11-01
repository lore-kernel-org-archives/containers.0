From: Toerless Eckert <Toerless.Eckert-vrlraubKdiR4tiELkoLHDcSSVFg4/55HhC4ANOJQIlc@public.gmane.org>
Subject: LXC L3 network isolation, yes/no ?, how ?
Date: Tue, 1 Nov 2011 03:12:30 +0100
Message-ID: <20111101021230.GE15906@faui40p.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

I am trying to understand if (and if so how) i can use LXC (or any
other comparable lightweightc container option) to effectively
run applications on a linux system with two separate IP interfaces
as if they each had only access to a single IP interface.

Eg:
    eth0 with address and default-router learned by DHCP
    eg: address 10.1.1.2/24, default-router 10.1.1.254
    DNS prefix and DNS domain name for ether0 of course also learned by DHCP.

    eth1 with address and default-router learned by DHCP
    eg: address 10.2.1.a/242, default-router 10.2.1.254
    DNS prefix and DNS domain name for ether0 of course also learned by DHCP.

    (no need for overlapping addresses).

So, i configure LXC accordingly (how...) for one eth0container, and one
eth1container. All processes running eth0container will have all their
traffic use ony eth0, all the ones in eth1container will only use eth1.

If this works, i'd love to get a pointer to an example config. The
ones i could find on the web looked as if they where using bridging
to attach multiple containers to ultimately the same single IP subnet
with the same default router (and thereby the same DNS prefix and DNS servers).

I can't see how LXC can make my case work without some additional kernel
support because when either process1 or process2 open let say a
client socket and just connect(), then (AFAIK) the default linux routing
logic takes place which would (AFAIK) first figure out where to route the
destination to (eth0 or eth1) and then pick the local IP address of that
interface as the sockets local IP address. And i don't understand how
LXC would make this decision process dependent on which contain the process
is running in.

I guess one can create additional routing tables, one for each container
and then use the fwmark on all sockets to have them use that container
specific routing table, but it's not clear to me whether/how that is really
done on LXC.

Thanks a lot!
    Toerless
