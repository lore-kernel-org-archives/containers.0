From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 0/25] Sysfs cleanups & tagged directory support
Date: Wed, 08 Aug 2007 23:35:36 +0900
Message-ID: <46B9D4B8.4050201@gmail.com>
References: <11860582832964-git-send-email-htejun@gmail.com>	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>	<20070808093815.0935a18e@gondolin.boeblingen.de.ibm.com>	<m1bqdifowo.fsf@ebiederm.dsl.xmission.com>	<20070808095432.4a520735@gondolin.boeblingen.de.ibm.com>	<m17io6foh8.fsf@ebiederm.dsl.xmission.com>	<20070808103759.0850383c@gondolin.boeblingen.de.ibm.com> <20070808161631.1ccf27fd@gondolin.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030003090206010103020901"
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934460AbXHHOfz@vger.kernel.org>
In-Reply-To: <20070808161631.1ccf27fd@gondolin.boeblingen.de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, satyam@infradead.org, stern@rowland.harvard.edu, Linux Containers <containers@lists.osdl.org>, gregkh@suse.de
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------030003090206010103020901
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Does the attached patch happen to fix the problem?

-- 
tejun

--------------030003090206010103020901
Content-Type: text/plain;
 name="debug"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="debug"

---
 fs/sysfs/dir.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: work/fs/sysfs/dir.c
===================================================================
--- work.orig/fs/sysfs/dir.c
+++ work/fs/sysfs/dir.c
@@ -1010,7 +1010,7 @@ static int sysfs_readdir(struct file * f
 		if (filldir(dirent, "..", 2, filp->f_pos, ino, DT_DIR) == 0)
 			filp->f_pos++;
 	}
-	if ((filp->f_pos > 1) && (filp->f_pos < UINT_MAX)) {
+	if ((filp->f_pos > 1) && (filp->f_pos < INT_MAX)) {
 		mutex_lock(&sysfs_mutex);
 
 		/* Skip the dentries we have already reported */
@@ -1031,7 +1031,7 @@ static int sysfs_readdir(struct file * f
 				break;
 		}
 		if (!pos)
-			filp->f_pos = UINT_MAX;
+			filp->f_pos = INT_MAX;
 		mutex_unlock(&sysfs_mutex);
 	}
 	return 0;

--------------030003090206010103020901--
