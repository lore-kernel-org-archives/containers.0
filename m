From: Chris Leech <cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 9/9] iscsi: filter flashnode sysfs by net namespace
Date: Tue,  7 Nov 2017 14:45:13 -0800
Message-ID: <20171107224513.4217-10-cleech__23531.9355423146$1510094833$gmane$org@redhat.com>
References: <20171107180156.GD29597@straylight.hirudinean.org>
	<20171107224513.4217-1-cleech@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20171107224513.4217-1-cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

Finished the net namespace support for flashnode sysfs devices

Signed-off-by: Chris Leech <cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/scsi/scsi_transport_iscsi.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index 5ffda170ac9d..783971d72c4c 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -1268,8 +1268,41 @@ static int iscsi_is_flashnode_conn_dev(struct device *dev, void *data)
 	return dev->type == &iscsi_flashnode_conn_dev_type;
 }
 
+static struct net *iscsi_flashnode_sess_net(struct iscsi_flash_session *f_sess)
+{
+	struct Scsi_Host *shost = iscsi_flash_session_to_shost(f_sess);
+	struct iscsi_cls_host *ihost = shost->shost_data;
+
+	return iscsi_host_net(ihost);
+}
+
+static struct net *iscsi_flashnode_conn_net(struct iscsi_flash_conn *f_conn)
+{
+	struct iscsi_flash_session *f_sess =
+		iscsi_flash_conn_to_flash_session(f_conn);
+
+	return iscsi_flashnode_sess_net(f_sess);
+}
+
+static const void *iscsi_flashnode_namespace(struct device *dev)
+{
+	struct iscsi_flash_conn *f_conn;
+	struct iscsi_flash_session *f_sess;
+
+	if (iscsi_is_flashnode_conn_dev(dev, NULL)) {
+		f_conn = iscsi_dev_to_flash_conn(dev);
+		return iscsi_flashnode_conn_net(f_conn);
+	} else if (iscsi_is_flashnode_session_dev(dev)) {
+		f_sess = iscsi_dev_to_flash_session(dev);
+		return iscsi_flashnode_sess_net(f_sess);
+	}
+	return NULL;
+}
+
 static struct class iscsi_flashnode = {
 	.name = "iscsi_flashnode",
+	.ns_type = &net_ns_type_operations,
+	.namespace = iscsi_flashnode_namespace,
 };
 
 /**
-- 
2.9.5
