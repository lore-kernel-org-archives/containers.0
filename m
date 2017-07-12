From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Tue, 11 Jul 2017 19:47:15 -0500
Message-ID: <20170712004715.GC6436__31740.5611080632$1499820446$gmane$org@mail.hallyn.com>
References: <1499785511-17192-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1499785511-17192-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<20170711171222.GB31603@mail.hallyn.com>
	<ca6e0001-6aeb-74dc-ab91-44aed3b7d128@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <ca6e0001-6aeb-74dc-ab91-44aed3b7d128-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, Stefan Berger <StefanBergerstefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Stefan Berger (stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> On 07/11/2017 01:12 PM, Serge E. Hallyn wrote:
> >>diff --git a/fs/xattr.c b/fs/xattr.c
> >>index 464c94b..eacad9e 100644
> >>--- a/fs/xattr.c
> >>+++ b/fs/xattr.c
> >>@@ -133,20 +133,440 @@ xattr_permission(struct inode *inode, const char *name, int mask)
> >>  	return inode_permission(inode, mask);
> >>  }
> >>+/*
> >>+ * A list of extended attributes that are supported in user namespaces
> >>+ */
> >>+static const char *const userns_xattrs[] = {
> >>+	XATTR_NAME_CAPS,
> >>+	NULL
> >>+};
> >>+
> >>+/*
> >>+ * xattrs_is_userns_supported - Check whether an xattr is supported in userns
> >>+ *
> >>+ * @name:   full name of the extended attribute
> >>+ * @prefix: do a prefix match (true) or a full match (false)
> >>+ *
> >>+ * This function returns < 0 if not supported, an index into userns_xattrs[]
> >>+ * otherwise.
> >>+ */
> >>+static int
> >>+xattr_is_userns_supported(const char *name, int prefix)
> >>+{
> >>+	int i;
> >>+
> >>+	if (!name)
> >>+		return -1;
> >>+
> >>+	for (i = 0; userns_xattrs[i]; i++) {
> >>+		if (prefix) {
> >>+			if (!strncmp(userns_xattrs[i], name,
> >>+				     strlen(userns_xattrs[i])))
> >>+				return i;
> >I think you here need to also check that the next char is either
> >'\0' or '.' (or maybe '@')
> 
> I have the checks for '@' and '\0' done by the caller. With the
> current support of only security.capability I don't think we need to
> check for '.'.

Ah - ok, thanks.
