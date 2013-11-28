From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Q: use vlan in container
Date: Thu, 28 Nov 2013 14:17:39 +0800
Message-ID: <5296E003.80804@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello LXC experts,

	I meet a problem. When using vlan as network device in suse11 system container,
I can not use halt to stop this container. It hung on "eth0 is still used from interfaces eth0" in cycle.

The config file:

lxc.network.type = vlan
lxc.network.flags = up
lxc.network.link = eth0
lxc.network.name = eth0
lxc.network.vlan.id = 1301
lxc.network.ipv4 = 128.5.131.100/24


The reason is in the shell command /sbin/ifdown, see below:

######################################################################
# Shut down depending interfaces
#
# Check if there are interfaces which depend on this interface. If yes these
# have to be shut down first.
# For example these might be bonding or vlan interfaces. Note that we don't
# catch all types of depending interfaces currently. See function
# 'get_depending_ifaces' in file 'functions' for details.
#
test "$SCRIPTNAME" = ifdown && DEP_IFACES=`get_depending_ifaces $INTERFACE`
if [ "$?" = 0 -a "$NODEPS" != yes ] ; then
        message "`printf "    %-9s is still used from interfaces %s" \
                         $INTERFACE "$DEP_IFACES"`"
        for DI in $DEP_IFACES; do
                ifdown $DI -o $OPTIONS
        done

        message "`printf "    %-9s now going down itself" $INTERFACE`"
        # check if iface is (still) avaliable
        # [bonding master may go down itself
        #  while the last slave gets removed]
        if ! is_iface_available $INTERFACE; then
                exit $R_SUCCESS
        fi
fi


$DEP_IFACES is also eth0 in this scene, so ifdown will call ifdown again and again.

if we set lxc.network.name = eth1, it will be ok, so can we add a judgment to make
lxc.network.link and lxc.network.name are not equal in lxc-start command.

simple implement like:

	if [ lxc.network.type == vlan ] ; then
		if [ lxc.network.link == lxc.network.name ] ; then
			return false
		fi
	fi


Is it reasonable?  or any other way to achieve this?
