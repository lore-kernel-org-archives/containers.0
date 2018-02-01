From: Christian Brauner <christian.brauner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: rtnetlink updates in 4.16
Date: Thu, 1 Feb 2018 09:57:44 +0100
Message-ID: <20180201085743.eqxbspsy6yg6n6yl@gmail.com>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

Pushed some patches that might be interesting to container runtimes. The
gist is:

rtnetlink: enable IFLA_IF_NETNSID for RTM_{DEL,NEW,SET}LINK

The series enables passing a IFLA_IF_NETNSID property along with
RTM_{DEL,NEW,SET}LINK requests to perform operations on network
namespaces without the need to setns() to the corresponding network
namespace (and its owning user namespace). For workloads employing user
namespaces and network namespaces this effectively let's you avoid
spawning an additional helper processes.

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=7c4f63ba824302492985553018881455982241d6
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c310bfcb6e1be993629c5747accf8e1c65fbb255
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=b61ad68a9fe85d29d5363eb36860164a049723cf
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=5bb8ed075428b71492734af66230aa0c07fcc515

Thanks!
Christian
