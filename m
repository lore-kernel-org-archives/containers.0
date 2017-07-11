From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Tue, 11 Jul 2017 12:12:22 -0500
Message-ID: <20170711171222.GB31603__19187.3641837903$1499793155$gmane$org@mail.hallyn.com>
References: <1499785511-17192-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1499785511-17192-2-git-send-email-stefanb@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1499785511-17192-2-git-send-email-stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stefan Berger <StefanBergerstefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: lkp-JC7UmRfGjtg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Stefan Berger (Stefan Bergerstefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> er.kernel.org>
> X-Mailing-List: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Content-Length: 19839
> Lines: 700
> X-UID: 24770                                                 
> Status: RO
> 
> From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> This patch enables security.capability in user namespaces but also
> takes a more general approach to enabling extended attributes in user
> namespaces.
> 
> The following rules describe the approach using security.foo as a
> 'user namespace enabled' extended attribute:
> 
> Reading of extended attributes:
> 
> 1a) Reading security.foo from a user namespace will read
>     security.foo@uid=<uid> of the parent user namespace instead with uid
>     being the mapping of root in that parent user namespace. An
>     exception is if root is mapped to uid 0 on the host, and in this case
>     we will read security.foo directly.
>     --> reading security.foo will read security.foo@uid=1000 for uid
>         mapping of root to 1000.
> 
> 1b) If security.foo@uid=<uid> is not available, the security.foo of the
>     parent namespace is tried to be read. This procedure is repeated up to
>     the init user namespace. This step only applies for reading of extended
>     attributes and provides the same behavior as older system where the
>     host's extended attributes applied to user namespaces.
> 
> 2) All security.foo@uid=<uid> with valid uid mapping in the user namespace
>    can be read. The uid within the user namespace will be mapped to the
>    corresponding uid on the host and that uid will be used in the name of
>    the extended attribute.
>    -> reading security.foo@uid=1 will read security.foo@uid=1001 for uid
>       mapping of root to 1000, size of at least 2.
> 
>    All security.foo@uid=<uid> can be read (by root) on the host with values
>    of <uid> also being subject to checking for valid mappings.
> 
> 3) No other security.foo* can be read.
> 
> The same rules for reading apply to writing and removing of user
> namespace enabled extended attributes.
> 
> When listing extended attributes of a file, only those are presented
> to the user namespace that have a valid mapping. Besides that, names
> of the extended attributes are adjusted to represent the mapping.
> This means that if root is mapped to uid 1000 on the host, the
> security.foo@uid=1000 will be listed as security.foo in the user
> namespace, security.foo@uid=1001 becomes security.foo@uid=1 and so on.
> 
> Signed-off-by: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Signed-off-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
> Reviewed-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
> ---
>  fs/xattr.c               | 509 +++++++++++++++++++++++++++++++++++++++++++++--
>  security/commoncap.c     |  36 +++-
>  security/selinux/hooks.c |   9 +-
>  3 files changed, 523 insertions(+), 31 deletions(-)
> 
> diff --git a/fs/xattr.c b/fs/xattr.c
> index 464c94b..eacad9e 100644
> --- a/fs/xattr.c
> +++ b/fs/xattr.c
> @@ -133,20 +133,440 @@ xattr_permission(struct inode *inode, const char *name, int mask)
>  	return inode_permission(inode, mask);
>  }
>  
> +/*
> + * A list of extended attributes that are supported in user namespaces
> + */
> +static const char *const userns_xattrs[] = {
> +	XATTR_NAME_CAPS,
> +	NULL
> +};
> +
> +/*
> + * xattrs_is_userns_supported - Check whether an xattr is supported in userns
> + *
> + * @name:   full name of the extended attribute
> + * @prefix: do a prefix match (true) or a full match (false)
> + *
> + * This function returns < 0 if not supported, an index into userns_xattrs[]
> + * otherwise.
> + */
> +static int
> +xattr_is_userns_supported(const char *name, int prefix)
> +{
> +	int i;
> +
> +	if (!name)
> +		return -1;
> +
> +	for (i = 0; userns_xattrs[i]; i++) {
> +		if (prefix) {
> +			if (!strncmp(userns_xattrs[i], name,
> +				     strlen(userns_xattrs[i])))
> +				return i;

I think you here need to also check that the next char is either
'\0' or '.' (or maybe '@')

> +		} else {
> +			if (!strcmp(userns_xattrs[i], name))
> +				return i;
> +		}
> +	}
> +	return -1;
> +}
> +
> +/*
> + * xattr_write_uid - print a string in the format of "%s@uid=%u", which
> + *                   includes a prefix string
> + *
> + * @uid:     the uid
> + * @prefix:  prefix string; may be NULL
> + *
> + * This function returns a buffer with the string, or a NULL pointer in
> + * case of out-of-memory error.
> + */
> +static char *
> +xattr_write_uid(uid_t uid, const char *prefix)
> +{
> +	size_t buflen;
> +	char *buffer;
> +
> +	buflen = sizeof("@uid=") - 1 + sizeof("4294967295") - 1 + 1;
> +	if (prefix)
> +		buflen += strlen(prefix);
> +
> +	buffer = kmalloc(buflen, GFP_KERNEL);
> +	if (!buffer)
> +		return NULL;
> +
> +	if (uid == 0)
> +		*buffer = 0;

Do you need to print out the prefix here?

> +	else
> +		sprintf(buffer, "%s@uid=%u",
> +			(prefix) ? prefix : "",
> +			uid);
> +
> +	return buffer;
> +}
