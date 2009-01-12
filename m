From: chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org
Subject: Net containers config and usage
Date: Mon, 12 Jan 2009 14:35:45 -0800
Message-ID: <20090112223545.GA15781@versecorp.net>
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

All,

  I'm new to linux containers and am interested in the network containers
support, but am having some troubles getting it working & could use some help.

  I saw that the code released to 2.6.26 was incompatible with sysfs, but
that 2.6.29 should have support for both.  

  So, I built:
    linux-2.6.29-rc1
    iproute2.2.6.25 plus the patch for containers support
    lxc-0.5.2

  I can now run lxc-unshare -n /bin/tcsh
  And, as expected, that process only sees loopback.

  But I'm having trouble assigning an interface over to that container.

  I tried doing:
     # echo <pid> > /sys/class/net/eth4/new_ns_pid

  But there are no entries in sysfs called new_ns_pid.

  I also tried doing ip link set eth4 newns <pid>
  but I get a netlink error:
    RTNETLINK answers: Invalid argument 


Any tips on what I might be doing wrong, or how to get this working?  Since
I can do the lxc-unshare, it seems like I'm part way there, but can't move
network devices between namespaces.

Thanks,
Chris
