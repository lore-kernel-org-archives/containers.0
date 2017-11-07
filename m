From: Chris Leech <cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/9] iscsi: associate endpoints with a host
Date: Tue,  7 Nov 2017 14:45:06 -0800
Message-ID: <20171107224513.4217-3-cleech__32065.0529386059$1510094797$gmane$org@redhat.com>
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

Right now the iscsi_endpoint is only linked to a connection once that
connection has been established.  For net namespace filtering of the
sysfs objects, associate an endpoint with the host that it was
allocated for when it is created.

Signed-off-by: Chris Leech <cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/ulp/iser/iscsi_iser.c | 2 +-
 drivers/scsi/be2iscsi/be_iscsi.c         | 2 +-
 drivers/scsi/bnx2i/bnx2i_iscsi.c         | 2 +-
 drivers/scsi/cxgbi/libcxgbi.c            | 2 +-
 drivers/scsi/qedi/qedi_iscsi.c           | 2 +-
 drivers/scsi/qla4xxx/ql4_os.c            | 2 +-
 drivers/scsi/scsi_transport_iscsi.c      | 3 ++-
 include/scsi/scsi_transport_iscsi.h      | 6 +++++-
 8 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/ulp/iser/iscsi_iser.c b/drivers/infiniband/ulp/iser/iscsi_iser.c
