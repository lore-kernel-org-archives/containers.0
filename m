From: Sudheer <sudheer-ETsMpvZGyKJdeDdKuUvyIgC/G2K4zDHf@public.gmane.org>
Subject: vlan based macvlan issue
Date: Mon, 6 Jul 2009 18:39:23 +0530
Message-ID: <1129ae910907060609g61322dcas8df914eeb2148a6f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

   I have created a macvlan container using one vlan interface . After that
I couldn't ping form the macvlan container to the host machine which is
included the same vlan network. Below the details.

lxc-macvlan config file :

       lxc.utsname = alpha
       lxc.network.type = macvlan
       lxc.network.flags = up
       lxc.network.link = eth1.100
       lxc.network.hwaddr = 4a:49:43:49:79:bd
       lxc.network.ipv4 = <xx.xx.100.xx>
After creating the container able to see the macvlan interface but couldn't
ping from the container to host machines. Is anything missing in my above
config file or anything need to be add for vlan based macvlan?

regards,
Sudheer.
