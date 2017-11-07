From: Chris Leech <cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/9] use network namespace for iSCSI control interfaces
Date: Tue,  7 Nov 2017 14:45:04 -0800
Message-ID: <20171107224513.4217-1-cleech@redhat.com>
References: <20171107180156.GD29597@straylight.hirudinean.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20171107180156.GD29597-r8IHplWLGbA5tHQWs+pTeqPFFGjUI2lm2LY78lusg7I@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

I've posted these changes to allow iSCSI management within a container
using a network namespace to the SCSI and Open-iSCSI lists, but seeing
as it's not really SCSI/block related I'm casting a wider net looking
for reviews.

These patches apply network namespace to the iSCSI netlink family and
sysfs objects from the iSCSI transport class.

Thank you,

Chris Leech

---

This series of changes makes the iSCSI netlink and sysfs control
interfaces filtered by network namespace.  This is required to run
iscsid in any network namespace other than the initial default one.

Currently the netlink communication will fail if iscsid is started in a
non-default network namespace, as there is no kernel side socket.  After
fixing that, the rest of these changes are to filter visibility of the
iSCSI transport objects by netns.  This allows for multiple iscsid
instances to be run, one per netns, each controlling it's own set of
iSCSI sessions.

The iSCSI transport objects are filtered, but not the SCSI or block
layer devices.  So while iSCSI hosts and sessions become limited to a
network namespace, any attached devices remain visible system wide.

This currently only supports iscsi_tcp running in a new namespace, as it
creates a virtual host per session.  Support could be added later to
allow assignment of iSCSI HBAs to network namespace, much as is done for
network interfaces.

Chris Leech (9):
  iscsi: create per-net iscsi netlink kernel sockets
  iscsi: associate endpoints with a host
  iscsi: sysfs filtering by network namespace
  iscsi: make all iSCSI netlink multicast namespace aware
  iscsi: set netns for iscsi_tcp hosts
  iscsi: check net namespace for all iscsi lookups
  iscsi: convert flashnode devices from bus to class
  iscsi: rename iscsi_bus_flash_* to iscsi_flash_*
  iscsi: filter flashnode sysfs by net namespace

 drivers/infiniband/ulp/iser/iscsi_iser.c |   7 +-
 drivers/scsi/be2iscsi/be_iscsi.c         |   6 +-
 drivers/scsi/bnx2i/bnx2i_iscsi.c         |   6 +-
 drivers/scsi/cxgbi/libcxgbi.c            |   6 +-
 drivers/scsi/iscsi_tcp.c                 |   7 +
 drivers/scsi/qedi/qedi_iscsi.c           |   6 +-
 drivers/scsi/qla4xxx/ql4_os.c            |  62 +--
 drivers/scsi/scsi_transport_iscsi.c      | 625 ++++++++++++++++++++++---------
 include/scsi/scsi_transport_iscsi.h      |  63 ++--
 9 files changed, 538 insertions(+), 250 deletions(-)

-- 
2.9.5
