From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: nfsd and containers
Date: Sat, 3 Jan 2009 21:54:15 -0500
Message-ID: <20090104025415.GF24075@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Does anyone have any ideas about how the kernel's nfsd should interact
(if at all) with network namespaces?

I'm initially interested because I've been experimenting with modifying
the server to allow it to present different exported filesystems
depending on which ip address it's accessed through.  One way to do that
might be by modifying the kernel to behave as though there's a separate
nfsd service per network namespace; then we'd need little or no
modification of the userspace support daemons (statd, the portmapper,
etc.)--just start multiple instances of them in separate network
namespaces and teach the kernel to route requests to them to the
corresponding loopback interface.  (That would work at least for daemons
that communicate with the kernel exclusively using rpc over loopback.
We could perhaps do something similar with the various /proc and nfsctl
interfaces.)

I'm also curious more generally whether anyone's thought about how nfsd 
should behave in the presence of containers.

(Also, I take it the sysfs problem described in
http://lwn.net/Articles/295587/ is still unsolved?)

--b.
