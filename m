From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 02/16] net: Don't implement dev_ifname32 inline
Date: Sat, 08 Sep 2007 15:13:04 -0600
Message-ID: <m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>
	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1myvwx3sf.fsf@ebiederm.dsl.xmission.com> (Eric W. Biederman's
	message of "Sat, 08 Sep 2007 15:09:36 -0600")
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org


The current implementation of dev_ifname makes maintenance difficult
because updates to the implementation of the ioctl have to made in two
places.  So this patch updates dev_ifname32 to do a classic 32/64
structure conversion and call sys_ioctl like the rest of the
compat calls do.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/compat_ioctl.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index a6c9078..361b994 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -324,22 +324,21 @@ struct ifconf32 {
 
 static int dev_ifname32(unsigned int fd, unsigned int cmd, unsigned long arg)
 {
-	struct net_device *dev;
-	struct ifreq32 ifr32;
+	struct ifreq __user *uifr;
 	int err;
 
-	if (copy_from_user(&ifr32, compat_ptr(arg), sizeof(ifr32)))
+	uifr = compat_alloc_user_space(sizeof(struct ifreq));
+	if (copy_in_user(uifr, compat_ptr(arg), sizeof(struct ifreq32)));
 		return -EFAULT;
 
-	dev = dev_get_by_index(ifr32.ifr_ifindex);
-	if (!dev)
-		return -ENODEV;
+	err = sys_ioctl(fd, SIOCGIFNAME, (unsigned long)uifr);
+	if (err)
+		return err;
 
-	strlcpy(ifr32.ifr_name, dev->name, sizeof(ifr32.ifr_name));
-	dev_put(dev);
-	
-	err = copy_to_user(compat_ptr(arg), &ifr32, sizeof(ifr32));
-	return (err ? -EFAULT : 0);
+	if (copy_in_user(compat_ptr(arg), uifr, sizeof(struct ifreq32)))
+		return -EFAULT;
+
+	return 0;
 }
 
 static int dev_ifconf(unsigned int fd, unsigned int cmd, unsigned long arg)
-- 
1.5.3.rc6.17.g1911