index 19624e023ebd..0a4214be4877 100644
--- a/drivers/infiniband/ulp/iser/iscsi_iser.c
+++ b/drivers/infiniband/ulp/iser/iscsi_iser.c
@@ -817,7 +817,7 @@ iscsi_iser_ep_connect(struct Scsi_Host *shost, struct sockaddr *dst_addr,
 	struct iser_conn *iser_conn;
 	struct iscsi_endpoint *ep;
 
-	ep = iscsi_create_endpoint(0);
+	ep = iscsi_create_endpoint(shost, 0);
 	if (!ep)
 		return ERR_PTR(-ENOMEM);
 
diff --git a/drivers/scsi/be2iscsi/be_iscsi.c b/drivers/scsi/be2iscsi/be_iscsi.c
index a398c54139aa..33f79f385660 100644
--- a/drivers/scsi/be2iscsi/be_iscsi.c
+++ b/drivers/scsi/be2iscsi/be_iscsi.c
@@ -1157,7 +1157,7 @@ beiscsi_ep_connect(struct Scsi_Host *shost, struct sockaddr *dst_addr,
 		return ERR_PTR(ret);
 	}
 
-	ep = iscsi_create_endpoint(sizeof(struct beiscsi_endpoint));
+	ep = iscsi_create_endpoint(shost, sizeof(struct beiscsi_endpoint));
 	if (!ep) {
 		ret = -ENOMEM;
 		return ERR_PTR(ret);
diff --git a/drivers/scsi/bnx2i/bnx2i_iscsi.c b/drivers/scsi/bnx2i/bnx2i_iscsi.c
index 03c104b47f31..19fadb5d3b3c 100644
--- a/drivers/scsi/bnx2i/bnx2i_iscsi.c
+++ b/drivers/scsi/bnx2i/bnx2i_iscsi.c
@@ -384,7 +384,7 @@ static struct iscsi_endpoint *bnx2i_alloc_ep(struct bnx2i_hba *hba)
 	struct bnx2i_endpoint *bnx2i_ep;
 	u32 ec_div;
 
-	ep = iscsi_create_endpoint(sizeof(*bnx2i_ep));
+	ep = iscsi_create_endpoint(hba->shost, sizeof(*bnx2i_ep));
 	if (!ep) {
 		printk(KERN_ERR "bnx2i: Could not allocate ep\n");
 		return NULL;
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 858e32e8ad2d..558484f72738 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -2616,7 +2616,7 @@ struct iscsi_endpoint *cxgbi_ep_connect(struct Scsi_Host *shost,
 		goto release_conn;
 	}
 
-	ep = iscsi_create_endpoint(sizeof(*cep));
+	ep = iscsi_create_endpoint(shost, sizeof(*cep));
 	if (!ep) {
 		err = -ENOMEM;
 		pr_info("iscsi alloc ep, OOM.\n");
diff --git a/drivers/scsi/qedi/qedi_iscsi.c b/drivers/scsi/qedi/qedi_iscsi.c
index a02b34ea5cab..5ae589ea1dd2 100644
--- a/drivers/scsi/qedi/qedi_iscsi.c
+++ b/drivers/scsi/qedi/qedi_iscsi.c
@@ -847,7 +847,7 @@ qedi_ep_connect(struct Scsi_Host *shost, struct sockaddr *dst_addr,
 		return ERR_PTR(ret);
 	}
 
-	ep = iscsi_create_endpoint(sizeof(struct qedi_endpoint));
+	ep = iscsi_create_endpoint(shost, sizeof(struct qedi_endpoint));
 	if (!ep) {
 		QEDI_ERR(&qedi->dbg_ctx, "endpoint create fail\n");
 		ret = -ENOMEM;
diff --git a/drivers/scsi/qla4xxx/ql4_os.c b/drivers/scsi/qla4xxx/ql4_os.c
index 64c6fa563fdb..5785bf6c3ec0 100644
--- a/drivers/scsi/qla4xxx/ql4_os.c
+++ b/drivers/scsi/qla4xxx/ql4_os.c
@@ -1673,7 +1673,7 @@ qla4xxx_ep_connect(struct Scsi_Host *shost, struct sockaddr *dst_addr,
 	}
 
 	ha = iscsi_host_priv(shost);
-	ep = iscsi_create_endpoint(sizeof(struct qla_endpoint));
+	ep = iscsi_create_endpoint(shost, sizeof(struct qla_endpoint));
 	if (!ep) {
 		ret = -ENOMEM;
 		return ERR_PTR(ret);
diff --git a/drivers/scsi/scsi_transport_iscsi.c b/drivers/scsi/scsi_transport_iscsi.c
index 0b23ba346cbe..6ab7ca82b121 100644
--- a/drivers/scsi/scsi_transport_iscsi.c
+++ b/drivers/scsi/scsi_transport_iscsi.c
@@ -194,7 +194,7 @@ static int iscsi_match_epid(struct device *dev, const void *data)
 }
 
 struct iscsi_endpoint *
-iscsi_create_endpoint(int dd_size)
+iscsi_create_endpoint(struct Scsi_Host *shost, int dd_size)
 {
 	struct device *dev;
 	struct iscsi_endpoint *ep;
@@ -221,6 +221,7 @@ iscsi_create_endpoint(int dd_size)
 
 	ep->id = id;
 	ep->dev.class = &iscsi_endpoint_class;
+	ep->dev.parent = &shost->shost_gendev;
 	dev_set_name(&ep->dev, "ep-%llu", (unsigned long long) id);
 	err = device_register(&ep->dev);
         if (err)
diff --git a/include/scsi/scsi_transport_iscsi.h b/include/scsi/scsi_transport_iscsi.h
index b266d2a3bcb1..3b40fea93556 100644
--- a/include/scsi/scsi_transport_iscsi.h
+++ b/include/scsi/scsi_transport_iscsi.h
@@ -267,6 +267,9 @@ struct iscsi_cls_session {
 #define iscsi_session_to_shost(_session) \
 	dev_to_shost(_session->dev.parent)
 
+#define iscsi_endpoint_to_shost(_ep) \
+	dev_to_shost(_ep->dev.parent)
+
 #define starget_to_session(_stgt) \
 	iscsi_dev_to_session(_stgt->dev.parent)
 
@@ -440,7 +443,8 @@ extern int iscsi_destroy_conn(struct iscsi_cls_conn *conn);
 extern void iscsi_unblock_session(struct iscsi_cls_session *session);
 extern void iscsi_block_session(struct iscsi_cls_session *session);
 extern int iscsi_scan_finished(struct Scsi_Host *shost, unsigned long time);
-extern struct iscsi_endpoint *iscsi_create_endpoint(int dd_size);
+extern struct iscsi_endpoint *iscsi_create_endpoint(struct Scsi_Host *shost,
+						    int dd_size);
 extern void iscsi_destroy_endpoint(struct iscsi_endpoint *ep);
 extern struct iscsi_endpoint *iscsi_lookup_endpoint(u64 handle);
 extern int iscsi_block_scsi_eh(struct scsi_cmnd *cmd);
-- 
2.9.5
